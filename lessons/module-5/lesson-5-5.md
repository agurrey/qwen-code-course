---
module: 5
lesson: 5
title: "Sharing Commands"
prerequisites: ["lesson-5-4"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 5.5: Sharing Commands

## The Problem

You have built a great set of custom commands that work well for your daily workflow. Your teammate asks, "How do you generate such consistent commit messages?" and you realize you need to share your `/commit` command with them. Sending them the file contents over chat is not sustainable. When you improve the command next week, you would have to send it again. You need a way to distribute commands to your team so everyone uses the same versions, and updates propagate naturally.

## Mental Model

Project-level commands live in `.qwen/commands/` inside your repository. When you commit this directory to git, every contributor who clones or pulls the repository gets the same commands automatically. User-level commands (`~/.qwen/commands/`) are personal and private. Project-level commands are shared and versioned. The same command file format works in both locations -- the only difference is scope.

## User-Level vs Project-Level Commands

Understanding the difference is critical:

| Aspect | User-Level (`~/.qwen/commands/`) | Project-Level (`.qwen/commands/`) |
|--------|-----------------------------------|------------------------------------|
| **Scope** | All projects | This project only |
| **Sharing** | Personal | Shared via git |
| **Version control** | Optional | Committed to repo |
| **Updates** | Manual per machine | Via `git pull` |
| **Best for** | Personal workflows | Team conventions |
| **Precedence** | Both are loaded | Both are loaded |

Both sets of commands are active simultaneously. If a command exists in both locations, behavior depends on your Qwen Code version -- typically the project-level command takes precedence when working in that project, and the user-level command applies everywhere else.

## When to Share

Not every command belongs in the project. Use this decision framework:

**Share (put in `.qwen/commands/`) when:**
- The command is relevant to everyone on the team
- It references project-specific paths or tools
- It enforces team conventions (commit message format, review checklist)
- It would save collective time

**Keep personal (in `~/.qwen/commands/`) when:**
- The command is about your personal workflow (daily notes, personal task management)
- It references personal paths (`~/notes/`, `~/scripts/`)
- It is experimental or not yet ready for the team
- Only you need it

## Try It: Share a Command with Your Team

### Step 1: Choose a command to share

Pick a command that would benefit the whole team. The `/git/commit` command from earlier lessons is a good candidate -- consistent commit messages help everyone.

### Step 2: Create the project-level commands directory

In your project directory:

```bash
mkdir -p .qwen/commands/git
```

Note: no tilde (`~`). This is a relative path inside your current project.

### Step 3: Copy (do not move) the command

```bash
cp ~/.qwen/commands/git/commit.md .qwen/commands/git/commit.md
```

We copy rather than move so the personal version remains available for other projects.

### Step 4: Customize for the project

Edit the project-level version to reference project-specific details:

```bash
cat .qwen/commands/git/commit.md
```

Customize it for your team's conventions. For example, if your team uses specific scopes:

```bash
cat > .qwen/commands/git/commit.md << 'EOF'
---
name: commit
description: "Generate commit message following team conventions"
---

# Command: commit

Arguments provided: {{args}}

Generate a git commit message following our team's conventions:

## Format
<type>(<scope>): <description>

## Types (use only these)
- feat: new feature
- fix: bug fix
- docs: documentation only
- refactor: code restructuring (no behavior change)
- test: test additions or fixes
- chore: build/config changes
- perf: performance improvement

## Allowed Scopes (project-specific)
- auth: authentication and authorization
- api: API endpoints and handlers
- ui: frontend components
- db: database migrations and queries
- infra: deployment and infrastructure
- core: shared utilities and types

## Rules
- Description is imperative: "add validation" not "added validation"
- Description is lowercase
- Max 72 characters for subject line
- Body explains WHAT changed and WHY, not HOW

## Process
1. Run `git diff --staged` and `git status`
2. If {{args}} provided, use as context or subject
3. Generate message following conventions above
4. Show for review before committing
5. Ask for confirmation before executing `git commit`
EOF
```

### Step 5: Commit to the repository

```bash
git add .qwen/commands/
git commit -m "chore: add team commit message command"
git push
```

### Step 6: Team members receive it

When a teammate pulls the repository:

```bash
git pull
```

They now have `.qwen/commands/git/commit.md` in their working directory. When they start Qwen Code in this project, `/git/commit` is automatically available.

### Step 7: Verify as a team member

Simulate being a new team member:

```bash
# Check the command file exists in the project
ls -la .qwen/commands/git/commit.md

# Verify the content
head -20 .qwen/commands/git/commit.md
```

## Updating Shared Commands

When you improve a shared command, the update flows through git:

```bash
# 1. Edit the project-level command
cat > .qwen/commands/git/commit.md << 'EOF'
---
name: commit
description: "Generate commit message following team conventions v2"
---

# Command: commit
[updated content...]
EOF

# 2. Commit and push
git add .qwen/commands/git/commit.md
git commit -m "chore: improve commit command with scope validation"
git push

# 3. Team members pull the update
# (They run: git pull)
```

## Conflict Resolution

### Scenario: User-level and project-level command with same name

You have `~/.qwen/commands/git/commit.md` (personal) and `.qwen/commands/git/commit.md` (project).

**Behavior:** When working in this project, the project-level command is used. When working in any other project, the user-level command is used.

This is the desired behavior in most cases -- project conventions override personal preferences when working on the project.

### Scenario: Two team members edit the same command

Alice and Bob both edit `.qwen/commands/git/commit.md` in different branches. When merging, git handles it like any other file:

```bash
# If there is a merge conflict:
git diff .qwen/commands/git/commit.md
# Resolve the conflict, then:
git add .qwen/commands/git/commit.md
git commit -m "merge: resolve commit command conflict"
```

Since command files are plain text, merge conflicts are straightforward to resolve.

## Bootstrapping a New Team Member

When someone joins the team, they get all project commands automatically via `git pull`. But they might not know the commands exist. Make them discoverable:

### Option 1: README entry

Add a section to your project README:

```markdown
## Qwen Code Commands

This project includes custom commands for common workflows:

| Command | Description |
|---------|-------------|
| `/git/commit` | Generate commit message from staged changes |
| `/git/pr` | Create PR with auto-generated description |
| `/review/security` | Security-focused code review |

Commands are in `.qwen/commands/`. Run `/` in Qwen Code to see all available commands.
```

### Option 2: Onboarding command

Create a command that introduces the team's other commands:

```bash
cat > .qwen/commands/onboarding.md << 'EOF'
---
name: onboard
description: "Show available project commands"
---

# Command: onboard

List and explain all custom commands available in this project:

## Git Commands
- `/git/commit` - Generate commit messages following team conventions
- `/git/pr` - Create a PR with auto-filled description and reviewers

## Review Commands
- `/review/security` - Security-focused code review
- `/review/quality` - General code quality review

## CI Commands
- `/ci/test` - Run tests with coverage report
- `/ci/lint` - Run linter and formatter

Tip: Run `/` in Qwen Code to see this list with tab completion.
All commands are defined in .qwen/commands/ in the repository.
EOF
```

## Check Your Work

Verify your shared command setup:

```bash
echo "=== Sharing Audit ==="

# Check project-level commands exist
echo "Project-level commands:"
find .qwen/commands/ -name "*.md" -type f 2>/dev/null | while read f; do
  echo "  $f"
done

# Check they are tracked by git
echo ""
echo "Git-tracked commands:"
git ls-files .qwen/commands/ 2>/dev/null | while read f; do
  echo "  $f"
done

# Check user-level commands (should still exist for personal use)
echo ""
echo "User-level commands (personal):"
find ~/.qwen/commands/ -name "*.md" -type f 2>/dev/null | while read f; do
  echo "  $f"
done

echo "=== Done ==="
```

## Debug It

### Scenario: Team member cannot see the command

A teammate cloned the repo but `/git/commit` does not appear.

**Cause 1: `.qwenignore` or `.gitignore` excludes the directory**
```bash
# Check if .qwen/ is ignored
cat .gitignore | grep qwen
cat .qwenignore 2>/dev/null
```

**Fix:** Ensure `.qwen/commands/` is not ignored:
```bash
# Add to .gitignore exceptions if needed:
echo "!/.qwen/commands/" >> .gitignore
```

**Cause 2: Qwen Code was not restarted**
Qwen Code discovers commands at startup.

**Fix:** Restart Qwen Code.

### Scenario: Command works for you but not for teammate

Your command uses a path or tool your teammate does not have.

**Fix:** Use project-relative paths and check for tool availability:
```markdown
# Instead of absolute paths, use relative:
GOOD:  "Save to docs/changelog.md"
AVOID: "Save to ~/projects/myapp/docs/changelog.md"

# Check for tools:
"If `jq` is available, use it. If not, use python3 -c 'import json'."
```

### Scenario: Command file not committed

You created the file but your teammate does not have it.

**Fix:** Verify the file is actually in git:
```bash
git status .qwen/commands/
git log --oneline -- .qwen/commands/
```

If the file shows as untracked, you forgot to `git add`:
```bash
git add .qwen/commands/
git commit -m "add: team commands"
git push
```

## Sharing Patterns

### Pattern 1: Template Repository

Create a repository with your standard commands and use it as a template for new projects:

```bash
# Standard command library
my-project-template/
  .qwen/commands/
    git/commit.md
    review/code.md
    ci/test.md
  README.md
```

### Pattern 2: Command Package via Symlink

For teams with multiple repositories, maintain commands centrally and symlink:

```bash
# Central location
~/team-commands/
  commit.md
  review.md

# In each project
ln -s ~/team-commands/commit.md .qwen/commands/git/commit.md
```

Note: symlinks may not work with all git configurations. The copy-and-commit approach (Pattern 1) is more reliable.

### Pattern 3: Version-Pinned Commands

Include the expected Qwen Code version in command frontmatter to prevent breakage:

```yaml
---
name: commit
description: "Generate commit message following team conventions"
min-version: "qwen-code>=0.1.0"
---
```

## Module 5 Complete

You have completed the Custom Commands module. Here is what you can now do:

- Create custom commands as markdown files with YAML frontmatter
- Use `{{args}}` to accept parameters in both interactive and scripted modes
- Organize commands with namespaced subdirectories (`/git/commit`)
- Share commands with your team via project-level `.qwen/commands/`
- Decide which commands are personal versus shared

Your command library is your personal API for Qwen Code. Every repetitive workflow is one command file away from being automated.

---

**Module 5 complete.** You now know how to build, organize, and share custom slash commands in Qwen Code.

**Coming up in Module 6:** Skills & Auto-Discovery -- learn how to give Qwen Code domain-specific capabilities through skill files. While commands are workflows you trigger, skills are capabilities Qwen Code discovers and offers automatically based on your project context.
