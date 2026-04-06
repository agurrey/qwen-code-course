---
module: 4
lesson: 7
title: "Web Fetch Tool Advanced"
prerequisites: ["module-4/lesson-4-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 4.7: Web Fetch Tool Advanced

> **Time:** ~5 min reading + ~5 min doing

## The Problem

You need data from the internet: an API response, a documentation page, a JSON config from a GitHub repo, or a weather forecast. The Web Fetch tool grabs web content, but APIs return JSON you need to extract, pages return HTML you need to parse, requests fail with errors, and APIs rate-limit you if you're too aggressive. Knowing how to fetch, parse, and handle failures makes Qwen Code a window to the entire web.

## Mental Model

The Web Fetch tool is a browser tab that returns page content as text. For HTML pages, it extracts readable text. For raw endpoints, it returns the raw response (JSON, XML, plain text). It doesn't execute JavaScript, fill forms, or click buttons — it fetches what the URL returns directly. APIs are its best friend because they return structured data.

## Try It

**Your task:** Practice fetching web content, APIs, JSON data, and handling errors.

1. Set up:
   ```bash
   mkdir -p ~/qwen-sandbox/fetch-advanced
   cd ~/qwen-sandbox/fetch-advanced
   ```

2. Launch Qwen Code:
   ```bash
   qwen
   ```

3. **Fetch a documentation page.** Ask:
   "Fetch the Python documentation landing page at https://www.python.org/ and summarize what it says about Python's key features."
   - Qwen Code fetches the HTML, extracts readable text, and summarizes the relevant section.
   - Note: This may return a lot of content. Ask for a focused summary.

4. **Fetch a public API (JSON).** Ask:
   "Fetch https://jsonplaceholder.typicode.com/users/1 and extract the user's name, email, and city."
   - This returns clean JSON. Qwen Code parses it and extracts the specific fields.
   - Expected output: name: "Leanne Graham", email: "Sincere@april.biz", city: "Gwenborough"

5. **Fetch a list endpoint.** Ask:
   "Fetch https://jsonplaceholder.typicode.com/posts?_limit=3 and list the titles of the three posts."
   - Returns a JSON array. Qwen Code extracts the `title` field from each object.

6. **Fetch with error handling.** Ask:
   "Fetch https://jsonplaceholder.typicode.com/users/99999 (a user that doesn't exist). What status code do you get, and what does the response say?"
   - Returns a 404. Qwen Code should report the error status and empty or error response body.

7. **Fetch and save to file.** Ask:
   "Fetch https://jsonplaceholder.typicode.com/users and save the result as users.json in the current directory."
   - Qwen Code fetches the data and uses the Write tool to save it.

8. **Verify the saved data:**
   ```bash
   python3 -c "import json; data = json.load(open('users.json')); print(f'Loaded {len(data)} users')"
   ```
   Should output: `Loaded 10 users`

9. **Fetch and analyze.** Ask:
   "I just saved users.json. Read it and tell me: how many users are from the city 'Gwenborough', and what companies do they work for?"
   - Qwen Code reads the local file and cross-references with the data it fetched earlier.

10. **Rate limit awareness.** Ask:
    "If I need to fetch data from an API 100 times in a loop, what should I watch out for?"
    - Qwen Code should explain rate limiting, suggest adding delays between requests, and recommend checking `X-RateLimit-*` headers.

## Check Your Work

The model should check:
1. `users.json` exists and contains valid JSON with 10 user objects
2. The user can explain what Qwen Code fetched from jsonplaceholder API for user ID 1
3. The user observed a 404 error when fetching non-existent user 99999
4. The post titles from the limited posts endpoint were correctly extracted
5. The user can explain the difference between fetching HTML pages (text extraction) and fetching API endpoints (structured JSON)
6. The user can explain what rate limiting is and why it matters for repeated fetches

## Debug It

**Something's broken:** The fetch returned an error, empty content, or HTML instead of the data you expected.

Common issues:
- **404 errors:** The URL is wrong or the resource doesn't exist. Double-check the URL.
- **Empty content:** Some pages are JavaScript-rendered (SPAs). Web Fetch gets the initial HTML, not the dynamically loaded content. If the page loads data via JS, fetch the API endpoint directly instead.
- **HTML instead of JSON:** You might be hitting a web page URL instead of an API endpoint. APIs usually have `/api/` in the path or end with `.json`.
- **Timeout:** The server is slow or unreachable. Try again or use a different URL.

**Hint if stuck:** Test the URL in your browser first. If it returns JSON in the browser, it will return JSON through Web Fetch. If it returns a rendered page, Web Fetch gets the HTML. If the page is blank, it's JavaScript-rendered and Web Fetch can't help — find the underlying API.

**Expected fix:** For APIs, always check the response type:
```
Ask Qwen Code: "What did the response look like? Was it JSON, HTML, or something else?"
```

If the response is HTML when you expected JSON, you probably hit the wrong endpoint. Most APIs have documentation — fetch the API's docs page instead.

For rate limiting, if you're getting `429 Too Many Requests`:
- Add delays between requests (1-2 seconds minimum)
- Check if the API has a `Retry-After` header
- Consider caching responses instead of re-fetching

A simple caching pattern:
```bash
# Only fetch if the file doesn't exist:
test -f users.json || curl -s https://jsonplaceholder.typicode.com/users > users.json
```

Ask Qwen Code to implement this pattern for you.

## What You Learned

The Web Fetch tool retrieves web content — APIs return structured JSON, pages return extracted text, and error handling is essential for production use.

---

**Module 4 Complete!** You now have deep knowledge of every tool Qwen Code uses: Read, Write, Edit, Shell, Grep, Glob, and Web Fetch. You can read files strategically, write production-quality content, make surgical edits, run complex shell commands, search code with regex, find files with patterns, and fetch web data from APIs. These are the skills that separate casual users from power users.

*Next: Module 5 — Workflows & Patterns — where you'll combine all these tools into repeatable workflows: code review cycles, debugging sessions, refactoring patterns, and automated documentation.*
