---
module: 0
lesson: 1
title: "Your First Terminal"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 0.1: Your First Terminal

> **Time:** ~2 min reading + ~3 min doing

## The Problem

You've heard about "terminal" and "command line" — words people throw around like you should already know them. You don't. That's okay. This lesson fixes that in 3 minutes.

## Mental Model

The terminal is just a text box where you type instructions to your computer. That's it. The graphical interface you're used to (clicking icons, dragging files) is just a prettier version of the same thing. The terminal is faster and more powerful — you're removing the middleman.

## Try It

**Your task:** Open your terminal and type your first command.

1. Open the terminal application on your computer:
   - **Linux:** Press `Ctrl+Alt+T`, or search for "Terminal" in your apps
   - **Mac:** Press `Cmd+Space`, type "Terminal", press Enter
   - **Windows:** Search for "PowerShell" or "Command Prompt"

2. You should see something like this:
   ```
   username@computer:~$
   ```
   This is called a **prompt**. It means the computer is waiting for you.

3. Type this and press Enter:
   ```bash
   whoami
   ```

4. You should see your username printed back:
   ```
   agurrey
   ```

Congratulations. You just gave your computer an instruction through text. That's all a terminal ever does.

## Check Your Work

The model should check:
1. The user can describe what they see when they open their terminal (prompt, username, cursor)
2. The user successfully ran `whoami` and saw output
3. The user can explain in their own words what `whoami` did ("it told me my username")

## Debug It

**Something's broken:** You type `whoami` and get an error like:
```
command not found: whoami
```

Or nothing happens at all.

**Hint if stuck:** The terminal only runs commands you type followed by pressing Enter. If nothing happens, you probably didn't press Enter. If you get an error, check that you typed it exactly: `whoami` (all lowercase, no spaces).

**Expected fix:** Type `whoami` exactly — all lowercase, no spaces — then press Enter.

## What You Learned

The terminal is a text box where you type commands to your computer. `whoami` tells you your username.

---

*Next: Lesson 0.2 — Getting Qwen Code running — where you install the AI that lives in your terminal.*
