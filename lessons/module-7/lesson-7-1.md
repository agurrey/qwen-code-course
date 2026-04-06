---
module: 7
lesson: 1
title: "What Are MCP Servers"
prerequisites: []
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You've been using Qwen Code to write code, run commands, and edit files. But what if you need to fetch live data from an API, query a database, or interact with a service like Google Drive or GitHub? Qwen Code can't do those things on its own. It has no built-in weather tool, no database connector, no Google Drive integration. You hit a wall every time you need something outside Qwen Code's built-in toolset.

MCP servers solve this by letting you plug external tools into Qwen Code. Think of it like adding plugins to a browser — the browser works fine on its own, but with plugins it can do things it was never designed to do.

## Mental Model

An MCP server is a separate program that runs alongside Qwen Code and speaks a standard protocol (the Model Context Protocol). Qwen Code asks the server "what tools do you have?" and the server replies with a list. Those tools then appear alongside Qwen Code's built-in tools as if they were always there. You don't switch contexts or learn a new interface — you just get more tools.

## Try It

First, understand the protocol itself. MCP stands for Model Context Protocol. It's an open standard that lets any AI assistant (not just Qwen Code) connect to any tool server. The key idea: instead of hardcoding tools into the AI, you make tools discoverable at runtime.

Create a file that simulates what an MCP server advertises:

```bash
mkdir -p ~/qwen-course-work/module-7
cd ~/qwen-course-work/module-7
```

Now create a file that represents a simple tool catalog:

```bash
cat > mock-tools.json << 'EOF'
{
  "tools": [
    {
      "name": "get_weather",
      "description": "Get current weather for a city",
      "input_schema": {
        "type": "object",
        "properties": {
          "city": { "type": "string" }
        },
        "required": ["city"]
      }
    },
    {
      "name": "convert_currency",
      "description": "Convert between two currencies",
      "input_schema": {
        "type": "object",
        "properties": {
          "from": { "type": "string" },
          "to": { "type": "string" },
          "amount": { "type": "number" }
        },
        "required": ["from", "to", "amount"]
      }
    }
  ]
}
EOF
```

Read the file back to see its structure:

```bash
cat mock-tools.json
```

This JSON is exactly what an MCP server sends when Qwen Code asks "what tools do you offer?" Each tool has a name, a description the AI uses to decide when to call it, and an input_schema that tells the AI what parameters to pass.

Now ask Qwen Code to explain the structure in human terms:

```
Explain the structure of mock-tools.json. What does each field do?
```

Expected output: Qwen Code will describe how `tools` is an array, each tool has a `name` (how it's called), `description` (used by the AI to understand when to use it), and `input_schema` (defines what parameters the tool accepts, using JSON Schema format).

## Check Your Work

Verify your file is valid JSON:

```bash
python3 -c "import json; json.load(open('mock-tools.json')); print('Valid JSON')"
```

You should see `Valid JSON`. If you get a `JSONDecodeError`, open the file and check for missing commas or unbalanced braces.

To confirm the structure matches the MCP tool format, check that every tool has all three required fields:

```bash
python3 -c "
import json
data = json.load(open('mock-tools.json'))
for tool in data['tools']:
    assert 'name' in tool, f'Missing name in {tool}'
    assert 'description' in tool, f'Missing description in {tool}'
    assert 'input_schema' in tool, f'Missing input_schema in {tool}'
    print(f'OK: {tool[\"name\"]} has all required fields')
"
```

You should see both tools confirmed as valid.

## Debug It

Here's a broken version of the same file. The `convert_currency` tool is missing its `required` field in the input schema, which means the AI won't know which parameters are mandatory:

```bash
cat > broken-tools.json << 'EOF'
{
  "tools": [
    {
      "name": "get_weather",
      "description": "Get current weather for a city",
      "input_schema": {
        "type": "object",
        "properties": {
          "city": { "type": "string" }
        },
        "required": ["city"]
      }
    },
    {
      "name": "convert_currency",
      "description": "Convert between two currencies",
      "input_schema": {
        "type": "object",
        "properties": {
          "from": { "type": "string" },
          "to": { "type": "string" },
          "amount": { "type": "number" }
        }
      }
    }
  ]
}
EOF
```

Run the validation script against it:

```bash
python3 -c "
import json
data = json.load(open('broken-tools.json'))
for tool in data['tools']:
    schema = tool.get('input_schema', {})
    if 'required' not in schema:
        print(f'BUG: {tool[\"name\"]} is missing required fields in input_schema')
    else:
        print(f'OK: {tool[\"name\"]}')
"
```

You'll see the bug: `convert_currency is missing required fields in input_schema`. Fix it by adding `"required": ["from", "to", "amount"]` to the `input_schema` of the `convert_currency` tool.

Edit the file and add the missing line inside the `input_schema` object, right after the `properties` block:

```json
      "input_schema": {
        "type": "object",
        "properties": {
          "from": { "type": "string" },
          "to": { "type": "string" },
          "amount": { "type": "number" }
        },
        "required": ["from", "to", "amount"]
      }
```

Run the validation again to confirm the fix.

## What You Learned

MCP servers are separate programs that expose tools to Qwen Code through a standard protocol, making external services feel like built-in features.

*Next: Lesson 7.2 — Adding Your First MCP Server — You'll connect a real MCP server and use its tools live.*
