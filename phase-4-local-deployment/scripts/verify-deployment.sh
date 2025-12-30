#!/bin/bash
# Deployment Verification Script for Todo Chatbot
# Task 4.5: Create Deployment Verification Script
# Reference: specs/003-local-k8s-deployment/tasks.md
#
# This script verifies the health and functionality of the deployed Todo Chatbot with:
# - Namespace existence check
# - Pod health and readiness verification
# - Service availability check
# - PVC binding verification
# - Backend health endpoint testing (via port-forward)
# - Frontend health endpoint testing (via NodePort)
# - Color-coded status reporting
# - Smoke tests for basic functionality

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

# Status symbols
CHECK_MARK="✓"
CROSS_MARK="✗"
WARNING_MARK="⚠"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[${CHECK_MARK}]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[${WARNING_MARK}]${NC} $1"
}

log_error() {
    echo -e "${RED}[${CROSS_MARK}]${NC} $1"
}

log_status() {
    local status=$1
    local message=$2
    if [ "$status" = "pass" ]; then
        log_success "$message"
    elif [ "$status" = "fail" ]; then
        log_error "$message"
    else
        log_warning "$message"
    fi
}

# Verification configuration
NAMESPACE="${NAMESPACE:-todo-chatbot}"
TEST_BACKEND_HEALTH="${TEST_BACKEND_HEALTH:-true}"
TEST_FRONTEND_HEALTH="${TEST_FRONTEND_HEALTH:-true}"
RUN_SMOKE_TESTS="${RUN_SMOKE_TESTS:-true}"
VERBOSE="${VERBOSE:-false}"

# Track overall status
ALL_CHECKS_PASSED=true

# Mark check as failed
mark_failed() {
    ALL_CHECKS_PASSED=false
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    echo ""

    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        echo "Please install kubectl and try again"
        exit 1
    fi
    log_success "kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

    # Check kubectl context
    CURRENT_CONTEXT=$(kubectl config current-context)
    log_info "Current kubectl context: $CURRENT_CONTEXT"

    # Check if jq is installed (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        log_warning "jq is not installed (some checks may be limited)"
        log_info "Install jq for better reporting: https://stedolan.github.io/jq/"
    else
        log_success "jq is installed"
    fi

    log_success "Prerequisites met"
    echo ""
}

# Check namespace exists
check_namespace() {
    log_info "Checking namespace..."
    echo ""

    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        log_success "Namespace '$NAMESPACE' exists"

        # Show namespace details if verbose
        if [ "$VERBOSE" = "true" ]; then
            kubectl describe namespace "$NAMESPACE"
        fi
        return 0
    else
        log_error "Namespace '$NAMESPACE' does not exist"
        mark_failed
        return 1
    fi
    echo ""
}

# Check pods status
check_pods() {
    log_info "Checking pods status..."
    echo ""

    # Check if any pods exist
    POD_COUNT=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)

    if [ "$POD_COUNT" -eq 0 ]; then
        log_error "No pods found in namespace '$NAMESPACE'"
        mark_failed
        return 1
    fi

    # Check backend pods
    log_info "Backend pods:"
    BACKEND_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=todo-chatbot-backend --no-headers 2>/dev/null)

    if [ -z "$BACKEND_PODS" ]; then
        log_error "No backend pods found"
        mark_failed
    else
        echo "$BACKEND_PODS" | while read -r line; do
            POD_NAME=$(echo "$line" | awk '{print $1}')
            POD_STATUS=$(echo "$line" | awk '{print $3}')
            POD_READY=$(echo "$line" | awk '{print $2}')

            if [ "$POD_STATUS" = "Running" ] && echo "$POD_READY" | grep -q "^[1-9]/[1-9]"; then
                log_success "$POD_NAME - $POD_STATUS ($POD_READY)"
            else
                log_error "$POD_NAME - $POD_STATUS ($POD_READY)"
                mark_failed
            fi
        done
    fi
    echo ""

    # Check frontend pods
    log_info "Frontend pods:"
    FRONTEND_PODS=$(kubectl get pods -n "$NAMESPACE" -l app=todo-chatbot-frontend --no-headers 2>/dev/null)

    if [ -z "$FRONTEND_PODS" ]; then
        log_error "No frontend pods found"
        mark_failed
    else
        echo "$FRONTEND_PODS" | while read -r line; do
            POD_NAME=$(echo "$line" | awk '{print $1}')
            POD_STATUS=$(echo "$line" | awk '{print $3}')
            POD_READY=$(echo "$line" | awk '{print $2}')

            if [ "$POD_STATUS" = "Running" ] && echo "$POD_READY" | grep -q "^[1-9]/[1-9]"; then
                log_success "$POD_NAME - $POD_STATUS ($POD_READY)"
            else
                log_error "$POD_NAME - $POD_STATUS ($POD_READY)"
                mark_failed
            fi
        done
    fi
    echo ""

    # Show all pods summary
    log_info "All pods in namespace '$NAMESPACE':"
    kubectl get pods -n "$NAMESPACE"
    echo ""
}

