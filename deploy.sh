#!/bin/bash

# Get latest image tag from Docker Hub or use provided tag
TAG=${1:-latest}

echo "🚀 Deploying Food API with tag: ${TAG}"

# Update Helm values
sed -i.bak "s|tag: .*|tag: \"${TAG}\"|g" foodapi-chart/values.yaml
rm -f foodapi-chart/values.yaml.bak

# Deploy with Helm
helm upgrade --install foodapi ./foodapi-chart

echo "✅ Deployment complete!"
echo "📦 Image: rashidov2005/foodapi:${TAG}"

# Show status
kubectl get pods -l app.kubernetes.io/name=foodapi