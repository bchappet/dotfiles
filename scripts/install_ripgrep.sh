#!/usr/bin/env bash

set -e

echo "Installing ripgrep..."

# Check if ripgrep is already installed
if command -v "$HOME/.local/bin/rg" &> /dev/null; then
    echo "ripgrep already installed at $HOME/.local/bin/rg"
    exit 0
fi

# Ensure ~/.local/bin directory exists
mkdir -p "$HOME/.local/bin"

# Download ripgrep tarball
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Downloading ripgrep..."
# Get latest release version
LATEST_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -LO "https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${LATEST_VERSION}-x86_64-unknown-linux-musl.tar.gz"

# Extract and install binary
echo "Extracting ripgrep to $HOME/.local/bin"
tar -xzf "ripgrep-${LATEST_VERSION}-x86_64-unknown-linux-musl.tar.gz"
cp "ripgrep-${LATEST_VERSION}-x86_64-unknown-linux-musl/rg" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/rg"

# Clean up
cd -
rm -rf "$TEMP_DIR"

echo "ripgrep installation complete!"
