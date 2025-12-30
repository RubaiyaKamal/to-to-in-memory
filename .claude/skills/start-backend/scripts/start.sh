#!/bin/bash

# Start Backend Server Script
# Starts the FastAPI backend for the to-do application

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default phase
PHASE="${1:-phase-2}"

# Determine backend directory
if [ "$PHASE" = "phase-2" ]; then
    BACKEND_DIR="phase-2-nextjs/backend"
    PORT=8000
elif [ "$PHASE" = "phase-3" ]; then
    BACKEND_DIR="phase-3-chatbot/backend"
    PORT=8001
else
    echo -e "${RED}Error: Invalid phase '$PHASE'. Use 'phase-2' or 'phase-3'.${NC}"
    exit 1
fi

echo -e "${GREEN}Starting $PHASE backend server...${NC}"
echo "Directory: $BACKEND_DIR"
echo "Port: $PORT"
echo ""

# Check if directory exists
if [ ! -d "$BACKEND_DIR" ]; then
    echo -e "${RED}Error: Backend directory not found: $BACKEND_DIR${NC}"
    exit 1
fi

# Navigate to backend directory
cd "$BACKEND_DIR"

# Check for .env file
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Warning: .env file not found${NC}"
    if [ -f ".env.example" ]; then
        echo -e "${YELLOW}Creating .env from .env.example...${NC}"
        cp .env.example .env
        echo -e "${YELLOW}Please edit .env and add your configuration${NC}"
    else
        echo -e "${RED}No .env.example found. Please create .env manually.${NC}"
    fi
fi

# Check for virtual environment
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}Virtual environment not found. Creating...${NC}"
    python3 -m venv venv
fi

# Activate virtual environment
echo -e "${GREEN}Activating virtual environment...${NC}"
source venv/bin/activate || source venv/Scripts/activate 2>/dev/null || {
    echo -e "${RED}Failed to activate virtual environment${NC}"
    exit 1
}

# Install/update dependencies
if [ -f "requirements.txt" ]; then
    echo -e "${GREEN}Installing dependencies...${NC}"
    pip install -q -r requirements.txt
fi

# Check if port is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -ano | grep ":$PORT" | grep "LISTENING" >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Port $PORT is already in use${NC}"
    echo "Please stop the existing server or choose a different port."
    exit 1
fi

# Start the server
echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Starting FastAPI server on port $PORT${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Server will be available at: http://localhost:$PORT"
echo "API docs: http://localhost:$PORT/docs"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start uvicorn with hot reload
uvicorn main:app --reload --host 0.0.0.0 --port $PORT
