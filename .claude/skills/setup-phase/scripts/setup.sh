#!/bin/bash

# Setup Phase Environment Script
# Complete environment setup for a specific phase

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PHASE="${1:-phase-2}"

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"

    # Check Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Python 3 not found. Please install Python 3.9+${NC}"
        exit 1
    fi

    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}✓ Python $PYTHON_VERSION${NC}"

    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo -e "${RED}Node.js not found. Please install Node.js 18+${NC}"
        exit 1
    fi

    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js $NODE_VERSION${NC}"

    # Check npm
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}npm not found. Please install npm${NC}"
        exit 1
    fi

    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓ npm $NPM_VERSION${NC}"

    echo ""
}

# Function to setup backend
setup_backend() {
    local backend_dir="$1"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}Setting up Backend${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo ""

    if [ ! -d "$backend_dir" ]; then
        echo -e "${RED}Backend directory not found: $backend_dir${NC}"
        return 1
    fi

    cd "$backend_dir"

    # Create virtual environment
    if [ ! -d "venv" ]; then
        echo -e "${GREEN}Creating virtual environment...${NC}"
        python3 -m venv venv
    else
        echo -e "${YELLOW}Virtual environment already exists${NC}"
    fi

    # Activate virtual environment
    echo -e "${GREEN}Activating virtual environment...${NC}"
    source venv/bin/activate || source venv/Scripts/activate 2>/dev/null

    # Upgrade pip
    echo -e "${GREEN}Upgrading pip...${NC}"
    pip install -q --upgrade pip

    # Install dependencies
    if [ -f "requirements.txt" ]; then
        echo -e "${GREEN}Installing dependencies...${NC}"
        pip install -q -r requirements.txt
    fi

    # Create .env file
    if [ ! -f ".env" ]; then
        echo -e "${GREEN}Creating .env file...${NC}"
        if [ -f ".env.example" ]; then
            cp .env.example .env
            echo -e "${YELLOW}Please edit .env and configure your settings${NC}"
        else
            cat > .env << 'EOF'
DATABASE_URL=sqlite:///./database.db
JWT_SECRET_KEY=your-secret-key-change-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF
            echo -e "${YELLOW}.env created with defaults. Please update JWT_SECRET_KEY${NC}"
        fi
    else
        echo -e "${YELLOW}.env file already exists${NC}"
    fi

    # Initialize database
    echo -e "${GREEN}Initializing database...${NC}"
    if [ -f "db.py" ]; then
        python -c "from db import init_db; init_db()" 2>/dev/null || echo -e "${YELLOW}Database might already be initialized${NC}"
    fi

    cd - > /dev/null
    echo -e "${GREEN}✓ Backend setup complete${NC}"
    echo ""
}

# Function to setup frontend
setup_frontend() {
    local frontend_dir="$1"
    local backend_port="$2"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}Setting up Frontend${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo ""

    if [ ! -d "$frontend_dir" ]; then
        echo -e "${RED}Frontend directory not found: $frontend_dir${NC}"
        return 1
    fi

    cd "$frontend_dir"

    # Install dependencies
    echo -e "${GREEN}Installing npm dependencies (this may take a few minutes)...${NC}"
    npm install

    # Create .env.local file
    if [ ! -f ".env.local" ]; then
        echo -e "${GREEN}Creating .env.local file...${NC}"
        if [ -f ".env.example" ]; then
            cp .env.example .env.local
        else
            echo "NEXT_PUBLIC_API_URL=http://localhost:$backend_port" > .env.local
            if [ "$PHASE" = "phase-3" ]; then
                echo "NEXT_PUBLIC_CHAT_ENABLED=true" >> .env.local
            fi
        fi
    else
        echo -e "${YELLOW}.env.local file already exists${NC}"
    fi

    cd - > /dev/null
    echo -e "${GREEN}✓ Frontend setup complete${NC}"
    echo ""
}

# Main execution
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}To-Do Application Setup${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

check_prerequisites

case "$PHASE" in
    phase-2)
        echo -e "${BLUE}Setting up Phase 2 (Next.js Full-Stack)${NC}"
        echo ""
        setup_backend "phase-2-nextjs/backend"
        setup_frontend "phase-2-nextjs/frontend" "8000"
        ;;
    phase-3)
        echo -e "${BLUE}Setting up Phase 3 (AI Chatbot)${NC}"
        echo ""
        setup_backend "phase-3-chatbot/backend"
        setup_frontend "phase-3-chatbot/frontend" "8001"
        echo ""
        echo -e "${YELLOW}Note: Phase 3 requires OPENAI_API_KEY in backend/.env${NC}"
        ;;
    all)
        echo -e "${BLUE}Setting up all phases${NC}"
        echo ""
        setup_backend "phase-2-nextjs/backend"
        setup_frontend "phase-2-nextjs/frontend" "8000"
        echo ""
        setup_backend "phase-3-chatbot/backend"
        setup_frontend "phase-3-chatbot/frontend" "8001"
        ;;
    *)
        echo -e "${RED}Invalid phase: $PHASE${NC}"
        echo "Usage: $0 {phase-2|phase-3|all}"
        exit 1
        ;;
esac

# Final summary
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Next steps:"
echo "1. Review and update .env files with your configuration"
echo "2. Start the backend: bash .claude/skills/start-backend/scripts/start.sh"
echo "3. Start the frontend: bash .claude/skills/start-frontend/scripts/start.sh"
echo "4. Verify setup: bash .claude/skills/verify-setup/scripts/verify.sh"
echo ""