# Check services
check_services() {
    log_info "Checking services..."
    echo ""

    # Check backend service
    if kubectl get service todo-chatbot-backend -n "$NAMESPACE" &> /dev/null; then
        log_success "Backend service exists"

        # Check service has endpoints
        BACKEND_ENDPOINTS=$(kubectl get endpoints todo-chatbot-backend -n "$NAMESPACE" --no-headers 2>/dev/null | awk '{print $2}')
        if [ -n "$BACKEND_ENDPOINTS" ] && [ "$BACKEND_ENDPOINTS" != "<none>" ]; then
            log_success "Backend service has endpoints: $BACKEND_ENDPOINTS"
        else
            log_error "Backend service has no endpoints"
            mark_failed
        fi
    else
        log_error "Backend service does not exist"
        mark_failed
    fi
    echo ""

    # Check frontend service
    if kubectl get service todo-chatbot-frontend -n "$NAMESPACE" &> /dev/null; then
        log_success "Frontend service exists"

        # Check service has endpoints
        FRONTEND_ENDPOINTS=$(kubectl get endpoints todo-chatbot-frontend -n "$NAMESPACE" --no-headers 2>/dev/null | awk '{print $2}')
        if [ -n "$FRONTEND_ENDPOINTS" ] && [ "$FRONTEND_ENDPOINTS" != "<none>" ]; then
            log_success "Frontend service has endpoints: $FRONTEND_ENDPOINTS"
        else
            log_error "Frontend service has no endpoints"
            mark_failed
        fi

        # Get NodePort
        NODE_PORT=$(kubectl get service todo-chatbot-frontend -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
        if [ -n "$NODE_PORT" ]; then
            log_success "Frontend NodePort: $NODE_PORT"
        fi
    else
        log_error "Frontend service does not exist"
        mark_failed
    fi
    echo ""

    # Show all services
    log_info "All services in namespace '$NAMESPACE':"
    kubectl get services -n "$NAMESPACE"
    echo ""
}

# Check PVC
check_pvc() {
    log_info "Checking PersistentVolumeClaim..."
    echo ""

    if kubectl get pvc todo-chatbot-data -n "$NAMESPACE" &> /dev/null; then
        PVC_STATUS=$(kubectl get pvc todo-chatbot-data -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null)

        if [ "$PVC_STATUS" = "Bound" ]; then
            log_success "PVC 'todo-chatbot-data' is Bound"

            # Show PVC details
            PVC_SIZE=$(kubectl get pvc todo-chatbot-data -n "$NAMESPACE" -o jsonpath='{.status.capacity.storage}' 2>/dev/null)
            PVC_VOLUME=$(kubectl get pvc todo-chatbot-data -n "$NAMESPACE" -o jsonpath='{.spec.volumeName}' 2>/dev/null)
            log_info "PVC size: $PVC_SIZE, Volume: $PVC_VOLUME"
        else
            log_error "PVC 'todo-chatbot-data' is not Bound (status: $PVC_STATUS)"
            mark_failed
        fi
    else
        log_error "PVC 'todo-chatbot-data' does not exist"
        mark_failed
    fi
    echo ""
}

# Test backend health endpoint
test_backend_health() {
    if [ "$TEST_BACKEND_HEALTH" != "true" ]; then
        log_info "Skipping backend health test (TEST_BACKEND_HEALTH=false)"
        return 0
    fi

    log_info "Testing backend health endpoint..."
    echo ""

    # Get a backend pod
    BACKEND_POD=$(kubectl get pods -n "$NAMESPACE" -l app=todo-chatbot-backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -z "$BACKEND_POD" ]; then
        log_error "No backend pod found for health test"
        mark_failed
        return 1
    fi

    log_info "Testing health endpoint on pod: $BACKEND_POD"

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        log_warning "curl not installed - skipping health endpoint test"
        return 0
    fi

    # Port-forward in background
    kubectl port-forward -n "$NAMESPACE" "$BACKEND_POD" 8001:8001 &> /dev/null &
    PORT_FORWARD_PID=$!

    # Wait for port-forward to establish
    sleep 3

    # Test health endpoint
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/health 2>/dev/null || echo "000")

    # Kill port-forward
    kill $PORT_FORWARD_PID &> /dev/null || true
    wait $PORT_FORWARD_PID 2>/dev/null || true

    if [ "$HTTP_CODE" = "200" ]; then
        log_success "Backend health endpoint returned 200 OK"
    else
        log_error "Backend health endpoint returned $HTTP_CODE (expected 200)"
        mark_failed
    fi
    echo ""
}

