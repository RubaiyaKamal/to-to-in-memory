# Multi-stage build for Phase 3 Chatbot Backend
# ADR-0001: Containerization Strategy with Multi-Stage Docker Builds
# Target: ~200MB final image size (vs ~800MB single-stage)

# =============================================================================
# BUILDER STAGE - Install dependencies and build wheels
# =============================================================================
FROM python:3.12-slim as builder

# Set working directory
WORKDIR /app

# Install build dependencies for Python packages with C extensions
# (e.g., cryptography from python-jose, bcrypt from passlib)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY phase-3-chatbot/backend/requirements.txt .

# Install Python dependencies to /opt/venv
# Using a virtual environment makes it easier to copy to runtime stage
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# =============================================================================
# RUNTIME STAGE - Minimal production image
# =============================================================================
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install runtime dependencies only (curl for healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY phase-3-chatbot/backend/ .

# Create data directory for SQLite database with proper permissions
RUN mkdir -p /app/data

# Create non-root user (UID 1000) and change ownership
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Add venv to PATH
ENV PATH="/opt/venv/bin:$PATH"

# Environment variables (override these at runtime)
# DATABASE_URL: SQLite database location (default: sqlite:////app/data/todo.db)
# OPENAI_API_KEY: Required for AI chat functionality
# BETTER_AUTH_SECRET: JWT secret for authentication
# BETTER_AUTH_URL: Base URL for authentication (default: http://localhost:8001)
ENV DATABASE_URL="sqlite:////app/data/todo.db" \
    PYTHONUNBUFFERED=1

# Expose application port
EXPOSE 8001

# Health check - uses curl instead of requests to avoid extra dependency
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8001/api/health || exit 1

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
