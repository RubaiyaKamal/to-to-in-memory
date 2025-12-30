# Multi-stage build for Phase 3 Chatbot Frontend (Vite + React + TypeScript)
# ADR-0001: Containerization Strategy with Multi-Stage Docker Builds
# Target: ~50MB final image size (vs ~1GB single-stage with Node.js)

# =============================================================================
# BUILDER STAGE - Install dependencies and build static assets
# =============================================================================
FROM node:20-alpine as builder

# Set working directory
WORKDIR /app

# Build argument for backend API URL (required for Vite configuration)
# Default to localhost for local development, override for production deployment
ARG VITE_API_URL=http://localhost:8001
ENV VITE_API_URL=${VITE_API_URL}

# Copy package files first for better layer caching
# Only rebuild dependencies if package.json or package-lock.json changes
COPY phase-3-chatbot/frontend/package*.json ./

# Install dependencies using npm ci for reproducible builds
# npm ci is faster and more reliable than npm install for CI/CD
RUN npm ci --only=production=false

# Copy application source code
COPY phase-3-chatbot/frontend/ .

# Build the application with TypeScript compilation and Vite bundling
# Output goes to /app/dist directory
RUN npm run build

# =============================================================================
# RUNTIME STAGE - Serve static assets with Nginx
# =============================================================================
FROM nginx:alpine

# Install curl for healthcheck (alpine doesn't include wget by default)
RUN apk add --no-cache curl

# Copy built static assets from builder stage
# Vite builds to /app/dist by default
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx configuration for SPA routing
COPY phase-4-local-deployment/docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Create nginx cache directories with proper permissions
RUN mkdir -p /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp \
    && chown -R nginx:nginx /var/cache/nginx

# Expose HTTP port
EXPOSE 80

# Health check using /health endpoint defined in nginx.conf
# Uses curl instead of wget for compatibility with alpine
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Start nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]
