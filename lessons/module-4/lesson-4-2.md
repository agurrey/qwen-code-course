---
module: 4
lesson: 2
title: "The Write Tool"
prerequisites: ["module-4/lesson-4-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 4.2: The Write Tool

> **Time:** ~5 min reading + ~5 min doing

## The Problem

You need to create a new file. You could open a text editor and type it out. But if the file has structure — a config file with specific keys, a Python module with a class skeleton, a Markdown document with headings — describing it to Qwen Code and letting it write the file is faster and less error-prone. The Write tool doesn't just dump text into a file; it creates properly formatted, structured content.

## Mental Model

The Write tool is Qwen Code's pen. It can write anything from scratch — code, docs, configs, data. The quality of what it writes depends on the specificity of your instructions. Vague prompts get vague files. Detailed prompts get production-ready content.

## Try It

**Your task:** Create multiple file types from scratch using the Write tool.

1. Set up:
   ```bash
   mkdir -p ~/qwen-sandbox/write-deep
   cd ~/qwen-sandbox/write-deep
   ```

2. Launch Qwen Code:
   ```bash
   qwen
   ```

3. **Write a Python module from a description.** Ask:
   "Create a Python file at src/validators.py with a class called Validator that has methods: validate_email, validate_phone, and validate_age. validate_email should check for @ and a domain. validate_phone should check for 10 digits. validate_age should check for a number between 0 and 150. Include a __main__ block that tests all three."

   Qwen Code will create the file with proper structure, docstrings, and test code.

4. Verify it works:
   ```bash
   python3 ~/qwen-sandbox/write-deep/src/validators.py
   ```

5. **Write a JSON config file.** Ask:
   "Create a JSON file at config/app.json with these keys: app_name ('ValidatorApp'), version ('0.1.0'), settings (an object with max_retries: 3, timeout: 30, log_level: 'INFO'), and endpoints (a list with '/validate/email', '/validate/phone', '/validate/age')."

6. Verify:
   ```bash
   python3 -m json.tool ~/qwen-sandbox/write-deep/config/app.json
   ```

7. **Write a Markdown README.** Ask:
   "Create a README.md for this project. Include: project title 'ValidatorApp', description, installation instructions (pip install), usage example showing how to import and use the Validator class, and an API reference section listing the three validation methods."

8. **Write a shell script.** Ask:
   "Create a scripts/run_tests.sh that runs pytest on src/validators.py with verbose output, prints a pass/fail summary, and exits with the appropriate code. Make it executable."

   Note: Qwen Code creates the file content, but you may need to run `chmod +x` yourself, or ask Qwen Code to run it for you.

9. **Write from a template pattern.** Ask:
   "Create a new file at src/test_validators.py that imports Validator from src/validators.py and writes one test for each validation method — one passing case and one failing case per method."

## Check Your Work

The model should check:
1. `src/validators.py` exists and runs without errors (`python3 src/validators.py`)
2. `config/app.json` exists and is valid JSON
3. `README.md` exists with headings for Installation, Usage, and API Reference
4. `scripts/run_tests.sh` exists and is executable
5. `src/test_validators.py` exists and imports from validators
6. The user can explain how prompt specificity affects output quality

## Debug It

**Something's broken:** Qwen Code writes a file but it has syntax errors, missing imports, or the JSON is malformed.

This happens when the prompt isn't specific enough. Qwen Code fills in gaps with its best guess, and sometimes guesses wrong.

For example, if the JSON file fails to parse:
```bash
python3 -c "import json; json.load(open('config/app.json'))"
# json.decoder.JSONDecodeError: ...
```

**Hint if stuck:** When the output is wrong, don't start over. Ask Qwen Code to fix it: "The JSON file at config/app.json has a syntax error on line X. Fix it." The Write tool can overwrite files, so corrections are easy.

**Expected fix:** For more reliable output, be more specific in your initial prompt. Instead of "create a JSON config file," say "create a JSON config file with exactly these keys and values: ..." and list them explicitly. Even better: provide a skeleton.

```
"Create config/app.json matching this structure:
{
  "app_name": "???",
  "version": "???",
  "settings": {
    "max_retries": ???,
    "timeout": ???,
    "log_level": "???"
  },
  "endpoints": ["???", "???", "???"]
}
Replace ??? with appropriate values."
```

The closer your prompt is to the final output, the better Qwen Code's Write tool performs.

## What You Learned

The Write tool creates any file type from scratch — the more specific your description, the more production-ready the output.

---

*Next: Lesson 4.3 — The Edit Tool — where you'll learn to make targeted changes to existing files without rewriting them from scratch.*
