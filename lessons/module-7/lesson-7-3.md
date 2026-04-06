---
module: 7
lesson: 3
title: "MCP Tools vs Qwen's Built-in Tools"
prerequisites: ["module-7/lesson-7-2"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You've added MCP tools and you already have Qwen Code's built-in tools. Now you have two sets of tools in front of you, and you need to understand how they interact. Does Qwen Code pick the right tool automatically? What happens when an MCP tool and a built-in tool do similar things? How do you know which one is being used?

## Mental Model

MCP tools and built-in tools live in the same namespace from Qwen Code's perspective. When you ask Qwen Code to do something, it looks at all available tools — built-in and MCP — reads their descriptions, and picks the best match. MCP tools don't override built-in tools; they sit beside them. If descriptions overlap, Qwen Code prefers the one whose description most closely matches your request.

## Try It

You'll create a scenario where the distinction matters. You'll set up two tools that sound similar but do different things, and observe how Qwen Code chooses between them.

Work in your exercise directory:

```bash
cd ~/qwen-course-work/module-7/mcp-exercise
```

Create a mock tool catalog that represents a mixed environment — built-in tools and MCP tools side by side:

```bash
cat > mixed-tools.json << 'EOF'
{
  "builtin_tools": [
    {
      "name": "read_file",
      "description": "Read the contents of a file on the local filesystem",
      "source": "builtin"
    },
    {
      "name": "run_shell_command",
      "description": "Execute a shell command in the terminal",
      "source": "builtin"
    },
    {
      "name": "edit",
      "description": "Edit a file by replacing a section of text",
      "source": "builtin"
    }
  ],
  "mcp_tools": [
    {
      "name": "read_github_file",
      "description": "Read a file from a GitHub repository given owner, repo, and path",
      "source": "mcp:github",
      "input_schema": {
        "properties": {
          "owner": {"type": "string"},
          "repo": {"type": "string"},
          "path": {"type": "string"},
          "branch": {"type": "string"}
        },
        "required": ["owner", "repo", "path"]
      }
    },
    {
      "name": "search_web",
      "description": "Search the web for a query and return top results with URLs",
      "source": "mcp:websearch",
      "input_schema": {
        "properties": {
          "query": {"type": "string"},
          "num_results": {"type": "integer"}
        },
        "required": ["query"]
      }
    }
  ]
}
EOF
```

Now create a script that simulates Qwen Code's tool selection logic. The AI picks tools based on description matching:

```bash
cat > tool_selector.py << 'PYEOF'
#!/usr/bin/env python3
"""Simulates Qwen Code's tool selection: pick the tool whose description best matches the request."""
import json
import sys

def load_tools():
    return json.load(open("mixed-tools.json"))

def score_tool(tool, request):
    """Score a tool based on keyword overlap with the request."""
    desc_words = set(tool["description"].lower().split())
    req_words = set(request.lower().split())
    overlap = len(desc_words & req_words)
    # Bonus for exact word matches beyond simple words
    for word in req_words:
        if word in tool.get("name", "").lower():
            overlap += 2
    return overlap

def select_tool(request, tools_data):
    all_tools = tools_data["builtin_tools"] + tools_data["mcp_tools"]
    best = None
    best_score = -1
    for tool in all_tools:
        score = score_tool(tool, request)
        if score > best_score:
            best_score = score
            best = tool
    return best, best_score

def main():
    tools_data = load_tools()

    requests = [
        "Read the README.md file in the current directory",
        "Find the latest Python tutorial about async on the web",
        "Read the main.py file from the facebook/react repository",
        "Run a git status command",
        "Search for documentation on MCP protocol",
    ]

    for req in requests:
        tool, score = select_tool(req, tools_data)
        source = tool.get("source", "unknown")
        print(f"Request: {req}")
        print(f"  -> Selected: {tool['name']} (source: {source}, score: {score})")
        print()

if __name__ == "__main__":
    main()
PYEOF
python3 tool_selector.py
```

Expected output:
```
Request: Read the README.md file in the current directory
  -> Selected: read_file (source: builtin, score: ...)

Request: Find the latest Python tutorial about async on the web
  -> Selected: search_web (source: mcp:websearch, score: ...)

Request: Read the main.py file from the facebook/react repository
  -> Selected: read_github_file (source: mcp:github, score: ...)

Request: Run a git status command
  -> Selected: run_shell_command (source: builtin, score: ...)

Request: Search for documentation on MCP protocol
  -> Selected: search_web (source: mcp:websearch, score: ...)
```

The key insight: Qwen Code uses the **description** to decide. The `search_web` tool gets selected for "search" and "web" queries because its description contains those words. The `read_file` tool wins for local file reads. The `read_github_file` tool wins when the request mentions a repository.

## Check Your Work

Add a third MCP tool to the catalog — a `read_url` tool that fetches the contents of any URL — and verify it gets selected for the right requests:

```bash
python3 -c "
import json
data = json.load(open('mixed-tools.json'))
data['mcp_tools'].append({
    'name': 'read_url',
    'description': 'Fetch the contents of a URL and return the page text',
    'source': 'mcp:browser',
    'input_schema': {
        'properties': {'url': {'type': 'string'}},
        'required': ['url']
    }
})
json.dump(data, open('mixed-tools.json', 'w'), indent=2)
print('Added read_url tool')
"
python3 tool_selector.py
```

Now requests mentioning "URL" or "fetch" or "page" should select `read_url`. Add a test request:

```bash
python3 -c "
import json, sys
sys.path.insert(0, '.')
from tool_selector import load_tools, select_tool
tools = load_tools()
tool, score = select_tool('Fetch the contents of https://example.com', tools)
print(f'Selected: {tool[\"name\"]} (score: {score})')
assert tool['name'] == 'read_url', f'Expected read_url but got {tool[\"name\"]}'
print('PASS: read_url selected correctly')
"
```

## Debug It

Here's a common problem: two tools with nearly identical descriptions. Qwen Code might pick the wrong one. Simulate this by giving `read_file` and `read_github_file` overlapping descriptions:

```bash
python3 -c "
import json
data = json.load(open('mixed-tools.json'))
# Make descriptions ambiguous
data['builtin_tools'][0]['description'] = 'Read a file from a repository'
data['mcp_tools'][0]['description'] = 'Read a file from a repository on GitHub'
json.dump(data, open('mixed-tools.json', 'w'), indent=2)
print('Made descriptions ambiguous')
"
```

Now run the selector on a request for a GitHub file:

```bash
python3 -c "
import json, sys
sys.path.insert(0, '.')
from tool_selector import load_tools, select_tool
tools = load_tools()
tool, score = select_tool('Read the main.py from facebook/react', tools)
print(f'Selected: {tool[\"name\"]} (source: {tool[\"source\"]}, score: {score})')
"
```

Both tools score similarly because their descriptions now overlap heavily. The fix: make descriptions specific and non-overlapping. Restore the original descriptions:

```bash
python3 -c "
import json
data = json.load(open('mixed-tools.json'))
data['builtin_tools'][0]['description'] = 'Read the contents of a file on the local filesystem'
data['mcp_tools'][0]['description'] = 'Read a file from a GitHub repository given owner, repo, and path'
json.dump(data, open('mixed-tools.json', 'w'), indent=2)
print('Fixed descriptions')
"
```

Run the selector again and confirm `read_github_file` wins for GitHub requests.

The lesson: when you install MCP servers, check their tool descriptions. If they're vague or overlap with built-in tools, you can override them in your MCP configuration to add more specific descriptions.

## What You Learned

MCP tools and built-in tools compete on equal footing — Qwen Code picks whichever description best matches your request, so clear and specific tool descriptions matter.

*Next: Lesson 7.4 — Popular MCP Servers — You'll explore real MCP servers for databases, cloud storage, and web automation.*
