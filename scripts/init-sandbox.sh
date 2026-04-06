#!/bin/bash
# init-sandbox.sh — Create the Qwen Code practice sandbox
# Run once during course setup. Safe to re-run (idempotent).

set -e

SANDBOX="$HOME/qwen-sandbox"

# Create sandbox directory structure
mkdir -p "$SANDBOX/practice"
mkdir -p "$SANDBOX/exercises"
mkdir -p "$SANDBOX/experiments"

# Create README
cat > "$SANDBOX/README.md" << 'EOF'
# Qwen Code Sandbox

This is your safe space to experiment with Qwen Code.

## Directories

- `practice/` — Free play. Create, modify, and delete files here without worry.
- `exercises/` — Course exercises will be placed here.
- `experiments/` — Try things that might break. Nothing outside this directory matters.

## Rules

- Nothing outside `~/qwen-sandbox/` should be modified by course exercises
- You can reset this directory anytime by deleting it and re-running `/course start`
- Files here are NOT backed up or version-controlled — they're disposable

Happy breaking! 🔧
EOF

# Create a starter exercise file
cat > "$SANDBOX/exercises/README.md" << 'EOF'
# Exercises

Course exercises will create files in this directory.
Each exercise produces a visible output file or terminal result.
EOF

echo "Sandbox created at: $SANDBOX"
echo "Directories created:"
echo "  - $SANDBOX/practice/"
echo "  - $SANDBOX/exercises/"
echo "  - $SANDBOX/experiments/"
echo ""
echo "This is your safe space for Qwen Code experiments."
