#!/bin/bash
# Kubectl Deployment Script for Todo Chatbot
# Task 4.3: Create kubectl Deployment Script
# Reference: specs/003-local-k8s-deployment/tasks.md
#
# This script deploys the Todo Chatbot application using kubectl and Kustomize with:
# - Prerequisites checking (kubectl, Minikube, images)
# - Secret management (prompts for API keys)
# - Kustomize-based deployment
# - Resource waiting and verification
# - Pod health checking
# - Access information display

set -e  # Exit on error
set -u  # Exit on undefined variable

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
K8S_BASE_DIR="$PROJECT_ROOT/phase-4-local-deployment/k8s/base"

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

# Deployment configuration
NAMESPACE="${NAMESPACE:-todo-chatbot}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-300}"
SKIP_IMAGES_CHECK="${SKIP_IMAGES_CHECK:-false}"

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        echo "Please install kubectl and try again"
        exit 1
    fi
    log_success "kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

    # Check if Minikube is running
    if command -v minikube &> /dev/null; then
        if ! minikube status &> /dev/null; then
            log_error "Minikube is not running"
            echo "Please start Minikube first:"
            echo "  ./phase-4-local-deployment/scripts/setup-minikube.sh"
            exit 1
        fi
        log_success "Minikube is running"
    else
        log_warning "Minikube not found - assuming external Kubernetes cluster"
    fi

    # Check kubectl context
    CURRENT_CONTEXT=$(kubectl config current-context)
    log_info "Current kubectl context: $CURRENT_CONTEXT"

    # Verify Kustomize manifests exist
    if [ ! -f "$K8S_BASE_DIR/kustomization.yaml" ]; then
        log_error "Kustomization file not found at: $K8S_BASE_DIR/kustomization.yaml"
        exit 1
    fi
    log_success "Kustomize manifests found"

    # Check if Docker images exist in Minikube (optional)
    if [ "$SKIP_IMAGES_CHECK" = "false" ] && command -v minikube &> /dev/null; then
        log_info "Checking Docker images in Minikube..."
        if ! minikube image ls | grep -q "todo-chatbot-backend"; then
            log_warning "Backend image not found in Minikube"
            log_warning "Build images first:"
            log_warning "  ./phase-4-local-deployment/scripts/build-images.sh"
            echo ""
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
        if ! minikube image ls | grep -q "todo-chatbot-frontend"; then
            log_warning "Frontend image not found in Minikube"
            log_warning "Build images first:"
            log_warning "  ./phase-4-local-deployment/scripts/build-images.sh"
            echo ""
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi

    log_success "All prerequisites met"
    echo ""
}

# Setup secrets
setup_secrets() {
    log_info "Setting up secrets..."

    # Check if secrets already exist
    if kubectl get secret todo-chatbot-secret -n "$NAMESPACE" &> /dev/null; then
        log_warning "Secret 'todo-chatbot-secret' already exists in namespace '$NAMESPACE'"
        echo ""
        read -p "Do you want to update the secret? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kubectl delete secret todo-chatbot-secret -n "$NAMESPACE"
            log_info "Existing secret deleted"
        else
            log_info "Using existing secret"
            echo ""
            return 0
        fi
    fi

    echo ""
    log_info "Please provide the following secrets:"
    echo ""

    # Prompt for OPENAI_API_KEY
    read -p "OPENAI_API_KEY (or press Enter to use placeholder): " OPENAI_API_KEY
    if [ -z "$OPENAI_API_KEY" ]; then
        OPENAI_API_KEY="REPLACE_WITH_YOUR_OPENAI_API_KEY"
        log_warning "Using placeholder for OPENAI_API_KEY"
    fi

    # Prompt for BETTER_AUTH_SECRET
    read -p "BETTER_AUTH_SECRET (min 32 chars, or press Enter to generate): " BETTER_AUTH_SECRET
    if [ -z "$BETTER_AUTH_SECRET" ]; then
        # Generate a random 32-character secret
        BETTER_AUTH_SECRET=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        log_info "Generated BETTER_AUTH_SECRET: ${BETTER_AUTH_SECRET:0:8}..."
    fi

    # Create secret using kubectl
    kubectl create secret generic todo-chatbot-secret \
        --from-literal=OPENAI_API_KEY="$OPENAI_API_KEY" \
        --from-literal=BETTER_AUTH_SECRET="$BETTER_AUTH_SECRET" \
        --namespace="$NAMESPACE" \
        --dry-run=client -o yaml | kubectl apply -f -

    if [ $? -eq 0 ]; then
        log_success "Secret created successfully"
    else
        log_error "Failed to create secret"
        exit 1
    fi
    echo ""
}

