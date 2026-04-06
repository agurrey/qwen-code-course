---
module: 8
lesson: 3
title: "Writing Agent Prompts"
prerequisites: ["module-8/lesson-8-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You've decided to use an agent for a task, but the agent came back with useless output. The problem isn't the agent — it's your prompt. Unlike your normal conversation with Qwen Code where you can clarify and correct, an agent works alone. If the prompt is vague, ambiguous, or missing constraints, the agent will guess wrong and you'll get back the wrong result. You need a reliable prompt format that gives agents everything they need to succeed without asking follow-up questions.

## Mental Model

An agent prompt has four parts: the goal (what to achieve), the scope (what's in bounds and what's not), the output format (what the result should look like), and the constraints (rules the agent must follow). Write all four explicitly and the agent can work completely independently. Skip any one and the agent fills in the blanks — possibly wrong.

## Try It

You'll write prompts for three different agent tasks using the four-part format, then test whether each prompt is complete enough for an agent to execute without questions.

Set up your workspace:

```bash
mkdir -p ~/qwen-course-work/module-8/prompts
cd ~/qwen-course-work/module-8/prompts
```

Create the prompt template:

```bash
cat > prompt-template.md << 'EOF'
# Agent Prompt Template

## Goal
[One sentence: what should the agent accomplish. Be specific about the end state.]

## Scope
[What the agent should and should not touch. List specific files, directories, or systems. Include explicit "do not" rules.]

## Output Format
[Exactly what the agent should produce. A file? A summary? A list? Include the filename and structure.]

## Constraints
[Rules the agent must follow. Style requirements, things to avoid, performance requirements, etc.]
EOF
```

Now write three real agent prompts using this template.

**Prompt 1: Find all TODOs in a codebase**

```bash
cat > prompt-todos.md << 'EOF'
## Goal
Find every TODO comment across all Python files in the project and compile them into a single organized file.

## Scope
- Search all .py files recursively from the project root
- Include files in subdirectories like src/, tests/, and scripts/
- Do NOT search .md, .js, .json, or any non-Python files
- Do NOT modify any source files — this is read-only

## Output Format
Create a file called `todo-audit.md` with this structure:
```
# TODO Audit

## Summary
- Total TODOs found: X
- Files with TODOs: Y

## By File

### path/to/file.py
- Line 12: TODO description text
- Line 45: TODO description text

### path/to/other.py
- Line 3: TODO description text
```

## Constraints
- Include the exact line number for each TODO
- Include the full TODO text (not just "TODO")
- Group TODOs by file, ordered by file path alphabetically
- If a file has no TODOs, do not list it
EOF
```

**Prompt 2: Compare three libraries**

```bash
cat > prompt-comparison.md << 'EOF'
## Goal
Compare PyYAML, ruamel.yaml, and omegaconf for YAML parsing and write a recommendation report.

## Scope
- Research only: installation, basic YAML loading, and error handling
- Do NOT benchmark performance or test advanced features
- Use only publicly available documentation — do not install or run anything

## Output Format
Create `yaml-comparison.md` with:
- A comparison table with columns: Library, Install Command, Load Example (3 lines), Error Handling, Async Support
- A "Recommendation" section that picks the best library for simple use cases
- Keep the total report under 60 lines

## Constraints
- All code examples must use valid, runnable Python code
- Include version numbers for each library
- If a feature is not supported, write "Not supported" — do not guess
- Do not express personal opinions — stick to documented facts
EOF
```

**Prompt 3: Security audit**

```bash
cat > prompt-audit.md << 'EOF'
## Goal
Scan all Python files for hardcoded secrets, API keys, passwords, and tokens, and produce a security report.

## Scope
- Search all .py files in the project
- Check for patterns like: api_key=, password=, secret=, token=, AUTH_KEY, PRIVATE_KEY
- Do NOT search configuration files (.env, .yaml, .json) — only .py source files
- Do NOT modify any files — read-only audit only

## Output Format
Create `security-audit.md` with:
```
# Security Audit

## Critical Findings
| File | Line | Pattern | Risk Level |
|------|------|---------|------------|
| src/config.py | 15 | api_key="sk-..." | HIGH |

## Summary
- Total findings: X
- HIGH risk: X
- MEDIUM risk: X
- LOW risk: X

## Recommendations
- [Brief remediation steps]
```

## Constraints
- Mark any hardcoded string that looks like a real key (starts with sk-, pk-, ghp-) as HIGH risk
- Mark generic placeholder values (YOUR_KEY_HERE, xxxxx) as LOW risk
- Do not include the actual secret values in the report — replace with [REDACTED]
- Sort findings by risk level (HIGH first, then MEDIUM, then LOW)
EOF
```

Now verify each prompt is complete using a checklist:

```bash
cat > check_prompts.py << 'PYEOF'
#!/usr/bin/env python3
"""Check that agent prompts have all four required sections."""
import sys

required_sections = ["Goal", "Scope", "Output Format", "Constraints"]

files = ["prompt-todos.md", "prompt-comparison.md", "prompt-audit.md"]

print("=== Agent Prompt Completeness Check ===\n")

all_pass = True
for filename in files:
    try:
        content = open(filename).read()
    except FileNotFoundError:
        print(f"  MISSING: {filename}")
        all_pass = False
        continue

    missing = []
    for section in required_sections:
        if f"## {section}" not in content and f"## {section.lower()}" not in content.lower():
            missing.append(section)

    if missing:
        print(f"  INCOMPLETE: {filename}")
        print(f"    Missing sections: {', '.join(missing)}")
        all_pass = False
    else:
        # Count words in each section
        print(f"  COMPLETE: {filename}")
        parts = content.split("## ")
        for part in parts:
            header = part.split("\n")[0].strip()
            if header in required_sections:
                body = "\n".join(part.split("\n")[1:]).strip()
                word_count = len(body.split())
                print(f"    {header}: {word_count} words")

    print()

if all_pass:
    print("All prompts are complete!")
else:
    print("Some prompts are incomplete — fix missing sections.")
PYEOF
python3 check_prompts.py
```

All three prompts should show COMPLETE with reasonable word counts in each section (10+ words each).

## Check Your Work

Test prompt quality by simulating whether an agent could execute each one without asking questions:

```bash
python3 << 'PYEOF'
import re

def check_prompt_quality(filename):
    content = open(filename).read()
    issues = []

    # Check for vague language
    vague_patterns = ["etc.", "and so on", "whatever", "some", "stuff", "things"]
    for pattern in vague_patterns:
        if pattern.lower() in content.lower():
            issues.append(f"Vague language: '{pattern}'")

    # Check Goal has a concrete verb
    goal_match = re.search(r'## Goal\n(.*?)(?=\n## )', content, re.DOTALL)
    if goal_match:
        goal = goal_match.group(1)
        action_verbs = ["find", "create", "compare", "scan", "build", "write", "generate", "audit", "list"]
        if not any(verb in goal.lower() for verb in action_verbs):
            issues.append("Goal lacks a clear action verb")
    else:
        issues.append("Could not find Goal section")

    # Check Output Format specifies a filename
    output_match = re.search(r'## Output Format\n(.*?)(?=\n## )', content, re.DOTALL)
    if output_match:
        output = output_match.group(1)
        if ".md" not in output and ".txt" not in output and ".json" not in output:
            issues.append("Output Format does not specify a filename")
    else:
        issues.append("Could not find Output Format section")

    # Check Constraints has at least one rule
    constraints_match = re.search(r'## Constraints\n(.+)', content, re.DOTALL)
    if constraints_match:
        constraints = constraints_match.group(1)
        if len(constraints.split()) < 10:
            issues.append("Constraints section is too short (under 10 words)")
    else:
        issues.append("Could not find Constraints section")

    return issues

files = ["prompt-todos.md", "prompt-comparison.md", "prompt-audit.md"]
print("=== Agent Prompt Quality Check ===\n")

for filename in files:
    issues = check_prompt_quality(filename)
    if issues:
        print(f"  ISSUES in {filename}:")
        for issue in issues:
            print(f"    - {issue}")
    else:
        print(f"  PASS: {filename} — no quality issues found")
    print()
PYEOF
```

All three should pass with no issues.

## Debug It

Here's a bad agent prompt and what goes wrong:

```bash
cat > bad-prompt.md << 'EOF'
## Goal
Fix the code quality issues.

## Scope
The whole project.

## Output Format
Better code.

## Constraints
Make it good.
EOF
python3 -c "
content = open('bad-prompt.md').read()
print('Bad prompt analysis:')
print('  Goal: \"Fix the code quality issues\" — Which issues? Where? What does \"fixed\" look like?')
print('  Scope: \"The whole project\" — Does this include tests? Config? Docs?')
print('  Output Format: \"Better code\" — No filename, no structure, no way to verify.')
print('  Constraints: \"Make it good\" — Subjective. The agent will guess.')
print()
print('This agent would either refuse to act or make arbitrary changes.')
print('Compare with the three good prompts above — they leave no ambiguity.')
"
```

The fix: always use the four-part template. Never skip a section. If you don't know what to write for a section, that means you haven't thought through the task enough to delegate it.

## What You Learned

An agent prompt needs four sections — Goal, Scope, Output Format, and Constraints — each specific enough that the agent can work without asking any follow-up questions.

*Next: Lesson 8.4 — Multiple Agents in Parallel — You'll launch two or more agents simultaneously to cut wall-clock time on big tasks.*
