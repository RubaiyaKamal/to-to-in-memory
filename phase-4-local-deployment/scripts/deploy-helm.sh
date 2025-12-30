#!/bin/bash
# Helm Deployment Script for Todo Chatbot
# Task 4.4: Create Helm Deployment Script
# Reference: specs/003-local-k8s-deployment/tasks.md
#
# This script deploys the Todo Chatbot application using Helm with:
# - Prerequisites checking (helm, kubectl, Minikube, chart)
# - Secret management (prompts for API keys)
# - Values file selection (local, dev, prod)
# - Install or upgrade logic
# - Release verification
# - NOTES.txt display
# - Access information

set -e  # Exit on error
set -u  # Exit on undefined variable

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHART_PATH="$PROJECT_ROOT/phase-4-local-deployment/helm/todo-chatbot"

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

# Helm configuration
RELEASE_NAME="${RELEASE_NAME:-todo-chatbot}"
NAMESPACE="${NAMESPACE:-todo-chatbot}"
VALUES_FILE="${VALUES_FILE:-values-local.yaml}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-5m}"
DRY_RUN="${DRY_RUN:-false}"

# Print configuration
print_config() {
    echo ""
    log_info "=== Helm Deployment Configuration ==="
    echo "  Release Name:      $RELEASE_NAME"
    echo "  Namespace:         $NAMESPACE"
    echo "  Chart Path:        $CHART_PATH"
    echo "  Values File:       $VALUES_FILE"
    echo "  Wait Timeout:      $WAIT_TIMEOUT"
    echo "  Dry Run:           $DRY_RUN"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        log_error "Helm is not installed"
        echo ""
        echo "Installation instructions:"
        echo "  macOS:   brew install helm"
        echo "  Linux:   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
        echo "  Windows: choco install kubernetes-helm"
        echo ""
        echo "See: https://helm.sh/docs/intro/install/"
        exit 1
    fi
    log_success "Helm is installed: $(helm version --short)"

    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        echo "Please install kubectl and try again"
        exit 1
    fi
    log_success "kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

    # Check if Minikube is running (optional)
    if command -v minikube &> /dev/null; then
        if ! minikube status &> /dev/null; then
            log_warning "Minikube is not running"
            log_warning "Start Minikube first for local deployment"
            echo ""
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            log_success "Minikube is running"
        fi
    fi

    # Check kubectl context
    CURRENT_CONTEXT=$(kubectl config current-context)
    log_info "Current kubectl context: $CURRENT_CONTEXT"

    # Verify Helm chart exists
    if [ ! -f "$CHART_PATH/Chart.yaml" ]; then
        log_error "Helm chart not found at: $CHART_PATH"
        exit 1
    fi
    log_success "Helm chart found: $CHART_PATH"

    # Verify values file exists
    VALUES_PATH="$CHART_PATH/$VALUES_FILE"
    if [ ! -f "$VALUES_PATH" ]; then
        log_error "Values file not found: $VALUES_PATH"
        echo ""
        echo "Available values files:"
        ls -1 "$CHART_PATH"/values*.yaml 2>/dev/null || echo "  None found"
        exit 1
    fi
    log_success "Values file found: $VALUES_FILE"

    # Lint Helm chart
    log_info "Linting Helm chart..."
    if helm lint "$CHART_PATH" &> /dev/null; then
        log_success "Helm chart passed linting"
    else
        log_warning "Helm chart has linting issues"
        helm lint "$CHART_PATH"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    log_success "All prerequisites met"
    echo ""
}

# Prompt for secrets
prompt_for_secrets() {
    log_info "Configuring secrets..."
    echo ""

    # Check if secrets are already set via environment variables
    if [ -n "${OPENAI_API_KEY:-}" ] && [ -n "${BETTER_AUTH_SECRET:-}" ]; then
        log_info "Using secrets from environment variables"
        return 0
    fi

    echo ""
    log_info "Please provide the following secrets:"
    log_warning "These will be passed to Helm via --set flags"
    echo ""

    # Prompt for OPENAI_API_KEY
    if [ -z "${OPENAI_API_KEY:-}" ]; then
        read -p "OPENAI_API_KEY (or press Enter to use placeholder): " OPENAI_API_KEY
        if [ -z "$OPENAI_API_KEY" ]; then
            OPENAI_API_KEY="REPLACE_WITH_YOUR_OPENAI_API_KEY"
            log_warning "Using placeholder for OPENAI_API_KEY"
        fi
    fi

    # Prompt for BETTER_AUTH_SECRET
    if [ -z "${BETTER_AUTH_SECRET:-}" ]; then
        read -p "BETTER_AUTH_SECRET (min 32 chars, or press Enter to generate): " BETTER_AUTH_SECRET
        if [ -z "$BETTER_AUTH_SECRET" ]; then
            # Generate a random 32-character secret
            BETTER_AUTH_SECRET=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
            log_info "Generated BETTER_AUTH_SECRET: ${BETTER_AUTH_SECRET:0:8}..."
        fi
    fi

    export OPENAI_API_KEY
    export BETTER_AUTH_SECRET
    echo ""
}

