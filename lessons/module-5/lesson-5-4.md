---
module: 5
lesson: 4
title: "Organizing Commands"
prerequisites: ["lesson-5-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 5.4: Organizing Commands

## The Problem

You now have a dozen custom commands: `/daily-note`, `/commit`, `/review`, `/test`, `/standup`, `/retrospective`, `/pr-summary`, `/changelog`, `/deploy-check`. They are all sitting in `~/.qwen/commands/` as a flat list. When you type `/` to browse available commands, the list is unwieldy and you cannot remember which command does what. You need a way to group related commands so they stay discoverable and maintainable as your collection grows.

## Mental Model

Qwen Code supports command namespacing through directory structure. Instead of putting every command in a single flat directory, you create subdirectories like `~/.qwen/commands/git/` and `~/.qwen/commands/docs/`. Commands in subdirectories are invoked with a namespace prefix: `/git/commit`, `/docs/changelog`. This gives you unlimited organization with zero configuration.

## The Flat Directory Problem

A flat commands directory looks like this:

```
~/.qwen/commands/
  daily-note.md
  commit.md
  review.md
  test.md
  standup.md
  retrospective.md
  pr-summary.md
  changelog.md
  deploy-check.md
  release-notes.md
  api-docs.md
  onboarding.md
```

Fifteen commands in one directory. When you type `/`, they all appear in one long list. Some are git-related, some are documentation-related, some are CI/CD-related, but there is no visible grouping.

## The Namespaced Solution

With namespaced subdirectories:

```
~/.qwen/commands/
  daily-note.md
  git/
    commit.md
    review.md
    pr-summary.md
  docs/
    changelog.md
    api-docs.md
    onboarding.md
  ci/
    test.md
    deploy-check.md
    release-notes.md
  team/
    standup.md
    retrospective.md
```

Now when you type `/`, you see both top-level commands AND namespace prefixes:

```
/daily-note
/git/
/docs/
/ci/
/team/
```

Typing `/git/` then shows:

```
/git/commit
/git/review
/git/pr-summary
```

This is the same convention used by programming language modules, CSS methodologies, and API routing. Namespaces prevent name collisions and make commands self-documenting.

## Try It: Reorganize Your Commands

### Step 1: See your current command layout

```bash
echo "=== Current commands in ~/.qwen/commands/ ==="
find ~/.qwen/commands/ -name "*.md" -type f 2>/dev/null | sort
```

### Step 2: Create namespace directories

Create subdirectories for logical groupings:

```bash
mkdir -p ~/.qwen/commands/git
mkdir -p ~/.qwen/commands/docs
mkdir -p ~/.qwen/commands/ci
```

### Step 3: Move commands into namespaces

Move existing commands into their appropriate namespaces:

```bash
# Git-related
mv ~/.qwen/commands/commit.md ~/.qwen/commands/git/commit.md 2>/dev/null
mv ~/.qwen/commands/review.md ~/.qwen/commands/git/review.md 2>/dev/null

# Docs related
mv ~/.qwen/commands/changelog.md ~/.qwen/commands/docs/changelog.md 2>/dev/null
mv ~/.qwen/commands/api-docs.md ~/.qwen/commands/docs/api-docs.md 2>/dev/null

# CI/CD related
mv ~/.qwen/commands/test.md ~/.qwen/commands/ci/test.md 2>/dev/null
mv ~/.qwen/commands/deploy-check.md ~/.qwen/commands/ci/deploy-check.md 2>/dev/null

echo "Done reorganizing"
```

Note: Commands that do not exist yet will produce "No such file" errors -- that is fine, the `2>/dev/null` suppresses them.

### Step 4: Verify the new structure

```bash
echo "=== New command structure ==="
find ~/.qwen/commands/ -name "*.md" -type f 2>/dev/null | sort
```

You should see the namespaced hierarchy.

### Step 5: Test namespaced commands

Start Qwen Code and try:

```
/git/commit
/docs/changelog
/ci/test
```

Each should work exactly as before. The command content has not changed -- only its location and therefore its invocation path.

## Namespace Design Patterns

### Pattern 1: By Tool or Technology

Group commands by the tool they interact with:

```
~/.qwen/commands/
  git/          # All git-related commands
    commit.md
    rebase.md
    pr.md
  docker/       # Docker commands
    build.md
    compose.md
    clean.md
  db/           # Database commands
    migrate.md
    seed.md
    backup.md
```

### Pattern 2: By Workflow Phase

Group commands by when you use them:

```
~/.qwen/commands/
  start/        # Start-of-day commands
    standup.md
    review-prs.md
    check-build.md
  code/         # During coding
    explain.md
    refactor.md
    test.md
  ship/         # Shipping code
    commit.md
    release.md
    changelog.md
```

### Pattern 3: Hybrid Approach

Combine tool and workflow:

```
~/.qwen/commands/
  daily-note.md          # Top-level for frequently-used commands
  git/
    commit.md
    pr-review.md
  review/
    code.md
    security.md
    pr.md
  docs/
    generate.md
    changelog.md
    api.md
```

## Naming Conventions for Commands

Consistent naming makes commands predictable and discoverable.

### Use Kebab-Case

```
GOOD:  daily-note.md, pr-summary.md, deploy-check.md
AVOID: dailyNote.md, PR_Summary.md, deployCheck.md
```

Qwen Code commands follow kebab-case convention. The URL becomes `/daily-note`, `/pr-summary`, etc.

### Use Verb-Noun or Noun-Only Names

```
Verb-Noun (action-oriented):
  review-pr.md
  generate-docs.md
  deploy-staging.md

Noun-Only (entity-oriented):
  standup.md
  changelog.md
  architecture.md
```

Pick one convention and be consistent. Verb-noun is better for commands that perform actions. Noun-only works well for commands that generate reports or summaries.

### Avoid Ambiguous Names

```
GOOD:  pr-review.md      (clearly reviews a PR)
AVOID: review.md          (review what? code? pr? docs?)

GOOD:  db-migrate.md      (clearly database migration)
AVOID: migrate.md          (migrate what? db? config? data?)
```

## Managing Command Descriptions

The `description` field in frontmatter is your command's documentation in the `/` picker. Make every word count:

```yaml
---
name: commit
description: "Generate commit message from staged changes"
---
```

Good descriptions:
- Start with a verb (or describe what the command produces)
- Are 3-8 words long
- Mention the key input or output
- Avoid obvious words ("This command will...")

```
GOOD: "Generate commit message from staged changes"
GOOD: "Review PR for security vulnerabilities"
GOOD: "Daily standup note generator"
AVOID: "This command helps you write commit messages"
AVOID: "A command for doing things with reviews"
AVOID: "Generates stuff"
```

## Keeping Commands Updated

As your project evolves, some commands will become stale. The `{{args}}` placeholder and command bodies may reference file paths, tools, or workflows that change over time.

### Audit Schedule

Set a recurring reminder to review your commands:

```bash
# Quick audit: list all command files and their last modified date
find ~/.qwen/commands/ -name "*.md" -type f -exec ls -la {} \; | sort -k6,7
```

Commands that have not been edited in months may need updating or removal.

### Version Control Your Commands

Since commands are just files, you can track them in git. This gives you:
- History of how commands evolved
- Ability to revert bad changes
- Easy sharing with team members (covered in Lesson 5.5)

```bash
# Put your commands under version control
cd ~/.qwen/commands
git init
git add .
git commit -m "Initial command library"
```

## Check Your Work

Verify your organized command structure:

```bash
echo "=== Command Organization Audit ==="

# Check namespace directories exist
for dir in git docs ci; do
  test -d ~/.qwen/commands/$dir && echo "Namespace $dir/ exists" || echo "Missing: $dir/"
done

# List all commands by namespace
echo ""
echo "Top-level commands:"
find ~/.qwen/commands/ -maxdepth 1 -name "*.md" -type f -exec basename {} \; 2>/dev/null

echo ""
echo "Namespaced commands:"
find ~/.qwen/commands/ -mindepth 2 -name "*.md" -type f | while read f; do
  # Extract namespace from path
  echo "  $f" | sed 's|.*/\.qwen/commands/||'
done

echo "=== Done ==="
```

## Debug It

### Scenario: Namespaced command not found

You moved `commit.md` to `~/.qwen/commands/git/commit.md` but `/git/commit` does not work.

**Cause:** Qwen Code needs to be restarted to pick up directory structure changes.

**Fix:**
```bash
# Exit and restart Qwen Code
exit
qwen
```

### Scenario: Command moved, old name still partially works

You moved a command but Qwen Code still shows the old name in some contexts.

**Cause:** Qwen Code may have cached the old command list.

**Fix:** Full restart. Also verify the old file is truly gone:
```bash
# Make sure the old location file is removed
ls ~/.qwen/commands/commit.md 2>/dev/null && echo "STILL EXISTS - remove it" || echo "Clean"
```

### Scenario: Too many namespace levels

You created deeply nested commands like `~/.qwen/commands/ci/git/commit.md` and they are hard to find.

**Fix:** Flatten to at most one level of namespacing:
```bash
# Instead of:
~/.qwen/commands/ci/git/commit.md

# Use:
~/.qwen/commands/git/commit.md
```

One level of namespacing (`/git/commit`) is the sweet spot. Deeper nesting (`/ci/git/commit`) creates navigation friction.

## Organization Principles

Follow these principles when deciding where a command lives:

1. **Frequency over purity** -- Frequently used commands should be top-level even if they "belong" in a namespace. `/daily-note` deserves top-level placement even though it could be under `/team/daily-note`.

2. **Cohesion** -- Commands used together should be in the same namespace. If you always run `/review` after `/commit`, they should both be under `/git/`.

3. **Discoverability** -- If a new team member would look for a command in a certain namespace, put it there. `/changelog` belongs in `/docs/` not `/git/`.

4. **Stability** -- Namespaces should change rarely. Do not create a namespace for a specific project phase that will end next month.

## What You Learned

Command namespacing uses subdirectories to group related commands, invoked as `/namespace/command`, keeping your command library discoverable at any scale.

---

**Coming up next:** In Lesson 5.5, the final lesson in this module, you will learn how to share commands with your team by moving them from user-level to project-level, so everyone gets the same workflows from a single commit.
