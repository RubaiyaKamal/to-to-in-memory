# Implementation Tasks: Local Kubernetes Deployment

**Feature Branch**: `003-local-k8s-deployment`
**Created**: 2025-12-30
**Status**: Ready for Implementation
**Dependencies**: Phase III Todo Chatbot (complete)

## Task Organization

Tasks are organized by priority (P0 = Critical, P1 = High, P2 = Medium, P3 = Low) and dependency order.

## P0: Critical Path - Containerization

### Task 1.1: Create Backend Dockerfile with Multi-Stage Build

**Priority**: P0 (Critical)
**Estimated Effort**: 2 hours
**Dependencies**: None
**Files to Create/Modify**:
- `phase-4-local-deployment/docker/backend/Dockerfile`

**Description**:
Create a multi-stage Dockerfile for the Phase III FastAPI backend application that produces an optimized production image.

**Acceptance Criteria**:
- [ ] Dockerfile has two stages: builder and runtime
- [ ] Builder stage uses `python:3.13` or `python:3.13-slim`
- [ ] Builder stage installs all dependencies from `requirements.txt`
- [ ] Runtime stage uses `python:3.13-slim` for minimal image size
- [ ] Runtime stage copies only necessary files from builder
- [ ] Final image size is under 250MB
- [ ] Image runs as non-root user (UID 1000)
- [ ] Working directory is `/app`
- [ ] Port 8001 is exposed
- [ ] Healthcheck defined for liveness probe
- [ ] Environment variables documented in Dockerfile comments
- [ ] Image builds successfully: `docker build -t todo-chatbot-backend:latest .`
- [ ] Image runs successfully: `docker run -p 8001:8001 -e OPENAI_API_KEY=test -e DATABASE_URL=sqlite:///data/todo.db todo-chatbot-backend:latest`

**Test Cases**:
1. **Build Test**: Image builds without errors in under 5 minutes
2. **Size Test**: Final image size is under 250MB (`docker images todo-chatbot-backend`)
3. **Run Test**: Container starts and health endpoint responds 200 OK
4. **Security Test**: Container runs as non-root user (check with `docker exec <container> whoami`)

---

### Task 1.2: Create Frontend Dockerfile with Multi-Stage Build

**Priority**: P0 (Critical)
**Estimated Effort**: 2 hours
**Dependencies**: None
**Files to Create/Modify**:
- `phase-4-local-deployment/docker/frontend/Dockerfile`
- `phase-4-local-deployment/docker/frontend/nginx.conf`

**Description**:
Create a multi-stage Dockerfile for the Phase III Next.js frontend that builds the static site and serves it with Nginx.

**Acceptance Criteria**:
- [ ] Dockerfile has two stages: builder and runtime
- [ ] Builder stage uses `node:20` or `node:20-alpine`
- [ ] Builder stage runs `npm install` and `npm run build`
- [ ] Runtime stage uses `nginx:alpine` for minimal image size
- [ ] Static build output copied from builder to Nginx html directory
- [ ] Custom `nginx.conf` configures SPA routing (fallback to index.html)
- [ ] Final image size is under 100MB
- [ ] Port 80 is exposed
- [ ] Healthcheck endpoint `/health` returns 200 OK
- [ ] Build-time arg `VITE_API_URL` for backend URL
- [ ] Image builds successfully: `docker build -t todo-chatbot-frontend:latest --build-arg VITE_API_URL=http://localhost:8001 .`
- [ ] Image runs successfully: `docker run -p 3000:80 todo-chatbot-frontend:latest`

**Test Cases**:
1. **Build Test**: Image builds without errors in under 5 minutes
2. **Size Test**: Final image size is under 100MB (`docker images todo-chatbot-frontend`)
3. **Run Test**: Container starts and serves UI on port 80
4. **Nginx Test**: Accessing any route (e.g., `/tasks`) returns index.html (SPA routing works)
5. **Health Test**: `/health` endpoint returns 200 OK

---

### Task 1.3: Create Docker Compose for Local Testing

**Priority**: P0 (Critical)
**Estimated Effort**: 1 hour
**Dependencies**: Task 1.1, Task 1.2
**Files to Create/Modify**:
- `phase-4-local-deployment/docker/docker-compose.yml`

**Description**:
Create a Docker Compose file for local testing of containerized application before Kubernetes deployment.

