---
description: Show current course progress, Qwen Code environment info, and what's next.
---

Show the user their current progress in the Qwen Code Course, combined with Qwen Code environment status.

## Step 1: Read progress file + environment

Read `~/.qwen/course-progress.json`. If it doesn't exist, say:

```
No progress found. Start the course with: /course start
```

Also read `~/.qwen/settings.json` for environment info.

## Step 2: Display combined status

```
=== Qwen Code Course — Status ===

── Environment ──
Model:           [from settings.json model.name]
Approval Mode:   [from settings.json tools.approvalMode]
Auth:            [from settings.json security.auth.selectedType]
QWEN.md:         [exists/missing]

── Progress ──
Overall:         X/60 lessons completed (Y%)
Course Version:  [from progress file]
Last Active:     [date, or "never"]

── Current Position ──
Module:          [Module N: Title]
Module Progress: A/B lessons completed
Next Lesson:     X.Y [title]

Completed Lessons:
  ✅ 0.1 [title]
  ✅ 0.2 [title]
  ...
```

## Step 3: Show module overview

For each module, show status:
```
Module 0: Your First 5 Minutes     ✅ Complete
Module 1: What Is Qwen Code?       🚧 In Progress (2/4 lessons)
Module 2: Your First Commands      📋 Not Started
...
```

## Step 4: If stagnant

If `stagnant_since` is set or `last_active` is more than 7 days ago:
```
⚠️ It's been a while since your last lesson. Want to continue? (/course next)
Or take a quick refresher on where you left off?
```

## Step 5: Initial assessment (if completed)

If `initial_assessment` has values:
```
── Your Profile ──
Terminal exp:    [answer]
AI exp:          [answer]
First goal:      [what they said]
```

## Step 6: Update last_active

Set `last_active` to now in the progress file.

## Step 7: Quick actions

At the bottom, show available actions:
```
Quick actions:
  /course next      — Continue to next lesson
  /course test-out  — Skip a module
  /course cheatsheet — Generate your cheat sheet
  /doctor           — Run full environment health check
```

Topic: {{args}}
