# ADR-0006: Deployment Automation with Shell Scripts

> **Scope**: Document decision clusters, not individual technology choices. Group related decisions that work together (e.g., "Frontend Stack" not separate ADRs for framework, styling, deployment).

- **Status:** Accepted
- **Date:** 2025-12-30
- **Feature:** 003-local-k8s-deployment
- **Context:** Phase IV requires automation for repetitive tasks (Minikube setup, image building, deployment, verification, cleanup). Need to balance cross-platform compatibility, learning value, industry standards, and minimal additional dependencies.

<!-- Significance checklist (ALL must be true to justify this ADR)
     1) Impact: Long-term consequence for architecture/platform/security? YES - Establishes automation patterns for deployment
     2) Alternatives: Multiple viable options considered with tradeoffs? YES - Shell, Makefile, task runners, Python, manual
     3) Scope: Cross-cutting concern (not an isolated detail)? YES - Affects developer workflow, CI/CD foundation
-->

## Decision

**Adopt Bash shell scripts for deployment automation with Git Bash support for Windows:**

- **Language**: Bash shell scripting (#!/bin/bash)
- **Location**: `scripts/` directory with descriptive names
- **Key Scripts**:
  - `setup-minikube.sh` - Cluster initialization and configuration
  - `build-images.sh` - Docker image building and Minikube loading
  - `deploy-k8s.sh` - kubectl-based deployment
  - `deploy-helm.sh` - Helm-based deployment
  - `verify-deployment.sh` - Health checking and validation
  - `cleanup.sh` - Resource teardown and cleanup
- **Windows Compatibility**: Scripts tested with Git Bash (bundled with Git for Windows)
- **Error Handling**: Exit on error (`set -e`), clear error messages
- **Idempotency**: Scripts can be run multiple times safely
- **Documentation**: Comments explaining each step, usage examples in README

## Consequences

### Positive

- **Industry standard**: Bash is lingua franca of DevOps and Kubernetes ecosystem
- **Learning value**: Exposes users to shell scripting, essential DevOps skill
- **Self-documenting**: Scripts show exact commands needed, educational
- **No additional dependencies**: Bash available on all platforms (Git Bash on Windows)
- **Powerful**: Full access to pipes, conditionals, loops, functions
- **Ubiquitous in K8s**: Most K8s tutorials and docs use bash scripts
- **Version control friendly**: Scripts are text files, easy to diff and review
- **Executable documentation**: Scripts serve as runnable documentation

### Negative

- **Windows compatibility**: Requires Git Bash or WSL on Windows (not native PowerShell)
- **Cross-platform challenges**: Path differences, line endings (CRLF vs LF)
- **Syntax complexity**: Bash syntax can be cryptic for beginners
- **Error handling**: Bash error handling is verbose and easy to get wrong
- **No dependency management**: Can't easily check if tools are installed (must script manually)
- **Debugging difficulty**: Bash debugging is less intuitive than Python/JavaScript

## Alternatives Considered

### Alternative A: Makefile with Make Targets
**Approach**: Use Makefile with targets for common tasks

**Why Rejected**:
- Less intuitive for non-C developers
- Make syntax (tabs vs spaces) is error-prone
- Not as widely understood as bash in DevOps
- Dependency management helpful but not critical for Phase IV
- Less self-explanatory than bash scripts
- **BUT**: Can be added later if desired

### Alternative B: Task Runner (npm scripts or Justfile)
**Approach**: Use modern task runner like npm scripts or Just

**Why Rejected**:
- npm requires Node.js (additional dependency)
- Justfile/Just less widely adopted than bash
- Adds another tool to learn and install
- Doesn't align with Kubernetes ecosystem norms
- Less transferable knowledge to Phase V

### Alternative C: Python Scripts
**Approach**: Write automation in Python for cross-platform compatibility

**Why Rejected**:
- Python runtime required (additional dependency)
- More verbose than bash for simple command execution
- Less common in K8s documentation and tutorials
- Overkill for command orchestration
- Doesn't teach shell scripting (important DevOps skill)
- Better for complex logic, not command wrappers

### Alternative D: Manual Commands Only (No Automation)
**Approach**: Document commands in README, users run manually

**Why Rejected**:
- Error-prone (users miss steps, typos)
- Time-consuming and tedious
- Doesn't scale as workflow grows
- Misses learning opportunity for automation
- Poor developer experience
- Doesn't prepare for Phase V CI/CD

### Alternative E: PowerShell for Cross-Platform
**Approach**: Use PowerShell Core scripts (.ps1)

**Why Rejected**:
- Less common in Linux/K8s ecosystem
- Syntax very different from Unix shell
- Smaller community for K8s PowerShell scripts
- Not standard in DevOps tooling
- Doesn't align with learning goals (K8s ecosystem uses bash)

## References

- Feature Spec: `specs/003-local-k8s-deployment/spec.md`
- Implementation Plan: `specs/003-local-k8s-deployment/plan.md` (Decision 7, lines 282-315)
- Related ADRs: ADR-0002 (Minikube Platform), ADR-0003 (Helm Charts)
- Bash Best Practices: https://google.github.io/styleguide/shellguide.html
- Evaluator Evidence: `history/prompts/003-local-k8s-deployment/0002-create-constitution-and-phase-iv-specs.plan.prompt.md`
