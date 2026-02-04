# Complete Monitoring Stack Setup Instructions

## Prerequisites
- Kubernetes cluster (minikube, kind, or cloud provider)
- Helm 3.x installed
- kubectl configured
- Docker installed
- GitHub account with repositories:
  - `Shohjahon59/foodapi` (main application repo)
  - `Shohjahon59/foodapi-gitops` (GitOps repo for ArgoCD)

## Step 1: Install Monitoring Stack

### 1.1 Add Helm Repositories
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 1.2 Create Monitoring Namespace
```bash
kubectl create namespace monitoring
```

### 1.3 Install Prometheus Stack
```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring -f kube-prom-values.yaml
```

### 1.4 Install Loki
```bash
helm install loki grafana/loki -n monitoring -f loki-values.yaml
```

### 1.5 Install Promtail (Log Collector)
```bash
helm install promtail grafana/promtail -n monitoring \
  --set config.clients[0].url=http://loki:3100/loki/api/v1/push
```

## Step 2: Access Grafana Dashboard

### 2.1 Get Grafana Admin Password
```bash
kubectl get secret --namespace monitoring kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode
```

### 2.2 Port Forward to Grafana
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

### 2.3 Login to Grafana
- URL: http://localhost:3000
- Username: admin
- Password: (from step 2.1)

## Step 3: Configure Data Sources

### 3.1 Add Prometheus Data Source
- Go to Configuration > Data Sources
- Add Prometheus data source
- URL: http://kube-prometheus-stack-prometheus:9090
- Save & Test

### 3.2 Add Loki Data Source
- Add Loki data source
- URL: http://loki:3100
- Save & Test

## Step 4: Build and Deploy Food API

### 4.1 Build Docker Image
```bash
cd foodapi
docker build -t rashidov2005/foodapi:latest .
docker push rashidov2005/foodapi:latest
```

### 4.2 Deploy with Helm
```bash
helm install foodapi ./foodapi-chart -n default
```

### 4.3 Apply Prometheus Configuration
```bash
kubectl apply -f prometheus-config.yaml
```

## Step 5: Install ArgoCD

### 5.1 Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 5.2 Get ArgoCD Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### 5.3 Port Forward to ArgoCD
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 5.4 Deploy Food API Application
```bash
kubectl apply -f argocd/foodapi-application.yaml
```

## Step 6: GitHub Actions Setup

### 6.1 Create GitHub Secrets
In your GitHub repository settings, add these secrets:
- `DOCKER_PASSWORD`: Your Docker Hub password
- `GITOPS_TOKEN`: GitHub personal access token for GitOps repo

### 6.2 Create GitOps Repository
Create a new repository `Shohjahon59/foodapi-gitops` and copy the `foodapi-chart` directory there.

## Step 7: Test the Setup

### 7.1 Test Food API Endpoints
```bash
# Port forward to food API
kubectl port-forward svc/foodapi 8080:80

# Test health endpoint
curl http://localhost:8080/health

# Test metrics endpoint
curl http://localhost:8080/metrics

# Create orders to generate metrics
curl -X POST http://localhost:8080/orders
```

### 7.2 Verify Metrics in Prometheus
- Access Prometheus: `kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090`
- URL: http://localhost:9090
- Query: `foodapi_orders_created_total`

### 7.3 View Logs in Grafana
- Go to Explore in Grafana
- Select Loki data source
- Query: `{app="foodapi"}`

## Step 8: Create Dashboards

### 8.1 Import Pre-built Dashboards
In Grafana, import these dashboard IDs:
- 315: Kubernetes cluster monitoring
- 1860: Node Exporter Full
- 13332: Kubernetes Pods

### 8.2 Create Custom Food API Dashboard
Create panels with queries from `monitoring-queries.md`:
- Request rate
- Response time
- Error rate
- Custom business metrics

## Step 9: Set Up Alerts

### 9.1 Configure Alertmanager
Edit the alertmanager configuration to add notification channels (Slack, email, etc.)

### 9.2 Create Alert Rules
Apply custom alert rules for your Food API:
```bash
kubectl apply -f alert-rules.yaml
```

## Troubleshooting

### Common Issues

1. **Node Exporter Pending**: Check if host mount propagation is disabled
2. **Metrics Not Appearing**: Verify ServiceMonitor labels match Prometheus selector
3. **Logs Not Showing**: Check Promtail configuration and Loki connectivity
4. **ArgoCD Sync Issues**: Verify GitOps repository permissions and webhook configuration

### Useful Commands

```bash
# Check pod status
kubectl get pods -n monitoring

# View logs
kubectl logs -n monitoring <pod-name>

# Check services
kubectl get svc -n monitoring

# Describe resources
kubectl describe servicemonitor foodapi -n default
```

## Next Steps

1. Set up proper ingress controllers for external access
2. Configure persistent storage for Prometheus and Loki
3. Set up backup and disaster recovery
4. Implement proper RBAC and security policies
5. Add more comprehensive alerting rules
6. Set up log aggregation and analysis
7. Implement distributed tracing with Jaeger
8. Add performance testing and SLI/SLO monitoring