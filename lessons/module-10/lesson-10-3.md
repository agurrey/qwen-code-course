---
module: 10
lesson: 3
title: "Project-Level Memory"
prerequisites: ["module-10/lesson-10-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

Your MEMORY.md says "use pytest" but this one legacy project uses unittest. Your MEMORY.md says "use TypeScript" but this utility script project is plain Python. Every time you open the project, you spend five minutes explaining what makes this project different. Project-level memory solves this by giving Qwen Code a project-specific briefing that overrides your global preferences.

## Mental Model

QWEN.md is the **project's README for Qwen Code** — it contains everything Qwen Code needs to know to be productive in this specific project, including overrides of global preferences, structural conventions, and domain knowledge that would otherwise take twenty minutes to explain.

## Try It

You'll create QWEN.md files for two different projects and see how they shape Qwen Code's behavior.

### Create your first QWEN.md

Set up a project directory:

```bash
mkdir -p /tmp/web-api && cd /tmp/web-api
```

Create the QWEN.md file:

```markdown
# Web API Project

## What This Is
A REST API built with FastAPI for managing user accounts and sessions.

## Structure
```
src/
├── api/          # Route handlers
├── models/       # SQLAlchemy models
├── schemas/      # Pydantic request/response schemas
├── services/     # Business logic
└── main.py       # Application entry point
tests/
├── test_api/
├── test_models/
└── conftest.py   # Shared fixtures
```

## Conventions
- All route handlers in src/api/ with HTTP method prefix (get_users, post_user)
- Database models use SQLAlchemy with declarative base
- Every endpoint has a corresponding test in tests/
- Error responses use the format: {"error": "message", "status_code": 400}
- API versioning via URL prefix: /api/v1/...

## Testing
- This project uses pytest (overrides global preference if different)
- Fixtures in conftest.py provide test database sessions
- Run tests with: pytest tests/ -v
- Test database is SQLite in-memory, never connect to real DB

## Important Constraints
- Never hardcode credentials — use os.environ.get()
- The Alembic migration config is in alembic.ini — use alembic for schema changes
- Rate limiting is handled by the middleware in src/middleware.py — don't add per-route limits
```

Now ask Qwen Code questions about the project:

```
where should I add a new endpoint for password reset?
```

**Expected output**: Qwen Code should suggest `src/api/post_password_reset.py` following the route handler naming convention, and mention it needs a corresponding test in `tests/test_api/`.

```
how do I run the tests?
```

**Expected output**: Qwen Code should say `pytest tests/ -v` and mention the in-memory SQLite database.

### QWEN.md vs MEMORY.md: what goes where

The rule is simple: **if it's about you, MEMORY.md. If it's about the project, QWEN.md.**

| Goes in MEMORY.md | Goes in QWEN.md |
|---|---|
| "I use pytest" | "This project uses unittest" |
| "snake_case for functions" | "Route handlers use HTTP prefix naming" |
| "Always run tests before committing" | "Test database is SQLite in-memory" |
| "TypeScript only, no plain JS" | "This utility project is plain Python" |
| "Descriptive commit messages" | "Branch naming: feature/jira-number-description" |

### QWEN.md for a team project

When multiple people use Qwen Code on the same project, QWEN.md becomes the **team's shared instructions**. Everyone benefits from the same context.

```markdown
# Team Project — E-Commerce Platform

## For Qwen Code

### Code Organization
- Feature modules in src/features/ (one feature per module)
- Shared utilities in src/lib/
- Components in src/components/ (one per file, named PascalCase)

### Code Review Standards
- Every PR needs 2 approvals
- Run `npm run lint` and `npm run typecheck` before requesting review
- No console.log in production code — use the logger utility

### Deployment
- Staging: merge to develop branch, auto-deploys
- Production: merge to main branch, requires manual approval
- Never deploy on Fridays

### Gotchas
- The payment service has a 30-second timeout — keep handlers under 25 seconds
- User session data is cached for 5 minutes — clear cache after profile updates
- The /admin routes bypass rate limiting — be extra careful with validation
```

Commit this QWEN.md to the repository so the whole team shares the same context:

```bash
git add QWEN.md
git commit -m "Add QWEN.md for Qwen Code project context"
```

### When to NOT use QWEN.md

Not every project needs a QWEN.md. Skip it when:

- **The project is small** (one or two files) — conventions are obvious from the code
- **The project is self-documenting** — well-structured code with clear names tells Qwen Code everything it needs
- **You only work on it once** — one-off scripts don't benefit from persistent memory

Use QWEN.md when the project has non-obvious conventions, structural decisions, or constraints that Qwen Code can't infer from reading the files.

### Multiple QWEN.md files in large projects

For large projects with multiple sub-projects, you can have QWEN.md files at different levels:

```
monorepo/
├── QWEN.md              # Top-level: general conventions for all sub-projects
├── services/api/
│   └── QWEN.md          # API-specific: routes, models, testing
├── services/web/
│   └── QWEN.md          # Web-specific: components, styling, SSR
└── tools/
    └── QWEN.md          # Tools: utility scripts, no testing framework
```

Qwen Code reads the nearest QWEN.md upward from your current directory. If you're working in `services/api/`, it reads both the top-level and the API-level QWEN.md. The more specific one (closer to you) takes precedence for conflicting instructions.

## Check Your Work

1. Verify your QWEN.md covers the essentials:

```bash
cat /tmp/web-api/QWEN.md
```

Should have: project description, structure, conventions, testing instructions, and important constraints.

2. Test that Qwen Code uses the project context:

```
what database does this project use for testing?
```
Expected: "SQLite in-memory" (from QWEN.md)

3. Verify that project-level overrides work:

```
what testing framework should I use?
```
Expected: "pytest for this project" even if your MEMORY.md says something different.

## Debug It

1. **"Qwen Code isn't reading my QWEN.md."** The file must be at the root of the directory where you started Qwen Code. If you ran `qwen` from inside `src/`, it won't find the QWEN.md in the parent directory. Start from the project root, or copy QWEN.md to your working directory.

2. **"My QWEN.md is too long and Qwen Code seems to ignore parts of it."** Long QWEN.md files (>100 lines) risk being partially forgotten. Trim it down:
   - Remove anything obvious from the code itself
   - Remove anything that's already in MEMORY.md
   - Focus on non-obvious conventions and constraints
   - Move general documentation to a real README.md

3. **"Team members are overriding my QWEN.md with their personal preferences."** This is why MEMORY.md and QWEN.md are separate. Personal preferences belong in MEMORY.md (which each person controls). Project conventions belong in QWEN.md (which the team controls). If someone puts personal preferences in QWEN.md, they're polluting shared context.

## What You Learned

QWEN.md gives Qwen Code project-specific knowledge — structure, conventions, and constraints — that overrides global preferences and eliminates repetitive explanations for each project.

*Next: Lesson 10.4 — Memory Maintenance — You'll learn how to update, prune, and consolidate memory files before they grow into unmaintainable walls of text.*
