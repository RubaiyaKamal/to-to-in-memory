# Frontend Docker Build - Testing Guide

This directory contains the multi-stage Dockerfile for the Phase III Todo Chatbot frontend (Vite + React + TypeScript).

## Reference

- **ADR:** [ADR-0001: Containerization Strategy with Multi-Stage Docker Builds](../../../history/adr/0001-containerization-strategy-with-multi-stage-docker-builds.md)
- **Task:** Task 1.2 from `specs/003-local-k8s-deployment/tasks.md`
- **Target Image Size:** ~50MB (vs ~1GB single-stage with Node.js)

## Prerequisites

1. **Docker Desktop must be running**
   - Install: https://www.docker.com/products/docker-desktop
   - Start Docker Desktop before running commands below

2. **Repository Context**
   - All commands must be run from the repository root: `C:\Users\Lap Zone\to-do-in-memory`
   - The Dockerfile copies from `phase-3-chatbot/frontend/`

## Build Commands

### Standard Build (Development Backend URL)

```bash
# From repository root
cd "C:\Users\Lap Zone\to-do-in-memory"

# Build with default backend URL (http://localhost:8001)
docker build \
  -f phase-4-local-deployment/docker/frontend/Dockerfile \
  -t todo-chatbot-frontend:latest \
  .
```

### Build with Custom Backend URL

```bash
# Build with custom API URL (for production or different environments)
docker build \
  -f phase-4-local-deployment/docker/frontend/Dockerfile \
  --build-arg VITE_API_URL=http://backend-service:8001 \
  -t todo-chatbot-frontend:latest \
  .
```

### Build with Progress Output

```bash
docker build \
  --progress=plain \
  -f phase-4-local-deployment/docker/frontend/Dockerfile \
  --build-arg VITE_API_URL=http://localhost:8001 \
  -t todo-chatbot-frontend:latest \
  .
```

## Test Cases (Task 1.2 Acceptance Criteria)

### 1. Build Test

**Requirement:** Image builds without errors in under 5 minutes

```bash
time docker build \
  -f phase-4-local-deployment/docker/frontend/Dockerfile \
  --build-arg VITE_API_URL=http://localhost:8001 \
  -t todo-chatbot-frontend:latest \
  .
```

**Expected:** Build completes successfully in < 5 minutes (first build)
**Expected:** Cached rebuild completes in < 30 seconds

### 2. Size Test

**Requirement:** Final image size is under 100MB

```bash
docker images todo-chatbot-frontend
```

**Expected Output:**
```
REPOSITORY              TAG       IMAGE ID       CREATED          SIZE
todo-chatbot-frontend   latest    <image-id>     <time>          <50MB
```

**Pass Criteria:** SIZE column shows value < 100MB (target ~50MB)

### 3. Run Test

**Requirement:** Container starts and serves UI on port 80

```bash
# Run container mapping port 3000 to container port 80
docker run -d \
  --name todo-frontend-test \
  -p 3000:80 \
  todo-chatbot-frontend:latest

# Wait for startup
sleep 5

# Check container status
docker ps -a | grep todo-frontend-test

# Test homepage
curl http://localhost:3000

# Check logs
docker logs todo-frontend-test
```

**Expected:**
- Container status shows "Up" (not "Exited")
- Homepage returns HTML with `<!DOCTYPE html>`
- Logs show Nginx starting successfully

**Cleanup:**
```bash
docker stop todo-frontend-test
docker rm todo-frontend-test
```

### 4. Nginx SPA Routing Test

**Requirement:** Accessing any route (e.g., `/tasks`) returns index.html (SPA routing works)

```bash
# Start container (if not already running from Test 3)
docker run -d \
  --name todo-frontend-test \
  -p 3000:80 \
  todo-chatbot-frontend:latest

# Wait for startup
sleep 5

# Test root path
curl -I http://localhost:3000/

# Test SPA route (should return index.html, not 404)
curl -I http://localhost:3000/tasks

# Test non-existent static file (should still return index.html for SPA routing)
curl -I http://localhost:3000/some-random-path
```

**Expected:**
- All routes return HTTP 200 OK (not 404)
- Content-Type is `text/html`
- This proves nginx `try_files $uri $uri/ /index.html` is working

**Cleanup:**
```bash
docker stop todo-frontend-test
docker rm todo-frontend-test
```

### 5. Health Check Test

**Requirement:** `/health` endpoint returns 200 OK

```bash
# Start container (if not already running)
docker run -d \
  --name todo-frontend-test \
  -p 3000:80 \
  todo-chatbot-frontend:latest

# Wait for startup
sleep 5

# Test health endpoint
curl -v http://localhost:3000/health

# Check Docker's built-in health status
docker inspect --format='{{json .State.Health}}' todo-frontend-test | jq
```

**Expected:**
- `/health` returns HTTP 200 OK
- Response body: `healthy\n`
- Docker health status shows "healthy" after 30+ seconds

**Cleanup:**
```bash
docker stop todo-frontend-test
docker rm todo-frontend-test
```

## Build Arguments

| Argument | Required | Default | Description |
|----------|----------|---------|-------------|
| `VITE_API_URL` | No | `http://localhost:8001` | Backend API base URL for Vite build |

**Usage Example:**

```bash
# Local development
docker build --build-arg VITE_API_URL=http://localhost:8001 ...

# Kubernetes deployment
docker build --build-arg VITE_API_URL=http://todo-chatbot-backend:8001 ...

# Production deployment
docker build --build-arg VITE_API_URL=https://api.example.com ...
```

## Dockerfile Features

### Multi-Stage Build

