---
module: 6
lesson: 4
title: "Skills with Supporting Files"
prerequisites: ["lesson-6-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 6.4: Skills with Supporting Files

## The Problem

Your SKILL.md for the internal API framework has grown to 500 lines. It contains configuration format, API endpoint reference tables, error handling patterns, authentication flows, pagination conventions, and six different example implementations. It is too long for the model to retain everything effectively, and it mixes reference material (endpoint tables) with instructions (conventions to follow). You need a way to organize this knowledge so the SKILL.md stays focused and the model can look up detailed reference material when needed.

## Mental Model

A skill is a directory, not just a file. The SKILL.md contains the core instructions and conventions, while supporting files provide examples, templates, and reference documentation that the model can read on demand. Think of SKILL.md as the table of contents and rules, and supporting files as the appendix -- the model knows to look in the skill directory for additional context when it needs detail.

## The Skill Directory Structure

A skill with supporting files follows this structure:

```
.qwen/skills/api-framework/
  SKILL.md              # Core instructions (required)
  reference.md          # Detailed API reference
  examples/
    basic-endpoint.py   # Minimal example
    authenticated.py    # With auth
    paginated.py        # With pagination
  templates/
    new-endpoint.md     # Template for creating endpoints
  schemas/
    request.json        # Request schema
    response.json       # Response schema
```

The model can read any file in the skill directory when the skill is active. You reference these files from SKILL.md so the model knows they exist and when to consult them.

## Why Supporting Files Matter

### Separation of Concerns

SKILL.md should contain:
- Core conventions and rules
- Critical instructions the model must always follow
- Overview of the domain

Supporting files should contain:
- Detailed reference tables (too large for SKILL.md)
- Complete working examples (too verbose for inline)
- Templates for generating new code
- Schema definitions
- Historical context or decision records

### Reduced Cognitive Load

When SKILL.md is concise (200-400 lines), the model retains and applies the core rules more reliably. Detailed reference material lives in separate files that the model consults when it needs specifics.

```markdown
# In SKILL.md - concise overview

## Pagination
All list endpoints MUST support pagination.
See `examples/paginated.py` for a complete example.
See `reference.md` for the full pagination parameter table.

# In reference.md - detailed spec

## Pagination Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | int | No | 1 | Page number |
| per_page | int | No | 20 | Items per page (max: 100) |
| cursor | string | No | null | Cursor for cursor-based pagination |
| ... | ... | ... | ... | ... |
```

## Try It: Build a Skill with Supporting Files

### Step 1: Create the skill directory structure

```bash
mkdir -p ~/.qwen/skills/api-framework/examples
mkdir -p ~/.qwen/skills/api-framework/templates
mkdir -p ~/.qwen/skills/api-framework/schemas
```

### Step 2: Write the core SKILL.md

```bash
cat > ~/.qwen/skills/api-framework/SKILL.md << 'EOF'
---
name: api-framework
description: "Internal REST API framework conventions"
triggers:
  - file: "src/api/framework.py"
  - content: "from api.framework import"
---

# Skill: api-framework

This project uses an internal REST API framework located in `src/api/framework.py`.
Follow these conventions when creating or modifying API endpoints.

## Endpoint Structure

All endpoints inherit from `BaseEndpoint` and follow this pattern:

```python
from api.framework import BaseEndpoint, Response, paginate

class UserListEndpoint(BaseEndpoint):
    """List all users with pagination."""

    @paginate(per_page=20, max_per_page=100)
    def get(self):
        users = User.query.all()
        return Response(data=users)
```

See `examples/basic-endpoint.py` for a minimal example.

## Response Format

All responses must use the `Response` wrapper:

```python
Response(data=user)                    # 200 OK
Response(data=user, status=201)        # 201 Created
Response(error="Not found", status=404)  # 404
Response(error="Unauthorized", status=401)  # 401
```

Never return raw dictionaries from endpoints.

## Authentication

Endpoints that require auth must use the `@require_auth` decorator:

```python
from api.framework import require_auth

class UserProfileEndpoint(BaseEndpoint):
    @require_auth
    def get(self, user_id: int):
        # request.user is available after @require_auth
        return Response(data=request.user.profile)
```

See `examples/authenticated.py` for the full pattern including token validation.

## Pagination

All list endpoints must use the `@paginate` decorator.
See `examples/paginated.py` for usage.
See `reference.md` for the complete parameter table.

## Error Handling

```python
from api.framework import APIError

# Raise for expected errors
raise APIError("User not found", status=404)
raise APIError("Invalid email", status=400, code="INVALID_EMAIL")

# Framework converts these to proper JSON responses:
# {"error": "User not found", "status": 404}
# {"error": "Invalid email", "status": 400, "code": "INVALID_EMAIL"}
```

## Creating a New Endpoint

1. Create the endpoint class in the appropriate module
2. Register it in `src/api/routes.py`
3. Add tests in the corresponding `*_test.py` file
4. Document the endpoint in the OpenAPI spec

Use the template in `templates/new-endpoint.md` as a starting point.

## Schema Validation

Request bodies must be validated against schemas in `schemas/`.
Use the `@validate(schema_name)` decorator:

```python
from api.framework import validate

class CreateUserEndpoint(BaseEndpoint):
    @validate("schemas/request.json")
    def post(self):
        return Response(data=User.create(request.validated_data), status=201)
```
EOF
```

### Step 3: Create supporting examples

```bash
cat > ~/.qwen/skills/api-framework/examples/basic-endpoint.py << 'PYEOF'
"""Minimal API endpoint example."""

from api.framework import BaseEndpoint, Response


class HealthEndpoint(BaseEndpoint):
    """Health check endpoint - returns service status."""

    def get(self):
        """GET /health - Check service health."""
        return Response(data={
            "status": "healthy",
            "version": "1.0.0"
        })


class UserDetailEndpoint(BaseEndpoint):
    """Get a single user by ID."""

    def get(self, user_id: int):
        """GET /users/<user_id> - Get user details."""
        user = User.query.get(user_id)
        if not user:
            return Response(error="User not found", status=404)
        return Response(data=user.to_dict())
PYEOF
```

```bash
cat > ~/.qwen/skills/api-framework/examples/authenticated.py << 'PYEOF'
"""Authenticated endpoint example."""

from api.framework import BaseEndpoint, Response, require_auth


class UserProfileEndpoint(BaseEndpoint):
    """Get the authenticated user's profile."""

    @require_auth
    def get(self):
        """GET /me - Get current user profile."""
        # request.user is set by @require_auth
        return Response(data={
            "id": request.user.id,
            "email": request.user.email,
            "name": request.user.name,
        })

    @require_auth
    def patch(self):
        """PATCH /me - Update user profile."""
        updates = request.get_json()
        request.user.update(updates)
        return Response(data=request.user.to_dict())
PYEOF
```

```bash
cat > ~/.qwen/skills/api-framework/examples/paginated.py << 'PYEOF'
"""Paginated list endpoint example."""

from api.framework import BaseEndpoint, Response, paginate


class UserListEndpoint(BaseEndpoint):
    """List users with pagination support."""

    @paginate(per_page=20, max_per_page=100)
    def get(self):
        """
        GET /users?page=1&per_page=20

        Query Parameters:
            page (int): Page number (default: 1)
            per_page (int): Items per page (default: 20, max: 100)
            search (str): Optional search filter

        Response:
            {
                "data": [...],
                "pagination": {
                    "page": 1,
                    "per_page": 20,
                    "total": 150,
                    "pages": 8,
                    "next": "/users?page=2&per_page=20",
                    "prev": null
                }
            }
        """
        search = request.args.get("search")
        query = User.query
        if search:
            query = query.filter(User.name.ilike(f"%{search}%"))
        return Response(data=query.all())
PYEOF
```

### Step 4: Create a template

```bash
cat > ~/.qwen/skills/api-framework/templates/new-endpoint.md << 'EOF'
# New Endpoint Template

Copy this template and fill in the sections:

```python
from api.framework import BaseEndpoint, Response, require_auth, paginate, validate


class {{EndpointName}}Endpoint(BaseEndpoint):
    """{{Description of what this endpoint does}}."""

    @require_auth  # Remove if public
    @validate("schemas/{{request_schema}}.json")  # Remove if no body
    def {{method}}(self{{, params}}):
        """{{HTTP_METHOD}} {{/url/path}} - {{Brief description}}."""
        # Implementation
        return Response(data={{result}}{{, status=201}})
```

## Checklist
- [ ] Endpoint class inherits from BaseEndpoint
- [ ] Docstring describes the endpoint
- [ ] Method docstring has HTTP method, path, and description
- [ ] @require_auth if endpoint needs authentication
- [ ] @validate if endpoint accepts request body
- [ ] @paginate if endpoint returns a list
- [ ] Response uses Response wrapper (never raw dict)
- [ ] Tests added in corresponding test file
- [ ] Route registered in src/api/routes.py
EOF
```

### Step 5: Create a schema example

```bash
cat > ~/.qwen/skills/api-framework/schemas/request.json << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["name", "email"],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100,
      "description": "User's full name"
    },
    "email": {
      "type": "string",
      "format": "email",
      "description": "User's email address"
    },
    "role": {
      "type": "string",
      "enum": ["admin", "user", "viewer"],
      "default": "user",
      "description": "User's role in the system"
    }
  },
  "additionalProperties": false
}
EOF
```

### Step 6: Test the skill

Start Qwen Code in a project that triggers the skill:

```bash
mkdir -p /tmp/api-test/src/api
touch /tmp/api-test/src/api/framework.py
cd /tmp/api-test
qwen
```

Try these interactions:

```
# The model should know the framework
How do I create a new endpoint for listing orders?

# It should reference examples
Show me how to add authentication to my endpoint

# It should use the template
Generate a new endpoint for updating user preferences
```

## Referencing Supporting Files

The key to making supporting files effective is explicit references in SKILL.md:

```markdown
## Pattern Name
Brief description of the pattern.

Example: See `examples/specific-example.py` for a complete working example.
Template: Use `templates/new-thing.md` as a starting point.
Reference: See `reference.md` section "Topic Name" for full details.
Schema: Validate against `schemas/thing.json`.
```

Always use paths relative to the skill directory. The model understands these paths and can read the files when needed.

## When to Use Supporting Files

| Content Type | Put In |
|-------------|--------|
| Core rules and conventions | SKILL.md |
| Critical "always do this" instructions | SKILL.md |
| Complete working code examples | `examples/` |
| Templates for generating code | `templates/` |
| Large reference tables | `reference.md` |
| Schema/contract definitions | `schemas/` |
| Historical decisions/ADRs | `decisions/` |
| Test fixtures | `tests/` |

## Check Your Work

Verify your skill structure:

```bash
echo "=== Supporting Files Audit ==="
echo ""
echo "Skill directory:"
find ~/.qwen/skills/api-framework/ -type f | sort

echo ""
echo "SKILL.md references examples:"
grep -o 'examples/[^ `"]*' ~/.qwen/skills/api-framework/SKILL.md 2>/dev/null | sort -u

echo ""
echo "SKILL.md references templates:"
grep -o 'templates/[^ `"]*' ~/.qwen/skills/api-framework/SKILL.md 2>/dev/null | sort -u

echo ""
echo "SKILL.md references schemas:"
grep -o 'schemas/[^ `"]*' ~/.qwen/skills/api-framework/SKILL.md 2>/dev/null | sort -u

echo "=== Done ==="
```

## Debug It

### Scenario: Model does not reference supporting files

The model follows SKILL.md conventions but never looks at the example files.

**Fix:** Add more explicit references in SKILL.md and tell the model to consult them:

```markdown
## Pagination
All list endpoints must use @paginate.
IMPORTANT: Before implementing a paginated endpoint, read examples/paginated.py
for the complete pattern including the response format.
```

### Scenario: Example files are outdated

The supporting files do not match the current conventions in SKILL.md.

**Fix:** Treat supporting files as code -- update them when conventions change, and review them periodically. Add a "last updated" comment to example files:

```python
# examples/paginated.py
# Last updated: 2025-01-15
# Matches SKILL.md pagination spec v2
```

### Scenario: Too many supporting files

Your skill directory has 20 files and is hard to navigate.

**Fix:** Split into multiple skills. If one skill covers "the API framework" and has examples for auth, pagination, validation, websockets, and file uploads, these should be separate skills with specific triggers:

```
~/.qwen/skills/
  api-auth/
    SKILL.md
    examples/
  api-pagination/
    SKILL.md
    examples/
  api-validation/
    SKILL.md
    schemas/
```

## What You Learned

Supporting files extend a skill's knowledge beyond SKILL.md, providing examples, templates, and reference material that the model reads on demand.

---

**Coming up next:** In Lesson 6.5, the final lesson of this module, you will learn the decision framework for choosing between skills and commands -- understanding when each approach is appropriate and how they complement each other.
