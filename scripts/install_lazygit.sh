#!/usr/bin/env bash

set -e

echo "Installing lazygit..."

# Check if lazygit is already installed
if command -v "$HOME/.local/bin/lazygit" &> /dev/null; then
    echo "lazygit already installed at $HOME/.local/bin/lazygit"
    exit 0
fi

# Ensure ~/.local/bin directory exists
mkdir -p "$HOME/.local/bin"

# Download lazygit tarball
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Downloading lazygit..."
# Get latest release version
LATEST_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')
curl -LO "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LATEST_VERSION}_Linux_x86_64.tar.gz"

# Extract and install binary
echo "Extracting lazygit to $HOME/.local/bin"
tar -xzf "lazygit_${LATEST_VERSION}_Linux_x86_64.tar.gz" lazygit
cp lazygit "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/lazygit"

# Clean up
cd -
rm -rf "$TEMP_DIR"

echo "lazygit installation complete!"
