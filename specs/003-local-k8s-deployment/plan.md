# Implementation Plan: Local Kubernetes Deployment for Todo Chatbot

**Feature Branch**: `003-local-k8s-deployment`
**Created**: 2025-12-30
**Status**: Planning
**Dependencies**: Phase III Todo Chatbot (complete)

## 1. Scope and Dependencies

### In Scope

**Containerization:**
- Dockerize Phase III backend (FastAPI application)
- Dockerize Phase III frontend (Next.js application)
- Multi-stage Docker builds for optimized image sizes
- Health check endpoints for container liveness and readiness
- Environment-based configuration via environment variables

**Kubernetes Orchestration:**
- Minikube-based local Kubernetes cluster setup
- Kubernetes deployments for frontend and backend services
- Service definitions for inter-pod communication
- ConfigMaps for application configuration
- Secrets management for sensitive data (API keys, database URLs)
- Persistent Volume Claims (PVC) for database persistence
- Liveness and readiness probes for pod health monitoring
- Horizontal pod scaling configuration

**Package Management:**
- Helm chart creation for templated deployments
- Values files for environment-specific configuration
- Helm release management (install, upgrade, rollback)
- Kustomize support for overlay-based configuration

**AI-Assisted DevOps (Optional Enhancements):**
- kubectl-ai integration for natural language K8s operations
- Kagent setup for cluster analysis and optimization
- Docker AI (Gordon) integration for intelligent Docker operations
- Documentation for using AI tools as productivity enhancers

**Deployment Automation:**
- Shell scripts for automated setup and deployment
- Verification scripts for health checking
- Cleanup scripts for resource teardown
- Documentation with step-by-step instructions

### Out of Scope

- Production cloud deployment (Phase V)
- CI/CD pipeline automation (Phase V)
- Multi-cluster or multi-region deployments
- Service mesh (Istio, Linkerd) integration
- Advanced observability (Prometheus, Grafana) - beyond basic logging
- TLS certificate management
- External load balancers (using NodePort/port-forward instead)
- Container registry hosting (using local images)
- Database clustering or high availability
- Backup and disaster recovery procedures
- Security scanning and vulnerability management
- Performance benchmarking and load testing

### External Dependencies

**Required Tools:**
- Docker Desktop 4.0+ (container runtime)
- Minikube 1.30+ (local Kubernetes cluster)
- kubectl 1.25+ (Kubernetes CLI)
- Helm 3.10+ (package manager)

**Optional AI Tools:**
- Docker Desktop 4.53+ with Gordon (Docker AI)
- kubectl-ai (npm package or binary)
- Kagent (GitHub installation)

**Application Dependencies:**
- Phase III chatbot application (backend + frontend)
- PostgreSQL database (can run in-cluster or external)
- OpenAI API access for chatbot functionality

**System Resources:**
- Minimum 8GB RAM (12GB recommended)
- 4 CPU cores minimum
- 20GB free disk space
- Modern OS (Windows 10/11, macOS 10.14+, Linux)

## 2. Key Decisions and Rationale

### Decision 1: Docker Multi-Stage Builds

**Options Considered:**
1. **Single-stage builds** - Simple Dockerfile with all build and runtime dependencies
2. **Multi-stage builds** - Separate build and runtime stages for smaller images
3. **Pre-built base images** - Custom base images with dependencies pre-installed

**Trade-offs:**

| Option | Pros | Cons |
|--------|------|------|
| Single-stage | Simple, fast to write | Large image size, includes build tools in runtime |
| Multi-stage | Small runtime images, better security | More complex Dockerfile, longer initial build |
| Pre-built base | Fastest builds, consistent | Requires registry management, additional maintenance |

**Chosen: Multi-stage builds**

**Rationale:**
- Backend: Python build stage compiles dependencies, runtime stage uses slim Python image
- Frontend: Node build stage compiles React/Vite, runtime stage uses Nginx Alpine
- Image size optimization: Backend ~200MB (vs ~800MB single-stage), Frontend ~50MB (vs ~1GB)
- Security: Runtime images don't include build tools, reducing attack surface
- No external registry needed for local development
- Build time acceptable for local development workflow

**Principles Applied:**
- Smallest viable change: Standard Docker best practices
- Security-first: Minimal runtime dependencies
- Measurable: Image size reduced by 60-80%

