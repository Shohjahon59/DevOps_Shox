#!/bin/bash

set -e

echo "🚀 Setting up ArgoCD for Food API..."

# Check if ArgoCD is installed
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ ArgoCD namespace not found. Installing ArgoCD..."
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    echo "⏳ Waiting for ArgoCD to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
else
    echo "✅ ArgoCD is already installed"
fi

# Get ArgoCD admin password
echo ""
echo "📝 ArgoCD Admin Credentials:"
echo "Username: admin"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Password: ${ARGOCD_PASSWORD}"

# Apply Food API application
echo ""
echo "📦 Deploying Food API application to ArgoCD..."
kubectl apply -f argocd/foodapi-application.yaml

# Wait for application to be created
sleep 5

# Check application status
echo ""
echo "📊 Application Status:"
kubectl get application foodapi -n argocd

# Port forward instructions
echo ""
echo "🌐 To access ArgoCD UI:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then open: https://localhost:8080"
echo ""
echo "🔐 Login with:"
echo "Username: admin"
echo "Password: ${ARGOCD_PASSWORD}"

# Sync application
echo ""
read -p "Do you want to sync the application now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Syncing application..."
    kubectl patch application foodapi -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
    echo "✅ Sync initiated"
fi

echo ""
echo "✨ ArgoCD setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Access ArgoCD UI at https://localhost:8080"
echo "2. Check application status"
echo "3. Push changes to trigger CI/CD pipeline"