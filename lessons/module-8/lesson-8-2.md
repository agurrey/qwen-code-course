---
module: 8
lesson: 2
title: "When to Use Agents"
prerequisites: ["module-8/lesson-8-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You know what agents are, but you're not sure when to use one versus just asking Qwen Code directly in your current session. Some tasks are faster to do yourself. Others would take forever if you wait for each step to complete before moving to the next. You need a clear decision framework so you don't waste time on tasks that don't benefit from agents, and don't miss opportunities where agents save you real time.

## Mental Model

Use an agent when the task is self-contained, takes more than a few steps, and produces a concrete output you can verify. Don't use an agent for quick questions, exploratory work where you need to guide each step, or tasks that build on work you're doing right now in your session. If you'd say "go work on this and come back when it's done" to a human colleague, an agent is the right call.

## Try It

You'll build a decision engine that classifies tasks as "agent-worthy" or "do it yourself" based on concrete criteria. Then you'll test it against real scenarios.

Create the classifier:

```bash
mkdir -p ~/qwen-course-work/module-8/decision
cd ~/qwen-course-work/module-8/decision
```

```bash
cat > task_classifier.py << 'PYEOF'
#!/usr/bin/env python3
"""
Classify tasks as AGENT or DIRECT based on decision criteria.

A task should use an AGENT when:
  1. It's self-contained (doesn't need ongoing input from you)
  2. It has 3+ distinct steps
  3. It produces a concrete output (file, report, summary)
  4. It would take more than 2 minutes of active work
  5. It doesn't depend on work happening in your current session

Otherwise, do it DIRECTLY in your current session.
"""
import json

def classify_task(task_description):
    """Return AGENT or DIRECT with reasoning."""
    desc = task_description.lower()

    # Scoring
    score = 0
    reasons = []

    # Criterion 1: Self-contained
    self_contained_phrases = [
        "research", "compare", "analyze", "find all", "search for",
        "audit", "scan", "review all", "generate", "create a report",
        "write documentation", "summarize all", "check every"
    ]
    if any(phrase in desc for phrase in self_contained_phrases):
        score += 1
        reasons.append("Task is self-contained")

    # Criterion 2: Multiple steps implied
    multi_step_phrases = [
        "each", "all", "every", "compare", "across", "multiple",
        "and then", "followed by", "for each", "one by one"
    ]
    if any(phrase in desc for phrase in multi_step_phrases):
        score += 1
        reasons.append("Task implies multiple steps")

    # Criterion 3: Concrete output specified
    output_phrases = [
        "write to", "save as", "create a", "generate a", "produce",
        "output to", "report on", "list all", "file called"
    ]
    if any(phrase in desc for phrase in output_phrases):
        score += 1
        reasons.append("Task specifies a concrete output")

    # Criterion 4: Large scope
    scope_phrases = [
        "entire", "all files", "whole codebase", "every", "full",
        "complete", "comprehensive", "exhaustive", "all directories"
    ]
    if any(phrase in desc for phrase in scope_phrases):
        score += 1
        reasons.append("Task has large scope")

    # Criterion 5: No immediate dependency
    dependency_phrases = [
        "the file I just", "what we were", "the change I'm making",
        "after I finish", "the function above"
    ]
    if any(phrase in desc for phrase in dependency_phrases):
        score -= 2
        reasons.append("Task depends on current session context")

    if score >= 2:
        verdict = "AGENT"
    else:
        verdict = "DIRECT"

    return verdict, reasons, score


def main():
    tasks = [
        # Agent-worthy tasks
        ("Research and compare pytest vs unittest for our test suite", True),
        ("Find all TODO comments across the entire codebase and write them to todos.md", True),
        ("Audit all Python files for hardcoded secrets and API keys", True),
        ("Generate API documentation for every endpoint in app.py", True),
        ("Search for all files larger than 1000 lines and list them", True),

        # Direct tasks
        ("Explain what this function does", False),
        ("Add a print statement to the function I just edited", False),
        ("What does the error on line 42 mean?", False),
        ("Help me refactor the class we're working on", False),
    ]

    print("=== Task Classification ===\n")

    correct = 0
    total = len(tasks)

    for task, expected_agent in tasks:
        verdict, reasons, score = classify_task(task)
        expected = "AGENT" if expected_agent else "DIRECT"
        match = verdict == expected
        if match:
            correct += 1

        status = "OK" if match else "MISMATCH"
        print(f"  [{status}] {task}")
        print(f"    Classified as: {verdict} (score: {score})")
        if reasons:
            print(f"    Reasons: {'; '.join(reasons)}")
        print()

    print(f"Results: {correct}/{total} correct ({100*correct//total}%)")

if __name__ == "__main__":
    main()
PYEOF
python3 task_classifier.py
```

You should see 9/10 or 10/10 correct classifications. The classifier uses simple keyword matching — the real Qwen Code agent system uses the LLM's understanding of the task, which is more nuanced.

Now apply the framework to your own task. Think of something you want to do today and classify it:

```bash
cat > my-task.json << 'EOF'
{
  "task": "YOUR TASK HERE",
  "classify_it": "Fill this in and run the classifier"
}
EOF
```

Replace the placeholder with a real task and run it through the classifier:

```bash
python3 -c "
from task_classifier import classify_task
task = 'Find all unused imports across the project and remove them'
verdict, reasons, score = classify_task(task)
print(f'Task: {task}')
print(f'Verdict: {verdict} (score: {score})')
for r in reasons:
    print(f'  - {r}')
"
```

## Check Your Work

Verify the classifier handles edge cases correctly. Test with tasks that sit right on the boundary:

```bash
python3 -c "
from task_classifier import classify_task

edge_cases = [
    # Borderline — could go either way
    ('List all functions in this file', 'DIRECT'),
    ('Find all Python files and count their lines', 'AGENT'),
    ('Summarize the last commit', 'DIRECT'),
    ('Review all commits from the last month and write a changelog', 'AGENT'),
]

print('Edge Case Tests:')
for task, expected in edge_cases:
    verdict, reasons, score = classify_task(task)
    match = verdict == expected
    status = 'OK' if match else 'MISMATCH'
    print(f'  [{status}] {task}')
    print(f'    -> {verdict} (expected: {expected})')
    print()
"
```

Some edge cases might be classified differently than expected — that's fine. The point is to have a framework, not a perfect classifier. When in doubt, the rule of thumb holds: if you'd delegate it to a person, use an agent.

## Debug It

The most common mistake: using an agent for a task that requires back-and-forth. Agents work best with a single prompt and a single output. If the task needs clarification mid-way, the agent can't ask you questions.

Simulate a bad agent task:

```bash
cat > interactive-task.json << 'EOF'
{
  "task": "Fix the bugs in my code",
  "problem": "This requires the agent to first find the bugs, then decide which approach to take, then possibly ask which coding style you prefer, then implement the fix, then run tests, then adjust based on test output.",
  "why_its_bad": "This is not self-contained. It requires judgment calls, iteration, and potential course correction. An agent would either give up or produce something you don't want."
}
EOF
python3 -c "
import json
task = json.load(open('interactive-task.json'))
print(f'Task: {task[\"task\"]}')
print(f'Why it is bad for agents: {task[\"why_its_bad\"]}')
print()
print('Better approach: Do this yourself in the main session.')
print('Or break it into self-contained subtasks:')
print('  1. Agent: Find all functions with more than 50 lines')
print('  2. You: Review the list and pick which to refactor')
print('  3. Agent: Refactor function X to be under 30 lines')
print('  4. You: Run tests and verify')
"
```

The fix for complex tasks: decompose them. Turn one interactive task into multiple self-contained agent tasks with you as the coordinator.

## What You Learned

Use agents for self-contained, multi-step tasks with concrete outputs — do work directly when you need to guide each step or the task depends on your current session context.

*Next: Lesson 8.3 — Writing Agent Prompts — You'll learn the exact format for giving agents instructions that produce reliable results.*
