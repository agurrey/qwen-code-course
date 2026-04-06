---
module: 11
lesson: 3
title: "Building It"
prerequisites: ["module-11/lesson-11-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You have a plan, a structure, and a checklist — but now you need to actually write the code. This is where all ten previous modules converge: file operations to create and edit, shell commands to run tests, hooks to prevent mistakes, memory to follow your conventions, approval modes to control the friction, and skills to handle specialized tasks. Building is where the course stops being lessons and starts being practice.

## Mental Model

Building with Qwen Code is **iterative collaboration, not delegation** — you don't describe the whole thing and walk away. You work task by task, review each result, fix what's wrong, and move to the next task. The loop is: describe one task, let Qwen Code implement it, verify the result, commit, repeat.

## Try It

You'll implement your project task by task, using the full Qwen Code toolkit at each step.

### The implementation loop

Here's the loop you'll repeat for every task on your checklist:

```
1. Pick the next unchecked item from CHECKLIST.md
2. Ask Qwen Code to implement it
3. Review the code it writes
4. Run tests to verify
5. If tests pass: commit, check off the item, go to step 1
6. If tests fail: describe the failure, ask Qwen Code to fix it, go to step 4
```

### Step 1: Implement the first module

Start with the simplest module — usually config or utilities. Ask Qwen Code:

```
Implement src/config.py. It should:
- Read SERVER_URLS, DISK_THRESHOLD, and WEBHOOK_URL from environment variables
- SERVER_URLS is a comma-separated list of URLs, parse it into a Python list
- DISK_THRESHOLD is an integer percentage (default 90)
- WEBHOOK_URL is a URL string
- If any required var is missing, raise ValueError with the missing var name
- Return a dict: {"server_urls": [...], "disk_threshold": int, "webhook_url": str}
```

Qwen Code will write the implementation. Review it:

```bash
cat src/config.py
```

Check:
- Does it handle all three environment variables?
- Does it parse the comma-separated list correctly?
- Does the default for DISK_THRESHOLD work?
- Are the error messages clear?

### Step 2: Test the first module

Before moving on, write tests for what you just built:

```
Write tests for src/config.py in tests/test_config.py. Test:
- All env vars set correctly
- Missing SERVER_URLS raises ValueError
- Missing DISK_THRESHOLD uses default of 90
- SERVER_URLS parsing with multiple URLs
- SERVER_URLS parsing with single URL
```

Qwen Code will create the test file. Run the tests:

```bash
pytest tests/test_config.py -v
```

**Expected output**: All tests pass. If any fail, paste the failure output and ask Qwen Code to fix it:

```
tests/test_config.py::test_missing_server_urls FAILED
ValueError: WEBHOOK_URL not set

The test expects ValueError for SERVER_URLS but got WEBHOOK_URL. Fix the validation order.
```

### Step 3: Use hooks to prevent mistakes

While building, your hooks are actively protecting you. Test this by asking Qwen Code to do something your hooks should catch:

```
add my API key to the config file: API_KEY = "sk-12345"
```

If you have a secret-protection hook, it should fire:

```
Hook 'protect-secrets' triggered:
Secret value detected. Make sure this isn't being hardcoded — use environment variables.
```

This is your safety net working. The hook caught you (or Qwen Code) about to hardcode a secret.

### Step 4: Use memory to enforce conventions

Your MEMORY.md and QWEN.md should be shaping how Qwen Code writes code without you having to remind it. If your MEMORY.md says "use type hints on every function," verify:

```bash
cat src/config.py
```

The function signatures should have type annotations. If they don't, your memory isn't working — check:

```
/memory list
```

If your preferences don't appear, they may not be in MEMORY.md or may be overridden.

### Step 5: Implement the core logic

Now implement the main business logic. For the health checker, this is the checker module:

```
Implement src/checker.py:
- check_server(url: str) -> bool: HTTP GET the URL, return True if status 200, False otherwise. Add a 5-second timeout.
- check_disk_usage(path: str, threshold: int) -> bool: Use shutil.disk_usage to check if the path's disk usage is below threshold percent. Return True if OK.
- run_all_checks(config: dict) -> dict: Run all checks and return {"servers": {url: bool, ...}, "disk": bool, "all_ok": bool}
```

Qwen Code implements it. Test it:

```bash
# Test with fake environment
SERVER_URLS="http://localhost:8080" DISK_THRESHOLD=90 WEBHOOK_URL="http://localhost:9090/hook" python -c "from src.checker import run_all_checks; print(run_all_checks(...))"
```

Or write proper tests:

```
Write tests for src/checker.py. Mock the HTTP calls with responses of 200 and 500. Mock disk usage to test both below and above threshold.
```

### Step 6: Use the right tools for each subtask

Not every task in your project is a code-writing task. Use Qwen Code's full toolkit:

- **File operations**: Create, edit, and read files throughout implementation
- **Shell commands**: Run tests, check environment variables, verify file permissions
- **Search/grep**: Find all references to a function before renaming it
- **Skills**: If you have specialized skills installed (like `pre-plan` for planning), use them for their specific purpose
- **Approval modes**: Switch to `accept` mode when implementing tricky logic, back to `default` for routine tasks

```
/approve accept
```

Now implement the notifier module with full oversight of each action.

### Step 7: Commit incrementally

After each module passes its tests, commit:

```bash
git add -A
git status
git commit -m "Implement config.py with env var parsing and tests"
```

Use the commit message to describe what was implemented, not just "update files." If something breaks, you can bisect to find which commit introduced the problem:

```bash
git log --oneline
```

### Step 8: Integration — wire it all together

Once all modules work individually, wire them together:

```
Create run.py that:
1. Loads config from environment
2. Runs all checks
3. Prints JSON summary to stdout
4. Sends notification to webhook if configured
5. Exits 0 if all_ok, 1 if any check failed
```

Test the full pipeline:

```bash
SERVER_URLS="http://localhost:8080" DISK_THRESHOLD=90 WEBHOOK_URL="" python run.py
echo "Exit code: $?"
```

### Step 9: Edge case review

Before declaring the project done, ask Qwen Code to review for edge cases:

```
Review all the code in src/ and tests/. What edge cases are we not handling?
```

Qwen Code should identify things like:
- What if a server URL is malformed?
- What if the webhook itself is down?
- What if disk usage check runs on a path that doesn't exist?
- What about network timeouts?

Implement the fixes for any critical edge cases. Leave nice-to-have improvements for v2.

### Step 10: Final verification

Run the full test suite:

```bash
pytest tests/ -v --tb=short
```

Check coverage:

```bash
pytest tests/ --cov=src --cov-report=term-missing
```

Verify no secrets are hardcoded:

```bash
grep -r "sk-\|api_key\|password\|secret" src/ tests/
```

Should return nothing (except comments or test fixtures).

## Check Your Work

1. All tests pass:

```bash
pytest tests/ -v
```

2. All checklist items are checked off:

```bash
grep "\[ \]" CHECKLIST.md
```

Should return nothing — every item should be `[x]`.

3. Code follows your conventions (from MEMORY.md and QWEN.md):

```bash
# Check type hints
grep -r "def " src/ | grep -v "->"
# Should return nothing if all functions have return type hints
```

4. Git history shows incremental commits:

```bash
git log --oneline
```

Should show 5-10 commits, each implementing one module.

5. No secrets hardcoded:

```bash
grep -rn "password\|api_key\|secret\|token" src/ --include="*.py" | grep -v "os.environ\|env\.get\|#"
```

Should return nothing.

## Debug It

1. **"Tests pass locally but the script fails when run for real."** This is the classic mock-vs-real problem. Your tests use mocked HTTP calls that always succeed. Test against a real endpoint:

```bash
# Start a test server or use a real endpoint
SERVER_URLS="https://httpbin.org/status/200" python run.py
```

2. **"Qwen Code keeps forgetting my conventions halfway through."** Long sessions cause the model to drift from its initial context. Re-ground it:

```
Remember: use type hints on every function, snake_case for names, and add docstrings. Please review the code you just wrote and fix any convention violations.
```

Or check if your MEMORY.md is being read:

```
/memory list
```

3. **"I've been working for hours and the project isn't done."** Scope creep. Stop. Run `git status` to see how much is uncommitted. Commit what works. Then re-read your CHECKLIST.md and CROSS OFF everything that's not essential. The goal is finished, not perfect.

## What You Learned

Building with Qwen Code is a tight loop of implementing one task at a time, testing, committing, and moving to the next — with hooks, memory, and approval modes working silently in the background.

*Next: Lesson 11.4 — Shipping It — You'll integrate with git, prepare for deployment, share your work, and reflect on everything you've achieved across all eleven modules.*
