#!/bin/bash
# Deploy Todo Chatbot to Kubernetes using kubectl

set -e

echo "☸️  Deploying Todo Chatbot to Kubernetes..."

# Navigate to k8s manifests directory
cd "$(dirname "$0")/../k8s/base"

# Apply all manifests
echo "📝 Applying Kubernetes manifests..."
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
kubectl apply -f pvc.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s \
  deployment/todo-chatbot-backend \
  deployment/todo-chatbot-frontend \
  -n todo-chatbot

echo "✅ Deployment complete!"
echo ""
echo "📊 Deployment status:"
kubectl get all -n todo-chatbot

echo ""
echo "🌐 Access the application:"
echo "Frontend: http://localhost:30080"
echo "Backend API: http://<minikube-ip>:30001 (use 'minikube ip' to get the IP)"
