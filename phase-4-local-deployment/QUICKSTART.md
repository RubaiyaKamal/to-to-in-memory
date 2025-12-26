# Phase IV Quick Start

Get Todo Chatbot running on Kubernetes in under 10 minutes!

## ⚡ Fast Track (3 Commands)

```bash
cd phase-4-local-deployment

# 1. Setup Minikube
./scripts/setup-minikube.sh

# 2. Build Docker images
./scripts/build-images.sh

# 3. Deploy with Helm (IMPORTANT: Set OPENAI_API_KEY first!)
# Edit helm/todo-chatbot/values.yaml and add your OpenAI API key
./scripts/deploy-helm.sh
```

**Access**: http://localhost:30080

## 📝 Before You Start

### Required

1. Install Docker Desktop: https://www.docker.com/products/docker-desktop
2. Install Minikube: https://minikube.sigs.k8s.io/docs/start/
3. Install kubectl: https://kubernetes.io/docs/tasks/tools/
4. Install Helm: https://helm.sh/docs/intro/install/
5. Get OpenAI API key: https://platform.openai.com/api-keys

### System Check

```bash
docker --version      # Should be 20.0+
minikube version      # Should be 1.30+
kubectl version       # Should be 1.25+
helm version          # Should be 3.10+
```

## 🚀 Step-by-Step

### Step 1: Configure OpenAI API Key

**For Helm deployment** (recommended):
```bash
# Edit the values file
nano helm/todo-chatbot/values.yaml

# Find this line and replace with your key:
# backend.secret.OPENAI_API_KEY: "your-openai-api-key-here"
```

**For kubectl deployment**:
```bash
# Edit the secret file
nano k8s/base/secret.yaml

# Find this line and replace with your key:
# OPENAI_API_KEY: "your-openai-api-key-here"
```

### Step 2: Setup Minikube

```bash
cd phase-4-local-deployment
./scripts/setup-minikube.sh
```

This will:
- Start Minikube with 4 CPUs and 8GB RAM
- Enable ingress and metrics-server addons
- Configure kubectl context

### Step 3: Build Images

```bash
./scripts/build-images.sh
```

This creates:
- `todo-chatbot-backend:latest` (~300MB)
- `todo-chatbot-frontend:latest` (~50MB)

### Step 4: Deploy

**Option A: Helm** (recommended)
```bash
./scripts/deploy-helm.sh
```

**Option B: kubectl**
```bash
./scripts/deploy-k8s.sh
```

**Option C: Docker Compose** (no Kubernetes)
```bash
cd docker
export OPENAI_API_KEY="your-key"
docker-compose up -d
```

### Step 5: Verify

```bash
./scripts/verify-deployment.sh
```

Expected output:
```
✅ Namespace: todo-chatbot
✅ Deployments: 2/2 ready
✅ Pods: 4/4 running
✅ Services: 2 active
```

### Step 6: Access

- **Frontend**: http://localhost:30080
- **Backend API**:
  ```bash
  kubectl port-forward -n todo-chatbot svc/todo-chatbot-backend 8001:8001
  ```
  Then visit: http://localhost:8001/docs

## 🔍 Common Issues

### Issue: "minikube: command not found"

**Solution**:
```bash
# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Issue: "Insufficient resources"

**Solution**:
```bash
# Delete and recreate with more resources
minikube delete
minikube start --cpus=4 --memory=8192
```

### Issue: "Pod stuck in ImagePullBackOff"

**Solution**:
```bash
# Load images into Minikube
minikube image load todo-chatbot-backend:latest
minikube image load todo-chatbot-frontend:latest
```

### Issue: "Backend pods in CrashLoopBackOff"

**Solution**:
```bash
# Check logs
kubectl logs -n todo-chatbot -l component=backend

# Common cause: Missing/invalid OPENAI_API_KEY
# Fix: Update secret
kubectl edit secret todo-chatbot-secret -n todo-chatbot
```

### Issue: "Cannot access frontend"

**Solution**:
```bash
# Get Minikube IP
minikube ip

# Access at http://<minikube-ip>:30080

# Or use port forwarding
kubectl port-forward -n todo-chatbot svc/todo-chatbot-frontend 3000:80
# Access at http://localhost:3000
```

## 🧪 Test the Application

```bash
# Port forward backend
kubectl port-forward -n todo-chatbot svc/todo-chatbot-backend 8001:8001 &

# Test health endpoint
curl http://localhost:8001/api/health

# Test chat endpoint
curl -X POST http://localhost:8001/api/testuser/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Add a task: Buy groceries",
    "language": "en"
  }'
```

## 🎯 Next Steps

- [ ] Add more tasks via the chatbot
- [ ] Scale backend: `kubectl scale deployment todo-chatbot-backend -n todo-chatbot --replicas=3`
- [ ] View dashboard: `minikube dashboard`
- [ ] Check logs: `kubectl logs -f -n todo-chatbot -l component=backend`
- [ ] Try AI tools: See `docs/AI-DEVOPS.md`

## 🧹 Cleanup

```bash
# Remove everything
./scripts/cleanup.sh

# Or manually
kubectl delete namespace todo-chatbot
minikube delete
```

## 📚 Full Documentation

See [README.md](README.md) for:
- Complete architecture details
- AI-assisted DevOps guide
- Advanced configuration options
- Troubleshooting guide

## 💬 Support

If you encounter issues:
1. Run `./scripts/verify-deployment.sh`
2. Check logs: `kubectl logs -n todo-chatbot -l component=backend`
3. View events: `kubectl get events -n todo-chatbot`
4. Review Phase III docs: `../phase-3-chatbot/QUICKSTART.md`

**Happy deploying! 🚀**
