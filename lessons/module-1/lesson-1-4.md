---
module: 1
lesson: 4
title: "Safety and Approval Modes"
prerequisites: ["1-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 1.4: Safety and Approval Modes

> **Time:** ~3 min reading + ~4 min doing

## The Problem

Qwen Code can modify files and run commands. That's powerful and dangerous. If you're not careful, it could delete something important, push broken code, or run a command that installs malware. The approval mode system is how you control how much freedom it has.

## Mental Model

Think of approval modes like different levels of trust:

| Mode | What it means | When to use |
|------|-------------|-------------|
| `default` | Asks before every edit and command | Daily use, learning |
| `auto-edit` | Edits files automatically, asks before commands | You trust it with files but not your system |
| `yolo` | Approves everything | Quick experiments, sandbox only |
| `plan` | Analyzes only, makes no changes | Reviewing before acting |

In `default` mode, every action needs your "yes." In `plan` mode, it can't change anything at all — only analyze and propose.

## Try It

**Your task:** See the difference between each approval mode.

1. Launch Qwen Code:
   ```bash
   cd ~/qwen-sandbox
   qwen
   ```

2. **Default mode** (you should already be in it):
   - Ask: "Create a file called test-default.txt with some text"
   - Qwen Code will ask for approval before creating it. Type `y` to approve.
   - Notice: it asked before acting.

3. **Plan mode:**
   - Type: `/approval-mode plan`
   - Ask: "Delete the file test-default.txt"
   - Qwen Code will analyze the situation and tell you what it WOULD do — but it won't actually delete anything.
   - This is useful for reviewing changes before making them.

4. **Back to default:**
   - Type: `/approval-mode default`
   - Ask: "Actually delete test-default.txt"
   - It will ask for approval. Approve it.
   - Verify: `ls ~/qwen-sandbox/test-default.txt` should say "no such file."

5. **Auto-edit mode:**
   - Type: `/approval-mode auto-edit`
   - Ask: "Create three files: a.txt, b.txt, c.txt — each with one line of text"
   - Qwen Code will create all three without asking about each edit. But it will still ask before running any shell commands.

6. **Reset to default:**
   - Type: `/approval-mode default`
   - Always go back to default when you're done experimenting.

## Check Your Work

The model should check:
1. The user experienced all four approval modes
2. The user observed that plan mode doesn't make changes
3. The user observed that auto-edit mode creates files without asking
4. The user ended in default mode (not yolo or auto-edit)
5. The user can explain when they'd use each mode

## Debug It

**Something's broken:** Qwen Code made changes in plan mode, or didn't ask for approval in default mode.

**Hint if stuck:** Approval mode state might not have switched properly. Check the current mode.

**Expected fix:**
1. Type `/approval-mode` without arguments to see the current mode
2. Re-set it explicitly: `/approval-mode default`
3. If changes were made in plan mode, something is misconfigured — this shouldn't be possible. Restart Qwen Code.

## What You Learned

Approval modes control how much freedom Qwen Code has. Default = ask everything. Plan = analyze only. Auto-edit = edit freely but ask before commands. Yolo = no questions.

---

**Module 1 Complete!** You now understand what Qwen Code is, what it isn't, how it thinks in tools, and how to keep it safe.

*Next: Module 2 — Your First Commands — where you'll learn the specific commands that make Qwen Code useful every day.*
