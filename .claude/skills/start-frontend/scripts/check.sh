#!/bin/bash

# Check Frontend Server Status Script
# Checks if the Next.js frontend is running

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Checking frontend servers..."
echo ""

# Check Phase 2 frontend (port 3000)
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -ano | grep ":3000" | grep "LISTENING" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Phase 2 frontend is running on port 3000${NC}"
    echo "  URL: http://localhost:3000"
else
    echo -e "${RED}✗ Phase 2 frontend is not running (port 3000)${NC}"
fi

echo ""

# Check Phase 3 frontend (port 3001)
if lsof -Pi :3001 -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -ano | grep ":3001" | grep "LISTENING" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Phase 3 frontend is running on port 3001${NC}"
    echo "  URL: http://localhost:3001"
else
    echo -e "${RED}✗ Phase 3 frontend is not running (port 3001)${NC}"
fi
