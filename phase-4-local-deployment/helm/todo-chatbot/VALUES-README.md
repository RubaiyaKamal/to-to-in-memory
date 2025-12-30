# Helm Values Files Guide

Task 3.3: Helm Values Examples
Reference: specs/003-local-k8s-deployment/tasks.md

This directory contains example values files for deploying the Todo Chatbot application to different environments.

## Available Values Files

### 1. values.yaml (Default)
The base values file with sensible defaults for general use.

**Use Case:** Template for creating custom values files
**Environment:** Generic
**Replica Count:** 2 (backend), 2 (frontend)
**Log Level:** INFO
**Resources:** Moderate (256Mi-512Mi backend, 128Mi-256Mi frontend)

### 2. values-local.yaml
Optimized for local development with Minikube.

**Use Case:** Local development and testing
**Environment:** Local/Minikube
**Replica Count:** 1 (backend), 1 (frontend)
**Log Level:** DEBUG
**Resources:** Minimal (128Mi-256Mi backend, 64Mi-128Mi frontend)
**Storage:** 500Mi PVC
**Service Type:** NodePort (30080)
**Image Pull Policy:** IfNotPresent (uses local images)

**Key Features:**
- Single replica for resource efficiency
- Debug logging enabled
- NodePort service for easy access
- Smaller resource limits
- Uses local Docker images from Minikube

**Installation:**
```bash
# Load secrets first
export OPENAI_API_KEY="sk-proj-your-key"
export BETTER_AUTH_SECRET="your-secret-min-32-chars"

# Install with local values
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f phase-4-local-deployment/helm/todo-chatbot/values-local.yaml \
  --set secrets.OPENAI_API_KEY="$OPENAI_API_KEY" \
  --set secrets.BETTER_AUTH_SECRET="$BETTER_AUTH_SECRET"

# Access the application
minikube service todo-chatbot-frontend -n todo-chatbot
```

### 3. values-dev.yaml
Configured for development environment with CI/CD integration.

**Use Case:** Shared development environment
**Environment:** Development cluster
**Replica Count:** 2 (backend), 2 (frontend)
**Log Level:** INFO
**Resources:** Moderate (256Mi-512Mi backend, 128Mi-256Mi frontend)
**Storage:** 2Gi PVC
**Service Type:** ClusterIP with Ingress
**Image Pull Policy:** Always (pulls latest dev images)
**Autoscaling:** Enabled (2-4 replicas)

**Key Features:**
- High availability with 2 replicas
- Info level logging for debugging
- Ingress with staging TLS certificates
- Autoscaling enabled for load testing
- Pulls latest development images
- Separate namespace (todo-chatbot-dev)

**Installation:**
```bash
# Install with development values
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f phase-4-local-deployment/helm/todo-chatbot/values-dev.yaml \
  --set secrets.OPENAI_API_KEY="$DEV_OPENAI_API_KEY" \
  --set secrets.BETTER_AUTH_SECRET="$DEV_BETTER_AUTH_SECRET"

# Access via ingress
# https://dev.todo-chatbot.example.com
# https://dev-api.todo-chatbot.example.com
```

### 4. values-prod.yaml
Production-ready configuration with high availability and security.

**Use Case:** Production deployment
**Environment:** Production cluster
**Replica Count:** 3 (backend), 3 (frontend)
**Log Level:** WARNING (errors only)
**Resources:** High (512Mi-1Gi backend, 256Mi-512Mi frontend)
**Storage:** 10Gi SSD PVC
**Service Type:** ClusterIP with Production Ingress
**Image Pull Policy:** IfNotPresent (stable versioned images)
**Autoscaling:** Enabled (3-10 replicas)

