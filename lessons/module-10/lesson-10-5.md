---
module: 10
lesson: 5
title: "The /memory Command"
prerequisites: ["module-10/lesson-10-4"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You're in the middle of a session and realize Qwen Code doesn't know something important. You could stop, open MEMORY.md in your editor, add the entry, save the file, and restart Qwen Code — or you could use the `/memory` command to manage memory right here, right now, without breaking your flow. The `/memory` command is how you handle memory management without context-switching out of your work.

## Mental Model

The `/memory` command is a **quick-edit panel** for Qwen Code's memory — it lets you add, remove, and check what Qwen Code knows during the session, without opening any files or restarting anything.

## Try It

You'll practice all the `/memory` subcommands and understand what they do, where the data goes, and when to use them versus editing files directly.

### /memory add

Add a fact to Qwen Code's current session memory:

```
/memory add I prefer single quotes in Python
```

**Expected output**: Qwen Code confirms the memory was added and will follow it going forward.

Now test it:

```
what quote style do I prefer in Python?
```

**Expected output**: "Single quotes."

You can add multiple facts at once:

```
/memory add I use 2-space indentation, never tabs
```

The text after `/memory add` becomes the memory entry. Keep entries short and specific — one sentence, one fact.

### /memory list

See everything Qwen Code currently knows from memory:

```
/memory list
```

**Expected output**: A list of all active memory entries, typically showing:
- Entries from MEMORY.md (user-level)
- Entries from QWEN.md (project-level)
- Entries added during this session with `/memory add`

This is your diagnostic tool — when Qwen Code seems confused, check what it actually knows.

### /memory remove

Remove a specific memory entry:

```
/memory remove I prefer single quotes in Python
```

**Expected output**: Qwen Code confirms the memory was removed.

Verify it's gone:

```
what quote style do I prefer in Python?
```

**Expected output**: Qwen Code won't know your preference anymore (unless it's also in MEMORY.md, which it may fall back to depending on implementation).

### /memory clear

Remove all session-added memories (not MEMORY.md or QWEN.md entries):

```
/memory clear
```

This removes everything you added with `/memory add` during this session but leaves your file-based memories intact. Use this when you've been adding temporary notes that you don't want to carry forward.

### Where do /memory entries go?

This depends on your Qwen Code version and configuration:

- **Session-only mode**: `/memory add` entries exist only for the current session. They disappear when you close Qwen Code.
- **Persistent mode**: `/memory add` entries are appended to MEMORY.md so they survive across sessions.

Check which mode you're in by adding a memory, closing Qwen Code, starting a new session, and running `/memory list`. If the entry is still there, you're in persistent mode. If it's gone, you're in session-only mode.

### When to use /memory vs editing files directly

| Use `/memory add` when... | Edit MEMORY.md directly when... |
|---|---|
| You're mid-session and need to correct Qwen Code | You're doing a planned maintenance session |
| The fact is temporary or experimental | The fact is a permanent preference |
| You want to test if a memory helps before committing | You want to organize entries into categories |
| You're teaching Qwen Code about this specific task | You're writing comprehensive preferences |

Rule of thumb: use `/memory add` for quick fixes during work, and edit files directly during your monthly maintenance session.

### Practical workflow: Correct → Add → Verify

When Qwen Code gets something wrong, use this three-step pattern:

1. **Correct it in conversation**: "No, I use Vitest, not Jest."
2. **Add it to memory**: `/memory add I use Vitest for JavaScript testing, not Jest`
3. **Verify it stuck**: "What testing framework do I use for JavaScript?"

If step 3 returns the right answer, you're set for the rest of the session. If you're in persistent mode, you're set for future sessions too.

### Common /memory mistakes

1. **Adding too much context**: 

```
/memory add On Tuesday when we were working on the login page I realized I prefer React hooks over class components
```

This is too long and includes irrelevant context (Tuesday, login page). Qwen Code doesn't need the story, it needs the rule:

```
/memory add I prefer React hooks over class components
```

2. **Adding contradictory entries**:

```
/memory add I use Jest for testing
(memory add from earlier: I use Vitest for testing)
```

Now Qwen Code has conflicting instructions. Use `/memory list` to see what's already there before adding. If you see a conflict, remove the old one first:

```
/memory remove I use Jest for testing
/memory add I use Vitest for testing, not Jest
```

3. **Assuming /memory is permanent**: If you're in session-only mode, everything you add with `/memory add` disappears when the session ends. If it's important, also add it to MEMORY.md during your maintenance session.

### /memory and QWEN.md

The `/memory` command primarily affects user-level memory (MEMORY.md). It does not modify project-level QWEN.md files. If you need to add a project-specific memory entry, edit the QWEN.md file directly:

```bash
# Add to the current project's QWEN.md
echo "- This project uses Vitest for testing" >> QWEN.md
```

Or ask Qwen Code to do it:

```
add "This project uses Vitest for testing" to the QWEN.md file
```

## Check Your Work

1. Test the full workflow:

```
/memory add I use 4-space indent for YAML files
/memory list          # Should show the new entry
/memory remove I use 4-space indent for YAML files
/memory list          # Should not show the entry anymore
```

2. Verify persistence (if applicable):
   - Add a memory with `/memory add`
   - Close Qwen Code and start a new session
   - Run `/memory list` and check if the entry survived

3. Check that Qwen Code actually follows the memories you add:

```
/memory add I prefer async functions in Python
```

Then ask it to write a function. It should use `async def`.

## Debug It

1. **"/memory add doesn't seem to do anything."** Qwen Code may have acknowledged it but the memory isn't being applied to its behavior. This can happen if:
   - The entry is too vague ("I like good code")
   - It conflicts with a stronger instruction in MEMORY.md or QWEN.md
   - The model doesn't connect the entry to its current task
   
   Fix: Make the entry more specific and action-oriented. "Always use async def, never def, for Python functions" is stronger than "I prefer async functions."

2. **"/memory list shows too many entries."** You've been using `/memory add` without cleaning up. Run `/memory clear` to remove session-added entries, then only re-add the ones that actually matter.

3. **"I added something with /memory but Qwen Code still does the old thing."** The file-based memory (MEMORY.md) may override session-based memory. If your MEMORY.md says "use Jest" and you added "use Vitest" via `/memory add`, the file might win. Fix: remove the old entry from MEMORY.md directly.

## What You Learned

The /memory command lets you manage Qwen Code's knowledge mid-session — add quick corrections, list what it knows, and remove outdated entries without leaving your workflow.

**Module 10 Complete!**

You now understand how Qwen Code's memory works across three layers — conversation context, user-level MEMORY.md, and project-level QWEN.md. You can write useful memory entries, maintain them over time, and manage memory on the fly with the /memory command.

*Next: Module 11 — Your Real Project — You'll put everything you've learned to work by planning, building, and shipping a real project using Qwen Code as your primary development tool.*
