---
module: 5
lesson: 3
title: "Commands with Parameters"
prerequisites: ["lesson-5-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 5.3: Commands with Parameters

## The Problem

Your `/daily-note` command works great interactively, but some days you already know what to write and do not want to answer questions one at a time. You want to be able to pass the information directly: `/daily-note "Fixed auth bug | Writing tests | None`. Similarly, you want a `/commit` command that takes a type and description: `/commit fix: resolve null pointer in user service`. Parameters make commands flexible enough to handle both interactive and scripted workflows.

## Mental Model

The `{{args}}` placeholder in a command file captures everything the user types after the command name. When you type `/my-command hello world`, the model receives the command body with `{{args}}` replaced by `hello world`. This turns a static prompt into a dynamic one that adapts to user input.

## How Parameters Work

### The {{args}} Placeholder

Inside any command file, you can use `{{args}}` as a placeholder. When the user invokes the command, everything they type after the command name replaces `{{args}}` in the prompt before the model processes it.

```
Command file contains: "Process these arguments: {{args}}"
User types: /my-command foo bar baz
Model receives: "Process these arguments: foo bar baz"
```

If the user provides no arguments, `{{args}}` is replaced with an empty string.

### Interactive vs Non-Interactive Modes

With parameters, your commands can support two modes of operation:

| Mode | Example | Use Case |
|------|---------|----------|
| **Interactive** | `/daily-note` | User wants guided Q&A |
| **Non-interactive** | `/daily-note "Fixed bug | Tests | None"` | User knows the answers |

The trick is writing the command body to handle both cases gracefully.

### Argument Parsing

Qwen Code does not do automatic argument parsing. The `{{args}}` placeholder captures the raw text. It is up to your prompt instructions to tell the model how to interpret the arguments. You can instruct the model to:

- Parse `key=value` pairs
- Split on a delimiter like `|`
- Treat everything as a single string
- Interpret flags like `--force` or `--dry-run`

## Try It: Add Parameters to /daily-note

### Step 1: Update your command file

Edit `~/.qwen/commands/daily-note.md` to support both interactive and parameter modes:

```bash
cat > ~/.qwen/commands/daily-note.md << 'EOF'
---
name: daily-note
description: "Generate a structured daily standup note"
---

# Command: daily-note

You are helping me write my daily developer standup note.

Check if arguments were provided: {{args}}

## Mode 1: Arguments Provided
If {{args}} is not empty, parse it as pipe-separated values:
- Part 1: Yesterday's accomplishments
- Part 2: Today's plans
- Part 3: Blockers (or "None")

Example: /daily-note "Fixed auth bug | Writing tests | Waiting on API docs"

Generate the markdown note directly using the provided information:

```markdown
# Daily Standup - {{DATE}}

## Yesterday
- [parsed yesterday's accomplishments]

## Today
- [parsed today's plans]

## Blockers
- [parsed blockers, or "None"]
```

## Mode 2: No Arguments (Interactive)
If {{args}} is empty, ask me these questions one at a time:
- What did you accomplish yesterday?
- What are you planning to work on today?
- Are there any blockers or risks?

After collecting all answers, generate the same markdown format.

## Saving
In both modes:
1. Save the note to `~/notes/daily-notes/YYYY-MM-DD.md`
2. If the directory does not exist, create it first
3. If a file for today already exists, ask about overwriting
4. After saving, show the file path and a one-line summary
EOF
```

### Step 2: Test interactive mode

Start Qwen Code and run:

```
/daily-note
```

The model should ask you questions one at a time, just as before. The behavior is unchanged because `{{args}}` is empty in this case.

### Step 3: Test parameter mode

Now try passing arguments directly:

```
/daily-note "Refactored the API client | Write unit tests for auth module | Waiting on design review"
```

The model should parse the three pipe-separated sections and generate the note immediately without asking questions.

### Step 4: Test edge cases

Test with minimal arguments:

```
/daily-note "Did stuff | More stuff"
```

The model should handle the missing third section gracefully (perhaps by noting "Blockers: Not specified").

Test with a single argument:

```
/daily-note "Just yesterday's update"
```

The model should use what is provided and leave reasonable defaults for missing sections.

## Building a Parameterized /commit Command

Let us build another command that demonstrates a different argument pattern -- key-value pairs.

### Step 1: Create the command file

```bash
cat > ~/.qwen/commands/commit.md << 'EOF'
---
name: commit
description: "Generate a commit message from staged changes"
---

# Command: commit

Arguments provided: {{args}}

Your task is to generate a well-formatted git commit message based on the
staged changes and any user-provided context.

## Instructions

1. Run `git diff --staged` to see the staged changes.
2. Run `git status` to see the overall state.
3. If {{args}} is provided, use it as context for the commit message.
   Interpret {{args}} as the desired commit message subject line.
4. Generate a commit message following conventional commits format:

```
<type>(<scope>): <description>

<body explaining what changed and why>
```

Types: feat, fix, docs, style, refactor, test, chore, perf

5. Show the proposed commit message to the user.
6. Ask if they want to proceed with `git commit -m "<message>"`.
7. If they confirm, execute the commit.

## Handling {{args}}

If {{args}} contains a colon (e.g., "fix: resolve null pointer"), use it
directly as the subject line and generate only the body.

If {{args}} is plain text without a colon (e.g., "fixed the login bug"),
determine the appropriate type and scope yourself and format it.

If {{args}} is empty, generate the entire message from the diff alone.
EOF
```

### Step 2: Test the /commit command

In a git repository with staged changes:

```bash
# Stage some files
git add .

# Test with no arguments - model generates message from diff
/commit

# Test with a suggested message
/commit "fix(auth): handle null user ID in login flow"

# Test with partial context
/commit "the login bug fix"
```

## Advanced Parameter Patterns

### Flag-Style Arguments

You can instruct the model to interpret arguments as flags:

```bash
cat > ~/.qwen/commands/review.md << 'EOF'
---
name: review
description: "Review code with optional flags"
---

# Command: review

Arguments: {{args}}

Review the current project for code quality. Parse {{args}} for flags:

- If "--focus <area>" is present, focus the review on that area
- If "--brief" is present, keep the review to 5 key points maximum
- If "--security" is present, prioritize security findings
- If no flags, do a comprehensive review

Report findings in a structured format with severity levels.
EOF
```

Usage:

```
/review --focus authentication --security --brief
```

### Multi-Value Arguments

For commands that need multiple values of the same type:

```bash
cat > ~/.qwen/commands/test.md << 'EOF'
---
name: test
description: "Run tests for specified modules"
---

# Command: test

Arguments: {{args}}

Run tests based on the arguments provided:

- If {{args}} is empty, run the full test suite
- If {{args}} contains comma-separated module names (e.g., "auth,users,billing"),
  run tests for each listed module
- If {{args}} contains a file path, run tests for that specific file

Execute the appropriate test command and report results.
EOF
```

Usage:

```
/test                    # Full test suite
/test auth,users         # Specific modules
/test src/auth.test.js   # Specific file
```

## Check Your Work

Verify your parameterized commands:

1. **{{args}} is present** in the command file body
2. **Both modes work** -- with and without arguments
3. **Edge cases are handled** -- empty args, partial args, unexpected format
4. **Instructions are explicit** about how to parse the arguments

Test script:

```bash
echo "=== Checking command parameters ==="
grep -q '{{args}}' ~/.qwen/commands/daily-note.md && echo "daily-note uses {{args}}" || echo "MISSING {{args}}"
grep -q '{{args}}' ~/.qwen/commands/commit.md && echo "commit uses {{args}}" || echo "MISSING {{args}}"
echo "=== Done ==="
```

## Debug It

### Scenario: {{args}} not being replaced

Your command file contains `{{args}}` but the model receives the literal text `{{args}}`.

**Cause:** Template syntax may vary by version. Verify the exact placeholder syntax in your version of Qwen Code.

**Fix:** Check the documentation for your version:
```bash
qwen --version
```

### Scenario: Model ignores argument parsing instructions

The user provides arguments but the model still asks interactive questions.

**Fix:** Make the conditional logic explicit and prominent:

```markdown
IMPORTANT: Check if arguments are provided before doing anything else.

{{args}}

IF the text above is empty (no arguments):
  -> Ask questions interactively

IF the text above has content (arguments provided):
  -> Use the arguments directly, do NOT ask questions
```

### Scenario: Arguments with special characters

Arguments containing pipes, quotes, or other special characters may not parse correctly.

**Fix:** Use a delimiter that is unlikely to appear in normal text, or instruct the model to handle quoted strings:

```markdown
Arguments: {{args}}

Parse {{args}} as follows:
- Arguments may be enclosed in double quotes
- Within quotes, pipe characters (|) are literal, not separators
- Outside quotes, pipes separate fields
- Example: "Contains | pipe" | field2 | field3
```

## Parameter Design Checklist

When designing a command with parameters:

- [ ] Use `{{args}}` to capture user input
- [ ] Decide on an argument format (pipe-separated, key=value, flags)
- [ ] Document the format in the command body
- [ ] Handle the empty-args case (interactive or default behavior)
- [ ] Handle partial args (missing some fields)
- [ ] Handle unexpected args format gracefully
- [ ] Test with realistic examples before sharing

## What You Learned

The `{{args}}` placeholder lets commands accept user input, enabling both interactive and scripted workflows with a single command definition.

---

**Coming up next:** In Lesson 5.4, you will learn how to organize dozens of commands using namespaces and directory structure, so your `~/.qwen/commands/` directory stays maintainable as your command library grows.
