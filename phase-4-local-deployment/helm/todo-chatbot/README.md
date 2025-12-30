# Todo Chatbot Helm Chart

Task 3.1: Helm Chart Structure
Reference: specs/003-local-k8s-deployment/tasks.md

## Overview

This Helm chart deploys the Todo Chatbot application to Kubernetes with:
- **Backend**: FastAPI application with SQLite database
- **Frontend**: Next.js application served by nginx
- **High Availability**: 2 replicas for both backend and frontend
- **Persistent Storage**: 1Gi PVC for SQLite database
- **Health Checks**: Liveness and readiness probes
- **External Access**: NodePort service on port 30080

## Chart Structure

```
todo-chatbot/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default configuration values
├── .helmignore             # Files to ignore when packaging
├── charts/                 # Chart dependencies (empty)
└── templates/              # Kubernetes manifest templates
    ├── _helpers.tpl        # Template helper functions
    ├── namespace.yaml      # Namespace definition
    ├── secret.yaml         # Secret for API keys
    ├── configmap.yaml      # ConfigMap for configuration
    ├── pvc.yaml            # PersistentVolumeClaim for database
    ├── backend-deployment.yaml   # Backend deployment
    ├── backend-service.yaml      # Backend ClusterIP service
    ├── frontend-deployment.yaml  # Frontend deployment
    └── frontend-service.yaml     # Frontend NodePort service
```

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Minikube (for local deployment)
- Docker images:
  - `todo-chatbot-backend:latest`
  - `todo-chatbot-frontend:latest`

## Configuration

### Required Secrets

Before installation, you must provide:

1. **OPENAI_API_KEY**: Your OpenAI API key
2. **BETTER_AUTH_SECRET**: Authentication secret (min 32 characters)

### Configuration Values

Key configuration options in `values.yaml`:

```yaml
# Secrets (must be overridden)
secrets:
  OPENAI_API_KEY: "REPLACE_WITH_YOUR_OPENAI_API_KEY"
  BETTER_AUTH_SECRET: "REPLACE_WITH_YOUR_SECRET_MIN_32_CHARS"

# Backend configuration
backend:
  replicaCount: 2
  image:
    repository: todo-chatbot-backend
    tag: latest
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"

# Frontend configuration
frontend:
  replicaCount: 2
  image:
    repository: todo-chatbot-frontend
    tag: latest
  service:
    nodePort: 30080  # External access port
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"
```

## Installation

### 1. Create secrets file

Create `custom-values.yaml`:

```yaml
secrets:
  OPENAI_API_KEY: "sk-proj-your-actual-api-key-here"
  BETTER_AUTH_SECRET: "your-secret-key-minimum-32-characters-long"
```

### 2. Install the chart

```bash
# Install with custom values
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f custom-values.yaml

# Or set values via --set
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  --set secrets.OPENAI_API_KEY="sk-proj-..." \
  --set secrets.BETTER_AUTH_SECRET="..."
```

### 3. Verify installation

```bash
# Check release status
helm status todo-chatbot

# List all resources
kubectl get all -n todo-chatbot

# Check pod status
kubectl get pods -n todo-chatbot

# View logs
kubectl logs -n todo-chatbot -l app=todo-chatbot-backend
kubectl logs -n todo-chatbot -l app=todo-chatbot-frontend
```

### 4. Access the application

```bash
# Get Minikube IP
minikube ip

# Access frontend
# http://<minikube-ip>:30080
```

## Upgrade

```bash
# Upgrade with new values
helm upgrade todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f custom-values.yaml

# Upgrade specific values
helm upgrade todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  --set backend.replicaCount=3
```

## Uninstall

```bash
# Uninstall the release
helm uninstall todo-chatbot

# Remove namespace (if needed)
kubectl delete namespace todo-chatbot
```

## Customization

### Override Configuration

Create a custom values file:

```yaml
# custom-values.yaml
namespace:
  name: my-todo-app

backend:
  replicaCount: 3
  resources:
    limits:
      memory: "1Gi"
      cpu: "1000m"

frontend:
  service:
    nodePort: 30090
```

Then install:

```bash
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f custom-values.yaml
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl get pods -n todo-chatbot

# Describe pod for events
kubectl describe pod <pod-name> -n todo-chatbot

# Check logs
kubectl logs <pod-name> -n todo-chatbot
```

### ImagePullBackOff error

```bash
# Load Docker images to Minikube
eval $(minikube docker-env)
docker images | grep todo-chatbot

# If images missing, rebuild:
# See Task 4.2 in specs/003-local-k8s-deployment/tasks.md
```

### Service not accessible

```bash
# Check service
kubectl get svc -n todo-chatbot

# Get Minikube IP
minikube ip

# Test connectivity
curl http://$(minikube ip):30080
```

## Development

### Validate chart

```bash
# Lint the chart
helm lint ./phase-4-local-deployment/helm/todo-chatbot

# Dry-run installation
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  --dry-run --debug

# Render templates
helm template todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot
```

### Package chart

```bash
# Package the chart
helm package ./phase-4-local-deployment/helm/todo-chatbot

# Creates: todo-chatbot-1.0.0.tgz
```

## Resources

- **Kubernetes Manifests**: `phase-4-local-deployment/k8s/base/`
- **Docker Compose**: `phase-4-local-deployment/docker/docker-compose.yml`
- **Task Documentation**: `specs/003-local-k8s-deployment/tasks.md`

## Support

For issues or questions:
- GitHub Issues: https://github.com/your-org/to-do-in-memory/issues
- Email: team@example.com
