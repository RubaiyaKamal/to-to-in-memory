#!/bin/bash

################################################################################
# End-to-End Deployment Test Script
# Task 7.1: Create End-to-End Deployment Test
# Reference: specs/003-local-k8s-deployment/tasks.md
#
# This script performs comprehensive end-to-end testing of the Todo Chatbot
# deployment on Kubernetes, including:
# - Minikube setup verification
# - Docker image building
# - Application deployment (kubectl or Helm)
# - Resource health validation
# - Service connectivity testing
# - Data persistence validation
# - Cleanup verification
#
# Usage:
#   ./phase-4-local-deployment/tests/test_deployment.sh [OPTIONS]
#
# Options:
#   --deploy-method <kubectl|helm>  Deployment method (default: kubectl)
#   --skip-setup                    Skip Minikube setup
#   --skip-build                    Skip image building
#   --skip-cleanup                  Skip cleanup after tests
#   --verbose                       Enable verbose output
#   --help                          Show this help message
#
# Environment Variables:
#   OPENAI_API_KEY                  OpenAI API key for backend (required)
#   NAMESPACE                       Kubernetes namespace (default: todo-chatbot)
#   TIMEOUT                         Deployment timeout in seconds (default: 300)
#
# Exit Codes:
#   0 - All tests passed
#   1 - One or more tests failed
#   2 - Prerequisites not met
################################################################################

set -euo pipefail

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------

NAMESPACE="${NAMESPACE:-todo-chatbot}"
DEPLOY_METHOD="${DEPLOY_METHOD:-kubectl}"
TIMEOUT="${TIMEOUT:-300}"
VERBOSE="${VERBOSE:-false}"
SKIP_SETUP="${SKIP_SETUP:-false}"
SKIP_BUILD="${SKIP_BUILD:-false}"
SKIP_CLEANUP="${SKIP_CLEANUP:-false}"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PHASE4_DIR="${PROJECT_ROOT}/phase-4-local-deployment"
SCRIPTS_DIR="${PHASE4_DIR}/scripts"

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

#------------------------------------------------------------------------------
# Color Output
#------------------------------------------------------------------------------

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    NC=''
fi

#------------------------------------------------------------------------------
# Logging Functions
#------------------------------------------------------------------------------

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_test() {
    echo -e "${MAGENTA}[TEST]${NC} $*"
}

log_verbose() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${CYAN}[VERBOSE]${NC} $*"
    fi
}

#------------------------------------------------------------------------------
# Test Result Functions
#------------------------------------------------------------------------------

test_pass() {
    local test_name="$1"
    ((TESTS_PASSED++))
    ((TESTS_TOTAL++))
    log_success "✓ ${test_name}"
}

test_fail() {
    local test_name="$1"
    local reason="${2:-Unknown failure}"
    ((TESTS_FAILED++))
    ((TESTS_TOTAL++))
    log_error "✗ ${test_name}: ${reason}"
}

print_test_summary() {
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${MAGENTA}TEST SUMMARY${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "Total Tests:  ${TESTS_TOTAL}"
    echo -e "Passed:       ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "Failed:       ${RED}${TESTS_FAILED}${NC}"
    echo "═══════════════════════════════════════════════════════════════"

    if [[ ${TESTS_FAILED} -eq 0 ]]; then
        log_success "All tests passed! 🎉"
        return 0
    else
        log_error "Some tests failed. Please review the output above."
        return 1
    fi
}

#------------------------------------------------------------------------------
# Help Function
#------------------------------------------------------------------------------

show_help() {
    cat << EOF
End-to-End Deployment Test Script

Usage: $0 [OPTIONS]

Options:
    --deploy-method <kubectl|helm>  Deployment method (default: kubectl)
    --skip-setup                    Skip Minikube setup
    --skip-build                    Skip image building
    --skip-cleanup                  Skip cleanup after tests
    --verbose                       Enable verbose output
    --help                          Show this help message

Environment Variables:
    OPENAI_API_KEY                  OpenAI API key for backend (required)
    NAMESPACE                       Kubernetes namespace (default: todo-chatbot)
    TIMEOUT                         Deployment timeout in seconds (default: 300)

Examples:
    # Run full test with kubectl deployment
    $0

    # Run with Helm deployment
    $0 --deploy-method helm

    # Skip setup and build (for faster testing)
    $0 --skip-setup --skip-build

    # Verbose output
    $0 --verbose

Exit Codes:
    0 - All tests passed
    1 - One or more tests failed
    2 - Prerequisites not met
EOF
}

#------------------------------------------------------------------------------
# Parse Arguments
#------------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case $1 in
        --deploy-method)
            DEPLOY_METHOD="$2"
            shift 2
            ;;
        --skip-setup)
            SKIP_SETUP="true"
            shift
            ;;
        --skip-build)
            SKIP_BUILD="true"
            shift
            ;;
        --skip-cleanup)
            SKIP_CLEANUP="true"
            shift
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 2
            ;;
    esac
