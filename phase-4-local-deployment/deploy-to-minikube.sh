#!/bin/bash
# Deploy Todo Chatbot to Minikube with Helm
# This script automates the complete deployment process

set -e  # Exit on error

echo "=========================================="
echo "Todo Chatbot - Minikube Deployment Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Check prerequisites
print_info "Step 1: Checking prerequisites..."

if ! command -v minikube &> /dev/null; then
    print_error "minikube is not installed. Please install it first."
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install it first."
    exit 1
fi

if ! command -v helm &> /dev/null; then
    print_error "helm is not installed. Please install it first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "docker is not installed. Please install it first."
    exit 1
fi

print_info "All prerequisites are installed!"
echo ""

# Step 2: Start Minikube (if not already running)
print_info "Step 2: Starting Minikube cluster..."

if minikube status | grep -q "Running"; then
    print_info "Minikube is already running"
else
    print_info "Starting Minikube with Docker driver..."
    minikube start --driver=docker --memory=3584 --cpus=2 
fi

# Enable required addons
print_info "Enabling Minikube addons..."
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster is ready
print_info "Verifying cluster is ready..."
kubectl cluster-info
echo ""

# Step 3: Build Docker images
print_info "Step 3: Building Docker images..."

# Navigate to Phase 3 directory to build images
BACKEND_DIR="$(dirname "$0")/../phase-3-chatbot/backend"
FRONTEND_DIR="$(dirname "$0")/../phase-3-chatbot/frontend"

print_info "Building backend image..."
if [ -f "$BACKEND_DIR/Dockerfile" ]; then
    docker build -t todo-chatbot-backend:latest "$BACKEND_DIR"
else
    print_warning "Backend Dockerfile not found, creating one..."
    cat > "$BACKEND_DIR/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8001

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
EOF
    docker build -t todo-chatbot-backend:latest "$BACKEND_DIR"
fi

print_info "Building frontend image..."
if [ -f "$FRONTEND_DIR/Dockerfile" ]; then
    docker build -t todo-chatbot-frontend:latest "$FRONTEND_DIR"
else
    print_warning "Frontend Dockerfile not found, creating one..."
    cat > "$FRONTEND_DIR/Dockerfile" << 'EOF'
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF
    docker build -t todo-chatbot-frontend:latest "$FRONTEND_DIR"
fi

print_info "Docker images built successfully!"
echo ""

# Step 4: Load images into Minikube
print_info "Step 4: Loading Docker images into Minikube..."

# Use Minikube's Docker daemon to load images
eval $(minikube docker-env)
docker build -t todo-chatbot-backend:latest "$BACKEND_DIR"
docker build -t todo-chatbot-frontend:latest "$FRONTEND_DIR"

print_info "Images loaded into Minikube!"
echo ""

# Step 5: Deploy with Helm
print_info "Step 5: Deploying application with Helm..."

HELM_DIR="$(dirname "$0")/helm/todo-chatbot"

# Check if OpenAI API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    print_warning "OPENAI_API_KEY environment variable is not set"
    print_warning "Please set it before deployment: export OPENAI_API_KEY='your-key-here'"
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Deploy or upgrade with Helm
print_info "Installing/Upgrading Helm release..."
helm upgrade --install todo-chatbot "$HELM_DIR" \
    --create-namespace \
    --namespace todo-chatbot \
    --set backend.secret.OPENAI_API_KEY="${OPENAI_API_KEY:-sk-proj-placeholder}" \
    --set backend.image.pullPolicy=Never \
    --set frontend.image.pullPolicy=Never \
    --wait \
    --timeout 5m

print_info "Helm deployment completed!"
echo ""

# Step 6: Wait for pods to be ready
print_info "Step 6: Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=todo-chatbot -n todo-chatbot --timeout=300s

echo ""

# Step 7: Display deployment information
print_info "Step 7: Deployment Information"
echo "=========================================="

print_info "Pods:"
kubectl get pods -n todo-chatbot

echo ""
print_info "Services:"
kubectl get svc -n todo-chatbot

echo ""
print_info "To access the application:"
echo "  Frontend: minikube service todo-chatbot-frontend -n todo-chatbot --url"
echo "  Backend:  minikube service todo-chatbot-backend -n todo-chatbot --url"

echo ""
print_info "To open frontend in browser:"
echo "  minikube service todo-chatbot-frontend -n todo-chatbot"

echo ""
print_info "Useful commands:"
echo "  # View logs"
echo "  kubectl logs -f deployment/todo-chatbot-backend -n todo-chatbot"
echo "  kubectl logs -f deployment/todo-chatbot-frontend -n todo-chatbot"
echo ""
echo "  # Scale replicas"
echo "  kubectl scale deployment/todo-chatbot-backend --replicas=3 -n todo-chatbot"
echo ""
echo "  # Delete deployment"
echo "  helm uninstall todo-chatbot -n todo-chatbot"
echo ""
echo "  # Minikube dashboard"
echo "  minikube dashboard"

echo ""
print_info "=========================================="
print_info "Deployment completed successfully!"
print_info "=========================================="
