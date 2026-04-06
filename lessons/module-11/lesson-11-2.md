---
module: 11
lesson: 2
title: "Planning with Qwen Code"
prerequisites: ["module-11/lesson-11-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You've picked your project and scoped it, but jumping straight into coding leads to meandering file structures, functions that do three unrelated things, and half-implemented features that you forgot about. The difference between a project that feels chaotic and one that feels professional isn't the code — it's the planning that happens before the code.

## Mental Model

Planning with Qwen Code is like **having an architect review your blueprint before you pour concrete** — you describe what you want, Qwen Code helps you structure it, you review the plan, and only then do you start building. One planning session saves hours of refactoring.

## Try It

You'll use Qwen Code's planning capabilities to break down your project into a concrete, actionable plan.

### Step 1: Describe the project to Qwen Code

Start Qwen Code in your project directory and describe what you're building:

```
I'm building a server health checker. It needs to:
1. Check if 3 servers respond to HTTP requests
2. Check if disk usage is under 90%
3. Send a summary to a chat webhook
4. Exit 0 on success, 1 on failure
5. All config comes from environment variables

Here's my intended structure:
src/checker.py, src/notifier.py, src/config.py
tests/test_checker.py, tests/test_notifier.py

Plan out the implementation step by step.
```

Qwen Code will analyze your request and produce a structured plan. It should look something like:

```
Here's my plan:

1. Create src/config.py
   - Read environment variables: SERVER_URLS, DISK_THRESHOLD, WEBHOOK_URL
   - Validate all required vars are set
   - Return a config dict

2. Create src/checker.py  
   - Function check_server(url) -> bool: HTTP GET, return True if 200
   - Function check_disk(path, threshold) -> bool: return True if usage < threshold
   - Function run_all_checks(config) -> dict: run all checks, return results

3. Create src/notifier.py
   - Function send_summary(results, webhook_url) -> None: POST JSON to webhook

4. Create the main entry point (src/__main__.py or a run.py)
   - Load config, run checks, send notification, exit with appropriate code

5. Create tests for each module
   - test_checker.py: mock HTTP responses, mock disk usage
   - test_notifier.py: mock POST requests

Shall I proceed with this plan?
```

### Step 2: Review and adjust the plan

Before saying yes, review the plan critically:

- **Does it match your scope?** Nothing extra, nothing missing?
- **Is the order logical?** Can you build step 1 without needing step 3?
- **Are the boundaries clean?** Does each file have one responsibility?
- **Is testing included?** Every feature should have corresponding tests

If something is wrong, don't accept the plan yet — refine it:

```
The plan looks good but I want to add error handling with retries for the HTTP checks. Also, let's put the main entry point in run.py instead of __main__.py. Update the plan.
```

Qwen Code will revise. Keep refining until the plan is right.

### Step 3: Use plan mode for oversight

If you're working in `plan` approval mode, Qwen Code will show you the plan before executing:

```
/approve plan
```

Then give your planning prompt. Qwen Code will show the full plan and wait for your approval. This is the safest way to execute multi-step planning because you review everything before it happens.

### Step 4: Execute the plan

Once you're happy with the plan, approve it. Qwen Code will create the file structure and scaffold the code:

```
Yes, proceed with the plan.
```

Qwen Code will create each file with the appropriate structure. After it's done, verify:

```bash
find . -type f -name "*.py" | sort
```

You should see all the planned files created. Check their contents:

```bash
cat src/config.py
```

The file should have the structure Qwen Code planned — reading environment variables, with placeholder logic where the implementation goes.

### Step 5: Break down each step into tasks

Now that the structure exists, break each file into specific implementation tasks. Ask Qwen Code:

```
Let's implement src/config.py first. Break it down into the smallest possible tasks.
```

Expected breakdown:

```
Tasks for src/config.py:
1. Import os module
2. Define required variables: SERVER_URLS, DISK_THRESHOLD, WEBHOOK_URL
3. Read each from environment with os.environ.get()
4. Validate none are None — raise ValueError if missing
5. Parse SERVER_URLS from comma-separated string to list
6. Parse DISK_THRESHOLD from string to int
7. Return config dict with all values
```

This level of breakdown makes implementation straightforward — you (or Qwen Code) can tackle each task one at a time.

### Step 6: Set up your development workflow

Before implementing, set up a smooth development loop. Ask Qwen Code:

```
Set up a test runner so I can run `pytest tests/ -v` and see results quickly. Also add a requirements.txt with pytest.
```

Qwen Code will create the necessary files. Verify:

```bash
cat requirements.txt
pytest tests/ -v --collect-only
```

The `--collect-only` flag shows which tests would run without actually running them — a good sanity check that your test structure is correct.

### Step 7: Create a project checklist

Ask Qwen Code to generate a checklist you can track progress against:

```
Create a CHECKLIST.md file with all the implementation tasks from our plan, with checkboxes.
```

This gives you a visible progress tracker:

```markdown
# Implementation Checklist

## src/config.py
- [ ] Read environment variables
- [ ] Validate required vars
- [ ] Parse SERVER_URLS to list
- [ ] Parse DISK_THRESHOLD to int
- [ ] Return config dict

## src/checker.py
- [ ] Implement check_server(url)
- [ ] Implement check_disk(path, threshold)
- [ ] Implement run_all_checks(config)
...
```

Update this as you work. The satisfaction of checking off boxes keeps momentum going.

## Check Your Work

1. Verify your project structure matches the plan:

```bash
find . -type f \( -name "*.py" -o -name "*.md" -o -name "*.txt" \) | sort
```

2. Verify your CHECKLIST.md exists and covers all planned work:

```bash
cat CHECKLIST.md
```

3. Run the test collection to verify test structure:

```bash
pytest tests/ --collect-only -q
```

Should show all test files discovered, even if they're empty (no tests written yet).

4. Verify your QWEN.md is still accurate after planning — update it if the plan changed the structure:

```bash
cat QWEN.md
```

## Debug It

1. **"Qwen Code created files in the wrong directories."** This usually means your QWEN.md structure description didn't match reality, or Qwen Code started from the wrong directory. Check:

```bash
pwd
```

Make sure you're in the project root. If files are in the wrong place, move them and update QWEN.md.

2. **"The plan included things I didn't ask for."** Qwen Code sometimes adds "helpful" extras you didn't scope. Check the plan carefully and remove anything out of scope before approving. You can say: "Remove the logging setup and the Makefile — those are out of scope."

3. **"The scaffolded files are empty skeletons."** This is expected — planning creates structure, not implementation. The files have function signatures and pass/fail placeholders. Implementation comes next, task by task. If you expected working code from planning alone, you skipped the implementation step.

4. **"Qwen Code's plan doesn't match my QWEN.md structure."** QWEN.md is guidance, not a constraint. If Qwen Code suggests a different (better) structure, consider whether to follow its suggestion. The plan is a negotiation — you can accept its structure or insist on yours.

## What You Learned

Planning with Qwen Code turns a vague idea into a structured blueprint — review the plan before executing, break each step into small tasks, and track progress with a checklist.

*Next: Lesson 11.3 — Building It — You'll put all your skills to work, implementing the project with commands, tools, skills, hooks, and memory working together like a real development workflow.*
