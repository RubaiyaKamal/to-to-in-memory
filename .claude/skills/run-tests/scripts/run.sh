#!/bin/bash

# Run Tests Script
# Execute automated tests for the to-do application

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEST_TYPE="${1:-all}"
PHASE="${2:-phase-2}"
EXTRA_ARGS="${@:3}"

# Function to run backend tests
run_backend_tests() {
    local backend_dir="$1"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}Running Backend Tests${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo ""

    if [ ! -d "$backend_dir" ]; then
        echo -e "${RED}Backend directory not found: $backend_dir${NC}"
        return 1
    fi

    cd "$backend_dir"

    # Activate virtual environment
    if [ -d "venv" ]; then
        source venv/bin/activate || source venv/Scripts/activate 2>/dev/null
    fi

    # Install test dependencies
    pip install -q pytest pytest-cov pytest-asyncio

    # Run tests
    if [[ "$EXTRA_ARGS" == *"--coverage"* ]]; then
        echo -e "${GREEN}Running tests with coverage...${NC}"
        pytest --cov=. --cov-report=html --cov-report=term -v
        echo ""
        echo -e "${GREEN}Coverage report generated in htmlcov/index.html${NC}"
    else
        pytest -v $EXTRA_ARGS
    fi

    local exit_code=$?
    cd - > /dev/null

    return $exit_code
}

# Function to run frontend tests
run_frontend_tests() {
    local frontend_dir="$1"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}Running Frontend Tests${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo ""

    if [ ! -d "$frontend_dir" ]; then
        echo -e "${RED}Frontend directory not found: $frontend_dir${NC}"
        return 1
    fi

    cd "$frontend_dir"

    # Install dependencies
    npm install --silent

    # Run tests
    if [[ "$EXTRA_ARGS" == *"--coverage"* ]]; then
        echo -e "${GREEN}Running tests with coverage...${NC}"
        npm test -- --coverage --passWithNoTests
    elif [[ "$EXTRA_ARGS" == *"--watch"* ]]; then
        echo -e "${GREEN}Running tests in watch mode...${NC}"
        npm test -- --watch
    else
        npm test -- --passWithNoTests $EXTRA_ARGS
    fi

    local exit_code=$?
    cd - > /dev/null

    return $exit_code
}

# Function to run E2E tests
run_e2e_tests() {
    local e2e_dir="$1"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}Running E2E Tests${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo ""

    if [ ! -d "$e2e_dir" ]; then
        echo -e "${YELLOW}E2E directory not found: $e2e_dir${NC}"
        echo -e "${YELLOW}Skipping E2E tests...${NC}"
        return 0
    fi

    cd "$e2e_dir"

    # Install Playwright
    npm install --silent
    npx playwright install --with-deps

    # Run E2E tests
    if [[ "$EXTRA_ARGS" == *"--headed"* ]]; then
        npx playwright test --headed
    else
        npx playwright test
    fi

    local exit_code=$?
    cd - > /dev/null

    return $exit_code
}

# Main execution
echo -e "${GREEN}Test Execution for To-Do Application${NC}"
echo "Test Type: $TEST_TYPE"
echo "Phase: $PHASE"
echo ""

# Determine directories
if [ "$PHASE" = "phase-2" ]; then
    BACKEND_DIR="phase-2-nextjs/backend"
    FRONTEND_DIR="phase-2-nextjs/frontend"
    E2E_DIR="phase-2-nextjs/e2e"
elif [ "$PHASE" = "phase-3" ]; then
    BACKEND_DIR="phase-3-chatbot/backend"
    FRONTEND_DIR="phase-3-chatbot/frontend"
    E2E_DIR="phase-3-chatbot/e2e"
else
    echo -e "${RED}Invalid phase: $PHASE${NC}"
    exit 1
fi

# Execute tests based on type
EXIT_CODE=0

case "$TEST_TYPE" in
    all)
        run_backend_tests "$BACKEND_DIR" || EXIT_CODE=$?
        echo ""
        run_frontend_tests "$FRONTEND_DIR" || EXIT_CODE=$?
        echo ""
        run_e2e_tests "$E2E_DIR" || EXIT_CODE=$?
        ;;
    backend)
        run_backend_tests "$BACKEND_DIR" || EXIT_CODE=$?
        ;;
    frontend)
        run_frontend_tests "$FRONTEND_DIR" || EXIT_CODE=$?
        ;;
    e2e)
        run_e2e_tests "$E2E_DIR" || EXIT_CODE=$?
        ;;
    *)
        echo -e "${RED}Invalid test type: $TEST_TYPE${NC}"
        echo "Usage: $0 {all|backend|frontend|e2e} [phase-2|phase-3] [options]"
        exit 1
        ;;
esac

# Summary
echo ""
echo -e "${BLUE}=====================================${NC}"
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
else
    echo -e "${RED}Some tests failed! ✗${NC}"
fi
echo -e "${BLUE}=====================================${NC}"

exit $EXIT_CODE