**Acceptance Criteria**:
- [ ] Compose file defines two services: `backend` and `frontend`
- [ ] Backend service builds from `./backend/Dockerfile`
- [ ] Frontend service builds from `./frontend/Dockerfile`
- [ ] Backend exposes port 8001
- [ ] Frontend exposes port 3000
- [ ] Backend has environment variables: `DATABASE_URL`, `OPENAI_API_KEY`, `BETTER_AUTH_SECRET`
- [ ] Frontend has build arg: `VITE_API_URL=http://localhost:8001`
- [ ] Backend has volume mount for database persistence
- [ ] Services can communicate via Docker network
- [ ] Compose starts successfully: `docker-compose up -d`
- [ ] Frontend accessible at `http://localhost:3000`
- [ ] Backend accessible at `http://localhost:8001/docs`

**Test Cases**:
1. **Start Test**: `docker-compose up -d` starts both services without errors
2. **Network Test**: Frontend can reach backend API
3. **Persistence Test**: Database data persists after `docker-compose restart`
4. **Cleanup Test**: `docker-compose down -v` removes all resources

---

## P1: High Priority - Kubernetes Manifests

### Task 2.1: Create Kubernetes Namespace and Base Configuration

**Priority**: P1 (High)
**Estimated Effort**: 1 hour
**Dependencies**: None
**Files to Create/Modify**:
- `phase-4-local-deployment/k8s/base/namespace.yaml`
- `phase-4-local-deployment/k8s/base/kustomization.yaml`

**Description**:
Create Kubernetes namespace and Kustomize base configuration for organizing resources.

**Acceptance Criteria**:
- [ ] Namespace YAML defines `todo-chatbot` namespace
- [ ] Namespace has labels: `app=todo-chatbot`, `environment=local`
- [ ] Kustomization file lists all base resources
- [ ] Kustomization applies namespace to all resources
- [ ] Namespace creates successfully: `kubectl apply -f namespace.yaml`
- [ ] Kustomization builds successfully: `kubectl kustomize k8s/base`

**Test Cases**:
1. **Create Test**: Namespace creates without errors
2. **List Test**: `kubectl get namespace todo-chatbot` shows namespace
3. **Kustomize Test**: `kubectl kustomize k8s/base` outputs valid YAML

---

### Task 2.2: Create Kubernetes Secrets

**Priority**: P1 (High)
**Estimated Effort**: 1 hour
**Dependencies**: Task 2.1
**Files to Create/Modify**:
- `phase-4-local-deployment/k8s/base/secrets.yaml` (template)
- `phase-4-local-deployment/k8s/base/secrets.env` (gitignored, example)

**Description**:
Create Kubernetes Secret for storing sensitive configuration (OpenAI API key, JWT secret).

**Acceptance Criteria**:
- [ ] Secret named `todo-chatbot-secret` in `todo-chatbot` namespace
- [ ] Secret type is `Opaque`
- [ ] Secret contains keys: `OPENAI_API_KEY`, `BETTER_AUTH_SECRET`
- [ ] Values are base64 encoded in YAML
- [ ] Template file has placeholder values
- [ ] Example `.env` file shows format (gitignored)
- [ ] Documentation explains how to create secret from `.env`
- [ ] Secret creates successfully: `kubectl apply -f secrets.yaml`
- [ ] Secret not exposed in logs or describe output

**Test Cases**:
1. **Create Test**: Secret creates without errors
2. **Get Test**: `kubectl get secret todo-chatbot-secret -n todo-chatbot` shows secret
3. **Decode Test**: Secret values are base64 encoded
4. **Security Test**: `kubectl describe secret todo-chatbot-secret -n todo-chatbot` doesn't show plaintext values

---

### Task 2.3: Create Kubernetes ConfigMap

**Priority**: P1 (High)
**Estimated Effort**: 30 minutes
**Dependencies**: Task 2.1
**Files to Create/Modify**:
- `phase-4-local-deployment/k8s/base/configmap.yaml`

**Description**:
Create Kubernetes ConfigMap for non-sensitive application configuration.

**Acceptance Criteria**:
- [ ] ConfigMap named `todo-chatbot-config` in `todo-chatbot` namespace
- [ ] ConfigMap contains: `DATABASE_URL`, `LOG_LEVEL`, `CORS_ORIGINS`
- [ ] DATABASE_URL points to SQLite file in PVC: `sqlite:////app/data/todo.db`
- [ ] LOG_LEVEL defaults to `INFO`
- [ ] CORS_ORIGINS includes frontend service URL
- [ ] ConfigMap creates successfully: `kubectl apply -f configmap.yaml`

**Test Cases**:
1. **Create Test**: ConfigMap creates without errors
2. **Get Test**: `kubectl get configmap todo-chatbot-config -n todo-chatbot` shows configmap
3. **Describe Test**: `kubectl describe configmap todo-chatbot-config -n todo-chatbot` shows all keys and values