1. **Builder Stage** (`node:20-alpine`)
   - Installs Node.js dependencies with `npm ci`
   - Runs TypeScript compilation (`tsc`)
   - Runs Vite build to generate static assets in `/app/dist`
   - Uses Alpine for smaller builder image (~180MB vs ~1GB with node:20)

2. **Runtime Stage** (`nginx:alpine`)
   - Copies only built static assets from `/app/dist`
   - Installs `curl` for healthcheck
   - Copies custom `nginx.conf` for SPA routing
   - Creates nginx cache directories with proper permissions
   - Final image size: ~50MB

### Nginx Configuration (`nginx.conf`)

**Features:**
- ✅ **SPA Routing**: `try_files $uri $uri/ /index.html` - all routes fallback to index.html
- ✅ **Health Endpoint**: `/health` returns 200 OK for Kubernetes health checks
- ✅ **Gzip Compression**: Compresses text assets for faster transfer
- ✅ **Security Headers**: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection
- ✅ **Static Asset Caching**: 1-year cache for JS/CSS/images
- ✅ **No Cache for index.html**: Ensures SPA always loads latest version

**SPA Routing Logic:**
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

This means:
1. Try to serve the exact file (`$uri`)
2. If not found, try to serve it as a directory (`$uri/`)
3. If still not found, serve `index.html` (SPA router takes over)

### Size Optimization

- ✅ Multi-stage build (only static assets in final image, no Node.js)
- ✅ Alpine-based images for both stages
- ✅ `npm ci` instead of `npm install` (faster, reproducible)
- ✅ `.dockerignore` excludes unnecessary files (node_modules, tests, docs)
- ✅ Nginx alpine is only ~40MB base image
- ✅ Built assets are highly optimized by Vite (minified, tree-shaken)

## Environment Variables (Runtime)

The frontend is a static SPA served by Nginx. All configuration is baked in at **build time** via `VITE_API_URL`.

**Note:** Vite environment variables are only available during the build step, not at runtime. If you need runtime configuration, consider:

1. **Build-time substitution** (current approach)
   - Set `VITE_API_URL` during Docker build
   - Requires rebuilding image for different environments

2. **Runtime injection** (advanced, requires custom script)
   - Generate `config.js` at container startup
   - Inject into `index.html` via entrypoint script
   - Allows same image for multiple environments

## Common Issues

### Issue: Docker daemon not running

```
ERROR: error during connect: ... The system cannot find the file specified.
```

**Solution:** Start Docker Desktop

### Issue: Build fails with "npm ci can only install packages when..."

```
npm ERR! Can only install packages when your package.json and package-lock.json or npm-shrinkwrap.json are in sync
```

**Solution:** The package-lock.json might be out of sync. From the frontend directory:
```bash
cd phase-3-chatbot/frontend
npm install
```

### Issue: 404 errors for /tasks or other routes

**Cause:** Nginx not configured for SPA routing

**Solution:** Verify `nginx.conf` has the `try_files $uri $uri/ /index.html;` directive

**Debug:**
```bash
docker exec todo-frontend-test cat /etc/nginx/conf.d/default.conf
```

### Issue: Health check failing

**Cause:** Health endpoint not configured or curl not installed

**Debug:**
```bash
# Check if curl is available
docker exec todo-frontend-test curl --version

# Manually test health endpoint
docker exec todo-frontend-test curl http://localhost/health

# Check nginx config
docker exec todo-frontend-test cat /etc/nginx/conf.d/default.conf | grep health
```

### Issue: Assets not loading (404 on JS/CSS files)

**Cause:** Vite build output not copied correctly or wrong base path

**Debug:**
```bash
# Check what's in the nginx html directory
docker exec todo-frontend-test ls -la /usr/share/nginx/html

# Should contain: index.html, assets/ directory, vite.svg, etc.
```

**Solution:** Verify Dockerfile copies from `/app/dist` (Vite's default output directory)

## Next Steps

After successful testing:

1. ✅ **Task 1.2 Complete** - Mark all acceptance criteria as passed
2. ⏭️ **Task 1.3** - Create Docker Compose for local testing (both frontend + backend)
3. ⏭️ **Task 2.1** - Create Kubernetes manifests for deployment

## Verification Checklist (Task 1.2)

- [ ] Dockerfile has two stages: builder and runtime
- [ ] Builder stage uses `node:20-alpine`
- [ ] Builder stage runs `npm install` and `npm run build`
- [ ] Runtime stage uses `nginx:alpine`
- [ ] Static build output copied from builder to Nginx html directory
- [ ] Custom `nginx.conf` configures SPA routing (fallback to index.html)
- [ ] Final image size is under 100MB
- [ ] Port 80 is exposed
- [ ] Healthcheck endpoint `/health` returns 200 OK
- [ ] Build-time arg `VITE_API_URL` is defined and used
- [ ] Image builds successfully with `--build-arg VITE_API_URL=http://localhost:8001`
- [ ] Image runs successfully with `-p 3000:80`
- [ ] Accessing `/tasks` returns index.html (SPA routing works)
- [ ] `/health` endpoint returns 200 OK

## Nginx Configuration Reference

The `nginx.conf` file includes:

```nginx
# SPA routing
location / {
    try_files $uri $uri/ /index.html;
}

# Health endpoint
location /health {
    access_log off;
    return 200 "healthy\n";
    add_header Content-Type text/plain;
}

# Static asset caching (1 year)
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# No cache for index.html
location = /index.html {
    add_header Cache-Control "no-store, no-cache, must-revalidate";
}
```

Full configuration is in `phase-4-local-deployment/docker/frontend/nginx.conf`.
