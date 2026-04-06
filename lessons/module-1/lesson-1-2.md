---
module: 1
lesson: 2
title: "What Qwen Code Is NOT"
prerequisites: ["1-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 1.2: What Qwen Code Is NOT

> **Time:** ~3 min reading + ~2 min doing

## The Problem

If you treat Qwen Code like something it's not, you'll get frustrated. The most common frustrations come from expecting it to behave like ChatGPT, a search engine, or an omniscient programmer who already knows your project.

## Mental Model

Qwen Code is NOT:
- **A chatbot** — it doesn't have opinions, personality, or memory between sessions (unless you give it files to read)
- **A search engine** — it doesn't browse your whole codebase automatically
- **A compiler** — it can write code, but it doesn't "know" if the code runs correctly until it tests it
- **A human developer** — it won't plan ahead, remember your preferences, or notice problems you didn't ask about (unless you tell it to)

Qwen Code IS:
- **A tool-using AI** — it reads your request, picks tools, executes them, and reports results
- **A tireless assistant** — it will do exactly what you ask, as many times as you ask, without getting bored
- **A pattern matcher** — it's seen millions of code examples and can apply those patterns to your situation

## Try It

**Your task:** Test the boundaries to see what Qwen Code doesn't know.

1. Launch Qwen Code:
   ```bash
   cd ~/qwen-sandbox
   qwen
   ```

2. Ask: "What's my name?"
   - It will guess or say it doesn't know. It genuinely doesn't know you.

3. Ask: "What projects do I have on my computer?"
   - It doesn't know. It hasn't read your directories.

4. Ask: "Is my code in hello.txt correct?"
   - It will read hello.txt (if it hasn't already) and evaluate it. But it only knows what's in that one file, not what you're trying to build.

5. Now tell it your name: "My name is [your name]. Remember it for this session."
   - It will acknowledge. Ask again: "What's my name?" — now it knows, because it's in the conversation.

6. Exit with `/quit` and relaunch `qwen`. Ask: "What's my name?"
   - It forgot. Conversation context doesn't persist between sessions.

## Check Your Work

The model should check:
1. The user observed that Qwen Code didn't know personal information (name, projects)
2. The user observed that information given in conversation persists within a session
3. The user observed that information does NOT persist between sessions
4. The user can name at least two things Qwen Code is NOT

## Debug It

**Something's broken:** Qwen Code seems to remember things between sessions, or knows about your files without reading them.

**Hint if stuck:** Qwen Code may have a "memory" feature that persists context between sessions. This is a configuration feature, not default behavior. Check if a MEMORY.md file exists in `~/.qwen/`.

**Expected fix:** This is actually correct behavior if memory is configured. The lesson is about understanding the default (no persistence) vs. configured (memory files). Both are valid — the key is knowing which one you have.

## What You Learned

Qwen Code has no inherent knowledge about you, your projects, or your preferences. It only knows what you tell it or what it reads from files.

---

*Next: Lesson 1.3 — How Qwen Code Thinks in Tools — the most important mental model for using it effectively.*
