#!/bin/bash
# install.sh — Copy course commands and skills into ~/.qwen/
# Run after cloning the repo to activate the course.

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
QWEN_DIR="$HOME/.qwen"

echo "Installing Qwen Code Course..."

# Create directories if they don't exist
mkdir -p "$QWEN_DIR/commands/course"
mkdir -p "$QWEN_DIR/skills/qwen-tutor"

# Copy commands
echo "  Installing commands..."
cp "$REPO_DIR/commands/course.md" "$QWEN_DIR/commands/course.md"
cp "$REPO_DIR/commands/course/start.md" "$QWEN_DIR/commands/course/start.md"
cp "$REPO_DIR/commands/course/next.md" "$QWEN_DIR/commands/course/next.md"
cp "$REPO_DIR/commands/course/status.md" "$QWEN_DIR/commands/course/status.md"
cp "$REPO_DIR/commands/course/test-out.md" "$QWEN_DIR/commands/course/test-out.md"
cp "$REPO_DIR/commands/course/cheatsheet.md" "$QWEN_DIR/commands/course/cheatsheet.md"

# Copy skills
echo "  Installing skills..."
cp "$REPO_DIR/skills/qwen-tutor/SKILL.md" "$QWEN_DIR/skills/qwen-tutor/SKILL.md"

# Create progress file if it doesn't exist
if [ ! -f "$QWEN_DIR/course-progress.json" ]; then
    echo "  Creating progress tracker..."
    cat > "$QWEN_DIR/course-progress.json" << 'EOF'
{
  "version": 1,
  "course_version": "v0.1.0",
  "started_at": null,
  "last_active": null,
  "initial_assessment": {
    "terminal_experience": null,
    "ai_experience": null,
    "first_goal": null,
    "skipped_modules": []
  },
  "modules": {},
  "total_lessons_completed": 0,
  "total_lessons": 60,
  "stagnant_since": null,
  "ad_hoc_topics": []
}
EOF
fi

# Run sandbox setup
if [ ! -d "$HOME/qwen-sandbox" ]; then
    echo "  Setting up sandbox..."
    bash "$REPO_DIR/scripts/init-sandbox.sh"
fi

echo ""
echo "Course installed!"
echo ""
echo "Restart Qwen Code and type: /course start"
echo ""
echo "To update in the future: git pull && bash scripts/install.sh"