### Decision 2: Minikube over Kind or k3s

**Options Considered:**
1. **Minikube** - Full-featured local Kubernetes
2. **Kind (Kubernetes in Docker)** - Lightweight, Docker-based
3. **k3s** - Lightweight Kubernetes distribution
4. **Docker Desktop Kubernetes** - Built-in K8s in Docker Desktop

**Trade-offs:**

| Option | Pros | Cons |
|--------|------|------|
| Minikube | Feature-complete, well-documented, dashboard UI | Higher resource usage |
| Kind | Fast startup, CI-friendly | Less feature-complete, CLI-only |
| k3s | Lightweight, production-like | Additional installation, less familiar |
| Docker Desktop K8s | Pre-installed with Docker | Limited configuration, Mac/Win only |

**Chosen: Minikube**

**Rationale:**
- Most comprehensive documentation and community support
- Built-in dashboard for visual cluster inspection
- Supports all Kubernetes features needed for learning
- Widely used in development and tutorials
- Works across Windows, macOS, and Linux
- Good balance between features and simplicity
- Users likely already familiar with Minikube from tutorials

**Principles Applied:**
- Reversible: Can switch to Kind or k3s if needed
- Smallest viable change: Industry-standard choice for local K8s
- Developer experience: Dashboard and docs improve learning curve

### Decision 3: Helm Charts for Package Management

**Options Considered:**
1. **Raw Kubernetes YAML manifests** - Direct kubectl apply
2. **Helm charts** - Templated package management
3. **Kustomize** - Overlay-based configuration management
4. **Helm + Kustomize** - Combined approach

**Trade-offs:**

| Option | Pros | Cons |
|--------|------|------|
| Raw YAML | Simple, direct, no tools | Duplication, no templating, hard to customize |
| Helm | Templating, versioning, rollback | Learning curve, complex syntax |
| Kustomize | Simpler than Helm, built into kubectl | Less powerful templating, no versioning |
| Helm + Kustomize | Best of both | Complex, overkill for Phase IV |

**Chosen: Helm Charts (Primary) + Kustomize (Alternative)**

**Rationale:**
- Helm is industry standard for Kubernetes package management
- Templating allows easy customization (replicas, resources, secrets)
- Versioning and rollback capabilities for experimentation
- Release management simplifies deployment lifecycle
- Prepare users for Phase V production deployments
- Provide Kustomize as alternative for users who prefer it
- Both approaches documented for learning purposes

**Principles Applied:**
- Reversible: Can use raw YAML or Kustomize if Helm proves complex
- Future-focused: Helm skills transfer to Phase V production
- Smallest viable change: Standard tool, well-documented

### Decision 4: Persistent Volumes for Database Storage

**Options Considered:**
1. **External PostgreSQL** - Connect to Phase III Neon database
2. **PostgreSQL in Kubernetes with PVC** - Database as a pod with persistent storage
3. **SQLite with PVC** - Lightweight embedded database
4. **StatefulSet with PostgreSQL** - Production-like database deployment

**Trade-offs:**

| Option | Pros | Cons |
|--------|------|------|
| External PostgreSQL | No changes to Phase III, reliable | Not cloud-native, depends on external service |
| PostgreSQL in K8s | Fully cloud-native, self-contained | Requires PVC setup, not HA |
| SQLite with PVC | Simple, no separate DB pod | Not production-like, limited concurrency |
| StatefulSet | Production-like, proper ordering | Complex, overkill for local dev |

**Chosen: SQLite with PVC (Primary) + External PostgreSQL (Alternative)**

**Rationale:**
- SQLite with PVC is simplest for local development
- Single backend pod with SQLite file on persistent volume
- Reduces resource usage (no separate database pod)
- Persistence across pod restarts via PVC
- Alternative: External PostgreSQL for users who prefer it
- Phase V will introduce proper PostgreSQL StatefulSet
- Focuses learning on containerization and K8s basics, not database administration

**Principles Applied:**
- Smallest viable change: Simplest persistence mechanism
- Resource-conscious: Minimize local resource usage
- Reversible: Easy to switch to PostgreSQL if needed
- Future-focused: PVC concepts transfer to Phase V

### Decision 5: NodePort Services for Local Access

