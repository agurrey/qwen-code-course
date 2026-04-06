---
module: 2
lesson: 5
title: "Finding Files with Glob"
prerequisites: ["2-4"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 2.5: Finding Files with Glob

> **Time:** ~2 min reading + ~3 min doing

## The Problem

You know a file exists somewhere in your project, but you don't remember the exact path. You remember it was a Python file, or it had "config" in the name, or it was in a subdirectory. Finding it manually means poking around directories. Glob does this instantly.

## Mental Model

**Glob** finds files by name pattern, not by content. While Grep searches INSIDE files, Glob searches file NAMES. Think of it as the "find file" feature. Patterns use wildcards: `*.py` finds all Python files, `**/*.md` finds all markdown files in any subdirectory, `config*` finds anything starting with "config."

## Try It

**Your task:** Use Glob to find files by name pattern across a directory tree.

1. Set up a nested directory structure:
   ```bash
   cd ~/qwen-sandbox
   mkdir -p glob-demo/src/components
   mkdir -p glob-demo/src/utils
   mkdir -p glob-demo/docs
   mkdir -p glob-demo/tests
   touch glob-demo/src/main.py
   touch glob-demo/src/components/button.py
   touch glob-demo/src/components/form.py
   touch glob-demo/src/components/modal.js
   touch glob-demo/src/utils/helpers.py
   touch glob-demo/src/utils/format.js
   touch glob-demo/docs/README.md
   touch glob-demo/docs/API.md
   touch glob-demo/tests/test_main.py
   touch glob-demo/tests/test_components.py
   ```

2. Launch Qwen Code:
   ```bash
   cd ~/qwen-sandbox/glob-demo
   qwen
   ```

3. Ask: "Find all Python files (.py) in this project."
   - It should find: main.py, button.py, form.py, helpers.py, test_main.py, test_components.py

4. Ask: "Find all JavaScript files."
   - It should find: modal.js, format.js

5. Ask: "Find all markdown files in the docs directory."
   - It should find: README.md, API.md

6. Ask: "Find all test files (files starting with 'test_')."
   - It should find: test_main.py, test_components.py

7. Ask: "Give me a tree view of all files in this project, organized by directory."
   - It should use Glob with `**/*` to find everything, then organize the output.

## Check Your Work

The model should check:
1. Qwen Code used Glob (not Shell + find/ls)
2. All Python files were found (6 total)
3. All JavaScript files were found (2 total)
4. The tree view shows the correct directory structure
5. The user can explain the difference between Glob (finds by filename) and Grep (finds by content)

## Debug It

**Something's broken:** Glob isn't finding files, or are finding too many.

**Hint if stuck:** Glob patterns are case-sensitive and path-relative. `*.py` only finds .py files in the current directory. `**/*.py` finds .py files in any subdirectory.

**Expected fix:**
1. Use `**/` prefix to search recursively: `**/*.py` instead of `*.py`
2. Be specific about the directory: "Find .py files in src/" vs "Find .py files everywhere"
3. If Glob doesn't work, try Shell fallback: "Run `find . -name '*.py'`"

## What You Learned

Glob finds files by name pattern. `*` matches anything in one directory, `**` matches any number of directories deep.

---

*Next: Lesson 2.6 — Fetching Web Content — where you'll have Qwen Code read web pages and extract information.*
