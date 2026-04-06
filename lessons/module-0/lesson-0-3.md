---
module: 0
lesson: 3
title: "Your First Qwen Command"
prerequisites: ["0-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 0.3: Your First Qwen Command

> **Time:** ~2 min reading + ~3 min doing

## The Problem

You installed Qwen Code. Now what? Most people open it, stare at the prompt, and close it because they don't know what to say. This lesson gets you past that in 2 minutes with a real, visible result.

## Mental Model

Qwen Code isn't a search engine — you don't ask it questions. You give it **tasks**. Think of it like telling a very competent assistant: "Here's what I want done." It will figure out how and show you the result.

## Try It

**Your task:** Create your first project file using Qwen Code.

1. Create a practice directory (your safe sandbox):
   ```bash
   mkdir -p ~/qwen-sandbox
   cd ~/qwen-sandbox
   ```

2. Launch Qwen Code in this directory:
   ```bash
   qwen
   ```

3. When Qwen Code loads, type this exact message:
   ```
   Create a file called hello.txt that says "Hello, I'm learning Qwen Code!"
   ```

4. Watch what happens. Qwen Code will:
   - Think for a moment (you'll see it processing)
   - Create the file `hello.txt`
   - Write the content
   - Tell you it's done

5. Verify it worked. Exit Qwen Code with `/quit`, then:
   ```bash
   cat ~/qwen-sandbox/hello.txt
   ```
   You should see:
   ```
   Hello, I'm learning Qwen Code!
   ```

**You just had an AI create a file for you through natural language.** That's the whole game. Everything else is just learning to ask for bigger things.

## Check Your Work

The model should check:
1. The directory `~/qwen-sandbox/` exists
2. The file `~/qwen-sandbox/hello.txt` exists
3. The file contains "Hello, I'm learning Qwen Code!"
4. The user can explain what happened in their own words

## Debug It

**Something's broken:** Qwen Code loaded but when you asked it to create the file, it just talked about it without actually creating it, or it asked for permission and you didn't know what to do.

**Hint if stuck:** Qwen Code operates in "approval mode" by default. When it wants to do something (like create a file), it will ask for your permission first. You need to approve it.

**Expected fix:** 
1. When Qwen Code asks "Should I proceed?" or shows an approval dialog, type `y` or `yes` to approve
2. If it didn't attempt the action at all, try rephrasing: "Please create a file called hello.txt in the current directory with the text 'Hello, I'm learning Qwen Code!'"
3. If you're in the wrong directory, Qwen Code might be confused. Make sure you ran `cd ~/qwen-sandbox` before launching `qwen`.

## What You Learned

You give Qwen Code tasks in plain language, it asks for permission, you approve, and it does the work.

---

**Module 0 Complete!** You've opened a terminal, installed Qwen Code, and had it create a file. In under 5 minutes.

*Next: Module 1 — What Is Qwen Code? — where you'll understand how it actually works so everything else makes sense.*
