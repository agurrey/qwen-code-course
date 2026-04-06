---
module: 10
lesson: 2
title: "Setting Up Your Personal Memory"
prerequisites: ["module-10/lesson-10-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You wrote a MEMORY.md file but it's either too vague ("I like clean code") or too detailed (a 200-line essay about your entire development philosophy). Neither helps Qwen Code do better work. The difference between a useful MEMORY.md and a useless one comes down to specificity, actionability, and knowing what Qwen Code actually needs versus what feels important to you.

## Mental Model

MEMORY.md is a **cheat sheet for a very competent intern** — it should contain the things this intern keeps getting wrong because nobody told them. Don't write everything you know. Write the things that matter for the work Qwen Code does for you.

## Try It

You'll write a real MEMORY.md file, structured for maximum impact with minimum bloat.

### What to include

Good MEMORY.md entries share three traits: they're **specific** (not "write good code" but "use type hints"), **recurring** (applies to multiple tasks, not a one-off), and **non-obvious** (Qwen Code wouldn't guess this from context).

Create or update your MEMORY.md:

```bash
mkdir -p ~/.qwen
```

```markdown
# My Preferences

## Languages & Frameworks
- Python: I use Python 3.11+, prefer async/await, type hints on every function
- JavaScript: TypeScript only, no plain JS files. Use ES modules (import/export), not CommonJS
- Shell: bash, not zsh or fish. Use set -euo pipefail in scripts

## Testing
- Python: pytest with fixtures, never unittest classes
- JavaScript: Vitest, not Jest. Use describe/it blocks
- Always write tests alongside new code, not as a separate step
- Test naming: test_ files go in tests/ directory mirroring src/ structure

## Code Style
- Python: follow PEP 8, use black formatting (line length 88)
- TypeScript: use Prettier, single quotes, no semicolons
- Function names: snake_case for Python, camelCase for TypeScript
- Keep functions under 30 lines. Split if longer.
- Always add docstrings to public functions, one-liner is fine

## Git
- Commit messages: imperative mood ("Add feature" not "Added feature")
- One commit per logical change
- Always run tests before committing
- Branch naming: feature/description, fix/description, chore/description

## What I Don't Want
- Don't generate boilerplate without asking
- Don't add comments explaining obvious code
- Don't use placeholder text like "TODO" or "implement this later"
- Don't suggest dependencies unless I ask
```

### What NOT to include

Bad MEMORY.md entries are **vague**, **obvious**, or **one-time facts**:

```markdown
# BAD — Don't write this

## Preferences
- I like clean code           ← vague, means nothing
- Use best practices          ← obvious, Qwen Code already does this
- I work at Acme Corp         ← irrelevant to coding
- My birthday is March 15     ← never needed
- Python is my favorite       ← obvious from context
- This project started in 2024 ← belongs in QWEN.md, not MEMORY.md
```

If Qwen Code can figure it out from the files, don't put it in MEMORY.md. If it only matters for one project, put it in that project's QWEN.md instead.

### Structure for scannability

Qwen Code reads your whole MEMORY.md at session start. Structure it so the model can quickly find what it needs:

```markdown
# My Preferences

## [Category]
- [Fact]
- [Fact]
```

Use categories that match the decisions Qwen Code actually makes:

| Good categories | Why |
|---|---|
| Languages & Frameworks | Determines what tools and syntax to use |
| Testing | Determines how to verify work |
| Code Style | Determines formatting and naming |
| Git | Determines how to manage changes |
| What I Don't Want | Prevents recurring mistakes |

Avoid categories like "About Me" or "Personal Notes" — they clutter memory with information that doesn't affect code.

### Test your MEMORY.md

Start a new Qwen Code session and run through these checks:

1. Ask about your Python testing preference:
```
how do I write tests in Python?
```
Expected: "pytest with fixtures"

2. Ask about commit messages:
```
what format should my commit messages use?
```
Expected: "imperative mood, one commit per logical change"

3. Ask about TypeScript:
```
should I use single or double quotes in TypeScript?
```
Expected: "single quotes, no semicolons"

4. Ask about something you explicitly don't want:
```
should I add TODO comments for unimplemented parts?
```
Expected: "no, don't use placeholder TODO text"

### Evolve your memory over time

Your first MEMORY.md won't be perfect. That's fine. Add to it when you notice a pattern:

- Qwen Code keeps using a library you don't like → add it to "What I Don't Want"
- You keep correcting the same style issue → add it to "Code Style"
- You switch from Jest to Vitest → update the Testing section

We'll cover memory maintenance in lesson 10.4. For now, just get something written.

## Check Your Work

1. Check file size:

```bash
wc -l ~/.qwen/MEMORY.md
```

Good MEMORY.md files are 20-60 lines. Under 20 lines means you're probably not being specific enough. Over 60 lines means you're including too much non-essential information.

2. Check for vague entries:

```bash
grep -i "clean\|best practice\|good\|nice\|prefer" ~/.qwen/MEMORY.md
```

Every match should be followed by something specific. "I prefer snake_case" is good. "I prefer clean code" is bad.

3. Test in a real session: ask Qwen Code about at least 3 preferences from your MEMORY.md. If it gets them right, your memory is working.

## Debug It

1. **"Qwen Code reads my MEMORY.md but doesn't follow it."** The instructions may be phrased as preferences rather than rules. Compare:

```markdown
# Weak: I kinda like type hints
# Strong: Always add type hints to function signatures
```

The second version is an instruction, not a preference. Qwen Code responds better to direct instructions.

2. **"My MEMORY.md is contradictory."** You wrote "use pytest" in one section and "use unittest for simple tests" in another. Qwen Code will be confused. Consolidate to one clear rule per topic.

3. **"Qwen Code follows MEMORY.md even when I don't want it to for this project."** Override it in the project's QWEN.md. If MEMORY.md says "use pytest" but this project uses unittest, put in QWEN.md:

```markdown
## Testing
- This project uses unittest, not pytest. Overrides global MEMORY.md preference.
```

The QWEN.md takes precedence for this project.

## What You Learned

A good MEMORY.md is specific, actionable, and non-obvious — a cheat sheet that prevents the recurring mistakes and preferences you'd otherwise repeat every session.

*Next: Lesson 10.3 — Project-Level Memory — You'll learn how to write QWEN.md files that give Qwen Code project-specific instructions, conventions, and structural knowledge for each project.*
