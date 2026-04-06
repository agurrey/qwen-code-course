---
description: Test out of a module by passing a 3-question quiz. Skip the module's lessons if you pass.
---

Run a test-out quiz for the specified module. If the user passes all 3 questions, the module is marked as complete and they skip to the next one.

## Step 1: Validate the request

Check if the user specified a module number. If not, ask:

```
Which module do you want to test out of? (0-11)
Note: You can only test out of modules whose prerequisites you've completed.
```

Validate:
- Module exists
- Prerequisites are met (user has completed or tested out of prerequisite modules)

## Step 2: Generate the quiz

Each test-out quiz has 3 questions:

**Q1 (Conceptual — multiple choice):** Tests understanding of the module's key concepts.
**Q2 (Practical — do something):** Tests ability to execute a skill from the module.
**Q3 (Debug — fix something broken):** Tests troubleshooting ability.

Read the module's `_module.json` for learning objectives, then generate questions based on those objectives.

### Example for Module 2 (Your First Commands):

**Q1:** "You need to find all files containing 'TODO' across your project. Which Qwen Code tool should you use?"
- A) Glob
- B) Grep ← correct
- C) Shell
- D) Read

**Q2:** "Create a file called quiz-answer.txt in ~/qwen-sandbox/ with the text 'I passed the Module 2 test-out!'"

**Q3:** "I tried to read a file but Qwen Code just described what it would do instead of actually reading it. What's probably wrong?"
- A) The file is too large
- B) Qwen Code is in plan mode ← correct
- C) The file doesn't exist
- D) Qwen Code doesn't have a Read tool

## Step 3: Administer the quiz

Present questions ONE AT A TIME. Wait for the user's answer before proceeding.

For Q2 (practical), actually verify the file was created with correct content.

## Step 4: Grade and report

- **3/3 correct:** "You passed! Module X marked as complete. You can skip to Module X+1."
  - Update progress: mark module as "test_out": true, "status": "completed"
- **2/3 or less:** "Not quite — you got X/3. I'd recommend doing the lessons for this module. Want to start with Lesson X.1?"
  - Don't mark the module as complete. Offer to start the first lesson.

## Step 5: Update progress

If passed:
```json
{
  "modules": {
    "X": {
      "status": "completed",
      "test_out": true,
      "test_out_score": "3/3",
      "completed_at": "2026-04-06T..."
    }
  }
}
```

Topic: {{args}}
