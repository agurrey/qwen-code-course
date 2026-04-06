---
module: 7
lesson: 2
title: "Adding Your First MCP Server"
prerequisites: ["module-7/lesson-7-1"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You know what MCP servers are in theory, but you've never actually connected one. Right now, Qwen Code can read files, run commands, and edit code — but it can't fetch live data from the web, query a database, or access any external service. You want to change that by wiring up a real MCP server and seeing external tools appear in your workflow.

## Mental Model

Adding an MCP server is like plugging a USB device into your computer. You connect it, the system discovers what it offers, and suddenly you have new capabilities. In Qwen Code, the connection lives in a configuration file (`mcp.json`). Once it's there, the tools show up automatically — no restart needed.

## Try It

First, check whether Qwen Code has an MCP configuration file already. It lives in your settings directory:

```bash
ls ~/.config/qwen-code/mcp.json 2>/dev/null || echo "No mcp.json found"
```

If you don't have one yet, that's fine — you'll create it.

For this exercise, you'll set up a simple MCP server that provides a filesystem search tool. You'll use a real, well-known MCP server: `@modelcontextprotocol/server-filesystem`. But since we need something that works without npm, let's build a minimal one from scratch to understand the mechanics.

Create a working directory:

```bash
mkdir -p ~/qwen-course-work/module-7/mcp-exercise
cd ~/qwen-course-work/module-7/mcp-exercise
```

Now create a tiny MCP server in Python. This server will offer one tool: `echo_upper`, which takes a string and returns it in uppercase.

```bash
cat > simple_server.py << 'PYEOF'
#!/usr/bin/env python3
"""A minimal MCP server that provides an echo_upper tool."""
import json
import sys

def handle_initialize():
    print(json.dumps({
        "jsonrpc": "2.0",
        "id": 1,
        "result": {
            "protocolVersion": "2024-11-05",
            "capabilities": {"tools": {}},
            "serverInfo": {"name": "simple-mcp", "version": "1.0.0"}
        }
    }))

def handle_tools_list():
    print(json.dumps({
        "jsonrpc": "2.0",
        "id": 2,
        "result": {
            "tools": [{
                "name": "echo_upper",
                "description": "Convert a string to uppercase",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "text": {
                            "type": "string",
                            "description": "The text to convert to uppercase"
                        }
                    },
                    "required": ["text"]
                }
            }]
        }
    }))

def handle_tools_call(params):
    tool_name = params.get("name", "")
    arguments = params.get("arguments", {})
    if tool_name == "echo_upper":
        text = arguments.get("text", "")
        result = text.upper()
        print(json.dumps({
            "jsonrpc": "2.0",
            "id": 3,
            "result": {
                "content": [{"type": "text", "text": result}]
            }
        }))
    else:
        print(json.dumps({
            "jsonrpc": "2.0",
            "id": 3,
            "error": {"code": -32601, "message": f"Unknown tool: {tool_name}"}
        }))

def main():
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
            method = msg.get("method", "")
            if method == "initialize":
                handle_initialize()
            elif method == "tools/list":
                handle_tools_list()
            elif method == "tools/call":
                handle_tools_call(msg.get("params", {}))
        except json.JSONDecodeError:
            pass

if __name__ == "__main__":
    main()
PYEOF
chmod +x simple_server.py
```

This server reads JSON-RPC messages from stdin and writes responses to stdout. That's the core of MCP transport: stdin/stdout for local servers, HTTP for remote ones.

Now simulate talking to this server. Send it an initialize message:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | python3 simple_server.py
```

Expected output (may be on one line):
```
{"jsonrpc": "2.0", "id": 1, "result": {"protocolVersion": "2024-11-05", "capabilities": {"tools": {}}, "serverInfo": {"name": "simple-mcp", "version": "1.0.0"}}}
```

Now ask for the tools list:

```bash
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | python3 simple_server.py
```

Expected output:
```
{"jsonrpc": "2.0", "id": 2, "result": {"tools": [{"name": "echo_upper", "description": "Convert a string to uppercase", "inputSchema": {"type": "object", "properties": {"text": {"type": "string", "description": "The text to convert to uppercase"}}, "required": ["text"]}}]}}
```

Now call the tool:

```bash
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"echo_upper","arguments":{"text":"hello from qwen code"}}}' | python3 simple_server.py
```

Expected output:
```
{"jsonrpc": "2.0", "id": 3, "result": {"content": [{"type": "text", "text": "HELLO FROM QWEN CODE"}]}}
```

You just ran a full MCP conversation: initialize, discover tools, call a tool. This is exactly what Qwen Code does behind the scenes.

## Check Your Work

Create a verification script that tests all three interactions:

```bash
cat > test_server.sh << 'SHEOF'
#!/bin/bash
set -e

echo "=== Test 1: Initialize ==="
RESP=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | python3 simple_server.py)
echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['result']['serverInfo']['name']=='simple-mcp'; print('PASS: Server initialized')"

echo "=== Test 2: Tools List ==="
RESP=$(echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | python3 simple_server.py)
echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); names=[t['name'] for t in d['result']['tools']]; assert 'echo_upper' in names; print('PASS: echo_upper tool found')"

echo "=== Test 3: Tool Call ==="
RESP=$(echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"echo_upper","arguments":{"text":"test"}}}' | python3 simple_server.py)
echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['result']['content'][0]['text']=='TEST'; print('PASS: echo_upper returned TEST')"

echo ""
echo "All 3 tests passed!"
SHEOF
chmod +x test_server.sh
./test_server.sh
```

You should see all three tests pass.

## Debug It

Here's a common bug. If the server crashes or returns invalid JSON, Qwen Code can't use it. Introduce a bug:

```bash
sed -i 's/result = text.upper()/result = text.upper() + 1/' simple_server.py
```

Now run test 3 again:

```bash
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"echo_upper","arguments":{"text":"test"}}}' | python3 simple_server.py 2>&1
```

You'll see a `TypeError` because you can't concatenate a string and an integer. The server crashes, Qwen Code gets no response, and the tool appears to hang or fail silently.

Fix it:

```bash
sed -i 's/result = text.upper() + 1/result = text.upper()/' simple_server.py
```

Run the test again to confirm it works. Always check stderr when an MCP tool seems unresponsive — the server might be crashing silently.

## What You Learned

You connected to an MCP server by sending JSON-RPC messages over stdin/stdout and received tool responses back — the same protocol Qwen Code uses internally.

*Next: Lesson 7.3 — MCP Tools vs Qwen's Built-in Tools — You'll learn how external tools and built-in tools coexist and when to reach for each.*
