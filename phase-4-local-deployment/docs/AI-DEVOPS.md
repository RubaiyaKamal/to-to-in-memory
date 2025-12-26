# AI-Assisted DevOps Guide

Complete guide for using Gordon (Docker AI), kubectl-ai, and Kagent for intelligent cloud-native operations.

## 🤖 Docker AI (Gordon)

### Setup

1. **Prerequisites**:
   - Docker Desktop 4.53 or later
   - Docker Desktop Pro, Team, or Business subscription

2. **Enable Gordon**:
   - Open Docker Desktop
   - Go to Settings → Beta features
   - Toggle "Docker AI" ON
   - Restart Docker Desktop

3. **Verify Installation**:
   ```bash
   docker ai "What can you do?"
   ```

### Common Operations

#### Build Images

```bash
# Build backend image
docker ai "build the backend image for todo chatbot from phase-4-local-deployment/docker/backend/Dockerfile"

# Build frontend image
docker ai "build the frontend image using the Dockerfile in phase-4-local-deployment/docker/frontend"

# Build both images
docker ai "build all images for the todo chatbot application"
```

#### Manage Containers

```bash
# Start containers
docker ai "start the todo chatbot containers using docker-compose"

# Stop containers
docker ai "stop all todo chatbot containers"

# Check status
docker ai "show me the status of todo chatbot containers"

# View logs
docker ai "show me logs from the backend container"
```

#### Troubleshoot

```bash
# Debug container issues
docker ai "why is the backend container exiting?"

# Check resource usage
docker ai "how much memory is the frontend container using?"

# Network debugging
docker ai "can the frontend container reach the backend?"
```

#### Optimize Images

```bash
# Analyze image size
docker ai "how can I reduce the size of the backend image?"

# Security scanning
docker ai "check the frontend image for security vulnerabilities"

# Best practices
docker ai "review the Dockerfile for best practices"
```

## ⚙️ kubectl-ai

### Setup

**Option 1: NPM (Recommended)**
```bash
npm install -g kubectl-ai
```

**Option 2: Manual Download**
```bash
# Download from GitHub releases
curl -LO https://github.com/sozercan/kubectl-ai/releases/latest/download/kubectl-ai-linux-amd64
chmod +x kubectl-ai-linux-amd64
sudo mv kubectl-ai-linux-amd64 /usr/local/bin/kubectl-ai
```

**Configure OpenAI API Key**:
```bash
export OPENAI_API_KEY="your-api-key"
# Or add to ~/.bashrc or ~/.zshrc
```

### Common Operations

#### Deployment

```bash
# Deploy application
kubectl-ai "deploy the todo chatbot to the todo-chatbot namespace"

# Scale deployment
kubectl-ai "scale the backend deployment to 3 replicas"

# Update image
kubectl-ai "update the frontend deployment to use version 2.0"

# Rollback
kubectl-ai "rollback the backend deployment to the previous version"
```

#### Service Management

```bash
# Create service
kubectl-ai "expose the backend deployment on port 8001"

# Update service
kubectl-ai "change the frontend service to LoadBalancer type"

# Create ingress
kubectl-ai "create an ingress for the frontend service at todo.local"
```

#### Monitoring & Debugging

```bash
# Check pod status
kubectl-ai "why are the backend pods not ready?"

# View logs
kubectl-ai "show me logs from the crashing backend pod"

# Debug networking
kubectl-ai "test if frontend pods can reach backend service"

# Check resources
kubectl-ai "show resource usage for all pods in todo-chatbot namespace"
```

#### Configuration

```bash
# Create ConfigMap
kubectl-ai "create a configmap with database connection string"

# Create Secret
kubectl-ai "create a secret for the OpenAI API key"

# Update environment variables
kubectl-ai "add a new environment variable to the backend deployment"
```

#### Storage

```bash
# Create PVC
kubectl-ai "create a 2GB persistent volume claim for the backend"

# Check storage
kubectl-ai "show me all persistent volumes and their status"

# Resize PVC
kubectl-ai "increase the backend PVC size to 5GB"
```

## 🧠 Kagent

### Setup

**Option 1: Homebrew (macOS)**
```bash
brew install kagent
```

**Option 2: Binary Download**
```bash
# Download latest release
curl -LO https://github.com/your-org/kagent/releases/latest/download/kagent-linux-amd64
chmod +x kagent-linux-amd64
sudo mv kagent-linux-amd64 /usr/local/bin/kagent
```

**Configure**:
```bash
kagent config set-context $(kubectl config current-context)
```

### Common Operations

#### Cluster Analysis

```bash
# Health check
kagent "analyze cluster health"

# Namespace analysis
kagent "analyze the todo-chatbot namespace"

# Resource efficiency
kagent "identify resource waste in my cluster"

# Security posture
kagent "check security best practices for todo-chatbot"
```

#### Optimization

```bash
# Resource allocation
kagent "optimize CPU and memory requests for backend pods"

# Cost optimization
kagent "how can I reduce costs for this deployment?"

# Performance tuning
kagent "improve response time for the frontend service"

# Scaling recommendations
kagent "should I add more replicas to the backend?"
```

