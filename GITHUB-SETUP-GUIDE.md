# 🚀 GitHub Repository Setup Guide

## ✅ Repository Status

**Repository**: https://github.com/Shohjahon59/DevOps_Shox
**Status**: ✅ All files pushed successfully
**Branch**: main
**CI/CD**: Ready to activate

## 🔐 GitHub Secrets Setup

GitHub Actions ishga tushishi uchun secrets sozlash kerak:

### 1. Docker Hub Token Olish

1. **Docker Hub ga kiring**: https://hub.docker.com/
2. **Account Settings** > **Security** ga boring
3. **New Access Token** tugmasini bosing
4. **Access Token Description**: `GitHub Actions CI/CD`
5. **Access permissions**: `Read, Write, Delete`
6. **Generate** tugmasini bosing
7. **Token ni copy qiling** (faqat bir marta ko'rsatiladi!)

### 2. GitHub Secrets Qo'shish

1. **Repository ga boring**: https://github.com/Shohjahon59/DevOps_Shox
2. **Settings** tab ni bosing
3. **Secrets and variables** > **Actions** ga boring
4. **New repository secret** tugmasini bosing
5. **Name**: `DOCKERHUB_TOKEN`
6. **Secret**: Docker Hub token ni paste qiling
7. **Add secret** tugmasini bosing

### 3. CI/CD Pipeline Aktivlashtirish

GitHub Secrets qo'shilgandan keyin:

1. **Actions** tab ga boring
2. **CI/CD Pipeline** workflow ni tanlang
3. **Enable workflow** tugmasini bosing (agar disabled bo'lsa)

## 🧪 Pipeline Test Qilish

### Test Push

```bash
# Local da test o'zgarish qiling
echo "# Test update" >> README.md

# Commit va push qiling
git add README.md
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

### Pipeline Monitoring

1. **GitHub** > **Actions** tab ga boring
2. **CI/CD Pipeline** workflow ni kuzating
3. **Jobs** ni ochib, har bir step ni ko'ring:
   - ✅ Test (.NET build)
   - ✅ Build and Push (Docker)
   - ✅ Deploy (Helm values update)

## 📊 ArgoCD Integration

### ArgoCD Application Status

ArgoCD allaqachon configured:
- **Repository**: https://github.com/Shohjahon59/DevOps_Shox.git
- **Path**: foodapi-chart
- **Auto-sync**: Enabled
- **Self-heal**: Enabled

### ArgoCD UI Access

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access: https://localhost:8080
# Username: admin
# Password: (run command below)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 🔄 Complete Workflow

### 1. Code Change
```bash
# Make changes to Food API
vim foodapi/FoodApi/Program.cs

# Commit and push
git add .
git commit -m "feat: add new endpoint"
git push origin main
```

### 2. GitHub Actions (Automatic)
- ✅ Run tests
- ✅ Build Docker image
- ✅ Push to Docker Hub
- ✅ Update Helm values
- ✅ Commit changes

### 3. ArgoCD (Automatic)
- ✅ Detect changes
- ✅ Sync to Kubernetes
- ✅ Deploy new version
- ✅ Health check

## 📁 Repository Structure

```
Shohjahon59/DevOps_Shox/
├── .github/workflows/
│   ├── ci-cd.yaml              ✅ Main CI/CD pipeline
│   └── local-test.yaml         ✅ PR validation
├── argocd/
│   └── foodapi-application.yaml ✅ ArgoCD config
├── foodapi/
│   ├── Dockerfile              ✅ Multi-stage build
│   └── FoodApi/                ✅ .NET 8.0 API
├── foodapi-chart/              ✅ Helm chart
├── monitoring configs/         ✅ Prometheus, Grafana, Loki
└── documentation/              ✅ Complete guides
```

## 🎯 Next Steps

### 1. Activate CI/CD
- [ ] Add DOCKERHUB_TOKEN secret
- [ ] Test pipeline with dummy commit
- [ ] Verify Docker image build
- [ ] Check ArgoCD sync

### 2. Monitoring Setup
- [ ] Access Grafana dashboards
- [ ] Verify Prometheus metrics
- [ ] Check Loki logs
- [ ] Test alert rules

### 3. Production Deployment
- [ ] Create production branch
- [ ] Set up staging environment
- [ ] Configure notifications
- [ ] Add security scanning

## 🛠 Troubleshooting

### Pipeline Failures

**Docker Build Fails**:
```bash
# Check Dockerfile
docker build -t test -f foodapi/Dockerfile foodapi/
```

**Push Fails**:
- Verify DOCKERHUB_TOKEN is correct
- Check Docker Hub repository exists
- Ensure token has write permissions

**ArgoCD Sync Issues**:
```bash
# Check application status
kubectl get application foodapi -n argocd -o yaml

# Force sync
kubectl patch application foodapi -n argocd \
  --type merge \
  -p '{"operation":{"sync":{"prune":true}}}'
```

## 📞 Support

### Useful Commands

```bash
# Check pipeline status
gh run list --repo Shohjahon59/DevOps_Shox

# View workflow logs
gh run view --repo Shohjahon59/DevOps_Shox

# Check ArgoCD apps
kubectl get applications -n argocd

# Monitor deployments
kubectl get pods -l app.kubernetes.io/name=foodapi -w
```

### Documentation Links

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [ArgoCD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)

## ✅ Checklist

- [ ] Repository accessible: https://github.com/Shohjahon59/DevOps_Shox
- [ ] DOCKERHUB_TOKEN secret added
- [ ] CI/CD pipeline enabled
- [ ] First test deployment successful
- [ ] ArgoCD application synced
- [ ] Monitoring dashboards accessible
- [ ] Documentation reviewed

## 🎉 Success!

Your complete DevOps pipeline is now live on GitHub:
- 🚀 **Automated CI/CD** with GitHub Actions
- 🔄 **GitOps deployment** with ArgoCD  
- 📊 **Full monitoring** with Prometheus/Grafana/Loki
- 📚 **Comprehensive documentation**
- 🛡️ **Production-ready** configuration

**Repository**: https://github.com/Shohjahon59/DevOps_Shox 🎊