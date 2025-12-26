#!/bin/bash

# Check Backend Server Status Script
# Checks if the FastAPI backend is running

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Checking backend servers..."
echo ""

# Check Phase 2 backend (port 8000)
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -ano | grep ":8000" | grep "LISTENING" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Phase 2 backend is running on port 8000${NC}"
    echo "  URL: http://localhost:8000"
    echo "  Docs: http://localhost:8000/docs"
else
    echo -e "${RED}✗ Phase 2 backend is not running (port 8000)${NC}"
fi

echo ""

# Check Phase 3 backend (port 8001)
if lsof -Pi :8001 -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -ano | grep ":8001" | grep "LISTENING" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Phase 3 backend is running on port 8001${NC}"
    echo "  URL: http://localhost:8001"
    echo "  Docs: http://localhost:8001/docs"
else
    echo -e "${RED}✗ Phase 3 backend is not running (port 8001)${NC}"
fi
