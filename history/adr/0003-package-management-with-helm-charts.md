# ADR-0003: Package Management with Helm Charts

> **Scope**: Document decision clusters, not individual technology choices. Group related decisions that work together (e.g., "Frontend Stack" not separate ADRs for framework, styling, deployment).

- **Status:** Accepted
- **Date:** 2025-12-30
- **Feature:** 003-local-k8s-deployment
- **Context:** Phase IV requires templated, version-controlled Kubernetes deployment configurations that can be easily customized for different environments and support rollback capabilities. Need to balance templating power, learning curve, and preparation for Phase V production deployments.

<!-- Significance checklist (ALL must be true to justify this ADR)
     1) Impact: Long-term consequence for architecture/platform/security? YES - Establishes deployment workflow and configuration management
     2) Alternatives: Multiple viable options considered with tradeoffs? YES - Raw YAML, Helm, Kustomize, Helm+Kustomize
     3) Scope: Cross-cutting concern (not an isolated detail)? YES - Affects all deployments, updates, and configuration management
-->

## Decision

**Adopt Helm Charts as primary package management solution, with Kustomize as documented alternative:**

- **Primary**: Helm 3.10+ for templated Kubernetes deployments
- **Chart Structure**: Custom chart in `helm/todo-chatbot/` with templates, values, helpers
- **Versioning**: Chart versioning aligned with application semantic versioning
- **Release Management**: `helm install/upgrade/rollback` for deployment lifecycle
- **Configuration**: Environment-specific values files (values-local.yaml, values-prod.yaml in Phase V)
- **Alternative**: Kustomize overlays for users who prefer declarative configuration
- **Documentation**: Both approaches documented for learning purposes

## Consequences

### Positive

- **Industry standard**: Helm is the de facto package manager for Kubernetes
- **Powerful templating**: Go templates allow complex conditional logic and parameterization
- **Versioning and rollback**: Chart versions enable easy rollback to previous configurations
- **Release management**: Simplifies install/upgrade/uninstall lifecycle
- **Reusable**: Charts can be packaged and shared (preparation for Phase V)
- **Values separation**: Configuration separated from manifests enables environment customization
- **Dependency management**: Can manage chart dependencies (useful for Phase V)
- **Phase V preparation**: Helm skills transfer directly to production deployments

### Negative

- **Learning curve**: Go template syntax and Helm concepts (charts, releases, values) require learning
- **Template complexity**: Complex templates can become hard to read and debug
- **Another tool**: Adds Helm to the tool stack (Docker, kubectl, Minikube, now Helm)
- **Over-engineering for Phase IV**: Raw YAML would be simpler for local development
- **Debugging difficulty**: Template errors can be cryptic, `helm template` debugging needed
- **Values.yaml sprawl**: Large values files can become unwieldy

## Alternatives Considered

### Alternative A: Raw Kubernetes YAML Manifests
**Approach**: Direct `kubectl apply -f` with plain YAML files

**Why Rejected**:
- No parameterization (must duplicate manifests for different configs)
- No versioning or rollback mechanism
- Hard to customize (replicas, resources, secrets) without editing files
- Doesn't prepare for Phase V production needs
- Configuration management becomes error-prone at scale

### Alternative B: Kustomize Only
**Approach**: Overlay-based configuration with kustomize patches

**Why Rejected (as sole solution)**:
- Less powerful templating than Helm (no conditionals, no loops)
- No built-in versioning or release management
- Harder to manage complex parameter customization
- Smaller ecosystem and community than Helm
- **BUT**: Included as documented alternative for those who prefer it

### Alternative C: Helm + Kustomize Combined
**Approach**: Use Helm for templating + Kustomize for overlays

**Why Rejected**:
- Too complex for Phase IV learning environment
- Overkill for local development needs
- Adds confusion about which tool to use when
- Deferred to Phase V if needed for multi-environment deployments

### Alternative D: Jsonnet or Dhall
**Approach**: Programmable configuration languages for K8s manifests

**Why Rejected**:
- Much smaller adoption and ecosystem than Helm
- Additional language to learn beyond Go templates
- Limited tooling and IDE support
- Not industry standard for K8s deployments

## References

- Feature Spec: `specs/003-local-k8s-deployment/spec.md`
- Implementation Plan: `specs/003-local-k8s-deployment/plan.md` (Decision 3, lines 151-182)
- Related ADRs: ADR-0002 (Minikube Platform), ADR-0006 (Deployment Automation)
- Helm Documentation: https://helm.sh/docs/
- Evaluator Evidence: `history/prompts/003-local-k8s-deployment/0002-create-constitution-and-phase-iv-specs.plan.prompt.md`
