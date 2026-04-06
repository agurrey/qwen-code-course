---
module: 4
lesson: 3
title: "The Edit Tool"
prerequisites: ["module-4/lesson-4-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 4.3: The Edit Tool

> **Time:** ~5 min reading + ~5 min doing

## The Problem

You have a 100-line Python file and need to change one function signature, update a variable name, and add a docstring. Rewriting the whole file with the Write tool works, but it's overkill and risks introducing errors in the 95 lines you didn't mean to change. The Edit tool makes surgical changes — it finds specific text and replaces it, leaving everything else untouched.

## Mental Model

The Edit tool is a scalpel, not a sledgehammer. It searches for exact text in a file and replaces it. You tell it what to find and what to put instead. If the search text doesn't match exactly, the edit fails — precision matters.

## Try It

**Your task:** Create a file, then practice editing it with increasing precision.

1. Create the base file:
   ```bash
   mkdir -p ~/qwen-sandbox/edit-deep
   cd ~/qwen-sandbox/edit-deep

   cat > data_processor.py << 'EOF'
   import json
   import os

   class DataProcessor:
       def __init__(self, input_path):
           self.input_path = input_path
           self.data = []
           self.processed = False

       def load(self):
           with open(self.input_path, 'r') as f:
               self.data = json.load(f)

       def process(self):
           for item in self.data:
               item['value'] = item['value'] * 2
           self.processed = True

       def save(self, output_path):
           with open(output_path, 'w') as f:
               json.dump(self.data, f, indent=2)

       def summary(self):
           if not self.processed:
               return "No data processed yet."
           return f"Processed {len(self.data)} items."
   EOF

   cat > sample_data.json << 'EOF'
   [
     {"id": 1, "name": "Alice", "value": 10},
     {"id": 2, "name": "Bob", "value": 20},
     {"id": 3, "name": "Charlie", "value": 30}
   ]
   EOF
   ```

2. Launch Qwen Code:
   ```bash
   qwen
   ```

3. **Simple rename.** Ask: "In data_processor.py, rename the class from DataProcessor to Processor."
   - Qwen Code uses the Edit tool to find `class DataProcessor:` and replace it with `class Processor:`.

4. **Add a parameter.** Ask: "In data_processor.py, update the __init__ method to accept an optional debug parameter with default False. Add self.debug = debug inside the method."
   - Qwen Code edits the signature and adds the assignment line.

5. **Add error handling.** Ask: "In data_processor.py, wrap the json.load call in the load method with a try/except that catches json.JSONDecodeError and prints an error message."
   - Qwen Code finds the specific load method body and wraps it.

6. **Multi-edit across the file.** Ask: "In data_processor.py, do these three edits: (1) Add a log method that prints a message if debug is True. (2) Update the process method to call self.log('Processing item') for each item. (3) Update the summary method to include 'in debug mode' if self.debug is True."
   - Qwen Code applies all three edits in a single request.

7. Verify the edits:
   ```bash
   python3 -c "
   import json
   from data_processor import Processor
   p = Processor('sample_data.json', debug=True)
   p.load()
   p.process()
   print(p.summary())
   "
   ```

## Check Your Work

The model should check:
1. `data_processor.py` exists and the class is now named `Processor` (not `DataProcessor`)
2. `__init__` accepts `debug=False` parameter
3. The `load` method has try/except for `json.JSONDecodeError`
4. The `process` method calls `self.log()` for each item
5. The `summary` method mentions debug mode when applicable
6. A `log` method exists
7. The file still runs correctly and produces output

## Debug It

**Something's broken:** Qwen Code says "edit failed — search text not found." This is the most common Edit tool error.

The search text must match the file content exactly — character for character, including whitespace and indentation. If you ask to edit `def process(self):` but the file has `def process(self): ` (trailing space), it won't match.

**Hint if stuck:** Ask Qwen Code to read the file first, then tell you the exact text to search for. Or provide a larger context around the edit so the match is unique:

```
# Bad — might match multiple places or not match exactly:
"Change the line 'x = 1' to 'x = 2'"

# Good — includes surrounding context:
"In the __init__ method, change:
    self.data = []
    self.processed = False
to:
    self.data = []
    self.processed = False
    self.debug = False"
```

**Expected fix:** When an edit fails:
1. Ask Qwen Code to read the file and show you the exact content
2. Copy the exact text from the file (including indentation)
3. Retry the edit with the precise text

If multiple edits fail in sequence, consider whether the Write tool would be better — if you're changing more than half the file, rewriting is safer than editing.

## What You Learned

The Edit tool makes surgical changes to existing files — exact text matching is required, so provide context around your edits for reliable results.

---

*Next: Lesson 4.4 — Shell Tool Advanced — where you'll learn background processes, piping, environment variables, and error handling in shell commands.*
