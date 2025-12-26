#!/bin/bash
# Deploy Todo Chatbot using Helm

set -e

RELEASE_NAME="todo-chatbot"
NAMESPACE="todo-chatbot"
CHART_PATH="$(dirname "$0")/../helm/todo-chatbot"

echo "⎈ Deploying Todo Chatbot with Helm..."

# Check if release exists
if helm list -n $NAMESPACE | grep -q $RELEASE_NAME; then
  echo "🔄 Upgrading existing release..."
  helm upgrade $RELEASE_NAME $CHART_PATH \
    --namespace $NAMESPACE \
    --wait \
    --timeout 5m
else
  echo "🆕 Installing new release..."
  helm install $RELEASE_NAME $CHART_PATH \
    --namespace $NAMESPACE \
    --create-namespace \
    --wait \
    --timeout 5m
fi

echo "✅ Helm deployment complete!"
echo ""
echo "📊 Release status:"
helm status $RELEASE_NAME -n $NAMESPACE

echo ""
echo "🌐 Access the application:"
echo "Frontend: http://localhost:30080"
echo "Backend API: kubectl port-forward -n $NAMESPACE svc/todo-chatbot-backend 8001:8001"
