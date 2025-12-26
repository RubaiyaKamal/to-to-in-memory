# Phase IV: Local Kubernetes Deployment

Cloud-native deployment of the Todo Chatbot application on local Kubernetes using Minikube, with Docker containers and Helm charts.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
- [AI-Assisted DevOps](#ai-assisted-devops)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## 🎯 Overview

Phase IV transforms the Phase III chatbot into a cloud-native application running on Kubernetes:

- **Containerization**: Docker images for frontend and backend
- **Orchestration**: Kubernetes deployments with health checks and auto-restart
- **Package Management**: Helm charts for templated deployments
- **Local Development**: Minikube for local Kubernetes cluster
- **Scalability**: Horizontal pod autoscaling support
- **Persistence**: Persistent volumes for data storage

## 📦 Prerequisites

### Required Tools

1. **Docker Desktop** (4.0+)
   - Download: https://www.docker.com/products/docker-desktop

2. **Minikube** (1.30+)
   - Installation: https://minikube.sigs.k8s.io/docs/start/

3. **kubectl** (1.25+)
   - Installation: https://kubernetes.io/docs/tasks/tools/

4. **Helm** (3.10+)
   - Installation: https://helm.sh/docs/intro/install/

### Optional AI DevOps Tools

- **Gordon (Docker AI)**: Requires Docker Desktop 4.53+ with beta features enabled
- **kubectl-ai**: `npm install -g kubectl-ai` or download from GitHub
- **Kagent**: Follow installation from https://github.com/kagent/kagent

### System Requirements

- **Memory**: Minimum 8GB RAM (12GB recommended)
- **CPU**: 4 cores minimum
- **Disk**: 20GB free space
- **OS**: Windows 10/11, macOS 10.14+, or Linux

## 🚀 Quick Start

### 1. Setup Minikube

```bash
# Navigate to Phase 4 directory
cd phase-4-local-deployment

# Setup and start Minikube
./scripts/setup-minikube.sh
```

### 2. Build Docker Images

```bash
# Build backend and frontend images
./scripts/build-images.sh
```

### 3. Deploy with Helm (Recommended)

```bash
# Update values in helm/todo-chatbot/values.yaml first
# Especially: backend.secret.OPENAI_API_KEY

# Deploy using Helm
./scripts/deploy-helm.sh
```

**OR** Deploy with kubectl:

```bash
# Update secret in k8s/base/secret.yaml first
# Especially: OPENAI_API_KEY

# Deploy using kubectl
./scripts/deploy-k8s.sh
```

### 4. Verify Deployment

```bash
# Check deployment health
./scripts/verify-deployment.sh
```

### 5. Access the Application

- **Frontend**: http://localhost:30080
- **Backend API**: Port-forward to access:
  ```bash
  kubectl port-forward -n todo-chatbot svc/todo-chatbot-backend 8001:8001
  ```
- **API Docs**: http://localhost:8001/docs (after port-forward)

## 🔧 Deployment Options

### Option 1: Docker Compose (Simplest)

For quick local testing without Kubernetes:

```bash
cd phase-4-local-deployment/docker

# Set your OpenAI API key
export OPENAI_API_KEY="your-key-here"

# Start with Docker Compose
docker-compose up -d

# Access frontend at http://localhost:3000
```

### Option 2: Kubernetes with kubectl

For manual control over resources:

```bash
# 1. Setup Minikube
./scripts/setup-minikube.sh

# 2. Build images
./scripts/build-images.sh

# 3. Update secret in k8s/base/secret.yaml
# Edit: OPENAI_API_KEY

# 4. Deploy
./scripts/deploy-k8s.sh

# 5. Verify
kubectl get all -n todo-chatbot
```

### Option 3: Helm (Production-Ready)

For templated, configurable deployments:

```bash
# 1. Setup Minikube
./scripts/setup-minikube.sh

# 2. Build images
./scripts/build-images.sh

# 3. Customize values
# Edit: helm/todo-chatbot/values.yaml
# Update: backend.secret.OPENAI_API_KEY

# 4. Deploy with Helm
./scripts/deploy-helm.sh

# 5. Verify
helm status todo-chatbot -n todo-chatbot
```

### Option 4: Kustomize

For environment-specific overlays:

```bash
# Apply base configuration
kubectl apply -k k8s/base

# Or create overlays for different environments
# kubectl apply -k k8s/overlays/development
```

## 🤖 AI-Assisted DevOps

### Docker AI (Gordon)

If you have Docker Desktop 4.53+ with Gordon enabled:

```bash
# Build images with AI assistance
docker ai "build images for todo chatbot backend and frontend"

# Check container status
docker ai "show me running containers for todo chatbot"

# Troubleshoot
docker ai "why is my backend container failing?"
```

### kubectl-ai

AI-assisted Kubernetes operations:

```bash
# Deploy with natural language
kubectl-ai "deploy the todo chatbot with 3 backend replicas"

# Scale services
kubectl-ai "scale the frontend to handle more traffic"

# Troubleshoot
kubectl-ai "check why the backend pods are failing"

# Get logs
kubectl-ai "show me logs from the failing backend pod"
```

### Kagent

Advanced cluster analysis:

```bash
# Analyze cluster health
kagent "analyze the todo-chatbot namespace health"

# Optimize resources
kagent "optimize resource allocation for todo-chatbot"

# Security audit
kagent "check security best practices for the deployment"
```

## 🏗️ Architecture

### Directory Structure

```
phase-4-local-deployment/
├── docker/                    # Docker configurations
│   ├── backend/
│   │   └── Dockerfile        # Backend container image
│   ├── frontend/
│   │   ├── Dockerfile        # Frontend container image
│   │   └── nginx.conf        # Nginx configuration
│   └── docker-compose.yml    # Docker Compose orchestration
├── k8s/                      # Kubernetes manifests
│   ├── base/                 # Base configurations
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── backend-deployment.yaml
│   │   ├── backend-service.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── pvc.yaml
│   │   └── kustomization.yaml
│   └── overlays/             # Environment-specific overrides
├── helm/                     # Helm charts
│   └── todo-chatbot/
│       ├── Chart.yaml        # Chart metadata
│       ├── values.yaml       # Default values
│       └── templates/        # K8s resource templates
├── scripts/                  # Deployment scripts
│   ├── setup-minikube.sh    # Minikube setup
│   ├── build-images.sh      # Image building
│   ├── deploy-k8s.sh        # kubectl deployment
│   ├── deploy-helm.sh       # Helm deployment
│   ├── verify-deployment.sh # Health verification
│   └── cleanup.sh           # Resource cleanup
├── docs/                     # Additional documentation
└── README.md                 # This file
```

### Components

#### Backend
- **Image**: `todo-chatbot-backend:latest`
- **Base**: Python 3.13-slim
- **App**: FastAPI with OpenAI integration
- **Port**: 8001
- **Replicas**: 2 (configurable)
- **Health Checks**: Liveness and readiness probes

#### Frontend
- **Image**: `todo-chatbot-frontend:latest`
- **Base**: Node 20 (build), Nginx Alpine (runtime)
- **App**: React/Vite SPA
- **Port**: 80
- **Replicas**: 2 (configurable)
- **Server**: Nginx with optimized config

#### Persistence
- **Backend Data**: PersistentVolumeClaim (1Gi)
- **Database**: SQLite in persistent volume
- **Conversations**: Stored in database

## 🔍 Troubleshooting

### Common Issues

#### 1. Images Not Found

```bash
# Verify images exist
docker images | grep todo-chatbot

# If not, rebuild
./scripts/build-images.sh

# Load into Minikube
minikube image load todo-chatbot-backend:latest
minikube image load todo-chatbot-frontend:latest
```

#### 2. Pods Stuck in Pending

```bash
# Check pod status
kubectl get pods -n todo-chatbot

# Describe pod for details
kubectl describe pod <pod-name> -n todo-chatbot

# Common causes:
# - Insufficient resources (increase Minikube memory)
# - PVC not bound (check storage class)
# - Image pull errors (verify image exists in Minikube)
```

#### 3. Pods CrashLoopBackOff

```bash
# Check logs
kubectl logs <pod-name> -n todo-chatbot

# Common causes:
# - Missing OPENAI_API_KEY
# - Database connection errors
# - Port conflicts

# Update secret
kubectl edit secret todo-chatbot-secret -n todo-chatbot
```

#### 4. Service Not Accessible

```bash
# Check service
kubectl get svc -n todo-chatbot

# For NodePort services
minikube service todo-chatbot-frontend -n todo-chatbot

# Port forward for debugging
kubectl port-forward -n todo-chatbot svc/todo-chatbot-frontend 3000:80
```

#### 5. Health Checks Failing

```bash
# Check pod health
kubectl get pods -n todo-chatbot -o wide

# Exec into pod
kubectl exec -it <pod-name> -n todo-chatbot -- /bin/sh

# Test health endpoint manually
curl http://localhost:8001/api/health  # Backend
curl http://localhost/health            # Frontend
```

### Debug Commands

```bash
# View all resources
kubectl get all -n todo-chatbot

# Check events
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp'

# View logs
kubectl logs -f <pod-name> -n todo-chatbot

# Describe resource
kubectl describe <resource-type> <resource-name> -n todo-chatbot

# Access Minikube dashboard
minikube dashboard
```

## 🧹 Cleanup

### Remove Deployment

```bash
# Interactive cleanup script
./scripts/cleanup.sh

# Or manual cleanup
kubectl delete namespace todo-chatbot

# Remove Helm release
helm uninstall todo-chatbot -n todo-chatbot
```

### Remove Docker Images

```bash
docker rmi todo-chatbot-backend:latest
docker rmi todo-chatbot-frontend:latest
```

### Stop Minikube

```bash
# Stop cluster
minikube stop

# Delete cluster (removes all data)
minikube delete
```

## 📚 Additional Resources

- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Helm Documentation**: https://helm.sh/docs/
- **Minikube Documentation**: https://minikube.sigs.k8s.io/docs/
- **Docker Documentation**: https://docs.docker.com/
- **Phase III Chatbot**: ../phase-3-chatbot/QUICKSTART.md

## 🎓 Learning Path

1. **Start Simple**: Use Docker Compose first
2. **Kubernetes Basics**: Deploy with kubectl
3. **Package Management**: Upgrade to Helm
4. **AI DevOps**: Experiment with kubectl-ai and Kagent
5. **Customization**: Create environment-specific overlays

## 🤝 Support

For issues or questions:
- Check logs: `kubectl logs <pod-name> -n todo-chatbot`
- Review events: `kubectl get events -n todo-chatbot`
- Use verification script: `./scripts/verify-deployment.sh`
- Consult Phase III documentation for app-specific issues

## 📝 Next Steps

- **Phase V**: Production cloud deployment (DOKS, Kafka, Dapr)
- **Monitoring**: Add Prometheus and Grafana
- **CI/CD**: Automate with GitHub Actions
- **Security**: Implement network policies and RBAC