---

### Task 2.4: Create Persistent Volume Claim for Database

**Priority**: P1 (High)
**Estimated Effort**: 1 hour
**Dependencies**: Task 2.1
**Files to Create/Modify**:
- `phase-4-local-deployment/k8s/base/pvc.yaml`

**Description**:
Create Persistent Volume Claim for SQLite database storage that persists across pod restarts.

**Acceptance Criteria**:
- [ ] PVC named `todo-chatbot-data` in `todo-chatbot` namespace
- [ ] Storage class is `standard` (Minikube default)
- [ ] Access mode is `ReadWriteOnce`
- [ ] Storage request is `1Gi`
- [ ] PVC labels: `app=todo-chatbot`
- [ ] PVC creates successfully: `kubectl apply -f pvc.yaml`
- [ ] PVC binds to a PV: status is `Bound`

**Test Cases**:
1. **Create Test**: PVC creates without errors
2. **Bind Test**: `kubectl get pvc todo-chatbot-data -n todo-chatbot` shows status `Bound`
3. **Describe Test**: `kubectl describe pvc todo-chatbot-data -n todo-chatbot` shows volume details
4. **Persistence Test**: Data written to mounted volume persists after pod deletion

---

### Task 2.5: Create Backend Deployment

**Priority**: P1 (High)
**Estimated Effort**: 2 hours
**Dependencies**: Task 2.2, Task 2.3, Task 2.4
**Files to Create/Modify**:
- `phase-4-local-deployment/k8s/base/backend-deployment.yaml`

**Description**:
Create Kubernetes Deployment for backend FastAPI application with health checks and resource limits.

**Acceptance Criteria**:
- [ ] Deployment named `todo-chatbot-backend` in `todo-chatbot` namespace
- [ ] Replica count is 2 for high availability
- [ ] Selector matches labels: `app=todo-chatbot-backend`
- [ ] Container uses image: `todo-chatbot-backend:latest`
- [ ] Image pull policy is `IfNotPresent` (local images)
- [ ] Container port 8001 exposed
- [ ] Environment variables loaded from ConfigMap and Secret
- [ ] Volume mounted from PVC at `/app/data`
- [ ] Liveness probe: HTTP GET `/health` every 10s
- [ ] Readiness probe: HTTP GET `/api/health` every 5s
- [ ] Resource requests: 256Mi memory, 250m CPU
- [ ] Resource limits: 512Mi memory, 500m CPU
- [ ] Rolling update strategy: maxUnavailable=1, maxSurge=1
- [ ] Deployment creates successfully: `kubectl apply -f backend-deployment.yaml`
- [ ] Pods reach Running and Ready state

**Test Cases**:
1. **Create Test**: Deployment creates without errors
2. **Rollout Test**: `kubectl rollout status deployment/todo-chatbot-backend -n todo-chatbot` shows successful rollout
3. **Pod Test**: `kubectl get pods -n todo-chatbot -l app=todo-chatbot-backend` shows 2 Running pods
4. **Health Test**: Liveness and readiness probes pass (pods are Ready)
5. **Logs Test**: `kubectl logs -l app=todo-chatbot-backend -n todo-chatbot` shows application startup logs
6. **Volume Test**: Database file created in PVC at `/app/data/todo.db`

---

### Task 2.6: Create Backend Service

**Priority**: P1 (High)
**Estimated Effort**: 30 minutes
**Dependencies**: Task 2.5
**Files to Create/Modify**:
- `phase-4-local-deployment/k8s/base/backend-service.yaml`

**Description**:
Create Kubernetes Service to expose backend deployment within cluster.

**Acceptance Criteria**:
- [ ] Service named `todo-chatbot-backend` in `todo-chatbot` namespace
- [ ] Service type is `ClusterIP` (internal only)
- [ ] Selector matches backend deployment: `app=todo-chatbot-backend`
- [ ] Port 8001 mapped to target port 8001
- [ ] Service creates successfully: `kubectl apply -f backend-service.yaml`
- [ ] Service endpoint lists backend pod IPs

**Test Cases**:
1. **Create Test**: Service creates without errors
2. **Get Test**: `kubectl get svc todo-chatbot-backend -n todo-chatbot` shows service
3. **Endpoint Test**: `kubectl get endpoints todo-chatbot-backend -n todo-chatbot` shows pod IPs
4. **DNS Test**: Service accessible via DNS: `todo-chatbot-backend.todo-chatbot.svc.cluster.local:8001`

---

### Task 2.7: Create Frontend Deployment

