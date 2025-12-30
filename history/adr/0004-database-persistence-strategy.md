# ADR-0004: Database Persistence Strategy

> **Scope**: Document decision clusters, not individual technology choices. Group related decisions that work together (e.g., "Frontend Stack" not separate ADRs for framework, styling, deployment).

- **Status:** Accepted
- **Date:** 2025-12-30
- **Feature:** 003-local-k8s-deployment
- **Context:** Phase IV needs database persistence for Phase III chatbot data (users, tasks, conversations) in Kubernetes. Must balance simplicity for local development, resource usage, persistence across pod restarts, and preparation for Phase V production PostgreSQL deployment.

<!-- Significance checklist (ALL must be true to justify this ADR)
     1) Impact: Long-term consequence for architecture/platform/security? YES - Affects data persistence, migration path to Phase V
     2) Alternatives: Multiple viable options considered with tradeoffs? YES - External PG, PG in K8s, SQLite, StatefulSet
     3) Scope: Cross-cutting concern (not an isolated detail)? YES - Affects database architecture, PVC strategy, backend deployment
-->

## Decision

**Adopt SQLite with Persistent Volume Claim (PVC) as primary persistence, with external PostgreSQL as alternative:**

- **Database**: SQLite embedded database
- **Location**: SQLite file stored at `/app/data/todo.db` in backend container
- **Persistence**: Kubernetes PVC (1Gi, ReadWriteOnce) mounted to `/app/data`
- **Storage Class**: `standard` (Minikube default, uses hostPath)
- **Backend**: Single backend deployment with SQLite file on PVC
- **Alternative**: External PostgreSQL (Phase III Neon database) for users who prefer it
- **Phase V Migration**: Documented migration path to PostgreSQL StatefulSet in production

##Consequences

### Positive

- **Simplicity**: No separate database pod to manage, reduces complexity
- **Resource efficient**: No database pod means less RAM/CPU usage in Minikube
- **Persistence**: PVC ensures data survives pod restarts and redeployments
- **Fast local development**: SQLite is fast for single-user local testing
- **No network overhead**: Embedded database eliminates network latency
- **Easy backup**: Single file can be easily copied/backed up
- **Learning focus**: Focuses on containerization and K8s concepts, not database administration
- **PVC concepts**: Teaches persistent storage patterns applicable to Phase V

### Negative

- **Not production-like**: Phase V will use PostgreSQL, different from local setup
- **Limited concurrency**: SQLite doesn't handle multiple simultaneous writers well
- **No horizontal scaling**: Can't scale backend to multiple pods with RW SQLite file
- **Migration complexity**: Data migration required when moving to Phase V PostgreSQL
- **Single point of failure**: If PVC corrupts, all data lost (no replication)
- **File locking**: SQLite file locking can cause issues with pod restarts
- **Not client-server**: Can't connect external tools for DB inspection

## Alternatives Considered

### Alternative A: External PostgreSQL (Phase III Neon Database)
**Approach**: Connect K8s backend pods to external Neon serverless PostgreSQL

**Why Rejected (as primary)**:
- Not cloud-native (depends on external SaaS service)
- Doesn't teach Kubernetes persistence concepts
- Misses opportunity to learn PVCs and storage classes
- Internet dependency for local development
- **BUT**: Included as documented alternative for seamless Phase III→IV transition

### Alternative B: PostgreSQL in Kubernetes with PVC
**Approach**: Deploy PostgreSQL as a pod with PVC for data directory

**Why Rejected**:
- Requires separate PostgreSQL pod (adds resource usage: ~256MB RAM)
- More complex setup (initdb, pg_hba.conf, connection strings)
- Database administration overhead (backups, monitoring, tuning)
- Overkill for local single-user development
- Phase IV focus is containerization/K8s, not database management
- Phase V will introduce proper PostgreSQL setup

### Alternative C: PostgreSQL StatefulSet
**Approach**: Production-like PostgreSQL deployment with StatefulSet

**Why Rejected**:
- Too complex for Phase IV learning goals
- StatefulSets add significant conceptual overhead
- Requires understanding of ordered deployment, persistent pod identity
- Deferred to Phase V where StatefulSets are appropriate
- Would distract from Phase IV core goals (containerization, basic K8s)

### Alternative D: In-Memory Database (No Persistence)
**Approach**: No PVC, data lost on pod restart

**Why Rejected**:
- Data loss on every pod restart unacceptable
- Doesn't teach Kubernetes persistence concepts
- Poor user experience for local development
- Doesn't align with Phase III behavior (persistent data)

## References

- Feature Spec: `specs/003-local-k8s-deployment/spec.md`
- Implementation Plan: `specs/003-local-k8s-deployment/plan.md` (Decision 4, lines 184-216)
- Related ADRs: ADR-0001 (Containerization), ADR-0002 (Minikube Platform)
- Kubernetes Persistent Volumes: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- Evaluator Evidence: `history/prompts/003-local-k8s-deployment/0002-create-constitution-and-phase-iv-specs.plan.prompt.md`
