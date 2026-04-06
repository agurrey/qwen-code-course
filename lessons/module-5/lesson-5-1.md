---
module: 5
lesson: 1
title: "What Are Custom Commands"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 5.1: What Are Custom Commands

## The Problem

You have been using Qwen Code for a few weeks now. Every morning you run the same sequence of commands: check the build, review open pull requests, and scan for test failures. Every time you start a new feature, you repeat the same instructions: "read the architecture doc, find related files, create a task list." You are typing the same things over and over, and it is wasting your time.

## Mental Model

Custom commands let you save any workflow in Qwen Code as a reusable slash command. Instead of typing a long prompt every time, you define it once, store it in a file, and invoke it with a short name like `/daily-note` or `/review-pr`. Under the hood, a custom command is just a markdown file with frontmatter that Qwen Code discovers and executes.

Commands live in `~/.qwen/commands/` for personal use, or in `.qwen/commands/` inside your project for team-wide sharing. Qwen Code scans these directories at startup and registers every command it finds. This is the same auto-discovery mechanism that powers built-in commands -- there is no technical difference between a command shipped with Qwen Code and one you write yourself.

## Understanding the Command System

Before we build our own command, let us understand what makes Qwen Code's command system powerful.

### How Commands Work

When you type a slash command like `/review` or `/help`, Qwen Code does the following:

1. **Looks up the command name** in its registry of known commands.
2. **Loads the command file** -- a markdown file containing instructions written in natural language.
3. **Executes the instructions** as if you had typed them as a prompt.
4. **Returns the result** -- the model processes those instructions and acts accordingly.

This means a custom command is simply a prompt that you have saved and named. The power comes from the fact that the model treats it as a first-class command with tab completion, help text, and consistent behavior.

### Where Commands Live

Commands can live at two levels:

| Level | Path | Scope |
|-------|------|-------|
| **User** | `~/.qwen/commands/` | Available in every project |
| **Project** | `.qwen/commands/` | Available only in this project |

User-level commands are perfect for personal workflows you use everywhere. Project-level commands are ideal for team conventions -- when you commit a command file to the repository, every contributor gets the same behavior.

### Command File Structure

Every command file is a markdown file with YAML frontmatter:

```markdown
---
name: command-name
description: "Short description shown in command help"
---

# Command: command-name

[Your instructions go here. This is the prompt the model will execute
when the user invokes this command.]
```

The `name` field determines how the user invokes the command (e.g., `/command-name`). The `description` appears when the user types `/` and sees the command list. The body of the file is the actual prompt.

## Try It

Let us explore the command system and see what commands already exist on your system.

### Step 1: Check if the commands directory exists

Run this command in your terminal:

```bash
ls -la ~/.qwen/commands/ 2>/dev/null || echo "Directory does not exist yet"
```

If the directory does not exist, that is fine -- we will create it shortly.

### Step 2: Look at an existing command

Qwen Code ships with built-in commands. Let us examine one to understand the structure. Run this in your terminal:

```bash
# Find where qwen-code stores bundled commands
find /usr -name "commands" -type d 2>/dev/null | head -5
```

Alternatively, if you have Qwen Code installed, you can list available commands by typing `/` inside a Qwen Code session. The completion list shows every registered command with its description.

### Step 3: Create your commands directory

Create the user-level commands directory:

```bash
mkdir -p ~/.qwen/commands
```

This is where all your personal custom commands will live. Qwen Code will automatically discover any command files you place here.

### Step 4: Verify the directory was created

```bash
ls -la ~/.qwen/commands/
```

You should see an empty directory. This is your canvas -- every file you add here becomes a new slash command.

## Check Your Work

You should have:

- Confirmed whether `~/.qwen/commands/` exists on your system
- Created the directory if it did not exist
- Understood that commands are markdown files with YAML frontmatter
- Know the difference between user-level (`~/.qwen/commands/`) and project-level (`.qwen/commands/`) commands

Run this to verify your setup:

```bash
test -d ~/.qwen/commands && echo "Commands directory ready" || echo "Need to create directory"
```

## Debug It

Let us intentionally make a mistake to understand how command discovery works.

### Scenario: Wrong file extension

Create a command file with the wrong extension:

```bash
cat > ~/.qwen/commands/test-command.txt << 'EOF'
---
name: test-command
description: "A test command"
---

# Command: test-command

Hello, this is a test.
EOF
```

Now start Qwen Code and type `/`. You will notice that `test-command` does NOT appear in the command list. This is because Qwen Code only discovers `.md` files in the commands directory.

Fix it by renaming the file:

```bash
mv ~/.qwen/commands/test-command.txt ~/.qwen/commands/test-command.md
```

Now restart Qwen Code and type `/` again. You should see `/test-command` in the list.

### Scenario: Missing frontmatter

Create a command file without proper frontmatter:

```bash
cat > ~/.qwen/commands/broken-command.md << 'EOF'
# Command: broken-command

This file has no frontmatter.
EOF
```

Start Qwen Code and type `/`. The command may appear but will not have a description, or it may not be recognized at all depending on the version. Always include proper YAML frontmatter with `name` and `description` fields.

Clean up:

```bash
rm ~/.qwen/commands/test-command.md ~/.qwen/commands/broken-command.md
```

## Key Concepts Summary

| Concept | Details |
|---------|---------|
| Command file | A `.md` file with YAML frontmatter |
| Discovery | Qwen Code scans `~/.qwen/commands/` and `.qwen/commands/` |
| Name | Determines the slash command name (e.g., `daily-note` becomes `/daily-note`) |
| Description | Shown in the `/` command picker |
| Body | The actual prompt the model executes |
| User scope | `~/.qwen/commands/` -- available everywhere |
| Project scope | `.qwen/commands/` -- only in this project |

## What You Learned

Custom commands are named, discoverable, reusable prompts stored as markdown files in `~/.qwen/commands/` or `.qwen/commands/`.

---

**Coming up next:** In Lesson 5.2, you will build your first real custom command -- a `/daily-note` command that generates your daily developer journal entry. You will see the complete file structure, test it live, and understand the anatomy of a well-written command.
