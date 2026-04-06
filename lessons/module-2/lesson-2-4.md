---
module: 2
lesson: 4
title: "Searching with Grep"
prerequisites: ["2-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 2.4: Searching with Grep

> **Time:** ~2 min reading + ~4 min doing

## The Problem

You have a directory full of files and you need to find where a specific word, function name, or phrase appears. Opening each file is slow. You need search — and Qwen Code can do it for you.

## Mental Model

Qwen Code has a **Grep** tool that searches file contents using patterns (regular expressions). It's like Ctrl+F but across your entire project at once. You can search for exact text or patterns like "all function definitions" or "every line with an email address."

## Try It

**Your task:** Search across multiple files to find specific content.

1. Set up test files:
   ```bash
   cd ~/qwen-sandbox
   mkdir -p search-demo
   cd search-demo
   echo "Contact us at admin@example.com" > info.txt
   echo "Support email: support@example.com" > support.txt
   echo "No email listed here" > about.txt
   echo "Send feedback to feedback@example.com" > feedback.txt
   echo "John's email: john@example.com" > team.txt
   ```

2. Launch Qwen Code:
   ```bash
   cd ~/qwen-sandbox/search-demo
   qwen
   ```

3. Ask: "Find all lines that contain an email address (something@something.com) across all files in this directory."
   - Qwen Code will use Grep to search for the pattern.
   - It should find 4 matches across info.txt, support.txt, feedback.txt, and team.txt.

4. Ask: "Which files do NOT contain an email address?"
   - It should identify about.txt.

5. Ask: "Count how many email addresses are in each file."
   - It will grep each file individually and count matches.

6. Ask: "Create a file called emails.txt with one email address per line, listing all emails found across all files."
   - It will compile the results.

7. Verify:
   ```bash
   cat ~/qwen-sandbox/search-demo/emails.txt
   ```
   Should list: admin@example.com, support@example.com, feedback@example.com, john@example.com

## Check Your Work

The model should check:
1. Qwen Code used Grep (not Shell + grep) to search
2. All 4 email addresses were found
3. about.txt was correctly identified as having no email
4. emails.txt contains all 4 emails, one per line
5. The user can explain the difference between Grep and reading each file manually

## Debug It

**Something's broken:** Grep didn't find results, or found too many.

**Hint if stuck:** The search pattern matters. A simple `@` will find any line with @. A more specific pattern like `\w+@\w+\.com` finds email-like strings. Also check that Qwen Code is searching in the right directory.

**Expected fix:**
1. Be specific about where to search: "Search all .txt files in the current directory"
2. Be specific about the pattern: "Find lines containing @ that look like email addresses"
3. If Grep isn't finding results, fall back to Shell: "Run `grep -r '@' .` to search all files"

## What You Learned

Grep searches file contents for patterns across your entire project — like Ctrl+F for your whole codebase.

---

*Next: Lesson 2.5 — Finding Files with Glob — where you'll locate files by name pattern without knowing exactly where they are.*
