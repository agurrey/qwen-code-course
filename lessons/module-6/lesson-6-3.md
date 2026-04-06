---
module: 6
lesson: 3
title: "Skill Descriptions and Triggers"
prerequisites: ["lesson-6-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 6.3: Skill Descriptions and Triggers

## The Problem

You created three skills: one for your Terraform configs, one for your team's React patterns, and one for database migrations. But Qwen Code is loading all three even when you are working on a simple Python script that has nothing to do with any of them. Conversely, when you open a project with both React and Terraform files, the React skill does not load because your trigger only checks for `*.tsx` files but this project uses `*.jsx`. Your skills either activate too eagerly or not at all, because the trigger configuration is not precise enough.

## Mental Model

Triggers are the routing logic that determines when a skill becomes active. Precise triggers ensure skills load only when relevant, preventing knowledge bleed between unrelated domains. The `description` field tells the model what the skill covers at a glance, helping it decide whether to apply the skill's knowledge to the current task.

## Trigger Types in Detail

Qwen Code supports three trigger mechanisms, each suited to different scenarios.

### File Pattern Triggers

Matches file extensions or glob patterns in the project:

```yaml
triggers:
  - "*.tf"
  - "*.tfvars"
  - "terraform/**/*.tf"
```

**When to use:** The skill is about a file format or technology identified by file extension or path pattern.

**Pros:** Simple, reliable, works for any project with the right files.
**Cons:** Can trigger on projects that have the file type but do not use the technology meaningfully (e.g., a `.tf` file in a tutorial repository that is not actually using Terraform).

**Best practices:**
- Use specific patterns: `"prisma/schema.prisma"` not just `"*.prisma"`
- Combine multiple patterns for confidence: `["Dockerfile", "docker-compose.yml"]`
- Avoid overly broad patterns: `"*.js"` triggers on nearly every project

### File Presence Triggers

Checks for the existence of specific files:

```yaml
triggers:
  - file: "next.config.js"
  - file: "tsconfig.json"
```

**When to use:** The presence of a specific config file indicates the technology is in use.

**Pros:** Very precise -- the file either exists or it does not.
**Cons:** Fails if the config file is named differently or located in a subdirectory.

**Best practices:**
- List alternative names: `file: "next.config.js"` and `file: "next.config.mjs"`
- Check for unique files: `package.json` is too generic, `ship.config.yaml` is specific
- Use path-qualified files: `file: "prisma/schema.prisma"` not just `file: "schema.prisma"`

### Content Triggers

Scans file contents for specific strings or patterns:

```yaml
triggers:
  - content: "useQuery"
  - content: "QueryClient"
  - content: "from '@tanstack/react-query'"
```

**When to use:** The technology is identified by code patterns rather than file names.

**Pros:** Extremely precise -- can detect specific library usage even in generic file types.
**Cons:** More expensive (requires reading file contents); can have false positives if the string appears in comments or documentation.

**Best practices:**
- Use unique identifiers: `from '@tanstack/react-query'` is better than just `useQuery`
- Avoid common words: `content: "function"` matches nearly everything
- Use multiple content triggers for confidence (ANY match activates)

## Try It: Tune Skill Triggers

### Step 1: Create skills with different trigger types

```bash
# Skill 1: File pattern triggers
mkdir -p ~/.qwen/skills/typescript
cat > ~/.qwen/skills/typescript/SKILL.md << 'EOF'
---
name: typescript
description: "TypeScript coding conventions and patterns"
triggers:
  - "*.ts"
  - "*.tsx"
  - file: "tsconfig.json"
---

# Skill: typescript

When working with TypeScript in this project:

## Type Conventions
- Use `interface` for object shapes, `type` for unions and intersections
- Avoid `any` -- use `unknown` when the type is truly uncertain
- Use readonly properties for immutable data: `readonly id: string`
- Prefer explicit return types on exported functions

## Null Safety
- Always use strict null checks
- Use optional chaining: `user?.address?.city`
- Use nullish coalescing: `value ?? defaultValue`
- Never use `!` non-null assertion unless you have verified the value

## Common Patterns
EOF
```

### Step 2: Content-triggered skill

```bash
# Skill 2: Content triggers
mkdir -p ~/.qwen/skills/fastapi
cat > ~/.qwen/skills/fastapi/SKILL.md << 'EOF'
---
name: fastapi
description: "FastAPI Python framework patterns"
triggers:
  - content: "from fastapi import"
  - content: "from fastapi import FastAPI"
  - file: "requirements.txt"
---

# Skill: fastapi

When working with FastAPI in this project:

## Route Definition
- Always use type annotations on path and query parameters
- Use Pydantic models for request/response bodies
- Use `async def` for routes that do I/O, `def` for CPU-bound routes

## Dependency Injection
- Use `Depends()` for shared logic like auth, database sessions
- Keep dependencies in `dependencies.py`
- Use `Annotated[]` for combined type + Depends

## Error Handling
- Use HTTPException for expected errors (4xx)
- Use custom exception handlers for application-level errors
- Always return structured error responses: `{"detail": message}`
EOF
```

### Step 3: Combined triggers

```bash
# Skill 3: Multiple trigger types
mkdir -p ~/.qwen/skills/docker-dev
cat > ~/.qwen/skills/docker-dev/SKILL.md << 'EOF'
---
name: docker-dev
description: "Docker development conventions"
triggers:
  - file: "Dockerfile"
  - file: "docker-compose.yml"
  - file: "docker-compose.yaml"
  - "*.dockerfile"
---

# Skill: docker-dev

When working with Docker in this project:

## Dockerfile Best Practices
- Use specific base image versions: `python:3.11-slim` not `python:latest`
- Multi-stage builds for production images
- Run as non-root user
- Minimize layers by combining RUN commands

## docker-compose Best Practices
- Use named volumes for persistent data
- Define resource limits for each service
- Use `.env` file for environment-specific values
- Health checks for services that depend on each other
EOF
```

### Step 4: Test trigger precision

Test in different project contexts:

```bash
# In a TypeScript project (has .ts files):
# Expected: typescript skill loads
cd ~/typescript-project && qwen

# In a Python project with FastAPI:
# Expected: fastapi skill loads (via content trigger)
cd ~/fastapi-project && qwen

# In a plain Python project (no FastAPI):
# Expected: fastapi skill does NOT load
cd ~/plain-python && qwen
```

## Trigger Design Decision Tree

```
What identifies the technology in the project?
    |
    +-- Specific file extension? --> File pattern trigger
    |   Example: *.tf for Terraform
    |
    +-- Specific config file? --> File presence trigger
    |   Example: next.config.js for Next.js
    |
    +-- Code patterns in files? --> Content trigger
    |   Example: "from fastapi import" for FastAPI
    |
    +-- Multiple indicators? --> Combined triggers
        Example: Dockerfile + docker-compose.yml for Docker
```

## The Description Field

The `description` field serves two purposes:

1. **Discovery:** Shown when listing available skills
2. **Context:** Helps the model understand the skill's scope

### Writing Effective Descriptions

```yaml
# Good descriptions are specific and concise
description: "TypeScript coding conventions and patterns"
description: "FastAPI Python framework patterns"
description: "Docker development conventions"

# Avoid vague descriptions
description: "Helpful stuff for coding"
description: "My skill about things"
description: "Configuration helper"
```

### Description Guidelines

- **3-8 words** -- long enough to be specific, short enough to scan
- **Mention the technology** -- "TypeScript" not "coding"
- **Mention the purpose** -- "conventions" not "stuff"
- **Use noun phrases** -- not imperative sentences

```
GOOD: "React Query data fetching patterns"
GOOD: "PostgreSQL migration conventions"
GOOD: "GraphQL schema validation rules"
AVOID: "This skill helps you with React Query"
AVOID: "Use this for database stuff"
AVOID: "A comprehensive skill for managing GraphQL schemas with validation"
```

## Debugging Triggers

### Scenario: Skill never activates

**Diagnostic steps:**

1. Verify the trigger condition exists in the project:
```bash
# For file patterns
find . -name "*.tf" -type f 2>/dev/null
# For file presence
ls next.config.js 2>/dev/null
# For content
grep -r "from fastapi import" --include="*.py" . 2>/dev/null | head -3
```

2. Verify the SKILL.md syntax:
```bash
cat ~/.qwen/skills/my-skill/SKILL.md | head -10
```

3. Check for typos in trigger format:
```yaml
# Wrong (missing quotes around glob)
triggers:
  - *.tf

# Right (quoted)
triggers:
  - "*.tf"
```

### Scenario: Skill activates too often

**Diagnostic:** Check if your trigger is too broad:

```yaml
# Too broad - triggers on any JS project
triggers:
  - "*.js"

# Better - specific to your framework
triggers:
  - file: "vite.config.js"
  - content: "from 'vue'"
```

### Scenario: Multiple skills conflict

Two skills trigger simultaneously and give contradictory instructions.

**Fix:** Make triggers mutually exclusive by adding negative conditions, or consolidate into a single skill:

```yaml
# If both vue-skill and nuxt-skill trigger on *.vue files,
# differentiate by config file:

# vue-skill
triggers:
  - "*.vue"
  - file: "vite.config.js"
  # NOT: nuxt.config.js

# nuxt-skill
triggers:
  - "*.vue"
  - file: "nuxt.config.js"
  - file: "nuxt.config.ts"
```

## Trigger Testing Checklist

For each skill, verify:

- [ ] Triggers match the intended project
- [ ] Triggers do NOT match unrelated projects
- [ ] Alternative file names are covered (`.js` and `.mjs`)
- [ ] Content triggers use unique identifiers
- [ ] File presence checks use full paths when needed
- [ ] Skill description is 3-8 words and mentions the technology

## Check Your Work

Audit your skills' triggers:

```bash
echo "=== Trigger Audit ==="
for skill_dir in ~/.qwen/skills/*/; do
  skill_name=$(basename "$skill_dir")
  skill_file="$skill_dir/SKILL.md"
  if [ -f "$skill_file" ]; then
    echo ""
    echo "Skill: $skill_name"
    echo "  Triggers:"
    grep -A 10 "^triggers:" "$skill_file" 2>/dev/null | grep "^  -" | head -5
    echo "  Description:"
    grep "^description:" "$skill_file" 2>/dev/null | head -1
  fi
done
echo "=== Done ==="
```

## What You Learned

Triggers control when skills activate, and descriptions tell the model what each skill covers -- together they ensure the right knowledge loads at the right time.

---

**Coming up next:** In Lesson 6.4, you will learn how to enhance skills with supporting files -- examples, templates, and reference documentation that give the model deeper context beyond what fits in SKILL.md.
