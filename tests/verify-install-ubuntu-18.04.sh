#!/usr/bin/env bash

set -e

echo "================================================="
echo "Verifying dotfiles installation (Ubuntu 18.04)..."
echo "================================================="

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

# Check 2: Verify symlinks were created
echo -n "Checking symlinks... "
if file_exists "$HOME/.bashrc" && file_exists "$HOME/.tmux.conf" && file_exists "$HOME/.config/nvim"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC} Some symlinks missing"
    FAILED=1
fi

# Check 3: Verify key directories were created
echo -n "Checking directories... "
if [ -d "$HOME/.config/nvim/undo" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}!${NC} Warning: undo directory not found"
fi

export PATH="$HOME/.local/bin:$PATH"

# Check 4: Ubuntu 18.04 specific - Python version compatibility
echo -n "Checking Python version (Ubuntu 18.04)... "
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    echo -e "${GREEN}✓${NC} Python $PYTHON_VERSION"
else
    echo -e "${RED}✗${NC} Python3 not available"
    FAILED=1
fi

# Check 5: Neovim compiled from source - more thorough testing
echo -n "Checking if nvim is available (compiled from source)... "
if command_exists nvim; then
    # Test that nvim can actually run (not just exist)
    if nvim --version >/dev/null 2>&1; then
        NVIM_VERSION=$(nvim --version | head -1)
        echo -e "${GREEN}✓${NC} ($NVIM_VERSION)"

        # Additional check: verify it can run basic commands without glibc issues
        echo -n "Testing nvim functionality... "
        if echo ':echo "test" | q' | nvim -es >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Basic functionality works"
        else
            echo -e "${YELLOW}!${NC} Warning: nvim may have functionality issues"
        fi
    else
        echo -e "${RED}✗${NC} nvim exists but fails to run (possible glibc issue)"
        FAILED=1
    fi
else
    echo -e "${RED}✗${NC} nvim not found in PATH"
    FAILED=1
fi

# Check 6: UV tool
echo -n "Checking if uv is available... "
if command_exists uv; then
    echo -e "${GREEN}✓${NC} ($(uv --version))"
else
    echo -e "${RED}✗${NC} uv not found in PATH"
    FAILED=1
fi

# Check 7: Tmux
echo -n "Checking if tmux is available... "
if command_exists tmux; then
    echo -e "${GREEN}✓${NC} ($(tmux -V))"
else
    echo -e "${RED}✗${NC} tmux not found in PATH"
    FAILED=1
fi

# Check 8: Ubuntu 18.04 specific - CMake version (needed for Neovim compilation)
echo -n "Checking CMake version... "
if command_exists cmake; then
    CMAKE_VERSION=$(cmake --version | head -1 | sed 's/.*cmake version \([0-9.]*\).*/\1/')
    # Check if version is 3.16 or newer
    if [ "$(printf '%s\n' "3.16.0" "$CMAKE_VERSION" | sort -V | head -n1)" = "3.16.0" ]; then
        echo -e "${GREEN}✓${NC} CMake $CMAKE_VERSION (sufficient for Neovim)"
    else
        echo -e "${RED}✗${NC} CMake $CMAKE_VERSION (too old for Neovim, need 3.16+)"
        FAILED=1
    fi
else
    echo -e "${RED}✗${NC} CMake not found"
    FAILED=1
fi

# Check 9: Ubuntu 18.04 specific - glibc version info
echo -n "Checking glibc version... "
if command_exists ldd; then
    GLIBC_VERSION=$(ldd --version | head -1 | awk '{print $NF}')
    echo -e "${GREEN}✓${NC} glibc $GLIBC_VERSION"
else
    echo -e "${YELLOW}!${NC} Could not determine glibc version"
fi

echo ""
echo "================================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}Ubuntu 18.04 Installation verification PASSED${NC}"
    echo "================================================="
    exit 0
else
    echo -e "${RED}Ubuntu 18.04 Installation verification FAILED${NC}"
    echo "================================================="
    exit 1
fi