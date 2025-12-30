# ADR-0002: Local Kubernetes Platform Selection

> **Scope**: Document decision clusters, not individual technology choices. Group related decisions that work together (e.g., "Frontend Stack" not separate ADRs for framework, styling, deployment).

- **Status:** Accepted
- **Date:** 2025-12-30
- **Feature:** 003-local-k8s-deployment
- **Context:** Phase IV requires a local Kubernetes environment for learning cloud-native deployment patterns before Phase V production deployment. Need to balance feature completeness, resource usage, cross-platform compatibility, and learning curve.

<!-- Significance checklist (ALL must be true to justify this ADR)
     1) Impact: Long-term consequence for architecture/platform/security? YES - Establishes local dev environment for K8s learning
     2) Alternatives: Multiple viable options considered with tradeoffs? YES - Minikube, Kind, k3s, Docker Desktop K8s
     3) Scope: Cross-cutting concern (not an isolated detail)? YES - Affects all local development, testing, and learning workflows
-->

## Decision

**Adopt Minikube as the primary local Kubernetes platform:**

- **Platform**: Minikube 1.30+ for full-featured local Kubernetes cluster
- **Resource Allocation**: 4GB RAM, 2 CPUs minimum (configurable)
- **Cross-Platform**: Works on Windows, macOS, and Linux
- **UI**: Built-in dashboard for visual cluster inspection
- **Addons**: metrics-server and storage-provisioner enabled by default
- **Image Loading**: Direct image loading without registry (`minikube image load`)

## Consequences

### Positive

- **Feature-complete Kubernetes**: Supports all K8s features needed for learning and Phase IV requirements
- **Excellent documentation**: Most comprehensive guides and tutorials available
- **Built-in dashboard**: Web UI for visual cluster inspection and troubleshooting
- **Widely adopted**: Industry-standard choice for local K8s development and tutorials
- **Cross-platform support**: Consistent experience across Windows (WSL2/Hyper-V), macOS, and Linux
- **Active community**: Large user base means better Stack Overflow support and troubleshooting resources
- **Good balance**: Features vs resource usage is optimal for learning environment
- **Image management**: Simple image loading without needing local registry

### Negative

- **Higher resource usage**: Requires more RAM/CPU than Kind or k3s (~4GB RAM vs 2GB)
- **Startup time**: Slower cluster startup compared to Kind (30-60s vs 10-20s)
- **VM overhead**: Uses virtualization layer (Hyper-V, VirtualBox, Docker) adding complexity
- **Not CI-friendly**: Heavier weight makes it less suitable for CI/CD pipelines (though Phase IV is local dev only)
- **Multiple drivers**: Different drivers for different platforms can cause confusion

## Alternatives Considered

### Alternative A: Kind (Kubernetes in Docker)
**Approach**: Lightweight K8s cluster running as Docker containers

**Why Rejected**:
- Less feature-complete (some K8s features not fully supported)
- No built-in dashboard UI (CLI-only, less beginner-friendly)
- Primarily designed for CI/CD, not interactive learning
- Image loading requires building/pushing to local registry (more complex)
- Less comprehensive documentation for learning purposes
- Good for CI, not optimal for Phase IV's learning-focused goals

### Alternative B: k3s (Lightweight Kubernetes)
**Approach**: Lightweight K8s distribution optimized for resource-constrained environments

**Why Rejected**:
- Additional installation beyond Docker (one more tool to manage)
- Less familiar to developers learning Kubernetes
- Some K8s features simplified/removed for size reduction
- Smaller community and fewer learning resources
- Documentation less comprehensive for beginners
- Better for edge/IoT deployments, not ideal for local learning

### Alternative C: Docker Desktop Kubernetes
**Approach**: Built-in Kubernetes cluster in Docker Desktop

**Why Rejected**:
- Mac and Windows only (excludes Linux users)
- Limited configuration options
- Less control over cluster setup and resources
- No dashboard included by default
- Less portable knowledge (Docker Desktop-specific vs standard Minikube)
- May conflict with Minikube if both installed

### Alternative D: MicroK8s (Canonical's Lightweight K8s)
**Approach**: Lightweight K8s from Canonical, optimized for Ubuntu/Linux

**Why Rejected**:
- Primarily Linux-focused (limited Windows/Mac support)
- Snap package dependency adds platform-specific complexity
- Less adoption in learning/tutorial ecosystem
- Configuration differs from standard K8s tooling

## References

- Feature Spec: `specs/003-local-k8s-deployment/spec.md`
- Implementation Plan: `specs/003-local-k8s-deployment/plan.md` (Decision 2, lines 118-149)
- Related ADRs: ADR-0001 (Containerization), ADR-0003 (Package Management)
- Minikube Documentation: https://minikube.sigs.k8s.io/docs/
- Evaluator Evidence: `history/prompts/003-local-k8s-deployment/0002-create-constitution-and-phase-iv-specs.plan.prompt.md`
