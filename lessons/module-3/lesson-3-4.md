---
module: 3
lesson: 4
title: "Working with Larger Files"
prerequisites: ["module-3/lesson-3-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 3.4: Working with Larger Files

> **Time:** ~5 min reading + ~5 min doing

## The Problem

You have a 500-line log file, a 2000-line CSV export, or a 1000-line source file. Asking Qwen Code to "read the whole thing" works, but it burns through context window tokens and returns a wall of text. You don't need the whole file — you need the error at line 347, the last 20 lines, or the function called `process_orders`. Reading files strategically saves tokens, time, and mental energy.

## Mental Model

Large files are books, not pamphlets. You don't read a book cover to cover to find one fact. You use the table of contents, the index, or jump to a chapter. With Qwen Code, you do the same thing: read specific line ranges, search for patterns, or ask targeted questions about sections.

## Try It

**Your task:** Create a large file and practice reading it in pieces.

1. Generate a large log-style file:
   ```bash
   mkdir -p ~/qwen-sandbox/large-files
   cd ~/qwen-sandbox/large-files

   python3 -c "
   import datetime
   lines = []
   for i in range(500):
       ts = datetime.datetime(2024, 1, 15, 8, 0, 0) + datetime.timedelta(minutes=i)
       level = 'ERROR' if i in [42, 157, 389] else 'INFO'
       msg = f'ERROR: Database connection timeout at request #{i}' if level == 'ERROR' else f'INFO: Processed request #{i} in {0.1 + (i % 10) * 0.05:.2f}s'
       lines.append(f'[{ts.isoformat()}] {level} - {msg}')
   print('\n'.join(lines))
   " > application.log
   ```

2. Verify the file size:
   ```bash
   wc -l ~/qwen-sandbox/large-files/application.log
   ```
   You should see 500 lines.

3. Launch Qwen Code:
   ```bash
   qwen
   ```

4. **Targeted line reading.** Ask: "Read lines 40-45 of application.log and tell me what's happening."
   - Qwen Code uses the Read tool with offset/limit parameters to fetch only those lines.
   - You'll see the ERROR at line 42 (index 42) without loading all 500 lines.

5. **Find specific content.** Ask: "Find all ERROR entries in application.log and tell me what line numbers they're on."
   - Qwen Code uses Grep to search for "ERROR" and reports the matching lines.
   - This is much faster than reading the whole file.

6. **Read the beginning and end.** Ask: "Show me the first 5 lines and last 5 lines of application.log."
   - Qwen Code reads two small sections instead of the entire file.
   - You see the time range the log covers without reading 500 lines.

7. **Summarize without reading everything.** Ask: "How many total lines are in application.log, and how many contain 'timeout'?"
   - Qwen Code uses shell commands (`wc -l` and `grep -c`) to get counts without reading file content.

8. **Extract a section.** Ask: "Read lines 150-165 of application.log — there should be an error around line 157. Extract just the error line and the two lines before and after it."
   - This is the "context window" approach: read a small window around the interesting part.

## Check Your Work

The model should check:
1. `application.log` exists with 500 lines
2. The file contains exactly 3 ERROR lines (at lines 43, 158, 390 — 1-indexed)
3. The user can explain the difference between reading a whole file vs. reading line ranges
4. The user used Grep to find ERROR entries without reading the entire file
5. The user can explain when to use: line ranges, grep patterns, head/tail, and shell counts

## Debug It

**Something's broken:** Qwen Code reads the whole 500-line file when you only needed one line, or the output gets truncated mid-response.

This is a context window problem. Qwen Code has a maximum context size. Reading a 500-line file plus generating a response might hit the limit, causing truncation.

**Hint if stuck:** Instead of "read the whole file," be specific about what you need:
- "Read lines 40-50" — uses offset/limit
- "Grep for ERROR" — finds only matching lines
- "Count lines with `wc -l`" — no content reading needed

**Expected fix:** Change your request from broad to targeted. Instead of "read application.log," say "grep application.log for ERROR and show me the results." Instead of "summarize this file," say "what are the first 10 and last 10 lines of this file."

You can also use shell tools directly:
```bash
# See only ERROR lines:
grep ERROR ~/qwen-sandbox/large-files/application.log

# See line numbers:
grep -n ERROR ~/qwen-sandbox/large-files/application.log

# See lines around a specific line:
sed -n '40,45p' ~/qwen-sandbox/large-files/application.log
```

Then ask Qwen Code about those specific results instead of the whole file.

## What You Learned

Large files should be read strategically — line ranges, pattern searches, and counts save tokens and avoid context overflow.

---

*Next: Lesson 3.5 — Project Templates — where you'll create reusable project structures so you never start from scratch again.*
