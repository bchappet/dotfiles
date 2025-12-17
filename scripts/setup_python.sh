#!/usr/bin/env bash

set -e

echo "Setting up Python tools with uv..."

# Install uv if not present
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Source the profile to get uv in PATH for the current script
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "uv already installed"
fi

echo "Installing ruff..."
uv tool install ruff

echo "Python tools installation complete!"
echo "Tools installed in ~/.local/bin"
