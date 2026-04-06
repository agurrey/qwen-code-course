---
module: 8
lesson: 4
title: "Multiple Agents in Parallel"
prerequisites: ["module-8/lesson-8-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You have three independent tasks: audit the codebase for TODOs, compare three libraries, and scan for security issues. You could run them one after another, waiting for each to finish before starting the next. Or you could run all three at the same time using multiple agents in parallel and get all results back in the time it takes to complete just one task. The question is: when can tasks run in parallel, and how do you combine the results?

## Mental Model

Multiple agents in parallel is like giving the same task to three different colleagues at once — they each work independently and you collect all their reports when they're done. Tasks can run in parallel when they don't depend on each other's output. When they do depend on each other, you must chain them: agent A finishes, then agent B starts with A's results.

## Try It

You'll set up three independent agent tasks, simulate running them in parallel versus sequentially, and measure the time difference. Then you'll learn how to merge their outputs.

Set up your workspace:

```bash
mkdir -p ~/qwen-course-work/module-8/parallel
cd ~/qwen-course-work/module-8/parallel
```

Define three independent tasks:

```bash
cat > tasks.json << 'EOF'
{
  "agent_1": {
    "name": "TODO Audit",
    "prompt": "Find all TODO comments in .py files and write them to todo-audit.md",
    "estimated_minutes": 3,
    "output_file": "todo-audit.md",
    "depends_on": null
  },
  "agent_2": {
    "name": "Library Comparison",
    "prompt": "Compare PyYAML, ruamel.yaml, and omegaconf and write yaml-comparison.md",
    "estimated_minutes": 5,
    "output_file": "yaml-comparison.md",
    "depends_on": null
  },
  "agent_3": {
    "name": "Security Audit",
    "prompt": "Scan .py files for hardcoded secrets and write security-audit.md",
    "estimated_minutes": 4,
    "output_file": "security-audit.md",
    "depends_on": null
  }
}
EOF
```

All three tasks have `depends_on: null` — none of them needs output from another. This means they can run in parallel.

Simulate both execution strategies:

```bash
cat > run_simulation.py << 'PYEOF'
#!/usr/bin/env python3
"""Simulate sequential vs parallel agent execution."""
import json
import time

tasks = json.load(open("tasks.json"))

print("=== Agent Execution Simulation ===\n")

# Sequential execution
print("--- Sequential Execution ---")
total_sequential = 0
for agent_id, task in tasks.items():
    est = task["estimated_minutes"]
    print(f"  [{agent_id}] Running: {task['name']}... ({est} min)")
    time.sleep(0.5)  # Simulate waiting
    total_sequential += est
    print(f"  [{agent_id}] Done: {task['output_file']}")

print(f"\n  Total wall time: {total_sequential} minutes")
print()

# Parallel execution
print("--- Parallel Execution ---")
print("  Launching all 3 agents simultaneously...")
time.sleep(0.3)
# In parallel, total time = longest individual task
max_time = max(t["estimated_minutes"] for t in tasks.values())
for agent_id, task in tasks.items():
    est = task["estimated_minutes"]
    print(f"  [{agent_id}] Running: {task['name']}... ({est} min)")

time.sleep(0.5)
print(f"\n  All agents finished. Total wall time: {max_time} minutes")
print(f"\n  Time saved: {total_sequential - max_time} minutes ({100*(total_sequential-max_time)//total_sequential}%)")

print("\n--- Results ---")
for agent_id, task in tasks.items():
    print(f"  {task['output_file']} — ready")
PYEOF
python3 run_simulation.py
```

Expected output shows sequential takes 12 minutes total, parallel takes 5 minutes (the longest individual task), saving 7 minutes or about 58%.

Now create mock output from all three agents and combine them:

```bash
cat > todo-audit.md << 'EOF'
# TODO Audit

## Summary
- Total TODOs found: 7
- Files with TODOs: 3

## By File

### src/auth.py
- Line 45: TODO: Replace hardcoded secret with env var
- Line 102: TODO: Add rate limiting

### src/database.py
- Line 18: TODO: Migrate to async driver
- Line 67: TODO: Add connection pooling

### tests/test_api.py
- Line 23: TODO: Add integration tests
- Line 89: TODO: Mock external service calls
- Line 134: TODO: Test error responses
EOF

cat > yaml-comparison.md << 'EOF'
# YAML Library Comparison

| Library | Install | Load Example | Error Handling | Async |
|---------|---------|-------------|----------------|-------|
| PyYAML | `pip install pyyaml` | `yaml.safe_load(f)` | Raises YAMLError | No |
| ruamel.yaml | `pip install ruamel.yaml` | `YAML().load(f)` | Raises YAMLError | No |
| omegaconf | `pip install omegaconf` | `OmegaConf.load(f)` | Raises ValidationError | No |

## Recommendation

Use **ruamel.yaml** for projects that need to round-trip YAML (read, modify, write back) because it preserves comments and formatting. Use **PyYAML** for simple read-only use cases where it is already a dependency.
EOF

cat > security-audit.md << 'EOF'
# Security Audit

## Critical Findings
| File | Line | Pattern | Risk Level |
|------|------|---------|------------|
| src/auth.py | 15 | api_key= | HIGH |
| src/auth.py | 45 | secret= | HIGH |
| src/config.py | 8 | password= | MEDIUM |

## Summary
- Total findings: 3
- HIGH risk: 2
- MEDIUM risk: 1
- LOW risk: 0

## Recommendations
- Move all secrets to environment variables or a vault
- Use a secrets manager for production credentials
- Add a pre-commit hook to prevent secrets in code
EOF
```

Now merge all three agent outputs into a single report:

```bash
cat > merge_reports.py << 'PYEOF'
#!/usr/bin/env python3
"""Merge multiple agent outputs into a single combined report."""

todo = open("todo-audit.md").read()
comparison = open("yaml-comparison.md").read()
audit = open("security-audit.md").read()

# Extract key metrics
todo_lines = [l for l in todo.split("\n") if "Total TODOs" in l]
audit_findings = [l for l in audit.split("\n") if "Total findings" in l]

print("=== Combined Agent Report ===\n")
print("Three agents ran in parallel and produced the following results:\n")

print("--- TODO Audit ---")
print(todo_lines[0] if todo_lines else "No summary found")
print()

print("--- YAML Comparison ---")
print("Recommendation: ruamel.yaml for round-trip, PyYAML for simple use")
print()

print("--- Security Audit ---")
print(audit_findings[0] if audit_findings else "No summary found")
print("HIGH risk items need immediate attention")
print()

print("All three reports are available as individual files for full details.")
PYEOF
python3 merge_reports.py
```

This is how you coordinate multiple agents: define independent tasks, launch them in parallel, collect their individual output files, and merge the key findings into a summary.

## Check Your Work

Verify that none of the agent tasks actually depend on each other:

```bash
python3 << 'PYEOF'
import json

tasks = json.load(open("tasks.json"))

print("=== Dependency Check ===\n")

# Check for circular or missing dependencies
all_outputs = {t["output_file"] for t in tasks.values()}
all_ids = set(tasks.keys())

for agent_id, task in tasks.items():
    deps = task.get("depends_on")
    if deps is None:
        print(f"  {agent_id} ({task['name']}): INDEPENDENT — can run immediately")
    elif deps in all_ids:
        print(f"  {agent_id} ({task['name']}): depends on {deps}")
    else:
        print(f"  {agent_id} ({task['name']}): WARNING — depends on unknown task '{deps}'")

# Check all outputs are distinct
output_files = [t["output_file"] for t in tasks.values()]
if len(output_files) == len(set(output_files)):
    print(f"\n  All {len(output_files)} output files are distinct — no write conflicts")
else:
    print(f"\n  WARNING: Multiple agents write to the same file!")
PYEOF
```

You should see all three tasks marked as INDEPENDENT with distinct output files.

## Debug It

The classic parallel bug: two agents depending on the same output file. Fix a scenario where tasks are accidentally dependent:

```bash
cat > bad-tasks.json << 'EOF'
{
  "agent_1": {
    "name": "TODO Audit",
    "prompt": "Find all TODOs and write to report.md",
    "depends_on": null,
    "output_file": "report.md"
  },
  "agent_2": {
    "name": "Security Audit",
    "prompt": "Scan for secrets and write to report.md",
    "depends_on": null,
    "output_file": "report.md"
  }
}
EOF
python3 -c "
import json
tasks = json.load(open('bad-tasks.json'))
outputs = [t['output_file'] for t in tasks.values()]
if len(outputs) != len(set(outputs)):
    print('BUG: Two agents write to the same file!')
    print('  Whichever agent finishes last overwrites the other\'s work.')
    print('  Fix: give each agent a unique output filename.')
else:
    print('OK: All output files are unique')
"
```

Fix it by giving each agent a unique filename:

```bash
python3 -c "
import json
tasks = json.load(open('bad-tasks.json'))
tasks['agent_1']['output_file'] = 'todo-report.md'
tasks['agent_2']['output_file'] = 'security-report.md'
json.dump(tasks, open('fixed-tasks.json', 'w'), indent=2)
print('Fixed: each agent now has a unique output file')
"
```

The rule: parallel agents must never write to the same file. Each agent gets its own output. You merge the results afterward.

## What You Learned

Run agents in parallel when their tasks are independent — the total time equals the longest single task, not the sum of all tasks — and give each agent a unique output file to avoid conflicts.

*Next: Lesson 8.5 — Agent Debugging — You'll learn to diagnose agent failures, read their output for clues, and fix problematic prompts.*
