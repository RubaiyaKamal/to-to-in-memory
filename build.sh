#!/usr/bin/env bash
# Build script for Render deployment

echo "Building Phase 2 Frontend..."
cd phase-2-nextjs/frontend
npm install
npm run build
cd ../..

echo "Building Phase 2 Backend..."
cd phase-2-nextjs/backend
uv sync
