#!/bin/bash

# Verify Setup Script
# Comprehensive verification of development environment

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PHASE="${1:-phase-2}"
FULL_CHECK=false
VERBOSE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --full) FULL_CHECK=true ;;
        --verbose) VERBOSE=true ;;
    esac
done

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to check and report
check() {
    local name="$1"
    local command="$2"
    local critical="${3:-true}"

    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}Checking: $name${NC}"
        echo "Command: $command"
    fi

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED++))
        return 0
    else
        if [ "$critical" = "true" ]; then
            echo -e "${RED}✗${NC} $name"
            ((FAILED++))
        else
            echo -e "${YELLOW}⚠${NC} $name (optional)"
            ((WARNINGS++))
        fi
        return 1
    fi
}

# Function to check file exists
check_file() {
    local name="$1"
    local file="$2"
    local critical="${3:-true}"

    check "$name" "test -f '$file'" "$critical"
}

# Function to check directory exists
check_dir() {
    local name="$1"
    local dir="$2"
    local critical="${3:-true}"

    check "$name" "test -d '$dir'" "$critical"
}

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Verifying Development Environment${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}Prerequisites:${NC}"
check "Python 3.9+" "command -v python3 && python3 --version | grep -E '3\\.(9|1[0-9])'"
check "Node.js 18+" "command -v node && node --version | grep -E 'v(1[8-9]|[2-9][0-9])'"
check "npm" "command -v npm"
check "Git" "command -v git" false
echo ""

# Determine directories
if [ "$PHASE" = "phase-2" ] || [ "$PHASE" = "all" ]; then
    BACKEND_DIR="phase-2-nextjs/backend"
    FRONTEND_DIR="phase-2-nextjs/frontend"

    echo -e "${BLUE}Phase 2 Backend:${NC}"
    check_dir "Backend directory exists" "$BACKEND_DIR"
    check_dir "Virtual environment exists" "$BACKEND_DIR/venv"
    check_file "requirements.txt exists" "$BACKEND_DIR/requirements.txt"
    check_file ".env file exists" "$BACKEND_DIR/.env"

    if [ -d "$BACKEND_DIR/venv" ]; then
        check "Backend dependencies installed" "[ -f '$BACKEND_DIR/venv/bin/activate' ] || [ -f '$BACKEND_DIR/venv/Scripts/activate' ]"
    fi

    echo ""

    echo -e "${BLUE}Phase 2 Frontend:${NC}"
    check_dir "Frontend directory exists" "$FRONTEND_DIR"
    check_dir "node_modules exists" "$FRONTEND_DIR/node_modules"
    check_file "package.json exists" "$FRONTEND_DIR/package.json"
    check_file ".env.local exists" "$FRONTEND_DIR/.env.local" false
    check_file "tsconfig.json exists" "$FRONTEND_DIR/tsconfig.json"
    echo ""
fi

if [ "$PHASE" = "phase-3" ] || [ "$PHASE" = "all" ]; then
    BACKEND_DIR="phase-3-chatbot/backend"
    FRONTEND_DIR="phase-3-chatbot/frontend"

    echo -e "${BLUE}Phase 3 Backend:${NC}"
    check_dir "Backend directory exists" "$BACKEND_DIR"
    check_dir "Virtual environment exists" "$BACKEND_DIR/venv"
    check_file "requirements.txt exists" "$BACKEND_DIR/requirements.txt"
    check_file ".env file exists" "$BACKEND_DIR/.env"

    if [ -f "$BACKEND_DIR/.env" ]; then
        check ".env contains OPENAI_API_KEY" "grep -q 'OPENAI_API_KEY' '$BACKEND_DIR/.env'"
    fi

    echo ""

    echo -e "${BLUE}Phase 3 Frontend:${NC}"
    check_dir "Frontend directory exists" "$FRONTEND_DIR"
    check_dir "node_modules exists" "$FRONTEND_DIR/node_modules"
    check_file "package.json exists" "$FRONTEND_DIR/package.json"
    check_file ".env.local exists" "$FRONTEND_DIR/.env.local" false
    echo ""
fi

# Full check - test services
if [ "$FULL_CHECK" = true ]; then
    echo -e "${BLUE}Service Health Checks:${NC}"

    if [ "$PHASE" = "phase-2" ] || [ "$PHASE" = "all" ]; then
        check "Phase 2 backend responds (port 8000)" "curl -f -s http://localhost:8000/health" false
        check "Phase 2 frontend responds (port 3000)" "curl -f -s http://localhost:3000" false
    fi

    if [ "$PHASE" = "phase-3" ] || [ "$PHASE" = "all" ]; then
        check "Phase 3 backend responds (port 8001)" "curl -f -s http://localhost:8001/health" false
        check "Phase 3 frontend responds (port 3001)" "curl -f -s http://localhost:3001" false
    fi

    echo ""
fi

# Summary
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Verification Summary${NC}"
echo -e "${BLUE}=====================================${NC}"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
fi
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
fi
echo ""

# Recommendations
if [ $FAILED -gt 0 ]; then
    echo -e "${YELLOW}Recommendations:${NC}"
    echo "- Run setup-phase skill to fix missing dependencies"
    echo "- Check .env files for required configuration"
    echo "- Ensure all prerequisites are installed"
    echo ""
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${GREEN}Setup is functional but some optional components are missing${NC}"
    exit 2
else
    echo -e "${GREEN}✓ All checks passed! Environment is ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Start backend: bash .claude/skills/start-backend/scripts/start.sh"
    echo "2. Start frontend: bash .claude/skills/start-frontend/scripts/start.sh"
    echo "3. Run tests: bash .claude/skills/run-tests/scripts/run.sh"
    echo ""
    exit 0
fi