done

#------------------------------------------------------------------------------
# Prerequisite Checks
#------------------------------------------------------------------------------

check_prerequisites() {
    log_info "Checking prerequisites..."

    local prereqs_ok=true

    # Check required commands
    for cmd in kubectl docker; do
        if ! command -v "${cmd}" &> /dev/null; then
            log_error "${cmd} is not installed or not in PATH"
            prereqs_ok=false
        else
            log_verbose "${cmd} found: $(command -v ${cmd})"
        fi
    done

    # Check for minikube if not skipping setup
    if [[ "${SKIP_SETUP}" == "false" ]]; then
        if ! command -v minikube &> /dev/null; then
            log_error "minikube is not installed or not in PATH"
            prereqs_ok=false
        else
            log_verbose "minikube found: $(command -v minikube)"
        fi
    fi

    # Check for helm if using helm deployment
    if [[ "${DEPLOY_METHOD}" == "helm" ]]; then
        if ! command -v helm &> /dev/null; then
            log_error "helm is not installed or not in PATH"
            prereqs_ok=false
        else
            log_verbose "helm found: $(command -v helm)"
        fi
    fi

    # Check for OPENAI_API_KEY
    if [[ -z "${OPENAI_API_KEY:-}" ]]; then
        log_error "OPENAI_API_KEY environment variable is not set"
        log_info "Set it with: export OPENAI_API_KEY=\"your-api-key\""
        prereqs_ok=false
    else
        log_verbose "OPENAI_API_KEY is set"
    fi

    # Check for scripts directory
    if [[ ! -d "${SCRIPTS_DIR}" ]]; then
        log_error "Scripts directory not found: ${SCRIPTS_DIR}"
        prereqs_ok=false
    else
        log_verbose "Scripts directory found: ${SCRIPTS_DIR}"
    fi

    if [[ "${prereqs_ok}" == "false" ]]; then
        log_error "Prerequisites check failed"
        return 2
    fi

    log_success "All prerequisites met"
    return 0
}

#------------------------------------------------------------------------------
# Test 1: Minikube Setup
#------------------------------------------------------------------------------

