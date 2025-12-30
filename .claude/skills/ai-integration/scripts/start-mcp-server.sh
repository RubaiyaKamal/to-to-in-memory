#!/bin/bash

# Start MCP Server Script
# Starts the MCP server in standalone mode (optional)

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKEND_DIR="phase-3-chatbot/backend"
PORT="${1:-8002}"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Starting MCP Server${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check backend directory
if [ ! -d "$BACKEND_DIR" ]; then
    echo -e "${RED}Backend directory not found: $BACKEND_DIR${NC}"
    exit 1
fi

cd "$BACKEND_DIR"

# Activate virtual environment
if [ -d "venv" ]; then
    echo -e "${GREEN}Activating virtual environment...${NC}"
    source venv/bin/activate || source venv/Scripts/activate 2>/dev/null
else
    echo -e "${RED}Virtual environment not found${NC}"
    exit 1
fi

# Check if MCP server exists
if [ ! -f "app/mcp/server.py" ]; then
    echo -e "${YELLOW}MCP server not yet implemented${NC}"
    echo "Please implement according to references/mcp-tools-implementation.py"
    exit 1
fi

# Check environment variables
if [ ! -f ".env" ]; then
    echo -e "${RED}.env file not found${NC}"
    exit 1
fi

source .env

if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${RED}OPENAI_API_KEY not set in .env${NC}"
    exit 1
fi

echo -e "${GREEN}Environment configured${NC}"
echo ""

# Check if port is in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${YELLOW}Port $PORT already in use${NC}"
    exit 1
fi

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Starting MCP Server on port $PORT${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Note: MCP tools are typically integrated into the FastAPI backend"
echo "This standalone mode is for testing MCP server directly"
echo ""
echo "Server will be available at: http://localhost:$PORT"
echo "Press Ctrl+C to stop"
echo ""

# Start MCP server (if standalone implementation exists)
python -m app.mcp.server --port $PORT || {
    echo ""
    echo -e "${YELLOW}Standalone MCP server not available${NC}"
    echo ""
    echo "MCP tools are integrated into the main FastAPI backend."
    echo "Start the backend instead:"
    echo "  bash .claude/skills/start-backend/scripts/start.sh phase-3"
    echo ""
    echo "Then test MCP tools via the chat endpoint:"
    echo "  POST http://localhost:8001/api/v1/chat"
}

cd - > /dev/null
