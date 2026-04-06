---
module: 1
lesson: 1
title: "What Qwen Code Actually Is"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 1.1: What Qwen Code Actually Is

> **Time:** ~3 min reading + ~3 min doing

## The Problem

People call Qwen Code an "AI coding assistant," "a coding agent," "like ChatGPT but for code." None of these are wrong, but none are right enough to help you actually use it. Without a clear mental model, you'll either underuse it (treating it like Google) or overtrust it (assuming it knows your whole codebase).

## Mental Model

Qwen Code is a **large language model with tools**. It reads your request, decides which tools it needs (read file, write file, run command, search, fetch web page), uses them, and reports back. It doesn't "know" your codebase — it only knows what it has read. It doesn't "think ahead" — it responds to your current request. Understanding these limits makes it dramatically more useful.

## Try It

**Your task:** See the difference between what Qwen Code knows by default vs. what it learns by reading.

1. Launch Qwen Code in your sandbox:
   ```bash
   cd ~/qwen-sandbox
   qwen
   ```

2. Ask it: "What files are in this directory?"
   - It will likely say it doesn't know, or list nothing. It hasn't read the directory yet.

3. Now ask: "List the files in the current directory."
   - It will use its file tools (glob or ls) to discover what's there.

4. Now ask: "Read hello.txt and tell me what's in it."
   - It will read the file and show you the content.

5. Now ask: "What files are in this directory?" again.
   - It now knows because it read the directory in step 3.

**The key insight:** Qwen Code only knows what it has actively read. It has no persistent memory between requests unless it reads files. This is fundamentally different from ChatGPT, which tries to remember your conversation.

## Check Your Work

The model should check:
1. The user observed that Qwen Code didn't know the directory contents until it used a tool to look
2. The user observed that after reading a file, Qwen Code "knew" its content
3. The user can explain the difference: "Qwen Code only knows what it reads"

## Debug It

**Something's broken:** Qwen Code seems to know things it shouldn't, or gives answers without reading files first.

**Hint if stuck:** Qwen Code might have read files in a previous turn of the conversation and retained that knowledge in the conversation context. This isn't "memory" — it's conversation history. Start a fresh session (`/quit` and `qwen` again) to see the blank slate.

**Expected fix:** Restart Qwen Code and repeat the exercise. Notice the difference between conversation context (temporary, within one session) and file knowledge (persistent, from reading actual files).

## What You Learned

Qwen Code has no built-in knowledge of your files. It only knows what it actively reads using its tools.

---

*Next: Lesson 1.2 — What Qwen Code Is NOT — the misconceptions that cause the most damage.*