**Options Considered:**
1. **NodePort** - Expose services on node ports (30000-32767)
2. **LoadBalancer** - External load balancer (requires cloud or MetalLB)
3. **Ingress Controller** - HTTP routing with ingress rules
4. **Port-forwarding** - kubectl port-forward for ad-hoc access

**Trade-offs:**

| Option | Pros | Cons |
|--------|------|------|
| NodePort | Simple, works out-of-box with Minikube | Non-standard ports, not production-like |
| LoadBalancer | Production-like | Requires MetalLB setup, additional complexity |
| Ingress | HTTP routing, production-like | Requires ingress controller, domain setup |
| Port-forward | Quick testing, no config | Manual, not persistent, CLI-only |

**Chosen: NodePort (Primary) + Port-forward (Alternative)**

**Rationale:**
- NodePort works immediately with Minikube without additional setup
- Frontend: NodePort on 30080 for web UI access
- Backend: Port-forward for API access (keeps it internal)
- Simpler than Ingress for local development
- No need for DNS or domain configuration
- Phase V will introduce proper Ingress with TLS
- Minikube service command makes NodePort URLs easy to access

**Principles Applied:**
- Smallest viable change: Minimal configuration for local access
- Learning-focused: Users understand K8s service types
- Reversible: Can add Ingress later if needed

### Decision 6: AI-Assisted Tools as Optional Enhancements

**Options Considered:**
1. **Mandatory AI tools** - Require kubectl-ai, Kagent, Gordon
2. **Optional AI tools** - Document but don't require
3. **No AI tools** - Only standard CLI commands

**Trade-offs:**

| Option | Pros | Cons |
|--------|------|------|
| Mandatory | Showcases AI capabilities, modern workflow | Not available in all regions, installation issues |
| Optional | Flexible, works for all users | Some users may not try AI features |
| No AI tools | Universal compatibility | Misses learning opportunity |

**Chosen: Optional AI Tools with Standard CLI Fallbacks**

**Rationale:**
- Gordon (Docker AI) only available in Docker Desktop 4.53+ beta
- Regional availability varies for AI features
- Not all users have access or want AI tools
- All functionality must work with standard commands
- Document AI tools as productivity enhancements
- Show parallel examples: AI command vs standard command
- Encourages exploration without creating blockers

**Principles Applied:**
- Inclusive: Works for all users regardless of AI tool access
- Educational: Shows both traditional and AI-assisted workflows
- Optional complexity: Users choose their comfort level

### Decision 7: Shell Scripts for Deployment Automation

**Options Considered:**
1. **Shell scripts (bash)** - Unix shell scripts for automation
2. **Makefile** - Make targets for common tasks
3. **Task runner (npm scripts, Justfile)** - Modern task runners
4. **Python scripts** - Cross-platform Python automation
5. **Manual commands** - No automation, just documentation

**Trade-offs:**

| Option | Pros | Cons |
|--------|------|------|
| Shell scripts | Standard, powerful, no dependencies | Windows compatibility issues |
| Makefile | Familiar to developers, dependency handling | Not intuitive for non-C devs |
| Task runner | Modern, declarative | Additional tool to install |
| Python | Cross-platform, familiar | Python runtime required |
| Manual | No scripting complexity | Error-prone, time-consuming |

**Chosen: Shell Scripts (Bash) with Windows Git Bash Support**

**Rationale:**
- Most DevOps tools and K8s docs use bash scripts
- Users learning K8s need bash scripting exposure
- Git Bash provides Windows compatibility
- Scripts are self-documenting with clear commands
- No additional tools to install (beyond Docker, K8s)
- Can be converted to other formats later if needed
- Key scripts: setup-minikube.sh, build-images.sh, deploy-helm.sh, verify-deployment.sh, cleanup.sh

**Principles Applied:**
- Industry standard: Bash is lingua franca of DevOps
- Learning-focused: Exposes users to shell scripting
- Reversible: Can add Makefile or task runner later

## 3. Interfaces and API Contracts

### Container Image Interfaces

**Backend Image: `todo-chatbot-backend:latest`**

**Exposed Ports:**
- `8001`: FastAPI application HTTP server

