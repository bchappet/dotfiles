#!/usr/bin/env bash

set -e

echo "Setting up vim-plug for Neovim..."

PLUG_DIR="$HOME/.local/share/nvim/site/autoload"
PLUG_FILE="$PLUG_DIR/plug.vim"

# Install vim-plug if not present
if [ ! -f "$PLUG_FILE" ]; then
    echo "Installing vim-plug..."
    curl -fLo "$PLUG_FILE" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "vim-plug already installed"
fi

# Install neovim plugins
echo "Installing Neovim plugins..."
# Use full path since nvim may not be in PATH yet during installation
"$HOME/.local/bin/nvim" --headless +PlugInstall +qa

echo "vim-plug setup complete!"
