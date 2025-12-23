#!/usr/bin/env bash
# Start script for Render deployment

echo "Starting Phase 2 Backend..."
cd phase-2-nextjs/backend
uvicorn main:app --host 0.0.0.0 --port $PORT