**Environment Variables:**
- `DATABASE_URL` (required): SQLite file path or PostgreSQL connection string
- `OPENAI_API_KEY` (required): OpenAI API key for chatbot functionality
- `BETTER_AUTH_SECRET` (required): JWT signing secret
- `CORS_ORIGINS` (optional): Allowed CORS origins, default: `http://localhost:3000`
- `LOG_LEVEL` (optional): Logging level, default: `INFO`

**Health Endpoints:**
- `GET /health`: Liveness probe, returns `{"status": "ok"}` with 200 status
- `GET /api/health`: Readiness probe, checks database connection

**Data Volumes:**
- `/app/data`: Directory for SQLite database file
- Recommended mount: PVC for persistence

**Frontend Image: `todo-chatbot-frontend:latest`**

**Exposed Ports:**
- `80`: Nginx HTTP server

**Environment Variables (Build-time):**
- `VITE_API_URL`: Backend API URL, default: `http://localhost:8001`

**Health Endpoints:**
- `GET /health`: Returns `{"status": "ok"}` with 200 status

**Data Volumes:**
- None required (stateless)

### Kubernetes Service Interfaces

**Backend Service: `todo-chatbot-backend`**

**Service Type:** ClusterIP
**Namespace:** `todo-chatbot`
**Selector:** `app=todo-chatbot-backend`
**Ports:**
- Port: `8001` → TargetPort: `8001` (HTTP)

**Frontend Service: `todo-chatbot-frontend`**

**Service Type:** NodePort
**Namespace:** `todo-chatbot`
**Selector:** `app=todo-chatbot-frontend`
**Ports:**
- Port: `80` → TargetPort: `80` → NodePort: `30080` (HTTP)

**Access Method:** `http://localhost:30080` or `minikube service todo-chatbot-frontend -n todo-chatbot`

### Helm Chart Values Interface

**Chart Name:** `todo-chatbot`
**Values File:** `helm/todo-chatbot/values.yaml`

**Key Configuration Parameters:**

```yaml
# Backend configuration
backend:
  replicas: 2
  image:
    repository: todo-chatbot-backend
    tag: latest
    pullPolicy: IfNotPresent
  resources:
    requests:
      memory: "256Mi"
      cpu: "250m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  secret:
    OPENAI_API_KEY: ""  # Must be set by user
    BETTER_AUTH_SECRET: ""  # Must be set by user
  config:
    DATABASE_URL: "sqlite:////app/data/todo.db"
    LOG_LEVEL: "INFO"

# Frontend configuration
frontend:
  replicas: 2
  image:
    repository: todo-chatbot-frontend
    tag: latest
    pullPolicy: IfNotPresent
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"
  service:
    type: NodePort
    nodePort: 30080

# Persistence
persistence:
  enabled: true
  storageClass: standard
  size: 1Gi
```

### Error Handling

**Container Build Errors:**
- Exit code 1: Dockerfile syntax error or missing dependencies
- Exit code 2: Application build failure (npm/pip errors)
- Logs: Build output shows specific error

**Pod Startup Errors:**
- `ImagePullBackOff`: Image not found in Minikube
- `CrashLoopBackOff`: Application startup failure (check logs)
- `Pending`: Resource constraints or PVC not bound

**Service Access Errors:**
- `Connection refused`: Service not ready, check pod status
- `404 Not Found`: Incorrect service endpoint or routing
- `502 Bad Gateway`: Backend pod not healthy

**Helm Deployment Errors:**
- `release: not found`: Chart not installed
- `validation error`: Invalid values.yaml configuration
- `timeout`: Pods failed to become ready within timeout

## 4. Non-Functional Requirements (NFRs) and Budgets

### Performance

**Build Times:**
- Backend image build: < 5 minutes (initial), < 1 minute (cached)
- Frontend image build: < 5 minutes (initial), < 1 minute (cached)
- Helm deployment: < 2 minutes (pod startup + readiness)

**Resource Usage:**
- Minikube cluster: 4GB RAM, 2 CPUs (minimum)
- Backend pod: 256Mi request, 512Mi limit
- Frontend pod: 128Mi request, 256Mi limit
- Database PVC: 1Gi storage

**Application Performance:**
- Backend API latency: < 200ms (p95) for CRUD operations
- Frontend page load: < 2s (first load), < 500ms (cached)
- Health check response: < 50ms