**Priority**: P1 (High)
**Estimated Effort**: 2 hours
**Dependencies**: Task 2.6
**Files to Create/Modify**:
- `phase-4-local-deployment/k8s/base/frontend-deployment.yaml`

**Description**:
Create Kubernetes Deployment for frontend Nginx application with health checks.

**Acceptance Criteria**:
- [ ] Deployment named `todo-chatbot-frontend` in `todo-chatbot` namespace
- [ ] Replica count is 2 for high availability
- [ ] Selector matches labels: `app=todo-chatbot-frontend`
- [ ] Container uses image: `todo-chatbot-frontend:latest`
- [ ] Image pull policy is `IfNotPresent` (local images)
- [ ] Container port 80 exposed
- [ ] Liveness probe: HTTP GET `/health` every 10s
- [ ] Readiness probe: HTTP GET `/health` every 5s
- [ ] Resource requests: 128Mi memory, 100m CPU
- [ ] Resource limits: 256Mi memory, 200m CPU
- [ ] Rolling update strategy: maxUnavailable=1, maxSurge=1
- [ ] Deployment creates successfully: `kubectl apply -f frontend-deployment.yaml`
- [ ] Pods reach Running and Ready state

**Test Cases**:
1. **Create Test**: Deployment creates without errors
2. **Rollout Test**: `kubectl rollout status deployment/todo-chatbot-frontend -n todo-chatbot` shows successful rollout
3. **Pod Test**: `kubectl get pods -n todo-chatbot -l app=todo-chatbot-frontend` shows 2 Running pods
4. **Health Test**: Liveness and readiness probes pass (pods are Ready)
5. **Logs Test**: `kubectl logs -l app=todo-chatbot-frontend -n todo-chatbot` shows Nginx access logs

---

### Task 2.8: Create Frontend Service with NodePort

**Priority**: P1 (High)
**Estimated Effort**: 30 minutes
**Dependencies**: Task 2.7
**Files to Create/Modify**:
- `phase-4-local-deployment/k8s/base/frontend-service.yaml`

**Description**:
Create Kubernetes Service to expose frontend deployment via NodePort for external access.

**Acceptance Criteria**:
- [ ] Service named `todo-chatbot-frontend` in `todo-chatbot` namespace
- [ ] Service type is `NodePort`
- [ ] Selector matches frontend deployment: `app=todo-chatbot-frontend`
- [ ] Port 80 mapped to target port 80
- [ ] NodePort set to 30080 for consistent access
- [ ] Service creates successfully: `kubectl apply -f frontend-service.yaml`
- [ ] Service accessible via NodePort

**Test Cases**:
1. **Create Test**: Service creates without errors
2. **Get Test**: `kubectl get svc todo-chatbot-frontend -n todo-chatbot` shows service with NodePort 30080
3. **Access Test**: Frontend accessible at `http://localhost:30080` or via `minikube service todo-chatbot-frontend -n todo-chatbot`
4. **Load Balance Test**: Requests distributed across frontend pods

---

## P1: High Priority - Helm Charts

### Task 3.1: Create Helm Chart Structure

**Priority**: P1 (High)
**Estimated Effort**: 1 hour
**Dependencies**: None
**Files to Create/Modify**:
- `phase-4-local-deployment/helm/todo-chatbot/Chart.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/values.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/.helmignore`

**Description**:
Initialize Helm chart structure with Chart.yaml metadata and default values.yaml.

**Acceptance Criteria**:
- [ ] Chart.yaml defines chart metadata: name, version, description, appVersion
- [ ] Chart name is `todo-chatbot`
- [ ] Chart version is `0.1.0`
- [ ] App version matches Phase III version
- [ ] values.yaml contains all configurable parameters with comments
- [ ] .helmignore excludes unnecessary files
- [ ] Chart structure is valid: `helm lint helm/todo-chatbot`

**Test Cases**:
1. **Lint Test**: `helm lint helm/todo-chatbot` passes without errors
2. **Template Test**: `helm template todo-chatbot helm/todo-chatbot` generates valid YAML
3. **Schema Test**: values.yaml has all required parameters

---

### Task 3.2: Create Helm Templates for All Resources

**Priority**: P1 (High)
**Estimated Effort**: 3 hours
**Dependencies**: Task 3.1, Task 2.1-2.8
**Files to Create/Modify**:
- `phase-4-local-deployment/helm/todo-chatbot/templates/namespace.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/templates/configmap.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/templates/secret.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/templates/pvc.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/templates/backend-deployment.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/templates/backend-service.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/templates/frontend-deployment.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/templates/frontend-service.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/templates/_helpers.tpl`