#### Troubleshooting

```bash
# Diagnose issues
kagent "diagnose why pods are in CrashLoopBackOff"

# Network problems
kagent "why can't frontend pods reach the backend?"

# Performance issues
kagent "why is the backend service slow?"

# Resource constraints
kagent "am I running out of resources?"
```

#### Best Practices

```bash
# Review configuration
kagent "review my deployment configuration for best practices"

# Security audit
kagent "audit my namespace for security vulnerabilities"

# Compliance check
kagent "check if my deployment follows Kubernetes best practices"

# Documentation
kagent "generate documentation for my deployment"
```

## 🎯 Practical Workflows

### Workflow 1: Initial Deployment

```bash
# 1. Build images with Docker AI
docker ai "build all images for todo chatbot"

# 2. Deploy with kubectl-ai
kubectl-ai "deploy todo chatbot to a new namespace with 2 replicas"

# 3. Verify with Kagent
kagent "analyze the todo-chatbot namespace and check for issues"

# 4. Optimize
kagent "optimize resource allocation for the deployment"
```

### Workflow 2: Troubleshooting Crashes

```bash
# 1. Identify issue with kubectl-ai
kubectl-ai "why are the backend pods crashing?"

# 2. Analyze with Kagent
kagent "diagnose the CrashLoopBackOff issue in backend pods"

# 3. Check logs with kubectl-ai
kubectl-ai "show me the last 100 lines of logs from the failing pod"

# 4. Verify fix with Docker AI
docker ai "test if the backend container runs locally"
```

### Workflow 3: Scaling for Load

```bash
# 1. Analyze current state with Kagent
kagent "analyze current load and resource usage"

# 2. Get scaling recommendation
kagent "how many replicas do I need to handle 1000 concurrent users?"

# 3. Scale with kubectl-ai
kubectl-ai "scale backend to 5 replicas and frontend to 3 replicas"

# 4. Verify with kubectl-ai
kubectl-ai "check if all pods are healthy after scaling"
```

### Workflow 4: Security Hardening

```bash
# 1. Security audit with Kagent
kagent "perform a security audit of the todo-chatbot namespace"

# 2. Image security with Docker AI
docker ai "scan both images for vulnerabilities"

# 3. Apply recommendations with kubectl-ai
kubectl-ai "add security context to limit pod privileges"

# 4. Verify with Kagent
kagent "verify security improvements were applied correctly"
```

## 💡 Tips & Best Practices

### General

1. **Be Specific**: More context leads to better AI responses
   - Good: "scale the backend deployment to 3 replicas in todo-chatbot namespace"
   - Bad: "scale backend"

2. **Verify Changes**: Always review AI-generated commands before executing
   ```bash
   kubectl-ai "scale backend to 5 replicas" --dry-run
   ```

3. **Learn from Suggestions**: Use AI tools as learning aids
   - Ask "why" questions
   - Request explanations
   - Compare different approaches

### Docker AI

- Use for quick prototyping and debugging
- Great for Dockerfile optimization
- Helps with multi-stage build strategies
- Excellent for container networking issues

### kubectl-ai

- Perfect for exploratory operations
- Saves time on complex kubectl syntax
- Great for generating manifest templates
- Use with `--dry-run` for safety

### Kagent

- Best for strategic decisions
- Excellent cluster-wide analysis
- Use for capacity planning
- Great for compliance and security

## 🚨 Limitations & Considerations

### Accuracy

- AI suggestions may not always be optimal
- Always review before applying to production
- Verify critical operations manually

### Cost

- API calls to OpenAI cost money
- Monitor usage for kubectl-ai and Kagent
- Set budget alerts if needed

### Security

- Never expose API keys in commands
- Review all generated YAML before applying
- Don't blindly trust security recommendations

### Learning

- Use AI as a supplement, not replacement
- Understand the underlying concepts
- Learn kubectl/helm/docker fundamentals

## 📚 Additional Resources

- **Docker AI Documentation**: https://docs.docker.com/desktop/ai/
- **kubectl-ai GitHub**: https://github.com/sozercan/kubectl-ai
- **Kagent Documentation**: https://kagent.dev/docs
- **OpenAI API Pricing**: https://openai.com/pricing

## 🎓 Exercise: Complete AI-Assisted Deployment

Try this full deployment using only AI tools:

```bash
# 1. Build images
docker ai "build optimized multi-stage images for todo chatbot"

# 2. Deploy to Kubernetes
kubectl-ai "create a new namespace todo-chatbot and deploy the application with health checks"

# 3. Configure networking
kubectl-ai "expose frontend as NodePort and backend as ClusterIP"

# 4. Add persistence
kubectl-ai "add a 1GB persistent volume to the backend for database storage"

# 5. Analyze deployment
kagent "analyze the deployment and suggest improvements"

# 6. Apply recommendations
kubectl-ai "apply the resource limits suggested by Kagent"

# 7. Verify everything
kagent "verify the deployment is healthy and following best practices"
```

Congratulations! You've deployed using AI-assisted DevOps tools!