### Reliability

**Pod Availability:**
- Backend: 2 replicas for high availability
- Frontend: 2 replicas for redundancy
- Max unavailable during rolling update: 1 pod

**Health Monitoring:**
- Liveness probe: Every 10s, 3 failures = restart
- Readiness probe: Every 5s, 3 failures = remove from service
- Startup grace period: 30s

**Data Persistence:**
- PVC retained across pod restarts
- Data survives Minikube restarts (using hostPath or standard storage class)

### Security

**Secrets Management:**
- OpenAI API key stored in Kubernetes Secret
- Better Auth secret stored in Kubernetes Secret
- Secrets not logged or exposed in pod describe

**Network Isolation:**
- Backend: ClusterIP (internal only)
- Frontend: NodePort (local access only)
- No external ingress in Phase IV

**Container Security:**
- Non-root user in containers
- Read-only root filesystem where possible
- No privileged containers
- Minimal base images (Alpine, Slim)

### Cost

**Local Development:**
- Zero cloud costs (all local)
- Hardware: Standard developer workstation
- No external services required (except OpenAI API usage)

**Time Budget:**
- Initial setup: 30-60 minutes (tool installation + cluster setup)
- Deployment: 5-10 minutes (build + deploy)
- Verification: 2-3 minutes (health checks)

## 5. Data Management and Migration

### Source of Truth

**Application Code:**
- Backend: `phase-3-chatbot/backend/`
- Frontend: `phase-3-chatbot/frontend/`

**Container Definitions:**
- Backend Dockerfile: `phase-4-local-deployment/docker/backend/Dockerfile`
- Frontend Dockerfile: `phase-4-local-deployment/docker/frontend/Dockerfile`

**Kubernetes Manifests:**
- Raw YAML: `phase-4-local-deployment/k8s/base/`
- Helm charts: `phase-4-local-deployment/helm/todo-chatbot/`

### Schema Evolution

**Database Schema:**
- No schema changes in Phase IV
- Uses Phase III schema (users, tasks, conversations)
- Database created automatically on first backend startup

**Configuration Schema:**
- Helm values.yaml is versioned alongside chart
- Breaking changes to values.yaml require chart version bump

### Migration and Rollback

**Data Migration:**
- Phase III → Phase IV: No data migration needed
- Database file can be copied to PVC if needed
- External PostgreSQL: Use existing Phase III database

**Helm Rollback:**
```bash
# List releases
helm list -n todo-chatbot

# Rollback to previous version
helm rollback todo-chatbot -n todo-chatbot

# Rollback to specific revision
helm rollback todo-chatbot 1 -n todo-chatbot
```

**Manual Rollback:**
```bash
# Delete current deployment
kubectl delete namespace todo-chatbot

# Redeploy previous version
git checkout <previous-commit>
./scripts/deploy-helm.sh
```

### Data Retention

**Development Data:**
- PVC data persists across pod restarts
- PVC deleted when namespace is deleted
- Backup not required for local development

**Logs:**
- Container logs: Retained while pod exists
- View with: `kubectl logs <pod-name> -n todo-chatbot`
- No log aggregation in Phase IV (Phase V)

## 6. Operational Readiness

### Observability

**Logging:**
- Backend: Structured JSON logs to stdout
- Frontend: Nginx access logs to stdout
- Kubernetes: Pod logs via `kubectl logs`
- Log level configurable via `LOG_LEVEL` env var

**Metrics:**
- Kubernetes metrics: CPU, memory, pod status
- View with: `kubectl top pods -n todo-chatbot`
- Minikube dashboard: Visual metrics

**Tracing:**
- Not implemented in Phase IV
- Phase V will add distributed tracing

### Alerting

**Not implemented in Phase IV (local development)**

Phase V will include:
- Prometheus alert rules
- Alertmanager notifications

### Runbooks

**Common Operations:**

**1. Deploy Application:**
```bash
# Setup cluster
./scripts/setup-minikube.sh

# Build images
./scripts/build-images.sh

# Deploy with Helm
./scripts/deploy-helm.sh

# Verify
./scripts/verify-deployment.sh
```