# Test frontend health endpoint
test_frontend_health() {
    if [ "$TEST_FRONTEND_HEALTH" != "true" ]; then
        log_info "Skipping frontend health test (TEST_FRONTEND_HEALTH=false)"
        return 0
    fi

    log_info "Testing frontend health endpoint..."
    echo ""

    # Get Minikube IP and NodePort
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        MINIKUBE_IP=$(minikube ip 2>/dev/null)
        NODE_PORT=$(kubectl get service todo-chatbot-frontend -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)

        if [ -n "$MINIKUBE_IP" ] && [ -n "$NODE_PORT" ]; then
            FRONTEND_URL="http://${MINIKUBE_IP}:${NODE_PORT}"
            log_info "Testing frontend at: $FRONTEND_URL"

            # Check if curl is available
            if ! command -v curl &> /dev/null; then
                log_warning "curl not installed - skipping frontend health test"
                return 0
            fi

            # Test frontend root
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>/dev/null || echo "000")

            if [ "$HTTP_CODE" = "200" ]; then
                log_success "Frontend returned 200 OK"
            else
                log_error "Frontend returned $HTTP_CODE (expected 200)"
                mark_failed
            fi
        else
            log_warning "Cannot determine frontend URL (Minikube IP or NodePort not available)"
        fi
    else
        log_warning "Minikube not available - skipping frontend health test"
        log_info "Test manually via: kubectl port-forward -n $NAMESPACE service/todo-chatbot-frontend 3000:80"
    fi
    echo ""
}

