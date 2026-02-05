# CI/CD Pipeline - Complete Guide

## 🎯 Overview

Bu loyihada to'liq CI/CD pipeline sozlangan:
- **CI (Continuous Integration)**: GitHub Actions orqali avtomatik build va test
- **CD (Continuous Deployment)**: ArgoCD orqali GitOps deployment

## 📋 Pipeline Architecture

```
GitHub Push → GitHub Actions → Docker Build → Docker Hub → ArgoCD → Kubernetes
```

## 🔧 Components

### 1. GitHub Actions Workflows

#### Main CI/CD Pipeline (`.github/workflows/ci-cd.yaml`)
- **Test Job**: .NET build va test
- **Build Job**: Docker image build va push
- **Deploy Job**: Helm values update va ArgoCD sync

#### Local Test Pipeline (`.github/workflows/local-test.yaml`)
- Pull request uchun validation
- Helm chart lint
- Dockerfile check

### 2. ArgoCD Configuration

**Application**: `argocd/foodapi-application.yaml`
- Repository: https://github.com/Shohjahon59/DevOps_Shox.git
- Path: foodapi-chart
- Auto-sync: Enabled
- Self-heal: Enabled

### 3. Helm Chart

**Location**: `foodapi-chart/`
- Deployment
- Service
- ServiceMonitor (Prometheus)
- Configurable via values.yaml

## 🚀 Setup Instructions

### Prerequisites
```bash
# Required tools
- kubectl
- helm
- docker
- git
```

### 1. GitHub Secrets Setup

GitHub repository Settings > Secrets and variables > Actions ga quyidagilarni qo'shing:

```
DOCKERHUB_TOKEN=your_docker_hub_token
```

Docker Hub token olish:
1. https://hub.docker.com/settings/security ga boring
2. "New Access Token" tugmasini bosing
3. Token ni copy qiling va GitHub secrets ga qo'shing

### 2. ArgoCD Setup

```bash
# ArgoCD o'rnatish
./setup-argocd.sh

# Yoki manual:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Admin password olish
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Application deploy
kubectl apply -f argocd/foodapi-application.yaml
```

### 3. Local Image Setup (Development)

```bash
# Docker image build
docker build -t rashidov2005/foodapi:latest -f foodapi/Dockerfile foodapi/

# Minikube ga load qilish
minikube image load rashidov2005/foodapi:latest

# Deploy
helm upgrade --install foodapi ./foodapi-chart -n default
```

## 🔄 CI/CD Workflow

### Automatic Deployment (Production)

1. **Code Push**:
```bash
git add .
git commit -m "feat: add new feature"
git push origin main
```

2. **GitHub Actions** avtomatik ishga tushadi:
   - ✅ Test .NET application
   - ✅ Build Docker image
   - ✅ Push to Docker Hub
   - ✅ Update Helm values
   - ✅ Commit changes

3. **ArgoCD** avtomatik sync qiladi:
   - ✅ Detect changes
   - ✅ Apply to Kubernetes
   - ✅ Health check

### Manual Deployment

```bash
# Helm orqali
helm upgrade --install foodapi ./foodapi-chart \
  --set image.tag=abc123 \
  --namespace default

# ArgoCD orqali
kubectl patch application foodapi -n argocd \
  --type merge \
  -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

## 🧪 Testing

### Local Testing

```bash
# CI/CD pipeline test
./test-cicd.sh

# Manual tests
dotnet test foodapi/FoodApi/FoodApi.csproj
helm lint foodapi-chart/
docker build -t test -f foodapi/Dockerfile foodapi/
```

### Integration Testing

```bash
# Deploy to test environment
helm upgrade --install foodapi-test ./foodapi-chart \
  --set image.tag=test \
  --namespace test \
  --create-namespace

# Test endpoints
kubectl port-forward svc/foodapi-test 8080:80 -n test
curl http://localhost:8080/health
curl http://localhost:8080/metrics
```

## 📊 Monitoring

### Check Deployment Status

```bash
# ArgoCD application status
kubectl get application foodapi -n argocd

# Kubernetes resources
kubectl get all -l app.kubernetes.io/name=foodapi

# Logs
kubectl logs -l app.kubernetes.io/name=foodapi --tail=50
```

### ArgoCD UI

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access: https://localhost:8080
# Username: admin
# Password: (from setup script)
```

## 🔍 Troubleshooting

### Image Pull Errors

```bash
# Check image exists
docker images rashidov2005/foodapi

# Load to minikube
minikube image load rashidov2005/foodapi:latest

# Or push to Docker Hub
docker push rashidov2005/foodapi:latest
```

### ArgoCD Sync Issues

```bash
# Check application status
kubectl get application foodapi -n argocd -o yaml

# Force sync
kubectl patch application foodapi -n argocd \
  --type merge \
  -p '{"operation":{"sync":{"prune":true}}}'

# Delete and recreate
kubectl delete application foodapi -n argocd
kubectl apply -f argocd/foodapi-application.yaml
```

### GitHub Actions Failures

1. Check workflow logs in GitHub Actions tab
2. Verify secrets are set correctly
3. Check Docker Hub credentials
4. Verify repository permissions

## 📝 Best Practices

### 1. Version Tagging

```yaml
# Use semantic versioning
image:
  tag: "v1.2.3"

# Or commit SHA
image:
  tag: "abc123"
```

### 2. Environment Separation

```bash
# Development
helm install foodapi-dev ./foodapi-chart -n dev

# Staging
helm install foodapi-staging ./foodapi-chart -n staging

# Production
helm install foodapi-prod ./foodapi-chart -n prod
```

### 3. Rollback Strategy

```bash
# Helm rollback
helm rollback foodapi 1 -n default

# ArgoCD rollback
kubectl patch application foodapi -n argocd \
  --type merge \
  -p '{"operation":{"sync":{"revision":"previous-commit-sha"}}}'
```

## 🎯 Next Steps

### 1. Add Tests
```bash
# Create test project
dotnet new xunit -n FoodApi.Tests
dotnet add FoodApi.Tests reference FoodApi/FoodApi.csproj
```

### 2. Add Staging Environment
```yaml
# .github/workflows/staging.yaml
on:
  push:
    branches: [ develop ]
```

### 3. Add Notifications
```yaml
# Slack, Discord, or Email notifications
- name: Notify deployment
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
```

### 4. Add Security Scanning
```yaml
# Trivy security scan
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: rashidov2005/foodapi:${{ github.sha }}
```

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Docker Documentation](https://docs.docker.com/)

## ✅ Checklist

- [ ] GitHub secrets configured
- [ ] Docker Hub account ready
- [ ] ArgoCD installed
- [ ] Helm chart validated
- [ ] Local tests passing
- [ ] First deployment successful
- [ ] Monitoring configured
- [ ] Documentation updated