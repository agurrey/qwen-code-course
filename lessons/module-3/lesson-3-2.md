---
module: 3
lesson: 2
title: "Multi-file Projects"
prerequisites: ["module-3/lesson-3-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 3.2: Multi-file Projects

> **Time:** ~5 min reading + ~5 min doing

## The Problem

Real projects are never one file. A Python app imports a config module, a script reads a data file, and tests import the app. When you work with multiple files, you need to understand how they connect — imports, references, relative paths. Qwen Code can manage all of this, but only if you teach it the relationships between files.

## Mental Model

A multi-file project is a network of connections. Each file has a role, and files talk to each other through imports, paths, and references. Qwen Code reads files one at a time — when you tell it how files connect, it can reason across the whole network.

## Try It

**Your task:** Build a multi-file Python project and watch Qwen Code trace the connections.

1. Set up the project:
   ```bash
   mkdir -p ~/qwen-sandbox/multi-file-project
   cd ~/qwen-sandbox/multi-file-project
   ```

2. Create the config file:
   ```bash
   cat > config.py << 'EOF'
   # Configuration for the data processor
   INPUT_FILE = "data/input.csv"
   OUTPUT_FILE = "data/output.json"
   BATCH_SIZE = 50
   LOG_LEVEL = "INFO"
   EOF
   ```

3. Create the main application:
   ```bash
   cat > src/processor.py << 'PYEOF'
   import json
   from config import BATCH_SIZE, OUTPUT_FILE

   def process_data(items):
       """Process a batch of items."""
       results = []
       for i in range(0, len(items), BATCH_SIZE):
           batch = items[i:i + BATCH_SIZE]
           results.extend([item.upper() for item in batch])
       return results

   def save_results(results, filepath):
       """Save results to a JSON file."""
       with open(filepath, 'w') as f:
           json.dump({"results": results, "count": len(results)}, f)
       print(f"Saved {len(results)} results to {filepath}")
   PYEOF
   ```

   Wait — this will fail because `src/` doesn't exist and the import path is wrong. That's intentional. We'll fix it.

4. Fix the structure:
   ```bash
   mkdir -p src data
   mv config.py .
   cat > src/processor.py << 'PYEOF'
   import json
   import sys
   import os

   # Add parent directory to path so we can import config
   sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
   from config import BATCH_SIZE, OUTPUT_FILE

   def process_data(items):
       """Process a batch of items."""
       results = []
       for i in range(0, len(items), BATCH_SIZE):
           batch = items[i:i + BATCH_SIZE]
           results.extend([item.upper() for item in batch])
       return results

   def save_results(results, filepath):
       """Save results to a JSON file."""
       with open(filepath, 'w') as f:
           json.dump({"results": results, "count": len(results)}, f)
       print(f"Saved {len(results)} results to {filepath}")
   PYEOF
   ```

5. Create the entry point:
   ```bash
   cat > main.py << 'EOF'
   import sys
   sys.path.insert(0, 'src')
   from processor import process_data, save_results
   from config import INPUT_FILE, OUTPUT_FILE

   if __name__ == "__main__":
       sample_data = ["apple", "banana", "cherry", "date", "elderberry"]
       results = process_data(sample_data)
       save_results(results, OUTPUT_FILE)
   EOF
   ```

6. Create sample data:
   ```bash
   echo "name,age,city" > data/input.csv
   echo "Alice,30,NYC" >> data/input.csv
   echo "Bob,25,LA" >> data/input.csv
   ```

7. Launch Qwen Code:
   ```bash
   qwen
   ```

8. Ask: "Trace all the connections between files in this project. Show me which file imports from which, and which files reference which paths."
   - Qwen Code will read multiple files and map out the dependency graph.

9. Ask: "Run the project and show me the output."
   - Qwen Code will execute `python3 main.py` and show the results.

10. Verify the output file was created:
    ```bash
    cat ~/qwen-sandbox/multi-file-project/data/output.json
    ```

## Check Your Work

The model should check:
1. `main.py` exists at the project root and is executable
2. `src/processor.py` exists with `process_data` and `save_results` functions
3. `config.py` exists at the project root
4. `data/output.json` exists with valid JSON after running the project
5. The user can explain the import chain: `main.py` -> `src/processor.py` -> `config.py`

## Debug It

**Something's broken:** You run `python3 main.py` and get `ModuleNotFoundError: No module named 'config'`.

This is the classic multi-file Python problem. The import path is wrong. When Python runs `main.py`, it adds the directory of `main.py` to `sys.path`. But `src/processor.py` tries to import `config`, which lives in the parent directory.

**Hint if stuck:** Look at the `sys.path` manipulation in `src/processor.py`. Does it actually point to the right place? Print `sys.path` to see what Python sees.

**Expected fix:** The simplest approach for this project is to move `config.py` next to `src/` (which you already did) and ensure `main.py` adds the project root to `sys.path` before importing from `src`. Alternatively, ask Qwen Code: "Fix the import error in my multi-file Python project" — it will read the files, trace the imports, and fix the path.

## What You Learned

Multi-file projects are connected by imports and references — Qwen Code can trace these connections across files when you show it the full picture.

---

*Next: Lesson 3.3 — Understanding File Types — where you'll learn what different file extensions mean and how Qwen Code handles each one differently.*
