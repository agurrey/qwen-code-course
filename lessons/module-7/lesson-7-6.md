---
module: 7
lesson: 6
title: "Building Your Own MCP Server"
prerequisites: ["module-7/lesson-7-5"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You've used other people's MCP servers, configured them, and debugged them. But now you have a specific need that no existing server fills. Maybe you want a tool that queries your company's internal API, or one that formats data in a very specific way, or one that wraps a command-line tool you use daily. Instead of hoping someone builds it, you'll build it yourself.

## Mental Model

An MCP server is just a program that reads JSON from stdin, processes it, and writes JSON to stdout. It follows the JSON-RPC 2.0 protocol: the client (Qwen Code) sends a request with a method name and parameters, and the server responds with a result or an error. That's the entire protocol — no HTTP, no sockets, no complex networking. Just stdin and stdout.

## Try It

You'll build a complete MCP server in Python that provides a useful tool: `word_count`, which reads a file and returns word count, line count, and character count. Then you'll wire it into an `mcp.json` and verify it works.

Create your working directory:

```bash
mkdir -p ~/qwen-course-work/module-7/custom-server
cd ~/qwen-course-work/module-7/custom-server
```

Now build the server:

```bash
cat > wordcount_server.py << 'PYEOF'
#!/usr/bin/env python3
"""
MCP Server: wordcount
Provides a tool that counts words, lines, and characters in a file.
"""
import json
import sys
import os

# Server metadata
SERVER_NAME = "wordcount-server"
SERVER_VERSION = "1.0.0"

def send_response(response_id, result):
    """Send a JSON-RPC response to stdout."""
    msg = {
        "jsonrpc": "2.0",
        "id": response_id,
        "result": result
    }
    print(json.dumps(msg), flush=True)

def send_error(response_id, code, message):
    """Send a JSON-RPC error response to stdout."""
    msg = {
        "jsonrpc": "2.0",
        "id": response_id,
        "error": {
            "code": code,
            "message": message
        }
    }
    print(json.dumps(msg), flush=True)

def handle_initialize(request_id, params):
    """Handle the initialize request from Qwen Code."""
    result = {
        "protocolVersion": "2024-11-05",
        "capabilities": {
            "tools": {}
        },
        "serverInfo": {
            "name": SERVER_NAME,
            "version": SERVER_VERSION
        }
    }
    send_response(request_id, result)

def handle_tools_list(request_id):
    """Handle the tools/list request."""
    result = {
        "tools": [
            {
                "name": "word_count",
                "description": "Count words, lines, and characters in a text file. Returns a breakdown of file statistics.",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "filepath": {
                            "type": "string",
                            "description": "Path to the file to analyze"
                        }
                    },
                    "required": ["filepath"]
                }
            },
            {
                "name": "count_text",
                "description": "Count words, lines, and characters in a raw text string.",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "text": {
                            "type": "string",
                            "description": "The text to analyze"
                        }
                    },
                    "required": ["text"]
                }
            }
        ]
    }
    send_response(request_id, result)

def handle_tools_call(request_id, params):
    """Handle a tools/call request."""
    tool_name = params.get("name", "")
    arguments = params.get("arguments", {})

    if tool_name == "word_count":
        filepath = arguments.get("filepath", "")
        if not filepath:
            send_error(request_id, -32602, "filepath is required")
            return

        if not os.path.exists(filepath):
            send_error(request_id, -32602, f"File not found: {filepath}")
            return

        try:
            with open(filepath, "r") as f:
                content = f.read()
            words = len(content.split())
            lines = content.count("\n") + (1 if content and not content.endswith("\n") else 0)
            chars = len(content)
            result = {
                "content": [
                    {
                        "type": "text",
                        "text": f"File: {filepath}\nLines: {lines}\nWords: {words}\nCharacters: {chars}"
                    }
                ]
            }
            send_response(request_id, result)
        except PermissionError:
            send_error(request_id, -32602, f"Permission denied: {filepath}")
        except Exception as e:
            send_error(request_id, -32603, str(e))

    elif tool_name == "count_text":
        text = arguments.get("text", "")
        words = len(text.split())
        lines = text.count("\n") + (1 if text and not text.endswith("\n") else 0)
        chars = len(text)
        result = {
            "content": [
                {
                    "type": "text",
                    "text": f"Lines: {lines}\nWords: {words}\nCharacters: {chars}"
                }
            ]
        }
        send_response(request_id, result)

    else:
        send_error(request_id, -32601, f"Unknown tool: {tool_name}")

def main():
    """Main loop: read JSON-RPC requests from stdin."""
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            request = json.loads(line)
        except json.JSONDecodeError:
            continue

        request_id = request.get("id")
        method = request.get("method", "")

        if method == "initialize":
            handle_initialize(request_id, request.get("params", {}))
        elif method == "tools/list":
            handle_tools_list(request_id)
        elif method == "tools/call":
            handle_tools_call(request_id, request.get("params", {}))

if __name__ == "__main__":
    main()
PYEOF
chmod +x wordcount_server.py
```

This server provides two tools: `word_count` (analyze a file) and `count_text` (analyze a string). Let's test each interaction.

First, create a test file:

```bash
cat > sample.txt << 'EOF'
The quick brown fox
jumps over the lazy dog.
This is a test file
for the word count server.
EOF
```

Now send an initialize request:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | python3 wordcount_server.py
```

Expected output includes `"serverInfo": {"name": "wordcount-server", "version": "1.0.0"}`.

Now list tools:

```bash
echo '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | python3 wordcount_server.py | python3 -m json.tool
```

You'll see both `word_count` and `count_text` with their schemas.

Now call `word_count` on your test file:

```bash
echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"word_count","arguments":{"filepath":"sample.txt"}}}' | python3 wordcount_server.py | python3 -m json.tool
```

Expected output:
```
{
    "jsonrpc": "2.0",
    "id": 3,
    "result": {
        "content": [
            {
                "type": "text",
                "text": "File: sample.txt\nLines: 4\nWords: 16\nCharacters: 83"
            }
        ]
    }
}
```

Now call `count_text` on a raw string:

```bash
echo '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"count_text","arguments":{"text":"hello world"}}}' | python3 wordcount_server.py | python3 -m json.tool
```

Expected output shows 1 line, 2 words, 11 characters.

## Check Your Work

Create a comprehensive test script that verifies every tool and edge case:

```bash
cat > test_wordcount_server.sh << 'SHEOF'
#!/bin/bash
set -e
PASS=0
FAIL=0

