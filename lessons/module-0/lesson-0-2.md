---
module: 0
lesson: 2
title: "Installing Qwen Code"
prerequisites: ["0-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 0.2: Installing Qwen Code

> **Time:** ~2 min reading + ~3 min doing

## The Problem

You have a terminal. Now you need Qwen Code — an AI coding assistant that runs inside your terminal and helps you read, write, and modify files, run commands, and solve problems. Think of it as a very patient expert sitting next to you, but you communicate through text.

## Mental Model

Qwen Code is a program you install once. After that, you "talk" to it by typing in the terminal, and it "responds" by taking actions (reading files, writing code, running commands) and explaining what it did. It's not a chatbot — it's a pair of hands and a brain for your computer.

## Try It

**Your task:** Install Qwen Code using npm (Node.js package manager).

1. First, check if you have Node.js installed. Type:
   ```bash
   node --version
   ```
   You should see something like `v20.x.x` or `v24.x.x`. If you see an error, you need to install Node.js first.

2. If Node.js is not installed, install it with this command:
   ```bash
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
   ```
   Then close and reopen your terminal, and run:
   ```bash
   nvm install node
   ```

3. Install Qwen Code globally:
   ```bash
   npm install -g @qwen-code/qwen-code
   ```
   You'll see installation progress. Wait for it to finish.

4. Launch Qwen Code:
   ```bash
   qwen
   ```
   You should see the Qwen Code welcome screen and an input prompt. You're in.

5. Type `/quit` to exit for now.

## Check Your Work

The model should check:
1. The user has Node.js installed (`node --version` returns a version)
2. The user ran `npm install -g @qwen-code/qwen-code` successfully
3. The user launched Qwen Code with `qwen` and saw the welcome screen
4. The user can explain what Qwen Code is in one sentence

## Debug It

**Something's broken:** You try to run `qwen` and get:
```
command not found: qwen
```

**Hint if stuck:** When you install a global npm package, the command goes into your PATH. If the terminal can't find it, either the installation failed or your PATH doesn't include the npm global bin directory.

**Expected fix:** 
1. Run `npm list -g @qwen-code/qwen-code` to check if it installed
2. If it shows the package, run `npm config get prefix` to find where global packages go
3. That directory's `bin/` subfolder needs to be in your PATH. Add this to your `~/.bashrc` or `~/.zshrc`:
   ```bash
   export PATH="$(npm config get prefix)/bin:$PATH"
   ```
4. Then run `source ~/.bashrc` (or `source ~/.zshrc`) and try `qwen` again.

## What You Learned

Qwen Code installs with one npm command and launches with `qwen`.

---

*Next: Lesson 0.3 — Your first Qwen interaction — where you'll give it a real task and watch it work.*
