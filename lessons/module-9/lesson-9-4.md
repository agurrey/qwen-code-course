---
module: 9
lesson: 4
title: "Safety Patterns"
prerequisites: ["module-9/lesson-9-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

Everyone tells you "don't run `rm -rf /`" but nobody tells you about the actual ways people lose work with Qwen Code: asking it to "clean up" and watching it delete the wrong directory, asking it to "reset everything" and losing uncommitted changes, asking it to "start fresh" and watching it nuke `node_modules` along with your local config files. Safety isn't about blocking one scary command — it's about building patterns that make accidents structurally difficult.

## Mental Model

Safety patterns are **defensive architecture** — you don't just block individual commands, you design your workspace so that the wrong thing is hard to do and the right thing is the path of least resistance. Like a building with fire doors: you don't need to remember where the fire is, the doors close automatically.

## Try It

You'll build a layered safety system using directory protection, hook patterns, and workspace discipline.

### Layer 1: The .qwenignore file

The `.qwenignore` file tells Qwen Code which directories to ignore entirely — it won't read, modify, or delete anything in ignored directories. This is your first and strongest line of defense.

Create a `.qwenignore` file in your project root:

```
# .qwenignore
# Never touch these directories
.git/
node_modules/
.venv/
.env
.env.*
*.lock
```

Every line is a glob pattern. Qwen Code treats these paths as if they don't exist. It won't search inside them, it won't modify files in them, and it won't suggest deleting them.

**Key difference from .gitignore**: `.gitignore` controls what git tracks. `.qwenignore` controls what Qwen Code can see and touch. They serve different purposes and can have different contents.

Test it: create a file inside an ignored directory and ask Qwen Code to list all files in your project:

```bash
mkdir -p node_modules && echo "should not appear" > node_modules/secret.txt
```

Now ask:

```
list all files in the project
```

**Expected output**: `node_modules/secret.txt` should NOT appear in the listing. Qwen Code genuinely cannot see it.

### Layer 2: Protected directory hooks

Even with `.qwenignore`, shell commands can bypass it (Qwen Code can still run `rm -rf node_modules` via shell even if it can't see the files). Add hooks to block destructive commands on important directories:

```yaml
# .qwen/hooks/protect-important-dirs.yaml
name: protect-important-dirs
description: Block destructive commands on important directories
type: pre-action
pattern: "(rm|mv|cp).*\\.(git|env|venv|node_modules|venv3|\\.venv)"
action: block
message: |
  Blocked: Attempt to modify a protected directory.
  
  These directories are protected by hooks:
  - .git/ (version history)
  - .env (secrets)
  - .venv/ (python environment)
  - node_modules/ (dependencies)
  
  If you genuinely need to modify these, disable this hook first.
```

### Layer 3: The sandbox discipline

The sandbox discipline is a set of habits that prevent accidents:

1. **Work in project directories, never above them**. If your project is at `/home/user/myproject`, always start Qwen Code from `/home/user/myproject`, never from `/home/user`. This ensures Qwen Code's scope is limited to the project.

2. **Use a scratch directory for experiments**. Before asking Qwen Code to try something risky:

```bash
mkdir -p /tmp/qwen-scratch && cd /tmp/qwen-scratch
```

In a scratch directory, you can safely use `yolo` mode because nothing matters if it breaks.

3. **Commit before big operations**. Before asking Qwen Code to do a large refactor:

```bash
git add -A && git commit -m "checkpoint: before refactor"
```

If Qwen Code messes up, you can always revert:

```bash
git reset --hard HEAD~1
```

4. **Use git's safety net**. Before any destructive operation, create a git tag:

```bash
git tag before-cleanup
```

If things go wrong:

```bash
git checkout before-cleanup
```

### Layer 4: The "dry run" pattern

Before asking Qwen Code to do something destructive, ask it to plan first:

```
/approve plan
```

Then describe what you want. Qwen Code will show you its plan before executing. Review it, and if something looks wrong, reject it and be more specific.

### Layer 5: The audit trail

Keep a log of what Qwen Code does. Create a post-action hook that logs every shell command:

```yaml
# .qwen/hooks/log-shell-commands.yaml
name: log-shell-commands
description: Log all shell commands for audit trail
type: post-action
pattern: "shell"
action: notify
message: "Shell command executed — logged to .qwen/audit.log"
```

Then in your project, create a simple audit log by asking Qwen Code to append to `.qwen/audit.log` after each session. This gives you a searchable history of everything that happened.

### Putting it all together

Here's what a well-protected project looks like:

```
myproject/
├── .qwen/
│   ├── hooks/
│   │   ├── block-danger-rm.yaml
│   │   ├── protect-important-dirs.yaml
│   │   ├── warn-migrations.yaml
│   │   └── log-shell-commands.yaml
│   ├── settings.json
│   └── audit.log
├── .qwenignore
├── .git/
├── src/
└── tests/
```

Each layer catches mistakes the others miss:
- `.qwenignore` prevents Qwen Code from seeing sensitive paths
- Hooks block shell commands that target sensitive paths
- Approval modes control the friction level
- Git commits provide undo capability
- Audit logs give you a record of what happened

## Check Your Work

1. Verify your `.qwenignore` is working:

```bash
cat .qwenignore
```

Should contain patterns for directories you want protected.

2. Verify your hooks cover important directories:

```bash
grep -l "block\|protect" .qwen/hooks/*.yaml
```

3. Test the sandbox: create a scratch directory, set yolo mode, and verify nothing important can be affected:

```bash
mkdir -p /tmp/qwen-scratch
cd /tmp/qwen-scratch
```

4. Verify your commit workflow works:

```bash
git add -A && git commit -m "test checkpoint"
git log --oneline -1
```

## Debug It

Scenario: You asked Qwen Code to "clean up unused files" and it deleted your `.env` file. Your hooks should have prevented this but didn't. Find the bug.

**Possible causes**:

1. **The hook pattern doesn't match the actual command**. Qwen Code might have run `rm .env` but your hook pattern was `rm -rf`. The `-rf` flags weren't present.

**Fix**: Broaden your pattern to catch `rm` without flags:

```yaml
pattern: "rm.*\\.env|rm -.*\\.env"
```

2. **The hook file isn't being loaded**. Check that it's in the right directory:

```bash
ls .qwen/hooks/
```

If your hook file is in `.qwen/hooks/subdir/`, it won't load. Hooks must be directly in `.qwen/hooks/`.

3. **The `.qwenignore` didn't cover `.env`**. If `.env` isn't in `.qwenignore`, Qwen Code can see and modify it.

**Fix**: Add it:

```
# .qwenignore
.env
.env.*
```

4. **No git checkpoint before the operation**. You can't undo the deletion because there's no clean commit to revert to.

**Fix**: Make the checkpoint habit automatic:

```bash
alias qwen-start='git add -A && git commit -m "pre-qwen checkpoint" && qwen'
```

## What You Learned

Safety patterns are layered defenses — .qwenignore hides sensitive paths, hooks block shell commands against them, approval modes control friction, and git provides your undo button.

*Next: Lesson 9.5 — Production Safety — You'll learn how to run Qwen Code safely in CI/CD pipelines, configure non-interactive mode, and maintain audit trails for compliance.*
