# Phase IV Testing and Validation

Task Group 7: Testing and Validation
Reference: `specs/003-local-k8s-deployment/tasks.md`

This directory contains comprehensive test scripts for validating the Todo Chatbot deployment on Kubernetes.

## Available Tests

### 1. test_deployment.sh (Task 7.1)

**End-to-End Deployment Test** - Validates the complete deployment workflow from setup to cleanup.

**What it tests:**
- ✅ Minikube setup and configuration
- ✅ Docker image building and loading
- ✅ Application deployment (kubectl or Helm)
- ✅ Resource creation (namespace, deployments, services, PVC, secrets)
- ✅ Pod health and readiness
- ✅ Service connectivity (backend/frontend)
- ✅ Data persistence in PVC
- ✅ Frontend UI accessibility
- ✅ Cleanup and resource removal

**Usage:**

```bash
# Run full end-to-end test (default: kubectl deployment)
./phase-4-local-deployment/tests/test_deployment.sh

# Use Helm deployment method
./phase-4-local-deployment/tests/test_deployment.sh --deploy-method helm

# Skip Minikube setup (if already running)
./phase-4-local-deployment/tests/test_deployment.sh --skip-setup

# Skip image building (if images already exist)
./phase-4-local-deployment/tests/test_deployment.sh --skip-build

# Skip cleanup (to keep deployment after test)
./phase-4-local-deployment/tests/test_deployment.sh --skip-cleanup

# Verbose output for debugging
./phase-4-local-deployment/tests/test_deployment.sh --verbose

# Combined flags
./phase-4-local-deployment/tests/test_deployment.sh --deploy-method helm --skip-setup --verbose
```

**Environment Variables:**

```bash
export OPENAI_API_KEY="your-openai-api-key"  # Required
export NAMESPACE="todo-chatbot"              # Optional (default: todo-chatbot)
export TIMEOUT="300"                         # Optional (default: 300s)
```

**Example Output:**

```
═══════════════════════════════════════════════════════════════
Todo Chatbot - End-to-End Deployment Test
═══════════════════════════════════════════════════════════════

Configuration:
  Namespace:       todo-chatbot
  Deploy Method:   kubectl
  Timeout:         300s
  Skip Setup:      false
  Skip Build:      false
  Skip Cleanup:    false
  Verbose:         false

[INFO] Checking prerequisites...
[SUCCESS] All prerequisites met

═══════════════════════════════════════════════════════════════
Running Tests
═══════════════════════════════════════════════════════════════

[TEST] Test 1: Minikube Setup
[SUCCESS] ✓ Minikube setup completed successfully

[TEST] Test 2: Docker Image Building
[SUCCESS] ✓ Docker images built successfully

[TEST] Test 3: Application Deployment (kubectl)
[SUCCESS] ✓ Application deployed successfully via kubectl

[TEST] Test 4: Resource Creation Validation
[SUCCESS] ✓ All required resources created

[TEST] Test 5: Pod Health Validation
[SUCCESS] ✓ All pods are healthy and ready

[TEST] Test 6: Service Connectivity
[SUCCESS] ✓ All services are reachable and responding

[TEST] Test 7: Data Persistence
[SUCCESS] ✓ Data persistence validated

[TEST] Test 8: Frontend UI Accessibility
[SUCCESS] Frontend UI is accessible at http://192.168.49.2:30080
[SUCCESS] ✓ Frontend UI is accessible

[TEST] Test 9: Cleanup Validation
[SUCCESS] ✓ Cleanup completed successfully

═══════════════════════════════════════════════════════════════
TEST SUMMARY
═══════════════════════════════════════════════════════════════
Total Tests:  9
Passed:       9
Failed:       0
═══════════════════════════════════════════════════════════════
[SUCCESS] All tests passed! 🎉
```

**Exit Codes:**
- `0` - All tests passed
- `1` - One or more tests failed
- `2` - Prerequisites not met

---

### 2. test_functionality.sh (Task 7.2)

**Application Functionality Test** - Validates the API functionality and data integrity of the deployed application.

**What it tests:**
- ✅ Create Task (POST /api/tasks)
- ✅ Read All Tasks (GET /api/tasks)
- ✅ Read Single Task (GET /api/tasks/{id})
- ✅ Update Task (PUT /api/tasks/{id})
- ✅ Chatbot Endpoint (POST /api/chat)
- ✅ Delete Task (DELETE /api/tasks/{id})
- ✅ Data persistence after pod restart
- ✅ API error handling (404 responses)

**Prerequisites:**
- Application must be deployed to Kubernetes
- kubectl configured with access to the cluster
- Backend pods must be running

**Usage:**