**Key Features:**
- High availability with 3 replicas minimum
- Warning-level logging only
- Production TLS certificates (Let's Encrypt)
- Autoscaling (3-10 replicas based on CPU/memory)
- Pod Disruption Budget (minimum 2 pods always available)
- Network policies for security
- Rate limiting and request size limits
- Service monitoring enabled
- Semantic versioning for images (not 'latest')
- Separate namespace (todo-chatbot-prod)

**Production Checklist:**
- [ ] Secrets managed via Vault/AWS Secrets Manager/Azure Key Vault
- [ ] TLS certificates configured (cert-manager)
- [ ] Monitoring and alerting configured (Prometheus/Grafana)
- [ ] Backup strategy for persistent data
- [ ] Resource quotas and limits defined
- [ ] Network policies configured
- [ ] Container images scanned for vulnerabilities
- [ ] Log aggregation configured (ELK/Loki)
- [ ] Disaster recovery plan documented

**Installation:**
```bash
# IMPORTANT: Use secure secret management for production
# DO NOT pass secrets via --set in production

# Example with Kubernetes secret created from Vault
kubectl create secret generic todo-chatbot-secrets \
  --from-literal=OPENAI_API_KEY="$PROD_OPENAI_API_KEY" \
  --from-literal=BETTER_AUTH_SECRET="$PROD_BETTER_AUTH_SECRET" \
  -n todo-chatbot-prod

# Install with production values
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f phase-4-local-deployment/helm/todo-chatbot/values-prod.yaml \
  --namespace todo-chatbot-prod

# Access via production domain
# https://todo-chatbot.example.com
# https://api.todo-chatbot.example.com
```

## Environment Comparison

| Feature | Local | Dev | Prod |
|---------|-------|-----|------|
| **Replicas (Backend)** | 1 | 2 | 3 |
| **Replicas (Frontend)** | 1 | 2 | 3 |
| **Log Level** | DEBUG | INFO | WARNING |
| **Backend Memory** | 128-256Mi | 256-512Mi | 512Mi-1Gi |
| **Frontend Memory** | 64-128Mi | 128-256Mi | 256-512Mi |
| **Storage Size** | 500Mi | 2Gi | 10Gi |
| **Storage Class** | standard | standard | ssd |
| **Service Type** | NodePort | ClusterIP | ClusterIP |
| **External Access** | NodePort:30080 | Ingress | Ingress |
| **TLS** | None | Staging | Production |
| **Autoscaling** | Disabled | 2-4 | 3-10 |
| **Image Tag** | latest | dev-latest | 1.0.0 |
| **Image Pull Policy** | IfNotPresent | Always | IfNotPresent |
| **Pod Disruption Budget** | No | No | Yes (min 2) |
| **Network Policies** | No | No | Yes |

## Customizing Values

### Creating a Custom Values File

1. Copy an existing values file:
```bash
cp values-local.yaml values-custom.yaml
```

2. Modify the settings for your environment:
```yaml
# values-custom.yaml
global:
  environment: custom

backend:
  replicaCount: 3
  resources:
    limits:
      memory: "2Gi"
      cpu: "2000m"
```

3. Install with your custom values:
```bash
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-custom.yaml
```

### Overriding Individual Values

Override specific values without creating a new file:

```bash
# Override replica count
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-local.yaml \
  --set backend.replicaCount=3 \
  --set frontend.replicaCount=3

# Override image tags
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-local.yaml \
  --set backend.image.tag=v1.2.3 \
  --set frontend.image.tag=v1.2.3

# Override namespace
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-local.yaml \
  --set namespace.name=my-custom-namespace
```

### Combining Multiple Values Files

Layer multiple values files (later files override earlier ones):

```bash
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values.yaml \
  -f values-dev.yaml \
  -f values-custom.yaml
```

## Secret Management Best Practices

### Local Development
```bash
# Use environment variables
export OPENAI_API_KEY="sk-proj-..."
export BETTER_AUTH_SECRET="..."

helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-local.yaml \
  --set secrets.OPENAI_API_KEY="$OPENAI_API_KEY" \
  --set secrets.BETTER_AUTH_SECRET="$BETTER_AUTH_SECRET"
```

### Development/Production
```bash
# Create Kubernetes secret from secure source
kubectl create secret generic todo-chatbot-secrets \
  --from-literal=OPENAI_API_KEY="$(vault kv get -field=OPENAI_API_KEY secret/todo-chatbot)" \
  --from-literal=BETTER_AUTH_SECRET="$(vault kv get -field=BETTER_AUTH_SECRET secret/todo-chatbot)" \
  -n todo-chatbot-prod

# Reference existing secret in values
# (requires template modification to support external secrets)
```

## Validation

Before deploying, validate your values file:

```bash
# Lint the chart with custom values
helm lint ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-custom.yaml

# Dry-run to see rendered manifests
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-custom.yaml \
  --dry-run --debug

# Template render only (no installation)
helm template todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-custom.yaml
```

## Upgrading Deployments

Update an existing deployment with new values:

```bash
# Upgrade with new values
helm upgrade todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-prod.yaml \
  --set backend.image.tag=v1.1.0

# View upgrade history
helm history todo-chatbot

# Rollback if needed
helm rollback todo-chatbot 1
```

## Troubleshooting

### Issue: Pods not starting
```bash
# Check pod status
kubectl get pods -n todo-chatbot

# Describe pod for events
kubectl describe pod <pod-name> -n todo-chatbot

# Check logs
kubectl logs <pod-name> -n todo-chatbot
```

### Issue: Wrong values applied
```bash
# Check what values are currently set
helm get values todo-chatbot

# View full manifest
helm get manifest todo-chatbot

# Re-install with correct values
helm uninstall todo-chatbot
helm install todo-chatbot ./phase-4-local-deployment/helm/todo-chatbot \
  -f values-correct.yaml
```

## Additional Resources

- Main README: `phase-4-local-deployment/helm/todo-chatbot/README.md`
- Chart Documentation: `phase-4-local-deployment/helm/todo-chatbot/Chart.yaml`
- Tasks: `specs/003-local-k8s-deployment/tasks.md`
- Kubernetes Manifests: `phase-4-local-deployment/k8s/base/`
