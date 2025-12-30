#!/bin/bash
# Docker Image Build Script for Todo Chatbot
# Task 4.2: Create Image Build Script
# Reference: specs/003-local-k8s-deployment/tasks.md
#
# This script builds Docker images for backend and frontend with:
# - Minikube Docker environment configuration
# - Multi-stage build optimization
# - Image tagging (latest, semantic version)
# - Automatic loading into Minikube
# - Build verification

set -e  # Exit on error
set -u  # Exit on undefined variable

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Build configuration
IMAGE_TAG="${IMAGE_TAG:-latest}"
BACKEND_IMAGE="todo-chatbot-backend"
FRONTEND_IMAGE="todo-chatbot-frontend"
USE_MINIKUBE="${USE_MINIKUBE:-true}"
LOAD_TO_MINIKUBE="${LOAD_TO_MINIKUBE:-true}"
BUILD_BACKEND="${BUILD_BACKEND:-true}"
BUILD_FRONTEND="${BUILD_FRONTEND:-true}"

# Print configuration
print_config() {
    echo ""
    log_info "=== Build Configuration ==="
    echo "  Image Tag:         $IMAGE_TAG"
    echo "  Backend Image:     ${BACKEND_IMAGE}:${IMAGE_TAG}"
    echo "  Frontend Image:    ${FRONTEND_IMAGE}:${IMAGE_TAG}"
    echo "  Use Minikube:      $USE_MINIKUBE"
    echo "  Load to Minikube:  $LOAD_TO_MINIKUBE"
    echo "  Build Backend:     $BUILD_BACKEND"
    echo "  Build Frontend:    $BUILD_FRONTEND"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        echo "Please install Docker and try again"
        exit 1
    fi
    log_success "Docker is installed: $(docker --version)"

    # Check if Docker is running
    if ! docker info &> /dev/null; then
        log_error "Docker is not running"
        echo "Please start Docker and try again"
        exit 1
    fi
    log_success "Docker is running"

    # Check if Minikube is running (if USE_MINIKUBE=true)
    if [ "$USE_MINIKUBE" = "true" ]; then
        if ! command -v minikube &> /dev/null; then
            log_warning "Minikube is not installed"
            log_warning "Images will be built for local Docker only"
            USE_MINIKUBE="false"
            LOAD_TO_MINIKUBE="false"
        elif ! minikube status &> /dev/null; then
            log_warning "Minikube is not running"
            log_warning "Images will be built for local Docker only"
            log_warning "Start Minikube first to build images for Kubernetes"
            USE_MINIKUBE="false"
            LOAD_TO_MINIKUBE="false"
        else
            log_success "Minikube is running"
        fi
    fi

    # Verify Dockerfiles exist
    if [ "$BUILD_BACKEND" = "true" ] && [ ! -f "$PROJECT_ROOT/phase-4-local-deployment/docker/backend/Dockerfile" ]; then
        log_error "Backend Dockerfile not found at: phase-4-local-deployment/docker/backend/Dockerfile"
        exit 1
    fi

    if [ "$BUILD_FRONTEND" = "true" ] && [ ! -f "$PROJECT_ROOT/phase-4-local-deployment/docker/frontend/Dockerfile" ]; then
        log_error "Frontend Dockerfile not found at: phase-4-local-deployment/docker/frontend/Dockerfile"
        exit 1
    fi

    log_success "All prerequisites met"
    echo ""
}

# Configure Docker environment for Minikube
configure_minikube_docker() {
    if [ "$USE_MINIKUBE" = "true" ]; then
        log_info "Configuring Docker environment for Minikube..."

        # Set Docker environment to Minikube
        eval $(minikube docker-env)

        if [ $? -eq 0 ]; then
            log_success "Docker environment configured for Minikube"
            log_info "Images will be built directly in Minikube's Docker daemon"
        else
            log_error "Failed to configure Minikube Docker environment"
            exit 1
        fi
        echo ""
    fi
}

# Build backend image
build_backend() {
    if [ "$BUILD_BACKEND" = "true" ]; then
        log_info "Building backend image..."
        echo ""

        cd "$PROJECT_ROOT"

        docker build \
            -f phase-4-local-deployment/docker/backend/Dockerfile \
            -t "${BACKEND_IMAGE}:${IMAGE_TAG}" \
            --progress=plain \
            .

        if [ $? -eq 0 ]; then
            log_success "Backend image built: ${BACKEND_IMAGE}:${IMAGE_TAG}"

            # Tag as latest if not already
            if [ "$IMAGE_TAG" != "latest" ]; then
                docker tag "${BACKEND_IMAGE}:${IMAGE_TAG}" "${BACKEND_IMAGE}:latest"
                log_success "Tagged as: ${BACKEND_IMAGE}:latest"
            fi
        else
            log_error "Failed to build backend image"
            exit 1
        fi
        echo ""
    else
        log_info "Skipping backend image build"
        echo ""
    fi
}

