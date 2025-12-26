#!/bin/bash

# Build Frontend for Production
# Creates an optimized production build

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PHASE="${1:-phase-2}"

# Determine frontend directory
if [ "$PHASE" = "phase-2" ]; then
    FRONTEND_DIR="phase-2-nextjs/frontend"
elif [ "$PHASE" = "phase-3" ]; then
    FRONTEND_DIR="phase-3-chatbot/frontend"
else
    echo -e "${RED}Error: Invalid phase '$PHASE'. Use 'phase-2' or 'phase-3'.${NC}"
    exit 1
fi

echo -e "${GREEN}Building $PHASE frontend for production...${NC}"
echo "Directory: $FRONTEND_DIR"
echo ""

# Navigate to frontend directory
cd "$FRONTEND_DIR"

# Install dependencies
echo -e "${GREEN}Installing dependencies...${NC}"
npm install

# Run type check
echo -e "${GREEN}Running type check...${NC}"
npm run type-check || true

# Run linter
echo -e "${GREEN}Running linter...${NC}"
npm run lint || true

# Build
echo -e "${GREEN}Building for production...${NC}"
npm run build

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "Output directory: .next"
echo "To start production server: npm run start"
