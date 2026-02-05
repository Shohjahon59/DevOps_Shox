# 🌾 Food API - DevOps Project

Complete CI/CD pipeline for Agriculture Management System.

## 🚀 Quick Start

```bash
# Deploy monitoring
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f kube-prom-values.yaml
helm install loki grafana/loki -n monitoring -f loki-values.yaml

# Deploy app
helm install foodapi ./foodapi-chart

# Setup ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/foodapi-application.yaml
```

## 📊 Access

```bash
# Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# http://localhost:3000 (admin/password from secret)

# ArgoCD  
kubectl port-forward svc/argocd-server -n argocd 8080:443
# https://localhost:8080 (admin/password from secret)

# Food API
kubectl port-forward svc/foodapi 8080:80
# http://localhost:8080/health
```

## 🔧 Setup

1. Add GitHub Secret: `DOCKERHUB_TOKEN`
2. Push to main branch
3. CI/CD runs automatically

## 📁 Structure

```
├── .github/workflows/deploy.yaml    # CI/CD pipeline
├── foodapi/                         # .NET API + Dockerfile  
├── foodapi-chart/                   # Helm chart
├── argocd/                          # ArgoCD config
├── kube-prom-values.yaml           # Prometheus config
└── loki-values.yaml                # Loki config
```

## 🎯 Workflow

```
Push → GitHub Actions → Docker Build → Docker Hub → ArgoCD → Kubernetes
```