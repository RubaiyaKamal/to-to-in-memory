# Backend Docker Build - Testing Guide

This directory contains the multi-stage Dockerfile for the Phase III Todo Chatbot backend (FastAPI application).

## Reference

- **ADR:** [ADR-0001: Containerization Strategy with Multi-Stage Docker Builds](../../../history/adr/0001-containerization-strategy-with-multi-stage-docker-builds.md)
- **Task:** Task 1.1 from `specs/003-local-k8s-deployment/tasks.md`
- **Target Image Size:** ~200MB (vs ~800MB single-stage)

## Prerequisites

1. **Docker Desktop must be running**
   - Install: https://www.docker.com/products/docker-desktop
   - Start Docker Desktop before running commands below

2. **Repository Context**
   - All commands must be run from the repository root: `C:\Users\Lap Zone\to-do-in-memory`
   - The Dockerfile copies from `phase-3-chatbot/backend/`

## Build Commands

### Standard Build

```bash
# From repository root
cd "C:\Users\Lap Zone\to-do-in-memory"

# Build the image
docker build \
  -f phase-4-local-deployment/docker/backend/Dockerfile \
  -t todo-chatbot-backend:latest \
  .
```

### Build with Progress Output

```bash
docker build \
  --progress=plain \
  -f phase-4-local-deployment/docker/backend/Dockerfile \
  -t todo-chatbot-backend:latest \
  .
```

## Test Cases (Task 1.1 Acceptance Criteria)

### 1. Build Test

**Requirement:** Image builds without errors in under 5 minutes

```bash
time docker build \
  -f phase-4-local-deployment/docker/backend/Dockerfile \
  -t todo-chatbot-backend:latest \
  .
```

**Expected:** Build completes successfully in < 5 minutes (first build)
**Expected:** Cached rebuild completes in < 1 minute

### 2. Size Test

**Requirement:** Final image size is under 250MB

```bash
docker images todo-chatbot-backend
```

**Expected Output:**
```
REPOSITORY              TAG       IMAGE ID       CREATED          SIZE
todo-chatbot-backend    latest    <image-id>     <time>          <200MB
```

**Pass Criteria:** SIZE column shows value < 250MB

### 3. Run Test

**Requirement:** Container starts and health endpoint responds 200 OK

```bash
# Run container with required environment variables
docker run -d \
  --name todo-backend-test \
  -p 8001:8001 \
  -e OPENAI_API_KEY=test-key-for-local-testing \
  -e DATABASE_URL=sqlite:////app/data/todo.db \
  -e BETTER_AUTH_SECRET=test-secret-minimum-32-characters-long \
  -e BETTER_AUTH_URL=http://localhost:8001 \
  todo-chatbot-backend:latest

# Wait for startup (40 seconds as per HEALTHCHECK start-period)
sleep 45

# Check container status
docker ps -a | grep todo-backend-test

# Test health endpoint
curl http://localhost:8001/api/health

# Check logs
docker logs todo-backend-test
```

**Expected:**
- Container status shows "Up" (not "Exited")
- Health endpoint returns 200 OK with JSON response
- Logs show "Uvicorn running on http://0.0.0.0:8001"

**Cleanup:**
```bash
docker stop todo-backend-test
docker rm todo-backend-test
```

### 4. Security Test

**Requirement:** Container runs as non-root user (UID 1000)

```bash
# Start container (if not already running from Test 3)
docker run -d \
  --name todo-backend-test \
  -p 8001:8001 \
  -e OPENAI_API_KEY=test \
  -e DATABASE_URL=sqlite:////app/data/todo.db \
  todo-chatbot-backend:latest

# Check user
docker exec todo-backend-test whoami

# Check UID
docker exec todo-backend-test id
```

**Expected Output:**
```
appuser
uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)
```

**Pass Criteria:** User is `appuser` with UID 1000 (not `root`)

**Cleanup:**
```bash
docker stop todo-backend-test
docker rm todo-backend-test
```

## Environment Variables

The Dockerfile documents these environment variables (see lines 63-68):

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | No | `sqlite:////app/data/todo.db` | SQLite database location |
| `OPENAI_API_KEY` | Yes | - | OpenAI API key for chat functionality |
| `BETTER_AUTH_SECRET` | Yes | - | JWT secret for authentication (min 32 chars) |
| `BETTER_AUTH_URL` | No | `http://localhost:8001` | Base URL for authentication |

## Dockerfile Features

### Multi-Stage Build

1. **Builder Stage** (`python:3.13-slim`)
   - Installs build dependencies (gcc, g++, libffi-dev)
   - Creates virtual environment at `/opt/venv`
   - Installs all Python packages from `requirements.txt`

2. **Runtime Stage** (`python:3.13-slim`)
   - Copies only `/opt/venv` from builder (no build tools)
   - Installs only `curl` for healthcheck
   - Creates non-root user `appuser` (UID 1000)
   - Creates `/app/data` directory for SQLite
   - Sets permissions for `appuser`

### Security Features

- ✅ Non-root user execution (UID 1000)
- ✅ Minimal attack surface (no build tools in runtime)
- ✅ No secrets hardcoded (all via environment variables)
- ✅ Health check for liveness probe
- ✅ `--no-install-recommends` to minimize installed packages

### Size Optimization

- ✅ Multi-stage build (only runtime dependencies in final image)
- ✅ `--no-cache-dir` for pip to avoid caching wheels
- ✅ Cleanup of apt lists with `rm -rf /var/lib/apt/lists/*`
- ✅ Virtual environment instead of system-wide packages
- ✅ `.dockerignore` excludes unnecessary files

## Common Issues

### Issue: Docker daemon not running

```
ERROR: error during connect: ... The system cannot find the file specified.
```

**Solution:** Start Docker Desktop

### Issue: Build fails with "gcc: command not found"

**Solution:** This shouldn't happen with the multi-stage build. The builder stage includes gcc. If it does happen, check that the Dockerfile has both builder and runtime stages.

### Issue: Permission denied when accessing /app/data

**Solution:** The Dockerfile creates `/app/data` and sets ownership to `appuser`. If this still occurs, check that the container is running as `appuser` (not root).

### Issue: Health check failing

**Cause:** Health endpoint `/api/health` may not be implemented or returning non-200 status

**Debug:**
```bash
docker logs <container-id>
docker exec <container-id> curl -v http://localhost:8001/api/health
```

## Next Steps

After successful testing:

1. ✅ **Task 1.1 Complete** - Mark all acceptance criteria as passed
2. ⏭️ **Task 1.2** - Create Frontend Dockerfile with multi-stage build
3. ⏭️ **Task 1.3** - Create Docker Compose for local testing
4. ⏭️ **Task 2.1** - Create Kubernetes manifests for deployment

## Verification Checklist (Task 1.1)

- [ ] Dockerfile has two stages: builder and runtime
- [ ] Builder stage uses `python:3.13-slim`
- [ ] Runtime stage uses `python:3.13-slim`
- [ ] Final image size is under 250MB
- [ ] Image runs as non-root user (UID 1000)
- [ ] Working directory is `/app`
- [ ] Port 8001 is exposed
- [ ] Healthcheck defined for liveness probe
- [ ] Environment variables documented
- [ ] Image builds successfully
- [ ] Image runs successfully
- [ ] Health endpoint responds 200 OK
- [ ] Container runs as `appuser` (verified with `whoami`)
