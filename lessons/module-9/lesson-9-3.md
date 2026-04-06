---
module: 9
lesson: 3
title: "Approval Modes Deep Dive"
prerequisites: ["module-9/lesson-9-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You're refactoring a large codebase and Qwen Code keeps asking for approval on every single file change. After the 47th "approve this edit?" prompt, you hit "approve all for this session" — and it immediately overwrites your database config file with a template. Approval modes are not just about security versus convenience; they're about finding the right level of friction for the task you're doing right now.

## Mental Model

Approval modes are **dials, not switches** — you don't pick one and stick with it forever. You turn the dial up when you're doing risky work and down when you need velocity. The skill is knowing which setting to use when, and how to change it without losing your safety net permanently.

## Try It

You'll work through each approval mode, understand when to use it, and learn how to persist your choices.

### The approval modes

Qwen Code has several approval modes that control how it interacts with you before taking actions:

1. **`yolo`** — No approvals, no questions. Qwen Code does everything you ask immediately.
2. **`default`** — Approves safe operations (reads, small edits), asks on anything risky (deletes, shell commands).
3. **`accept`** — Asks for confirmation on every single action.
4. **`plan`** — Shows you a plan of everything it will do, waits for one approval, then executes.

### Test mode 1: yolo (maximum velocity)

Set yolo mode for your current session:

```
/approve yolo
```

Now ask Qwen Code to do something:

```
create a file called hello.txt with the content "hello world"
```

**Expected output**: Qwen Code creates the file immediately without asking for any confirmation.

**When to use yolo**:
- Working in a throwaway directory (`/tmp/`, a test project)
- You're confident about every action you're asking for
- Rapid prototyping where mistakes are cheap

**When NOT to use yolo**:
- Working on production code
- Any operation that touches important files
- When you're tired and might have misdescribed what you want

### Test mode 2: default (balanced)

```
/approve default
```

Now ask Qwen Code to do a mix of safe and risky things:

```
read the contents of hello.txt, then delete it
```

**Expected output**: Qwen Code reads the file without asking, but pauses and asks for confirmation before deleting it.

**When to use default**:
- Your day-to-day mode
- Working on real code where some actions are safe and others aren't
- When you want a safety net without being interrupted constantly

### Test mode 3: accept (maximum caution)

```
/approve accept
```

Ask Qwen Code to do something simple:

```
create a file called test.txt with "test" in it
```

**Expected output**: Qwen Code asks for explicit confirmation before creating the file. Every action, no matter how trivial, requires your approval.

**When to use accept**:
- You're debugging something fragile and need to watch every step
- You don't fully trust the instructions you gave
- Working with production systems where every action has consequences
- You're learning and want to understand exactly what Qwen Code is doing at each step

### Test mode 4: plan (plan first, then execute)

```
/approve plan
```

Ask Qwen Code to do a multi-step task:

```
create three files: a.txt with "alpha", b.txt with "beta", c.txt with "gamma"
```

**Expected output**: Qwen Code shows you a plan like:

```
Here's what I'll do:
1. Create a.txt with content "alpha"
2. Create b.txt with content "beta"  
3. Create c.txt with content "gamma"

Proceed? [y/n]
```

You review the entire plan once, approve it, and then Qwen Code executes all steps without further interruptions.

**When to use plan**:
- Multi-step refactoring where you want to review the full scope before execution
- Complex tasks where the sequence of operations matters
- When you want oversight without micromanaging each step

### Persisting approval modes across sessions

By default, approval mode resets when you start a new session. To make it stick:

1. **Project-level approval settings** — Create or edit `.qwen/settings.json` in your project:

```json
{
  "approval": {
    "mode": "default",
    "persist": true
  }
}
```

The `"persist": true` field means Qwen Code remembers this mode across sessions in this project directory.

2. **User-level settings** — For a global default, edit your user settings:

```
/settings
```

Navigate to the approval mode setting and choose your default. This applies to every project that doesn't have its own `.qwen/settings.json`.

3. **Session override** — Even with persisted settings, you can always override for the current session:

```
/approve yolo
```

This overrides the persisted mode for this session only. When you start a new session, it reverts to the persisted mode.

### Combining approval modes with hooks

Hooks and approval modes work together, not against each other. Here's how they interact:

- **Hooks always fire** regardless of approval mode. Even in `yolo` mode, a block hook will stop a destructive command.
- **Approval mode controls the friction** for actions that aren't caught by hooks.
- Think of hooks as your **safety floor** (things that can never slip through) and approval mode as the **friction dial** (how much oversight you want on everything else).

A practical setup:
1. Write block hooks for the things that should **never** happen automatically
2. Write warn hooks for things that should **always get attention**
3. Set your approval mode to `default` for everyday work
4. Switch to `yolo` in scratch directories
5. Switch to `plan` or `accept` for delicate operations

This layered approach means you're never fully unprotected, even in yolo mode.

### Approval mode decision tree

When you're about to start working, ask yourself:

```
Is this a throwaway experiment?
  YES → yolo
  NO → Continue...

Am I doing a multi-step refactor I want to review as a whole?
  YES → plan
  NO → Continue...

Am I touching production or fragile systems?
  YES → accept
  NO → default
```

Keep this decision tree in mind. The goal isn't to always be cautious — it's to match the level of caution to the level of risk.

## Check Your Work

1. Test each approval mode by setting it and triggering at least one action:

```
/approve yolo    → create a file → should not ask
/approve default → delete a file → should ask
/approve accept  → create a file → should ask
/approve plan    → multi-step task → should show plan first
```

2. Verify your project settings file exists and has the right structure:

```bash
cat .qwen/settings.json
```

Should contain the `approval` section with `mode` and optionally `persist`.

3. Test persistence: set a mode, end your session, start a new one, and verify the mode carried over (if `persist: true`).

## Debug It

Two common approval mode problems:

1. **"I set persist to true but it still resets."** The problem is usually the location of your settings file. Qwen Code looks for `.qwen/settings.json` relative to your current working directory. If you're working in a subdirectory, it may not find the file.

**Fix**: Put `.qwen/settings.json` in your project root and verify the path is correct:

```bash
find . -name "settings.json" -path "*/.qwen/*"
```

2. **"Yolo mode and my hooks aren't blocking anything."** This shouldn't happen — hooks are designed to fire regardless of approval mode. If it does, check:
   - Is the hook file named with `.yaml` extension? (`.yml` won't load)
   - Is the YAML valid? Test with: `python -c "import yaml; yaml.safe_load(open('hook-file.yaml'))"`
   - Is the `type` set to `pre-action`? Post-action hooks run after, so they won't block.

3. **"Plan mode shows a plan I didn't expect."** This isn't a bug — it's the system working as designed. Review the plan carefully. If the plan includes actions you don't want, reject it and rephrase your request more specifically.

## What You Learned

Approval modes are a friction dial — turn them up for risky work and down for velocity, while hooks provide a permanent safety floor that never turns off.

*Next: Lesson 9.4 — Safety Patterns — You'll learn why rm -rf is the wrong problem to focus on, how to protect entire directory categories, and how to build a sandbox discipline that prevents accidents before they happen.*
