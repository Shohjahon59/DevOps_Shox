# PromQL and LogQL Learning Guide

## PromQL (Prometheus Query Language) Examples

### Basic Metrics Queries
```promql
# CPU usage by pod
rate(container_cpu_usage_seconds_total[5m])

# Memory usage by pod
container_memory_working_set_bytes

# HTTP request rate
rate(http_requests_total[5m])

# HTTP request duration
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### Food API Custom Metrics
```promql
# Total orders created
foodapi_orders_created_total

# Order creation rate (per second)
rate(foodapi_orders_created_total[5m])

# Order processing duration (95th percentile)
histogram_quantile(0.95, rate(foodapi_order_duration_seconds_bucket[5m]))

# Average order processing time
rate(foodapi_order_duration_seconds_sum[5m]) / rate(foodapi_order_duration_seconds_count[5m])
```

### System Metrics
```promql
# Node CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Node memory usage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage
100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)

# Network traffic
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

### Kubernetes Metrics
```promql
# Pod restart count
kube_pod_container_status_restarts_total

# Pod CPU requests vs limits
kube_pod_container_resource_requests{resource="cpu"}
kube_pod_container_resource_limits{resource="cpu"}

# Pod memory requests vs limits
kube_pod_container_resource_requests{resource="memory"}
kube_pod_container_resource_limits{resource="memory"}

# Number of running pods
kube_pod_status_phase{phase="Running"}
```

## LogQL (Loki Query Language) Examples

### Basic Log Queries
```logql
# All logs from foodapi
{app="foodapi"}

# Logs containing "error"
{app="foodapi"} |= "error"

# Logs NOT containing "health"
{app="foodapi"} != "health"

# Logs with regex pattern
{app="foodapi"} |~ "Order.*created"
```

### Log Aggregations
```logql
# Count of log lines per minute
count_over_time({app="foodapi"}[1m])

# Rate of log lines per second
rate({app="foodapi"}[5m])

# Count of error logs
count_over_time({app="foodapi"} |= "error" [5m])

# Error rate
rate({app="foodapi"} |= "error" [5m])
```

### Advanced LogQL
```logql
# Extract JSON fields
{app="foodapi"} | json | level="error"

# Parse log format
{app="foodapi"} | pattern `<timestamp> <level> <message>`

# Count by log level
sum by (level) (count_over_time({app="foodapi"} | json [5m]))

# Top error messages
topk(10, count by (message) (count_over_time({app="foodapi"} |= "error" [1h])))
```

## Useful Grafana Dashboard Queries

### Food API Dashboard Panels

#### Request Rate Panel
```promql
sum(rate(http_requests_total{job="foodapi"}[5m])) by (method, status)
```

#### Response Time Panel
```promql
histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket{job="foodapi"}[5m])) by (le))
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job="foodapi"}[5m])) by (le))
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{job="foodapi"}[5m])) by (le))
```

#### Error Rate Panel
```promql
sum(rate(http_requests_total{job="foodapi",status=~"5.."}[5m])) / sum(rate(http_requests_total{job="foodapi"}[5m])) * 100
```

#### Custom Business Metrics Panel
```promql
# Orders per minute
increase(foodapi_orders_created_total[1m])

# Average order processing time
avg(rate(foodapi_order_duration_seconds_sum[5m]) / rate(foodapi_order_duration_seconds_count[5m]))
```

## Alert Rules Examples

### Prometheus Alert Rules
```yaml
groups:
- name: foodapi.rules
  rules:
  - alert: FoodAPIHighErrorRate
    expr: sum(rate(http_requests_total{job="foodapi",status=~"5.."}[5m])) / sum(rate(http_requests_total{job="foodapi"}[5m])) > 0.05
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Food API has high error rate"
      description: "Food API error rate is {{ $value | humanizePercentage }}"

  - alert: FoodAPIHighLatency
    expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job="foodapi"}[5m])) by (le)) > 1
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Food API has high latency"
      description: "Food API 95th percentile latency is {{ $value }}s"

  - alert: FoodAPIPodDown
    expr: up{job="foodapi"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Food API pod is down"
      description: "Food API pod has been down for more than 1 minute"
```

## Tips for Writing Effective Queries

1. **Use rate() for counters**: Always use `rate()` or `increase()` for counter metrics
2. **Choose appropriate time ranges**: Use `[5m]` for most rate calculations
3. **Use labels for filtering**: Filter by specific services, namespaces, or instances
4. **Aggregate wisely**: Use `sum`, `avg`, `max`, `min` to aggregate across instances
5. **Use histogram_quantile()**: For latency percentiles from histogram metrics
6. **Combine metrics**: Create ratios like error rates or utilization percentages