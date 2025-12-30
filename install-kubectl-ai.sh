#!/bin/bash
# Install kubectl-ai plugin

echo "Installing kubectl-ai..."

# Download and install kubectl-ai
KUBECTL_AI_VERSION="v0.0.13"
OS="windows"
ARCH="amd64"

curl -LO "https://github.com/sozercan/kubectl-ai/releases/download/${KUBECTL_AI_VERSION}/kubectl-ai_${KUBECTL_AI_VERSION}_${OS}_${ARCH}.zip"
unzip kubectl-ai_${KUBECTL_AI_VERSION}_${OS}_${ARCH}.zip
chmod +x kubectl-ai.exe
mv kubectl-ai.exe /usr/local/bin/kubectl-ai

echo "kubectl-ai installed successfully!"
kubectl-ai --version
