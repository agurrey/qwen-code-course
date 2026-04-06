---
module: 9
lesson: 5
title: "Production Safety"
prerequisites: ["module-9/lesson-9-4"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

Your team wants to use Qwen Code in the CI/CD pipeline to automate code reviews and generate changelogs. But running Qwen Code non-interactively means no human is watching each action. A misconfigured hook, an overly broad pattern, or a misunderstood instruction could push broken code to production. You need to run Qwen Code safely when nobody is sitting at the keyboard.

## Mental Model

Production safety for Qwen Code is the same principle as production safety for anything else: **automate the checks, restrict the blast radius, and log everything**. You don't need a human watching — you need guardrails so strong that mistakes either can't happen or get caught before they matter.

## Try It

You'll set up Qwen Code for safe non-interactive use, configure CI/CD integration, and build an audit trail.

### Non-interactive mode

Qwen Code can run in non-interactive mode, where it processes input without a human at the terminal. This is how you use it in scripts, CI/CD pipelines, and automated workflows.

Start Qwen Code with the `--yolo` flag for fully automated mode:

```bash
qwen --yolo -p "Read all files in src/ and generate a summary in SUMMARY.md"
```

The `-p` flag passes a prompt directly. Qwen Code executes it and exits.

**Critical safety rule**: Never run non-interactive Qwen Code with write access to production directories. Always use one of these strategies:

### Strategy 1: Sandboxed execution

Run Qwen Code in an isolated directory where it can't touch anything important:

```bash
#!/bin/bash
# ci-qwen-review.sh

# Create a fresh sandbox
SANDBOX=$(mktemp -d /tmp/qwen-ci-XXXXXX)
trap "rm -rf $SANDBOX" EXIT

# Clone the repo into the sandbox
git clone --depth 1 https://github.com/myorg/myproject.git "$SANDBOX"
cd "$SANDBOX"

# Run Qwen Code with read-only intent
qwen --yolo -p "Review all changes in the last 24 hours and write a summary to REVIEW.md"

# The sandbox is destroyed on exit (trap above)
# The only artifact is REVIEW.md which you can inspect
```

The `trap` command ensures cleanup happens even if the script fails. `mktemp -d` creates a unique temporary directory. `--depth 1` clones only the latest commit (faster, less data).

### Strategy 2: Read-only hooks for CI

In CI/CD, Qwen Code should primarily read and analyze, not modify. Write hooks that enforce this:

```yaml
# .qwen/hooks/ci-read-only.yaml
name: ci-read-only
description: Block write operations in CI mode
type: pre-action
pattern: "(write|edit|delete|rm|mv|cp|create).*(file|directory)"
action: block
message: |
  Blocked: Write operation in CI mode.
  
  CI pipelines should only read and analyze code.
  To write files, use a dedicated build step, not Qwen Code.
  
  Allowed: read, search, analyze, test, lint
```

Set the CI mode via an environment variable:

```bash
export QWEN_CI_MODE=1
```

Then reference this in your hooks or settings to enforce read-only behavior.

### Strategy 3: Audit logging

Every non-interactive run of Qwen Code should produce an audit log. Create a wrapper script:

```bash
#!/bin/bash
# qwen-audit.sh — Run Qwen Code with full audit logging

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_DIR=".qwen/audit"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/session-${TIMESTAMP}.log"

{
  echo "=== Qwen Code Audit Log ==="
  echo "Timestamp: $(date -Iseconds)"
  echo "User: $(whoami)"
  echo "Directory: $(pwd)"
  echo "Command: qwen $@"
  echo "=========================="
  echo ""
} > "$LOG_FILE"

# Run Qwen Code and capture output
qwen "$@" 2>&1 | tee -a "$LOG_FILE"

{
  echo ""
  echo "=== Session End ==="
  echo "End time: $(date -Iseconds)"
  echo "Files modified:"
  git diff --name-only 2>/dev/null || echo "(not a git repo or no changes)"
  echo "================="
} >> "$LOG_FILE"

echo "Audit log saved to $LOG_FILE"
```

Usage:

```bash
./qwen-audit.sh --yolo -p "analyze the codebase and report issues"
```

This creates a timestamped log file with everything Qwen Code saw and did during the session.

### CI/CD integration example: GitHub Actions

Here's a GitHub Actions workflow that runs Qwen Code safely on every pull request:

```yaml
# .github/workflows/qwen-review.yml
name: Qwen Code Review
on:
  pull_request:
    branches: [main]

jobs:
  qwen-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Qwen Code
        run: |
          npm install -g @anthropic/qwen-code

      - name: Run Qwen Code analysis
        env:
          QWEN_CI_MODE: 1
        run: |
          qwen --yolo -p "
            Analyze this codebase for:
            1. Security vulnerabilities
            2. Performance issues
            3. Code style inconsistencies
            Write findings to QWEN-REVIEW.md
          "

      - name: Upload review
        uses: actions/upload-artifact@v4
        with:
          name: qwen-review
          path: QWEN-REVIEW.md
```

This workflow:
1. Checks out the PR branch
2. Installs and runs Qwen Code in a sandboxed CI runner
3. Produces a review file as an artifact
4. Cannot modify the actual PR — it only generates a report

### Production deployment safety

If you must let Qwen Code touch production systems, use this pattern:

1. **Two-phase approval**: Qwen Code generates the changes in a sandbox, a human reviews them, then a separate CI step applies them.

```bash
# Phase 1: Generate changes in sandbox
SANDBOX=$(mktemp -d)
cd "$SANDBOX"
qwen --yolo -p "update the deployment config for v2.0"

# Phase 2: Human reviews the changes
diff /prod/config/deploy.yaml "$SANDBOX/config/deploy.yaml"

# Phase 3: If approved, apply through normal CI/CD
cp "$SANDBOX/config/deploy.yaml" /tmp/staging-deploy/
# Normal CI/CD picks it up and deploys with its own safeguards
```

2. **Never let Qwen Code push directly to production**. Always push to a branch or PR, and let your normal deployment pipeline handle the rest.

### Compliance and audit trails

If your organization requires audit trails (SOC2, HIPAA, etc.), Qwen Code's logs are part of your evidence:

```bash
# List all Qwen Code sessions
ls -la .qwen/audit/

# Show what changed in a specific session
cat .qwen/audit/session-20250401-143022.log

# Verify no unauthorized changes were made
git log --since="2025-04-01" --until="2025-04-02" --author="qwen"
```

Store audit logs alongside your other compliance artifacts:

```bash
# Archive old logs
mkdir -p .qwen/audit/archive
mv .qwen/audit/session-*.log .qwen/audit/archive/
```

### The production safety checklist

Before running Qwen Code in any automated or production-adjacent context:

- [ ] Running in an isolated sandbox (tmpdir, container, CI runner)
- [ ] Read-only hooks are in place
- [ ] Audit logging is enabled
- [ ] No direct write access to production paths
- [ ] Changes go through normal CI/CD review process
- [ ] Hook files are committed and reviewed
- [ ] `.qwenignore` covers sensitive paths
- [ ] Approval mode is set appropriately (yolo only in sandboxes)

## Check Your Work

1. Create and test the audit wrapper script:

```bash
mkdir -p /tmp/ci-test && cd /tmp/ci-test
# Create the qwen-audit.sh script from above
chmod +x qwen-audit.sh
./qwen-audit.sh --yolo -p "list files in the current directory"
cat .qwen/audit/session-*.log
```

2. Verify the audit log contains: timestamp, command run, output, files modified, session end time.

3. Test sandbox cleanup:

```bash
ls /tmp/qwen-ci-*  # Should not exist after the script exits (trap cleaned up)
```

## Debug It

1. **"Qwen Code hangs in non-interactive mode."** This usually means it's waiting for input despite `--yolo`. Check if there's a hook that's set to `warn` — warn hooks still prompt for acknowledgment. In CI mode, change all `warn` hooks to `notify` so they don't block execution.

2. **"The audit log is empty."** The `tee` command may not be capturing Qwen Code's output if it writes to stderr separately. Fix the script:

```bash
qwen "$@" >> "$LOG_FILE" 2>&1
```

The `2>&1` redirects stderr to stdout, so everything goes into the log.

3. **"CI runner can't find hook files."** The hooks are in your local `.qwen/hooks/` but the CI runner clones a fresh copy. Make sure `.qwen/` is committed to the repository:

```bash
git add .qwen/ && git commit -m "Add Qwen Code config for CI"
```

## What You Learned

Production safety for Qwen Code means sandboxed execution, read-only hooks in CI, comprehensive audit logging, and never letting automated actions bypass your normal review process.

**Module 9 Complete!**

You now understand hooks as automatic safety checkpoints, approval modes as friction dials, and production safety as layered defense. You can write hooks that prevent real disasters, choose the right approval mode for each task, and run Qwen Code safely in automated pipelines.

*Next: Module 10 — Memory & Context — You'll learn how Qwen Code remembers things across sessions, how to write your own memory files, and how to manage project-specific instructions that shape how Qwen Code behaves.*
