# Deployment Automation Scripts

Task 4: Deployment Automation
Reference: specs/003-local-k8s-deployment/tasks.md

This directory contains automation scripts for deploying the Todo Chatbot application to Kubernetes.

## Available Scripts

### 1. setup-minikube.sh (Task 4.1)

Sets up Minikube for local Kubernetes deployment.

**Features:**
- Checks prerequisites (Minikube, kubectl, Docker)
- Configures resource allocation (CPU, memory, disk)
- Starts Minikube with appropriate settings
- Enables required addons (ingress, metrics-server, storage)
- Configures kubectl context
- Verifies setup

**Usage:**
```bash
# Run with default settings
./phase-4-local-deployment/scripts/setup-minikube.sh

# Customize resources with environment variables
MINIKUBE_CPUS=4 MINIKUBE_MEMORY=8192 ./phase-4-local-deployment/scripts/setup-minikube.sh

# Using specific driver
MINIKUBE_DRIVER=virtualbox ./phase-4-local-deployment/scripts/setup-minikube.sh
```

**Environment Variables:**
- `MINIKUBE_CPUS` - CPU cores (default: 2)
- `MINIKUBE_MEMORY` - Memory in MB (default: 4096)
- `MINIKUBE_DISK` - Disk size (default: 20g)
- `MINIKUBE_DRIVER` - Driver to use (default: docker)
- `KUBERNETES_VERSION` - Kubernetes version (default: v1.28.3)

**Output:**
- Minikube status and configuration
- Cluster information
- Node status
- System pods status
- Minikube IP address
- Next steps and useful commands

**Prerequisites:**
- Minikube installed
- kubectl installed
- Docker installed (for docker driver)
- Docker running

---

### 2. build-images.sh (Task 4.2)

Builds Docker images for backend and frontend.

**Status:** ✅ Implemented

**Features:**
- Builds backend Docker image
- Builds frontend Docker image
- Loads images into Minikube
- Tags images appropriately (version + latest)
- Verifies images are available
- Minikube Docker environment configuration
- Selective building (backend/frontend flags)
- Image size reporting

---

### 3. deploy-kubectl.sh (Task 4.3)

Deploys application using kubectl and Kustomize.

**Status:** ✅ Implemented

**Features:**
- Applies Kubernetes manifests using Kustomize
- Creates namespace
- Interactive secret management (prompts for API keys)
- Deploys backend and frontend
- Waits for deployments to be ready with timeout
- Verifies deployment health
- Shows pod logs on failure
- Access information display
- Image availability checking

---

### 4. deploy-helm.sh (Task 4.4)

Deploys application using Helm.

**Status:** ✅ Implemented

**Features:**
- Installs or upgrades Helm release (auto-detection)
- Helm chart linting before deployment
- Interactive secret management with auto-generation
- Configures values from files (values-local, values-dev, values-prod)
- Waits for deployment with configurable timeout
- Dry-run support for testing
- Release verification and status display
- Comprehensive Helm/kubectl command guidance

---

### 5. verify-deployment.sh (Task 4.5)

Verifies application deployment health.

**Status:** ✅ Implemented

**Features:**
- Checks namespace existence
- Verifies all pods are Running and Ready
- Validates services and endpoints
- Checks PVC binding status
- Tests backend health endpoint via port-forward
- Tests frontend health endpoint via NodePort
- Runs smoke tests (API docs, tasks endpoint)
- Color-coded status reporting (✓ pass, ✗ fail, ⚠ warning)
- Overall pass/fail exit code
- Troubleshooting guidance on failure

---

### 6. cleanup.sh (Task 4.6)

Cleans up deployed resources.

**Status:** ✅ Implemented

**Features:**
- User confirmation prompts before deletion
- Automatic detection of deployment method (Helm or kubectl)
- Helm release uninstallation
- Namespace deletion (removes all resources)
- Optional Docker image removal (prompt)
- Optional Minikube stop/delete (prompt)
- Cleanup summary with detailed reporting
- Force mode for non-interactive cleanup
- Environment variable configuration

---

## Quick Start Guide

### 1. Setup Minikube

```bash
# Start Minikube with default settings
./phase-4-local-deployment/scripts/setup-minikube.sh

# Or with custom resources
MINIKUBE_CPUS=4 MINIKUBE_MEMORY=8192 ./phase-4-local-deployment/scripts/setup-minikube.sh
```

### 2. Build Docker Images

```bash
# Build images (Task 4.2 - to be implemented)
./phase-4-local-deployment/scripts/build-images.sh
```

### 3. Deploy Application

**Option A: Using kubectl**
```bash
# Deploy with kubectl (Task 4.3 - to be implemented)
./phase-4-local-deployment/scripts/deploy-kubectl.sh
```

**Option B: Using Helm**
```bash
# Deploy with Helm (Task 4.4 - to be implemented)
./phase-4-local-deployment/scripts/deploy-helm.sh
```

### 4. Verify Deployment

```bash
# Verify deployment (Task 4.5 - to be implemented)
./phase-4-local-deployment/scripts/verify-deployment.sh
```

### 5. Access Application

```bash
# Get Minikube IP
minikube ip

# Access frontend at http://<minikube-ip>:30080
# Or use:
minikube service todo-chatbot-frontend -n todo-chatbot
```

### 6. Cleanup

```bash
# Clean up resources (Task 4.6 - to be implemented)
./phase-4-local-deployment/scripts/cleanup.sh
```

## Script Dependencies

```
setup-minikube.sh (4.1)
    ↓
build-images.sh (4.2)
    ↓
deploy-kubectl.sh (4.3)  OR  deploy-helm.sh (4.4)
    ↓
verify-deployment.sh (4.5)
    ↓
cleanup.sh (4.6)
```

## Troubleshooting

### Minikube won't start

```bash
# Check Docker is running
docker info

# Delete and recreate Minikube
minikube delete
./phase-4-local-deployment/scripts/setup-minikube.sh
```

### Images not found

```bash
# Ensure Docker environment is set
eval $(minikube docker-env)

# Rebuild images
./phase-4-local-deployment/scripts/build-images.sh
```

### Pods not starting

```bash
# Check pod status
kubectl get pods -n todo-chatbot

# Describe pod for details
kubectl describe pod <pod-name> -n todo-chatbot

# Check logs
kubectl logs <pod-name> -n todo-chatbot
```

## Manual Deployment

If scripts are not available, use manual commands:

**Setup Minikube:**
```bash
minikube start --cpus=2 --memory=4096 --disk-size=20g --driver=docker
minikube addons enable ingress metrics-server
kubectl config use-context minikube
```

**Build Images:**
```bash
eval $(minikube docker-env)
cd phase-4-local-deployment/docker
docker-compose build
```

**Deploy with kubectl:**
```bash
kubectl apply -k phase-4-local-deployment/k8s/base
```

**Deploy with Helm:**
```bash
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f ./phase-4-local-deployment/helm/todo-chatbot/values-local.yaml \
  --set secrets.OPENAI_API_KEY="your-key" \
  --set secrets.BETTER_AUTH_SECRET="your-secret"
```

## Additional Resources

- **Task Documentation:** `specs/003-local-k8s-deployment/tasks.md`
- **Kubernetes Manifests:** `phase-4-local-deployment/k8s/base/`
- **Helm Chart:** `phase-4-local-deployment/helm/todo-chatbot/`
- **Docker Configuration:** `phase-4-local-deployment/docker/`
- **Minikube Docs:** https://minikube.sigs.k8s.io/docs/
- **kubectl Docs:** https://kubernetes.io/docs/reference/kubectl/
- **Helm Docs:** https://helm.sh/docs/
