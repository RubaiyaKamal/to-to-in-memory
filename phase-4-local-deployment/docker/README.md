# Docker Compose - Local Testing Guide

This directory contains Docker Compose configuration for local testing of the Todo Chatbot application before Kubernetes deployment.

## Reference

- **ADR:** [ADR-0001: Containerization Strategy](../../history/adr/0001-containerization-strategy-with-multi-stage-docker-builds.md)
- **Task:** Task 1.3 from `specs/003-local-k8s-deployment/tasks.md`
- **Purpose:** Full-stack local testing with both backend and frontend services

## Directory Structure

```
phase-4-local-deployment/docker/
├── backend/
│   ├── Dockerfile              # Multi-stage backend build (Python 3.13-slim)
│   ├── .dockerignore           # Build context exclusions
│   └── README.md               # Backend-specific documentation
├── frontend/
│   ├── Dockerfile              # Multi-stage frontend build (Node 20 + Nginx)
│   ├── nginx.conf              # Nginx configuration for SPA routing
│   ├── .dockerignore           # Build context exclusions
│   └── README.md               # Frontend-specific documentation
├── docker-compose.yml          # Service orchestration (THIS FILE'S PURPOSE)
├── .env.example                # Environment variable template
├── .env                        # Your actual secrets (DO NOT COMMIT)
└── README.md                   # This file
```

## Prerequisites

1. **Docker Desktop Running**
   - Install: https://www.docker.com/products/docker-desktop
   - Ensure Docker Desktop is started

2. **Environment Variables**
   ```bash
   # Copy example file
   cp .env.example .env

   # Edit .env and add your OpenAI API key
   # OPENAI_API_KEY=sk-your-actual-key-here
   ```

3. **Repository Context**
   - All commands must be run from this directory: `phase-4-local-deployment/docker/`

## Quick Start

```bash
# Navigate to docker directory
cd "C:\Users\Lap Zone\to-do-in-memory\phase-4-local-deployment\docker"

# 1. Copy environment template (first time only)
cp .env.example .env

# 2. Edit .env and add your OPENAI_API_KEY
# (Use your favorite text editor)

# 3. Start services in background
docker-compose up -d

# 4. View logs
docker-compose logs -f

# 5. Open browser
# Frontend: http://localhost:3000
# Backend API Docs: http://localhost:8001/docs
# Backend Health: http://localhost:8001/api/health

# 6. Stop services
docker-compose down

# 7. Stop and remove volumes (delete database)
docker-compose down -v
```

## Services

### Backend Service

- **Image:** Built from `backend/Dockerfile`
- **Port:** 8001 (mapped to host 8001)
- **Database:** SQLite at `/app/data/todo.db` (persisted in Docker volume)
- **Health Check:** `http://localhost:8001/api/health`
- **API Docs:** `http://localhost:8001/docs` (FastAPI Swagger UI)

**Environment Variables:**
- `OPENAI_API_KEY` - Required (from .env file)
- `BETTER_AUTH_SECRET` - Required (from .env or default)
- `DATABASE_URL` - Auto-configured to SQLite
- `BETTER_AUTH_URL` - Auto-configured to http://localhost:8001

### Frontend Service

- **Image:** Built from `frontend/Dockerfile`
- **Port:** 80 (mapped to host 3000)
- **Build Arg:** `VITE_API_URL=http://localhost:8001` (from .env)
- **Health Check:** `http://localhost:3000/health`
- **UI:** `http://localhost:3000`

