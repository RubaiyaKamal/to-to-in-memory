#!/bin/bash

# Test Chat Endpoint Script
# Interactive testing of the chat endpoint

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKEND_URL="${1:-http://localhost:8001}"
JWT_TOKEN="${JWT_TOKEN:-}"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Testing Chat Endpoint${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check if backend is running
if ! curl -s "$BACKEND_URL/health" > /dev/null 2>&1; then
    echo -e "${RED}✗ Backend not responding at $BACKEND_URL${NC}"
    echo ""
    echo "Start the backend first:"
    echo "  bash .claude/skills/start-backend/scripts/start.sh phase-3"
    exit 1
fi

echo -e "${GREEN}✓ Backend is running${NC}"
echo ""

# Get JWT token if not provided
if [ -z "$JWT_TOKEN" ]; then
    echo -e "${YELLOW}JWT token not provided${NC}"
    echo "Please log in to get a token, or set JWT_TOKEN environment variable"
    echo ""
    echo "Example:"
    echo "  export JWT_TOKEN=\$(curl -s -X POST $BACKEND_URL/api/v1/auth/login \\"
    echo "    -H 'Content-Type: application/json' \\"
    echo "    -d '{\"username\":\"test\",\"password\":\"test\"}' | jq -r '.access_token')"
    echo ""
    read -p "Enter JWT token (or press Enter to skip): " JWT_TOKEN
    echo ""
fi

# Interactive chat loop
CONVERSATION_ID=""

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Chat Session Started${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Type your messages below. Type 'exit' to quit."
echo ""

while true; do
    # Get user input
    echo -ne "${BLUE}You:${NC} "
    read -r USER_MESSAGE

    # Check for exit
    if [ "$USER_MESSAGE" = "exit" ]; then
        echo ""
        echo "Chat session ended."
        break
    fi

    # Skip empty messages
    if [ -z "$USER_MESSAGE" ]; then
        continue
    fi

    # Build request JSON
    if [ -z "$CONVERSATION_ID" ]; then
        REQUEST_JSON="{\"message\": \"$USER_MESSAGE\"}"
    else
        REQUEST_JSON="{\"conversation_id\": $CONVERSATION_ID, \"message\": \"$USER_MESSAGE\"}"
    fi

    # Send request
    echo -ne "${YELLOW}Assistant:${NC} "

    if [ -n "$JWT_TOKEN" ]; then
        RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/chat" \
            -H "Authorization: Bearer $JWT_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$REQUEST_JSON")
    else
        RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/chat" \
            -H "Content-Type: application/json" \
            -d "$REQUEST_JSON")
    fi

    # Parse response
    if echo "$RESPONSE" | jq -e . >/dev/null 2>&1; then
        # Valid JSON
        CONVERSATION_ID=$(echo "$RESPONSE" | jq -r '.conversation_id')
        ASSISTANT_MESSAGE=$(echo "$RESPONSE" | jq -r '.response')

        echo "$ASSISTANT_MESSAGE"
        echo ""
    else
        # Error
        echo -e "${RED}Error: $RESPONSE${NC}"
        echo ""
    fi
done

echo ""
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Example cURL Commands${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo "# Start new conversation"
echo "curl -X POST $BACKEND_URL/api/v1/chat \\"
echo "  -H 'Authorization: Bearer YOUR_TOKEN' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"message\": \"Add a task: Buy groceries\"}'"
echo ""
echo "# Continue conversation"
echo "curl -X POST $BACKEND_URL/api/v1/chat \\"
echo "  -H 'Authorization: Bearer YOUR_TOKEN' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"conversation_id\": 1, \"message\": \"Show my tasks\"}'"
echo ""
