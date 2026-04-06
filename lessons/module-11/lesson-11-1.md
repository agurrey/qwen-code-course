---
module: 11
lesson: 1
title: "Choosing Your Project"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You want to build something real with Qwen Code, but picking the wrong project kills momentum. Too small (a "hello world" script) and you learn nothing new. Too big (a full SaaS platform) and you'll drown in scope before finishing. The right first project is one you actually need, scoped small enough to finish in a session or two, and complex enough to use the skills from all ten previous modules.

## Mental Model

Your first project should be a **real problem from your actual work or life** — something small enough to solve in an afternoon but meaningful enough that solving it saves you time every week. Real stakes keep you motivated; small scope keeps you from drowning.

## Try It

You'll identify, evaluate, and scope a project that hits the sweet spot.

### What makes a good first project

A good first project for learning Qwen Code has these characteristics:

1. **You actually need it** — not a tutorial exercise, something that solves a real problem you have right now
2. **It's under 500 lines of code** — small enough to hold in your head, big enough to have structure
3. **It has clear boundaries** — you can define exactly what's in and what's out
4. **It uses at least three skills from the course** — commands, tools, hooks, memory, MCP, file operations, etc.
5. **It produces a visible result** — something you can run, read, or interact with

### Good project examples

Here are real projects that hit the sweet spot:

**A script that checks your server's health and sends a summary to your chat.** You need this because you keep manually SSH-ing in to check. It's about 100 lines of Python, uses shell commands, environment variables, and could benefit from hooks (protecting API keys) and memory (your server addresses).

**A CLI tool that formats and organizes data from an API you use regularly.** Maybe it's a tool that pulls your project's open issues and shows them grouped by label. About 150 lines, uses MCP or API connections, file I/O, and benefits from QWEN.md (API conventions).

**A small web scraper that monitors a page for changes and emails you.** You need this because you keep checking manually. About 200 lines, uses file I/O, scheduling, email, and hooks (rate limiting, error handling).

**A config generator for your deployment pipeline.** You're tired of writing the same YAML structure. About 100 lines of Python or a template system, uses file I/O, and benefits from MEMORY.md (your deployment conventions).

**A log analyzer that reads your app's logs and reports the top errors.** About 150 lines, uses file reading, regex patterns, and produces a visible report. Benefits from hooks (never modifying original log files).

### Bad first projects (save these for later)

Avoid these for your first project:

- **A full web application with auth, database, and frontend** — too many moving parts, you'll spend sessions on setup, not building
- **A mobile app** — Qwen Code's strengths are in backend and scripting, not mobile toolchains
- **A library for other people to use** — API design and documentation is a different skill set
- **A rewrite of an existing large codebase** — too much context, too many edge cases
- **"I'll figure out what to build as I go"** — no scope means no finish line

### Pick from your actual work

The best project comes from your real life. Think about:

- What task do you repeat more than once a week?
- What file do you keep editing by hand that could be generated?
- What monitoring or checking do you do manually?
- What report do you generate that could be automated?
- What setup step do you forget and have to look up?

Each of these is a project. Pick the smallest one.

### Scoping your project

Once you've picked an idea, scope it down until it fits. Use this framework:

```
Project: [name]
In scope:
  - [Thing 1: specific, bounded]
  - [Thing 2: specific, bounded]
  - [Thing 3: specific, bounded]
Out of scope:
  - [Thing that would expand the project]
  - [Nice-to-have that can wait]
Deliverable: [exactly what exists when done]
```

Example:

```
Project: Server health checker
In scope:
  - Check if 3 servers respond to HTTP requests
  - Check if disk usage is under 90%
  - Send a summary message to a chat webhook
  - Run as a cron job
Out of scope:
  - Web dashboard (would need frontend framework)
  - Historical data / graphs (would need a database)
  - Alert escalation (would need more integrations)
Deliverable: A Python script that checks servers and sends results, plus a crontab entry
```

When everything in "In scope" is done, the project is done. No creeping scope, no "just one more feature."

### Set up your project directory

Create your project directory with good structure from the start:

```bash
mkdir -p ~/projects/your-project-name && cd ~/projects/your-project-name
```

Initialize it with the basics:

```bash
git init
mkdir -p src tests
touch src/__init__.py tests/__init__.py
```

Set up your QWEN.md so Qwen Code knows about this project:

```markdown
# Server Health Checker

## What This Is
A Python script that checks server health and sends summaries.

## Structure
```
src/
├── checker.py      # Health check logic
├── notifier.py     # Notification sending
└── config.py       # Configuration from env vars
tests/
├── test_checker.py
└── test_notifier.py
```

## Conventions
- All config from environment variables (no hardcoded values)
- Tests use pytest with mocked HTTP calls
- Script exits 0 on success, 1 on any failure
- Output is JSON summary to stdout plus optional webhook notification
```

Set up hooks to protect against common mistakes:

```bash
mkdir -p .qwen/hooks
```

```yaml
# .qwen/hooks/protect-secrets.yaml
name: protect-secrets
description: Block committing or displaying secret values
type: pre-action
pattern: "(API_KEY|SECRET|PASSWORD|TOKEN)"
action: warn
message: "Secret value detected. Make sure this isn't being hardcoded — use environment variables."
```

## Check Your Work

1. Write out your project scope document using the framework above. If you can't fill in all sections, your project isn't scoped tightly enough.

2. Verify your project directory has:
```bash
ls -la
```
Should show: `.git/`, `src/`, `tests/`, `QWEN.md`, `.qwen/hooks/`

3. Ask yourself: "Can I describe the deliverable in one sentence?" If not, scope it down further.

## Debug It

1. **"I can't think of a real project I need."** Then build something small and useful for fun:
   - A tool that generates passwords
   - A script that renames files in bulk
   - A CLI that shows the weather
   These aren't work projects but they're real tools that produce real output.

2. **"My project is growing as I think about it."** This is normal. Every new idea goes in the "Out of scope" list. You can always build a v2 later. The discipline of finishing a small project is more valuable than starting a big one.

3. **"I already started building something and it's a mess."** That's fine — this module isn't about greenfield projects. Apply the scoping framework to what you have: define what "done" looks like, declare everything else out of scope, and finish what you started.

## What You Learned

A good first project is a real problem from your life, scoped small enough to finish in a session or two, with clear boundaries between what's in and what's out.

*Next: Lesson 11.2 — Planning with Qwen Code — You'll use Qwen Code's planning capabilities to break down your project into concrete steps and set up the complete file structure before writing any code.*
