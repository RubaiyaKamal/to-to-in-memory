#!/bin/bash

# Verify OpenAI Configuration Script
# Checks OpenAI API key and configuration

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

BACKEND_DIR="phase-3-chatbot/backend"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}Verifying OpenAI Configuration${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Check backend directory
if [ ! -d "$BACKEND_DIR" ]; then
    echo -e "${RED}✗ Backend directory not found: $BACKEND_DIR${NC}"
    exit 1
fi

cd "$BACKEND_DIR"

# Check .env file
if [ ! -f ".env" ]; then
    echo -e "${RED}✗ .env file not found${NC}"
    echo ""
    echo "Create .env file with:"
    echo "  OPENAI_API_KEY=sk-...your-key-here..."
    exit 1
fi

echo -e "${GREEN}✓ .env file exists${NC}"

# Check for OpenAI API key in .env
if grep -q "OPENAI_API_KEY" .env; then
    echo -e "${GREEN}✓ OPENAI_API_KEY found in .env${NC}"

    # Check if key is not placeholder
    if grep -q "OPENAI_API_KEY=sk-" .env; then
        echo -e "${GREEN}✓ API key appears to be set${NC}"
    else
        echo -e "${YELLOW}⚠ OPENAI_API_KEY may be placeholder${NC}"
        echo "  Please set a valid OpenAI API key starting with 'sk-'"
    fi
else
    echo -e "${RED}✗ OPENAI_API_KEY not found in .env${NC}"
    echo ""
    echo "Add to .env file:"
    echo "  OPENAI_API_KEY=sk-...your-key-here..."
    exit 1
fi

echo ""

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate || source venv/Scripts/activate 2>/dev/null
else
    echo -e "${YELLOW}⚠ Virtual environment not found${NC}"
    echo "  Run: bash .claude/skills/setup-phase/scripts/setup.sh phase-3"
    exit 1
fi

# Check if openai package is installed
echo -e "${BLUE}Checking OpenAI package...${NC}"
if python -c "import openai" 2>/dev/null; then
    echo -e "${GREEN}✓ openai package installed${NC}"

    # Get version
    VERSION=$(python -c "import openai; print(openai.__version__)" 2>/dev/null || echo "unknown")
    echo "  Version: $VERSION"
else
    echo -e "${RED}✗ openai package not installed${NC}"
    echo ""
    echo "Install with:"
    echo "  pip install openai"
    exit 1
fi

echo ""

# Test API key (optional, requires network)
echo -e "${BLUE}Testing API key (optional)...${NC}"
python -c "
import os
from openai import OpenAI

# Load from .env
from dotenv import load_dotenv
load_dotenv()

api_key = os.getenv('OPENAI_API_KEY')

if not api_key or api_key.startswith('your-') or api_key == 'sk-':
    print('⚠ API key appears to be placeholder')
    exit(0)

try:
    client = OpenAI(api_key=api_key)

    # Test with a minimal request
    response = client.chat.completions.create(
        model='gpt-3.5-turbo',
        messages=[{'role': 'user', 'content': 'Hi'}],
        max_tokens=5
    )

    print('✓ API key is valid and working')
    print(f'  Model: {response.model}')
    print(f'  Response: {response.choices[0].message.content}')

except Exception as e:
    print(f'✗ API key test failed: {str(e)}')
    print('')
    print('Please check:')
    print('  1. API key is correct')
    print('  2. You have credits in your OpenAI account')
    print('  3. Internet connection is working')
    exit(1)
" 2>/dev/null || echo -e "${YELLOW}⚠ Could not test API key (network required)${NC}"

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}OpenAI Configuration Verified${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Implement MCP tools (see references/mcp-tools-implementation.py)"
echo "  2. Test tools: bash .claude/skills/ai-integration/scripts/test-mcp-tools.sh"
echo "  3. Start backend: bash .claude/skills/start-backend/scripts/start.sh phase-3"
echo ""

cd - > /dev/null