**Description**:
Convert Kubernetes manifests to Helm templates with parameterized values.

**Acceptance Criteria**:
- [ ] All templates use Helm template syntax with `.Values` references
- [ ] `_helpers.tpl` defines reusable template functions (labels, names)
- [ ] Templates include proper comments explaining parameters
- [ ] Secret template supports setting values from values.yaml
- [ ] Resource limits and replica counts are configurable
- [ ] Image tags and pull policies are configurable
- [ ] Service types and ports are configurable
- [ ] Templates render correctly: `helm template todo-chatbot helm/todo-chatbot`

**Test Cases**:
1. **Render Test**: All templates render without errors
2. **Values Test**: Changing values.yaml reflects in rendered output
3. **Validation Test**: Rendered YAML passes Kubernetes validation
4. **Dry-run Test**: `helm install --dry-run --debug todo-chatbot helm/todo-chatbot` succeeds

---

### Task 3.3: Create Helm Values Examples

**Priority**: P1 (High)
**Estimated Effort**: 1 hour
**Dependencies**: Task 3.2
**Files to Create/Modify**:
- `phase-4-local-deployment/helm/todo-chatbot/values-local.yaml`
- `phase-4-local-deployment/helm/todo-chatbot/values-example.yaml`

**Description**:
Create example values files for different deployment scenarios.

**Acceptance Criteria**:
- [ ] `values-local.yaml` configured for Minikube deployment
- [ ] `values-example.yaml` shows all available configuration options
- [ ] Examples include comments explaining each parameter
- [ ] Sensitive values (secrets) have placeholder text
- [ ] Examples work with `helm install -f values-local.yaml`

**Test Cases**:
1. **Validation Test**: All values files are valid YAML
2. **Install Test**: `helm install todo-chatbot helm/todo-chatbot -f helm/todo-chatbot/values-local.yaml` succeeds
3. **Upgrade Test**: Changing values and running `helm upgrade` applies changes

---

## P2: Medium Priority - Deployment Automation

### Task 4.1: Create Minikube Setup Script

**Priority**: P2 (Medium)
**Estimated Effort**: 2 hours
**Dependencies**: None
**Files to Create/Modify**:
- `phase-4-local-deployment/scripts/setup-minikube.sh`

**Description**:
Create bash script to automate Minikube cluster setup and configuration.

**Acceptance Criteria**:
- [ ] Script checks if Minikube is installed
- [ ] Script checks if kubectl is installed
- [ ] Script checks system resources (RAM, CPU)
- [ ] Script starts Minikube if not running
- [ ] Script configures Minikube with appropriate resources (4GB RAM, 2 CPUs)
- [ ] Script enables required addons (metrics-server, storage-provisioner)
- [ ] Script verifies cluster is ready
- [ ] Script outputs Minikube status and dashboard URL
- [ ] Script is executable: `chmod +x scripts/setup-minikube.sh`
- [ ] Script runs successfully: `./scripts/setup-minikube.sh`

**Test Cases**:
1. **Check Test**: Script detects missing prerequisites
2. **Start Test**: Script starts Minikube successfully
3. **Verify Test**: Script confirms cluster is ready
4. **Idempotent Test**: Running script multiple times doesn't cause errors

---

### Task 4.2: Create Image Build Script

**Priority**: P2 (Medium)
**Estimated Effort**: 1 hour
**Dependencies**: Task 1.1, Task 1.2
**Files to Create/Modify**:
- `phase-4-local-deployment/scripts/build-images.sh`

**Description**:
Create bash script to build Docker images and load them into Minikube.

**Acceptance Criteria**:
- [ ] Script changes to correct directories for builds
- [ ] Script builds backend image: `docker build -t todo-chatbot-backend:latest`
- [ ] Script builds frontend image: `docker build -t todo-chatbot-frontend:latest`
- [ ] Script loads images into Minikube: `minikube image load`
- [ ] Script verifies images exist in Minikube
- [ ] Script outputs build status and image sizes
- [ ] Script is executable: `chmod +x scripts/build-images.sh`
- [ ] Script runs successfully: `./scripts/build-images.sh`

**Test Cases**:
1. **Build Test**: Both images build without errors
2. **Load Test**: Images loaded into Minikube successfully
3. **Verify Test**: `minikube image ls | grep todo-chatbot` shows both images
4. **Clean Test**: Script supports `--clean` flag to remove old images

---

### Task 4.3: Create Kubectl Deployment Script

**Priority**: P2 (Medium)
**Estimated Effort**: 1 hour
**Dependencies**: Task 2.1-2.8
**Files to Create/Modify**:
- `phase-4-local-deployment/scripts/deploy-k8s.sh`

