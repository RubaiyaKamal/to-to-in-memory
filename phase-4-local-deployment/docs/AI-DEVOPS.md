# AI-Assisted DevOps Tools

**Status**: Optional Enhancement (Phase IV Extension)

This guide documents AI-powered tools that can enhance the Phase IV deployment workflow through natural language interactions. These tools are **entirely optional** and all operations can be performed using standard CLI commands.

## Table of Contents

- [Overview](#overview)
- [kubectl-ai: AI-Powered Kubernetes Operations](#kubectl-ai-ai-powered-kubernetes-operations)
- [Kagent: Kubernetes Agent for Cluster Analysis](#kagent-kubernetes-agent-for-cluster-analysis)
- [Docker AI (Gordon): AI-Assisted Docker Operations](#docker-ai-gordon-ai-assisted-docker-operations)
- [Comparison Matrix](#comparison-matrix)
- [Best Practices](#best-practices)
- [Limitations](#limitations)

---

## Overview

AI-assisted DevOps tools leverage Large Language Models (LLMs) to translate natural language commands into Kubernetes, Docker, and infrastructure operations. They can accelerate workflows, help with troubleshooting, and lower the barrier to entry for complex operations.

### When to Use AI Tools

**Good Use Cases:**
- ✅ Learning Kubernetes/Docker commands
- ✅ Quick troubleshooting and diagnostics
- ✅ Exploring cluster state
- ✅ Prototyping complex operations
- ✅ Generating configuration templates

**When to Use Standard CLI:**
- 🔧 Production deployments (use scripts)
- 🔧 CI/CD pipelines (use deterministic commands)
- 🔧 Operations requiring exact precision
- 🔧 Security-sensitive operations

### Prerequisites

All AI tools require:
- Active internet connection (LLM API calls)
- API keys for AI services (OpenAI, Anthropic, etc.)
- Standard CLI tools already installed (kubectl, docker, helm)

---

## kubectl-ai: AI-Powered Kubernetes Operations

**Project**: [kubectl-ai](https://github.com/sozercan/kubectl-ai)
**Status**: Community project, actively maintained
**License**: Apache 2.0

### What is kubectl-ai?

kubectl-ai is a kubectl plugin that uses OpenAI's GPT models to generate and execute Kubernetes commands from natural language descriptions.

### Installation

#### Option 1: npm (Recommended)

```bash
# Install globally via npm
npm install -g kubectl-ai

# Verify installation
kubectl ai version
```

#### Option 2: Binary Download

```bash
# Download latest release
# Visit: https://github.com/sozercan/kubectl-ai/releases

# macOS (ARM)
curl -LO https://github.com/sozercan/kubectl-ai/releases/latest/download/kubectl-ai-darwin-arm64
chmod +x kubectl-ai-darwin-arm64
sudo mv kubectl-ai-darwin-arm64 /usr/local/bin/kubectl-ai

# Linux (AMD64)
curl -LO https://github.com/sozercan/kubectl-ai/releases/latest/download/kubectl-ai-linux-amd64
chmod +x kubectl-ai-linux-amd64
sudo mv kubectl-ai-linux-amd64 /usr/local/bin/kubectl-ai

# Windows (PowerShell)
# Download from releases page and add to PATH
```

#### Option 3: Krew (kubectl plugin manager)

```bash
# Install krew if not already installed
# See: https://krew.sigs.k8s.io/docs/user-guide/setup/install/

# Install kubectl-ai via krew
kubectl krew install ai

# Verify
kubectl ai version
```

### Configuration

#### Set OpenAI API Key

```bash
# Option 1: Environment variable (recommended)
export OPENAI_API_KEY="sk-your-api-key-here"

# Option 2: kubectl-ai config
kubectl ai config set-key sk-your-api-key-here

# Option 3: Add to shell profile
echo 'export OPENAI_API_KEY="sk-your-api-key-here"' >> ~/.bashrc
source ~/.bashrc
```

#### Configure Model (Optional)

```bash
# Default: gpt-3.5-turbo
# Use GPT-4 for better accuracy (higher cost)
kubectl ai config set-model gpt-4

# Or set via environment variable
export KUBECTL_AI_MODEL="gpt-4"
```

### Usage Examples with Standard Command Comparison

#### Basic Operations

| Task | kubectl-ai | Standard kubectl |
|------|-----------|------------------|
| List pods | `kubectl ai "show me all pods in todo-chatbot"` | `kubectl get pods -n todo-chatbot` |
| Describe pod | `kubectl ai "describe the backend pod"` | `kubectl describe pod <name> -n todo-chatbot` |
| View logs | `kubectl ai "show last 100 log lines from backend"` | `kubectl logs -l app=todo-chatbot-backend -n todo-chatbot --tail=100` |
| Scale deployment | `kubectl ai "scale backend to 3 replicas"` | `kubectl scale deployment/todo-chatbot-backend --replicas=3 -n todo-chatbot` |
| Restart deployment | `kubectl ai "restart the frontend deployment"` | `kubectl rollout restart deployment/todo-chatbot-frontend -n todo-chatbot` |

#### Troubleshooting Examples

**Example 1: Find Crashing Pods**

```bash
# AI command
kubectl ai "show me all pods that are crashing or have errors"

# Generated command (approximately):
kubectl get pods --all-namespaces --field-selector status.phase!=Running,status.phase!=Succeeded
```

**Example 2: Debug Service Endpoints**

```bash
# AI command
kubectl ai "check why the backend service has no endpoints in todo-chatbot namespace"

# kubectl-ai will run multiple commands:
# 1. kubectl get svc todo-chatbot-backend -n todo-chatbot
# 2. kubectl get endpoints todo-chatbot-backend -n todo-chatbot
# 3. kubectl get pods -n todo-chatbot -l app=todo-chatbot-backend
```

**Example 3: Resource Usage**

```bash
# AI command
kubectl ai "show me which pods are using the most memory"

# Standard command:
kubectl top pods --all-namespaces --sort-by=memory
```

### Interactive Mode

```bash
# Start interactive session
kubectl ai

# Then type natural language commands
> show me all namespaces
> describe the todo-chatbot namespace
> list all services in todo-chatbot
> exit
```

### Dry Run Mode

```bash
# See generated command without executing
kubectl ai --dry-run "scale backend to 5 replicas"

# Output:
# Generated command: kubectl scale deployment/todo-chatbot-backend --replicas=5 -n todo-chatbot
# (Not executed due to --dry-run flag)
```

### Limitations

**1. Context Awareness**
- kubectl-ai doesn't maintain conversation context
- Each command is independent
- Cannot reference previous commands

**2. Accuracy**
- GPT-3.5-turbo: ~80-90% accuracy
- GPT-4: ~95-98% accuracy
- Always verify generated commands

**3. Resource Names**
- May struggle with exact resource names
- Works better with labels and selectors

**4. Cost**
- Each command = 1 API call to OpenAI
- GPT-4 more expensive than GPT-3.5-turbo

### Troubleshooting

**Error: "API key not found"**
```bash
# Set API key
export OPENAI_API_KEY="sk-your-key"

# Verify
echo $OPENAI_API_KEY
```

**Error: "Command failed to execute"**
```bash
# Use dry-run to see generated command
kubectl ai --dry-run "your command here"

# Manually verify and adjust
```

---

## Kagent: Kubernetes Agent for Cluster Analysis

**Note**: As of January 2025, Kagent is an emerging concept. Alternative: [K8sGPT](https://github.com/k8sgpt-ai/k8sgpt)

### What is Kagent/K8sGPT?

An AI-powered tool that performs cluster-wide analysis, optimization recommendations, and security audits using LLM-based reasoning.

### Installation (K8sGPT)

```bash
# Using Homebrew (macOS/Linux)
brew tap k8sgpt-ai/k8sgpt
brew install k8sgpt

# Using binary
# Visit: https://github.com/k8sgpt-ai/k8sgpt/releases
curl -LO https://github.com/k8sgpt-ai/k8sgpt/releases/latest/download/k8sgpt_Linux_x86_64.tar.gz
tar -xvf k8sgpt_Linux_x86_64.tar.gz
sudo mv k8sgpt /usr/local/bin/

# Verify
k8sgpt version
```

### Configuration

```bash
# Configure with OpenAI
k8sgpt auth add openai --token sk-your-api-key

# Or use Azure OpenAI
k8sgpt auth add azureopenai --token <token> --baseurl <url>

# List integrations
k8sgpt integrations list

# Enable integrations (e.g., Prometheus)
k8sgpt integrations activate prometheus
```

### Usage Examples with Standard Comparison

#### Health Analysis

| Task | K8sGPT | Standard kubectl |
|------|--------|------------------|
| Analyze namespace | `k8sgpt analyze --namespace todo-chatbot` | `kubectl get all -n todo-chatbot` + manual analysis |
| Explain errors | `k8sgpt analyze --explain` | Read events + manual troubleshooting |
| Generate report | `k8sgpt analyze --output json` | Multiple kubectl commands + manual reporting |

**Example 1: Analyze Todo Chatbot Namespace**

```bash
# AI command
k8sgpt analyze --namespace todo-chatbot --explain

# Output (example):
# 0: Pod todo-chatbot-backend-xyz is in CrashLoopBackOff
#    Explanation: The pod is crashing because the OPENAI_API_KEY environment
#    variable is not set. Check if the secret todo-chatbot-secret exists
#    and is properly referenced in the deployment.
#    Solution: kubectl create secret generic todo-chatbot-secret...
```

**Example 2: Cluster-Wide Health Check**

```bash
# AI command
k8sgpt analyze --explain

# Analyzes:
# - All pod failures
# - Service misconfigurations
# - PVC binding issues
# - Node problems
# - Provides AI-powered explanations
```

#### Filters and Options

```bash
# Filter by problem type
k8sgpt analyze --filter Pod,Service --namespace todo-chatbot

# Include configuration analysis
k8sgpt analyze --with-doc

# Export results
k8sgpt analyze --output json > cluster-analysis.json
k8sgpt analyze --output yaml > cluster-analysis.yaml
```

### Integration with Prometheus

```bash
# Enable Prometheus integration
k8sgpt integrations activate prometheus

# Analyze with metrics
k8sgpt analyze --filter Deployment --with-metrics

# This provides resource usage insights along with error analysis
```

### Limitations

**1. Emerging Technology**
- Check repository for latest features
- API may change

**2. Accuracy**
- Recommendations should be human-reviewed
- Not a replacement for SRE expertise

**3. Cost**
- Each analysis makes LLM API calls
- Large clusters = higher costs

**4. Dependency**
- Requires metrics-server for resource analysis
- Best with Prometheus for detailed metrics

### Troubleshooting

**Installation Issues**
```bash
# Verify prerequisites
kubectl version
kubectl get nodes

# Check permissions
kubectl auth can-i get pods --all-namespaces
```

**API Rate Limits**
```bash
# Use caching
k8sgpt analyze --cache

# Filter to reduce API calls
k8sgpt analyze --filter Pod,Service
```

---

## Docker AI (Gordon): AI-Assisted Docker Operations

**Product**: Docker AI (codename: Gordon)
**Availability**: Docker Desktop 4.53+ (Beta feature)
**Regions**: Initially US-only, expanding

### What is Docker AI (Gordon)?

Docker AI is an AI-powered assistant built into Docker Desktop that helps with image building, container troubleshooting, and Docker operations through natural language.

### Prerequisites

**Required:**
- Docker Desktop 4.53 or later
- Docker Desktop account
- Supported region (check Docker website)

**Supported Platforms:**
- macOS (Intel and Apple Silicon)
- Windows 10/11 with WSL2
- Linux (select distributions)

### Installation

**Step 1: Update Docker Desktop**

```bash
# Check current version
docker --version

# Should show: Docker version 24.0.0 or later

# If older, download latest from:
# https://www.docker.com/products/docker-desktop/
```

**Step 2: Enable Beta Features**

1. Open Docker Desktop
2. Click Settings (gear icon)
3. Navigate to "Features in development"
4. Enable "Docker AI" (Gordon)
5. Restart Docker Desktop

**Step 3: Verify Gordon is Available**

```bash
# Check if Gordon is enabled
docker ai help

# Or look for "Ask Docker AI" in Docker Desktop UI
```

### Usage Examples with Standard Comparison

#### Image Building

| Task | Docker AI (Gordon) | Standard Docker |
|------|-------------------|-----------------|
| Build help | `docker ai "help me build a Python FastAPI image"` | Read Dockerfile docs + create manually |
| Build image | `docker ai "build backend image from phase-4-local-deployment/docker/backend"` | `docker build -t backend:latest -f path/to/Dockerfile .` |
| Optimize size | `docker ai "how can I reduce image size?"` | Research + implement multi-stage builds manually |
| Debug build | `docker ai "why is my build failing with ModuleNotFoundError?"` | Read build logs + Google error + fix manually |

**Example 1: Build Troubleshooting**

```bash
# AI command
docker ai "my backend build fails with 'ModuleNotFoundError: No module named sqlalchemy'"

# Gordon suggests:
# 1. Check requirements.txt includes sqlalchemy
# 2. Ensure pip install runs before COPY of app code
# 3. Verify Python version compatibility
# 4. Suggested fix: Add sqlalchemy==2.0.23 to requirements.txt
```

**Example 2: Multi-Stage Build Help**

```bash
# AI command
docker ai "create a multi-stage Dockerfile for Next.js with nginx"

# Gordon generates:
# FROM node:20 AS builder
# WORKDIR /app
# COPY package*.json ./
# RUN npm ci
# COPY . .
# RUN npm run build
#
# FROM nginx:alpine
# COPY --from=builder /app/dist /usr/share/nginx/html
# ...
```

#### Container Troubleshooting

**Example 3: Container Won't Start**

```bash
# AI command
docker ai "my todo-chatbot-backend container keeps crashing"

# Gordon checks:
# 1. docker logs <container>
# 2. Exit code analysis
# 3. Common startup issues
# 4. Provides specific fixes
```

**Example 4: Network Issues**

```bash
# AI command
docker ai "frontend can't connect to backend container"

# Gordon investigates:
# 1. docker network inspect
# 2. Container networking mode
# 3. Port mappings
# 4. DNS resolution
# 5. Suggests fixes
```

### Docker Desktop UI Integration

**AI Chat Panel:**
1. Open Docker Desktop
2. Click "Ask Docker AI" button (chat icon)
3. Type natural language questions
4. Gordon responds with:
   - Explanations
   - Command suggestions
   - Clickable actions

**Inline Help:**
- Error messages have "Ask AI" button
- Gordon explains error and suggests fixes
- Can execute fixes directly from UI

### Regional Availability

**Currently Available:**
- United States
- Canada (limited)

**Coming Soon:**
- Europe (EU regions)
- Asia Pacific (select countries)

**Not Available in Your Region?**
```bash
# Use standard Docker commands
# This guide shows all standard command equivalents

# Or use kubectl-ai for Kubernetes operations
```

### Limitations

**1. Beta Status**
- Features may change
- Occasional inaccuracies
- Not recommended for production-critical decisions

**2. Regional Restrictions**
- Limited to specific countries
- Requires Docker account in supported region

**3. Internet Required**
- All queries require internet connection

**4. Context Limitations**
- Gordon can't access files outside Docker Desktop
- Limited to Docker-specific operations

**5. Privacy**
- Queries sent to Docker's AI service
- May include container/image metadata
- Review Docker's privacy policy

### Fallback to Standard Commands

```bash
# Always know standard commands:

# Build image
docker build -t todo-chatbot-backend:latest \
  -f phase-4-local-deployment/docker/backend/Dockerfile .

# View logs
docker logs <container-id>

# Inspect
docker inspect <container-id>

# Execute command
docker exec -it <container-id> /bin/bash

# Stats
docker stats

# Network debug
docker network ls
docker network inspect <network>

# Cleanup
docker system prune -a --volumes
```

### Troubleshooting Gordon

**Gordon Not Available**
```bash
# Check version
docker --version  # Should be 4.53+

# Update Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop/

# Enable beta features
# Settings → Features in development → Docker AI
```

**Gordon Not Responding**
```bash
# Check internet
ping docker.com

# Restart Docker Desktop
# Docker Desktop → Restart

# Check status
docker info
```

---

## Comparison Matrix

| Feature | kubectl-ai | K8sGPT/Kagent | Docker AI (Gordon) |
|---------|-----------|---------------|-------------------|
| **Platform** | kubectl plugin | Standalone | Docker Desktop |
| **Installation** | npm/binary/krew | Binary/brew | Built-in (beta) |
| **Cost** | OpenAI API fees | OpenAI API fees | Included |
| **Availability** | Global | Global | Regional (US+) |
| **Maturity** | Stable | Emerging | Beta |
| **Primary Use** | K8s operations | Cluster analysis | Docker operations |
| **Internet** | Required | Required | Required |
| **Accuracy** | 80-95% | 70-90% | 75-90% |
| **Best For** | Quick K8s tasks | Audits & reports | Docker debugging |

---

## Best Practices

### 1. Always Verify AI-Generated Commands

```bash
# Use dry-run when available
kubectl ai --dry-run "scale deployment to 10 replicas"

# Review before execution
docker ai --dry-run "build with optimization flags"
```

### 2. Start Simple, Graduate to Complex

```bash
# Good first commands:
kubectl ai "list all pods"
docker ai "show running containers"
k8sgpt analyze --namespace todo-chatbot

# Avoid initially:
# - Multi-step workflows
# - Production changes
# - Security-critical operations
```

### 3. Provide Context

```bash
# Vague: "fix the backend"
# Better: "backend pod in todo-chatbot namespace is CrashLoopBackOff, logs show OPENAI_API_KEY not found"
```

### 4. Learn Standard Commands

```bash
# Use AI to learn, but memorize common operations
kubectl get pods -n todo-chatbot
docker ps
helm list

# AI should augment, not replace, CLI knowledge
```

### 5. Cost Management

```bash
# kubectl-ai and K8sGPT use APIs = costs money

# Monitor usage
# Use GPT-3.5-turbo for simple queries (cheaper)
# Use GPT-4 for complex analysis (accurate, expensive)

# Set budget alerts in OpenAI account
```

### 6. Security Considerations

```bash
# Don't share in AI queries:
# - API keys
# - Passwords
# - Production secrets
# - Customer data

# Queries may be logged
# Check provider privacy policies
```

---

## Limitations

### General

**Accuracy:** Not 100% accurate - always review
**Context:** Don't maintain conversation state
**Training Data:** May not know latest features
**Cost:** API calls cost money
**Internet:** Required for all operations

### Security and Privacy

**Data Sent to AI:**
- Cluster configurations
- Resource names/labels
- Error messages
- Deployment strategies

**Recommendations:**
- Don't use in highly secure environments
- Redact sensitive information
- Review privacy policies
- Use standard CLI for production

---

## Additional Resources

### kubectl-ai
- GitHub: https://github.com/sozercan/kubectl-ai
- Documentation: https://github.com/sozercan/kubectl-ai#readme

### K8sGPT
- GitHub: https://github.com/k8sgpt-ai/k8sgpt
- Documentation: https://docs.k8sgpt.ai/

### Docker AI
- Docker Desktop: https://www.docker.com/products/docker-desktop/
- Release Notes: https://docs.docker.com/desktop/release-notes/

### API Services
- OpenAI: https://platform.openai.com/
- Pricing: https://openai.com/pricing

---

## Conclusion

AI tools enhance productivity but should **complement**, not **replace**, standard CLI expertise.

**Recommended Approach:**
1. Learn kubectl, docker, helm basics
2. Use AI to accelerate repetitive tasks
3. Verify all AI-generated commands
4. Keep fallbacks ready

**For Phase IV Todo Chatbot:**
- Use kubectl-ai for quick troubleshooting
- Use K8sGPT for cluster analysis
- Use Docker AI (if available) for build optimization
- **Always use standard scripts for production**

**Remember:** AI is a powerful assistant, but human judgment remains essential.
