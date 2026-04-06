---
description: Health check for Qwen Code. Verifies authentication, skills, commands, sandbox, and overall setup. Use when things aren't working or as a first-run check.
---

Run a complete health check of the Qwen Code environment. Check each item and report status.

## Step 1: Authentication

Check `~/.qwen/settings.json`:
- If it has `security.auth.selectedType` set → ✅ Auth configured
- If `oauth_creds.json` exists and is non-empty → ✅ OAuth tokens present
- If neither → ❌ Not authenticated. Run `/auth` to fix.

## Step 2: Model

Read `~/.qwen/settings.json` and check `model.name`:
- If set → ✅ Model configured: [name]
- If empty → ❌ No model set. Run `/model` to fix.

## Step 3: Approval Mode

Read `~/.qwen/settings.json` and check `tools.approvalMode`:
- If set → ✅ Approval mode: [mode]
- If not set → ⚠️ Using default (asks for everything)

## Step 4: Skills

List `~/.qwen/skills/`:
- Count how many skill directories exist
- For each skill, check that `SKILL.md` exists inside
- Report: ✅ X skills installed, or ⚠️ No skills found, or ❌ Skill missing SKILL.md

## Step 5: Commands

List `~/.qwen/commands/`:
- Count how many command files exist (both .md files and subdirectories)
- Check each for valid YAML frontmatter (starts with `---`)
- Report: ✅ X commands installed, or ⚠️ No commands found

## Step 6: Memory

Check if `~/.qwen/QWEN.md` exists:
- If yes → ✅ User memory configured ([size])
- If no → ⚠️ No user memory file. Run `/memory add ...` to create one.

## Step 7: Sandbox (if course is installed)

Check if `~/qwen-sandbox/` exists:
- If yes → ✅ Sandbox directory exists with [X] subdirectories
- If no → ⚠️ No sandbox. Run `/course start` to create one.

## Step 8: Course (if installed)

Check if `~/.qwen/course-progress.json` exists:
- If yes → Read it and report:
  - Course version
  - Lessons completed / total
  - Current module
  - Last active date (and if stagnant)
- If no → ⚠️ Course not installed. Clone https://github.com/agurrey/qwen-code-course

## Step 9: Disk Space

Run: `df -h ~/` and check available space:
- If > 10GB → ✅ Plenty of disk space
- If 1-10GB → ⚠️ Getting low on disk space
- If < 1GB → ❌ Very low disk space

## Step 10: Node.js (for Qwen Code installation)

Run: `node --version 2>&1`:
- If v18+ → ✅ Node.js: [version]
- If not found → ❌ Node.js not installed
- If < v18 → ⚠️ Node.js too old (need v18+)

## Summary Report

After all checks, print:

```
=== Qwen Code Doctor ===

Authentication:  [✅/❌] ...
Model:           [✅/❌] ...
Approval Mode:   [✅/⚠️] ...
Skills:          [✅/⚠️] ...
Commands:        [✅/⚠️] ...
Memory:          [✅/⚠️] ...
Sandbox:         [✅/⚠️] ...
Course:          [✅/⚠️] ...
Disk Space:      [✅/⚠️/❌] ...
Node.js:         [✅/⚠️/❌] ...

Overall: [ALL OK / X warnings / X errors]
```

If there are errors, list them with specific fix instructions:
```
Issues found:
1. [Issue] → Fix: [command to run]
2. [Issue] → Fix: [command to run]
```

If everything is OK:
```
All checks passed. Your Qwen Code setup looks good.
```

Topic: {{args}}