```bash
# Run all functionality tests
./phase-4-local-deployment/tests/test_functionality.sh

# Test specific namespace
./phase-4-local-deployment/tests/test_functionality.sh --namespace my-namespace

# Skip pod restart test (faster)
./phase-4-local-deployment/tests/test_functionality.sh --skip-restart

# Verbose output for debugging
./phase-4-local-deployment/tests/test_functionality.sh --verbose
```

**Environment Variables:**

```bash
export NAMESPACE="todo-chatbot"  # Optional (default: todo-chatbot)
```

**Example Output:**

```
═══════════════════════════════════════════════════════════════
Todo Chatbot - Application Functionality Test
═══════════════════════════════════════════════════════════════

Configuration:
  Namespace:       todo-chatbot
  Skip Restart:    false
  Verbose:         false

[INFO] Checking prerequisites...
[SUCCESS] All prerequisites met

═══════════════════════════════════════════════════════════════
Running Functionality Tests
═══════════════════════════════════════════════════════════════

[TEST] Test 1: Create Task (POST /api/tasks)
[SUCCESS] ✓ Create Task (ID: 123)

[TEST] Test 2: Read All Tasks (GET /api/tasks)
[SUCCESS] ✓ Read All Tasks

[TEST] Test 3: Read Single Task (GET /api/tasks/{id})
[SUCCESS] ✓ Read Single Task (ID: 123)

[TEST] Test 4: Update Task (PUT /api/tasks/{id})
[SUCCESS] ✓ Update Task (ID: 123)

[TEST] Test 5: Chatbot Endpoint (POST /api/chat)
[SUCCESS] ✓ Chatbot Endpoint

[TEST] Test 6: Delete Task (DELETE /api/tasks/{id})
[SUCCESS] ✓ Delete Task (ID: 123)

[TEST] Test 7: Data Persistence After Pod Restart
[INFO] Creating persistence test task...
[INFO] Deleting backend pod: todo-chatbot-backend-abc123
[INFO] Waiting for new pod to be ready...
[INFO] Verifying task persistence after restart...
[SUCCESS] Task survived pod restart
[SUCCESS] ✓ Data Persistence After Restart

[TEST] Test 8: API Error Handling
[SUCCESS] ✓ API Error Handling

[INFO] Cleaning up test data...

═══════════════════════════════════════════════════════════════
TEST SUMMARY
═══════════════════════════════════════════════════════════════
Total Tests:  8
Passed:       8
Failed:       0
═══════════════════════════════════════════════════════════════
[SUCCESS] All functionality tests passed! 🎉
```

**Exit Codes:**
- `0` - All tests passed
- `1` - One or more tests failed
- `2` - Prerequisites not met

---

## Test Workflow

### Quick Test (Existing Deployment)

If you already have the application deployed, run functionality tests only:

```bash
# Quick functionality validation
./phase-4-local-deployment/tests/test_functionality.sh
```

### Full Test (From Scratch)

For comprehensive end-to-end testing from clean state:

```bash
# Set API key
export OPENAI_API_KEY="your-api-key"

# Run full deployment test
./phase-4-local-deployment/tests/test_deployment.sh

# Run functionality tests on deployed app
./phase-4-local-deployment/tests/test_functionality.sh
```

### CI/CD Pipeline Integration

```bash
#!/bin/bash
# Example CI/CD test pipeline

set -e

export OPENAI_API_KEY="${CI_OPENAI_API_KEY}"

# Full deployment test
./phase-4-local-deployment/tests/test_deployment.sh \
  --deploy-method kubectl \
  --verbose

# Functionality validation
./phase-4-local-deployment/tests/test_functionality.sh \
  --verbose

echo "All tests passed!"
```

### Development Testing

For faster iteration during development:

```bash
# Setup once
export OPENAI_API_KEY="your-api-key"
./phase-4-local-deployment/scripts/setup-minikube.sh
./phase-4-local-deployment/scripts/build-images.sh

# Deploy and test (skip setup/build)
./phase-4-local-deployment/tests/test_deployment.sh \
  --skip-setup \
  --skip-build \
  --skip-cleanup

# Run functionality tests
./phase-4-local-deployment/tests/test_functionality.sh

# Make code changes, rebuild, and test again
./phase-4-local-deployment/scripts/build-images.sh
./phase-4-local-deployment/tests/test_deployment.sh \
  --skip-setup \
  --skip-build \
  --skip-cleanup
./phase-4-local-deployment/tests/test_functionality.sh
```

---

## Troubleshooting

### Prerequisites Check Failed

**Problem:** Tests fail at prerequisites check

**Solution:**
```bash
# Ensure kubectl is installed
kubectl version --client

# Ensure Minikube is installed
minikube version

# Ensure Docker is running
docker info

# Set OPENAI_API_KEY
export OPENAI_API_KEY="your-api-key"
```

