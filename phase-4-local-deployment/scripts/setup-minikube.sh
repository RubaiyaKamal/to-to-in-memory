#!/bin/bash
# Setup Minikube for local Kubernetes deployment

set -e

echo "🚀 Setting up Minikube..."

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed. Please install it first:"
    echo "   https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Check if minikube is running
if minikube status | grep -q "Running"; then
    echo "✅ Minikube is already running"
else
    echo "🔄 Starting Minikube..."
    minikube start \
      --cpus=4 \
      --memory=8192 \
      --disk-size=20g \
      --driver=docker
fi

# Enable addons
echo "🔌 Enabling Minikube addons..."
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard

# Set kubectl context
echo "⚙️  Setting kubectl context..."
kubectl config use-context minikube

# Load Docker images into Minikube (if images exist)
echo "📦 Loading Docker images into Minikube..."
if docker images | grep -q "todo-chatbot-backend"; then
    minikube image load todo-chatbot-backend:latest
fi
if docker images | grep -q "todo-chatbot-frontend"; then
    minikube image load todo-chatbot-frontend:latest
fi

echo "✅ Minikube setup complete!"
echo ""
echo "🔍 Cluster info:"
kubectl cluster-info
echo ""
echo "📊 Node status:"
kubectl get nodes
echo ""
echo "🌐 Minikube IP:"
minikube ip
echo ""
echo "💡 Useful commands:"
echo "  - Dashboard: minikube dashboard"
echo "  - SSH: minikube ssh"
echo "  - Stop: minikube stop"
echo "  - Delete: minikube delete"
