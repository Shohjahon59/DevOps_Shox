# Screenshot va Testing Guide

## 🎯 Grafana Dashboard Screenshots

### 1. Grafana Access
- **URL**: http://localhost:3000
- **Username**: admin
- **Password**: JuLrWElc0BIGgRXvsO21BesXAZk2PGfgTUpBQAVc

### 2. Data Sources ni Tekshirish
1. Grafana ga kiring
2. Configuration > Data Sources ga boring
3. Prometheus va Loki data sources mavjudligini tekshiring
4. Test & Save tugmasini bosing

### 3. Prometheus Metrics Screenshots
**Prometheus URL**: http://localhost:9090

#### Food API Custom Metrics:
```promql
# Orders created
foodapi_orders_created_total

# Active users
foodapi_active_users

# Crops monitored
foodapi_crops_monitored

# Order processing duration
rate(foodapi_order_duration_seconds_sum[5m]) / rate(foodapi_order_duration_seconds_count[5m])
```

#### System Metrics:
```promql
# CPU usage
rate(container_cpu_usage_seconds_total[5m]) * 100

# Memory usage
container_memory_working_set_bytes / 1024 / 1024

# Pod status
up{job="kubernetes-pods"}
```

### 4. Loki Logs Screenshots

#### LogQL Queries:
```logql
# All Food API logs
{app="log-generator"}

# Agriculture system logs
{app="agriculture-logs"}

# Error logs
{app=~"log-generator|agriculture-logs"} |= "ERROR"

# Order processing logs
{app="log-generator"} |= "Order"

# Sensor logs
{app="agriculture-logs"} |= "Sensor"
```

## 🔍 Health Check Testing

### 1. Food API Health Check
```bash
# Port forward to Food API
kubectl port-forward svc/foodapi-metrics 8080:80

# Test endpoints
curl http://localhost:8080/health
curl http://localhost:8080/metrics
curl http://localhost:8080/
```

### 2. Prometheus Targets Check
1. Prometheus ga boring: http://localhost:9090
2. Status > Targets ga boring
3. foodapi-metrics target UP holatda ekanligini tekshiring

### 3. Loki Logs Check
1. Grafana da Explore ga boring
2. Loki data source ni tanlang
3. Query: `{app="log-generator"}` yozing
4. Run query tugmasini bosing

## 📊 Dashboard Creation

### 1. Food API Dashboard
1. Grafana da "+" > Dashboard
2. Add panel
3. Quyidagi queries ni qo'shing:

**Panel 1: Orders Created**
- Query: `foodapi_orders_created_total`
- Visualization: Stat

**Panel 2: Active Users**
- Query: `foodapi_active_users`
- Visualization: Stat

**Panel 3: Crops Monitored**
- Query: `foodapi_crops_monitored`
- Visualization: Stat

**Panel 4: Order Processing Time**
- Query: `rate(foodapi_order_duration_seconds_sum[5m]) / rate(foodapi_order_duration_seconds_count[5m])`
- Visualization: Stat
- Unit: seconds

### 2. Logs Dashboard
1. Yangi dashboard yarating
2. Add panel
3. Visualization: Logs
4. Data source: Loki
5. Query: `{app=~"log-generator|agriculture-logs"}`

## 🚀 ArgoCD Setup

### 1. ArgoCD Access
- **URL**: https://localhost:8080
- **Username**: admin
- **Password**: XzJLXhvm-MkIleJ6

### 2. Food API Application Deploy
```bash
kubectl apply -f argocd/foodapi-application.yaml
```

### 3. ArgoCD UI da Application ni ko'rish
1. ArgoCD ga kiring
2. Applications bo'limiga boring
3. foodapi application ni ko'ring
4. Sync tugmasini bosing

## 📸 Screenshot Checklist

### Grafana Screenshots:
- [ ] Data Sources page (Prometheus va Loki)
- [ ] Prometheus metrics dashboard
- [ ] Food API custom metrics
- [ ] Loki logs dashboard
- [ ] Log queries results
- [ ] System monitoring dashboard

### Prometheus Screenshots:
- [ ] Prometheus targets page
- [ ] Food API metrics query results
- [ ] Graph visualization
- [ ] Alert rules (agar mavjud bo'lsa)

### ArgoCD Screenshots:
- [ ] ArgoCD applications page
- [ ] Food API application details
- [ ] Sync status
- [ ] Resource tree

## 🧪 Testing Commands

### Metrics Testing:
```bash
# Test Food API metrics endpoint
curl http://localhost:8080/metrics | grep foodapi

# Check if metrics are in Prometheus
curl "http://localhost:9090/api/v1/query?query=foodapi_orders_created_total"
```

### Logs Testing:
```bash
# Check log generator pods
kubectl get pods -l app=log-generator
kubectl get pods -l app=agriculture-logs

# View logs
kubectl logs -l app=log-generator --tail=10
kubectl logs -l app=agriculture-logs --tail=10
```

### ArgoCD Testing:
```bash
# Check ArgoCD status
kubectl get pods -n argocd

# Check applications
kubectl get applications -n argocd
```

## 🎨 Dashboard Import

### Pre-built Dashboards:
1. Grafana da "+" > Import
2. Quyidagi ID larni import qiling:
   - **315**: Kubernetes cluster monitoring
   - **1860**: Node Exporter Full
   - **13332**: Kubernetes Pods
   - **12019**: Loki Dashboard

## 🔧 Troubleshooting

### Agar metrics ko'rinmasa:
1. ServiceMonitor ni tekshiring: `kubectl get servicemonitor`
2. Prometheus targets ni tekshiring
3. Pod annotations ni tekshiring

### Agar logs ko'rinmasa:
1. Promtail pods ni tekshiring: `kubectl get pods -n monitoring | grep promtail`
2. Loki service ni tekshiring: `kubectl get svc -n monitoring | grep loki`
3. Log generator pods ni tekshiring

### Port forwarding issues:
```bash
# Kill existing port forwards
pkill -f "port-forward"

# Restart port forwards
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 &
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090 &
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```

## 📋 Final Checklist

- [ ] Grafana accessible va data sources configured
- [ ] Prometheus metrics visible
- [ ] Loki logs flowing
- [ ] Food API health checks passing
- [ ] ArgoCD installed va accessible
- [ ] Custom dashboards created
- [ ] Screenshots taken
- [ ] All services healthy