# Check if release exists
check_release_exists() {
    if helm list -n "$NAMESPACE" 2>/dev/null | grep -q "^$RELEASE_NAME"; then
        return 0  # Release exists
    else
        return 1  # Release does not exist
    fi
}

# Install or upgrade Helm release
deploy_helm_release() {
    local action=""
    local helm_cmd=""

    if check_release_exists; then
        action="Upgrading"
        helm_cmd="upgrade"
        log_info "Existing release found. Upgrading..."
    else
        action="Installing"
        helm_cmd="install"
        log_info "No existing release found. Installing..."
    fi

    echo ""
    log_info "$action Helm release..."

    # Build Helm command
    HELM_COMMAND="helm $helm_cmd $RELEASE_NAME $CHART_PATH"
    HELM_COMMAND="$HELM_COMMAND --namespace $NAMESPACE"
    HELM_COMMAND="$HELM_COMMAND --create-namespace"
    HELM_COMMAND="$HELM_COMMAND -f $CHART_PATH/$VALUES_FILE"
    HELM_COMMAND="$HELM_COMMAND --set secrets.OPENAI_API_KEY=\"$OPENAI_API_KEY\""
    HELM_COMMAND="$HELM_COMMAND --set secrets.BETTER_AUTH_SECRET=\"$BETTER_AUTH_SECRET\""
    HELM_COMMAND="$HELM_COMMAND --wait"
    HELM_COMMAND="$HELM_COMMAND --timeout $WAIT_TIMEOUT"

    # Add dry-run flag if enabled
    if [ "$DRY_RUN" = "true" ]; then
        HELM_COMMAND="$HELM_COMMAND --dry-run --debug"
        log_warning "DRY RUN MODE - No changes will be applied"
    fi

    # Execute Helm command
    log_info "Executing: helm $helm_cmd $RELEASE_NAME ..."
    eval "$HELM_COMMAND"

    if [ $? -eq 0 ]; then
        if [ "$DRY_RUN" = "false" ]; then
            log_success "Helm release $action successfully"
        else
            log_success "Dry run completed successfully"
        fi
    else
        log_error "Helm $helm_cmd failed"
        exit 1
    fi
    echo ""
}

# Verify deployment
verify_deployment() {
    if [ "$DRY_RUN" = "true" ]; then
        log_info "Skipping verification (dry run mode)"
        return 0
    fi

    log_info "Verifying deployment..."
    echo ""

    # Check release status
    log_info "Helm release status:"
    helm status "$RELEASE_NAME" -n "$NAMESPACE"
    echo ""

    # Check pods
    log_info "Pod status:"
    kubectl get pods -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
    echo ""

    # Check services
    log_info "Services:"
    kubectl get services -n "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
    echo ""
}

# Display access information
display_access_info() {
    if [ "$DRY_RUN" = "true" ]; then
        return 0
    fi

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
        echo "  Or use minikube service:"
        echo "    minikube service todo-chatbot-frontend -n $NAMESPACE"
        echo ""
    fi

    log_info "Useful Helm commands:"
    echo ""
    echo "  # View release information"
    echo "  helm list -n $NAMESPACE"
    echo "  helm status $RELEASE_NAME -n $NAMESPACE"
    echo ""
    echo "  # View release values"
    echo "  helm get values $RELEASE_NAME -n $NAMESPACE"
    echo ""
    echo "  # View release manifest"
    echo "  helm get manifest $RELEASE_NAME -n $NAMESPACE"
    echo ""
    echo "  # View release history"
    echo "  helm history $RELEASE_NAME -n $NAMESPACE"
    echo ""
    echo "  # Rollback to previous version"
    echo "  helm rollback $RELEASE_NAME -n $NAMESPACE"
    echo ""
    echo "  # Upgrade with new values"
    echo "  helm upgrade $RELEASE_NAME $CHART_PATH -n $NAMESPACE \\"
    echo "    -f $CHART_PATH/$VALUES_FILE \\"
    echo "    --set secrets.OPENAI_API_KEY=\"...\" \\"
    echo "    --set secrets.BETTER_AUTH_SECRET=\"...\""
    echo ""
    echo "  # Uninstall release"
    echo "  helm uninstall $RELEASE_NAME -n $NAMESPACE"
    echo ""

    log_info "Useful kubectl commands:"
    echo ""
    echo "  # View pods"
    echo "  kubectl get pods -n $NAMESPACE"
    echo ""
    echo "  # View logs"
    echo "  kubectl logs -f -l app=todo-chatbot-backend -n $NAMESPACE"
    echo "  kubectl logs -f -l app=todo-chatbot-frontend -n $NAMESPACE"
    echo ""
}

# Main execution
main() {
    echo ""
    log_info "=== Todo Chatbot - Helm Deployment ==="
    echo ""

    # Print configuration
    print_config

    # Check prerequisites
    check_prerequisites

    # Prompt for secrets (unless already set)
    prompt_for_secrets

    # Deploy Helm release (install or upgrade)
    deploy_helm_release

    # Verify deployment
    verify_deployment

    # Display access information
    display_access_info

    if [ "$DRY_RUN" = "false" ]; then
        log_success "Application deployed successfully with Helm!"
    else
        log_success "Dry run completed successfully!"
    fi
    echo ""
}

# Run main function
main "$@"