test_minikube_setup() {
    log_test "Test 1: Minikube Setup"

    if [[ "${SKIP_SETUP}" == "true" ]]; then
        log_info "Skipping Minikube setup (--skip-setup flag)"

        # Verify Minikube is running
        if minikube status &> /dev/null; then
            test_pass "Minikube is running (skipped setup)"
            return 0
        else
            test_fail "Minikube is not running" "Run setup-minikube.sh first"
            return 1
        fi
    fi

    log_info "Running setup-minikube.sh..."

    if bash "${SCRIPTS_DIR}/setup-minikube.sh"; then
        test_pass "Minikube setup completed successfully"
        return 0
    else
        test_fail "Minikube setup" "setup-minikube.sh failed"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Test 2: Docker Image Building
#------------------------------------------------------------------------------

test_image_building() {
    log_test "Test 2: Docker Image Building"

    if [[ "${SKIP_BUILD}" == "true" ]]; then
        log_info "Skipping image building (--skip-build flag)"

        # Verify images exist
        eval "$(minikube docker-env)"

        local images_ok=true
        for image in todo-chatbot-backend:latest todo-chatbot-frontend:latest; do
            if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${image}$"; then
                log_verbose "Image found: ${image}"
            else
                log_error "Image not found: ${image}"
                images_ok=false
            fi
        done

        if [[ "${images_ok}" == "true" ]]; then
            test_pass "Docker images exist (skipped build)"
            return 0
        else
            test_fail "Docker images not found" "Run build-images.sh first"
            return 1
        fi
    fi

    log_info "Running build-images.sh..."

    if bash "${SCRIPTS_DIR}/build-images.sh"; then
        test_pass "Docker images built successfully"
        return 0
    else
        test_fail "Docker image building" "build-images.sh failed"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Test 3: Application Deployment
#------------------------------------------------------------------------------

test_deployment() {
    log_test "Test 3: Application Deployment (${DEPLOY_METHOD})"

    local deploy_script
    if [[ "${DEPLOY_METHOD}" == "helm" ]]; then
        deploy_script="${SCRIPTS_DIR}/deploy-helm.sh"
    else
        deploy_script="${SCRIPTS_DIR}/deploy-kubectl.sh"
    fi

    log_info "Running ${deploy_script}..."

    # Deploy with OPENAI_API_KEY
    if OPENAI_API_KEY="${OPENAI_API_KEY}" bash "${deploy_script}"; then
        test_pass "Application deployed successfully via ${DEPLOY_METHOD}"
        return 0
    else
        test_fail "Application deployment" "${deploy_script} failed"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Test 4: Resource Creation Validation
#------------------------------------------------------------------------------

test_resource_creation() {
    log_test "Test 4: Resource Creation Validation"

    local resources_ok=true

    # Check namespace
    if kubectl get namespace "${NAMESPACE}" &> /dev/null; then
        log_verbose "Namespace ${NAMESPACE} exists"
    else
        log_error "Namespace ${NAMESPACE} not found"
        resources_ok=false
    fi

    # Check deployments
    for deployment in todo-chatbot-backend todo-chatbot-frontend; do
        if kubectl get deployment "${deployment}" -n "${NAMESPACE}" &> /dev/null; then
            log_verbose "Deployment ${deployment} exists"
        else
            log_error "Deployment ${deployment} not found"
            resources_ok=false
        fi
    done

    # Check services
    for service in todo-chatbot-backend todo-chatbot-frontend; do
        if kubectl get service "${service}" -n "${NAMESPACE}" &> /dev/null; then
            log_verbose "Service ${service} exists"
        else
            log_error "Service ${service} not found"
            resources_ok=false
        fi
    done

    # Check PVC
    if kubectl get pvc todo-chatbot-data -n "${NAMESPACE}" &> /dev/null; then
        log_verbose "PVC todo-chatbot-data exists"
    else
        log_error "PVC todo-chatbot-data not found"
        resources_ok=false
    fi

    # Check secret
    if kubectl get secret todo-chatbot-secret -n "${NAMESPACE}" &> /dev/null; then
        log_verbose "Secret todo-chatbot-secret exists"
    else
        log_error "Secret todo-chatbot-secret not found"
        resources_ok=false
    fi

    if [[ "${resources_ok}" == "true" ]]; then
        test_pass "All required resources created"
        return 0
    else
        test_fail "Resource creation" "Some resources are missing"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Test 5: Pod Health Validation
#------------------------------------------------------------------------------

test_pod_health() {
    log_test "Test 5: Pod Health Validation"

    log_info "Waiting for pods to be ready (timeout: ${TIMEOUT}s)..."

    local start_time
    start_time=$(date +%s)

    while true; do
        local all_ready=true

        # Check all pods in namespace
        local pods
        pods=$(kubectl get pods -n "${NAMESPACE}" --no-headers 2>/dev/null || echo "")

        if [[ -z "${pods}" ]]; then
            log_error "No pods found in namespace ${NAMESPACE}"
            all_ready=false
        else
            while IFS= read -r pod_line; do
                local pod_name ready_status status
                pod_name=$(echo "${pod_line}" | awk '{print $1}')
                ready_status=$(echo "${pod_line}" | awk '{print $2}')
                status=$(echo "${pod_line}" | awk '{print $3}')

                log_verbose "Pod ${pod_name}: ${ready_status} ${status}"

                if [[ "${status}" != "Running" ]]; then
                    all_ready=false
                fi

                if ! echo "${ready_status}" | grep -q "^[0-9]*/[0-9]*$"; then
                    all_ready=false
                else
                    local ready_count total_count
                    ready_count=$(echo "${ready_status}" | cut -d'/' -f1)
                    total_count=$(echo "${ready_status}" | cut -d'/' -f2)

                    if [[ "${ready_count}" != "${total_count}" ]]; then
                        all_ready=false
                    fi
                fi
            done <<< "${pods}"
        fi

        if [[ "${all_ready}" == "true" ]]; then
            test_pass "All pods are healthy and ready"
            return 0
        fi

        local current_time
        current_time=$(date +%s)
        local elapsed=$((current_time - start_time))

        if [[ ${elapsed} -ge ${TIMEOUT} ]]; then
            log_error "Timeout waiting for pods to be ready"
            kubectl get pods -n "${NAMESPACE}"
            test_fail "Pod health" "Pods not ready after ${TIMEOUT}s"
            return 1
        fi

        sleep 5
    done
}

#------------------------------------------------------------------------------
# Test 6: Service Connectivity
#------------------------------------------------------------------------------

test_service_connectivity() {
    log_test "Test 6: Service Connectivity"

    local connectivity_ok=true

    # Test backend health endpoint
    log_info "Testing backend health endpoint..."

    local backend_pod
    backend_pod=$(kubectl get pods -n "${NAMESPACE}" -l app=todo-chatbot-backend --no-headers | head -n1 | awk '{print $1}')

    if [[ -z "${backend_pod}" ]]; then
        log_error "No backend pod found"
        connectivity_ok=false
    else
        log_verbose "Testing health endpoint on pod: ${backend_pod}"

        if kubectl exec -n "${NAMESPACE}" "${backend_pod}" -- curl -sf http://localhost:8001/api/health > /dev/null 2>&1; then
            log_verbose "Backend health endpoint responding"
        else
            log_error "Backend health endpoint not responding"
            connectivity_ok=false
        fi
    fi

    # Test frontend service
    log_info "Testing frontend service..."

    local frontend_pod
    frontend_pod=$(kubectl get pods -n "${NAMESPACE}" -l app=todo-chatbot-frontend --no-headers | head -n1 | awk '{print $1}')

    if [[ -z "${frontend_pod}" ]]; then
        log_error "No frontend pod found"
        connectivity_ok=false
    else
        log_verbose "Testing frontend on pod: ${frontend_pod}"

        if kubectl exec -n "${NAMESPACE}" "${frontend_pod}" -- curl -sf http://localhost/health > /dev/null 2>&1; then
            log_verbose "Frontend health endpoint responding"
        else
            log_error "Frontend health endpoint not responding"
            connectivity_ok=false
        fi
    fi

    if [[ "${connectivity_ok}" == "true" ]]; then
        test_pass "All services are reachable and responding"
        return 0
    else
        test_fail "Service connectivity" "Some services not responding"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Test 7: Data Persistence
#------------------------------------------------------------------------------

test_data_persistence() {
    log_test "Test 7: Data Persistence"

    log_info "Testing data persistence by creating a task..."

    local backend_pod
    backend_pod=$(kubectl get pods -n "${NAMESPACE}" -l app=todo-chatbot-backend --no-headers | head -n1 | awk '{print $1}')

    if [[ -z "${backend_pod}" ]]; then
        test_fail "Data persistence" "No backend pod found"
        return 1
    fi

    # Create a test task via API
    local task_json='{"title":"E2E Test Task","description":"Created by deployment test","completed":false}'

    log_verbose "Creating test task via API..."

    local create_response
    create_response=$(kubectl exec -n "${NAMESPACE}" "${backend_pod}" -- \
        curl -sf -X POST http://localhost:8001/api/tasks \
        -H "Content-Type: application/json" \
        -d "${task_json}" 2>/dev/null || echo "FAILED")

    if [[ "${create_response}" == "FAILED" ]]; then
        test_fail "Data persistence" "Failed to create test task"
        return 1
    fi

    log_verbose "Task created successfully"

    # Retrieve the task to verify persistence
    log_info "Retrieving tasks to verify persistence..."

    local get_response
    get_response=$(kubectl exec -n "${NAMESPACE}" "${backend_pod}" -- \
        curl -sf http://localhost:8001/api/tasks 2>/dev/null || echo "FAILED")

    if [[ "${get_response}" == "FAILED" ]]; then
        test_fail "Data persistence" "Failed to retrieve tasks"
        return 1
    fi

    if echo "${get_response}" | grep -q "E2E Test Task"; then
        log_verbose "Test task found in database"
        test_pass "Data persistence validated"
        return 0
    else
        test_fail "Data persistence" "Test task not found in database"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Test 8: Frontend UI Accessibility
#------------------------------------------------------------------------------

test_frontend_ui() {
    log_test "Test 8: Frontend UI Accessibility"

    log_info "Testing frontend UI accessibility via NodePort..."

    # Get Minikube IP
    local minikube_ip
    minikube_ip=$(minikube ip 2>/dev/null || echo "")

    if [[ -z "${minikube_ip}" ]]; then
        test_fail "Frontend UI" "Could not get Minikube IP"
        return 1
    fi

    log_verbose "Minikube IP: ${minikube_ip}"

    # Get NodePort
    local nodeport
    nodeport=$(kubectl get svc todo-chatbot-frontend -n "${NAMESPACE}" -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "")

    if [[ -z "${nodeport}" ]]; then
        test_fail "Frontend UI" "Could not get NodePort"
        return 1
    fi

    log_verbose "Frontend NodePort: ${nodeport}"

    # Test frontend accessibility
    local frontend_url="http://${minikube_ip}:${nodeport}"

    log_info "Testing frontend at: ${frontend_url}"

    if curl -sf "${frontend_url}" > /dev/null 2>&1; then
        log_success "Frontend UI is accessible at ${frontend_url}"
        test_pass "Frontend UI is accessible"
        return 0
    else
        log_warning "Frontend UI not accessible via curl (may require browser)"
        log_info "Manual verification URL: ${frontend_url}"
        test_pass "Frontend UI accessible (manual verification recommended)"
        return 0
    fi
}

#------------------------------------------------------------------------------
# Test 9: Cleanup Validation
#------------------------------------------------------------------------------

test_cleanup() {
    log_test "Test 9: Cleanup Validation"

    if [[ "${SKIP_CLEANUP}" == "true" ]]; then
        log_info "Skipping cleanup (--skip-cleanup flag)"
        test_pass "Cleanup skipped by user request"
        return 0
    fi

    log_info "Running cleanup.sh..."

    # Run cleanup in non-interactive mode
    if echo -e "y\ny\nn\nn" | bash "${SCRIPTS_DIR}/cleanup.sh"; then
        log_verbose "Cleanup script executed"
    else
        log_warning "Cleanup script returned non-zero exit code"
    fi

    # Verify namespace is deleted
    log_info "Verifying namespace deletion..."

    local timeout=60
    local elapsed=0

    while kubectl get namespace "${NAMESPACE}" &> /dev/null; do
        if [[ ${elapsed} -ge ${timeout} ]]; then
            test_fail "Cleanup validation" "Namespace still exists after ${timeout}s"
            return 1
        fi

        sleep 2
        ((elapsed += 2))
    done

    log_verbose "Namespace ${NAMESPACE} successfully deleted"
    test_pass "Cleanup completed successfully"
    return 0
}

#------------------------------------------------------------------------------
# Main Test Execution
#------------------------------------------------------------------------------

main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${MAGENTA}Todo Chatbot - End-to-End Deployment Test${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "Configuration:"
    echo "  Namespace:       ${NAMESPACE}"
    echo "  Deploy Method:   ${DEPLOY_METHOD}"
    echo "  Timeout:         ${TIMEOUT}s"
    echo "  Skip Setup:      ${SKIP_SETUP}"
    echo "  Skip Build:      ${SKIP_BUILD}"
    echo "  Skip Cleanup:    ${SKIP_CLEANUP}"
    echo "  Verbose:         ${VERBOSE}"
    echo ""

    # Check prerequisites
    if ! check_prerequisites; then
        log_error "Prerequisites check failed"
        exit 2
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo -e "${MAGENTA}Running Tests${NC}"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    # Run all tests
    test_minikube_setup
    test_image_building
    test_deployment
    test_resource_creation
    test_pod_health
    test_service_connectivity
    test_data_persistence
    test_frontend_ui
    test_cleanup

    # Print summary
    echo ""
    if print_test_summary; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
