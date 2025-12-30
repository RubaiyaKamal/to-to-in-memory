#!/bin/bash
# Minikube Setup Script for Todo Chatbot
# Task 4.1: Create Minikube Setup Script
# Reference: specs/003-local-k8s-deployment/tasks.md
#
# This script sets up Minikube for local Kubernetes deployment with:
# - Resource allocation (CPU, memory, disk)
# - Kubernetes version configuration
# - Required addons (ingress, metrics-server, storage)
# - Docker environment configuration
# - Verification of setup

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

# Minikube configuration
MINIKUBE_CPUS="${MINIKUBE_CPUS:-2}"
MINIKUBE_MEMORY="${MINIKUBE_MEMORY:-4096}"
MINIKUBE_DISK="${MINIKUBE_DISK:-20g}"
MINIKUBE_DRIVER="${MINIKUBE_DRIVER:-docker}"
KUBERNETES_VERSION="${KUBERNETES_VERSION:-v1.28.3}"

# Print configuration
print_config() {
    echo ""
    log_info "=== Minikube Configuration ==="
    echo "  CPUs:              $MINIKUBE_CPUS"
    echo "  Memory:            ${MINIKUBE_MEMORY}MB"
    echo "  Disk Size:         $MINIKUBE_DISK"
    echo "  Driver:            $MINIKUBE_DRIVER"
    echo "  Kubernetes:        $KUBERNETES_VERSION"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if minikube is installed
    if ! command -v minikube &> /dev/null; then
        log_error "Minikube is not installed"
        echo ""
        echo "Installation instructions:"
        echo "  macOS:   brew install minikube"
        echo "  Linux:   curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
        echo "           sudo install minikube-linux-amd64 /usr/local/bin/minikube"
        echo "  Windows: choco install minikube"
        echo ""
        echo "See: https://minikube.sigs.k8s.io/docs/start/"
        exit 1
    fi
    log_success "Minikube is installed: $(minikube version --short)"

    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        echo ""
        echo "Installation instructions:"
        echo "  macOS:   brew install kubectl"
        echo "  Linux:   curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        echo "  Windows: choco install kubernetes-cli"
        echo ""
        echo "See: https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    log_success "kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

    # Check if Docker is installed (if using docker driver)
    if [ "$MINIKUBE_DRIVER" = "docker" ]; then
        if ! command -v docker &> /dev/null; then
            log_error "Docker is not installed (required for docker driver)"
            echo ""
            echo "Installation instructions:"
            echo "  macOS:   brew install --cask docker"
            echo "  Linux:   https://docs.docker.com/engine/install/"
            echo "  Windows: https://docs.docker.com/desktop/install/windows-install/"
            echo ""
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
    fi

    log_success "All prerequisites met"
    echo ""
}

# Check Minikube status
check_minikube_status() {
    log_info "Checking Minikube status..."

    if minikube status &> /dev/null; then
        log_warning "Minikube is already running"
        echo ""
        read -p "Do you want to delete and recreate Minikube? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deleting existing Minikube cluster..."
            minikube delete
            log_success "Minikube cluster deleted"
        else
            log_info "Using existing Minikube cluster"
            return 0
        fi
    fi

    return 1
}

# Start Minikube
start_minikube() {
    log_info "Starting Minikube..."

    minikube start \
        --cpus="$MINIKUBE_CPUS" \
        --memory="$MINIKUBE_MEMORY" \
        --disk-size="$MINIKUBE_DISK" \
        --driver="$MINIKUBE_DRIVER" \
        --kubernetes-version="$KUBERNETES_VERSION" \
        --addons=ingress,metrics-server,storage-provisioner,default-storageclass

    if [ $? -eq 0 ]; then
        log_success "Minikube started successfully"
    else
        log_error "Failed to start Minikube"
        exit 1
    fi
    echo ""
}

