---
title: "Troubleshooting — Qwen Code Course"
---

# Troubleshooting

Common problems and how to fix them.

## Course Installation

### `/course` says "Unknown command"

The course commands aren't installed in your `~/.qwen/` directory yet.

**Fix:**
```bash
cd qwen-code-course
bash scripts/install.sh
```

Then restart Qwen Code.

### Commands are installed but don't work

Restart Qwen Code completely (quit and relaunch). Commands are loaded at startup.

## During Lessons

### Qwen Code won't create/edit files

You're probably in **plan mode**. Check with:
```
/approval-mode
```

If it says `plan`, switch to default:
```
/approval-mode default
```

### Qwen Code can't find my files

Qwen Code looks for files relative to the directory where it was launched.

**Fix:** Either:
1. Launch Qwen Code from the right directory: `cd /path/to/files && qwen`
2. Or use absolute paths in your requests: "Read the file at /full/path/to/file.txt"

### The lesson exercise isn't working

1. Make sure you're in the sandbox directory: `cd ~/qwen-sandbox && qwen`
2. Check that the files from earlier lessons exist
3. If something is broken, try resetting the sandbox:
   ```bash
   rm -rf ~/qwen-sandbox
   # Then in Qwen Code: /course start (it will recreate the sandbox)
   ```

### I made a mistake and want to undo

Use Qwen Code's restore feature:
```
/restore
```

Or just ask Qwen Code: "Undo the last change you made."

## Progress Tracking

### I lost my progress

Your progress is in `~/.qwen/course-progress.json`. If this file was deleted, your progress is gone.

**Prevention:** Back up this file:
```bash
cp ~/.qwen/course-progress.json ~/backups/course-progress.json
```

### I want to start over

```
/course reset
```

This will ask for confirmation and then reset your progress.

## General

### Qwen Code is slow

This is usually a network or model issue, not a course issue. Try:
```
/model
```
to switch models if you have alternatives available.

### I found a bug in a lesson

Great catch! Please report it:
1. Note the lesson number and what went wrong
2. Open an issue at the [GitHub repo](https://github.com/agurrey/qwen-code-course/issues)
3. Or fix it yourself — see [CONTRIBUTING.md](https://github.com/agurrey/qwen-code-course/blob/main/CONTRIBUTING.md)
