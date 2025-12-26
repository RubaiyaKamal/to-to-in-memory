#!/bin/bash
# Verify Todo Chatbot deployment health

set -e

NAMESPACE="todo-chatbot"

echo "🔍 Verifying Todo Chatbot deployment..."

# Check namespace
echo ""
echo "📦 Namespace:"
kubectl get namespace $NAMESPACE 2>/dev/null || echo "❌ Namespace not found"

# Check deployments
echo ""
echo "🚀 Deployments:"
kubectl get deployments -n $NAMESPACE 2>/dev/null || echo "❌ No deployments found"

# Check pods
echo ""
echo "🔷 Pods:"
kubectl get pods -n $NAMESPACE 2>/dev/null || echo "❌ No pods found"

# Check services
echo ""
echo "🌐 Services:"
kubectl get services -n $NAMESPACE 2>/dev/null || echo "❌ No services found"

# Check PVCs
echo ""
echo "💾 Persistent Volume Claims:"
kubectl get pvc -n $NAMESPACE 2>/dev/null || echo "ℹ️  No PVCs found"

# Health checks
echo ""
echo "🏥 Health Checks:"

# Backend health
BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l component=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$BACKEND_POD" ]; then
    echo "Backend:"
    kubectl exec -n $NAMESPACE $BACKEND_POD -- python -c "import requests; r = requests.get('http://localhost:8001/api/health'); print(f'  Status: {r.status_code}'); print(f'  Response: {r.text}')" 2>/dev/null || echo "  ❌ Health check failed"
else
    echo "  ❌ Backend pod not found"
fi

# Frontend health
FRONTEND_POD=$(kubectl get pods -n $NAMESPACE -l component=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$FRONTEND_POD" ]; then
    echo "Frontend:"
    kubectl exec -n $NAMESPACE $FRONTEND_POD -- wget -q -O- http://localhost/health 2>/dev/null && echo "  ✅ Healthy" || echo "  ❌ Health check failed"
else
    echo "  ❌ Frontend pod not found"
fi

# Resource usage
echo ""
echo "📊 Resource Usage:"
kubectl top pods -n $NAMESPACE 2>/dev/null || echo "ℹ️  Metrics not available (enable metrics-server)"

echo ""
echo "✅ Verification complete!"
