#!/bin/bash
# Cleanup Script for Todo Chatbot
# Task 4.6: Create Cleanup Script
# Reference: specs/003-local-k8s-deployment/tasks.md
#
# This script removes all deployed Todo Chatbot resources with:
# - User confirmation prompts before deletion
# - Automatic detection of deployment method (Helm or kubectl)
# - Helm release uninstallation
# - Namespace deletion (removes all resources)
# - Optional Docker image removal
# - Optional Minikube stop/delete
# - Detailed cleanup status reporting

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

# Cleanup configuration
NAMESPACE="${NAMESPACE:-todo-chatbot}"
RELEASE_NAME="${RELEASE_NAME:-todo-chatbot}"
REMOVE_IMAGES="${REMOVE_IMAGES:-prompt}"  # prompt, yes, no
STOP_MINIKUBE="${STOP_MINIKUBE:-prompt}"  # prompt, yes, no
DELETE_MINIKUBE="${DELETE_MINIKUBE:-no}"  # prompt, yes, no
FORCE="${FORCE:-false}"  # Skip confirmation if true

# Track what was cleaned
CLEANUP_SUMMARY=()

# Add to cleanup summary
add_to_summary() {
    CLEANUP_SUMMARY+=("$1")
}

# Confirm cleanup
confirm_cleanup() {
    if [ "$FORCE" = "true" ]; then
        log_warning "Force mode enabled - skipping confirmation"
        return 0
    fi

    echo ""
    log_warning "This will delete the following resources:"
    echo "  - Kubernetes namespace: $NAMESPACE"
    echo "  - All pods, services, deployments in namespace"
    echo "  - Persistent Volume Claims (data will be lost)"
    if command -v helm &> /dev/null && helm list -n "$NAMESPACE" 2>/dev/null | grep -q "^$RELEASE_NAME"; then
        echo "  - Helm release: $RELEASE_NAME"
    fi
    echo ""

    read -p "Are you sure you want to continue? (yes/NO): " -r CONFIRM
    echo ""

    if [ "$CONFIRM" != "yes" ]; then
        log_info "Cleanup cancelled by user"
        exit 0
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    echo ""

    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        echo "Cannot cleanup without kubectl"
        exit 1
    fi
    log_success "kubectl is installed"

    # Check kubectl context
    CURRENT_CONTEXT=$(kubectl config current-context)
    log_info "Current kubectl context: $CURRENT_CONTEXT"

    log_success "Prerequisites met"
    echo ""
}

# Detect deployment method
detect_deployment_method() {
    log_info "Detecting deployment method..."
    echo ""

    DEPLOYMENT_METHOD="none"

    # Check for Helm deployment
    if command -v helm &> /dev/null; then
        if helm list -n "$NAMESPACE" 2>/dev/null | grep -q "^$RELEASE_NAME"; then
            DEPLOYMENT_METHOD="helm"
            log_info "Detected Helm deployment: $RELEASE_NAME"
        fi
    fi

    # Check for kubectl deployment
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        if [ "$DEPLOYMENT_METHOD" = "none" ]; then
            DEPLOYMENT_METHOD="kubectl"
            log_info "Detected kubectl deployment in namespace: $NAMESPACE"
        else
            log_info "Namespace exists: $NAMESPACE (will be deleted with Helm)"
        fi
    fi

    if [ "$DEPLOYMENT_METHOD" = "none" ]; then
        log_warning "No deployment found in namespace: $NAMESPACE"
        return 1
    fi

    echo ""
    return 0
}

# Uninstall Helm release
uninstall_helm_release() {
    log_info "Uninstalling Helm release..."
    echo ""

    if ! command -v helm &> /dev/null; then
        log_error "Helm is not installed"
        return 1
    fi

    if helm list -n "$NAMESPACE" 2>/dev/null | grep -q "^$RELEASE_NAME"; then
        log_info "Uninstalling Helm release: $RELEASE_NAME"

        helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"

        if [ $? -eq 0 ]; then
            log_success "Helm release uninstalled: $RELEASE_NAME"
            add_to_summary "Helm release '$RELEASE_NAME' uninstalled"
        else
            log_error "Failed to uninstall Helm release"
            return 1
        fi
    else
        log_warning "Helm release not found: $RELEASE_NAME"
    fi
    echo ""
}

# Delete namespace
delete_namespace() {
    log_info "Deleting namespace..."
    echo ""

    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        log_info "Deleting namespace: $NAMESPACE"
        log_warning "This will delete all resources in the namespace"

        # Show resources before deletion
        log_info "Resources to be deleted:"
        kubectl get all -n "$NAMESPACE" 2>/dev/null || log_info "  No resources found"
        echo ""

        kubectl delete namespace "$NAMESPACE"

        if [ $? -eq 0 ]; then
            log_success "Namespace deleted: $NAMESPACE"
            add_to_summary "Namespace '$NAMESPACE' deleted"
        else
            log_error "Failed to delete namespace"
            return 1
        fi
    else
        log_warning "Namespace does not exist: $NAMESPACE"
    fi
    echo ""
}

