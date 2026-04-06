---
module: 3
lesson: 5
title: "Project Templates"
prerequisites: ["module-3/lesson-3-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 3.5: Project Templates

> **Time:** ~5 min reading + ~5 min doing

## The Problem

Every time you start a new Python project, you create the same directories, the same `__init__.py` files, the same `README.md` skeleton, the same `.gitignore`. You do this manually, from memory, every single time. It takes five minutes each project, but it adds up — and you always forget something. Project templates solve this once and reuse forever.

## Mental Model

A project template is a recipe. Instead of remembering every step, you store a reference structure once and tell Qwen Code to scaffold new projects from it. You describe the project type, Qwen Code generates the full structure with placeholder content, and you customize from there.

## Try It

**Your task:** Create a reusable project template and use it to generate new projects.

1. Set up a template project:
   ```bash
   mkdir -p ~/qwen-sandbox/templates/python-project
   cd ~/qwen-sandbox/templates/python-project
   ```

2. Create the template structure with placeholder files:
   ```bash
   mkdir -p src tests docs scripts

   cat > README.md << 'EOF'
   # {{PROJECT_NAME}}

   {{DESCRIPTION}}

   ## Installation
   ```bash
   pip install -r requirements.txt
   ```

   ## Usage
   ```bash
   python3 -m src.main
   ```
   EOF

   cat > src/__init__.py << 'EOF'
   # {{PROJECT_NAME}} source code
   EOF

   cat > src/main.py << 'EOF'
   def main():
       print("Hello from {{PROJECT_NAME}}!")

   if __name__ == "__main__":
       main()
   EOF

   cat > tests/__init__.py << 'EOF'
   EOF

   cat > tests/test_main.py << 'EOF'
   from src.main import main

   def test_main(capsys):
       main()
       captured = capsys.readouterr()
       assert "Hello from" in captured.out
   EOF

   cat > requirements.txt << 'EOF'
   # Add dependencies here
   EOF

   cat > .gitignore << 'EOF'
   __pycache__/
   *.pyc
   .venv/
   *.egg-info/
   dist/
   build/
   EOF

   cat > Makefile << 'EOF'
   .PHONY: test run clean

   test:
   	python3 -m pytest tests/

   run:
   	python3 -m src.main

   clean:
   	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
   	find . -type f -name "*.pyc" -delete 2>/dev/null || true
   EOF
   ```

3. Launch Qwen Code:
   ```bash
   qwen
   ```

4. Ask: "Create a new project called 'weather-api' in ~/qwen-sandbox/ using the template at ~/qwen-sandbox/templates/python-project/. Replace {{PROJECT_NAME}} with 'weather-api' and {{DESCRIPTION}} with 'A REST API for fetching weather data.'"

5. Qwen Code will:
   - Copy the entire template structure
   - Replace `{{PROJECT_NAME}}` with `weather-api`
   - Replace `{{DESCRIPTION}}` with the description
   - Create the project at the target path

6. Verify the new project:
   ```bash
   find ~/qwen-sandbox/weather-api -type f | sort
   cat ~/qwen-sandbox/weather-api/README.md
   ```

   You should see the full structure with `weather-api` substituted everywhere.

7. Create a second project to prove the template is reusable:
   - Ask Qwen Code: "Now create 'todo-cli' using the same template, description: 'A command-line todo list manager.'"

## Check Your Work

The model should check:
1. The template directory exists at `~/qwen-sandbox/templates/python-project/`
2. The template contains all required files: `README.md`, `src/__init__.py`, `src/main.py`, `tests/__init__.py`, `tests/test_main.py`, `requirements.txt`, `.gitignore`, `Makefile`
3. `~/qwen-sandbox/weather-api/` exists with all files and `weather-api` substituted for `{{PROJECT_NAME}}`
4. `~/qwen-sandbox/todo-cli/` exists with `todo-cli` substituted
5. The user can explain how templates save time compared to manual project setup

## Debug It

**Something's broken:** Qwen Code missed some placeholder replacements, or the new project is missing files compared to the template.

Check for unreplaced placeholders:
```bash
grep -r '{{' ~/qwen-sandbox/weather-api/
```

If you find any `{{PROJECT_NAME}}` still in the files, Qwen Code missed some replacements. This happens when the project has many files and Qwen Code doesn't track every substitution.

**Hint if stuck:** Tell Qwen Code to be systematic. Say: "Copy every file from the template, and in each file, replace {{PROJECT_NAME}} with weather-api and {{DESCRIPTION}} with the description. Then list every file you created so I can verify."

**Expected fix:** If replacements are missed, ask Qwen Code to fix them specifically: "In the weather-api project, replace all remaining {{PROJECT_NAME}} with weather-api." You can also ask it to list all files and verify each one.

For a more robust approach, create a shell-based scaffolding script:
```bash
cat > ~/qwen-sandbox/templates/new-project.sh << 'BASH'
#!/bin/bash
NAME="$1"
DESC="$2"
DEST="~/qwen-sandbox/$NAME"

cp -r ~/qwen-sandbox/templates/python-project "$DEST"
find "$DEST" -type f -exec sed -i "s/{{PROJECT_NAME}}/$NAME/g" {} +
find "$DEST" -type f -exec sed -i "s/{{DESCRIPTION}}/$DESC/g" {} +
echo "Project '$NAME' created at $DEST"
BASH
chmod +x ~/qwen-sandbox/templates/new-project.sh
```

Then use Qwen Code to generate the script, and run it directly.

## What You Learned

Project templates let you scaffold new projects instantly with consistent structure, placeholder content, and zero manual setup.

---

**Module 3 Complete!** You now know how to organize workspaces, build multi-file projects, understand file types, work with large files, and create reusable templates. You can manage any project structure Qwen Code throws at you.

*Next: Module 4 — The Tools Qwen Uses — where you'll go deep into every tool Qwen Code has: Read, Write, Edit, Shell, Grep, Glob, and Web Fetch. You'll learn the advanced features that separate casual users from power users.*
