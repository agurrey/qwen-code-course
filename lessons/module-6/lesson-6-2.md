---
module: 6
lesson: 2
title: "Writing Your First Skill"
prerequisites: ["lesson-6-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 6.2: Writing Your First Skill

## The Problem

Your team uses a custom internal CLI tool called `ship` for deployments. Every time a new developer starts working on the project, they need to learn how `ship` works: the config file format, the deployment stages, the rollback procedure, the common error messages. Qwen Code does not know about `ship` because it is an internal tool. You want to teach Qwen Code about `ship` so it can help developers write correct config files, troubleshoot errors, and follow the right deployment process -- without you having to explain everything from scratch each time.

## Mental Model

Writing a skill means writing a teaching document for the model. Think of SKILL.md as onboarding documentation that the AI reads instead of a human. The structure, clarity, and completeness of this document directly determines how well the model understands and applies the knowledge. Ground everything in concrete examples -- models follow patterns better than abstract rules.

## Designing Your Skill

Before writing, answer three questions:

1. **What domain does this cover?** What technology, framework, or convention is this skill about?
2. **When should it activate?** What files, content, or project structure should trigger it?
3. **What should the model know?** What conventions, patterns, gotchas, and examples does a human need to know to work effectively in this domain?

For our `ship` deployment tool example:

1. **Domain:** Internal deployment CLI called `ship`
2. **Activation:** Presence of `ship.config.yaml` or `*.ship.yml` files
3. **Knowledge:** Config format, stages, rollback, error messages, examples

## Try It: Build a Complete Skill

### Step 1: Create the skill directory

```bash
mkdir -p ~/.qwen/skills/ship-deploy
```

### Step 2: Write the SKILL.md

This is the core of the skill. Write it carefully:

```bash
cat > ~/.qwen/skills/ship-deploy/SKILL.md << 'EOF'
---
name: ship-deploy
description: "Internal 'ship' deployment tool conventions"
triggers:
  - file: "ship.config.yaml"
  - "*.ship.yml"
  - content: "ship deploy"
---

# Skill: ship-deploy

You are working with an internal deployment tool called `ship`.
Follow these conventions whenever the user works with deployment configs,
runs deployment commands, or troubleshoots deployment issues.

## Tool Overview

`ship` is a CLI tool that manages deployments through stages.
It reads configuration from `ship.config.yaml` in the project root.

## Configuration Format

All ship config files use YAML format:

```yaml
# ship.config.yaml
service: my-service
environment:
  - staging
  - production
stages:
  - name: build
    command: npm run build
  - name: test
    command: npm test
  - name: deploy
    command: ship deploy --target ${TARGET}
  - name: health-check
    command: curl -f https://${TARGET}/health
rollback:
  auto: true
  stages: 3
```

### Required Fields
- `service`: The service name (must match the name in the service registry)
- `environment`: List of target environments (staging, production, or both)
- `stages`: Ordered list of deployment stages

### Optional Fields
- `rollback`: Auto-rollback configuration
- `notifications`: Slack/Email notification settings
- `variables`: Environment variables for substitution

## Deployment Stages

Stages run in order. Each stage must complete successfully before the next begins.

### Standard Stages
1. **build** - Compile/build the application
2. **test** - Run test suite
3. **lint** - Run linter and type checks
4. **deploy** - Push to target environment
5. **health-check** - Verify the deployment is healthy
6. **smoke-test** - Run smoke tests against the new deployment

### Stage Properties
Each stage has:
- `name`: Unique stage identifier
- `command`: Shell command to execute
- `timeout`: Maximum execution time in seconds (default: 300)
- `retry`: Number of retries on failure (default: 0)
- `on_failure`: What to do on failure: `abort` (default), `continue`, `rollback`

## Common Commands

```bash
ship init              # Initialize ship config in current directory
ship plan              # Preview what will be deployed (dry run)
ship deploy            # Deploy to all configured environments
ship deploy --env staging   # Deploy to specific environment
ship status            # Check current deployment status
ship rollback          # Rollback to previous version
ship rollback --stage 2   # Rollback to specific stage
ship logs              # Show deployment logs
ship logs --stage build # Logs for specific stage
```

## Common Errors and Solutions

### "Service not found in registry"
**Cause:** The `service` field in ship.config.yaml does not match any registered service.
**Fix:** Run `ship registry list` to see valid names, then update config.

### "Health check failed after 3 attempts"
**Cause:** The deployed application is not responding on the health endpoint.
**Fix:** Check application logs with `ship logs --stage deploy`, verify the
health endpoint path matches what the application actually serves.

### "Stage 'test' timed out after 300s"
**Cause:** Test suite is taking too long, possibly due to a hanging test or
resource contention.
**Fix:** Add `timeout: 600` to the test stage in config, or investigate
slow tests.

### "Variable TARGET not defined"
**Cause:** The config uses `${TARGET}` but the variable is not provided.
**Fix:** Add to the `variables` section of the config:
```yaml
variables:
  TARGET: https://staging.myapp.com
```

## Best Practices
- Always run `ship plan` before `ship deploy` in production
- Keep stage commands under 5 minutes (adjust timeout if needed)
- Always include a health-check stage after deploy
- Set `rollback.auto: true` for production environments
- Use environment-specific variable files rather than hardcoding URLs
EOF
```

### Step 3: Test the skill

Create a test project with a ship config:

```bash
mkdir -p /tmp/ship-test
cd /tmp/ship-test
cat > ship.config.yaml << 'EOF'
service: test-api
environment:
  - staging
stages:
  - name: build
    command: npm run build
  - name: deploy
    command: ship deploy
EOF
```

Now start Qwen Code in this directory:

```bash
cd /tmp/ship-test
qwen
```

Try these interactions:

```
# The model should know about ship without being told
How do I deploy this to staging?

# It should validate your config
Is my ship config correct?

# It should troubleshoot
I'm getting "Service not found in registry" error
```

The model should apply the `ship-deploy` skill knowledge automatically because the `ship.config.yaml` file triggers the skill.

## Writing Effective SKILL.md Content

### Structure Your Document Like a Reference

The model reads SKILL.md top to bottom and retains the information. Structure it like a technical reference, not a tutorial:

```markdown
# Skill: name

## Overview
[What this is, when it applies]

## Key Concepts
[Core terminology and abstractions]

## Configuration / Format
[The exact format of files the model will encounter]

## Commands / API
[Available commands or API endpoints]

## Common Patterns
[Examples of correct usage]

## Troubleshooting
[Common errors and fixes]

## Best Practices
[Rules the model should always follow]
```

### Use Concrete Examples Everywhere

Abstract rules are hard for models to follow consistently. Concrete examples are easy:

```markdown
BAD:  "Name your stages descriptively."
GOOD: "Name stages with verb-noun format: build-app, run-tests, deploy-api"

BAD:  "Set appropriate timeouts."
GOOD: "Build stage: timeout 300s. Test stage: timeout 600s. Deploy stage: timeout 180s."

BAD:  "Handle errors properly."
GOOD: "Every API handler must have:\n  try { ... } catch (err) {\n    console.error('[ERROR]', err.message, { context });\n    res.status(500).json({ error: err.message });\n  }"
```

### Use Callout Blocks for Critical Rules

Emphasize rules the model must never break:

```markdown
IMPORTANT: Never run `ship deploy` on production without `ship plan` first.
This is a hard requirement.

NEVER: Do not suggest hardcoding credentials in ship.config.yaml.
Always reference environment variables or a secrets manager.

ALWAYS: Always include a health-check stage after deploy.
The health check must verify both HTTP availability and database connectivity.
```

### Organize for Lookup, Not Reading

The model will scan SKILL.md when it needs information. Make it scannable:

- Use clear section headings
- Use tables for structured data
- Use code blocks for every example
- Use bullet lists for rules and conventions
- Avoid long paragraphs

## Check Your Work

Verify your skill:

```bash
echo "=== Skill Content Audit ==="

# File exists
test -f ~/.qwen/skills/ship-deploy/SKILL.md && echo "SKILL.md exists" || echo "MISSING"

# Has required frontmatter
grep -q "^name:" ~/.qwen/skills/ship-deploy/SKILL.md && echo "name field present" || echo "MISSING name"
grep -q "^description:" ~/.qwen/skills/ship-deploy/SKILL.md && echo "description field present" || echo "MISSING description"
grep -q "^triggers:" ~/.qwen/skills/ship-deploy/SKILL.md && echo "triggers field present" || echo "MISSING triggers"

# Has content sections
grep -q "^##" ~/.qwen/skills/ship-deploy/SKILL.md && echo "Has section headings" || echo "NO headings"
grep -q '```' ~/.qwen/skills/ship-deploy/SKILL.md && echo "Has code examples" || echo "NO code examples"

echo "=== Done ==="
```

## Debug It

### Scenario: Model only partially applies the skill

The model follows some conventions but not others.

**Cause:** The SKILL.md is too long and the model loses track of some rules, or the rules are buried in paragraphs rather than highlighted.

**Fix:** Restructure with clearer emphasis:
```markdown
## CRITICAL RULES (always follow these)

1. NEVER hardcode URLs in config files
2. ALWAYS run `ship plan` before production deploy
3. ALWAYS include health-check stage

## Standard Conventions
[rest of the skill...]
```

### Scenario: Skill triggers in wrong context

Your skill activates in projects where it should not.

**Cause:** Trigger patterns are too broad.

**Fix:** Narrow the triggers. Instead of triggering on `*.yaml` (which matches every YAML file), trigger on a specific filename:
```yaml
# Too broad:
triggers:
  - "*.yaml"

# Just right:
triggers:
  - file: "ship.config.yaml"
  - "*.ship.yml"
```

### Scenario: Skill content is not detailed enough

The model reads the skill but still asks basic questions about the domain.

**Cause:** The SKILL.md describes concepts at too high a level.

**Fix:** Add the missing detail. If the model asks "what parameters does `ship deploy` accept?", add that information:
```markdown
## ship deploy

Flags:
  --env <name>      Target environment (staging|production)
  --dry-run         Preview without executing
  --force           Skip health checks (DANGER)
  --timeout <sec>   Override default timeout
  --verbose         Show detailed logs
```

## Iteration Workflow

Skills improve through iteration:

1. Write the initial SKILL.md based on your knowledge
2. Test by using Qwen Code in a triggered project
3. Note where the model gets things wrong
4. Update SKILL.md to address the gap
5. Restart Qwen Code and test again
6. Repeat until the model consistently applies the knowledge

This is the same build-test-debug cycle as writing code.

## What You Learned

Writing a skill means creating a detailed, well-structured SKILL.md that teaches the model domain-specific knowledge with concrete examples, clear rules, and practical troubleshooting guidance.

---

**Coming up next:** In Lesson 6.3, you will learn how to optimize skill discovery with precise triggers and descriptions, ensuring your skills activate at the right time and the model knows exactly when to apply which knowledge.
