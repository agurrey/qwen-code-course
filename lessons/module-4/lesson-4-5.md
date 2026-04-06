---
module: 4
lesson: 5
title: "Grep Tool Advanced"
prerequisites: ["module-4/lesson-4-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 4.5: Grep Tool Advanced

> **Time:** ~5 min reading + ~5 min doing

## The Problem

You need to find something in your codebase. A simple text search works for exact matches. But what if you need to find all function definitions, all email addresses, all TODO comments, or all variable assignments — across specific file types, excluding certain directories? That's where regex patterns, file type filtering, and directory exclusions turn Grep from a simple search into a precision instrument.

## Mental Model

Grep is a codebase search engine with regex power. You can search for literal text, patterns (regex), or complex queries. You can limit which files to search by extension and exclude directories like `node_modules` or `.git`. The combination of pattern + file filter + exclusions gives you surgical search capability.

## Try It

**Your task:** Build a codebase and search it with increasingly sophisticated Grep queries.

1. Create a multi-file project to search:
   ```bash
   mkdir -p ~/qwen-sandbox/grep-advanced/{src,tests,docs,legacy}
   cd ~/qwen-sandbox/grep-advanced

   cat > src/auth.py << 'EOF'
   import re
   import hashlib

   def validate_email(email):
       """Validate email format."""
       pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
       return bool(re.match(pattern, email))

   def hash_password(password):
       """Hash a password using SHA-256."""
       return hashlib.sha256(password.encode()).hexdigest()

   # TODO: Add rate limiting
   # TODO: Implement password strength checker
   def authenticate(user, password):
       if validate_email(user):
           hashed = hash_password(password)
           return {"user": user, "hash": hashed}
       return None
   EOF

   cat > src/models.py << 'EOF'
   class User:
       def __init__(self, name, email, age):
           self.name = name
           self.email = email
           self.age = age

       def __repr__(self):
           return f"User(name={self.name}, email={self.email})"

   class Product:
       def __init__(self, name, price, sku):
           self.name = name
           self.price = price
           self.sku = sku
           self.discount = 0

       def apply_discount(self, percent):
           self.discount = percent
           return self.price * (1 - percent / 100)
   EOF

   cat > src/utils.py << 'EOF'
   import os
   import json

   def load_config(path):
       with open(path) as f:
           return json.load(f)

   def get_env_var(name, default=None):
       return os.environ.get(name, default)

   # FIXME: This doesn't handle nested configs
   def merge_configs(base, override):
       result = base.copy()
       result.update(override)
       return result
   EOF

   cat > tests/test_auth.py << 'EOF'
   import unittest
   from src.auth import validate_email, hash_password

   class TestAuth(unittest.TestCase):
       def test_valid_email(self):
           self.assertTrue(validate_email("user@example.com"))

       def test_invalid_email(self):
           self.assertFalse(validate_email("not-an-email"))

       def test_hash_password(self):
           result = hash_password("test123")
           self.assertEqual(len(result), 64)  # SHA-256 hex length
   EOF

   cat > legacy/old_auth.py << 'EOF'
   # This file is deprecated - do not use
   import md5

   def old_validate(password):
       return md5.new(password).hexdigest()

   # WARNING: MD5 is insecure!
   EOF

   cat > docs/TODO.md << 'EOF'
   # TODOs

   - TODO: Migrate auth module to OAuth2
   - TODO: Add unit tests for models
   - FIXME: User class doesn't validate email on creation
   EOF
   ```

2. Launch Qwen Code:
   ```bash
   qwen
   ```

3. **Basic regex search.** Ask: "Find all TODO and FIXME comments in Python files."
   - Qwen Code uses Grep with pattern `TODO|FIXME` and glob `*.py`.

4. **Search for patterns.** Ask: "Find all function definitions across all Python files in the src/ directory."
   - Qwen Code uses pattern `def \w+` with glob `**/*.py` or path restriction to `src/`.

5. **Email pattern search.** Ask: "Find all regex patterns that match email addresses in any file."
   - Qwen Code uses a regex like `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`.

6. **Exclude directories.** Ask: "Search for 'TODO' in all files but exclude the legacy/ directory."
   - Qwen Code uses Grep's path exclusion to skip legacy files.

7. **Complex search.** Ask: "Find all lines that contain both 'def' and 'test' — I want to see every test function definition."
   - Qwen Code uses pattern `def.*test` with appropriate glob.

8. **Cross-file summary.** Ask: "Search for all FIXME and TODO comments across all files (including docs/) and summarize what needs to be done."
   - Qwen Code searches broadly and synthesizes the results.

## Check Your Work

The model should check:
1. All project files exist across `src/`, `tests/`, `docs/`, and `legacy/`
2. Grep found TODOs and FIXMEs in Python files (at least 4 total)
3. Grep found function definitions (at least 10 across all files)
4. When excluding `legacy/`, results don't include `old_auth.py`
5. Email regex pattern matches found in `auth.py`
6. Test function definitions found in `test_auth.py`
7. The user can explain how to combine regex + glob + path filters

## Debug It

**Something's broken:** Grep returns too many results (including irrelevant files), or the regex pattern doesn't match what you expect.

Too many results usually means you need to exclude directories or filter by file type:
```bash
# Exclude node_modules and .git:
# In Qwen Code, specify path exclusions

# Only search Python files:
# Use glob: **/*.py
```

Regex not matching? Common gotchas:
- Grep uses a slightly different regex flavor than Python's `re` module
- Special characters need escaping: `\.` for literal dot, `\(` for literal parens
- In Qwen Code's Grep tool, the `pattern` parameter uses ripgrep syntax, which is mostly compatible with standard regex

**Hint if stuck:** Start with a broader search and narrow down. If `def.*test` doesn't find test functions, try just `def` first to see all functions, then refine the pattern. If results include files you don't care about, add a glob filter.

**Expected fix:** Break complex searches into steps:
1. First, search broadly to confirm the pattern works
2. Then add file type filters
3. Then add directory exclusions

If a regex isn't working, test it on a known string first. Ask Qwen Code: "Does the regex pattern `def \w+` match the text `def my_function():`?" — this helps you isolate the regex issue from the search issue.

## What You Learned

Grep with regex patterns, file type filters, and directory exclusions turns a simple text search into a precision codebase exploration tool.

---

*Next: Lesson 4.6 — Glob Tool Advanced — where you'll master complex file matching patterns, exclusions, and combining Glob with other tools for powerful workflows.*
