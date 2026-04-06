---
module: 11
lesson: 4
title: "Shipping It"
prerequisites: ["module-11/lesson-11-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

Your project works on your machine, in your terminal, at this exact moment. But "works" isn't shipped. Shipped means someone else can clone it, run it, and get the same result. Shipped means it has a README, clean git history, and a way to deploy. Shipping is the difference between a project that lives on your laptop and one that actually exists in the world.

## Mental Model

Shipping is **packaging, not polishing** — you're not making the code prettier, you're making it reproducible. A shipped project has everything another person (or future you at 2am) needs to understand it, run it, and trust it, without asking you a single question.

## Try It

You'll take your built project through the complete shipping process: git preparation, README creation, deployment setup, and publication.

### Step 1: Clean up your git history

Your commit history from the implementation phase is probably messy — "fix typo," "oops," "actually this time." That's fine for development but not for a shipped project. Clean it up:

```bash
git log --oneline
```

You'll see something like:

```
a1b2c3d fix typo in config
e4f5g6h actually handle the edge case
i7j8k9l add tests for checker
m9n0o1p implement checker
q2r3s4t implement config
u5v6w7x initial structure
```

For a clean shipped project, squash these into logical commits. Use interactive rebase:

```bash
git rebase -i HEAD~7
```

This opens an editor. Change `pick` to `squash` (or `s`) for commits you want to merge into the one above them. Aim for 3-5 logical commits:

```
pick u5v6w7x Initial project structure
pick q2r3s4t Implement config module with env var parsing
pick m9n0o1p Implement health checker and notifier modules
pick i7j8k9l Add comprehensive test suite
pick e4f5g6h Add run.py entry point and integration
```

Save and exit. Git rewrites the history with clean commits.

If rebasing feels too risky, skip this step. A working project with messy history is better than a broken project with clean history.

### Step 2: Write a README that actually helps

Your README is the first thing anyone sees. It needs to answer three questions in under 30 seconds: what is this, how do I run it, how do I contribute.

Ask Qwen Code to generate it:

```
Write a README.md for this project. It should include:
- Project name and one-sentence description
- Prerequisites (Python version, dependencies)
- Quick start: exactly what commands to run to get it working
- Environment variables needed (with examples)
- How to run tests
- Example output
- License note
```

Qwen Code will generate something like:

```markdown
# Server Health Checker

A lightweight Python script that checks server health and disk usage, then sends a summary notification via webhook.

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export SERVER_URLS="http://server1:8080,http://server2:8080"
export DISK_THRESHOLD=90
export WEBHOOK_URL="https://hooks.example.com/notify"

# Run the checker
python run.py
```

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `SERVER_URLS` | Yes | Comma-separated list of server URLs to check |
| `DISK_THRESHOLD` | No | Disk usage percentage threshold (default: 90) |
| `WEBHOOK_URL` | No | Webhook URL for notifications (skip to print only) |

## Running Tests

```bash
pip install pytest
pytest tests/ -v
```

## Output

On success, prints JSON summary to stdout and exits with code 0:

```json
{"servers": {"http://server1:8080": true}, "disk": true, "all_ok": true}
```

On failure, exits with code 1.
```

Review the generated README. Fix any inaccuracies. Make sure the quick start actually works if someone follows it step by step.

### Step 3: Add a .gitignore

Make sure you're not committing garbage:

```bash
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*.egg-info/
dist/
build/
.eggs/

# Virtual environments
.venv/
venv/

# Environment files (contain secrets)
.env
.env.*

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db
EOF
```

Verify nothing important is being ignored:

```bash
git status
```

Should show only your source files, tests, config files, and README — no cache files, no virtual environment, no `.env`.

### Step 4: Tag the release

Mark this as your first release:

```bash
git tag -a v0.1.0 -m "Initial release: server health checker"
git tag -l
```

Tags are permanent markers in your git history. When you add features later, you'll tag v0.2.0, v1.0.0, etc. Tags answer the question: "what version am I running?"

### Step 5: Set up deployment (if applicable)

How your project gets deployed depends on what it is. Common patterns:

**For a script that runs on a server:**

```bash
# Create a simple deployment script
cat > deploy.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# Copy to server
scp run.py src/ requirements.txt user@server:/opt/health-checker/

# Install dependencies on server
ssh user@server "cd /opt/health-checker && pip install -r requirements.txt"

# Set up cron (runs every 5 minutes)
ssh user@server "echo '*/5 * * * * cd /opt/health-checker && python run.py' | crontab -"
EOF

chmod +x deploy.sh
```

**For a project that runs as a web service:**

Ask Qwen Code to create a Dockerfile:

```
Create a Dockerfile for this project. Use a minimal Python base image, install dependencies, and set the entrypoint to run.py.
```

```dockerfile
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ src/
COPY run.py .

CMD ["python", "run.py"]
```

Build and test it:

```bash
docker build -t health-checker:latest .
docker run --rm \
  -e SERVER_URLS="http://localhost:8080" \
  -e DISK_THRESHOLD=90 \
  health-checker:latest
```

### Step 6: Push to a remote repository

Make your project accessible to others:

```bash
# Create a repo on GitHub (via web interface), then:
git remote add origin https://github.com/yourusername/health-checker.git
git push -u origin main
git push --tags
```

The `--tags` pushes your version tags. Without it, tags only exist locally.

### Step 7: Verify the shipped product

Clone your project fresh in a temporary directory and verify it works as a stranger would experience it:

```bash
SANDBOX=$(mktemp -d)
git clone https://github.com/yourusername/health-checker.git "$SANDBOX"
cd "$SANDBOX"
cat README.md
pip install -r requirements.txt
pytest tests/ -v
```

If anything fails, that's a bug in your shipping, not your code. Fix it, commit the fix, and try again.

### Step 8: Reflect on what you built

Look at everything that went into this project:

- **Module 1-2**: You can navigate a terminal and understand what commands do
- **Module 3-4**: You can create, read, edit, and search files with Qwen Code
- **Module 5**: You can use Qwen Code's specialized tools (grep, glob, etc.)
- **Module 6**: You can write and use custom commands
- **Module 7**: You can install and invoke skills for specialized tasks
- **Module 8**: You can connect MCP servers and external services
- **Module 9**: You have hooks and approval modes preventing disasters
- **Module 10**: You have memory files that make Qwen Code know your preferences
- **Module 11**: You planned, built, and shipped a real project

Every skill from this course is now in your toolkit. You didn't just learn about Qwen Code — you used it to create something that didn't exist before.

### What to do next

This is the end of the course but not the end of your Qwen Code journey. Here's what to do now:

1. **Keep using it** — Every coding task is a chance to practice. Use Qwen Code for your next work task, side project, or automation.

2. **Contribute back** — If you found a better way to explain something, or discovered a tip worth sharing, submit a lesson or improvement to the course: https://github.com/agurrey/qwen-code-course

3. **Teach someone** — The best way to solidify your knowledge is to explain it. Share this course with someone who needs it.

4. **Build something bigger** — Your first project was scoped small on purpose. Now take on something that stretches your skills.

## Check Your Work

1. Your project has a clean git history:

```bash
git log --oneline
```

3-5 logical commits, no "fix typo" noise.

2. README.md exists and a stranger could follow the quick start:

```bash
cat README.md
```

3. .gitignore covers Python artifacts, env files, and IDE files:

```bash
cat .gitignore
```

4. Tests still pass:

```bash
pytest tests/ -v
```

5. The project is pushed to a remote:

```bash
git remote -v
git push
```

6. Fresh clone works:

```bash
SANDBOX=$(mktemp -d) && git clone <your-repo-url> "$SANDBOX" && cd "$SANDBOX" && pip install -r requirements.txt && pytest tests/ -v
```

## Debug It

1. **"Fresh clone fails because of missing dependencies."** You forgot to add a dependency to requirements.txt. Check what's imported in your code but not listed:

```bash
grep -rh "^import\|^from" src/ | awk '{print $2}' | cut -d. -f1 | sort -u
```

Compare this to requirements.txt and add missing entries.

2. **"The README quick start doesn't work."** Follow it yourself, literally copy-pasting each command. Note exactly where it fails and fix the README. The README is documentation — if it's wrong, it's a bug.

3. **"I pushed but the tags didn't go up."** Tags need a separate push:

```bash
git push --tags
```

Verify on GitHub that the tag appears in the releases section.

4. **"The Docker container can't connect to the network."** Docker containers run in an isolated network. If your script needs to reach external URLs, ensure the container has DNS configured. The `python:3.12-slim` image includes basic DNS, but if you're behind a corporate proxy, you may need to pass proxy settings:

```bash
docker run --rm -e HTTP_PROXY=$HTTP_PROXY -e HTTPS_PROXY=$HTTPS_PROXY health-checker:latest
```

## What You Learned

Shipping means making your project reproducible and accessible — clean git history, a working README, proper ignores, version tags, and a verified fresh clone.

**Module 11 Complete!**

You went from a scoped idea to a shipped, deployed project — planning the architecture, implementing it task by task, and packaging it so anyone can clone and run it.

**Module 11 Complete!**

You've completed the Qwen Code Course!

You went from zero terminal knowledge to building real projects. You understand how Qwen Code works, how to use all its tools, how to extend it with commands and skills, and how to connect external services.

**What to do next:**
- Generate your personalized cheat sheet: /course cheatsheet
- Start a real project with everything you've learned
- Contribute a lesson back to the course: https://github.com/agurrey/qwen-code-course
- Share the course with someone who needs it
