---
description: Generate a personalized cheat sheet based on what you've learned and struggled with in the course.
---

Generate a personalized cheat sheet from the user's course progress.

## Step 1: Read progress

Read `~/.qwen/course-progress.json`.

## Step 2: Generate the cheat sheet

Create `~/.qwen/cheatsheet.md` with this structure:

```markdown
# My Qwen Code Cheat Sheet
Generated: [date]
Progress: X/60 lessons completed

---

## Commands I Know

[List every command from completed modules with 1-line description and example]

## Concepts I Mastered

[Key mental models from completed modules — the user's own "aha" moments]

## Things I Struggled With

[From lessons where confidence was "low" — include the concept and a reminder of the solution]

## Tools I Use Most

[Based on which lessons were completed with "high" confidence — the tools the user is most comfortable with]

## Quick Reference

### Reading Files
- "Read [filename] and [what to do with it]"
- Qwen uses the Read tool automatically

### Editing Files
- "Change [what] in [filename] to [new value]"
- Qwen reads, edits, and writes back

### Running Commands
- Always review commands before approving
- Shell tool runs in Qwen's working directory

### Searching
- Grep = search INSIDE files for text patterns
- Glob = find FILES by name pattern

### Web Fetch
- Gets webpage content as readable text
- Can't interact with forms or logged-in pages

## Next Steps

[What module they should tackle next, and why]

---

*This cheat sheet is personalized based on YOUR progress. Retake it after each module — it grows as you learn.*
```

## Step 3: Save and confirm

Write the file to `~/.qwen/cheatsheet.md` and say:

```
Your personalized cheat sheet is ready at ~/.qwen/cheatsheet.md
It covers everything you've learned so far and flags areas you struggled with.
Come back and run /course cheatsheet after each module — it gets better as you progress.
```

Topic: {{args}}