# Remove Docker images
remove_docker_images() {
    local should_remove="$REMOVE_IMAGES"

    if [ "$should_remove" = "prompt" ]; then
        echo ""
        read -p "Remove Docker images? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            should_remove="yes"
        else
            should_remove="no"
        fi
    fi

    if [ "$should_remove" != "yes" ]; then
        log_info "Skipping Docker image removal"
        return 0
    fi

    log_info "Removing Docker images..."
    echo ""

    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        log_warning "Docker is not installed - skipping image removal"
        return 0
    fi

    # Remove backend image
    if docker images | grep -q "todo-chatbot-backend"; then
        log_info "Removing backend image..."
        docker rmi todo-chatbot-backend:latest --force 2>/dev/null || log_warning "Failed to remove backend image"
        log_success "Backend image removed"
        add_to_summary "Docker image 'todo-chatbot-backend:latest' removed"
    else
        log_info "Backend image not found"
    fi

    # Remove frontend image
    if docker images | grep -q "todo-chatbot-frontend"; then
        log_info "Removing frontend image..."
        docker rmi todo-chatbot-frontend:latest --force 2>/dev/null || log_warning "Failed to remove frontend image"
        log_success "Frontend image removed"
        add_to_summary "Docker image 'todo-chatbot-frontend:latest' removed"
    else
        log_info "Frontend image not found"
    fi

    echo ""
}

# Stop or delete Minikube
handle_minikube() {
    local should_stop="$STOP_MINIKUBE"
    local should_delete="$DELETE_MINIKUBE"

    # Check if Minikube is available
    if ! command -v minikube &> /dev/null; then
        log_info "Minikube not installed - skipping"
        return 0
    fi

    # Check if Minikube is running
    if ! minikube status &> /dev/null; then
        log_info "Minikube is not running - skipping"
        return 0
    fi

    echo ""
    log_info "Minikube Management"
    echo ""

    # Ask about stopping Minikube
    if [ "$should_stop" = "prompt" ]; then
        read -p "Stop Minikube cluster? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            should_stop="yes"
        else
            should_stop="no"
        fi
    fi

    if [ "$should_stop" = "yes" ]; then
        log_info "Stopping Minikube..."
        minikube stop

        if [ $? -eq 0 ]; then
            log_success "Minikube stopped"
            add_to_summary "Minikube cluster stopped"
        else
            log_error "Failed to stop Minikube"
        fi
        echo ""
    fi

    # Ask about deleting Minikube
    if [ "$should_delete" = "prompt" ]; then
        log_warning "Deleting Minikube will remove the entire cluster"
        read -p "Delete Minikube cluster? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            should_delete="yes"
        else
            should_delete="no"
        fi
    fi

    if [ "$should_delete" = "yes" ]; then
        log_warning "Deleting Minikube cluster..."
        minikube delete

        if [ $? -eq 0 ]; then
            log_success "Minikube cluster deleted"
            add_to_summary "Minikube cluster deleted"
        else
            log_error "Failed to delete Minikube"
        fi
        echo ""
    fi
}

# Display cleanup summary
display_summary() {
    echo ""
    log_success "=== Cleanup Complete ===="
    echo ""

    if [ ${#CLEANUP_SUMMARY[@]} -eq 0 ]; then
        log_info "No resources were cleaned up"
    else
        log_info "Cleaned up resources:"
        for item in "${CLEANUP_SUMMARY[@]}"; do
            echo "  - $item"
        done
    fi

    echo ""
    log_info "Verification commands:"
    echo ""
    echo "  # Check namespace is gone"
    echo "  kubectl get namespace $NAMESPACE"
    echo ""
    echo "  # Check Docker images"
    echo "  docker images | grep todo-chatbot"
    echo ""
    echo "  # Check Minikube status"
    echo "  minikube status"
    echo ""

    log_success "Cleanup completed successfully!"
    echo ""
}

# Main execution
main() {
    echo ""
    log_info "=== Todo Chatbot - Cleanup ===="
    echo ""

    log_info "Cleanup configuration:"
    echo "  Namespace:          $NAMESPACE"
    echo "  Helm Release:       $RELEASE_NAME"
    echo "  Remove Images:      $REMOVE_IMAGES"
    echo "  Stop Minikube:      $STOP_MINIKUBE"
    echo "  Delete Minikube:    $DELETE_MINIKUBE"
    echo "  Force (no confirm): $FORCE"
    echo ""

    # Check prerequisites
    check_prerequisites

    # Detect deployment method
    if ! detect_deployment_method; then
        log_warning "No deployment found - nothing to clean up"
        exit 0
    fi

    # Confirm cleanup
    confirm_cleanup

    # Perform cleanup based on deployment method
    if [ "$DEPLOYMENT_METHOD" = "helm" ]; then
        uninstall_helm_release
        # Namespace might still exist, so delete it
        delete_namespace
    elif [ "$DEPLOYMENT_METHOD" = "kubectl" ]; then
        delete_namespace
    fi

    # Remove Docker images (optional)
    remove_docker_images

    # Handle Minikube (optional)
    handle_minikube

    # Display summary
    display_summary
}

# Run main function
main "$@"
