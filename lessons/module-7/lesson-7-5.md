---
module: 7
lesson: 5
title: "Configuring MCP Servers"
prerequisites: ["module-7/lesson-7-4"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

## The Problem

You've seen what MCP servers can do, but now you need to actually configure them. Real MCP servers need authentication tokens, environment variables, file path restrictions, and other settings. If you get the configuration wrong, the server won't start, the tools won't appear, or the calls will fail with cryptic auth errors. You need to understand the `mcp.json` format inside and out.

## Mental Model

The `mcp.json` file is a recipe book. Each recipe tells Qwen Code how to launch one MCP server: what command to run, what arguments to pass, and what environment variables to set. When Qwen Code starts, it reads every recipe, launches every server, and collects all the tools. If a recipe is wrong, that server fails silently and its tools never appear.

## Try It

You'll create a complete `mcp.json` configuration file with multiple servers, then validate it and simulate the startup process.

Create your working directory:

```bash
mkdir -p ~/qwen-course-work/module-7/config
cd ~/qwen-course-work/module-7/config
```

Now create a realistic `mcp.json` configuration:

```bash
cat > mcp.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token_here"
      },
      "disabled": false
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/documents",
        "/home/user/projects"
      ],
      "disabled": false
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:password@localhost:5432/mydb"
      },
      "disabled": false
    },
    "broken-server": {
      "command": "nonexistent-command",
      "args": [],
      "env": {},
      "disabled": false
    },
    "disabled-server": {
      "command": "some-server",
      "args": [],
      "env": {},
      "disabled": true
    }
  }
}
EOF
```

This configuration defines five MCP servers. Let's break down each field:

- `mcpServers` — the top-level key. Every server lives inside this object.
- Server name (`github`, `filesystem`, etc.) — your chosen label. This appears in tool names and logs.
- `command` — the executable to run. Often `npx` for npm packages, `python3` for Python scripts, or a direct path to a binary.
- `args` — command-line arguments passed to the command. For `npx`, the `-y` flag auto-confirms installation, followed by the package name.
- `env` — environment variables set before launching the server. This is where tokens and API keys go.
- `disabled` — set to `true` to temporarily disable a server without deleting its config.

Validate the JSON and inspect the configuration:

```bash
python3 -c "
import json

data = json.load(open('mcp.json'))
servers = data['mcpServers']

print(f'Total servers defined: {len(servers)}')
print()

for name, config in servers.items():
    status = 'DISABLED' if config.get('disabled') else 'ACTIVE'
    cmd = config.get('command', 'unknown')
    args = config.get('args', [])
    env_keys = list(config.get('env', {}).keys())

    print(f'  [{status}] {name}')
    print(f'    Command: {cmd}')
    print(f'    Args: {args}')
    print(f'    Env vars: {env_keys if env_keys else \"(none)\"}')
    print()
"
```

Expected output:
```
Total servers defined: 5

  [ACTIVE] github
    Command: npx
    Args: ['-y', '@modelcontextprotocol/server-github']
    Env vars: ['GITHUB_TOKEN']

  [ACTIVE] filesystem
    Command: npx
    Args: ['-y', '@modelcontextprotocol/server-filesystem', '/home/user/documents', '/home/user/projects']
    Env vars: (none)

  [ACTIVE] postgres
    Command: npx
    Args: ['-y', '@modelcontextprotocol/server-postgres']
    Env vars: ['DATABASE_URL']

  [ACTIVE] broken-server
    Command: nonexistent-command
    Args: []
    Env vars: (none)

  [DISABLED] disabled-server
    Command: some-server
    Args: []
    Env vars: (none)
```

Now simulate what happens when Qwen Code tries to launch each server:

```bash
cat > simulate_startup.py << 'PYEOF'
#!/usr/bin/env python3
"""Simulate Qwen Code launching each MCP server."""
import json
import shutil

data = json.load(open("mcp.json"))
servers = data["mcpServers"]

print("=== MCP Server Startup Simulation ===")
print()

for name, config in servers.items():
    if config.get("disabled"):
        print(f"  SKIP  {name} (disabled in config)")
        continue

    cmd = config.get("command", "")
    # Check if the command exists on this system
    found = shutil.which(cmd) is not None

    if found:
        print(f"  OK    {name} ({cmd} found on PATH)")
    else:
        print(f"  FAIL  {name} (command '{cmd}' not found on PATH)")

print()
print("Startup simulation complete.")
PYEOF
python3 simulate_startup.py
```

On your system, `npx` might or might not be installed. Either way, this script shows you which servers would actually start.

## Check Your Work

Verify three critical rules for `mcp.json`:

1. Every server must have a `command` field.
2. `env` must be an object (not a string or null).
3. No two servers should share the same name.

```bash
cat > validate_mcp.py << 'PYEOF'
#!/usr/bin/env python3
"""Validate mcp.json against MCP configuration rules."""
import json
import sys

data = json.load(open("mcp.json"))
servers = data.get("mcpServers", {})
errors = []

if not isinstance(servers, dict):
    print("FATAL: mcpServers must be an object")
    sys.exit(1)

for name, config in servers.items():
    if "command" not in config:
        errors.append(f"{name}: missing 'command' field")
    if "args" not in config:
        errors.append(f"{name}: missing 'args' field (use empty array [])")
    elif not isinstance(config["args"], list):
        errors.append(f"{name}: 'args' must be an array")
    if "env" not in config:
        config["env"] = {}
    elif not isinstance(config["env"], dict):
        errors.append(f"{name}: 'env' must be an object")

if errors:
    print(f"Found {len(errors)} error(s):")
    for err in errors:
        print(f"  - {err}")
    sys.exit(1)
else:
    print(f"All {len(servers)} server entries are valid!")
PYEOF
python3 validate_mcp.py
```

You should see `All 5 server entries are valid!` even though `broken-server` has a nonexistent command — the validator only checks structure, not whether the command actually exists. That's correct: the config format is valid, the command just won't launch.

## Debug It

Here are three common configuration mistakes and how to fix each one.

**Mistake 1: Typo in the command name.**

```bash
cat > bad-mcp.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "command": "npxp",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {}
    }
  }
}
EOF
python3 -c "import shutil; print('npxp exists:', shutil.which('npxp') is not None)"
```

The typo `npxp` instead of `npx` means the server silently fails to start. Fix: correct the command name.

**Mistake 2: Missing env variable that the server requires.**

```bash
python3 -c "
import json
data = json.load(open('mcp.json'))
# Remove GITHUB_TOKEN from github server
data['mcpServers']['github']['env'] = {}
json.dump(data, open('mcp-no-token.json', 'w'), indent=2)
print('Created mcp-no-token.json without GITHUB_TOKEN')
"
```

The GitHub MCP server will start but every tool call will fail with an authentication error. The server runs but is useless without the token. Fix: add the `GITHUB_TOKEN` env variable.

**Mistake 3: Args as a string instead of an array.**

```bash
cat > bad-args.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": "-y @modelcontextprotocol/server-filesystem /home/user",
      "env": {}
    }
  }
}
EOF
python3 -c "
import json
data = json.load(open('bad-args.json'))
args = data['mcpServers']['filesystem']['args']
print(f'args type: {type(args).__name__}')
print(f'Is array: {isinstance(args, list)}')
"
```

When `args` is a string instead of an array, the command receives one giant argument instead of being split properly. Fix: use an array `["-y", "@modelcontextprotocol/server-filesystem", "/home/user"]`.

Correct all three issues:

```bash
cat > mcp.json << 'EOF'
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_your_token_here"
      },
      "disabled": false
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/documents",
        "/home/user/projects"
      ],
      "disabled": false
    }
  }
}
EOF
echo "Fixed configuration written."
```

## What You Learned

The mcp.json file defines each server with a command, arguments, environment variables, and a disabled flag — and any mistake in this file silently prevents that server's tools from appearing.

*Next: Lesson 7.6 — Building Your Own MCP Server — You'll write a complete MCP server in Python from scratch.*
