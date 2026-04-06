---
module: 2
lesson: 2
title: "Editing Files"
prerequisites: ["2-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 2.2: Editing Files

> **Time:** ~2 min reading + ~4 min doing

## The Problem

You need to change something in a file — a bug fix, a new feature, a typo correction. Normally you'd open an editor, find the line, make the change, save, and close. With Qwen Code, you just describe what needs to change.

## Mental Model

Qwen Code edits files by reading the current content, making the changes, and writing the result back. It uses either the **Edit** tool (for targeted changes) or **Write** (for replacing the whole file). You describe the change in plain English — "add a comment at the top," "change the port to 3000," "remove the debug line."

## Try It

**Your task:** Edit config.json through Qwen Code without opening an editor.

1. Make sure config.json exists from Lesson 2.1. Launch Qwen Code:
   ```bash
   cd ~/qwen-sandbox
   qwen
   ```

2. Ask: "In config.json, change the port from 8080 to 3000."
   - Qwen Code will read the file, make the change, and write it back.

3. Ask: "Add a new key called APP_VERSION with value '1.0.0' to config.json."
   - It will add the new key to the JSON.

4. Ask: "Remove the DB_PASS field from config.json — passwords shouldn't be in config files."
   - It will remove that field.

5. Ask: "Sort all the keys in config.json alphabetically."
   - It will reorganize the file.

6. Verify the changes:
   ```bash
   cat ~/qwen-sandbox/config.json
   ```
   You should see: port changed to 3000, APP_VERSION added, DB_PASS removed, keys sorted.

## Check Your Work

The model should check:
1. config.json has port set to 3000
2. config.json has APP_VERSION: "1.0.0"
3. config.json does NOT have DB_PASS
4. Keys in config.json are in alphabetical order
5. The file is still valid JSON

## Debug It

**Something's broken:** Qwen Code described the change but didn't actually make it, or the JSON is now invalid.

**Hint if stuck:** Qwen Code may be in plan mode. Also, when editing JSON, a single syntax error (missing comma, extra bracket) breaks the whole file.

**Expected fix:**
1. Check your approval mode: `/approval-mode` — make sure it's not `plan`
2. If the JSON is broken, ask Qwen Code to fix it: "config.json has invalid JSON. Read it and fix the syntax errors."
3. If all else fails, recreate it: "Delete config.json and create a new one with these keys: [list them]"

## What You Learned

You describe file changes in plain English and Qwen Code handles the editing — no text editor needed.

---

*Next: Lesson 2.3 — Running Commands — where you'll learn to have Qwen Code execute shell commands safely.*