**2. Check Application Health:**
```bash
# Check pods
kubectl get pods -n todo-chatbot

# Check services
kubectl get svc -n todo-chatbot

# View logs
kubectl logs -f <pod-name> -n todo-chatbot

# Describe pod
kubectl describe pod <pod-name> -n todo-chatbot
```

**3. Update Configuration:**
```bash
# Edit values.yaml
vim helm/todo-chatbot/values.yaml

# Upgrade release
helm upgrade todo-chatbot helm/todo-chatbot -n todo-chatbot

# Verify
kubectl rollout status deployment/todo-chatbot-backend -n todo-chatbot
```

**4. Scale Services:**
```bash
# Scale backend
kubectl scale deployment todo-chatbot-backend --replicas=3 -n todo-chatbot

# Or update Helm values and upgrade
```

**5. Debug Issues:**
```bash
# Get events
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp'

# Exec into pod
kubectl exec -it <pod-name> -n todo-chatbot -- /bin/sh

# Port forward for debugging
kubectl port-forward -n todo-chatbot svc/todo-chatbot-backend 8001:8001
```

**6. Cleanup:**
```bash
# Delete release
helm uninstall todo-chatbot -n todo-chatbot

# Delete namespace
kubectl delete namespace todo-chatbot

# Stop Minikube
minikube stop
```

### Deployment and Rollback Strategies

**Deployment Strategy:**
- **Rolling Update** (default)
- Max unavailable: 1 pod
- Max surge: 1 pod
- Zero downtime for 2+ replicas

**Rollback Strategy:**
- Helm rollback: Instant rollback to previous release
- Kubernetes rollback: `kubectl rollout undo deployment/<name> -n todo-chatbot`
- Manual: Redeploy previous version from Git

**Feature Flags:**
- Not implemented in Phase IV
- Phase V will use Dapr for feature flags

## 7. Risk Analysis and Mitigation

### Risk 1: Insufficient Local Resources

**Risk:** Developer workstation doesn't have enough RAM/CPU for Minikube cluster

**Blast Radius:** Developer cannot run application, blocks all testing

**Probability:** Medium (older machines, many background apps)

**Impact:** High (blocks development)

**Mitigation:**
- Document minimum requirements clearly (8GB RAM, 4 CPUs)
- Provide resource optimization tips (reduce replicas to 1)
- Offer lightweight alternatives (Docker Compose without K8s)
- Script includes resource checks before setup

**Kill Switch:**
- User can run Phase III directly without containerization
- Docker Compose as simpler alternative to K8s

### Risk 2: Docker Image Build Failures

**Risk:** Image build fails due to missing dependencies or network issues

**Blast Radius:** Cannot create container images, blocks deployment

**Probability:** Medium (network issues, missing build tools)

