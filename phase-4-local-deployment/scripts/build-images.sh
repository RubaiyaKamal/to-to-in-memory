#!/bin/bash
# Build Docker images for Phase 4 deployment

set -e

echo "🐳 Building Docker images for Todo Chatbot..."

# Navigate to project root
cd "$(dirname "$0")/../.."

# Build backend image
echo "📦 Building backend image..."
docker build \
  -f phase-4-local-deployment/docker/backend/Dockerfile \
  -t todo-chatbot-backend:latest \
  .

# Build frontend image
echo "📦 Building frontend image..."
docker build \
  -f phase-4-local-deployment/docker/frontend/Dockerfile \
  -t todo-chatbot-frontend:latest \
  .

echo "✅ Docker images built successfully!"
echo ""
echo "Images created:"
docker images | grep todo-chatbot
