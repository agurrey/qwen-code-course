# Contributing to Qwen Code Course

This course is community-maintained. Anyone can contribute lessons, fixes, or improvements.

## Quick Start for Contributors

1. Fork this repository
2. Clone your fork locally
3. Create a branch: `git checkout -b lesson/your-lesson-name`
4. Make your changes
5. Test your lesson (see below)
6. Open a Pull Request

## Adding a New Lesson

### Step 1: Copy the template

```bash
cp module-templates/lesson-template.md lessons/module-X/lesson-X-Y.md
```

### Step 2: Fill in the template

Every lesson follows this format:

```markdown
---
module: X
lesson: Y
title: "Lesson Title"
prerequisites: ["X-Z"]  # lesson IDs that must be completed first, or []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson X.Y: Title

## The Problem
[2-3 sentences: a real scenario that motivates this lesson]

## Mental Model
[1-2 sentences: how to think about this concept]

## Try It
[Step-by-step exercise. The user must DO something and see a result.]

## Check Your Work
[How the model verifies the exercise was completed correctly]

## Debug It
[Something intentionally breaks. The user must fix it.]

## What You Learned
[1 sentence summary]
```

### Step 3: Write good lessons

**DO:**
- Start with a real problem, not a command reference
- Explain the "why" before the "how"
- Keep exercises short — user should see results in under 2 minutes
- Include a debug exercise in every lesson
- Use concrete examples, not abstract concepts
- Write at a beginner level — no assumed knowledge

**DON'T:**
- Write "read this and understand" lessons — every lesson needs a DO component
- Assume terminal experience — explain every symbol the first time
- Copy content from other courses or documentation
- Make lessons longer than 5 minutes of reading + 5 minutes of doing

### Step 4: Test your lesson

```bash
# The lesson should work when loaded as a custom command
# Test it by running the exercises yourself in Qwen Code
./scripts/test-lesson.sh lessons/module-X/lesson-X-Y.md
```

### Step 5: Open a PR

Include:
- [ ] Lesson file follows template
- [ ] Tested in Qwen Code
- [ ] No assumed knowledge beyond stated prerequisites
- [ ] Includes debug exercise
- [ ] Version-pinned for current Qwen Code version

## Lesson Difficulty Guidelines

| Module | Difficulty | What to assume |
|--------|-----------|----------------|
| 0 | Absolute zero | Nothing. Explain the terminal. |
| 1 | Beginner | User has seen a terminal briefly |
| 2 | Beginner | User can open terminal and type |
| 3-4 | Early intermediate | User can run basic commands |
| 5-7 | Intermediate | User understands Qwen's tool model |
| 8-10 | Advanced | User builds their own commands/skills |
| 11 | Real-world | User applies everything |

## Updating a Lesson for a New Qwen Version

1. Find the lesson you want to update
2. Create a new version of it (don't edit the old one — keep history)
3. Update the `version-pinned` field
4. Add a `## Changelog` section at the bottom:
   ```markdown
   ## Changelog
   - 2026-04-10: Updated for Qwen Code v0.2.0 — changed /approval-mode syntax
   ```
5. Open a PR with the update

## Repository Structure

```
qwen-code-course/
├── commands/           # Custom commands (→ ~/.qwen/commands/)
├── skills/             # Auto-invoked skills (→ ~/.qwen/skills/)
├── lessons/            # Lesson content, organized by module
├── exercises/          # Pre-built exercise files
├── module-templates/   # Templates for lesson authors
├── scripts/            # Install, test, and maintenance scripts
└── website/            # Static companion site content
```

## Style Guide

- **Tone:** Direct, practical, no corporate speak. Like a patient friend explaining something.
- **Voice:** Second person ("you"). Not "the user" or "one should."
- **Code blocks:** Always show expected output so users can compare.
- **Errors:** When something breaks, show the exact error message and explain what it means.
- **Length:** If a lesson takes more than 10 minutes to complete, split it.