**Impact:** Medium (can retry, doesn't break existing deployments)

**Mitigation:**
- Multi-stage builds with clear error messages
- Offline-friendly builds with dependency caching
- Document common build errors and solutions
- Test Dockerfiles across platforms (Windows, Mac, Linux)

**Kill Switch:**
- Pre-built images can be provided if needed
- Docker Compose alternative uses local directories instead of images

### Risk 3: AI Tools Unavailable or Not Working

**Risk:** kubectl-ai, Kagent, or Gordon not available in user's region or tier

**Blast Radius:** User cannot use AI-assisted features

**Probability:** High (regional restrictions, beta features)

**Impact:** Low (AI tools are optional enhancements)

**Mitigation:**
- Clearly document AI tools as optional
- Provide standard CLI alternatives for all operations
- Test all functionality without AI tools
- Show parallel examples (AI vs standard commands)

**Guardrails:**
- No core functionality depends on AI tools
- All scripts use standard commands, AI is documented separately

## 8. Evaluation and Validation

### Definition of Done

**For Phase IV Completion:**

- [ ] Docker images build successfully for backend and frontend
- [ ] Images are optimized (backend < 250MB, frontend < 100MB)
- [ ] Minikube cluster sets up and starts successfully
- [ ] Kubernetes manifests deploy without errors
- [ ] Helm charts deploy without errors
- [ ] All pods reach Running and Ready state
- [ ] Health checks pass for all services
- [ ] Frontend accessible via NodePort on localhost:30080
- [ ] Backend API accessible via port-forward
- [ ] Application functions identically to Phase III
- [ ] Database persists across pod restarts
- [ ] Horizontal scaling works (can scale to 3 replicas)
- [ ] Rolling updates complete without downtime
- [ ] Helm rollback works correctly
- [ ] Cleanup scripts remove all resources
- [ ] Documentation complete with step-by-step instructions
- [ ] Troubleshooting guide covers common issues
- [ ] AI tools documented as optional enhancements

**Testing Checklist:**

- [ ] Backend unit tests pass (`pytest` in backend)
- [ ] Frontend unit tests pass (`npm test` in frontend)
- [ ] E2E tests pass for critical flows
- [ ] Container health checks work
- [ ] Pod liveness probes trigger restart on failure
- [ ] Pod readiness probes remove unhealthy pods from service
- [ ] PVC retains data across pod restarts
- [ ] Service discovery works (frontend → backend)
- [ ] Secrets are not exposed in logs or pod describe
- [ ] Resource limits prevent OOM kills

### Output Validation

**Container Images:**
- Run `docker images | grep todo-chatbot` shows both images
- Run `docker inspect <image>` shows correct labels and config
- Run container locally: `docker run -p 8001:8001 todo-chatbot-backend:latest`

**Kubernetes Deployment:**
- Run `kubectl get all -n todo-chatbot` shows all resources
- Run `kubectl get pods -n todo-chatbot` shows all pods Running
- Run `kubectl get pvc -n todo-chatbot` shows PVC Bound
- Run `kubectl get secrets -n todo-chatbot` shows secrets exist

**Application Access:**
- Frontend: Open `http://localhost:30080` shows UI
- Backend: Port-forward and open `http://localhost:8001/docs` shows Swagger UI
- Health: `curl http://localhost:8001/health` returns 200

**Helm Release:**
- Run `helm list -n todo-chatbot` shows release installed
- Run `helm get values todo-chatbot -n todo-chatbot` shows configured values
- Run `helm status todo-chatbot -n todo-chatbot` shows deployed status

### Safety Requirements

**Before Deployment:**
- Verify all secrets are set in values.yaml or k8s/base/secrets.yaml
- Verify OPENAI_API_KEY is valid
- Verify sufficient disk space (20GB free)
- Verify Minikube can allocate requested resources

**During Deployment:**
- Monitor pod startup logs for errors
- Verify health checks pass before considering deployment complete
- Verify PVC binds successfully to storage

**After Deployment:**
- Verify application is functional (create task, view tasks, chatbot works)
- Verify data persists across pod restart
- Verify all Phase III features work

## 9. Architectural Decision Records (ADRs)

The following architectural decisions from this plan should be documented as ADRs:

### ADR-001: Multi-Stage Docker Builds
- **Context:** Need to containerize Phase III application
- **Decision:** Use multi-stage builds for size optimization
- **Consequences:** Smaller images, better security, more complex Dockerfiles

### ADR-002: Minikube for Local Kubernetes
- **Context:** Need local Kubernetes environment for Phase IV
- **Decision:** Use Minikube over Kind, k3s, or Docker Desktop K8s
- **Consequences:** Feature-complete, well-documented, higher resource usage

### ADR-003: Helm for Package Management
- **Context:** Need templated, versioned K8s deployments
- **Decision:** Use Helm as primary, Kustomize as alternative
- **Consequences:** Industry-standard tooling, learning curve, rollback support

### ADR-004: SQLite with PVC for Persistence
- **Context:** Need database persistence in Kubernetes
- **Decision:** Use SQLite with PVC instead of PostgreSQL StatefulSet
- **Consequences:** Simple, resource-efficient, not production-like

### ADR-005: AI Tools as Optional Enhancements
- **Context:** kubectl-ai, Kagent, Gordon have limited availability
- **Decision:** Document AI tools but don't require them
- **Consequences:** Inclusive, flexible, some users may not explore AI features

---

**Document Status:** Planning Complete
**Next Steps:**
1. Create tasks.md with implementation tasks
2. Begin implementation: Dockerfiles → K8s manifests → Helm charts → Scripts → Documentation
3. Test across platforms (Windows, Mac, Linux)
4. Create ADRs for key decisions

**Approvals Required:**
- [ ] Architecture review (multi-stage builds, Minikube, Helm)
- [ ] Security review (secrets management, container security)
- [ ] User approval to proceed with implementation
