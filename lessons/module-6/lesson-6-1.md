---
module: 6
lesson: 1
title: "What Are Skills"
prerequisites: ["lesson-5-5"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 6.1: What Are Skills

## The Problem

Commands are great for workflows you explicitly trigger -- you type `/commit` or `/daily-note` and the model executes your instructions. But some capabilities should not require you to remember a command name. When you open a project that uses Terraform, Qwen Code should know how to validate your infrastructure configs without you asking. When you are working in a codebase that uses a proprietary internal framework, the model should understand your project's conventions automatically. You need a way to teach Qwen Code about domain-specific knowledge that activates contextually.

## Mental Model

Skills are domain-specific capabilities that Qwen Code discovers automatically. While commands are workflows you trigger with a slash, skills are knowledge the model absorbs about a specific technology, framework, or domain. A skill consists of a `SKILL.md` file (the primary definition) and optionally supporting files. When Qwen Code detects that a skill is relevant -- based on file types, project structure, or content -- it loads the skill's instructions and applies them automatically to its reasoning.

## Commands vs Skills: The Core Difference

Before diving into skills, it is critical to understand how they differ from the custom commands you built in Module 5:

| Aspect | Commands | Skills |
|--------|----------|--------|
| **Activation** | User types `/command-name` | Auto-discovered based on context |
| **Purpose** | Execute a specific workflow | Add domain knowledge to the model |
| **Trigger** | Explicit | Implicit (contextual) |
| **Example** | `/git/commit` generates a commit message | A "terraform" skill means the model knows Terraform conventions whenever you work with `.tf` files |
| **Analogy** | A tool you pick up and use | A subject-matter expert in the room |

Commands answer "do this specific task." Skills answer "now that you are working in this domain, here is what you need to know."

## How Skill Discovery Works

Qwen Code discovers skills through a file called `SKILL.md`. The discovery process works like this:

```
Qwen Code starts (or directory changes)
    |
    v
Scans for SKILL.md files in:
  - .qwen/skills/<skill-name>/SKILL.md  (project-level)
  - ~/.qwen/skills/<skill-name>/SKILL.md (user-level)
    |
    v
Each SKILL.md contains:
  - Frontmatter with name, description, triggers
  - Instructions for the model
    |
    v
When context matches a skill's triggers:
  - Skill instructions are loaded
  - Model applies the knowledge automatically
```

### Discovery Locations

Skills can live in two places, paralleling the command system:

| Location | Scope | Example |
|----------|-------|---------|
| `~/.qwen/skills/<name>/SKILL.md` | User-level, all projects | Personal knowledge (your company's internal patterns) |
| `.qwen/skills/<name>/SKILL.md` | Project-level, this project | Project-specific knowledge (this repo's architecture) |

### The SKILL.md File

Every skill is anchored by a single `SKILL.md` file. This file contains:

```markdown
---
name: skill-name
description: "What this skill does"
---

# Skill: skill-name

[Instructions and knowledge for the model go here.]
```

The frontmatter provides metadata. The body provides domain knowledge that the model internalizes when the skill is active.

## Anatomy of a Skill

A minimal skill has just the `SKILL.md` file:

```
.qwen/skills/terraform/SKILL.md
```

A more complex skill can include supporting files:

```
.qwen/skills/terraform/
  SKILL.md              # Primary definition
  examples/             # Reference examples
    main.tf
    variables.tf
  templates/            # Templates the skill references
    module-template.md
  reference.md          # Detailed reference documentation
```

The model can read any file within the skill directory when the skill is active. This lets you provide examples, templates, and detailed reference material that grounds the model's responses in your specific context.

## Try It: Explore Existing Skills

### Step 1: Check for existing skills

Look for any skills already present on your system:

```bash
# Check user-level skills
ls -la ~/.qwen/skills/ 2>/dev/null || echo "No user-level skills yet"

# Check if Qwen Code has bundled skills
find / -path "*/skills/*/SKILL.md" -type f 2>/dev/null | head -10
```

### Step 2: Create your skills directory

```bash
mkdir -p ~/.qwen/skills
```

This is where your personal skills will live.

### Step 3: Understand the structure

A skill is a directory with a required `SKILL.md` file:

```
~/.qwen/skills/
  my-skill/
    SKILL.md           # Required
    reference.md       # Optional
    examples/          # Optional
```

Every skill you write will follow this structure.

## Skill Triggers

Skills activate based on **triggers** defined in the frontmatter. There are several trigger types:

### File Pattern Triggers

The skill activates when files matching a pattern exist in the project:

```yaml
---
name: terraform
description: "Terraform infrastructure as code conventions"
triggers:
  - "*.tf"
  - "*.tfvars"
---
```

When Qwen Code sees `.tf` files in your project, it loads the Terraform skill automatically.

### Content Triggers

The skill activates when certain content is detected:

```yaml
---
name: react-query
description: "React Query data fetching patterns"
triggers:
  - content: "useQuery"
  - content: "QueryClient"
---
```

When Qwen Code encounters `useQuery` or `QueryClient` in the codebase, it loads the React Query skill.

### File Presence Triggers

The skill activates when a specific file exists:

```yaml
---
name: nextjs
description: "Next.js application conventions"
triggers:
  - file: "next.config.js"
  - file: "next.config.mjs"
---
```

### Combined Triggers

You can combine trigger types:

```yaml
---
name: prisma
description: "Prisma ORM conventions"
triggers:
  - "*.prisma"
  - file: "prisma/schema.prisma"
  - content: "@prisma/client"
---
```

The skill activates if ANY of these conditions are met.

## Try It: Create Your First Skill

Let us create a simple skill that teaches your team's coding conventions.

### Step 1: Create the skill directory

```bash
mkdir -p ~/.qwen/skills/team-conventions
```

### Step 2: Create the SKILL.md file

```bash
cat > ~/.qwen/skills/team-conventions/SKILL.md << 'EOF'
---
name: team-conventions
description: "Our team's coding conventions and patterns"
triggers:
  - "*.js"
  - "*.ts"
  - "*.py"
---

# Skill: team-conventions

When working on this project, follow these conventions:

## Naming
- Use kebab-case for file names: `user-service.js`
- Use PascalCase for component/class names: `UserService`
- Use camelCase for variables and functions: `getUserData()`

## Architecture
- All API handlers go in `src/api/`
- All database models go in `src/models/`
- All utilities go in `src/utils/`
- Tests live next to source files: `user-service.test.js`

## Code Style
- Use async/await, never use raw Promises
- Always handle errors with try/catch in API handlers
- Log errors with: `console.error('[ERROR]', message, context)`
- Maximum function length: 30 lines

## Git
- Follow conventional commits format
- Reference ticket numbers in commit messages
EOF
```

### Step 3: Test the skill

Open Qwen Code in a project that has JavaScript or TypeScript files:

```bash
cd ~/your-js-project
qwen
```

Ask a general question like "how should I structure this new API handler?" The model should apply your team's conventions without you having to mention them.

## Check Your Work

Verify your skill setup:

```bash
echo "=== Skills Audit ==="
test -d ~/.qwen/skills && echo "Skills directory exists" || echo "MISSING"
find ~/.qwen/skills/ -name "SKILL.md" -type f 2>/dev/null | while read f; do
  echo ""
  echo "File: $f"
  grep -E "^name:|^description:|^triggers:" "$f" 2>/dev/null
done
echo "=== Done ==="
```

## Debug It

### Scenario: Skill not loading

You created a `SKILL.md` but the model does not apply the knowledge.

**Cause 1: Triggers not matching**
Check that your triggers actually match the current project:
```bash
# For file pattern triggers
find . -name "*.tf" -type f 2>/dev/null | head -5
# For file presence triggers
ls next.config.js 2>/dev/null || echo "File not present"
```

**Fix:** Adjust triggers to match your actual project structure.

**Cause 2: Wrong file name**
```bash
# Must be exactly SKILL.md (case-sensitive)
ls ~/.qwen/skills/my-skill/
# If you have skill.md (lowercase), rename it:
mv ~/.qwen/skills/my-skill/skill.md ~/.qwen/skills/my-skill/SKILL.md
```

### Scenario: Skill loads but model ignores it

The skill is discovered but the model does not follow the instructions.

**Fix:** Make instructions more explicit and prominent. The model processes SKILL.md content as domain knowledge -- frame it as conventions to follow, not suggestions:

```markdown
BAD:  "You might want to consider using kebab-case for files"
GOOD: "ALWAYS use kebab-case for file names. Example: user-service.js"
```

## Skill Discovery Flowchart

```
Does .qwen/skills/<name>/SKILL.md exist?
  |
  +-- YES: Load the skill
  |    |
  |    v
  |   Check triggers against project
  |    |
  |    +-- Trigger matches: Skill is ACTIVE
  |    +-- No trigger match: Skill stays dormant
  |
  +-- NO: Check ~/.qwen/skills/<name>/SKILL.md
       |
       +-- YES: Same trigger check process
       +-- NO: Skill does not exist
```

## Key Concepts Summary

| Concept | Details |
|---------|---------|
| SKILL.md | Required anchor file for every skill |
| Discovery locations | `~/.qwen/skills/` (user) and `.qwen/skills/` (project) |
| Triggers | File patterns, content matches, file presence |
| Activation | Automatic when triggers match project context |
| Supporting files | Any additional files in the skill directory |

## What You Learned

Skills are domain-specific knowledge stored in `SKILL.md` files that Qwen Code discovers and activates automatically based on project context and triggers.

---

**Coming up next:** In Lesson 6.2, you will write a complete skill from scratch for a real technology, learning how to structure the SKILL.md content so the model actually follows your conventions.
