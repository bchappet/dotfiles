#!/usr/bin/env bash

set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
VERBOSE=false
NO_CACHE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verbose, -v Enable verbose output"
            echo "  --no-cache    Force rebuild without using cache"
            echo "  --help, -h    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run with --help for usage information"
            exit 1
            ;;
    esac
done

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Docker image name
IMAGE_NAME="dotfiles-test:ubuntu-22.04"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Dotfiles Installation Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo ""
    echo "Please install Docker first:"
    echo "  https://docs.docker.com/get-docker/"
    echo ""
    exit 1
fi

# Check if Docker daemon is accessible
DOCKER_CHECK=$(timeout 5 docker info 2>&1 || echo "timeout")
if echo "$DOCKER_CHECK" | grep -q "permission denied"; then
    echo -e "${RED}Error: Permission denied accessing Docker${NC}"
    echo ""
    echo "Fix by adding your user to the docker group:"
    echo "  sudo usermod -aG docker \$USER"
    echo "  newgrp docker"
    echo ""
    echo "Or restart your WSL session:"
    echo "  wsl --shutdown  # in Windows PowerShell"
    echo ""
    exit 1
elif echo "$DOCKER_CHECK" | grep -q -E "Cannot connect to the Docker daemon|timeout"; then
    echo -e "${RED}Error: Docker daemon is not running${NC}"
    echo ""
    echo "Please start Docker and try again"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker installed: $(docker --version)"
echo ""

# Build Docker image
echo -e "${BLUE}Building Docker image...${NC}"
echo ""

cd "$REPO_ROOT"

# Build the Docker image
if [ "$VERBOSE" = true ]; then
    if [ "$NO_CACHE" = true ]; then
        docker build --no-cache -f tests/Dockerfile -t "$IMAGE_NAME" .
    else
        docker build -f tests/Dockerfile -t "$IMAGE_NAME" .
    fi
    BUILD_EXIT_CODE=$?
else
    if [ "$NO_CACHE" = true ]; then
        docker build --no-cache -f tests/Dockerfile -t "$IMAGE_NAME" . 2>&1 | grep -E "(Step|Successfully|ERROR)"
    else
        docker build -f tests/Dockerfile -t "$IMAGE_NAME" . 2>&1 | grep -E "(Step|Successfully|ERROR)"
    fi
    BUILD_EXIT_CODE=${PIPESTATUS[0]}
fi

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo ""
    echo -e "${RED}✗ Docker build failed${NC}"
    echo ""
    echo "Run with --verbose to see full build output"
    exit 1
fi

echo ""
echo -e "${GREEN}✓${NC} Image built successfully"
echo ""

# Run the container
echo -e "${BLUE}Running installation tests...${NC}"
echo ""

if [ "$VERBOSE" = true ]; then
    docker run --rm "$IMAGE_NAME"
    TEST_EXIT_CODE=$?
else
    docker run --rm "$IMAGE_NAME" 2>&1
    TEST_EXIT_CODE=$?
fi

echo ""

# Check test results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    echo -e "${BLUE}========================================${NC}"
    exit 0
else
    echo -e "${BLUE}========================================${NC}"
    echo -e "${RED}✗ TESTS FAILED${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "To debug, run:"
    echo "  docker run --rm -it $IMAGE_NAME bash"
    echo ""
    exit 1
fi
