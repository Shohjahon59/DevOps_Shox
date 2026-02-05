#!/bin/bash

set -e

echo "🔄 Syncing ArgoCD Application..."

# Method 1: Using kubectl patch
echo "Triggering sync via kubectl..."
kubectl patch application foodapi -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD","prune":true}}}'

echo "⏳ Waiting for sync to complete..."
sleep 10

# Check status
echo ""
echo "📊 Application Status:"
kubectl get application foodapi -n argocd

echo ""
echo "📦 Resources:"
kubectl get all -n default -l app.kubernetes.io/name=foodapi

echo ""
echo "✅ Sync complete!"