# Configure kubectl context
configure_kubectl() {
    log_info "Configuring kubectl context..."

    # Set kubectl context to minikube
    kubectl config use-context minikube

    if [ $? -eq 0 ]; then
        log_success "kubectl context set to minikube"
    else
        log_error "Failed to set kubectl context"
        exit 1
    fi
    echo ""
}

# Enable Minikube addons
enable_addons() {
    log_info "Enabling Minikube addons..."

    # List of addons to enable
    ADDONS=(
        "ingress"
        "metrics-server"
        "storage-provisioner"
        "default-storageclass"
    )

    for addon in "${ADDONS[@]}"; do
        log_info "Enabling addon: $addon"
        minikube addons enable "$addon"

        if [ $? -eq 0 ]; then
            log_success "Addon enabled: $addon"
        else
            log_warning "Failed to enable addon: $addon"
        fi
    done
    echo ""
}

# Verify Minikube setup
verify_setup() {
    log_info "Verifying Minikube setup..."

    # Check Minikube status
    log_info "Checking Minikube status..."
    minikube status
    echo ""

    # Check cluster info
    log_info "Checking cluster info..."
    kubectl cluster-info
    echo ""

    # Check nodes
    log_info "Checking nodes..."
    kubectl get nodes
    echo ""

    # Check system pods
    log_info "Checking system pods..."
    kubectl get pods -n kube-system
    echo ""

    # Get Minikube IP
    MINIKUBE_IP=$(minikube ip)
    log_success "Minikube IP: $MINIKUBE_IP"
    echo ""
}

# Configure Docker environment
configure_docker_env() {
    log_info "Configuring Docker environment..."

    echo ""
    log_info "To use Minikube's Docker daemon, run:"
    echo ""
    echo "  eval \$(minikube docker-env)"
    echo ""
    log_info "This allows you to build Docker images directly in Minikube"
    echo ""
}

# Display next steps
display_next_steps() {
    echo ""
    log_success "=== Minikube Setup Complete ==="
    echo ""
    log_info "Minikube Dashboard:"
    echo "  minikube dashboard"
    echo ""
    log_info "Build Docker images in Minikube:"
    echo "  eval \$(minikube docker-env)"
    echo "  cd $PROJECT_ROOT/phase-4-local-deployment/docker"
    echo "  docker-compose build"
    echo ""
    log_info "Deploy application:"
    echo "  # Using kubectl:"
    echo "  kubectl apply -k $PROJECT_ROOT/phase-4-local-deployment/k8s/base"
    echo ""
    echo "  # Using Helm:"
    echo "  helm install todo-chatbot $PROJECT_ROOT/phase-4-local-deployment/helm/todo-chatbot \\"
    echo "    -f $PROJECT_ROOT/phase-4-local-deployment/helm/todo-chatbot/values-local.yaml"
    echo ""
    log_info "Access application:"
    echo "  # Get Minikube IP:"
    echo "  minikube ip"
    echo ""
    echo "  # Access frontend:"
    echo "  http://\$(minikube ip):30080"
    echo ""
    echo "  # Or use minikube service:"
    echo "  minikube service todo-chatbot-frontend -n todo-chatbot"
    echo ""
    log_info "Stop Minikube:"
    echo "  minikube stop"
    echo ""
    log_info "Delete Minikube:"
    echo "  minikube delete"
    echo ""
}

# Main execution
main() {
    echo ""
    log_info "=== Todo Chatbot - Minikube Setup ==="
    echo ""

    # Print configuration
    print_config

    # Check prerequisites
    check_prerequisites

    # Check if Minikube is already running
    if check_minikube_status; then
        # Minikube exists and user chose to keep it
        configure_kubectl
        verify_setup
    else
        # Start new Minikube cluster
        start_minikube
        configure_kubectl
        enable_addons
        verify_setup
    fi

    # Configure Docker environment
    configure_docker_env

    # Display next steps
    display_next_steps

    log_success "Minikube is ready for deployment!"
    echo ""
}

# Run main function
main "$@"
