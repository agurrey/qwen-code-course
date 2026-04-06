---
module: 3
lesson: 1
title: "Organizing Your Workspace"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 3.1: Organizing Your Workspace

> **Time:** ~5 min reading + ~5 min doing

## The Problem

You start a project and dump everything into one folder. Three files later, you can't find what you need. Scripts mix with data, notes sit next to code, and your `sandbox` directory becomes a junk drawer. When you ask Qwen Code to help, it has to wade through everything just to find the relevant file. A messy workspace slows down both you and the AI.

## Mental Model

Your workspace is a filing cabinet, not a junk drawer. Every file has a home. When Qwen Code can see a clean structure, it finds things faster, understands your project's purpose, and gives better answers.

## Try It

**Your task:** Build a clean project structure from scratch, then ask Qwen Code to navigate it.

1. Start fresh:
   ```bash
   mkdir -p ~/qwen-sandbox/my-app/{src,data,docs,scripts,tests}
   cd ~/qwen-sandbox/my-app
   ```

2. Create files in their proper homes:
   ```bash
   echo "# My App" > README.md
   echo 'print("hello from app")' > src/app.py
   echo '{"users": ["alice", "bob"]}' > data/users.json
   echo "This app processes user data." > docs/overview.md
   echo '#!/bin/bash\necho "Running app..."\npython3 src/app.py' > scripts/run.sh
   echo 'def test_app(): pass' > tests/test_app.py
   chmod +x scripts/run.sh
   ```

3. Launch Qwen Code:
   ```bash
   qwen
   ```

4. Ask: "Show me the project structure and explain what each directory is for."
   - Qwen Code will use Glob or file listing to map the structure and explain it.

5. Ask: "Where would I put a new utility function? Where would I put API documentation?"
   - With the structure visible, Qwen Code gives precise answers: `src/` for utility functions, `docs/` for API documentation.

6. Now ask: "Add a `logs/` directory and a `.gitignore` file to this project."
   - Qwen Code creates both in the right places.

7. Verify your structure:
   ```bash
   find ~/qwen-sandbox/my-app -type f | sort
   ```

   You should see files organized across directories, not piled in one place.

## Check Your Work

The model should check:
1. The directory structure includes `src/`, `data/`, `docs/`, `scripts/`, `tests/`, and `logs/`
2. Each directory contains at least one file
3. A `.gitignore` exists at the project root
4. The user can explain why each directory exists and what belongs in it

## Debug It

**Something's broken:** Qwen Code suggests putting a new file in the wrong directory, or you can't remember where something lives.

Look at your actual structure:
```bash
tree ~/qwen-sandbox/my-app 2>/dev/null || find ~/qwen-sandbox/my-app -type f | sort
```

If Qwen Code suggested `src/test_app.py` instead of `tests/test_app.py`, the problem isn't Qwen Code — it's that your structure needs to be clearer. Qwen Code infers conventions from what it sees. If your structure is ambiguous, its guesses will be too.

**Hint if stuck:** Show Qwen Code the structure explicitly. Ask: "Here's my project structure. Based on this, where should new test files go?" — then paste the `find` output. This gives Qwen Code the context it needs.

**Expected fix:** Be explicit about conventions. Create an empty `tests/README.md` that says "All test files go here" if needed. The clearer the structure, the better Qwen Code navigates it.

## What You Learned

A clean workspace with purpose-built directories helps Qwen Code find files quickly and give accurate guidance.

---

*Next: Lesson 3.2 — Multi-file Projects — where you'll learn to create related files that work together and understand how Qwen Code tracks connections between them.*
