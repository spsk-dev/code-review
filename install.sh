#!/usr/bin/env bash
set -euo pipefail

PLUGIN_NAME="code-review"
REPO_URL="https://github.com/spsk-dev/code-review.git"
INSTALL_DIR="$HOME/.claude/plugins/$PLUGIN_NAME"

echo "SpSk — $PLUGIN_NAME installer"
echo ""

# Check prerequisites
if ! command -v git &> /dev/null; then
  echo "Error: git is required but not installed."
  exit 1
fi

if ! command -v claude &> /dev/null; then
  echo "Warning: Claude Code CLI not found. Plugin will be installed but won't activate until Claude Code is available."
fi

# Install
if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation..."
  cd "$INSTALL_DIR" && git pull origin main
else
  echo "Installing to $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo ""
echo "Installed: $INSTALL_DIR"
echo "Command:   /code-review <PR_NUMBER>"
echo ""
echo "Optional: install codex and gemini CLIs for 3-model consensus (Tier 1)"
echo "  Without them, the plugin runs Claude-only review (Tier 3)"
