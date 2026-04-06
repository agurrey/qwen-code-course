---
module: 10
lesson: 1
title: "How Qwen Code Remembers Things"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

Every time you start a new Qwen Code session, you re-explain the same things: your preferred naming conventions, the project's directory structure, the fact that you use pytest not unittest, that you never want generated files committed. This repetition wastes time and breeds frustration. Qwen Code has no memory between sessions by default — but it can, if you give it the right files to read.

## Mental Model

Qwen Code's memory works like a **notebook on its desk** — it only knows what's written in the notebooks you put there. The conversation itself is like a whiteboard: everything discussed during this session, wiped clean when you close the terminal. Memory files are the notebooks that survive between sessions. You write in them once, and Qwen Code reads them every time it starts.

## Try It

You'll explore the three levels of memory in Qwen Code and see how each one works.

### Level 1: Conversation context (the whiteboard)

This is what Qwen Code remembers naturally during a single session. Every message you send, every file it reads, every command it runs — it's all in the conversation history.

Test it:

```
create a file called colors.txt with "blue, green, red"
```

Then, a few messages later:

```
what colors did I mention earlier?
```

Qwen Code will remember because it's in the conversation context. Now close the session and start a new one:

```
what colors did I mention earlier?
```

**Expected output**: Qwen Code won't know. The conversation context is gone — the whiteboard was erased.

### Level 2: User-level memory (MEMORY.md)

MEMORY.md is a file in your user directory that Qwen Code reads at the start of every session, regardless of which project you're working in. It's for facts about **you** — your preferences, conventions, and habits that apply everywhere.

Check if you have one:

```bash
ls ~/.qwen/MEMORY.md 2>/dev/null && echo "exists" || echo "does not exist"
```

If it doesn't exist, create it:

```bash
mkdir -p ~/.qwen
```

Now create your first MEMORY.md:

```markdown
# My Preferences

## Coding Style
- I prefer snake_case for Python functions and variables
- I use descriptive variable names, not single letters
- Always add type hints to function signatures

## Tools
- I use pytest for Python testing, never unittest
- I use black for formatting, isort for imports
- My editor tab size is 2 spaces

## Workflow
- Always commit with descriptive messages
- Never push directly to main
- Run tests before suggesting any commit
```

Start a new Qwen Code session and ask:

```
what testing framework do I use?
```

**Expected output**: Qwen Code should answer "pytest" because it read your MEMORY.md at the start of the session.

### Level 3: Project-level memory (QWEN.md)

QWEN.md lives in your project directory and contains instructions specific to **that project**. Every project can have its own QWEN.md, and Qwen Code reads it when working in that directory.

Create one in a project:

```bash
mkdir -p /tmp/my-project && cd /tmp/my-project
```

```markdown
# My Project

## Structure
- src/ contains the application code
- tests/ contains pytest tests
- docs/ contains documentation files

## Conventions
- All new modules go in src/myproject/
- Tests mirror the src/ structure in tests/
- Use Click for CLI commands

## Important
- The config.yaml file is generated, never edit it directly
- Database migrations are in migrations/ — use alembic to manage them
- API keys are in .env, never commit them
```

Now ask Qwen Code:

```
where should I put a new module called auth.py?
```

**Expected output**: Qwen Code should say `src/myproject/auth.py` because it read the QWEN.md.

### How the memory layers stack

When Qwen Code starts a session, it reads memory in this order:

1. **MEMORY.md** (user-level) — your personal preferences
2. **QWEN.md** (project-level) — project-specific instructions
3. **Conversation context** — what's been said in this session

If there's a conflict, conversation context wins (most recent), then QWEN.md (most specific), then MEMORY.md (most general). This means you can override your global preferences for a specific project by putting different instructions in that project's QWEN.md.

Example: Your MEMORY.md says "use pytest" but a JavaScript project's QWEN.md says "use Jest for testing." In that project, Qwen Code follows the QWEN.md. Everywhere else, it follows MEMORY.md.

### The /memory command

You can also manage memory during a session using the `/memory` command:

```
/memory add I prefer async/await over callbacks
```

This adds the fact to your current session's context. Depending on your Qwen Code configuration, it may also persist it to MEMORY.md.

```
/memory list
```

Shows everything Qwen Code currently knows from memory.

```
/memory remove I prefer async/await over callbacks
```

Removes that specific memory.

## Check Your Work

1. Verify your MEMORY.md exists and has content:

```bash
cat ~/.qwen/MEMORY.md
```

2. Verify your project's QWEN.md exists:

```bash
cat /tmp/my-project/QWEN.md
```

3. Start a new session and test that Qwen Code reads both files by asking about your preferences and project conventions.

## Debug It

1. **"Qwen Code doesn't seem to read my MEMORY.md."** Check the path. It must be exactly at `~/.qwen/MEMORY.md` (which expands to `/home/yourusername/.qwen/MEMORY.md`). Not `~/.qwen/memory.md` (case matters on Linux). Not `~/qwen-code-course/MEMORY.md`.

2. **"Qwen Code is ignoring my QWEN.md."** The file must be at the root of your project directory — the same directory where you started Qwen Code. If you started Qwen Code in `/tmp/my-project/src/`, it won't find `/tmp/my-project/QWEN.md`. Start from the project root.

3. **"My /memory add command didn't persist."** The `/memory add` command may only affect the current session depending on your Qwen Code version. To make it permanent, add it to MEMORY.md manually. The `/memory` command is best used for temporary session-specific notes.

## What You Learned

Qwen Code remembers things through files it reads at startup — MEMORY.md for your personal preferences, QWEN.md for project specifics, and conversation context for the current session only.

*Next: Lesson 10.2 — Setting Up Your Personal Memory — You'll write your first real MEMORY.md, learn what to include and what to skip, and set up memory that actually improves your daily workflow.*
