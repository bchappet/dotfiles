#!/usr/bin/env bash

set -e

echo "Auto-detecting Ubuntu version for Neovim installation..."

# Function to get Ubuntu version
get_ubuntu_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            echo "$VERSION_ID"
            return 0
        fi
    fi

    # Fallback: try lsb_release
    if command -v lsb_release >/dev/null 2>&1; then
        local distrib_id=$(lsb_release -i -s 2>/dev/null)
        if [ "$distrib_id" = "Ubuntu" ]; then
            lsb_release -r -s 2>/dev/null
            return 0
        fi
    fi

    # If we can't determine, default to empty (will use standard script)
    echo ""
    return 1
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect Ubuntu version
UBUNTU_VERSION=$(get_ubuntu_version)

if [ "$UBUNTU_VERSION" = "18.04" ]; then
    echo "Detected Ubuntu 18.04 - using source compilation method"
    exec "$SCRIPT_DIR/install_neovim_ubuntu18.sh"
else
    echo "Detected Ubuntu $UBUNTU_VERSION (or non-Ubuntu) - using binary download method"
    exec "$SCRIPT_DIR/install_neovim.sh"
fi