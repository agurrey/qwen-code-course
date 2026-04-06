---
module: 9
lesson: 2
title: "Writing Your First Hook"
prerequisites: ["module-9/lesson-9-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You asked Qwen Code to "clean up the old files" and it ran `rm -rf build/` — which worked fine, except `build/` was a symlink to `/var/www/build` and you just wiped out your production build artifacts. Hooks aren't just about blocking single commands; they're about encoding your hard-won knowledge about what goes wrong in your specific workflow. In this lesson, you'll write hooks that prevent real disasters, not just textbook examples.

## Mental Model

Every hook you write captures a **mistake you've made or could make**. The best hooks come from post-mortems — thinking about what went wrong last time and making sure it can't happen again. You're not writing code, you're writing institutional memory in YAML form.

## Try It

You'll write four production-quality hooks that cover the most common destructive scenarios.

### Hook 1: Block destructive filesystem commands

The `rm -rf` problem isn't just about recursion. It's about running destructive commands on paths you didn't intend. Create this hook:

```yaml
# .qwen/hooks/block-danger-rm.yaml
name: block-danger-rm
description: Block rm commands with force flag on sensitive paths
type: pre-action
pattern: "rm\\s+(-[a-zA-Z]*f[a-zA-Z]*\\s+)(/?home|/?etc|/?var|/?usr|/?root|/?tmp|/?opt)"
action: block
message: |
  Blocked: rm with -f flag on a system or shared directory.
  If you need to clean a directory, use: rm -ri <path>
  Or verify the path first with: ls <path>
```

The `pattern` here uses regex. Let's break it down:
- `rm\\s+` matches "rm" followed by one or more spaces
- `(-[a-zA-Z]*f[a-zA-Z]*\\s+)` matches flags containing 'f' (like `-rf`, `-f`, `-fr`) followed by a space
- `(/?home|/?etc|...)` matches common system directory paths

The pipe `|` after `message:` means the message is a multi-line YAML string. Each line becomes part of the message.

### Hook 2: Block accidental production deployments

If you have a deploy command, you don't want it running against production without explicit intent. Create a hook that catches this:

```yaml
# .qwen/hooks/block-prod-deploy.yaml
name: block-prod-deploy
description: Block deployments to production without explicit confirmation
type: pre-action
pattern: "deploy.*production|deploy.*prod|npm run deploy:prod"
action: block
message: |
  Blocked: Production deployment detected.
  
  Production deployments require explicit review. To proceed:
  1. Disable this hook temporarily: rename the file to block-prod-deploy.yaml.disabled
  2. Or use: deploy --confirm-production
  
  Never deploy to prod on autopilot.
```

This hook encodes a process, not just a command restriction. It tells you exactly how to proceed when you genuinely need to deploy.

### Hook 3: Warn on database migrations

Database migrations are reversible in theory but destructive in practice. You want to be aware when they're running:

```yaml
# .qwen/hooks/warn-migrations.yaml
name: warn-migrations
description: Warn before running database migrations
type: pre-action
pattern: "(rails|django|flask|knex|prisma|sequelize).*migrate|npm run.*migrate"
action: warn
message: |
  Running database migrations. Make sure:
  - You have a recent database backup
  - The migration has been tested on a staging copy
  - No one is actively using the database
```

### Hook 4: Block environment file modifications

Your `.env` files contain secrets. Accidentally overwriting them is a common and painful mistake:

```yaml
# .qwen/hooks/block-env-overwrite.yaml
name: block-env-overwrite
description: Block overwriting .env files
type: pre-action
pattern: "(cp|mv|cat.*>|echo.*>).*(\\.env|\\.env\\.)"
action: block
message: |
  Blocked: Attempt to overwrite a .env file.
  
  Environment files contain secrets and credentials. To modify:
  1. Edit directly: nano .env
  2. Use a safe copy: cp --no-clobber source.env dest.env
  3. Backup first: cp .env .env.backup
  
  Never blindly redirect into .env files.
```

### Test your hooks

Create a safe testing environment. Make a test directory and try to trigger each hook:

```bash
mkdir -p /tmp/hook-test && cd /tmp/hook-test
```

Ask Qwen Code to run commands that should trigger your hooks. For each one, verify:

1. **Block hooks should stop execution** — ask Qwen Code to `delete the etc directory with force`:
   - Expected: Hook blocks the action with your message

2. **Warn hooks should warn but proceed** — ask Qwen Code to `run the database migration`:
   - Expected: Hook shows the warning, then proceeds

3. **Env protection** — ask Qwen Code to `overwrite the .env file with empty content`:
   - Expected: Hook blocks with instructions to do it safely

### Hook execution order

When multiple hooks match the same command, they all fire in alphabetical order by filename. This means `block-danger-rm.yaml` fires before `warn-migrations.yaml`. You can control order by naming files with prefixes:

- `01-block-rm.yaml` fires first
- `02-warn-git.yaml` fires second
- `03-notify-deploy.yaml` fires third

This is useful when you want a block hook to fire before a warn hook on overlapping patterns.

### Disabling hooks temporarily

Sometimes you genuinely need to bypass a hook. Don't delete it — disable it:

```bash
mv .qwen/hooks/block-danger-rm.yaml .qwen/hooks/block-danger-rm.yaml.disabled
```

Qwen Code only loads `.yaml` files. The `.disabled` suffix means it's ignored but preserved. To re-enable:

```bash
mv .qwen/hooks/block-danger-rm.yaml.disabled .qwen/hooks/block-danger-rm.yaml
```

### Hooks in your workflow

Hooks should live in version control alongside your code. When you clone a project, you get its safety net:

```bash
git add .qwen/hooks/
git commit -m "Add safety hooks for destructive operations"
```

When a teammate encounters a new type of failure, they write a hook and commit it. Over time, your `.qwen/hooks/` directory becomes a living document of everything that has ever gone wrong on this project.

## Check Your Work

List your hooks and verify they're all valid YAML:

```bash
ls -la .qwen/hooks/
```

You should have at least 4 hook files. Test each one by asking Qwen Code to trigger it. If any hook doesn't fire:

1. Check the YAML syntax: `python -c "import yaml; yaml.safe_load(open('.qwen/hooks/your-hook.yaml'))"`
2. Verify the pattern actually matches the command Qwen Code generates
3. Check that the `type` is `pre-action` (post-action hooks run after, so you won't see them blocking anything)

## Debug It

Here's a scenario where your hooks aren't working and you need to figure out why.

1. **The pattern doesn't match**. You created this hook to block npm install with the --save flag:

```yaml
# .qwen/hooks/block-npm-save.yaml
name: block-npm-save
description: Block npm install --save
type: pre-action
pattern: "npm install --save"
action: block
message: "Don't use --save, it's the default in npm 5+"
```

But when you ask Qwen Code to run `npm install --save lodash`, the hook doesn't fire. Why?

**The problem**: Qwen Code might run the command as `npm install lodash --save` (different argument order). Your pattern matches a specific string order, not a semantic intent.

**The fix**: Use a more flexible pattern:

```yaml
pattern: "npm install.*--save|--save.*npm install"
```

The `.*` matches anything between the two parts. The `|` means "or". This catches both argument orders.

2. **The hook blocks too much**. You wrote a hook to block `rm -rf` but it's also blocking `rm -rf .git/hooks/my-temp-file` which you genuinely want to delete.

**The problem**: Your pattern matches the command string but not the context.

**The fix**: Use a warn instead of block for edge cases, and add a second hook that specifically blocks the dangerous combinations:

```yaml
# Keep the general block
pattern: "rm -rf /"
action: block

# Add a warn for everything else
name: warn-rm-recursive
pattern: "rm -r"
action: warn
message: "About to recursively delete files. Double-check the path."
```

**Lesson**: When a block hook is too aggressive, narrow its pattern and add a warn hook as a safety net. Layer your hooks from most restrictive to least.

## What You Learned

Good hooks encode real failure modes — they block what should never happen, warn on what needs attention, and provide clear recovery instructions when triggered.

*Next: Lesson 9.3 — Approval Modes Deep Dive — You'll learn when to use each approval mode, how to make them persist across sessions, and how to set project-level approval policies.*
