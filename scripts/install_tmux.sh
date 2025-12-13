#!/usr/bin/env bash

set -e

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "tmux not found, installing from source..."

    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    git clone https://github.com/tmux/tmux.git
    cd tmux

    sh autogen.sh
    ./configure --prefix="$HOME/.local"
    make
    make install

    cd ~
    rm -rf "$TEMP_DIR"

    echo "tmux installed successfully to ~/.local/bin"
else
    echo "tmux already installed ($(tmux -V))"
fi

# Ensure ~/.local/bin is in PATH for tpm installation
export PATH="$HOME/.local/bin:$PATH"

echo "Setting up Tmux Plugin Manager (tpm)..."

TPM_DIR="$HOME/.tmux/plugins/tpm"

# Install tpm if not present
if [ ! -d "$TPM_DIR" ]; then
    echo "Installing tpm..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "tpm already installed"
fi

# Install tmux plugins
echo "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins" || true

echo "tpm setup complete!"