**Description**:
Create bash script to deploy application using kubectl and Kustomize.

**Acceptance Criteria**:
- [ ] Script checks if kubectl is configured
- [ ] Script prompts user to set secrets if not present
- [ ] Script applies Kustomize base: `kubectl apply -k k8s/base`
- [ ] Script waits for pods to be ready
- [ ] Script outputs deployment status
- [ ] Script shows service URLs (frontend NodePort)
- [ ] Script is executable: `chmod +x scripts/deploy-k8s.sh`
- [ ] Script runs successfully: `./scripts/deploy-k8s.sh`

**Test Cases**:
1. **Deploy Test**: All resources created successfully
2. **Wait Test**: Script waits for pods to be ready before completing
3. **Output Test**: Script shows access URLs
4. **Idempotent Test**: Running script multiple times updates resources correctly

---

### Task 4.4: Create Helm Deployment Script

**Priority**: P2 (Medium)
**Estimated Effort**: 1 hour
**Dependencies**: Task 3.1-3.3
**Files to Create/Modify**:
- `phase-4-local-deployment/scripts/deploy-helm.sh`

**Description**:
Create bash script to deploy application using Helm.

**Acceptance Criteria**:
- [ ] Script checks if Helm is installed
- [ ] Script checks if values.yaml has required secrets set
- [ ] Script creates namespace if not exists
- [ ] Script installs or upgrades Helm release
- [ ] Script waits for pods to be ready
- [ ] Script outputs release status
- [ ] Script shows access URLs
- [ ] Script is executable: `chmod +x scripts/deploy-helm.sh`
- [ ] Script runs successfully: `./scripts/deploy-helm.sh`

**Test Cases**:
1. **Install Test**: Helm release installs successfully
2. **Upgrade Test**: Running script again upgrades existing release
3. **Rollback Test**: Script supports `--rollback` flag
4. **Status Test**: `helm list -n todo-chatbot` shows installed release

---

### Task 4.5: Create Deployment Verification Script

**Priority**: P2 (Medium)
**Estimated Effort**: 1 hour
**Dependencies**: Task 4.3 or Task 4.4
**Files to Create/Modify**:
- `phase-4-local-deployment/scripts/verify-deployment.sh`

**Description**:
Create bash script to verify deployment health and functionality.

**Acceptance Criteria**:
- [ ] Script checks namespace exists
- [ ] Script checks all pods are Running and Ready
- [ ] Script checks services are created
- [ ] Script checks PVC is Bound
- [ ] Script tests backend health endpoint via port-forward
- [ ] Script tests frontend health endpoint via NodePort
- [ ] Script outputs color-coded status (green=pass, red=fail)
- [ ] Script is executable: `chmod +x scripts/verify-deployment.sh`
- [ ] Script runs successfully: `./scripts/verify-deployment.sh`

**Test Cases**:
1. **Health Test**: All health checks pass for healthy deployment
2. **Failure Test**: Script detects and reports unhealthy pods
3. **Connectivity Test**: Script verifies service connectivity
4. **Output Test**: Script output is clear and actionable

---

### Task 4.6: Create Cleanup Script

**Priority**: P2 (Medium)
**Estimated Effort**: 1 hour
**Dependencies**: None
**Files to Create/Modify**:
- `phase-4-local-deployment/scripts/cleanup.sh`

**Description**:
Create bash script to remove all deployed resources.

**Acceptance Criteria**:
- [ ] Script prompts for confirmation before deletion
- [ ] Script detects deployment method (kubectl or Helm)
- [ ] Script deletes Helm release if installed
- [ ] Script deletes namespace (removes all resources)
- [ ] Script optionally stops Minikube
- [ ] Script optionally removes Docker images
- [ ] Script outputs cleanup status
- [ ] Script is executable: `chmod +x scripts/cleanup.sh`
- [ ] Script runs successfully: `./scripts/cleanup.sh`

**Test Cases**:
1. **Delete Test**: All resources removed successfully
2. **Confirmation Test**: Script requires user confirmation
3. **Helm Test**: Helm release uninstalled correctly
4. **Complete Test**: `kubectl get all -n todo-chatbot` returns no resources

---

## P3: Low Priority - AI-Assisted DevOps (Optional)

### Task 5.1: Document kubectl-ai Setup and Usage

**Priority**: P3 (Low, Optional)
**Estimated Effort**: 2 hours
**Dependencies**: None
**Files to Create/Modify**:
- `phase-4-local-deployment/docs/AI-DEVOPS.md`

**Description**:
Create documentation for installing and using kubectl-ai for natural language Kubernetes operations.

