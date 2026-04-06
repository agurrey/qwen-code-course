---
module: 2
lesson: 6
title: "Fetching Web Content"
prerequisites: ["2-5"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 2.6: Fetching Web Content

> **Time:** ~2 min reading + ~5 min doing

## The Problem

You need information from a website — a documentation page, an API reference, a news article. Instead of copying and pasting, you can have Qwen Code fetch and summarize it directly.

## Mental Model

Qwen Code has a **Web Fetch** tool that retrieves web pages and converts them to readable text. It can't interact with forms or click buttons — it just grabs the page content. Think of it as "view source" but cleaned up so a human (and AI) can read it. This is useful for documentation, research, and extracting data from public websites.

## Try It

**Your task:** Fetch a web page, extract useful information, and save it.

1. Launch Qwen Code:
   ```bash
   cd ~/qwen-sandbox
   qwen
   ```

2. Ask: "Fetch https://jsonplaceholder.typicode.com/users and show me the data."
   - Qwen Code will use Web Fetch to retrieve the JSON.
   - It should display the user data.

3. Ask: "From that data, create a file called users.txt with each user's name and email on one line, formatted as: 'Name <email>'"
   - It will parse the JSON and write the file.

4. Now try a real webpage. Ask: "Fetch https://example.com and summarize what's on the page."
   - It should fetch the page and provide a summary.

5. Ask: "Save the summary to example-summary.txt."

6. Verify:
   ```bash
   cat ~/qwen-sandbox/users.txt
   cat ~/qwen-sandbox/example-summary.txt
   ```

## Check Your Work

The model should check:
1. Qwen Code used Web Fetch (not Shell + curl/wget)
2. users.txt contains name + email pairs for users from the API
3. example-summary.txt contains a summary of example.com
4. The user can explain what Web Fetch can and cannot do (gets pages, can't interact)
5. The file is valid and readable

## Debug It

**Something's broken:** Web Fetch failed, or the content is garbled.

**Hint if stuck:** Some websites block automated fetching (anti-bot protection). JSON APIs usually work fine. Static pages work better than JavaScript-rendered pages (SPAs).

**Expected fix:**
1. If a site blocks fetching, try the Shell tool: "Run `curl -s URL` and show me the output"
2. If content is garbled (HTML tags everywhere), ask Qwen Code to clean it: "The fetched content has too many HTML tags. Clean it up and show just the readable text."
3. Some sites require authentication — Web Fetch can't handle logged-in pages.

## What You Learned

Web Fetch grabs webpage content as text. It works best with APIs and static pages, not with interactive or authenticated sites.

---

**Module 2 Complete!** You can now read files, edit files, run commands, search content, find files, and fetch web pages — all through Qwen Code. These six capabilities cover about 80% of what you'll do daily.

*Next: Module 3 — Files & Projects — where you'll learn to organize your work and manage projects with Qwen Code's help.*

---

## Combined Exercise: Putting It All Together

Now that you've learned all six commands, try this challenge without step-by-step instructions:

**Task:** Create a project called "mini-blog" in `~/qwen-sandbox/mini-blog/` with:
1. A `posts/` directory containing 3 markdown files (post-1.md, post-2.md, post-3.md)
2. Each post should have a title, date, and body
3. A `README.md` that lists all posts with their titles
4. A `search.txt` file containing all lines that have "date:" in them across all posts
5. Fetch https://example.com and save its title tag as `inspiration.txt`

Take your time. Use any combination of the tools you've learned. When you're done, you'll know you've got the basics down.
