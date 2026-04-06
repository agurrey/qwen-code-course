---
description: Start the Qwen Code Course. Runs initial assessment and begins Module 0.
---

Start the Qwen Code Course for the user. Follow this exact flow:

## Step 1: Check if returning user

Read `~/.qwen/course-progress.json`. If it exists and `started_at` is not null, the user has already started. Say:

```
You've already started the course! You've completed X lessons. Want to continue where you left off? (/course next) Or start over? (/course reset)
```

And stop. Don't proceed further.

## Step 2: Initial Assessment (new user)

Ask the user these 3 questions ONE AT A TIME:

**Q1:** "Have you used a terminal or command line before? (bash, zsh, PowerShell — any shell)"
- Options: "Never touched one", "A few times", "Comfortable with it"

**Q2:** "Have you used an AI coding assistant before? (Cursor, Claude Code, GitHub Copilot, etc.)"
- Options: "No", "Tried one briefly", "Use one regularly"

**Q3:** "What's the first thing you'd like to automate or build with Qwen Code? (even a vague idea is fine)"
- Free text — let them describe it

Record answers in the progress file under `initial_assessment`.

Based on Q1-Q2:
- If "Never touched one" + "No" → no modules skipped
- If "Comfortable" + "Use one regularly" → offer to skip Modules 0-1 (but don't force it)
- Otherwise → no skips

Use Q3 to personalize examples throughout the course (reference their goal when relevant).

## Step 3: Create Sandbox

Run:
```bash
mkdir -p ~/qwen-sandbox/practice ~/qwen-sandbox/exercises ~/qwen-sandbox/experiments
```

Create `~/qwen-sandbox/README.md`:
```
This is your Qwen Code sandbox — a safe space to experiment.
Files here can be created, modified, and deleted freely.
Nothing outside this directory will be touched by course exercises.
```

## Step 4: Start Module 0

1. Set `started_at` and `last_active` in progress.json to now
2. Load and present Lesson 0.1 from `~/qwen-tryouts/qwen-code-course/lessons/module-0/lesson-0-1.md`
3. Guide the user through the lesson:
   - Show them the problem statement and mental model
   - Walk them through the "Try It" exercise
   - Check their work
   - Run the "Debug It" exercise
4. Mark lesson 0-1 as in_progress in the progress file
5. Tell them: "That's Lesson 0.1. Type /course next to continue when you're ready."

## Rules

- Do NOT rush through all of Module 0 in one go. Present Lesson 0.1, let the user complete it, then stop.
- Always update the progress file after each action.
- Be encouraging but not fake — real achievement deserves recognition, struggling deserves patience.
