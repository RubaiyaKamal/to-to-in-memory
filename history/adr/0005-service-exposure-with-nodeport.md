# ADR-0005: Service Exposure with NodePort

> **Scope**: Document decision clusters, not individual technology choices. Group related decisions that work together (e.g., "Frontend Stack" not separate ADRs for framework, styling, deployment).

- **Status:** Accepted
- **Date:** 2025-12-30
- **Feature:** 003-local-k8s-deployment
- **Context:** Phase IV needs external access to frontend UI and internal access to backend API in local Minikube cluster. Must balance simplicity, no additional infrastructure requirements, learning value, and preparation for Phase V Ingress deployment.

<!-- Significance checklist (ALL must be true to justify this ADR)
     1) Impact: Long-term consequence for architecture/platform/security? MODERATE - Affects local access patterns
     2) Alternatives: Multiple viable options considered with tradeoffs? YES - NodePort, LoadBalancer, Ingress, port-forward
     3) Scope: Cross-cutting concern (not an isolated detail)? YES - Affects service accessibility, networking strategy
-->

## Decision

**Adopt NodePort for frontend exposure, port-forward for backend access:**

- **Frontend Service**: NodePort type exposing port 80 on NodePort 30080
- **Frontend Access**: `http://localhost:30080` or `minikube service todo-chatbot-frontend`
- **Backend Service**: ClusterIP type (internal only)
- **Backend Access**: `kubectl port-forward svc/todo-chatbot-backend 8001:8001` for development/debugging
- **No Ingress**: Defer ingress controller setup to Phase V
- **No LoadBalancer**: Avoid MetalLB complexity for local development

## Consequences

### Positive

- **Works immediately**: NodePort supported out-of-box in Minikube, no additional setup
- **Simple configuration**: Minimal YAML, no ingress rules or TLS certificates
- **Predictable access**: Fixed port (30080) for easy documentation
- **Learning value**: Teaches K8s service types (ClusterIP vs NodePort)
- **No additional tools**: No ingress controller, load balancer, or DNS to install
- **Backend security**: ClusterIP keeps backend internal, accessed only via port-forward
- **Minikube helper**: `minikube service` command makes URL discovery easy
- **Low overhead**: No additional pods or resources needed

### Negative

- **Non-standard ports**: Port 30080 instead of 80/443, slightly awkward
- **Not production-like**: Phase V will use Ingress with proper HTTP routing
- **No HTTP routing**: Can't route based on paths or hosts
- **No TLS**: Plain HTTP only (acceptable for local development)
- **Port conflicts**: NodePort range (30000-32767) could conflict with other local services
- **Manual backend access**: Requires kubectl port-forward command for API access
- **Limited scalability**: Doesn't demonstrate load balancing across replicas (works but less visible)

## Alternatives Considered

### Alternative A: LoadBalancer Service
**Approach**: Use LoadBalancer service type for external access

**Why Rejected**:
- Requires MetalLB installation in Minikube (additional complexity)
- MetalLB setup adds multiple configuration steps
- Overkill for local single-machine development
- Adds resource overhead (MetalLB controller pods)
- Doesn't significantly improve learning experience vs NodePort
- LoadBalancer concepts better taught in Phase V cloud deployment

### Alternative B: Ingress Controller (nginx-ingress or Traefik)
**Approach**: Deploy ingress controller with ingress rules for HTTP routing

**Why Rejected**:
- Requires ingress controller installation (nginx, Traefik, etc.)
- Additional resource usage (~128MB RAM for ingress controller)
- Ingress rules add configuration complexity (paths, hosts, backends)
- Would need to set up local DNS or /etc/hosts entries
- TLS certificate generation adds complexity (even with self-signed)
- Too much additional learning for Phase IV goals
- **Better suited for Phase V** where Ingress is production-appropriate

### Alternative C: Port-Forward Only
**Approach**: Use `kubectl port-forward` for both frontend and backend

**Why Rejected**:
- Manual command required every time (not persistent)
- Requires terminal window to stay open
- Doesn't teach K8s service concepts
- Less production-like than NodePort
- Interrupts workflow when terminal closes
- Better as supplementary tool, not primary access method

### Alternative D: Cluster IP Only
**Approach**: Use ClusterIP for all services, access via port-forward or ingress

**Why Rejected**:
- Requires either port-forward (manual) or ingress (complex)
- Doesn't provide simple, persistent external access
- Makes frontend access unnecessarily difficult
- Doesn't align with learning goals (understanding service types)

## References

- Feature Spec: `specs/003-local-k8s-deployment/spec.md`
- Implementation Plan: `specs/003-local-k8s-deployment/plan.md` (Decision 5, lines 218-249)
- Related ADRs: ADR-0002 (Minikube Platform), ADR-0003 (Helm Charts)
- Kubernetes Services: https://kubernetes.io/docs/concepts/services-networking/service/
- Evaluator Evidence: `history/prompts/003-local-k8s-deployment/0002-create-constitution-and-phase-iv-specs.plan.prompt.md`
