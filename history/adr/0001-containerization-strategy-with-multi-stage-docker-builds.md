# ADR-0001: Containerization Strategy with Multi-Stage Docker Builds

> **Scope**: Document decision clusters, not individual technology choices. Group related decisions that work together (e.g., "Frontend Stack" not separate ADRs for framework, styling, deployment).

- **Status:** Accepted
- **Date:** 2025-12-30
- **Feature:** 003-local-k8s-deployment
- **Context:** Phase IV requires containerizing the Phase III Todo Chatbot (FastAPI backend + Next.js frontend) for deployment to local Kubernetes (Minikube). Need to balance image size, build complexity, security, and development workflow efficiency.

<!-- Significance checklist (ALL must be true to justify this ADR)
     1) Impact: Long-term consequence for architecture/platform/security? YES - Sets pattern for all future containerization
     2) Alternatives: Multiple viable options considered with tradeoffs? YES - Single-stage, multi-stage, pre-built bases
     3) Scope: Cross-cutting concern (not an isolated detail)? YES - Affects all container builds, deployment size, security posture
-->

## Decision

**Adopt multi-stage Docker builds for both backend and frontend applications:**

- **Backend Strategy**:
  - Builder stage: `python:3.13` with full build dependencies
  - Runtime stage: `python:3.13-slim` with only runtime dependencies
  - Target size: ~200MB (vs ~800MB single-stage)

- **Frontend Strategy**:
  - Builder stage: `node:20` or `node:20-alpine` for npm build
  - Runtime stage: `nginx:alpine` serving static assets
  - Target size: ~50MB (vs ~1GB single-stage)

- **Security Hardening**:
  - Runtime images exclude build tools and dev dependencies
  - Non-root user execution (UID 1000)
  - Minimal attack surface with slim/alpine base images

- **Development Workflow**:
  - Docker layer caching for fast rebuilds after initial build
  - No external container registry dependency (local images only)

## Consequences

### Positive

- **60-80% image size reduction**: Backend from ~800MB to ~200MB, frontend from ~1GB to ~50MB
- **Enhanced security**: Runtime containers don't include compilers, build tools, or dev dependencies
- **Faster deployments**: Smaller images load faster in Minikube and transfer faster if pushed to registry later
- **Industry best practice**: Multi-stage builds are Docker's recommended approach for production
- **Layer caching efficiency**: Dependency layers cached separately from application code
- **No registry overhead**: Local development doesn't require maintaining custom base images

### Negative

- **More complex Dockerfiles**: Requires understanding multi-stage syntax and COPY --from directives
- **Longer initial builds**: First build takes 5+ minutes per image (cached rebuilds <1 min)
- **Debugging complexity**: Need to understand which stage failures occur in
- **Build tool duplication**: Some tools needed in both stages (e.g., version managers)
- **Learning curve**: Developers unfamiliar with multi-stage builds need ramp-up time

## Alternatives Considered

### Alternative A: Single-Stage Builds
**Approach**: One Dockerfile stage with all build and runtime dependencies

**Why Rejected**:
- Image sizes 3-4x larger (800MB backend, 1GB frontend)
- Includes unnecessary build tools in production containers (security risk)
- Wastes disk space and memory in Minikube (limited local resources)
- Goes against Docker best practices for production deployments

### Alternative B: Pre-Built Custom Base Images
**Approach**: Create custom base images with common dependencies, push to registry, use as FROM

**Why Rejected**:
- Requires container registry setup and maintenance (out of scope for Phase IV)
- Adds complexity for local development workflow
- Base image versioning and updates become additional overhead
- Doesn't significantly improve build time vs layer caching
- Overkill for a learning-focused Phase IV deployment

### Alternative C: Buildpacks (Cloud Native Buildpacks)
**Approach**: Use `pack build` to auto-generate optimized images without Dockerfiles

**Why Rejected**:
- Hides the containerization process (reduces learning value)
- Less control over image contents and layers
- Additional tool to install and learn (pack CLI)
- Not as widely adopted as standard Docker multi-stage builds
- Doesn't align with Phase IV goal of learning container fundamentals

## References

- Feature Spec: `specs/003-local-k8s-deployment/spec.md`
- Implementation Plan: `specs/003-local-k8s-deployment/plan.md` (Decision 1, lines 88-117)
- Related ADRs: ADR-0002 (Minikube Platform), ADR-0004 (Database Persistence)
- Docker Best Practices: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#use-multi-stage-builds
- Evaluator Evidence: `history/prompts/003-local-k8s-deployment/0002-create-constitution-and-phase-iv-specs.plan.prompt.md`
