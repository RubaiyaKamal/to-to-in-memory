#!/bin/bash

# Stop Frontend Server Script
# Stops the Next.js frontend server

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PHASE="${1:-phase-2}"

# Determine port
if [ "$PHASE" = "phase-2" ]; then
    PORT=3000
elif [ "$PHASE" = "phase-3" ]; then
    PORT=3001
else
    echo -e "${RED}Error: Invalid phase '$PHASE'. Use 'phase-2' or 'phase-3'.${NC}"
    exit 1
fi

echo -e "${YELLOW}Stopping $PHASE frontend server on port $PORT...${NC}"

# Find and kill the process
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    PID=$(lsof -Pi :$PORT -sTCP:LISTEN -t)
    kill $PID
    echo -e "${GREEN}Frontend server stopped successfully (PID: $PID)${NC}"
elif netstat -ano | grep ":$PORT" | grep "LISTENING" >/dev/null 2>&1; then
    # Windows alternative
    for /f "tokens=5" %a in ('netstat -ano ^| findstr :$PORT') do taskkill /F /PID %a
    echo -e "${GREEN}Frontend server stopped successfully${NC}"
else
    echo -e "${YELLOW}No frontend server found running on port $PORT${NC}"
fi
