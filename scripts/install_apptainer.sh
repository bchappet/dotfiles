#!/bin/bash
set -e

echo "=== Apptainer Installation Script for WSL2 ==="
echo ""

# Configuration
GO_VERSION="1.21.5"
APPTAINER_VERSION="1.3.5"
GO_OS="linux"
GO_ARCH="amd64"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Check if running on WSL
if ! grep -qi microsoft /proc/version; then
    print_error "This script is designed for WSL2. Are you sure you want to continue?"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update package list
print_info "Updating package lists..."
sudo apt-get update

# Install dependencies
print_info "Installing build dependencies..."
sudo apt-get install -y \
    build-essential \
    libseccomp-dev \
    pkg-config \
    uidmap \
    squashfs-tools \
    fakeroot \
    cryptsetup \
    tzdata \
    dh-apparmor \
    curl \
    wget \
    git

print_status "Dependencies installed"

# Check if Go is already installed
if command -v go &> /dev/null; then
    CURRENT_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    print_info "Go is already installed (version $CURRENT_GO_VERSION)"
    read -p "Do you want to reinstall Go $GO_VERSION? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_GO=true
    else
        INSTALL_GO=false
    fi
else
    INSTALL_GO=true
fi

# Install Go
if [ "$INSTALL_GO" = true ]; then
    print_info "Downloading Go ${GO_VERSION}..."
    cd /tmp
    wget -q --show-progress https://dl.google.com/go/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz

    print_info "Installing Go..."
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
    rm go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz

    # Add Go to PATH if not already present
    if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
        echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc
        print_status "Added Go to PATH in ~/.bashrc"
    fi

    export PATH=/usr/local/go/bin:$PATH
    print_status "Go ${GO_VERSION} installed successfully"
else
    export PATH=/usr/local/go/bin:$PATH
fi

# Verify Go installation
if ! command -v go &> /dev/null; then
    print_error "Go installation failed"
    exit 1
fi

print_info "Go version: $(go version)"

# Download Apptainer
print_info "Downloading Apptainer ${APPTAINER_VERSION}..."
cd /tmp
wget -q --show-progress https://github.com/apptainer/apptainer/releases/download/v${APPTAINER_VERSION}/apptainer-${APPTAINER_VERSION}.tar.gz

print_info "Extracting Apptainer..."
tar -xzf apptainer-${APPTAINER_VERSION}.tar.gz
cd apptainer-${APPTAINER_VERSION}

# Build Apptainer
print_info "Configuring Apptainer build..."
./mconfig

print_info "Building Apptainer (this may take a few minutes)..."
make -C builddir

print_info "Installing Apptainer..."
sudo make -C builddir install

# Cleanup
cd /tmp
rm -rf apptainer-${APPTAINER_VERSION} apptainer-${APPTAINER_VERSION}.tar.gz

print_status "Apptainer ${APPTAINER_VERSION} installed successfully"

# Verify installation
echo ""
print_info "Verifying installation..."
if command -v apptainer &> /dev/null; then
    print_status "Apptainer is installed and available in PATH"
    apptainer --version
    echo ""
    print_status "Installation complete!"
    echo ""
    print_info "Note: You may need to run 'source ~/.bashrc' or restart your terminal for PATH changes to take effect."
    echo ""
    print_info "To use Apptainer on WSL2, you'll typically use fakeroot mode:"
    echo "  apptainer build --fakeroot myimage.sif docker://ubuntu:latest"
    echo ""
else
    print_error "Apptainer installation verification failed"
    exit 1
fi
