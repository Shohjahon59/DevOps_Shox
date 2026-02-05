# 🌾 Food API - DevOps Project

Simple CI/CD pipeline for Agriculture Management System.

## 🚀 Quick Start

```bash
# Setup everything
./setup.sh

# Deploy app manually  
./deploy.sh [tag]
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

## 🔧 CI/CD Setup

1. Add GitHub Secret: `DOCKERHUB_TOKEN`
2. Push to main → Docker image builds automatically
3. Deploy manually: `./deploy.sh abc123`

## 📁 Structure

```
├── .github/workflows/deploy.yaml    # CI builds Docker image
├── foodapi/                         # .NET API + Dockerfile  
├── foodapi-chart/                   # Helm chart
├── setup.sh                         # Setup everything
├── deploy.sh                        # Deploy with tag
└── argocd/                          # ArgoCD config
```

## 🎯 Workflow

```
Push → GitHub Actions → Docker Build → Docker Hub
                                    ↓
Manual Deploy ← Helm ← ./deploy.sh [tag]
```