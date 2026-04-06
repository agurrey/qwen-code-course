---
module: 3
lesson: 3
title: "Understanding File Types"
prerequisites: ["module-3/lesson-3-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 3.3: Understanding File Types

> **Time:** ~5 min reading + ~5 min doing

## The Problem

You see a `.py` file, a `.json` file, a `.sh` file, a `.md` file, and a `.txt` file. They all contain text. So what's the difference? If you treat them all the same, you'll try to run a text file as a script, or parse a Markdown file as JSON, and wonder why things break. File extensions are signals — to you, to your operating system, and to Qwen Code.

## Mental Model

A file extension tells the world how to interpret the contents. `.py` means Python code — it gets executed. `.json` means structured data — it gets parsed. `.md` means documentation — it gets rendered. `.sh` means shell commands — it runs in a terminal. `.txt` means plain text — it gets read. Qwen Code uses these signals to decide which tools and approaches to use.

## Try It

**Your task:** Create one file of each type and observe how Qwen Code handles each differently.

1. Set up:
   ```bash
   mkdir -p ~/qwen-sandbox/file-types
   cd ~/qwen-sandbox/file-types
   ```

2. Create a `.txt` file — raw text, no structure:
   ```bash
   cat > notes.txt << 'EOF'
   Meeting notes from Monday:
   - Discussed project timeline
   - Need to finish API integration by Friday
   - Follow up with design team about mockups
   EOF
   ```

3. Create a `.py` file — executable Python code:
   ```bash
   cat > calculator.py << 'EOF'
   def add(a, b):
       return a + b

   def multiply(a, b):
       return a * b

   if __name__ == "__main__":
       print(f"2 + 3 = {add(2, 3)}")
       print(f"4 * 5 = {multiply(4, 5)}")
   EOF
   ```

4. Create a `.json` file — structured data:
   ```bash
   cat > settings.json << 'EOF'
   {
     "app_name": "Calculator",
     "version": "1.0.0",
     "features": {
       "addition": true,
       "multiplication": true,
       "division": false
     },
     "max_history": 100
   }
   EOF
   ```

5. Create a `.md` file — formatted documentation:
   ```bash
   cat > README.md << 'EOF'
   # Calculator App

   A simple calculator with add and multiply operations.

   ## Usage

   ```bash
   python3 calculator.py
   ```

   ## Features

   - Addition
   - Multiplication
   - More coming soon
   EOF
   ```

6. Create a `.sh` file — executable shell script:
   ```bash
   cat > setup.sh << 'EOF'
   #!/bin/bash
   echo "Setting up Calculator app..."
   python3 --version
   echo "Running calculator..."
   python3 calculator.py
   echo "Setup complete!"
   EOF
   chmod +x setup.sh
   ```

7. Launch Qwen Code:
   ```bash
   qwen
   ```

8. Now test how Qwen Code treats each file differently:

   **For the .txt file:** Ask "Summarize my notes.txt"
   - Qwen Code reads it as plain text and summarizes the content.

   **For the .py file:** Ask "Run calculator.py and show me the output"
   - Qwen Code executes it with Python. It treats it as code, not documentation.

   **For the .json file:** Ask "Read settings.json and tell me which features are enabled"
   - Qwen Code parses the JSON structure and extracts specific values.

   **For the .md file:** Ask "Show me the usage instructions from README.md"
   - Qwen Code reads the Markdown and presents the rendered documentation.

   **For the .sh file:** Ask "What does setup.sh do? Don't run it, just explain."
   - Qwen Code reads the shell script and explains the commands without executing.

9. Now ask Qwen Code to convert between types:
   - "Convert settings.json to a Python dictionary and save it as settings.py"
   - "Turn notes.txt into a structured JSON file called notes.json with a 'content' key"

10. Verify the conversions:
    ```bash
    cat ~/qwen-sandbox/file-types/settings.py
    cat ~/qwen-sandbox/file-types/notes.json
    ```

## Check Your Work

The model should check:
1. All five files exist (`.txt`, `.py`, `.json`, `.md`, `.sh`)
2. `calculator.py` runs successfully with `python3 calculator.py`
3. `settings.json` is valid JSON (test with `python3 -m json.tool settings.json`)
4. `setup.sh` is executable (`test -x setup.sh`)
5. The user can explain the difference between how Qwen Code handles each file type
6. Converted files (`settings.py`, `notes.json`) exist and are valid

## Debug It

**Something's broken:** You try to run `python3 settings.json` and get a `SyntaxError`. Or you try to parse `notes.txt` as JSON and it fails.

This happens because you're treating files as the wrong type. The extension tells you what the file is:

```bash
# This fails — JSON is not Python code:
python3 settings.json

# This fails — plain text is not JSON:
python3 -c "import json; json.load(open('notes.txt'))"

# This works — JSON parsed as JSON:
python3 -c "import json; print(json.load(open('settings.json')))"
```

**Hint if stuck:** Before operating on a file, check its extension. Use `file` command if unsure:
```bash
file settings.json notes.txt calculator.py
```

**Expected fix:** Match the operation to the file type. Run `.py` and `.sh` files. Parse `.json` files. Read `.txt` and `.md` files. When in doubt, ask Qwen Code: "What type of file is this and how should I work with it?"

## What You Learned

File extensions are signals that determine how Qwen Code reads, parses, and executes — always match the operation to the file type.

---

*Next: Lesson 3.4 — Working with Larger Files — where you'll learn to handle files too big to read at once, using paginated reading and targeted section access.*
