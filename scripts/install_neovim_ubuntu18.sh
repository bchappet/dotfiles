#!/usr/bin/env bash

set -e

echo "Installing Neovim from source (Ubuntu 18.04 compatibility)..."

# Check if neovim is already installed and working
if [ -f "$HOME/.local/bin/nvim" ] && "$HOME/.local/bin/nvim" --version >/dev/null 2>&1; then
    echo "Neovim already installed at $HOME/.local/bin/nvim"
    echo "Version: $(nvim --version | head -1)"
    exit 0
fi

# Function to check CMake version
check_cmake_version() {
    if command -v cmake >/dev/null 2>&1; then
        local cmake_version=$(cmake --version | head -1 | sed 's/.*cmake version \([0-9.]*\).*/\1/')
        local required_version="3.16.0"

        # Simple version comparison (works for x.y.z format)
        if [ "$(printf '%s\n' "$required_version" "$cmake_version" | sort -V | head -n1)" = "$required_version" ]; then
            echo "CMake version $cmake_version is sufficient"
            return 0
        else
            echo "CMake version $cmake_version is too old (need 3.16+)"
            return 1
        fi
    else
        echo "CMake not found"
        return 1
    fi
}

# Install newer CMake if needed (Ubuntu 18.04 ships with 3.10.2, Neovim needs 3.16+)
install_newer_cmake() {
    echo "Installing newer CMake for Ubuntu 18.04..."

    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Download CMake 3.20.0 (stable version that works well with Neovim)
    echo "Downloading CMake 3.20.0..."
    curl -L -O https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-x86_64.tar.gz

    # Extract to ~/.local
    echo "Installing CMake to ~/.local..."
    mkdir -p "$HOME/.local"
    tar -C "$HOME/.local" --strip-components=1 -xzf cmake-3.20.0-linux-x86_64.tar.gz

    # Clean up
    cd ~
    rm -rf "$temp_dir"

    # Update PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    echo "CMake installation complete!"
    cmake --version
}

# Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"

# Check and install newer CMake if needed
if ! check_cmake_version; then
    install_newer_cmake
fi

# Create temporary directory for building
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Cloning Neovim stable branch..."
git clone -b stable --depth 1 https://github.com/neovim/neovim.git
cd neovim

echo "Building Neovim from source..."

# Ensure ~/.local directory exists
mkdir -p "$HOME/.local"

# Configure with cmake - install to ~/.local
echo "Configuring build with cmake..."
make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$HOME/.local"

echo "Installing Neovim to $HOME/.local..."
make install

# Ensure ~/.local/bin is created and nvim is accessible
mkdir -p "$HOME/.local/bin"

# Clean up
cd ~
rm -rf "$TEMP_DIR"

# Verify installation
if [ -f "$HOME/.local/bin/nvim" ]; then
    echo "Neovim compilation and installation complete!"
    echo "Version: $("$HOME/.local/bin/nvim" --version | head -1)"
else
    echo "Error: Neovim installation failed - nvim binary not found"
    exit 1
fi