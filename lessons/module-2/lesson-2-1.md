---
module: 2
lesson: 1
title: "Reading Files"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 2.1: Reading Files

> **Time:** ~2 min reading + ~3 min doing

## The Problem

You have a file and you need to understand what's in it. You could open it in a text editor and scroll through 200 lines. Or you could ask Qwen Code to read it and tell you what matters.

## Mental Model

When you ask Qwen Code to read a file, it uses the **Read** tool. This loads the file content into its context. It can then summarize, explain, find bugs, translate, or do anything with that content. You don't need to know the file's path exactly — you can describe it and Qwen Code will find it.

## Try It

**Your task:** Create a file and have Qwen Code read, summarize, and explain it.

1. Create a practice file:
   ```bash
   cd ~/qwen-sandbox
   cat > config.txt << 'EOF'
   # Application Configuration
   APP_NAME=MyApp
   APP_PORT=8080
   APP_DEBUG=true
   APP_LOG_LEVEL=info
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=myapp_db
   DB_USER=admin
   DB_PASS=secret123
   CACHE_TTL=3600
   MAX_CONNECTIONS=100
   EOF
   ```

2. Launch Qwen Code:
   ```bash
   qwen
   ```

3. Ask: "Read config.txt and tell me: what port does the app run on, and is debug mode enabled?"

4. Qwen Code will read the file and answer your specific questions.

5. Now ask: "Are there any security concerns in this config file?"
   - It should flag the hardcoded password (`DB_PASS=secret123`) as a security risk.

6. Now ask: "Read config.txt and convert it to JSON format, saving the result as config.json."
   - It will read the file, transform the content, and write a new file.

7. Verify:
   ```bash
   cat ~/qwen-sandbox/config.json
   ```

## Check Your Work

The model should check:
1. The file `config.txt` exists with the specified content
2. The file `config.json` exists and contains valid JSON
3. The JSON keys match the config file keys
4. The user can explain how Qwen Code reads files (it uses the Read tool)

## Debug It

**Something's broken:** Qwen Code can't find config.txt, or the JSON conversion has errors.

**Hint if stuck:** Make sure you created config.txt in `~/qwen-sandbox/` and launched Qwen Code from that directory. Qwen Code looks for files relative to its working directory.

**Expected fix:**
1. Check the file exists: `ls ~/qwen-sandbox/config.txt`
2. Launch Qwen Code from the right directory: `cd ~/qwen-sandbox && qwen`
3. Be specific about the path if needed: "Read the file at ~/qwen-sandbox/config.txt"

## What You Learned

Qwen Code reads files with the Read tool and can then summarize, analyze, or transform their content.

---

*Next: Lesson 2.2 — Editing Files — where you'll learn to modify files through Qwen Code without opening an editor.*
