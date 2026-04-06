---
description: Continue to the next unfinished lesson in the course.
---

Load the next unfinished lesson for the user. Follow this flow:

## Step 1: Read progress

Read `~/.qwen/course-progress.json`. Determine:
- Which module the user is currently in
- Which was the last completed lesson in that module
- What the next lesson is

## Step 2: Check for stagnation

If `last_active` is more than 7 days ago:
1. Say: "You've been away for a while. Last time you were on Lesson X.Y ([lesson title]). Want a quick refresher before we continue?"
2. If yes → load the previous lesson for a 1-question review
3. If no → proceed to next lesson

Update `last_active` to now.

## Step 3: Check if module is complete

If the user has completed all lessons in the current module:
1. Congratulate them: "Module X Complete! [module title]"
2. Show a 1-sentence summary of what they learned
3. Tease the next module: "Next up: Module X+1 — [module title] — [one-sentence teaser]"
4. Ask: "Ready for Module X+1?" If yes, proceed to first lesson of next module.

## Step 4: Load the next lesson

Read the lesson file from `~/qwen-tryouts/qwen-code-course/lessons/module-X/lesson-X-Y.md`.

Present it to the user in this format:

```
=== Lesson X.Y: [Title] ===
[Time estimate]

## The Problem
[content]

## Mental Model
[content]

Ready? Let's do the exercise.
```

## Step 5: Guide through the exercise

Walk the user through the "Try It" section of the lesson:
1. Tell them what to do
2. Wait for them to do it
3. Check the result (actually verify — read the file, run the command, etc.)
4. If wrong, give a hint (not the answer)
5. If right, acknowledge and move to "Debug It"
6. Guide through the debug exercise

## Step 6: Complete the lesson

When both exercises are done:
1. Update progress.json: mark the lesson as "completed" with timestamp, attempts count, confidence level
2. Summarize: "What You Learned: [1-sentence summary]"
3. Ask: "Ready for the next lesson? (/course next) or take a break?"

## Confidence tracking

After each lesson, assess confidence based on:
- **high:** Completed both exercises on first attempt, explained concepts clearly
- **medium:** Needed 1-2 hints, got there eventually
- **low:** Needed 3+ hints or the answer was shown to them

Record this in the progress file under the lesson's `confidence` field.
