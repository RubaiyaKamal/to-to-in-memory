#!/usr/bin/env bash
# Start script for Render deployment

echo "Starting Phase 3 Backend..."
uvicorn phase-3-chatbot.backend.main:app --host 0.0.0.0 --port $PORT
