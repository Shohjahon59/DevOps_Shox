# 🌾 Food API - DevOps Project

Simple DevOps setup for Agriculture Management System.

## 🚀 Quick Start

```bash
# Setup everything
./setup.sh

# Build and deploy locally
./build-and-deploy.sh

# Or deploy specific tag
./deploy.sh abc123
```

## 📊 Access

```bash
# Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# http://localhost:3000 (admin/password from secret)

# ArgoCD  
kubectl port-forward -n argocd svc/argocd-server 8080:443
# https://localhost:8080 (admin/password from secret)

# Food API
kubectl port-forward svc/foodapi 8080:80
# http://localhost:8080/health
```

## 🔧 Development Workflow

```bash
# 1. Make changes to code
vim foodapi/FoodApi/Program.cs

# 2. Build, test, and deploy
./build-and-deploy.sh

# 3. Check deployment
kubectl get pods -l app.kubernetes.io/name=foodapi
```

## 📁 Structure

```
├── .github/workflows/simple-build.yaml  # CI (build only)
├── foodapi/                             # .NET API + Dockerfile  
├── foodapi-chart/                       # Helm chart
├── setup.sh                             # Setup everything
├── build-and-deploy.sh                  # Local build & deploy
├── deploy.sh                            # Deploy with tag
└── argocd/                              # ArgoCD config
```

## 🎯 Workflow

```
Local Development → build-and-deploy.sh → Docker → Kubernetes
                                       ↓
GitHub Push → Simple Build (CI) → Manual Deploy
```