run_test() {
    local name="$1"
    local input="$2"
    local check="$3"

    RESP=$(echo "$input" | python3 wordcount_server.py)
    if echo "$RESP" | python3 -c "import sys,json; $check" 2>/dev/null; then
        echo "PASS: $name"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $name"
        echo "  Response: $RESP"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== Word Count Server Tests ==="
echo ""

run_test "Initialize" \
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' \
    'd=json.load(sys.stdin); assert d["result"]["serverInfo"]["name"]=="wordcount-server"'

run_test "Tools list has word_count" \
    '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
    'd=json.load(sys.stdin); names=[t["name"] for t in d["result"]["tools"]]; assert "word_count" in names'

run_test "Tools list has count_text" \
    '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
    'd=json.load(sys.stdin); names=[t["name"] for t in d["result"]["tools"]]; assert "count_text" in names'

run_test "word_count on sample.txt" \
    '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"word_count","arguments":{"filepath":"sample.txt"}}}' \
    'd=json.load(sys.stdin); text=d["result"]["content"][0]["text"]; assert "Words:" in text'

run_test "count_text on hello world" \
    '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"count_text","arguments":{"text":"hello world"}}}' \
    'd=json.load(sys.stdin); text=d["result"]["content"][0]["text"]; assert "Words: 2" in text'

run_test "word_count on nonexistent file returns error" \
    '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"word_count","arguments":{"filepath":"no_such_file.txt"}}}' \
    'd=json.load(sys.stdin); assert "error" in d'

run_test "Unknown tool returns error" \
    '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"nonexistent_tool","arguments":{}}}' \
    'd=json.load(sys.stdin); assert "error" in d'

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
SHEOF
chmod +x test_wordcount_server.sh
./test_wordcount_server.sh
```

You should see all 7 tests pass.

Now create the `mcp.json` entry that would wire this server into Qwen Code:

```bash
cat > mcp-entry.json << 'EOF'
{
  "mcpServers": {
    "wordcount": {
      "command": "python3",
      "args": ["/path/to/project/wordcount_server.py"],
      "env": {},
      "disabled": false
    }
  }
}
EOF
echo "MCP configuration entry created."
```

This is what you would merge into your real `~/.config/qwen-code/mcp.json` to make the `word_count` and `count_text` tools available in every Qwen Code session.

## Debug It

The most common bug when building MCP servers: forgetting `flush=True` on the print statement. Without it, Python buffers stdout and Qwen Code waits forever for a response that's stuck in the buffer.

Introduce the bug:

```bash
cp wordcount_server.py wordcount_buffered.py
sed -i 's/print(json.dumps(msg), flush=True)/print(json.dumps(msg))/' wordcount_buffered.py
```

Now try to talk to the buffered version:

```bash
timeout 2 bash -c 'echo "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"test\",\"version\":\"1.0\"}}}" | python3 wordcount_buffered.py' || echo "TIMEOUT: Server did not respond (buffering issue)"
```

The `timeout` command kills the process after 2 seconds because the response never arrives. The fix is simple: always use `flush=True`.

Another common bug: not handling JSON parsing errors. If Qwen Code sends malformed JSON, your server shouldn't crash — it should skip the bad line and keep listening.

Test the crash scenario:

```bash
echo "not valid json" | python3 wordcount_server.py
echo "Exit code: $?"
```

The server exits cleanly with code 0 because the `try/except` catches the JSON error and continues. If you removed that error handling, the server would crash and Qwen Code would lose all tools from that server permanently.

## What You Learned

Building an MCP server is writing a stdin/stdout loop that handles three JSON-RPC methods — initialize, tools/list, and tools/call — and always flushes stdout after writing.

**Module 7 Complete!** You've learned what MCP servers are, connected one, understood how MCP and built-in tools coexist, explored popular servers, configured them in mcp.json, and built your own from scratch. *Next: Module 8 — Agents & Sub-Agents — You'll learn to launch autonomous sub-processes that work independently on complex tasks.*
