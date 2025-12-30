#!/bin/bash

# Start Frontend Server Script
# Starts the Next.js frontend for the to-do application

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default phase
PHASE="${1:-phase-2}"

# Determine frontend directory and port
if [ "$PHASE" = "phase-2" ]; then
    FRONTEND_DIR="phase-2-nextjs/frontend"
    PORT=3000
    BACKEND_PORT=8000
elif [ "$PHASE" = "phase-3" ]; then
    FRONTEND_DIR="phase-3-chatbot/frontend"
    PORT=3001
    BACKEND_PORT=8001
else
    echo -e "${RED}Error: Invalid phase '$PHASE'. Use 'phase-2' or 'phase-3'.${NC}"
    exit 1
fi

echo -e "${GREEN}Starting $PHASE frontend application...${NC}"
echo "Directory: $FRONTEND_DIR"
echo "Port: $PORT"
echo ""

# Check if directory exists
if [ ! -d "$FRONTEND_DIR" ]; then
    echo -e "${RED}Error: Frontend directory not found: $FRONTEND_DIR${NC}"
    exit 1
fi

# Navigate to frontend directory
cd "$FRONTEND_DIR"

# Check for .env.local file
if [ ! -f ".env.local" ]; then
    echo -e "${YELLOW}Warning: .env.local file not found${NC}"
    echo -e "${YELLOW}Creating .env.local...${NC}"
    echo "NEXT_PUBLIC_API_URL=http://localhost:$BACKEND_PORT" > .env.local
    if [ "$PHASE" = "phase-3" ]; then
        echo "NEXT_PUBLIC_CHAT_ENABLED=true" >> .env.local
    fi
    echo -e "${GREEN}.env.local created successfully${NC}"
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}node_modules not found. Installing dependencies...${NC}"
    npm install
else
    echo -e "${GREEN}Checking for dependency updates...${NC}"
    npm install --quiet
fi

# Check if backend is running
echo -e "${GREEN}Checking backend status...${NC}"
if ! curl -s http://localhost:$BACKEND_PORT/health >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Backend server not responding on port $BACKEND_PORT${NC}"
    echo -e "${YELLOW}Please start the backend server first using the start-backend skill${NC}"
    echo ""
fi

# Check if port is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -ano | grep ":$PORT" | grep "LISTENING" >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Port $PORT is already in use${NC}"
    echo "Please stop the existing server or choose a different port."
    exit 1
fi

# Start the development server
echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Starting Next.js dev server on port $PORT${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Application will be available at: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start Next.js with custom port
PORT=$PORT npm run dev
