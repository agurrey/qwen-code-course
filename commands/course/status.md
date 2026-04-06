---
description: Show current course progress, completed lessons, and what's next.
---

Show the user their current progress in the Qwen Code Course.

## Step 1: Read progress file

Read `~/.qwen/course-progress.json`. If it doesn't exist, say:

```
No progress found. Start the course with: /course start
```

## Step 2: Display progress

Format and show:

```
=== Qwen Code Course — Progress ===

Overall: X/60 lessons completed (Y%)

Current Module: [Module N: Title]
Module progress: A/B lessons completed

Completed Lessons:
  ✅ 0.1 [title]
  ✅ 0.2 [title]
  ...

Next Lesson: X.Y [title]

Initial Assessment Results:
  Terminal experience: [answer]
  AI experience: [answer]
  First goal: [what they said they want to build]
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

## Step 5: Update last_active

Set `last_active` to now in the progress file.

Topic: {{args}}
