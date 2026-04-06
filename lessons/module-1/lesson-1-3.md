---
module: 1
lesson: 3
title: "How Qwen Code Thinks in Tools"
prerequisites: ["1-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 1.3: How Qwen Code Thinks in Tools

> **Time:** ~3 min reading + ~4 min doing

## The Problem

Most beginners talk to Qwen Code like they talk to Google: "how do I find all files ending in .py?" They get an explanation instead of action. The difference between a frustrating experience and a great one is understanding that Qwen Code doesn't answer questions — it **uses tools**.

## Mental Model

When you give Qwen Code a task, here's what happens inside:

1. It reads your request
2. It decides which **tool** to use (there are ~14 built-in tools)
3. It calls the tool and sees the result
4. It decides the next tool (or answers you)
5. Repeat until done

The main tools are:
- **Read** — reads a file's content
- **Write** — creates or modifies files
- **Shell** — runs terminal commands
- **Glob** — finds files matching a pattern
- **Grep** — searches file contents
- **Web Fetch** — retrieves a web page
- **Agent** — launches a sub-agent for complex tasks

You don't pick the tools — Qwen Code does. But you can influence which tools it picks by how you phrase your request.

## Try It

**Your task:** Watch Qwen Code pick and use tools in real time.

1. Set up a practice project:
   ```bash
   mkdir -p ~/qwen-sandbox/tool-demo
   cd ~/qwen-sandbox/tool-demo
   echo "print('hello')" > script.py
   echo "print('world')" > main.py
   echo "some notes" > README.md
   ```

2. Launch Qwen Code:
   ```bash
   qwen
   ```

3. Ask: "Find all Python files in this directory and tell me what's in them."

4. Watch the tool calls. You should see Qwen Code:
   - Use **Glob** (or similar) to find `*.py` files
   - Use **Read** to open each `.py` file
   - Report the contents

5. Now try: "Add a comment at the top of each Python file that says '# Created by Qwen Code course'"

6. Watch it use **Read** (to see current content) then **Write/Edit** (to add the comment).

7. Verify:
   ```bash
   head -1 ~/qwen-sandbox/tool-demo/*.py
   ```
   You should see the comment in each file.

**The insight:** You didn't tell Qwen Code which tools to use. You described what you wanted, and it figured out the tool sequence. The better you describe the outcome, the better its tool choices.

## Check Your Work

The model should check:
1. The user saw Qwen Code use Glob to find files
2. The user saw Qwen Code use Read to open each file
3. The user saw Qwen Code use Write/Edit to modify files
4. The Python files actually have the comment added
5. The user can name at least 3 tools Qwen Code has

## Debug It

**Something's broken:** Qwen Code described what it would do but didn't actually do it, or it used the wrong tool and failed.

**Hint if stuck:** If Qwen Code is in plan mode (`/approval-mode plan`), it will only analyze — it won't execute. Make sure you're in `default` or `auto-edit` mode.

**Expected fix:** 
1. Type `/approval-mode default` to ensure Qwen Code can take actions (with your approval)
2. If it used the wrong tool, rephrase: be more specific about the outcome. Instead of "look at the files," say "read each Python file and show me the content."

## What You Learned

Qwen Code doesn't answer questions — it uses tools to take action. Your job is to describe the outcome clearly enough that it picks the right tools.

---

*Next: Lesson 1.4 — Safety and Approval Modes — understanding when Qwen Code asks permission and how to control it.*
