# AI-Assisted Kubernetes Deployment Guide

This guide shows how to use kubectl-ai and kagent for intelligent Kubernetes operations.

## Prerequisites

1. **Set OpenAI API Key** (required for both tools):
   ```bash
   export OPENAI_API_KEY="your-openai-api-key-here"
   ```

2. **Install Tools** (see SETUP-AI-TOOLS.md)

## Using kubectl-ai

### Generate and Validate Helm Values

kubectl-ai can help you generate or validate Helm values files:

```bash
# Generate custom values for production environment
kubectl-ai "create helm values for a todo chatbot with:
- backend with 3 replicas
- frontend with 2 replicas
- persistent storage enabled
- autoscaling enabled with max 5 replicas
- resource limits: backend 1Gi memory, frontend 512Mi memory"

# Save output to a custom values file
kubectl-ai "..." > helm/todo-chatbot/values-production.yaml
```

### Generate Kubernetes Manifests from Natural Language

```bash
# Generate a deployment
kubectl-ai "create a deployment for todo-chatbot-backend using image todo-chatbot-backend:latest with 2 replicas, port 8001, environment variables DATABASE_URL and OPENAI_API_KEY, health checks on /api/health endpoint"

# Generate a service
kubectl-ai "create a ClusterIP service for todo-chatbot-backend exposing port 8001"

# Generate a ConfigMap
kubectl-ai "create a configmap for todo-chatbot with keys: API_URL=http://todo-chatbot-backend:8001, LOG_LEVEL=info"

# Generate a Secret
kubectl-ai "create a secret for todo-chatbot with OPENAI_API_KEY from environment variable"
```

### Validate and Improve Existing Manifests

```bash
# Validate a Helm template
helm template todo-chatbot ./helm/todo-chatbot | kubectl-ai "review this Kubernetes manifest and suggest improvements for security and best practices"

# Check resource limits
kubectl-ai "analyze these deployments and suggest appropriate resource limits for a todo chatbot application running on a 8GB RAM machine"
```

## Using kagent

kagent is an AI-powered Kubernetes troubleshooting and management assistant.

### Cluster Analysis

```bash
# Analyze cluster health
kagent analyze cluster

# Check resource usage
kagent "show me resource usage across all namespaces"

# Identify potential issues
kagent "what issues do you see in my cluster?"
```

### Deployment Management

```bash
# Deploy with AI assistance
kagent "deploy todo-chatbot application with backend and frontend services in namespace todo-chatbot"

# Scale intelligently
kagent "scale todo-chatbot-backend to handle 100 concurrent users"

# Update deployment
kagent "update todo-chatbot-backend image to version 1.1.0 with rolling update strategy"
```

### Troubleshooting

```bash
# Diagnose pod failures
kagent diagnose pod todo-chatbot-backend-xxx -n todo-chatbot

# Check why service is not responding
kagent "my todo-chatbot-frontend service is not accessible, help me troubleshoot"

# Analyze logs
kagent "show me errors in todo-chatbot-backend logs from the last 10 minutes"

# Network debugging
kagent "check if frontend can connect to backend service"
```

### Performance Optimization

```bash
# Analyze performance
kagent "analyze performance of todo-chatbot deployment"

# Suggest optimizations
kagent "suggest resource optimization for todo-chatbot to reduce costs"

# Check autoscaling configuration
kagent "is my HPA configuration optimal for todo-chatbot-backend?"
```

## Practical Workflow with AI Tools

### 1. Initial Deployment with kubectl-ai

```bash
# Generate custom Helm values
kubectl-ai "create production-ready helm values for todo chatbot with high availability and security" > values-prod.yaml

# Review and edit the generated file
vi values-prod.yaml

# Deploy with Helm
helm install todo-chatbot ./helm/todo-chatbot -f values-prod.yaml -n todo-chatbot --create-namespace
```

### 2. Monitoring with kagent

```bash
# Check deployment status
kagent "show me the status of todo-chatbot deployment"

# Monitor resource usage
watch -n 5 'kagent "show resource usage for todo-chatbot namespace"'

# Check pod health
kagent "are all todo-chatbot pods healthy?"
```