**Build Arguments:**
- `VITE_API_URL` - Backend API URL (from .env file, default: http://localhost:8001)

### Network

Both services communicate via `todo-network` (bridge driver):
- Backend accessible at: `http://backend:8001` (from within network)
- Frontend accessible at: `http://frontend:80` (from within network)
- From host: Use localhost with mapped ports (8001, 3000)

### Volume

- **backend-data**: Persists SQLite database across container restarts
  - Location: Docker-managed volume
  - Contents: `/app/data/todo.db`
  - Survives `docker-compose restart` and `docker-compose up/down`
  - Deleted with `docker-compose down -v`

## Common Commands

### Start and Stop

```bash
# Start services (builds images if needed)
docker-compose up -d

# Start and rebuild images (after code changes)
docker-compose up -d --build

# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f backend
docker-compose logs -f frontend

# Stop services (keeps containers and volumes)
docker-compose stop

# Start stopped services
docker-compose start

# Restart services
docker-compose restart

# Stop and remove containers (keeps volumes)
docker-compose down

# Stop and remove containers + volumes (DELETES DATABASE)
docker-compose down -v
```

### Debugging

```bash
# Check service status
docker-compose ps

# Execute command in backend container
docker-compose exec backend bash

# Execute command in frontend container
docker-compose exec frontend sh

# View backend logs
docker-compose logs backend --tail=100 -f

# View frontend logs
docker-compose logs frontend --tail=100 -f

# Inspect backend health
docker-compose exec backend curl http://localhost:8001/api/health

# Inspect frontend health
docker-compose exec frontend curl http://localhost/health

# Check database file
docker-compose exec backend ls -lah /app/data/
docker-compose exec backend sqlite3 /app/data/todo.db ".tables"
```

### Cleanup

```bash
# Remove all stopped containers
docker-compose down

# Remove all stopped containers and volumes
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Remove everything (containers, volumes, networks, images)
docker-compose down -v --rmi all
```

## Test Cases (Task 1.3 Acceptance Criteria)

### 1. Start Test

**Requirement:** `docker-compose up -d` starts both services without errors

```bash
cd phase-4-local-deployment/docker

# Start services
docker-compose up -d

# Check status (should show both services as "Up")
docker-compose ps

# Check logs for errors
docker-compose logs
```

**Expected Output:**
```
NAME                      COMMAND                  SERVICE    STATUS
todo-chatbot-backend      "uvicorn main:app --…"   backend    Up (healthy)
todo-chatbot-frontend     "nginx -g 'daemon of…"   frontend   Up (healthy)
```

**Pass Criteria:**
- Both services show status "Up"
- No error messages in logs
- Health checks passing (wait 40s for backend)

### 2. Network Test

**Requirement:** Frontend can reach backend API

```bash
# Test from host machine
curl http://localhost:8001/api/health
curl http://localhost:3000/health

# Test backend from frontend container
docker-compose exec frontend curl http://backend:8001/api/health

# Test API docs accessible
curl http://localhost:8001/docs
```

**Expected:**
- Backend health returns JSON: `{"status":"ok",...}`
- Frontend health returns: `healthy`
- Frontend can reach backend using service name
- API docs accessible from browser

**Pass Criteria:**
- All health checks return 200 OK
- No connection errors

### 3. Persistence Test

**Requirement:** Database data persists after `docker-compose restart`

```bash
# Create test data via API (requires backend to be running)
curl -X POST http://localhost:8001/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Persistence test"}'

# Check data exists
docker-compose exec backend sqlite3 /app/data/todo.db "SELECT * FROM tasks;"

# Restart services
docker-compose restart

# Wait for startup (40s for backend health)
sleep 45

# Check data still exists
docker-compose exec backend sqlite3 /app/data/todo.db "SELECT * FROM tasks;"
```

**Expected:**
- Data created before restart is still present after restart
- Database file persists in volume

**Pass Criteria:**
- Same data visible before and after restart
- No data loss

### 4. Cleanup Test

**Requirement:** `docker-compose down -v` removes all resources

```bash
# List volumes before
docker volume ls | grep backend-data

# Stop and remove everything
docker-compose down -v

# List volumes after (should be gone)
docker volume ls | grep backend-data

# Check containers removed
docker-compose ps

# Check network removed
docker network ls | grep todo-network
```

**Expected:**
- All containers stopped and removed
- Volume `backend-data` removed
- Network `todo-network` removed

**Pass Criteria:**
- No containers running
- No volumes remaining
- No networks remaining (except default)

## Environment Variables

### Required

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key for chat functionality | `sk-proj-...` |

### Optional (with defaults)

| Variable | Default | Description |
|----------|---------|-------------|
| `BETTER_AUTH_SECRET` | `default-secret-change-in-production-min-32-chars` | JWT secret (min 32 chars) |
| `BETTER_AUTH_URL` | `http://localhost:8001` | Auth base URL |
| `VITE_API_URL` | `http://localhost:8001` | Frontend API URL (build arg) |

## Troubleshooting

### Issue: "Cannot connect to Docker daemon"

```
ERROR: error during connect: ...
```

**Solution:** Start Docker Desktop

---

### Issue: "Service 'backend' failed to build"

**Possible Causes:**
1. Docker Desktop not running
2. Build context issues
3. Dockerfile syntax errors

**Debug:**
```bash
# Try building manually
cd ../..
docker build -f phase-4-local-deployment/docker/backend/Dockerfile .

# Check build logs
docker-compose build backend
```

---

### Issue: "Backend health check failing"

**Symptoms:** Backend container restarts continuously

**Debug:**
```bash
# Check logs
docker-compose logs backend

# Check if app is running
docker-compose exec backend ps aux

# Test health endpoint manually
docker-compose exec backend curl http://localhost:8001/api/health
```

**Common Causes:**
- Missing `OPENAI_API_KEY`
- Database initialization errors
- FastAPI startup errors

---

### Issue: "Frontend shows connection errors"

**Symptoms:** Frontend loads but API calls fail

**Debug:**
```bash
# Check if backend is reachable from frontend
docker-compose exec frontend curl http://backend:8001/api/health

# Check frontend environment
docker-compose exec frontend env | grep VITE

# Check nginx configuration
docker-compose exec frontend cat /etc/nginx/conf.d/default.conf
```

**Common Causes:**
- Backend not healthy yet (wait 40s)
- Wrong `VITE_API_URL` in .env
- Network configuration issue

---

### Issue: "Port already in use"

```
ERROR: for backend  Cannot start service backend:
Ports are not available: exposing port TCP 0.0.0.0:8001 -> 0.0.0.0:0: listen tcp 0.0.0.0:8001: bind: address already in use
```

**Solution:**
```bash
# Find what's using the port
# Windows:
netstat -ano | findstr :8001

# Kill the process or change port in docker-compose.yml
# Change: "8001:8001" to "8002:8001"
```

---

### Issue: "Database file not found"

**Debug:**
```bash
# Check volume
docker volume inspect phase-4-local-deployment_docker_backend-data

# Check if database file exists
docker-compose exec backend ls -la /app/data/

# Check permissions
docker-compose exec backend whoami
docker-compose exec backend ls -la /app/
```

**Solution:** Volume should be automatically created. If not:
```bash
docker-compose down -v
docker-compose up -d
```

---

### Issue: "Changes to code not reflected"

**Cause:** Docker images cached

**Solution:**
```bash
# Rebuild images
docker-compose up -d --build

# Or force rebuild
docker-compose build --no-cache
docker-compose up -d
```

## Production Considerations

⚠️ **This Docker Compose setup is for LOCAL DEVELOPMENT only**

For production deployment:
1. Use Kubernetes (Phase IV - Minikube, Phase V - DOKS)
2. Never use default `BETTER_AUTH_SECRET`
3. Use PostgreSQL instead of SQLite
4. Enable HTTPS/TLS
5. Use proper secrets management (Kubernetes Secrets, Dapr)
6. Configure resource limits
7. Set up monitoring and logging
8. Use production-grade container registry

## Next Steps

After successful Docker Compose testing:

1. ✅ **Task 1.3 Complete** - Mark all acceptance criteria as passed
2. ⏭️ **Task 2.1** - Create Kubernetes namespace and base configuration
3. ⏭️ **Task 2.2** - Create ConfigMap and Secrets
4. ⏭️ **Task 2.3** - Create PersistentVolumeClaim for database
5. ⏭️ **Task 2.4** - Create backend Deployment and Service
6. ⏭️ **Task 2.5** - Create frontend Deployment and Service

## Verification Checklist (Task 1.3)

- [ ] Compose file defines two services: `backend` and `frontend`
- [ ] Backend service builds from `./backend/Dockerfile`
- [ ] Frontend service builds from `./frontend/Dockerfile`
- [ ] Backend exposes port 8001
- [ ] Frontend exposes port 3000
- [ ] Backend has `DATABASE_URL` environment variable
- [ ] Backend has `OPENAI_API_KEY` environment variable
- [ ] Backend has `BETTER_AUTH_SECRET` environment variable
- [ ] Frontend has `VITE_API_URL` build argument
- [ ] Backend has volume mount for database persistence
- [ ] Services can communicate via Docker network
- [ ] `docker-compose up -d` starts successfully
- [ ] Frontend accessible at `http://localhost:3000`
- [ ] Backend accessible at `http://localhost:8001/docs`
- [ ] Database persists after restart
- [ ] `docker-compose down -v` removes all resources
