---
module: 8
lesson: 1
title: "What Are Agents"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

Every time you give Qwen Code a complex task, it works on it step by step in your main session. But some tasks are self-contained and time-consuming — like researching five different libraries, auditing an entire codebase for security issues, or generating documentation for twenty files. While Qwen Code works on those, you're stuck waiting. You can't do other work in the same session because it's busy. What if you could fire off these tasks in the background and get results when they're done?

## Mental Model

An agent is a separate Qwen Code session that runs independently with its own instructions and tools. You give it a prompt, it goes off and works on its own, and it comes back with results. Think of it like handing a task to a colleague: you tell them what you need, they go do it, they bring you the answer. Meanwhile, you're free to work on something else.

## Try It

You'll create a task definition file that represents what you'd hand to an agent, then simulate the agent workflow to understand how it works.

Set up your workspace:

```bash
mkdir -p ~/qwen-course-work/module-8
cd ~/qwen-course-work/module-8
```

Create a file that represents an agent task — a self-contained research assignment:

```bash
cat > agent-task.json << 'EOF'
{
  "task": "Research Python HTTP libraries",
  "prompt": "Compare the following Python HTTP client libraries: requests, httpx, aiohttp, and urllib3. For each one, find: (1) installation command, (2) basic usage example in 3 lines of code, (3) whether it supports async, (4) latest version number. Write the results to a file called http-comparison.md in the current directory.",
  "scope": "research and file output only — do not modify any existing files",
  "expected_output": "http-comparison.md with a comparison table",
  "can_run_parallel": true
}
EOF
```

This is the kind of task you'd give to an agent: it's self-contained, has clear success criteria, and produces a tangible output file.

Now simulate what the agent would do. An agent reads the prompt, plans its approach, executes step by step, and produces the output:

```bash
cat > simulate_agent.py << 'PYEOF'
#!/usr/bin/env python3
"""Simulate an agent working on a research task."""
import json
import time

task = json.load(open("agent-task.json"))

print(f"=== Agent: {task['task']} ===")
print()

steps = [
    ("1. Understanding the prompt", "Reading task instructions..."),
    ("2. Planning", "Need to research 4 libraries: requests, httpx, aiohttp, urllib3"),
    ("3. Research: requests", "Found: pip install requests, sync-only, v2.31.0"),
    ("4. Research: httpx", "Found: pip install httpx, async support, v0.25.0"),
    ("5. Research: aiohttp", "Found: pip install aiohttp, async-only, v3.9.0"),
    ("6. Research: urllib3", "Found: pip install urllib3, sync-only, v2.1.0"),
    ("7. Writing output", "Creating http-comparison.md with comparison table..."),
    ("8. Verification", "Checking output file has all 4 libraries..."),
]

for step_name, detail in steps:
    print(f"  [{step_name}]")
    print(f"    {detail}")
    time.sleep(0.3)

print()
print("Agent completed the task.")
print(f"Output: {task['expected_output']}")
PYEOF
python3 simulate_agent.py
```

This shows the agent's internal workflow. Notice how each step is independent — the agent could research all four libraries in any order, or even in parallel if it had that capability.

Now create the output the agent would produce:

```bash
cat > http-comparison.md << 'EOF'
# Python HTTP Client Library Comparison

| Library | Install | Async | Latest |
|---------|---------|-------|--------|
| requests | `pip install requests` | No | 2.31.0 |
| httpx | `pip install httpx` | Yes | 0.25.0 |
| aiohttp | `pip install aiohttp` | Yes (async-only) | 3.9.0 |
| urllib3 | `pip install urllib3` | No | 2.1.0 |

## Quick Start Examples

### requests
```python
import requests
r = requests.get("https://api.example.com/data")
print(r.json())
```

### httpx
```python
import httpx
r = httpx.get("https://api.example.com/data")
print(r.json())
```

### aiohttp
```python
import aiohttp
async with aiohttp.ClientSession() as s:
    r = await s.get("https://api.example.com/data")
```

### urllib3
```python
import urllib3
http = urllib3.PoolManager()
r = http.request("GET", "https://api.example.com/data")
```

## Recommendation

Use **httpx** for new projects — it has a requests-compatible API plus async support.
Use **requests** for simple sync projects where you want maximum compatibility.
Use **aiohttp** for high-concurrency async applications.
Use **urllib3** when you need low-level control over connection pooling.
EOF
echo "Agent output created: http-comparison.md"
wc -l http-comparison.md
```

## Check Your Work

Verify the agent's output meets the task requirements:

```bash
python3 -c "
content = open('http-comparison.md').read()

checks = {
    'Mentions requests': 'requests' in content,
    'Mentions httpx': 'httpx' in content,
    'Mentions aiohttp': 'aiohttp' in content,
    'Mentions urllib3': 'urllib3' in content,
    'Has install commands': 'pip install' in content,
    'Has async info': 'async' in content.lower(),
    'Has code examples': '\`\`\`python' in content,
    'Has recommendation': 'Recommendation' in content or 'recommend' in content.lower(),
}

print('Agent Output Verification:')
all_pass = True
for check, result in checks.items():
    status = 'PASS' if result else 'FAIL'
    if not result:
        all_pass = False
    print(f'  {status}: {check}')

print()
if all_pass:
    print('All checks passed — agent produced complete output.')
else:
    print('Some checks failed — agent output is incomplete.')
"
```

## Debug It

What happens when you give an agent a vague or ambiguous prompt? Simulate this by creating a poorly specified task:

```bash
cat > bad-agent-task.json << 'EOF'
{
  "task": "Look into it",
  "prompt": "Check the thing and do the stuff",
  "scope": "whatever",
  "expected_output": "something good"
}
EOF
python3 -c "
import json
task = json.load(open('bad-agent-task.json'))
print(f'Task: {task[\"task\"]}')
print(f'Prompt: {task[\"prompt\"]}')
print()
print('Problems with this task:')
if len(task['prompt'].split()) < 10:
    print('  - Prompt is too vague (less than 10 words)')
if not task.get('scope') or task['scope'] in ('whatever', 'anything', 'any'):
    print('  - Scope is not defined or too broad')
if not task.get('expected_output') or task['expected_output'] in ('something good', 'something'):
    print('  - Expected output is not specific enough')
print()
print('An agent receiving this task would not know what to do.')
print('It would likely produce irrelevant or wrong output.')
"
```

The fix is to be specific about what you want, what the agent should not do, and what the output should look like. Compare the bad task with your original good task — the difference is specificity.

## What You Learned

An agent is an independent Qwen Code session that takes a self-contained task, works on it autonom, and returns a result — freeing you to do other work while it runs.

*Next: Lesson 8.2 — When to Use Agents — You'll learn to recognize which tasks deserve delegation and which are better done directly.*
