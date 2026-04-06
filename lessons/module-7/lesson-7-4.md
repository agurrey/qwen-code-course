---
module: 7
lesson: 4
title: "Popular MCP Servers"
prerequisites: ["module-7/lesson-7-3"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You understand MCP servers conceptually, but you want to know what's actually available to use. There are dozens of MCP servers out there — for databases, file storage, web browsing, APIs, and more. You need a curated overview of the most useful ones and a concrete way to understand what each one does before you commit to installing any.

## Mental Model

Think of MCP servers as a marketplace. Each one solves a specific problem: "I need to talk to this service." Instead of learning every service's API, you install the corresponding MCP server and the tools appear in Qwen Code. The server handles authentication, rate limits, and data formatting so you don't have to.

## Try It

You'll catalog five popular MCP server categories, understand what tools each provides, and simulate calling one of them. This builds the mental model you need to evaluate any MCP server you encounter.

Create the catalog:

```bash
mkdir -p ~/qwen-course-work/module-7/catalog
cd ~/qwen-course-work/module-7/catalog
```

Create a JSON catalog of popular MCP servers:

```bash
cat > mcp-catalog.json << 'EOF'
{
  "servers": [
    {
      "name": "@modelcontextprotocol/server-postgres",
      "category": "Database",
      "connects_to": "PostgreSQL database",
      "tools": [
        {
          "name": "query",
          "description": "Execute a read-only SQL query against the database",
          "params": ["sql_query"]
        },
        {
          "name": "list_tables",
          "description": "List all tables in the database",
          "params": []
        }
      ],
      "setup": "Requires DATABASE_URL environment variable"
    },
    {
      "name": "@modelcontextprotocol/server-google-drive",
      "category": "Cloud Storage",
      "connects_to": "Google Drive files and folders",
      "tools": [
        {
          "name": "search_files",
          "description": "Search for files in Google Drive by name or content",
          "params": ["query"]
        },
        {
          "name": "read_file",
          "description": "Read the contents of a Google Drive file",
          "params": ["file_id"]
        },
        {
          "name": "list_folder",
          "description": "List files in a Google Drive folder",
          "params": ["folder_id"]
        }
      ],
      "setup": "Requires Google OAuth credentials"
    },
    {
      "name": "@anthropic-ai/mcp-server-filesystem",
      "category": "Filesystem",
      "connects_to": "Local file system (with path restrictions)",
      "tools": [
        {
          "name": "read_file",
          "description": "Read the contents of a file",
          "params": ["path"]
        },
        {
          "name": "write_file",
          "description": "Write contents to a file",
          "params": ["path", "content"]
        },
        {
          "name": "list_directory",
          "description": "List files and directories in a path",
          "params": ["path"]
        }
      ],
      "setup": "Requires allowed_paths configuration"
    },
    {
      "name": "@anthropic-ai/mcp-server-puppeteer",
      "category": "Browser Automation",
      "connects_to": "Chromium browser instance",
      "tools": [
        {
          "name": "navigate",
          "description": "Navigate to a URL in the browser",
          "params": ["url"]
        },
        {
          "name": "screenshot",
          "description": "Take a screenshot of the current page",
          "params": []
        },
        {
          "name": "click",
          "description": "Click an element on the page by selector",
          "params": ["selector"]
        },
        {
          "name": "evaluate",
          "description": "Run JavaScript in the page context",
          "params": ["script"]
        }
      ],
      "setup": "Requires Chromium installed"
    },
    {
      "name": "@modelcontextprotocol/server-github",
      "category": "Developer Tools",
      "connects_to": "GitHub repositories and issues",
      "tools": [
        {
          "name": "search_repositories",
          "description": "Search GitHub repositories",
          "params": ["query"]
        },
        {
          "name": "get_file_contents",
          "description": "Get file contents from a repository",
          "params": ["owner", "repo", "path", "branch"]
        },
        {
          "name": "create_issue",
          "description": "Create a GitHub issue",
          "params": ["owner", "repo", "title", "body"]
        },
        {
          "name": "list_pull_requests",
          "description": "List pull requests in a repository",
          "params": ["owner", "repo"]
        }
      ],
      "setup": "Requires GITHUB_TOKEN environment variable"
    }
  ]
}
EOF
```

Now explore the catalog. How many tools does each server expose?

```bash
python3 -c "
import json
data = json.load(open('mcp-catalog.json'))
for server in data['servers']:
    tool_count = len(server['tools'])
    print(f'{server[\"name\"]} ({server[\"category\"]}): {tool_count} tools')
    print(f'  Connects to: {server[\"connects_to\"]}')
    print(f'  Setup: {server[\"setup\"]}')
    print()
"
```

You'll see a quick overview of each server. Notice the pattern: each server connects to one service and exposes 3-5 tools for it.

Now simulate using the GitHub server. Create a scenario where you ask Qwen Code to find a file in a repo:

```bash
cat > simulate-github.py << 'PYEOF'
#!/usr/bin/env python3
"""Simulate a GitHub MCP server interaction."""
import json

# This is what the tool definition looks like
tool = {
    "name": "get_file_contents",
    "description": "Get file contents from a repository",
    "params": ["owner", "repo", "path", "branch"]
}

# This is the call Qwen Code would make
call = {
    "name": "get_file_contents",
    "arguments": {
        "owner": "facebook",
        "repo": "react",
        "path": "README.md",
        "branch": "main"
    }
}

# In reality, the MCP server would fetch this from GitHub's API
# Here we simulate the response
response = {
    "content": [
        {
            "type": "text",
            "text": "# React\n\nReact is a JavaScript library for building user interfaces.\n\n## Getting Started\n\nVisit the tutorial at https://react.dev/learn"
        }
    ]
}

print("=== Tool Definition ===")
print(json.dumps(tool, indent=2))
print()
print("=== Tool Call ===")
print(json.dumps(call, indent=2))
print()
print("=== Response ===")
print(json.dumps(response, indent=2))
print()
print(f"File size: {len(response['content'][0]['text'])} characters")
PYEOF
python3 simulate-github.py
```

This shows the full lifecycle: tool definition, tool call with arguments, and the response. When Qwen Code uses the real GitHub MCP server, the flow is identical — only the response comes from GitHub's actual API instead of a hardcoded string.

## Check Your Work

Pick a server from the catalog and verify you understand it by answering these questions in a script:

```bash
cat > verify-understanding.py << 'PYEOF'
#!/usr/bin/env python3
"""Check that you understand which MCP server to use for each task."""
import json

data = json.load(open("mcp-catalog.json"))

# Build a lookup: category -> server name
by_category = {s["category"]: s["name"] for s in data["servers"]}

tasks = {
    "Read a CSV from Google Drive": "Cloud Storage",
    "Run SELECT * FROM users LIMIT 10": "Database",
    "Take a screenshot of https://example.com": "Browser Automation",
    "Find all open issues in facebook/react": "Developer Tools",
    "List files in /home/user/documents": "Filesystem",
}

print("Task -> Required MCP Server Category")
print("=" * 60)
all_pass = True
for task, expected_category in tasks.items():
    server_name = by_category.get(expected_category, "NOT FOUND")
    print(f"  {task}")
    print(f"    -> {expected_category} ({server_name})")

    # Verify the server has relevant tools
    server = next((s for s in data["servers"] if s["category"] == expected_category), None)
    if server:
        tool_names = [t["name"] for t in server["tools"]]
        print(f"    -> Tools available: {', '.join(tool_names)}")
    else:
        all_pass = False
    print()

print("Understanding check complete!")
PYEOF
python3 verify-understanding.py
```

## Debug It

A common mistake: installing the wrong MCP server for the job. You want to query a PostgreSQL database but you accidentally install the filesystem server.

```bash
python3 -c "
import json
data = json.load(open('mcp-catalog.json'))

# Scenario: user wants to query a database
# Wrong choice:
fs_server = next(s for s in data['servers'] if s['category'] == 'Filesystem')
print(f'Wrong choice: {fs_server[\"name\"]}')
print(f'  Tools: {[t[\"name\"] for t in fs_server[\"tools\"]]}')
print(f'  Can it run SQL queries? No — it only reads/writes files.')
print()

# Right choice:
db_server = next(s for s in data['servers'] if s['category'] == 'Database')
print(f'Right choice: {db_server[\"name\"]}')
print(f'  Tools: {[t[\"name\"] for t in db_server[\"tools\"]}')
print(f'  Can it run SQL queries? Yes — query tool executes SQL.')
"
```

The fix is straightforward: match the task to the server's category. If you need database access, use a database server. If you need web browsing, use a browser automation server. The tool descriptions tell you exactly what each server does — read them before installing.

## What You Learned

Popular MCP servers cover databases, cloud storage, filesystems, browser automation, and developer platforms — each one exposing 3-5 focused tools for its service.

*Next: Lesson 7.5 — Configuring MCP Servers — You'll write real mcp.json configuration with authentication and environment variables.*
