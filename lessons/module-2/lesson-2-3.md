---
module: 2
lesson: 3
title: "Running Shell Commands"
prerequisites: ["2-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 2.3: Running Shell Commands

> **Time:** ~2 min reading + ~4 min doing

## The Problem

You need to run a terminal command — maybe to check something, install a package, or process data. Instead of switching between Qwen Code and your terminal, you can have Qwen Code run commands for you.

## Mental Model

Qwen Code has a **Shell** tool that runs commands in a subprocess. It sees the output and can use it to make decisions. In `default` mode, it asks before running every command. This is important — a wrong command could delete files, install malware, or break your system. Always review commands before approving, especially if they involve `rm`, `sudo`, or downloading things.

## Try It

**Your task:** Have Qwen Code run commands to solve a real task.

1. Launch Qwen Code:
   ```bash
   cd ~/qwen-sandbox
   qwen
   ```

2. Ask: "Create a directory called reports, then inside it create three files: report-1.txt, report-2.txt, report-3.txt. Each file should contain 'Report N — Generated on [today's date]' where N is the number."
   - Qwen Code will run mkdir and echo/write commands.
   - Review each command before approving. Look for: correct paths, no destructive operations.

3. Ask: "List the contents of the reports directory to verify the files were created."
   - It will run `ls` and show you the result.

4. Ask: "Show me the content of report-2.txt."
   - It can either use Read or run `cat`. Either works.

5. Ask: "What's today's date?"
   - It will run `date` and show you.

6. Verify from outside Qwen Code:
   ```bash
   ls ~/qwen-sandbox/reports/
   cat ~/qwen-sandbox/reports/report-2.txt
   ```

## Check Your Work

The model should check:
1. The `reports/` directory exists in `~/qwen-sandbox/`
2. Three files exist: report-1.txt, report-2.txt, report-3.txt
3. Each file contains the correct format with its number and today's date
4. The user reviewed commands before approving (model should observe this)
5. The user can explain what the Shell tool does

## Debug It

**Something's broken:** Commands failed, or files weren't created.

**Hint if stuck:** Shell commands run in the working directory where Qwen Code was launched. If Qwen Code was launched from your home directory, paths need to be absolute (`~/qwen-sandbox/reports/` not just `reports/`).

**Expected fix:**
1. Check what directory Qwen Code was launched from
2. Re-run with absolute paths: "Create files at ~/qwen-sandbox/reports/"
3. If a command errored, ask Qwen Code to explain the error: "The command failed with this error: [paste it]. What went wrong?"

## What You Learned

Qwen Code runs shell commands and sees their output. Always review commands before approving — they have the same power as commands you type yourself.

---

*Next: Lesson 2.4 — Searching Your Codebase with Grep — where you'll find text inside files without opening each one.*