# Build frontend image
build_frontend() {
    if [ "$BUILD_FRONTEND" = "true" ]; then
        log_info "Building frontend image..."
        echo ""

        cd "$PROJECT_ROOT"

        docker build \
            -f phase-4-local-deployment/docker/frontend/Dockerfile \
            -t "${FRONTEND_IMAGE}:${IMAGE_TAG}" \
            --progress=plain \
            .

        if [ $? -eq 0 ]; then
            log_success "Frontend image built: ${FRONTEND_IMAGE}:${IMAGE_TAG}"

            # Tag as latest if not already
            if [ "$IMAGE_TAG" != "latest" ]; then
                docker tag "${FRONTEND_IMAGE}:${IMAGE_TAG}" "${FRONTEND_IMAGE}:latest"
                log_success "Tagged as: ${FRONTEND_IMAGE}:latest"
            fi
        else
            log_error "Failed to build frontend image"
            exit 1
        fi
        echo ""
    else
        log_info "Skipping frontend image build"
        echo ""
    fi
}

# Load images to Minikube (if not already built in Minikube Docker)
load_images_to_minikube() {
    if [ "$LOAD_TO_MINIKUBE" = "true" ] && [ "$USE_MINIKUBE" = "false" ]; then
        log_info "Loading images to Minikube..."

        if [ "$BUILD_BACKEND" = "true" ]; then
            log_info "Loading backend image to Minikube..."
            minikube image load "${BACKEND_IMAGE}:${IMAGE_TAG}"
            if [ $? -eq 0 ]; then
                log_success "Backend image loaded to Minikube"
            else
                log_warning "Failed to load backend image to Minikube"
            fi
        fi

        if [ "$BUILD_FRONTEND" = "true" ]; then
            log_info "Loading frontend image to Minikube..."
            minikube image load "${FRONTEND_IMAGE}:${IMAGE_TAG}"
            if [ $? -eq 0 ]; then
                log_success "Frontend image loaded to Minikube"
            else
                log_warning "Failed to load frontend image to Minikube"
            fi
        fi
        echo ""
    fi
}

# Verify images
verify_images() {
    log_info "Verifying built images..."
    echo ""

    # List images
    log_info "Docker images:"
    docker images | grep -E "REPOSITORY|todo-chatbot"
    echo ""

    # Check image sizes
    if [ "$BUILD_BACKEND" = "true" ]; then
        BACKEND_SIZE=$(docker images --format "{{.Size}}" "${BACKEND_IMAGE}:${IMAGE_TAG}")
        log_info "Backend image size: $BACKEND_SIZE"
    fi

    if [ "$BUILD_FRONTEND" = "true" ]; then
        FRONTEND_SIZE=$(docker images --format "{{.Size}}" "${FRONTEND_IMAGE}:${IMAGE_TAG}")
        log_info "Frontend image size: $FRONTEND_SIZE"
    fi
    echo ""

    # Verify images in Minikube (if applicable)
    if [ "$USE_MINIKUBE" = "true" ]; then
        log_info "Images in Minikube:"
        minikube image ls | grep todo-chatbot || log_warning "No todo-chatbot images found in Minikube"
        echo ""
    fi
}

# Display next steps
display_next_steps() {
    echo ""
    log_success "=== Image Build Complete ==="
    echo ""
    log_info "Built images:"
    if [ "$BUILD_BACKEND" = "true" ]; then
        echo "  - ${BACKEND_IMAGE}:${IMAGE_TAG}"
        if [ "$IMAGE_TAG" != "latest" ]; then
            echo "  - ${BACKEND_IMAGE}:latest"
        fi
    fi
    if [ "$BUILD_FRONTEND" = "true" ]; then
        echo "  - ${FRONTEND_IMAGE}:${IMAGE_TAG}"
        if [ "$IMAGE_TAG" != "latest" ]; then
            echo "  - ${FRONTEND_IMAGE}:latest"
        fi
    fi
    echo ""

    log_info "Next steps:"
    echo ""
    echo "  1. Deploy with kubectl:"
    echo "     kubectl apply -k $PROJECT_ROOT/phase-4-local-deployment/k8s/base"
    echo ""
    echo "  2. Deploy with Helm:"
    echo "     helm install todo-chatbot $PROJECT_ROOT/phase-4-local-deployment/helm/todo-chatbot \\"
    echo "       -f $PROJECT_ROOT/phase-4-local-deployment/helm/todo-chatbot/values-local.yaml"
    echo ""
    echo "  3. Verify deployment:"
    echo "     kubectl get pods -n todo-chatbot"
    echo ""
    echo "  4. Access application:"
    echo "     minikube service todo-chatbot-frontend -n todo-chatbot"
    echo ""
}

# Main execution
main() {
    echo ""
    log_info "=== Todo Chatbot - Docker Image Build ==="
    echo ""

    # Print configuration
    print_config

    # Check prerequisites
    check_prerequisites

    # Configure Minikube Docker environment (if needed)
    configure_minikube_docker

    # Build images
    build_backend
    build_frontend

    # Load images to Minikube (if needed)
    load_images_to_minikube

    # Verify images
    verify_images

    # Display next steps
    display_next_steps

    log_success "All images built successfully!"
    echo ""
}

# Run main function
main "$@"
