#!/usr/bin/env bash
# Build script for Render deployment

echo "Building Phase 3 Frontend..."
cd phase-3-chatbot/frontend
npm install
npm run build
