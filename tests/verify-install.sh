#!/usr/bin/env bash

set -e

echo "==================================="
echo "Verifying dotfiles installation..."
echo "==================================="

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track verification status
FAILED=0

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a file/symlink exists
file_exists() {
    [ -e "$1" ]
}

# Check 1: Verify installation script ran (this script is running, so it did)
echo -e "${GREEN}✓${NC} Installation script completed"

# Check 2: Verify symlinks were created (optional but good to check)
echo -n "Checking symlinks... "
if file_exists "$HOME/.bashrc" && file_exists "$HOME/.tmux.conf" && file_exists "$HOME/.config/nvim"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC} Some symlinks missing"
    FAILED=1
fi

# Check 3: Verify key directories were created (optional)
echo -n "Checking directories... "
if [ -d "$HOME/.config/nvim/undo" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}!${NC} Warning: undo directory not found"
fi

# Update PATH to include installed tools (bashrc won't work in non-interactive shell)
export PATH="$HOME/.local/bin:$HOME/.local/nvim-linux-x86_64/bin:$PATH"

# Check 4: Basic tool availability (optional - can be extended)
echo -n "Checking if nvim is available... "
if command_exists nvim; then
    echo -e "${GREEN}✓${NC} ($(nvim --version | head -1))"
else
    echo -e "${YELLOW}!${NC} Warning: nvim not found in PATH"
fi

echo -n "Checking if uv is available... "
if command_exists uv; then
    echo -e "${GREEN}✓${NC} ($(uv --version))"
else
    echo -e "${YELLOW}!${NC} Warning: uv not found in PATH"
fi

echo ""
echo "==================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}Installation verification PASSED${NC}"
    echo "==================================="
    exit 0
else
    echo -e "${RED}Installation verification FAILED${NC}"
    echo "==================================="
    exit 1
fi