### Timeout Waiting for Pods

**Problem:** `test_deployment.sh` times out waiting for pods

**Solution:**
```bash
# Increase timeout
export TIMEOUT=600  # 10 minutes

# Check pod status manually
kubectl get pods -n todo-chatbot

# Check pod logs
kubectl logs <pod-name> -n todo-chatbot

# Describe pod for events
kubectl describe pod <pod-name> -n todo-chatbot
```

### API Request Failed

**Problem:** `test_functionality.sh` fails with API_ERROR

**Solution:**
```bash
# Check backend pod is running
kubectl get pods -n todo-chatbot -l app=todo-chatbot-backend

# Check backend logs
kubectl logs <backend-pod-name> -n todo-chatbot

# Test health endpoint manually
kubectl exec -it <backend-pod-name> -n todo-chatbot -- \
  curl http://localhost:8001/api/health

# Port forward and test locally
kubectl port-forward -n todo-chatbot svc/todo-chatbot-backend 8001:8001
curl http://localhost:8001/api/health
```

### Cleanup Not Working

**Problem:** Namespace or resources remain after cleanup

**Solution:**
```bash
# Manual cleanup
kubectl delete namespace todo-chatbot --force --grace-period=0

# Remove finalizers if stuck
kubectl patch namespace todo-chatbot -p '{"metadata":{"finalizers":null}}'

# Delete Helm release
helm uninstall todo-chatbot -n todo-chatbot

# Verify cleanup
kubectl get all -n todo-chatbot
```

### jq Not Available Warning

**Problem:** Warning about jq not installed

**Impact:** Tests still work but JSON parsing is limited

**Solution (Optional):**
```bash
# Install jq for better test output

# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Windows (via Chocolatey)
choco install jq

# Or run tests without jq (still works)
./phase-4-local-deployment/tests/test_functionality.sh
```

---

## Test Coverage

### Deployment Test Coverage

| Component | Test |
|-----------|------|
| Minikube | Setup, configuration, addons |
| Docker | Image building, loading to Minikube |
| Kubernetes | Namespace, deployments, services, PVC, secrets |
| Pods | Health checks, readiness probes |
| Services | Backend/frontend connectivity |
| Data | Persistence in PVC |
| Frontend | UI accessibility via NodePort |
| Cleanup | Resource removal verification |

### Functionality Test Coverage

| API Endpoint | Test |
|--------------|------|
| POST /api/tasks | Create task with validation |
| GET /api/tasks | List all tasks |
| GET /api/tasks/{id} | Get single task by ID |
| PUT /api/tasks/{id} | Update task fields |
| DELETE /api/tasks/{id} | Delete task |
| POST /api/chat | Chatbot conversation |
| Error Handling | 404 responses, invalid requests |
| Data Integrity | Persistence after pod restart |

---

## Best Practices

1. **Always set OPENAI_API_KEY** before running deployment tests
   ```bash
   export OPENAI_API_KEY="your-api-key"
   ```

2. **Use verbose mode for debugging** failures
   ```bash
   ./test_deployment.sh --verbose
   ```

3. **Skip setup/build for faster iteration** during development
   ```bash
   ./test_deployment.sh --skip-setup --skip-build
   ```

4. **Run functionality tests after deployment** to validate application
   ```bash
   ./test_deployment.sh && ./test_functionality.sh
   ```

5. **Check exit codes in scripts** for CI/CD integration
   ```bash
   if ./test_deployment.sh; then
     echo "Deployment test passed"
   else
     echo "Deployment test failed"
     exit 1
   fi
   ```

6. **Keep Minikube resources adequate** for testing
   ```bash
   # Increase resources if tests timeout
   MINIKUBE_CPUS=4 MINIKUBE_MEMORY=8192 \
     ./phase-4-local-deployment/scripts/setup-minikube.sh
   ```

---

## Additional Resources

- **Task Documentation:** `specs/003-local-k8s-deployment/tasks.md`
- **Deployment Scripts:** `phase-4-local-deployment/scripts/`
- **Kubernetes Manifests:** `phase-4-local-deployment/k8s/base/`
- **Helm Chart:** `phase-4-local-deployment/helm/todo-chatbot/`
- **Troubleshooting Guide:** `phase-4-local-deployment/docs/TROUBLESHOOTING.md`
- **Architecture Documentation:** `phase-4-local-deployment/docs/ARCHITECTURE.md`

---

## Contributing

When adding new tests:

1. Follow the existing test structure (logging, test_pass/test_fail)
2. Add clear test names and descriptions
3. Update this README with new test documentation
4. Ensure tests clean up after themselves
5. Add appropriate error handling
6. Use verbose logging for debugging
7. Test both success and failure paths
8. Document prerequisites and environment variables
