---
module: 9
lesson: 1
title: "What Are Hooks"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You just asked Qwen Code to delete a directory and it did it without asking. The directory contained three weeks of work. Gone. You can't undo it because you didn't have a backup. This happens to people every day — not because Qwen Code is dangerous, but because there was nothing stopping it from running a destructive command the moment you asked. Hooks are how you put guardrails between your words and Qwen Code's actions.

## Mental Model

Hooks are **automatic checkpoints** — small rules that run before or after certain actions. Think of them like a bouncer at a club door: they inspect what's about to happen, decide if it's allowed, and either let it through, block it entirely, or let it through but warn you about it. You write the rules once, and they fire automatically every time a matching action occurs.

## Try It

You'll create your first hook and watch it intercept a command.

1. **Create a hooks directory** in your project. Hooks live in `.qwen/hooks/` inside your project:

```bash
mkdir -p .qwen/hooks
```

2. **Create a simple hook file**. Hooks use a format called "hookify" — each hook is a YAML-formatted file that describes what to match and what to do:

```yaml
# .qwen/hooks/block-rm-recursive.yaml
name: block-rm-recursive
description: Block recursive rm commands
type: pre-action
pattern: "rm -r"
action: block
message: "Blocked: recursive rm is dangerous. Use git rm or move files to trash instead."
```

3. **Test it**. Now ask Qwen Code to delete a directory recursively:

```
delete the temp directory and all its contents
```

**Expected output**: Qwen Code will respond with something like:

```
Hook 'block-rm-recursive' blocked this action:
Blocked: recursive rm is dangerous. Use git rm or move files to trash instead.
```

The hook intercepted the command before it ran. You're now protected from one of the most common destructive mistakes.

4. **Understand the hook format**. Every hook file has these fields:

- `name`: A unique identifier for the hook (no spaces, use hyphens)
- `description`: What this hook does, in plain English
- `type`: Either `pre-action` (runs before the action) or `post-action` (runs after)
- `pattern`: A string or regex that matches against the command. If the pattern appears in the command, the hook fires.
- `action`: What to do when the pattern matches. Three options:
  - `block` — stop the action entirely, show your message
  - `warn` — let the action through but display a warning first
  - `notify` — log that it happened, no interruption
- `message`: The text shown to you when the hook fires

5. **Create a warning hook**. This one doesn't block, it just warns:

```yaml
# .qwen/hooks/warn-git-force.yaml
name: warn-git-force
description: Warn before git force operations
type: pre-action
pattern: "git push.*--force"
action: warn
message: "Warning: force-pushing will overwrite remote history. Make sure nobody else has unpushed work."
```

6. **Test the warning hook**. Ask Qwen Code to force-push:

```
force push to main
```

**Expected output**: Qwen Code will show the warning but then proceed with the action after acknowledging it:

```
Hook 'warn-git-force' triggered:
Warning: force-pushing will overwrite remote history. Make sure nobody else has unpushed work.

Proceeding with: git push --force origin main
```

The key difference: `block` stops the action dead. `warn` shows your message but continues. `notify` is silent during execution but logs the event.

7. **See the blocking vs warning distinction in action**. The difference matters in practice:

- **Block** = "This should never happen automatically." Examples: `rm -rf /`, `DROP TABLE`, overwriting production config files.
- **Warn** = "This is risky but sometimes necessary." Examples: force push, dropping a column, changing a migration.
- **Notify** = "I want to track when this happens." Examples: deploying to staging, running tests, modifying dependencies.

8. **Hook files are just files**. You can edit them, delete them, or commit them to git. When you commit hooks to your project, every team member gets the same safety net.

```bash
git add .qwen/hooks/
git commit -m "Add project safety hooks"
```

## Check Your Work

Verify your hooks are in place:

```bash
ls -la .qwen/hooks/
```

You should see at least two files: `block-rm-recursive.yaml` and `warn-git-force.yaml`. Check their contents:

```bash
cat .qwen/hooks/block-rm-recursive.yaml
cat .qwen/hooks/warn-git-force.yaml
```

Both files should be valid YAML with all required fields: `name`, `description`, `type`, `pattern`, `action`, and `message`. If any field is missing, the hook won't fire correctly.

## Debug It

Now break something on purpose so you understand how hooks fail and how to fix them.

1. **Create a broken hook** — remove the `action` field:

```yaml
# .qwen/hooks/broken-hook.yaml
name: broken-hook
description: This hook is missing its action field
type: pre-action
pattern: "echo"
message: "This will never fire because action is missing"
```

2. **Test it**. Ask Qwen Code to run `echo hello`.

**What happens**: The hook fails silently or shows an error in the hook execution log. Qwen Code may ignore the hook entirely because it's malformed.

3. **Fix it**: Add the missing `action` field:

```yaml
# .qwen/hooks/broken-hook.yaml
name: broken-hook
description: This hook notifies on echo commands
type: pre-action
pattern: "echo"
action: notify
message: "Echo command detected"
```

4. **Another common bug: patterns too broad**. Create this hook:

```yaml
# .qwen/hooks/overzealous-block.yaml
name: overzealous-block
description: Blocks all git commands (too broad!)
type: pre-action
pattern: "git"
action: block
message: "All git commands are blocked"
```

Now try asking Qwen Code to do anything with git — even `git status`. It will all be blocked. This is why your `pattern` needs to be specific. Fix it by narrowing the pattern:

```yaml
pattern: "git push.*--force"
```

**Lesson**: Hook patterns match substrings. `"git"` matches every command containing "git". Be precise with your patterns, or you'll block things you didn't intend to.

## What You Learned

Hooks are automatic safety checkpoints — YAML files that intercept commands matching your patterns and either block, warn, or notify before the action runs.

*Next: Lesson 9.2 — Writing Your First Hook — You'll build real-world hooks that protect against actual destructive scenarios, including blocking dangerous shell patterns and catching accidental production deployments.*
