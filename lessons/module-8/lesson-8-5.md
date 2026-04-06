---
module: 8
lesson: 5
title: "Agent Debugging"
prerequisites: ["module-8/lesson-8-4"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You launched an agent and it came back with wrong output, no output, or output that's clearly incomplete. Unlike your normal Qwen Code session where you can see each step and intervene, an agent works in the background — you only see the final result. When something goes wrong, you need a systematic way to figure out what happened and fix it.

## Mental Model

Debugging an agent means debugging its prompt. The agent's behavior is entirely determined by the instructions you gave it. If the output is wrong, the prompt was either ambiguous, missing a constraint, or specified the wrong output format. Read the output carefully, identify the gap between what you got and what you wanted, then close that gap by rewriting the relevant section of the prompt.

## Try It

You'll create three broken agent outputs, diagnose what went wrong in each case, and fix the prompts. This builds the muscle you need for every real agent failure you'll encounter.

Set up your workspace:

```bash
mkdir -p ~/qwen-course-work/module-8/debugging
cd ~/qwen-course-work/module-8/debugging
```

**Failure Mode 1: Agent ignored scope constraints.**

The prompt said "only audit .py files" but the agent also checked .md and .json files:

```bash
cat > broken-output-1.txt << 'EOF'
# TODO Audit

## Summary
- Total TODOs found: 12
- Files with TODOs: 7

## By File

### README.md
- Line 5: TODO: Add installation instructions
- Line 20: TODO: Update screenshots

### src/auth.py
- Line 45: TODO: Replace hardcoded secret

### package.json
- Line 3: "description": "TODO: add description"

### tests/test_auth.py
- Line 10: TODO: Add more test cases
EOF
```

The problem: the agent searched too broadly. The prompt's scope was unclear. Diagnose it:

```bash
python3 << 'PYEOF'
output = open("broken-output-1.txt").read()

print("=== Diagnosing Failure Mode 1: Scope Creep ===\n")

# Check which file types were included
import re
files = re.findall(r'### (.+)', output)
print(f"Files found in output: {files}")

non_python = [f for f in files if not f.endswith('.py')]
if non_python:
    print(f"\nBUG: Agent included non-Python files: {non_python}")
    print("\nRoot cause: Prompt's Scope section did not explicitly exclude non-.py files.")
    print("  The agent saw 'find all TODO comments' and included every file type.")
    print()
    print("Fix: Add to Scope section:")
    print('  - Search ONLY .py files')
    print('  - Do NOT search .md, .json, .yaml, .txt, or any non-Python files')
else:
    print("All files are .py — no scope creep detected")
PYEOF
```

Write the fixed prompt:

```bash
cat > fixed-prompt-1.md << 'EOF'
## Goal
Find every TODO comment across all Python files in the project and compile them into a single organized file.

## Scope
- Search ONLY .py files recursively from the project root
- Do NOT search .md, .json, .yaml, .txt, .js, .ts, or any non-Python files
- Do NOT modify any source files — this is read-only

## Output Format
Create a file called `todo-audit.md` with a table showing file path, line number, and TODO text for each TODO found, grouped by file.

## Constraints
- Include the exact line number for each TODO
- Include the full TODO text
- If a file has no TODOs, do not list it
- Sort files alphabetically by path
EOF
```

**Failure Mode 2: Agent produced wrong format.**

The prompt asked for a markdown table but the agent wrote a paragraph:

```bash
cat > broken-output-2.txt << 'EOF'
I looked at the three libraries. PyYAML is the most popular one and you install it with pip install pyyaml. It does not support async. ruamel.yaml is a fork that preserves formatting. omegaconf is from Facebook and uses a different config system. I think ruamel.yaml is probably the best one to use because it has good features.
EOF
```

Diagnose it:

```bash
python3 << 'PYEOF'
output = open("broken-output-2.txt").read()

print("=== Diagnosing Failure Mode 2: Wrong Output Format ===\n")

# Check for markdown table syntax
has_table = "|" in output
has_header = "## " in output
has_code_block = "```" in output
has_single_paragraph = output.count("\n") < 3

print(f"Has markdown table: {has_table}")
print(f"Has section headers: {has_header}")
print(f"Has code blocks: {has_code_block}")
print(f"Is single paragraph: {has_single_paragraph}")
print()

if has_single_paragraph and not has_table:
    print("BUG: Agent wrote a narrative paragraph instead of a structured comparison table.")
    print()
    print("Root cause: Output Format section said 'write a comparison' without specifying")
    print("  the exact structure. The agent chose the easiest format — a paragraph.")
    print()
    print("Fix: In Output Format, show the exact template:")
    print("  'Create yaml-comparison.md with a markdown table with these columns:')
    print("  | Library | Install | Load Example | Error Handling | Async Support |")
    print("  'Include a code block with a 3-line load example for each library.'")
    print("  'End with a ## Recommendation section that picks one library.'")
PYEOF
```

Write the fixed prompt:

```bash
cat > fixed-prompt-2.md << 'EOF'
## Goal
Compare PyYAML, ruamel.yaml, and omegaconf for YAML parsing and write a recommendation report.

## Scope
- Research only: installation, basic YAML loading, and error handling
- Do NOT benchmark performance or test advanced features

## Output Format
Create `yaml-comparison.md` with exactly this structure:

1. A markdown table with columns: | Library | Install Command | Load Example (3 lines) | Error Handling | Async Support |
2. A `## Recommendation` section that picks one library for simple use cases and explains why in 2 sentences maximum.

Total file must be under 40 lines.

## Constraints
- All code examples must be valid, runnable Python
- Include version numbers
- If a feature is not supported, write "Not supported"
- Do not include any prose outside the Recommendation section
EOF
```

**Failure Mode 3: Agent output is truncated.**

The agent started listing TODOs but stopped mid-file:

```bash
cat > broken-output-3.txt << 'EOF'
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
EOF
```

Diagnose it:

```bash
python3 << 'PYEOF'
output = open("broken-output-3.txt").read()

print("=== Diagnosing Failure Mode 3: Truncated Output ===\n")

# Check if the output looks cut off
lines = output.strip().split("\n")
last_line = lines[-1] if lines else ""

# Summary says 7 TODOs, but count what's actually listed
todo_lines_count = output.count("- Line")
summary_total = 0
for line in lines:
    if "Total TODOs found:" in line:
        import re
        match = re.search(r'(\d+)', line)
        if match:
            summary_total = int(match.group(1))

print(f"Summary claims: {summary_total} TODOs")
print(f"Actually listed: {todo_lines_count} TODOs")
print(f"Last line: '{last_line}'")
print()

if todo_lines_count < summary_total:
    missing = summary_total - todo_lines_count
    print(f"BUG: Output is missing {missing} TODO entries.")
    print()
    print("Possible causes:")
    print("  1. Agent hit a context length limit and was cut off")
    print("  2. Agent encountered an error partway through and stopped")
    print("  3. The agent did not search all files listed in scope")
    print()
    print("Fixes:")
    print("  - In Constraints, add: 'If you find more than 20 TODOs, still list them all.'")
    print("  - In Output Format, add: 'The file must be complete. Do not truncate.'")
    print("  - If the codebase is very large, split the task: one agent per directory")
PYEOF
```

Write the fixed prompt:

```bash
cat > fixed-prompt-3.md << 'EOF'
## Goal
Find every TODO comment across all Python files and write a complete audit report.

## Scope
- Search all .py files recursively from the project root
- Do NOT search non-Python files
- Do NOT modify any source files

## Output Format
Create `todo-audit.md` listing every TODO found, grouped by file, with line numbers and full TODO text.

## Constraints
- You MUST list every TODO found — do not stop early or summarize mid-report
- If the list is long, still include every entry
- Sort files alphabetically
- End the file with a summary line: "Total: X TODOs across Y files"
EOF
```

## Check Your Work

Verify all three fixed prompts pass the completeness check from Lesson 8.3:

```bash
python3 << 'PYEOF'
required_sections = ["Goal", "Scope", "Output Format", "Constraints"]
files = ["fixed-prompt-1.md", "fixed-prompt-2.md", "fixed-prompt-3.md"]

print("=== Fixed Prompt Verification ===\n")

all_pass = True
for filename in files:
    try:
        content = open(filename).read()
    except FileNotFoundError:
        print(f"  MISSING: {filename}")
        all_pass = False
        continue

    missing = [s for s in required_sections if f"## {s}" not in content]
    if missing:
        print(f"  INCOMPLETE: {filename} — missing: {', '.join(missing)}")
        all_pass = False
    else:
        print(f"  PASS: {filename} — all 4 sections present")

print()
if all_pass:
    print("All fixed prompts are complete and well-structured.")
else:
    print("Some fixed prompts still need work.")
PYEOF
```

All three should pass.

## Debug It

Here's a systematic debugging workflow you can use for any agent failure:

```bash
cat > debug-workflow.sh << 'SHEOF'
#!/bin/bash
echo "=== Agent Debugging Workflow ==="
echo ""
echo "Step 1: Read the agent's output file."
echo "  What did it actually produce?"
echo ""
echo "Step 2: Compare against the prompt's Output Format section."
echo "  Does the output match the requested structure?"
echo "  If no -> the Output Format section was unclear. Rewrite it."
echo ""
echo "Step 3: Check the Scope section."
echo "  Did the agent touch files it shouldn't have?"
echo "  Did it miss files it should have searched?"
echo "  If yes -> add explicit include/exclude rules."
echo ""
echo "Step 4: Check the Constraints section."
echo "  Did the agent violate any rules you specified?"
echo "  If yes -> the constraint may be ambiguous or buried in prose."
echo "  Make it a bullet point: 'Do NOT do X'."
echo ""
echo "Step 5: Check the Goal section."
echo "  Does the output actually accomplish the stated goal?"
echo "  If no -> the Goal may conflict with the Output Format."
echo "  Make sure they align."
echo ""
echo "Step 6: Rewrite the prompt with all fixes."
echo "  Re-run the agent with the improved prompt."
echo "  Verify the new output against all four sections."
echo ""
echo "Golden rule: When an agent fails, blame the prompt — not the agent."
SHEOF
chmod +x debug-workflow.sh
bash debug-workflow.sh
```

This workflow works because agents are deterministic in their dependence on prompts. The same prompt produces the same behavior. If you fix the prompt, the agent's output changes predictably.

## What You Learned

Debugging an agent means comparing its output against each section of the prompt, identifying which section was ambiguous or incomplete, and rewriting that section to close the gap.

**Module 8 Complete!** You've learned what agents are, when to use them, how to write prompts that work, how to run multiple agents in parallel, and how to debug them when they go wrong. *Next: Module 9 — Advanced Workflows — You'll combine MCP servers, agents, and skills into powerful multi-step automation pipelines.*