# Deploy using Kustomize
deploy_kustomize() {
    log_info "Deploying application using Kustomize..."

    cd "$K8S_BASE_DIR"

    # Apply Kustomize manifests
    kubectl apply -k .

    if [ $? -eq 0 ]; then
        log_success "Kubernetes manifests applied successfully"
    else
        log_error "Failed to apply Kubernetes manifests"
        exit 1
    fi
    echo ""
}

# Wait for deployments
wait_for_deployments() {
    log_info "Waiting for deployments to be ready (timeout: ${WAIT_TIMEOUT}s)..."

    # Wait for backend deployment
    log_info "Waiting for backend deployment..."
    kubectl wait --for=condition=available \
        --timeout="${WAIT_TIMEOUT}s" \
        deployment/todo-chatbot-backend \
        -n "$NAMESPACE"

    if [ $? -eq 0 ]; then
        log_success "Backend deployment is ready"
    else
        log_error "Backend deployment failed to become ready"
        show_pod_logs "app=todo-chatbot-backend"
        exit 1
    fi

    # Wait for frontend deployment
    log_info "Waiting for frontend deployment..."
    kubectl wait --for=condition=available \
        --timeout="${WAIT_TIMEOUT}s" \
        deployment/todo-chatbot-frontend \
        -n "$NAMESPACE"

    if [ $? -eq 0 ]; then
        log_success "Frontend deployment is ready"
    else
        log_error "Frontend deployment failed to become ready"
        show_pod_logs "app=todo-chatbot-frontend"
        exit 1
    fi
    echo ""
}

# Show pod logs on failure
show_pod_logs() {
    local label=$1
    log_error "Deployment failed. Showing pod logs:"
    echo ""

    # Get pod name
    POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l "$label" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -n "$POD_NAME" ]; then
        log_info "Pod: $POD_NAME"
        echo ""
        kubectl logs "$POD_NAME" -n "$NAMESPACE" --tail=50
        echo ""
        kubectl describe pod "$POD_NAME" -n "$NAMESPACE"
    else
        log_error "No pods found with label: $label"
    fi
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."
    echo ""

    # Check namespace
    log_info "Namespace:"
    kubectl get namespace "$NAMESPACE"
    echo ""

    # Check all resources
    log_info "All resources in namespace '$NAMESPACE':"
    kubectl get all -n "$NAMESPACE"
    echo ""

    # Check pods status
    log_info "Pod status:"
    kubectl get pods -n "$NAMESPACE" -o wide
    echo ""

    # Check services
    log_info "Services:"
    kubectl get services -n "$NAMESPACE"
    echo ""

    # Check PVC
    log_info "Persistent Volume Claims:"
    kubectl get pvc -n "$NAMESPACE"
    echo ""
}

# Display access information
display_access_info() {
    echo ""
    log_success "=== Deployment Complete ==="
    echo ""

    # Get Minikube IP (if available)
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        MINIKUBE_IP=$(minikube ip 2>/dev/null)

        log_info "Access the application:"
        echo ""
        echo "  Frontend URL:"
        echo "    http://${MINIKUBE_IP}:30080"
        echo ""
        echo "  Backend API:"
        echo "    http://${MINIKUBE_IP}:8001"
        echo ""
        echo "  Or use minikube service:"
        echo "    minikube service todo-chatbot-frontend -n $NAMESPACE"
        echo ""
    else
        log_info "Get service URLs:"
        echo "  kubectl get services -n $NAMESPACE"
        echo ""
    fi

    log_info "Useful commands:"
    echo ""
    echo "  # View pods"
    echo "  kubectl get pods -n $NAMESPACE"
    echo ""
    echo "  # View logs"
    echo "  kubectl logs -f deployment/todo-chatbot-backend -n $NAMESPACE"
    echo "  kubectl logs -f deployment/todo-chatbot-frontend -n $NAMESPACE"
    echo ""
    echo "  # Describe resources"
    echo "  kubectl describe deployment/todo-chatbot-backend -n $NAMESPACE"
    echo "  kubectl describe deployment/todo-chatbot-frontend -n $NAMESPACE"
    echo ""
    echo "  # Port forward (alternative access)"
    echo "  kubectl port-forward -n $NAMESPACE service/todo-chatbot-frontend 3000:80"
    echo "  kubectl port-forward -n $NAMESPACE service/todo-chatbot-backend 8001:8001"
    echo ""
    echo "  # Delete deployment"
    echo "  kubectl delete -k $K8S_BASE_DIR"
    echo ""
}

# Main execution
main() {
    echo ""
    log_info "=== Todo Chatbot - kubectl Deployment ==="
    echo ""

    # Check prerequisites
    check_prerequisites

    # Setup secrets (prompt user)
    setup_secrets

    # Deploy using Kustomize
    deploy_kustomize

    # Wait for deployments to be ready
    wait_for_deployments

    # Verify deployment
    verify_deployment

    # Display access information
    display_access_info

    log_success "Application deployed successfully!"
    echo ""
}

# Run main function
main "$@"
