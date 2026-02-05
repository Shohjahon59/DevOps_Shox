#!/bin/bash

echo "🚀 Setting up Food API DevOps Stack..."

# 1. Create namespaces
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# 2. Install monitoring
echo "📊 Installing Prometheus & Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring -f kube-prom-values.yaml

helm upgrade --install loki grafana/loki \
  -n monitoring -f loki-values.yaml

# 3. Install ArgoCD
echo "🔄 Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 4. Deploy Food API
echo "🌾 Deploying Food API..."
helm upgrade --install foodapi ./foodapi-chart

# 5. Setup ArgoCD app
echo "⏳ Waiting for ArgoCD..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl apply -f argocd/foodapi-application.yaml

# 6. Get access info
echo ""
echo "✅ Setup complete!"
echo ""
echo "🔐 Access Information:"
echo "Grafana: kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "ArgoCD:  kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "Food API: kubectl port-forward svc/foodapi 8080:80"
echo ""
echo "🔑 Get passwords:"
echo "Grafana: kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d"
echo "ArgoCD:  kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"