# Run smoke tests
run_smoke_tests() {
    if [ "$RUN_SMOKE_TESTS" != "true" ]; then
        log_info "Skipping smoke tests (RUN_SMOKE_TESTS=false)"
        return 0
    fi

    log_info "Running smoke tests..."
    echo ""

    # Get backend pod
    BACKEND_POD=$(kubectl get pods -n "$NAMESPACE" -l app=todo-chatbot-backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -z "$BACKEND_POD" ]; then
        log_error "No backend pod found for smoke tests"
        mark_failed
        return 1
    fi

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        log_warning "curl not installed - skipping smoke tests"
        return 0
    fi

    # Port-forward in background
    kubectl port-forward -n "$NAMESPACE" "$BACKEND_POD" 8001:8001 &> /dev/null &
    PORT_FORWARD_PID=$!

    # Wait for port-forward to establish
    sleep 3

    # Test 1: API docs endpoint
    log_info "Test 1: API documentation endpoint"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/docs 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "200" ]; then
        log_success "API docs endpoint accessible (HTTP $HTTP_CODE)"
    else
        log_error "API docs endpoint failed (HTTP $HTTP_CODE)"
        mark_failed
    fi

    # Test 2: Tasks endpoint (requires authentication)
    log_info "Test 2: Tasks API endpoint (unauthorized test)"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/api/tasks 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "200" ]; then
        log_success "Tasks API endpoint responding correctly (HTTP $HTTP_CODE)"
    else
        log_warning "Tasks API endpoint returned unexpected code (HTTP $HTTP_CODE)"
    fi

    # Kill port-forward
    kill $PORT_FORWARD_PID &> /dev/null || true
    wait $PORT_FORWARD_PID 2>/dev/null || true

    echo ""
}

# Display deployment summary
display_summary() {
    echo ""
    log_info "=== Deployment Verification Summary ==="
    echo ""

    # Show resource counts
    POD_COUNT=$(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    SERVICE_COUNT=$(kubectl get services -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)
    PVC_COUNT=$(kubectl get pvc -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l)

    echo "Resources in namespace '$NAMESPACE':"
    echo "  Pods:     $POD_COUNT"
    echo "  Services: $SERVICE_COUNT"
    echo "  PVCs:     $PVC_COUNT"
    echo ""

    # Show access information
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        MINIKUBE_IP=$(minikube ip 2>/dev/null)
        NODE_PORT=$(kubectl get service todo-chatbot-frontend -n "$NAMESPACE" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)

        if [ -n "$MINIKUBE_IP" ] && [ -n "$NODE_PORT" ]; then
            log_info "Access the application:"
            echo ""
            echo "  Frontend URL:"
            echo "    http://${MINIKUBE_IP}:${NODE_PORT}"
            echo ""
            echo "  Or use minikube service:"
            echo "    minikube service todo-chatbot-frontend -n $NAMESPACE"
            echo ""
        fi
    fi

    # Overall status
    if [ "$ALL_CHECKS_PASSED" = true ]; then
        echo ""
        log_success "=== ALL VERIFICATION CHECKS PASSED ==="
        echo ""
        return 0
    else
        echo ""
        log_error "=== SOME VERIFICATION CHECKS FAILED ==="
        echo ""
        log_info "Troubleshooting commands:"
        echo ""
        echo "  # View pod logs"
        echo "  kubectl logs -l app=todo-chatbot-backend -n $NAMESPACE"
        echo "  kubectl logs -l app=todo-chatbot-frontend -n $NAMESPACE"
        echo ""
        echo "  # Describe pods for details"
        echo "  kubectl describe pods -n $NAMESPACE"
        echo ""
        echo "  # Check events"
        echo "  kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'"
        echo ""
        return 1
    fi
}

# Main execution
main() {
    echo ""
    log_info "=== Todo Chatbot - Deployment Verification ==="
    echo ""

    log_info "Verification configuration:"
    echo "  Namespace:              $NAMESPACE"
    echo "  Test backend health:    $TEST_BACKEND_HEALTH"
    echo "  Test frontend health:   $TEST_FRONTEND_HEALTH"
    echo "  Run smoke tests:        $RUN_SMOKE_TESTS"
    echo "  Verbose:                $VERBOSE"
    echo ""

    # Check prerequisites
    check_prerequisites

    # Run verification checks
    check_namespace
    check_pods
    check_services
    check_pvc
    test_backend_health
    test_frontend_health
    run_smoke_tests

    # Display summary
    display_summary

    # Exit with appropriate code
    if [ "$ALL_CHECKS_PASSED" = true ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
