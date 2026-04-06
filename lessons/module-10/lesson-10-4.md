---
module: 10
lesson: 4
title: "Memory Maintenance"
prerequisites: ["module-10/lesson-10-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

Six months ago you wrote a MEMORY.md and three QWEN.md files. Now your MEMORY.md is 300 lines of conflicting advice, your QWEN.md files reference tools you no longer use, and Qwen Code seems to ignore large chunks of both. Memory files rot like any other file — the longer they sit unreviewed, the less accurate they become. Maintenance isn't optional; stale memory actively makes Qwen Code worse.

## Mental Model

Memory maintenance is **pruning a garden, not demolishing a building** — you cut away what's dead, shape what's overgrown, and plant new seeds where there's room. The goal isn't a clean empty file, it's a living document that stays useful by staying current.

## Try It

You'll learn to audit, prune, and consolidate your memory files so they stay lean and accurate.

### Step 1: The audit

First, see what you're working with:

```bash
echo "=== MEMORY.md ===" && wc -l ~/.qwen/MEMORY.md
echo "=== QWEN.md files ===" && find . -name "QWEN.md" -exec echo {} \; -exec wc -l {} \;
```

This shows you the line count of each file. Anything over 60 lines needs attention.

Now read through your MEMORY.md and mark each line with one of three tags:

- **KEEP** — still accurate, still useful, still non-obvious
- **UPDATE** — the topic is right but the details have changed
- **DELETE** — no longer true, no longer relevant, or too obvious to need stating

### Step 2: Pruning

Here's a realistic before-and-after of a MEMORY.md that needs pruning:

```markdown
# BEFORE — 45 lines, needs pruning

# My Preferences

## Languages
- Python 3.8+                           ← UPDATE: now using 3.12
- JavaScript with CommonJS               ← DELETE: switched to ES modules
- TypeScript for new projects            ← KEEP
- I was learning Go but not anymore      ← DELETE: obsolete

## Testing
- pytest for Python                      ← KEEP
- Jest for JavaScript                     ← UPDATE: switched to Vitest
- unittest for simple scripts             ← DELETE: don't use this anymore
- Always write tests                      ← DELETE: too obvious

## Code Style
- 4 space indent for Python             ← DELETE: switched to 2 spaces
- black for formatting                   ← KEEP
- Line length 79                        ← UPDATE: now 88 (black default)
- Use descriptive variable names         ← DELETE: too obvious/vague
- Functions under 30 lines              ← KEEP
- Always add docstrings                  ← KEEP

## Tools
- VS Code                               ← UPDATE: switched to Qwen Code
- npm for packages                       ← KEEP
- docker compose for local services     ← KEEP
- I use a Mac                           ← DELETE: irrelevant to code

## Git
- Conventional commits                   ← KEEP
- Feature branches                       ← KEEP
- Squash merge to main                   ← KEEP
- Never push to main directly            ← KEEP

## Personal
- I like hiking                         ← DELETE: irrelevant
- My timezone is PST                     ← DELETE: rarely matters
- This project started in January 2024   ← DELETE: belongs in project QWEN.md
```

After pruning:

```markdown
# AFTER — 18 lines, all actionable

# My Preferences

## Languages
- Python 3.12+, type hints on every function
- TypeScript for new projects, ES modules (import/export)

## Testing
- pytest for Python, Vitest for JavaScript/TypeScript
- Functions under 30 lines
- Always add docstrings to public functions

## Code Style
- 2 space indent everywhere
- black for Python formatting (line length 88)

## Tools
- npm for packages
- docker compose for local services

## Git
- Conventional commits
- Feature branches, squash merge to main
- Never push to main directly
```

Half the lines, twice the signal. Every remaining line is specific, accurate, and non-obvious.

### Step 3: Consolidating

When multiple QWEN.md files share common patterns, consolidate them. If you have three projects that all use the same testing convention, don't repeat it three times — put it in MEMORY.md once and remove it from each QWEN.md.

Before:

```
# Project A QWEN.md (has "pytest for testing")
# Project B QWEN.md (has "pytest for testing")  
# Project C QWEN.md (has "pytest for testing")
```

After:

```
# MEMORY.md (has "pytest for testing")
# Project A QWEN.md (testing section removed — covered by MEMORY.md)
# Project B QWEN.md (testing section removed — covered by MEMORY.md)
# Project C QWEN.md (testing section removed — covered by MEMORY.md)
```

Exception: if one project differs, keep it in that project's QWEN.md with an explicit note:

```markdown
## Testing
- This project uses unittest, not pytest. Overrides global MEMORY.md preference.
```

### Step 4: The maintenance schedule

Memory maintenance is a **monthly habit**. Set a calendar reminder. The process takes 10 minutes:

1. Open MEMORY.md and QWEN.md files
2. Read every line
3. Delete anything that's no longer true
4. Update anything that's partially true
5. Add new patterns you've noticed Qwen Code getting wrong

### Step 5: When Qwen Code tells you what to add

Pay attention to when you correct Qwen Code. Each correction is a candidate for memory:

You say: "No, I use Vitest, not Jest."
→ That goes in MEMORY.md under Testing.

You say: "This project uses a different naming convention."
→ That goes in the project's QWEN.md.

You say: "Don't add comments to obvious code."
→ That goes in MEMORY.md under "What I Don't Want."

Don't add these in the moment — jot them down somewhere (a scratch file, a note), and add them during your monthly maintenance session. This prevents your memory files from growing with every minor correction.

### Step 6: Version control your MEMORY.md

Treat MEMORY.md like code — commit changes to track your evolution:

```bash
mkdir -p ~/.qwen && cd ~/.qwen
git init
git add MEMORY.md
git commit -m "Initial memory: Python 3.12, pytest, 2-space indent"
```

Then after each maintenance session:

```bash
git add MEMORY.md
git commit -m "Update: switched to Vitest, removed obsolete JS prefs"
```

This gives you a history of how your preferences have changed, and a way to undo bad edits.

## Check Your Work

1. After pruning, check line counts:

```bash
wc -l ~/.qwen/MEMORY.md
find . -name "QWEN.md" -exec wc -l {} \;
```

Target: MEMORY.md under 60 lines, QWEN.md under 80 lines.

2. Verify every line is still accurate:

```bash
cat ~/.qwen/MEMORY.md
```

Read each line and ask: "Is this still true? Would Qwen Code produce better results because of this line?"

3. Test in a real session: ask Qwen Code about topics in your memory files and verify it gives the updated answers, not stale ones.

## Debug It

1. **"I deleted something from MEMORY.md and now Qwen Code does the old thing again."** This is expected — Qwen Code follows what's in the file. If you removed "use Jest" and Qwen Code goes back to suggesting Jest, that means Jest is the model's default. Add the correction back with stronger language: "Always use Vitest, never Jest."

2. **"My QWEN.md files are out of sync with each other."** Three projects, three different testing conventions documented — but they all actually use the same thing. Consolidate to MEMORY.md and remove the duplicated sections from each QWEN.md.

3. **"I did maintenance but the file is still long."** You're probably keeping things that feel important but aren't actionable. Be ruthless. If a line doesn't tell Qwen Code to do (or not do) something specific, cut it. "I care about code quality" tells Qwen Code nothing. "Run black before every commit" tells Qwen Code exactly what to do.

## What You Learned

Memory files decay without maintenance — prune outdated entries, consolidate duplicates, and add corrections monthly to keep your memory files lean and accurate.

*Next: Lesson 10.5 — The /memory Command — You'll learn how to add, remove, and list memory entries during a session for quick context management without editing files manually.*
