# Troubleshooting Guide: Phase IV Local Kubernetes Deployment

This guide covers common issues encountered during Phase IV deployment and their resolutions.

## Table of Contents

- [Quick Diagnostic Commands](#quick-diagnostic-commands)
- [Pod Issues](#pod-issues)
  - [ImagePullBackOff](#imagepullbackoff)
  - [CrashLoopBackOff](#crashloopbackoff)
  - [Pending Pods](#pending-pods)
  - [Init:Error or Init:CrashLoopBackOff](#initerror-or-initcrashloopbackoff)
- [Docker Issues](#docker-issues)
  - [Build Failures](#build-failures)
  - [Image Not Found in Minikube](#image-not-found-in-minikube)
- [Minikube Issues](#minikube-issues)
  - [Insufficient Resources](#insufficient-resources)
  - [Minikube Won't Start](#minikube-wont-start)
  - [Addons Not Working](#addons-not-working)
- [Secret Configuration Issues](#secret-configuration-issues)
- [Networking Issues](#networking-issues)
- [PersistentVolume Issues](#persistentvolume-issues)
- [Helm Issues](#helm-issues)
- [Debugging Techniques](#debugging-techniques)

---

## Quick Diagnostic Commands

Run these first to get an overview of the deployment state:

```bash
# Check all resources in the namespace
kubectl get all -n todo-chatbot

# Check pod status with detailed info
kubectl get pods -n todo-chatbot -o wide

# Check recent events (most useful)
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp'

# Run verification script
./phase-4-local-deployment/scripts/verify-deployment.sh

# Check Minikube status
minikube status

# Check Minikube IP
minikube ip
```

---

## Pod Issues

### ImagePullBackOff

**Symptoms:**
- Pod status shows `ImagePullBackOff` or `ErrImagePull`
- Pods never reach Running state

**Cause:**
- Image doesn't exist in Minikube's Docker daemon
- Wrong image name or tag
- Image pull policy set to `Always` but image is local

**Diagnostic Commands:**
```bash
# Check pod details
kubectl describe pod <pod-name> -n todo-chatbot

# List images in Minikube
minikube image ls | grep todo-chatbot

# Check local Docker images
docker images | grep todo-chatbot
```

**Resolution:**

**Option 1: Build and Load Images**
```bash
# Use Minikube's Docker daemon
eval $(minikube docker-env)

# Rebuild images
./phase-4-local-deployment/scripts/build-images.sh

# Verify images exist in Minikube
minikube image ls | grep todo-chatbot
```

**Option 2: Load Existing Images**
```bash
# If images exist locally but not in Minikube
minikube image load todo-chatbot-backend:latest
minikube image load todo-chatbot-frontend:latest
```

**Option 3: Fix Image Pull Policy**
```bash
# Edit deployment to use IfNotPresent
kubectl edit deployment todo-chatbot-backend -n todo-chatbot

# Change imagePullPolicy from "Always" to "IfNotPresent"
```

**Restart Deployment:**
```bash
kubectl rollout restart deployment/todo-chatbot-backend -n todo-chatbot
kubectl rollout restart deployment/todo-chatbot-frontend -n todo-chatbot
```

---

### CrashLoopBackOff

**Symptoms:**
- Pod status shows `CrashLoopBackOff`
- Pod starts but immediately crashes
- Restart count keeps increasing

**Cause:**
- Application error on startup
- Missing environment variables (OPENAI_API_KEY)
- Database connection issues
- Port already in use
- Health check failures

**Diagnostic Commands:**
```bash
# Check pod logs
kubectl logs <pod-name> -n todo-chatbot

# Check previous crash logs
kubectl logs <pod-name> -n todo-chatbot --previous

# Describe pod for events
kubectl describe pod <pod-name> -n todo-chatbot

# Check environment variables
kubectl exec <pod-name> -n todo-chatbot -- env | grep -E 'OPENAI|DATABASE'
```

**Resolution:**

**Fix 1: Missing OPENAI_API_KEY**
```bash
# Check secret exists
kubectl get secret todo-chatbot-secret -n todo-chatbot

# View secret (base64 encoded)
kubectl get secret todo-chatbot-secret -n todo-chatbot -o yaml

# Update secret
kubectl delete secret todo-chatbot-secret -n todo-chatbot
kubectl create secret generic todo-chatbot-secret \
  --from-literal=OPENAI_API_KEY="your-actual-key" \
  --from-literal=BETTER_AUTH_SECRET="$(openssl rand -hex 32)" \
  -n todo-chatbot

# Restart deployment
kubectl rollout restart deployment/todo-chatbot-backend -n todo-chatbot
```

**Fix 2: Database Issues**
```bash
# Check PVC is bound
kubectl get pvc -n todo-chatbot

# Check volume mount
kubectl describe pod <pod-name> -n todo-chatbot | grep -A 5 "Mounts"

# Exec into pod and check database
kubectl exec -it <pod-name> -n todo-chatbot -- ls -la /app/data/
```

**Fix 3: Application Error**
```bash
# View detailed logs
kubectl logs <pod-name> -n todo-chatbot --tail=100

# Common Python errors:
# - ModuleNotFoundError: Rebuild image with correct dependencies
# - ImportError: Check Python version compatibility (use 3.12, not 3.13)
# - AttributeError: Check OpenAI SDK version
```

**Fix 4: Port Conflict**
```bash
# Check if port is already in use
kubectl exec -it <pod-name> -n todo-chatbot -- netstat -tulpn | grep 8001

# If conflict, check if multiple containers in pod
kubectl get pod <pod-name> -n todo-chatbot -o jsonpath='{.spec.containers[*].name}'
```

---

### Pending Pods

**Symptoms:**
- Pod status stuck at `Pending`
- No containers running
- Events show scheduling errors

**Cause:**
- Insufficient cluster resources (CPU/memory)
- PVC not bound
- Node selector constraints not met
- Taints/tolerations issues

**Diagnostic Commands:**
```bash
# Describe pod to see scheduling events
kubectl describe pod <pod-name> -n todo-chatbot

# Check node resources
kubectl top nodes

# Check PVC status
kubectl get pvc -n todo-chatbot

# Check pod resource requests
kubectl get pod <pod-name> -n todo-chatbot -o yaml | grep -A 10 resources
```

**Resolution:**

**Fix 1: Insufficient Resources**
```bash
# Check Minikube resources
minikube status

# Increase Minikube resources
minikube delete
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Or reduce pod resource requests
kubectl edit deployment/todo-chatbot-backend -n todo-chatbot
# Reduce resources.requests values
```

**Fix 2: PVC Not Bound**
```bash
# Check PVC status
kubectl get pvc todo-chatbot-data -n todo-chatbot

# If Pending, check storage class
kubectl get storageclass

# Minikube should have 'standard' (default)
# If missing, enable storage-provisioner addon
minikube addons enable storage-provisioner

# Delete and recreate PVC
kubectl delete pvc todo-chatbot-data -n todo-chatbot
kubectl apply -f phase-4-local-deployment/k8s/base/pvc.yaml
```

**Fix 3: Node Affinity Issues**
```bash
# Check node labels
kubectl get nodes --show-labels

# Remove node selectors if present
kubectl edit deployment/todo-chatbot-backend -n todo-chatbot
# Remove spec.template.spec.nodeSelector section
```

---

### Init:Error or Init:CrashLoopBackOff

**Symptoms:**
- Pod shows `Init:Error` or `Init:CrashLoopBackOff`
- Init containers failing

**Diagnostic Commands:**
```bash
# Check init container logs
kubectl logs <pod-name> -n todo-chatbot -c <init-container-name>

# Describe pod
kubectl describe pod <pod-name> -n todo-chatbot
```

**Resolution:**
```bash
# Review init container configuration
kubectl get pod <pod-name> -n todo-chatbot -o yaml | grep -A 20 initContainers

# Fix init container script or remove if not needed
kubectl edit deployment/todo-chatbot-backend -n todo-chatbot
```

---

## Docker Issues

### Build Failures

**Symptoms:**
- `docker build` command fails
- Build script exits with errors

**Diagnostic Commands:**
```bash
# Build with verbose output
docker build -f phase-4-local-deployment/docker/backend/Dockerfile \
  -t todo-chatbot-backend:latest . --progress=plain

# Check Docker daemon
docker info

# Check disk space
df -h
```

**Common Errors and Fixes:**

**Error 1: Python Package Installation Fails**
```bash
# Check requirements.txt exists
cat phase-3-chatbot/backend/requirements.txt

# Try building with --no-cache
docker build --no-cache -f phase-4-local-deployment/docker/backend/Dockerfile \
  -t todo-chatbot-backend:latest .
```

**Error 2: COPY Failed - No Such File**
```bash
# Ensure build context is project root
pwd  # Should be: .../to-do-in-memory

# Build from correct directory
cd /path/to/to-do-in-memory
docker build -f phase-4-local-deployment/docker/backend/Dockerfile \
  -t todo-chatbot-backend:latest .
```

**Error 3: Out of Disk Space**
```bash
# Clean up Docker
docker system prune -a --volumes

# Remove old images
docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi
```

**Error 4: Network Issues**
```bash
# Check internet connectivity
ping -c 3 pypi.org

# Use different package index
# Edit Dockerfile to add:
# RUN pip install --no-cache-dir -r requirements.txt \
#     --index-url https://pypi.org/simple --trusted-host pypi.org
```

---

### Image Not Found in Minikube

**Symptoms:**
- Images exist locally but not in Minikube
- `minikube image ls` doesn't show images

**Resolution:**
```bash
# Option 1: Use Minikube's Docker daemon
eval $(minikube docker-env)
./phase-4-local-deployment/scripts/build-images.sh

# Option 2: Load existing images
minikube image load todo-chatbot-backend:latest
minikube image load todo-chatbot-frontend:latest

# Verify
minikube image ls | grep todo-chatbot

# Reset Docker environment (to use local Docker again)
eval $(minikube docker-env --unset)
```

---

## Minikube Issues

### Insufficient Resources

**Symptoms:**
- Pods stuck in Pending
- Events show "Insufficient memory" or "Insufficient cpu"
- Minikube slow or unresponsive

**Diagnostic Commands:**
```bash
# Check Minikube resource allocation
minikube config get memory
minikube config get cpus

# Check actual usage
kubectl top nodes
kubectl top pods -n todo-chatbot
```

**Resolution:**
```bash
# Delete and recreate with more resources
minikube delete
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Or use setup script
MINIKUBE_CPUS=4 MINIKUBE_MEMORY=8192 \
  ./phase-4-local-deployment/scripts/setup-minikube.sh
```

---

### Minikube Won't Start

**Symptoms:**
- `minikube start` fails
- Timeout errors
- Driver errors

**Diagnostic Commands:**
```bash
# Check Minikube status
minikube status

# Check Docker is running
docker info

# View Minikube logs
minikube logs
```

**Common Fixes:**

**Fix 1: Docker Not Running**
```bash
# Start Docker Desktop (Windows/Mac)
# Or start Docker daemon (Linux):
sudo systemctl start docker
```

**Fix 2: VT-x/AMD-v Not Enabled**
```bash
# Enable virtualization in BIOS
# Then delete and recreate Minikube
minikube delete
minikube start --driver=docker
```

**Fix 3: Old Minikube Cluster**
```bash
# Delete corrupted cluster
minikube delete --all --purge

# Start fresh
minikube start --driver=docker --cpus=2 --memory=4096
```

**Fix 4: Permission Issues (Linux)**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Restart Minikube
minikube delete
minikube start
```

---

### Addons Not Working

**Symptoms:**
- Ingress not working
- Metrics server unavailable
- Storage provisioner failing

**Resolution:**
```bash
# List addons
minikube addons list

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable storage-provisioner
minikube addons enable default-storageclass

# Verify addon pods
kubectl get pods -n kube-system
```

---

## Secret Configuration Issues

**Symptoms:**
- Pods crash with authentication errors
- OpenAI API calls fail
- 401 Unauthorized errors

**Diagnostic Commands:**
```bash
# Check secret exists
kubectl get secret todo-chatbot-secret -n todo-chatbot

# View secret structure (keys only)
kubectl get secret todo-chatbot-secret -n todo-chatbot -o jsonpath='{.data}'

# Check secret is mounted in pod
kubectl describe pod <pod-name> -n todo-chatbot | grep -A 5 "Environment"
```

**Resolution:**

**Recreate Secret:**
```bash
# Delete existing secret
kubectl delete secret todo-chatbot-secret -n todo-chatbot

# Create with correct values
kubectl create secret generic todo-chatbot-secret \
  --from-literal=OPENAI_API_KEY="sk-your-actual-openai-api-key" \
  --from-literal=BETTER_AUTH_SECRET="$(openssl rand -hex 32)" \
  -n todo-chatbot

# Restart pods to pick up new secret
kubectl rollout restart deployment/todo-chatbot-backend -n todo-chatbot
```

**Verify Secret Value:**
```bash
# Decode secret (check it's correct)
kubectl get secret todo-chatbot-secret -n todo-chatbot \
  -o jsonpath='{.data.OPENAI_API_KEY}' | base64 --decode

# Should start with "sk-"
```

---

## Networking Issues

### Service Not Accessible

**Symptoms:**
- Cannot access frontend via NodePort
- Backend not reachable from frontend
- Service endpoints empty

**Diagnostic Commands:**
```bash
# Check services
kubectl get svc -n todo-chatbot

# Check endpoints
kubectl get endpoints -n todo-chatbot

# Check pod labels match service selector
kubectl get pods -n todo-chatbot --show-labels
kubectl get svc todo-chatbot-backend -n todo-chatbot -o yaml | grep selector
```

**Resolution:**

**Fix 1: NodePort Not Accessible**
```bash
# Get Minikube IP
minikube ip

# Get NodePort
kubectl get svc todo-chatbot-frontend -n todo-chatbot

# Access via: http://<minikube-ip>:<nodeport>

# Or use minikube service
minikube service todo-chatbot-frontend -n todo-chatbot --url
```

**Fix 2: Service Has No Endpoints**
```bash
# Check pod labels
kubectl get pods -n todo-chatbot -l app=todo-chatbot-backend

# If no pods match, update deployment labels
kubectl edit deployment/todo-chatbot-backend -n todo-chatbot
# Ensure spec.template.metadata.labels.app=todo-chatbot-backend
```

**Fix 3: DNS Not Resolving**
```bash
# Test DNS from pod
kubectl exec -it <frontend-pod> -n todo-chatbot -- \
  nslookup todo-chatbot-backend.todo-chatbot.svc.cluster.local

# If fails, check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

---

## PersistentVolume Issues

**Symptoms:**
- PVC stuck in Pending
- Data not persisting across pod restarts
- Volume mount failures

**Diagnostic Commands:**
```bash
# Check PVC status
kubectl get pvc -n todo-chatbot

# Describe PVC
kubectl describe pvc todo-chatbot-data -n todo-chatbot

# Check storage classes
kubectl get storageclass
```

**Resolution:**

**Fix 1: No Storage Class**
```bash
# Enable storage provisioner
minikube addons enable storage-provisioner
minikube addons enable default-storageclass

# Verify
kubectl get storageclass

# Delete and recreate PVC
kubectl delete pvc todo-chatbot-data -n todo-chatbot
kubectl apply -f phase-4-local-deployment/k8s/base/pvc.yaml
```

**Fix 2: Volume Mount Permissions**
```bash
# Check pod logs for permission errors
kubectl logs <pod-name> -n todo-chatbot

# If permission denied, exec into pod
kubectl exec -it <pod-name> -n todo-chatbot -- ls -la /app/data/

# Fix permissions (if needed)
kubectl exec -it <pod-name> -n todo-chatbot -- chown -R 1000:1000 /app/data/
```

---

## Helm Issues

**Symptoms:**
- Helm install/upgrade fails
- Release in failed state
- Template rendering errors

**Diagnostic Commands:**
```bash
# List releases
helm list -n todo-chatbot

# Get release status
helm status todo-chatbot -n todo-chatbot

# View release history
helm history todo-chatbot -n todo-chatbot

# Debug template rendering
helm template todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f ./phase-4-local-deployment/helm/todo-chatbot/values-local.yaml
```

**Resolution:**

**Fix 1: Failed Release**
```bash
# Uninstall failed release
helm uninstall todo-chatbot -n todo-chatbot

# Reinstall
./phase-4-local-deployment/scripts/deploy-helm.sh
```

**Fix 2: Template Errors**
```bash
# Lint chart
helm lint ./phase-4-local-deployment/helm/todo-chatbot

# Dry-run to check rendering
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f ./phase-4-local-deployment/helm/todo-chatbot/values-local.yaml \
  --dry-run --debug
```

**Fix 3: Rollback**
```bash
# View history
helm history todo-chatbot -n todo-chatbot

# Rollback to previous revision
helm rollback todo-chatbot <revision-number> -n todo-chatbot
```

---

## Debugging Techniques

### View Pod Logs

```bash
# Current logs
kubectl logs <pod-name> -n todo-chatbot

# Previous container logs (after crash)
kubectl logs <pod-name> -n todo-chatbot --previous

# Follow logs (tail -f)
kubectl logs -f <pod-name> -n todo-chatbot

# Logs from all pods with label
kubectl logs -l app=todo-chatbot-backend -n todo-chatbot --tail=50

# Logs with timestamps
kubectl logs <pod-name> -n todo-chatbot --timestamps
```

### Execute Commands in Pod

```bash
# Get shell in pod
kubectl exec -it <pod-name> -n todo-chatbot -- /bin/sh

# Or bash if available
kubectl exec -it <pod-name> -n todo-chatbot -- /bin/bash

# Run single command
kubectl exec <pod-name> -n todo-chatbot -- ls -la /app

# Check environment variables
kubectl exec <pod-name> -n todo-chatbot -- env

# Test network connectivity
kubectl exec <pod-name> -n todo-chatbot -- curl http://todo-chatbot-backend:8001/health
```

### Describe Resources

```bash
# Describe pod (most useful for troubleshooting)
kubectl describe pod <pod-name> -n todo-chatbot

# Describe deployment
kubectl describe deployment/todo-chatbot-backend -n todo-chatbot

# Describe service
kubectl describe svc/todo-chatbot-backend -n todo-chatbot

# Describe PVC
kubectl describe pvc/todo-chatbot-data -n todo-chatbot
```

### View Events

```bash
# Recent events in namespace
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp'

# Watch events (real-time)
kubectl get events -n todo-chatbot --watch

# Events for specific pod
kubectl describe pod <pod-name> -n todo-chatbot | grep -A 20 "Events"
```

### Port Forwarding for Testing

```bash
# Forward backend port
kubectl port-forward -n todo-chatbot svc/todo-chatbot-backend 8001:8001

# Forward frontend port
kubectl port-forward -n todo-chatbot svc/todo-chatbot-frontend 3000:80

# Forward to specific pod
kubectl port-forward -n todo-chatbot <pod-name> 8001:8001

# Test endpoint
curl http://localhost:8001/health
```

### Check Resource Usage

```bash
# Node resource usage
kubectl top nodes

# Pod resource usage
kubectl top pods -n todo-chatbot

# Describe node resources
kubectl describe node minikube
```

### Minikube Dashboard

```bash
# Launch Kubernetes dashboard
minikube dashboard

# Get dashboard URL without opening browser
minikube dashboard --url
```

---

## Additional Resources

- **Kubernetes Documentation**: https://kubernetes.io/docs/tasks/debug/
- **Minikube Troubleshooting**: https://minikube.sigs.k8s.io/docs/handbook/troubleshooting/
- **Helm Troubleshooting**: https://helm.sh/docs/faq/troubleshooting/
- **Docker Troubleshooting**: https://docs.docker.com/config/daemon/troubleshoot/
- **Phase IV README**: ../README.md
- **Deployment Scripts**: ../scripts/README.md

---

## Still Having Issues?

If none of the above solutions work:

1. **Run the verification script**:
   ```bash
   ./phase-4-local-deployment/scripts/verify-deployment.sh
   ```

2. **Collect diagnostic information**:
   ```bash
   kubectl get all -n todo-chatbot > diagnostics.txt
   kubectl describe pods -n todo-chatbot >> diagnostics.txt
   kubectl get events -n todo-chatbot --sort-by='.lastTimestamp' >> diagnostics.txt
   minikube logs >> diagnostics.txt
   ```

3. **Clean slate approach**:
   ```bash
   # Complete cleanup
   ./phase-4-local-deployment/scripts/cleanup.sh

   # Restart Minikube
   minikube delete
   minikube start --cpus=4 --memory=8192

   # Redeploy
   ./phase-4-local-deployment/scripts/setup-minikube.sh
   ./phase-4-local-deployment/scripts/build-images.sh
   ./phase-4-local-deployment/scripts/deploy-helm.sh
   ```

4. **Check Phase III application** works standalone before deploying to Kubernetes

5. **Review logs systematically**:
   - Minikube logs: `minikube logs`
   - Docker logs: `docker logs <container-id>`
   - Kubectl logs: `kubectl logs <pod-name> -n todo-chatbot`
   - System logs: Check Docker Desktop or system journal
