#!/usr/bin/env bash

set -e

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
KEEP_CONTAINER=false
VERBOSE=false
FORCE_REBUILD=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --keep)
            KEEP_CONTAINER=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --rebuild|-r)
            FORCE_REBUILD=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --keep        Keep container image after tests"
            echo "  --verbose, -v Enable verbose output"
            echo "  --rebuild, -r Force rebuild of container"
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

# Container files
CONTAINER_DEF="$SCRIPT_DIR/apptainer/ubuntu-22.04.def"
CONTAINER_IMAGE="$SCRIPT_DIR/ubuntu-22.04.sif"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Dotfiles Installation Test Suite${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Apptainer is installed
if ! command -v apptainer &> /dev/null; then
    echo -e "${RED}Error: Apptainer is not installed${NC}"
    echo ""
    echo "Please install Apptainer first:"
    echo "  https://apptainer.org/docs/admin/main/installation.html"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓${NC} Apptainer installed: $(apptainer --version)"
echo ""

# Remove existing container if force rebuild
if [ "$FORCE_REBUILD" = true ] && [ -f "$CONTAINER_IMAGE" ]; then
    echo -e "${YELLOW}Removing existing container image...${NC}"
    rm -f "$CONTAINER_IMAGE"
fi

# Build container if it doesn't exist
if [ ! -f "$CONTAINER_IMAGE" ]; then
    echo -e "${BLUE}Building Apptainer container...${NC}"
    echo "Definition file: $CONTAINER_DEF"
    echo "Output image: $CONTAINER_IMAGE"
    echo ""

    cd "$REPO_ROOT"

    if [ "$VERBOSE" = true ]; then
        apptainer build "$CONTAINER_IMAGE" "$CONTAINER_DEF"
    else
        apptainer build "$CONTAINER_IMAGE" "$CONTAINER_DEF" 2>&1 | grep -E "(INFO|ERROR|FATAL)" || true
    fi

    echo ""
    echo -e "${GREEN}✓${NC} Container built successfully"
    echo ""
else
    echo -e "${GREEN}✓${NC} Using existing container image"
    echo "  (use --rebuild to force rebuild)"
    echo ""
fi

# Run the container
echo -e "${BLUE}Running installation tests...${NC}"
echo ""

cd "$REPO_ROOT"

if [ "$VERBOSE" = true ]; then
    apptainer run --contain "$CONTAINER_IMAGE"  # contain to avoid mounting home
    TEST_EXIT_CODE=$?
else
    apptainer run --contain "$CONTAINER_IMAGE" 2>&1
    TEST_EXIT_CODE=$?
fi

echo ""

# Check test results
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✓ ALL TESTS PASSED${NC}"
    echo -e "${BLUE}========================================${NC}"
    OVERALL_EXIT=0
else
    echo -e "${BLUE}========================================${NC}"
    echo -e "${RED}✗ TESTS FAILED${NC}"
    echo -e "${BLUE}========================================${NC}"
    OVERALL_EXIT=1
fi

# Cleanup
if [ "$KEEP_CONTAINER" = false ] && [ "$OVERALL_EXIT" -eq 0 ]; then
    echo ""
    echo "Cleaning up container image..."
    rm -f "$CONTAINER_IMAGE"
    echo -e "${GREEN}✓${NC} Cleanup complete"
else
    if [ "$KEEP_CONTAINER" = true ]; then
        echo ""
        echo "Container image kept at: $CONTAINER_IMAGE"
    elif [ "$OVERALL_EXIT" -ne 0 ]; then
        echo ""
        echo "Container image kept for debugging: $CONTAINER_IMAGE"
        echo "To inspect: apptainer shell $CONTAINER_IMAGE"
    fi
fi

echo ""
exit $OVERALL_EXIT
