#!/bin/bash
# Cleanup Todo Chatbot deployment

set -e

echo "🧹 Cleaning up Todo Chatbot deployment..."

# Ask for confirmation
read -p "This will delete all Todo Chatbot resources. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 1
fi

# Check if deployed with Helm
if helm list -n todo-chatbot | grep -q "todo-chatbot"; then
    echo "🔄 Uninstalling Helm release..."
    helm uninstall todo-chatbot -n todo-chatbot
fi

# Delete Kubernetes resources
echo "🗑️  Deleting Kubernetes resources..."
kubectl delete namespace todo-chatbot --ignore-not-found=true

# Remove Docker images (optional)
read -p "Remove Docker images? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🐳 Removing Docker images..."
    docker rmi todo-chatbot-backend:latest --force 2>/dev/null || true
    docker rmi todo-chatbot-frontend:latest --force 2>/dev/null || true
fi

echo "✅ Cleanup complete!"
