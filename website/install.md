---
title: "Install Qwen Code"
---

# Installing Qwen Code

## Prerequisites

You need **Node.js** installed. Check with:

```bash
node --version
```

If you see a version number (v18 or higher), you're good. If not:

### Installing Node.js

**Using nvm (recommended):**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# Close and reopen your terminal, then:
nvm install node
```

**Using package manager:**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install nodejs npm

# macOS
brew install node

# Windows
# Download from https://nodejs.org
```

## Install Qwen Code

```bash
npm install -g @qwen-code/qwen-code
```

## Verify Installation

```bash
qwen --version
```

You should see a version number. If you get `command not found`, see troubleshooting below.

## Launch

```bash
qwen
```

You should see the Qwen Code welcome screen. Type `/quit` to exit.

## Troubleshooting

### "command not found: qwen"

Your PATH doesn't include npm's global bin directory:

```bash
# Find where npm installs global packages
npm config get prefix

# Add it to your PATH (add this line to ~/.bashrc or ~/.zshrc)
export PATH="$(npm config get prefix)/bin:$PATH"

# Reload your shell config
source ~/.bashrc  # or source ~/.zshrc
```

### "Permission denied"

Try:
```bash
npm install -g @qwen-code/qwen-code --prefix ~/.local
```

### Qwen Code crashes on startup

Check your Node.js version:
```bash
node --version
```
You need v18 or higher. If not, upgrade with `nvm install node`.
