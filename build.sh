#!/usr/bin/env bash
# Build script for Render deployment

echo "Building frontend..."
cd frontend
npm install
npm run build
