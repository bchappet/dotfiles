#!/usr/bin/env bash

set -e

echo "Installing Neovim..."

# Check if neovim is already installed
if [ -d "$HOME/.local/nvim-linux64" ]; then
    echo "Neovim already installed at $HOME/.local/nvim-linux64"
    exit 0
fi

# Download neovim tarball
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Downloading Neovim..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

# Ensure ~/.local directory exists
mkdir -p "$HOME/.local"

# Extract to ~/.local (no sudo required)
echo "Extracting Neovim to $HOME/.local/bin"
tar -C "$HOME/.local" -xzf nvim-linux-x86_64.tar.gz
ln -s "$HOME/.local/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"

# Clean up
cd -
rm -rf "$TEMP_DIR"

echo "Neovim installation complete!"