**Acceptance Criteria**:
- [ ] Document kubectl-ai installation steps (npm or binary)
- [ ] Document configuration and authentication
- [ ] Provide example commands for common operations
- [ ] Show parallel examples: AI command vs standard kubectl command
- [ ] Document limitations and troubleshooting
- [ ] Mark as optional enhancement (not required)
- [ ] Include screenshots or GIFs if possible

**Test Cases**:
1. **Installation Test**: Follow installation instructions successfully
2. **Usage Test**: Example commands work as documented
3. **Clarity Test**: Documentation is clear for beginners

---

### Task 5.2: Document Kagent Setup and Usage

**Priority**: P3 (Low, Optional)
**Estimated Effort**: 2 hours
**Dependencies**: None
**Files to Update**:
- `phase-4-local-deployment/docs/AI-DEVOPS.md`

**Description**:
Document Kagent installation and usage for cluster analysis and optimization.

**Acceptance Criteria**:
- [ ] Document Kagent installation from GitHub
- [ ] Document configuration requirements
- [ ] Provide example commands for cluster analysis
- [ ] Show use cases: health analysis, resource optimization, security audit
- [ ] Document limitations and availability
- [ ] Mark as optional enhancement
- [ ] Include example outputs

**Test Cases**:
1. **Installation Test**: Follow installation instructions successfully
2. **Usage Test**: Example commands work as documented
3. **Analysis Test**: Kagent provides useful insights

---

### Task 5.3: Document Docker AI (Gordon) Usage

**Priority**: P3 (Low, Optional)
**Estimated Effort**: 1 hour
**Dependencies**: None
**Files to Update**:
- `phase-4-local-deployment/docs/AI-DEVOPS.md`

**Description**:
Document Docker AI (Gordon) usage for AI-assisted Docker operations.

**Acceptance Criteria**:
- [ ] Document Gordon availability (Docker Desktop 4.53+ beta)
- [ ] Document how to enable Gordon in Docker Desktop settings
- [ ] Provide example commands for image building and troubleshooting
- [ ] Show parallel examples: Gordon vs standard docker commands
- [ ] Document regional availability and limitations
- [ ] Mark as optional enhancement
- [ ] Note fallback to standard Docker commands

**Test Cases**:
1. **Enable Test**: Gordon enabled in Docker Desktop
2. **Usage Test**: Example Gordon commands work
3. **Fallback Test**: All operations work without Gordon

---

## P2: Medium Priority - Documentation

### Task 6.1: Create Phase IV README

**Priority**: P2 (Medium)
**Estimated Effort**: 3 hours
**Dependencies**: All implementation tasks
**Files to Update**:
- `phase-4-local-deployment/README.md` (already exists, enhance)

**Description**:
Enhance Phase IV README with comprehensive setup, deployment, and troubleshooting instructions.

**Acceptance Criteria**:
- [ ] Overview section explains Phase IV goals
- [ ] Prerequisites listed with version requirements
- [ ] Quick start guide (3-5 commands to deploy)
- [ ] Detailed deployment options (Docker Compose, kubectl, Helm)
- [ ] AI-assisted DevOps section with examples
- [ ] Architecture diagram (Mermaid or image)
- [ ] Troubleshooting section with common issues
- [ ] Cleanup instructions
- [ ] Links to next steps (Phase V)
- [ ] README is well-formatted and easy to follow

**Test Cases**:
1. **Clarity Test**: New user can follow README and deploy successfully
2. **Completeness Test**: All deployment methods documented
3. **Accuracy Test**: All commands tested and work as documented

---

### Task 6.2: Create Troubleshooting Guide

**Priority**: P2 (Medium)
**Estimated Effort**: 2 hours
**Dependencies**: All implementation tasks
**Files to Create/Modify**:
- `phase-4-local-deployment/docs/TROUBLESHOOTING.md`

**Description**:
Create comprehensive troubleshooting guide for common Phase IV issues.

**Acceptance Criteria**:
- [ ] Cover common issues: ImagePullBackOff, CrashLoopBackOff, Pending pods
- [ ] Include diagnostic commands for each issue
- [ ] Provide step-by-step resolution steps
- [ ] Cover Docker build failures
- [ ] Cover Minikube resource issues
- [ ] Cover secret configuration issues
- [ ] Cover networking issues
- [ ] Include debugging techniques (logs, exec, describe)
- [ ] Link to external resources where appropriate

**Test Cases**:
1. **Coverage Test**: Common issues from user testing are documented
2. **Resolution Test**: Following troubleshooting steps resolves issues
3. **Clarity Test**: Instructions are clear and actionable

