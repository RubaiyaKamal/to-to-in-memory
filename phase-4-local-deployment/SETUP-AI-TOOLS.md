# AI-Assisted Kubernetes Tools Setup Guide

## kubectl-ai Installation

kubectl-ai uses OpenAI to generate Kubernetes manifests from natural language.

### Windows Installation

1. **Download kubectl-ai**:
   ```bash
   # Using PowerShell
   $version = "v0.0.13"
   Invoke-WebRequest -Uri "https://github.com/sozercan/kubectl-ai/releases/download/$version/kubectl-ai_${version}_windows_amd64.zip" -OutFile kubectl-ai.zip
   Expand-Archive kubectl-ai.zip -DestinationPath .
   Move-Item kubectl-ai.exe C:\Windows\System32\
   ```

   Or download manually from: https://github.com/sozercan/kubectl-ai/releases

2. **Configure OpenAI API Key**:
   ```bash
   # Set environment variable (Git Bash)
   export OPENAI_API_KEY="your-openai-api-key-here"

   # Or add to ~/.bashrc
   echo 'export OPENAI_API_KEY="your-openai-api-key-here"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Verify Installation**:
   ```bash
   kubectl-ai --version
   ```

### Usage Examples

```bash
# Generate a deployment
kubectl-ai "create a deployment for nginx with 3 replicas"

# Generate a service
kubectl-ai "create a service for my-app on port 8080"

# Generate Helm values
kubectl-ai "create helm values for a todo app with backend and frontend"
```

## kagent Installation

kagent is a Kubernetes AI agent for cluster management.

### Installation Options

**Option 1: Using Go**
```bash
go install github.com/kubeshop/kagent@latest
```

**Option 2: Using Docker**
```bash
docker pull kubeshop/kagent:latest
alias kagent="docker run --rm -v ~/.kube:/root/.kube kubeshop/kagent"
```

**Option 3: Binary Download**
Download from: https://github.com/kubeshop/kagent/releases

### Configure kagent

1. **Set OpenAI API Key**:
   ```bash
   export OPENAI_API_KEY="your-openai-api-key-here"
   ```

2. **Verify Installation**:
   ```bash
   kagent --version
   ```

### Usage Examples

```bash
# Diagnose pod issues
kagent diagnose pod my-pod

# Get cluster insights
kagent analyze cluster

# Troubleshoot deployment
kagent troubleshoot deployment my-deployment
```

## Alternative: Use kubectl with AI Prompting

If you don't have OpenAI API key or prefer not to use these tools, you can:

1. Use this documentation to generate manifests manually
2. Use Helm charts directly (already provided in this repo)
3. Use kubectl explain for Kubernetes resource documentation

```bash
kubectl explain deployment
kubectl explain service
kubectl explain pod.spec
```

## Next Steps

Once tools are installed:
1. Start Minikube: `minikube start`
2. Build Docker images
3. Load images into Minikube
4. Deploy using Helm
