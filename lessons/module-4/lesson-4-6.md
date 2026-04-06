---
module: 4
lesson: 6
title: "Glob Tool Advanced"
prerequisites: ["module-4/lesson-4-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 4.6: Glob Tool Advanced

> **Time:** ~5 min reading + ~5 min doing

## The Problem

You need to find files, but you don't know their exact names. You know they're Python files in the `src/` directory, or JSON files anywhere in the project, or anything except log files. `find` works but is slow and verbose. Glob uses pattern matching — `**/*.py` for all Python files, `src/*.py` for Python files only in src, `**/!(*.log)` for everything except logs. When combined with Read, Grep, and Shell, Glob becomes the starting point for powerful workflows.

## Mental Model

Glob is a file pattern matcher. It uses `*` for any characters in a filename segment, `**` for any directory depth, and `?` for single characters. Unlike Grep, Glob doesn't look inside files — it matches filenames and paths. Use Glob to find what files exist, then use other tools to work with them.

## Try It

**Your task:** Create a diverse file structure and practice finding files with Glob patterns.

1. Set up:
   ```bash
   mkdir -p ~/qwen-sandbox/glob-advanced/{src,tests,docs,data,config,.github/workflows}
   cd ~/qwen-sandbox/glob-advanced

   # Create diverse files
   touch src/app.py src/utils.py src/models.py src/__init__.py
   touch tests/test_app.py tests/test_models.py tests/__init__.py tests/conftest.py
   touch docs/README.md docs/API.md docs/CONTRIBUTING.md
   touch data/users.json data/orders.csv data/logs/app.log data/logs/error.log
   touch config/settings.json config/settings.yaml config/secrets.env
   touch .github/workflows/ci.yml .github/workflows/deploy.yml
   touch Makefile LICENSE .gitignore
   ```

2. Launch Qwen Code:
   ```bash
   qwen
   ```

3. **Basic glob patterns.** Ask these in sequence:
   - "Find all Python files anywhere in the project."
     - Pattern: `**/*.py`
     - Should find: `src/app.py`, `src/utils.py`, `src/models.py`, `src/__init__.py`, `tests/test_app.py`, `tests/test_models.py`, `tests/__init__.py`, `tests/conftest.py`

   - "Find all Markdown files in the docs/ directory only."
     - Pattern: `docs/*.md`
     - Should find: `docs/README.md`, `docs/API.md`, `docs/CONTRIBUTING.md`

4. **Deep recursive patterns.** Ask:
   - "Find all files inside the data/ directory, any depth."
     - Pattern: `data/**/*`
     - Should find all files in `data/` and `data/logs/`

   - "Find all YAML and JSON config files."
     - Pattern: `config/*.{json,yaml}` or ask separately
     - Should find: `config/settings.json`, `config/settings.yaml`

5. **Specific depth patterns.** Ask:
   - "Find all `__init__.py` files — I need to see which packages are Python packages."
     - Pattern: `**/__init__.py`
     - Should find: `src/__init__.py`, `tests/__init__.py`

6. **Combining Glob with Grep.** Ask:
   - "Find all Python test files (files starting with 'test_' in tests/), then search them for any function containing 'assert'."
     - Glob finds: `tests/test_app.py`, `tests/test_models.py`
     - Grep searches those files for `assert`

7. **Combining Glob with Shell.** Ask:
   - "Find all `.py` files and count how many lines of code each has."
     - Glob finds the files, Shell runs `wc -l` on each.

8. **Negation patterns.** Ask:
   - "Find all files in the data/ directory except log files."
     - Pattern: `data/**/*` then filter out `*.log`, or use the tool's exclusion feature.
     - Should find: `data/users.json`, `data/orders.csv`

## Check Your Work

The model should check:
1. All project files exist across the full directory structure
2. Glob `**/*.py` finds at least 8 Python files
3. Glob `docs/*.md` finds exactly 3 Markdown files (not recursive)
4. Glob `data/**/*` finds files in `data/logs/` too
5. Glob `**/__init__.py` finds exactly 2 files
6. The combined Glob+Grep workflow found assert statements in test files
7. The combined Glob+Shell workflow produced line counts for Python files
8. The user can explain the difference between `*.py`, `**/*.py`, and `src/*.py`

## Debug It

**Something's broken:** Glob returns fewer files than expected, or matches files in directories you didn't intend.

The most common confusion is `*` vs `**`:
- `*.py` matches Python files only in the current directory (not subdirectories)
- `**/*.py` matches Python files in any directory, any depth
- `src/*.py` matches Python files only directly inside `src/` (not `src/subdir/`)
- `src/**/*.py` matches Python files in `src/` at any depth

**Hint if stuck:** If you're not seeing expected results, check what directory Qwen Code is searching from. Glob patterns are relative to the working directory. If you launched Qwen Code from `~`, the pattern `**/*.py` searches your entire home directory — which is slow and noisy.

**Expected fix:** Always specify a path or launch Qwen Code from the correct directory:
```bash
cd ~/qwen-sandbox/glob-advanced && qwen
```

Then patterns like `**/*.py` are scoped to your project only.

If Glob doesn't support negation directly (depends on the implementation), use a two-step approach:
1. Glob to find all matching files
2. Filter the results manually or with Shell: `echo results | grep -v '\.log$'`

## What You Learned

Glob finds files by pattern, not content — combine it with Grep, Read, and Shell to build powerful file discovery and analysis workflows.

---

*Next: Lesson 4.7 — Web Fetch Tool Advanced — where you'll learn to fetch APIs, extract JSON, handle errors, and work with rate limits.*
