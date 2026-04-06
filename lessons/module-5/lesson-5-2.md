---
module: 5
lesson: 2
title: "Your First Custom Command"
prerequisites: ["lesson-5-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 5.2: Your First Custom Command

## The Problem

You want to start each workday by reviewing what you accomplished yesterday, what is on your agenda today, and what risks might block your progress. Instead of writing this from scratch every morning, you want a command that sets up the structure, prompts you to fill in the details, and saves it to a consistent location.

## Mental Model

Building a custom command is a three-step process: write the command file with clear instructions, invoke it with a slash, and verify the output matches your expectations. The command file is a prompt written in natural language -- the better you write the prompt, the more reliable and consistent the command's behavior will be.

## Anatomy of a Well-Written Command

Before we write our first command, let us understand what separates a useful command from a vague one.

### Good Commands Are Specific

Compare these two instructions:

**Vague:**
```markdown
Help me write a daily note.
```

**Specific:**
```markdown
Generate a structured daily standup note with sections for yesterday's
accomplishments, today's plan, and blockers. Ask me clarifying questions
if any section is missing information. Save the result to
~/notes/daily-notes/YYYY-MM-DD.md.
```

The second version tells the model exactly what to produce, what format to use, and where to put it. The first version leaves everything to interpretation.

### Good Commands Have Structure

Effective commands typically include:

1. **Role or context** -- "You are helping me write a daily standup note"
2. **Output format** -- "Use markdown with these sections..."
3. **Interaction pattern** -- "Ask me for input on each section"
4. **Post-processing** -- "Save to this file, then summarize"

### Good Commands Handle Edge Cases

Consider: what happens if the output directory does not exist? What if the file already exists? A robust command anticipates these scenarios:

```markdown
If the directory ~/notes/daily-notes/ does not exist, create it first.
If a file for today's date already exists, append to it rather than overwriting.
```

## Try It: Build a /daily-note Command

### Step 1: Create the command file

Create a new file at `~/.qwen/commands/daily-note.md`:

```bash
cat > ~/.qwen/commands/daily-note.md << 'EOF'
---
name: daily-note
description: "Generate a structured daily standup note"
---

# Command: daily-note

You are helping me write my daily developer standup note. Follow this process:

1. Ask me these questions one at a time and wait for my answers:
   - What did you accomplish yesterday?
   - What are you planning to work on today?
   - Are there any blockers or risks?

2. After collecting all answers, generate a markdown note with this structure:

```markdown
# Daily Standup - {{DATE}}

## Yesterday
- [user's accomplishments]

## Today
- [user's plans]

## Blockers
- [user's blockers, or "None"]
```

3. Save the note to `~/notes/daily-notes/YYYY-MM-DD.md` (using today's date).
4. If the directory does not exist, create it first.
5. If a file for today already exists, ask me if I want to overwrite or append.
6. After saving, show me the file path and a one-line summary of what was saved.
EOF
```

### Step 2: Verify the file was created correctly

```bash
cat ~/.qwen/commands/daily-note.md
```

Check that:
- The frontmatter has both `name` and `description` fields
- The body contains clear, step-by-step instructions
- The file extension is `.md`

### Step 3: Test the command

Start Qwen Code in any project directory:

```bash
qwen
```

Once inside Qwen Code, type `/` and you should see `daily-note` in the command list. Select it (or type `/daily-note` directly) and watch the model execute your command.

The model will:
1. Ask you about yesterday's accomplishments
2. Ask about today's plan
3. Ask about blockers
4. Generate the formatted note
5. Save it to the correct location

### Step 4: Verify the output

After the command runs, check that the file was created:

```bash
ls -la ~/notes/daily-notes/
cat ~/notes/daily-notes/$(date +%Y-%m-%d).md
```

You should see a well-formatted markdown note with the sections you defined.

## Understanding the Command Execution Flow

When you run `/daily-note`, here is what happens internally:

```
User types: /daily-note
    |
    v
Qwen Code looks up "daily-note" in command registry
    |
    v
Loads ~/./qwen/commands/daily-note.md
    |
    v
Parses frontmatter (name, description)
    |
    v
Extracts body as the prompt
    |
    v
Sends prompt to the model
    |
    v
Model executes instructions step by step
    |
    v
Result displayed to user
```

This is the same flow as any built-in command. Your custom command has no performance penalty and no behavioral difference from commands shipped with Qwen Code.

## Best Practices for Command Prompts

As you write commands, keep these principles in mind:

### Use Imperative Language

Write instructions as commands, not suggestions:

```
GOOD:  "Generate a markdown note with these sections..."
AVOID: "Maybe you could help me write a note..."
```

### Be Explicit About Format

Specify the exact output structure you want:

```
GOOD:  "Use a markdown table with columns: File, Issue, Status"
AVOID: "Summarize the issues in a nice format"
```

### Handle the Happy Path and Edge Cases

```
GOOD:  "Save to ~/notes/daily-notes/YYYY-MM-DD.md. If the directory
        does not exist, create it. If the file exists, ask about
        overwriting."
AVOID: "Save the note somewhere convenient."
```

### Keep Commands Focused

Each command should do one thing well. If you find yourself writing a command with 20 steps covering multiple unrelated tasks, split it into separate commands:

```
/daily-note        # Write daily standup
/weekly-summary    # Generate weekly report from daily notes
/monthly-review    # Monthly retrospective
```

## Check Your Work

Verify your command meets these criteria:

1. The file exists at `~/.qwen/commands/daily-note.md`
2. The frontmatter contains `name: daily-note` and a `description`
3. The body has clear step-by-step instructions
4. Running `/daily-note` in Qwen Code produces the expected interactive flow
5. The output file is saved to the correct location with the correct format

Run this verification:

```bash
echo "=== Checking daily-note command ==="
test -f ~/.qwen/commands/daily-note.md && echo "File exists" || echo "MISSING"
grep -q "name: daily-note" ~/.qwen/commands/daily-note.md && echo "Name field present" || echo "MISSING name"
grep -q "description:" ~/.qwen/commands/daily-note.md && echo "Description field present" || echo "MISSING description"
echo "=== Done ==="
```

## Debug It

### Scenario: Command not appearing in the list

You created the file but `/daily-note` does not show up when you type `/`.

**Cause 1: Wrong file extension**
```bash
# Check the file extension
ls ~/.qwen/commands/daily-note*
# If you see daily-note.txt or daily-note, rename it:
mv ~/.qwen/commands/daily-note.txt ~/.qwen/commands/daily-note.md
```

**Cause 2: Wrong directory**
```bash
# Make sure the file is in the correct directory
ls -la ~/.qwen/commands/daily-note.md
# If it is elsewhere, move it:
mv /wrong/path/daily-note.md ~/.qwen/commands/daily-note.md
```

**Cause 3: Qwen Code was already running**
Qwen Code discovers commands at startup. If you created the file while Qwen Code was running, restart it:
```bash
# Exit Qwen Code and start it again
exit
qwen
```

### Scenario: Command runs but output is wrong

Your command runs but the model does not produce the expected output.

**Fix:** Make the instructions more explicit. If the model is not saving to the correct path, add more detail:

```markdown
# Before (vague)
Save the note to the daily notes folder.

# After (specific)
Save the note to ~/notes/daily-notes/YYYY-MM-DD.md where YYYY-MM-DD
is today's date in ISO format. Use the shell command:
  mkdir -p ~/notes/daily-notes/
  cat > ~/notes/daily-notes/$(date +%Y-%m-%d).md << 'NOTE'
  [note content here]
  NOTE
```

## Iterating on Your Command

Commands are just files, so you can edit them like any other file. If the output is not quite right:

1. Open `~/.qwen/commands/daily-note.md` in your editor
2. Adjust the instructions to be more specific
3. Save the file
4. Restart Qwen Code and try again

There is no compile step, no deployment, no registration. Edit the file, restart, and test. This rapid iteration cycle is one of the biggest advantages of the custom command system.

## What You Learned

A custom command is a markdown file with frontmatter and step-by-step instructions that Qwen Code executes as a named slash command.

---

**Coming up next:** In Lesson 5.3, you will learn how to make your commands accept parameters using the `{{args}}` syntax, turning `/daily-note` into something like `/daily-note --yesterday "Fixed auth bug" --today "Write tests"` for non-interactive use.