### 3. Troubleshooting with kagent

```bash
# If deployment fails
kagent "my todo-chatbot-backend pod is in CrashLoopBackOff, help me fix it"

# If service is unreachable
kagent "frontend cannot reach backend service, diagnose the issue"

# If performance is degraded
kagent "todo-chatbot is slow, help me identify bottlenecks"
```

### 4. Optimization with kubectl-ai

```bash
# Generate optimized manifest
kubectl-ai "optimize this deployment for better performance and resource efficiency" < k8s/base/backend-deployment.yaml

# Apply suggested improvements
kubectl apply -f optimized-deployment.yaml
```

## Advanced AI-Assisted Operations

### GitOps Workflow

```bash
# Generate ArgoCD application manifest
kubectl-ai "create an ArgoCD application manifest for todo-chatbot helm chart with automatic sync"

# Generate Flux HelmRelease
kubectl-ai "create a Flux HelmRelease for todo-chatbot with automatic updates"
```

### Security Hardening

```bash
# Generate Network Policies
kubectl-ai "create network policies for todo-chatbot that:
- allow frontend to backend communication
- allow backend to database
- deny all other traffic"

# Generate Pod Security Policies
kubectl-ai "create pod security policy for todo-chatbot with:
- no privileged containers
- read-only root filesystem
- drop all capabilities"

# Security audit with kagent
kagent "audit security of todo-chatbot deployment"
```

### Disaster Recovery

```bash
# Create backup manifests
kagent "create velero backup configuration for todo-chatbot"

# Test rollback
kagent "help me rollback todo-chatbot to previous version"
```

## Example: Complete AI-Assisted Deployment

```bash
#!/bin/bash

# 1. Generate optimized Helm values
echo "Generating Helm values with kubectl-ai..."
kubectl-ai "create production Helm values for todo chatbot with:
- backend: 3 replicas, 512Mi memory, 250m CPU
- frontend: 2 replicas, 256Mi memory, 100m CPU
- persistent volume: 5Gi
- autoscaling enabled
- ingress with TLS
- resource limits and requests
- liveness and readiness probes" > values-ai-generated.yaml

# 2. Deploy with Helm
echo "Deploying with Helm..."
helm install todo-chatbot ./helm/todo-chatbot -f values-ai-generated.yaml -n todo-chatbot --create-namespace

# 3. Verify with kagent
echo "Verifying deployment with kagent..."
kagent "verify todo-chatbot deployment is healthy and all pods are running"

# 4. Get access information
echo "Getting access URLs..."
kagent "how can I access the todo-chatbot frontend?"

# 5. Monitor deployment
echo "Monitoring deployment..."
kagent "show me real-time status of todo-chatbot"
```

## Best Practices

1. **Always review AI-generated manifests** before applying to production
2. **Version control all manifests** including AI-generated ones
3. **Test in development** before using AI-generated configs in production
4. **Validate YAML syntax** after generation
5. **Use kubectl dry-run** to preview changes
6. **Keep API keys secure** - never commit them to git

## Troubleshooting AI Tools

### kubectl-ai not working

```bash
# Check API key
echo $OPENAI_API_KEY

# Test with simple prompt
kubectl-ai "create a simple pod"

# Check kubectl-ai logs
kubectl-ai --debug "create a deployment"
```

### kagent not connecting to cluster

```bash
# Verify kubeconfig
kubectl cluster-info

# Check kagent configuration
kagent config show

# Reset kagent
kagent config reset
```

## Alternative: Manual Commands

If AI tools are not available, you can use standard commands:

```bash
# Instead of kubectl-ai
helm template todo-chatbot ./helm/todo-chatbot
kubectl explain deployment
kubectl explain service

# Instead of kagent
kubectl get all -n todo-chatbot
kubectl describe pod <pod-name> -n todo-chatbot
kubectl logs -f deployment/todo-chatbot-backend -n todo-chatbot
minikube dashboard
```

## Resources

- kubectl-ai: https://github.com/sozercan/kubectl-ai
- kagent: https://github.com/kubeshop/kagent
- Helm: https://helm.sh/docs
- Kubernetes: https://kubernetes.io/docs
