---
module: 4
lesson: 4
title: "Shell Tool Advanced"
prerequisites: ["module-4/lesson-4-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 4.4: Shell Tool Advanced

> **Time:** ~5 min reading + ~5 min doing

## The Problem

Running `ls` or `cat` through Qwen Code's Shell tool is easy. But real work requires more: running a server in the background while you test it, piping output through multiple filters, setting environment variables for a script, and handling errors without losing your terminal. When shell commands get complex, you need technique.

## Mental Model

The Shell tool is a remote control for your terminal. It can run any command, but it has limits — long-running commands may time out, background processes need special handling, and errors can cascade. Knowing the techniques for piping, env vars, background execution, and error handling makes you a power user.

## Try It

**Your task:** Practice advanced shell techniques through Qwen Code.

1. Set up:
   ```bash
   mkdir -p ~/qwen-sandbox/shell-advanced
   cd ~/qwen-sandbox/shell-advanced
   ```

2. Launch Qwen Code:
   ```bash
   qwen
   ```

3. **Piping commands.** Ask:
   "Create a file called names.txt with these names, one per line: Alice, Bob, Charlie, Alice, Diana, Bob, Eve, Alice. Then count how many times each name appears, sorted by frequency."

   Qwen Code should use a pipeline like:
   ```bash
   sort names.txt | uniq -c | sort -rn
   ```
   This chains three commands: sort, count unique, sort by count.

4. **Environment variables.** Ask:
   "Run this command with DATABASE_URL set to 'postgres://localhost/test' and APP_ENV set to 'testing': python3 -c 'import os; print(os.environ.get(\"DATABASE_URL\"), os.environ.get(\"APP_ENV\"))'"

   Qwen Code uses env var syntax:
   ```bash
   DATABASE_URL='postgres://localhost/test' APP_ENV='testing' python3 -c '...'
   ```

5. **Background processes.** Ask:
   "Start a Python HTTP server in the background on port 8765, then verify it's running by fetching its home page."

   Qwen Code runs:
   ```bash
   python3 -m http.server 8765 &
   ```
   Then verifies with:
   ```bash
   curl -s http://localhost:8765/
   ```

   After verification, ask Qwen Code to clean up: "Kill the background HTTP server."

6. **Error handling.** Ask:
   "Run a command that will fail: `cat nonexistent_file.txt`. Show me the error output and the exit code."

   Qwen Code should show the stderr output. Then ask:
   "Now run the same command but redirect stderr to a file called error.log, and exit gracefully."

   ```bash
   cat nonexistent_file.txt 2> error.log; echo "Exit code: $?"
   ```

7. **Conditional execution.** Ask:
   "Create a script called check_port.sh that checks if port 8765 is in use. If it is, print 'Port 8765 is in use'. If not, print 'Port 8765 is free'. Use the appropriate exit code."

   Qwen Code creates:
   ```bash
   #!/bin/bash
   if lsof -i :8765 > /dev/null 2>&1; then
       echo "Port 8765 is in use"
       exit 0
   else
       echo "Port 8765 is free"
       exit 1
   fi
   ```

## Check Your Work

The model should check:
1. `names.txt` exists with 8 names including duplicates
2. The pipeline `sort | uniq -c | sort -rn` produces correct frequency counts
3. Environment variables were passed correctly to the Python one-liner
4. The HTTP server started on port 8765 and responded to curl
5. The background process was cleaned up (no longer listening on 8765)
6. `error.log` exists with the "No such file" error
7. `check_port.sh` exists and runs correctly

## Debug It

**Something's broken:** The background server didn't start, or the pipe produced wrong output, or the environment variable wasn't passed through.

Background processes are the trickiest. Qwen Code's shell may not support true background execution (`&`) in all modes. If the server doesn't start:

```bash
# Alternative: run the server and redirect output
python3 -m http.server 8765 > /dev/null 2>&1 &
disown

# Verify it started:
sleep 1
lsof -i :8765
```

**Hint if stuck:** For pipes, test each stage individually. If `sort names.txt | uniq -c | sort -rn` gives wrong results, check:
```bash
sort names.txt          # Step 1: is it sorted?
sort names.txt | uniq -c  # Step 2: are counts right?
```

**Expected fix:** For environment variables, the syntax matters. It must be `VAR=value command`, not `export VAR=value && command` (the latter works but is two commands). If a pipe fails, check that the input file exists and has the expected content. For background processes, if `&` doesn't work, use the shell tool's `is_background` flag or run the server as a foreground process in a separate Qwen Code session.

## What You Learned

The Shell tool handles pipes, environment variables, background processes, and error handling — but each technique has specific syntax and edge cases you need to know.

---

*Next: Lesson 4.5 — Grep Tool Advanced — where you'll master regex patterns, file type filtering, and directory exclusions for powerful code searching.*