---

### Task 6.3: Create Architecture Documentation

**Priority**: P2 (Medium)
**Estimated Effort**: 2 hours
**Dependencies**: All implementation tasks
**Files to Create/Modify**:
- `phase-4-local-deployment/docs/ARCHITECTURE.md`

**Description**:
Document Phase IV architecture with diagrams and explanations.

**Acceptance Criteria**:
- [ ] Overview of containerization architecture
- [ ] Kubernetes deployment topology diagram (Mermaid)
- [ ] Component descriptions (backend, frontend, database)
- [ ] Network flow diagram
- [ ] Persistence architecture explanation
- [ ] Resource allocation details
- [ ] Comparison with Phase III architecture
- [ ] Preparation for Phase V architecture

**Test Cases**:
1. **Completeness Test**: All components documented
2. **Clarity Test**: Diagrams are clear and accurate
3. **Accuracy Test**: Architecture matches actual implementation

---

## P2: Medium Priority - Testing and Validation

### Task 7.1: Create End-to-End Deployment Test

**Priority**: P2 (Medium)
**Estimated Effort**: 2 hours
**Dependencies**: All implementation tasks
**Files to Create/Modify**:
- `phase-4-local-deployment/tests/test_deployment.sh`

**Description**:
Create automated test script that validates complete deployment workflow.

**Acceptance Criteria**:
- [ ] Test script performs full deployment (Minikube setup → build → deploy)
- [ ] Test validates all resources created
- [ ] Test validates pod health
- [ ] Test validates service connectivity
- [ ] Test validates frontend UI loads
- [ ] Test validates backend API responds
- [ ] Test validates data persistence
- [ ] Test performs cleanup
- [ ] Test outputs pass/fail status
- [ ] Test is executable: `chmod +x tests/test_deployment.sh`

**Test Cases**:
1. **Full Test**: Complete deployment test passes on clean system
2. **Failure Detection**: Test fails if deployment has issues
3. **Cleanup Test**: Test cleanup removes all resources

---

### Task 7.2: Create Application Functionality Test

**Priority**: P2 (Medium)
**Estimated Effort**: 2 hours
**Dependencies**: Task 7.1
**Files to Create/Modify**:
- `phase-4-local-deployment/tests/test_functionality.sh`

**Description**:
Create test script that validates Phase III functionality works in Phase IV deployment.

**Acceptance Criteria**:
- [ ] Test creates a task via API
- [ ] Test retrieves tasks via API
- [ ] Test updates a task via API
- [ ] Test deletes a task via API
- [ ] Test verifies chatbot endpoint responds
- [ ] Test verifies task persists after pod restart
- [ ] Test outputs pass/fail status
- [ ] Test is executable: `chmod +x tests/test_functionality.sh`

**Test Cases**:
1. **CRUD Test**: All CRUD operations work correctly
2. **Persistence Test**: Data persists across pod restarts
3. **Chatbot Test**: Chatbot functionality works

---

## Summary

**Total Tasks**: 28
- **P0 (Critical)**: 3 tasks - Containerization
- **P1 (High)**: 13 tasks - Kubernetes manifests, Helm charts
- **P2 (Medium)**: 9 tasks - Automation, documentation, testing
- **P3 (Low)**: 3 tasks - Optional AI tools

**Estimated Total Effort**: 40-50 hours

**Critical Path**:
1. Docker images (Task 1.1, 1.2, 1.3)
2. Kubernetes base resources (Task 2.1-2.4)
3. Deployments and services (Task 2.5-2.8)
4. Helm charts (Task 3.1-3.3)
5. Deployment scripts (Task 4.1-4.6)
6. Documentation (Task 6.1-6.3)
7. Testing (Task 7.1-7.2)

**Recommended Implementation Order**:
1. **Week 1**: Containerization (Tasks 1.1-1.3)
2. **Week 2**: Kubernetes manifests (Tasks 2.1-2.8)
3. **Week 3**: Helm charts and automation (Tasks 3.1-3.3, 4.1-4.6)
4. **Week 4**: Documentation and testing (Tasks 6.1-6.3, 7.1-7.2)
5. **Optional**: AI tools documentation (Tasks 5.1-5.3)

**Success Criteria**:
All P0 and P1 tasks must be completed. P2 tasks are important but can be prioritized based on time. P3 tasks are optional enhancements.

---

**Document Status**: Ready for Implementation
**Next Steps**:
1. User approval of task breakdown
2. Begin implementation with Task 1.1 (Backend Dockerfile)
3. Create ADRs for key architectural decisions
4. Track progress and update task status
