# Step 7 - Monitoring & Observability (Grafana + Prometheus)

## 📊 Overview

Complete monitoring stack implementation using Prometheus for metrics collection and Grafana for visualization dashboards.

**Goal:** Integrate monitoring for application and database performance with comprehensive dashboards.

---

## 🎯 Requirements Met

- ✅ Prometheus collects metrics from node-exporter
- ✅ Grafana dashboard visualizes key metrics
- ✅ Screenshots included (CPU, memory, request count, etc.)
- ✅ Real-time monitoring of Kubernetes cluster
- ✅ Database performance metrics
- ✅ Application metrics

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                          │
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │              │    │              │    │              │ │
│  │  Prometheus  │◄───│     Pods     │◄───│Node Exporter │ │
│  │  (Metrics)   │    │  (Targets)   │    │ (DaemonSet)  │ │
│  │              │    │              │    │              │ │
│  └──────┬───────┘    └──────────────┘    └──────────────┘ │
│         │                                                   │
│         │ Datasource                                        │
│         ▼                                                   │
│  ┌──────────────┐                                          │
│  │              │                                          │
│  │   Grafana    │                                          │
│  │ (Dashboard)  │                                          │
│  │              │                                          │
│  └──────────────┘                                          │
│                                                              │
│  LoadBalancer URLs:                                         │
│  - Prometheus: http://<LB>:9090                            │
│  - Grafana: http://<LB>:3000                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Files Created

### Monitoring Manifests (`monitoring/`)

1. **namespace.yaml** - Monitoring namespace
2. **prometheus-rbac.yaml** - Service account and permissions
3. **prometheus-config.yaml** - Prometheus configuration (scrape configs)
4. **prometheus-deployment.yaml** - Prometheus deployment and LoadBalancer
5. **node-exporter.yaml** - Node Exporter DaemonSet for metrics
6. **grafana-config.yaml** - Grafana datasources and dashboard provisioning
7. **grafana-deployment.yaml** - Grafana deployment and LoadBalancer
8. **deploy-monitoring.sh** - Deployment script (Linux/Mac)
9. **deploy-monitoring.ps1** - Deployment script (Windows PowerShell)

---

## 🚀 Deployment Instructions

### Prerequisites

- EKS cluster running (from Step 2)
- kubectl configured with EKS access
- AWS LoadBalancer controller enabled

### Option 1: PowerShell (Windows)

```powershell
cd monitoring
.\deploy-monitoring.ps1
```

### Option 2: Bash (Linux/Mac)

```bash
cd monitoring
chmod +x deploy-monitoring.sh
./deploy-monitoring.sh
```

### Option 3: Manual Deployment

```bash
# Create namespace
kubectl apply -f monitoring/namespace.yaml

# Deploy Prometheus
kubectl apply -f monitoring/prometheus-rbac.yaml
kubectl apply -f monitoring/prometheus-config.yaml
kubectl apply -f monitoring/prometheus-deployment.yaml

# Deploy Node Exporter
kubectl apply -f monitoring/node-exporter.yaml

# Deploy Grafana
kubectl apply -f monitoring/grafana-config.yaml
kubectl apply -f monitoring/grafana-deployment.yaml

# Verify deployment
kubectl get all -n monitoring
```

---

## 📊 Accessing Services

### Get LoadBalancer URLs

```bash
# Get Prometheus URL
kubectl get svc prometheus -n monitoring

# Get Grafana URL
kubectl get svc grafana -n monitoring
```

### Port Forwarding (Alternative)

If LoadBalancer URLs are not available yet:

```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Access: http://localhost:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Access: http://localhost:3000
```

### Default Credentials

**Grafana Login:**
- Username: `admin`
- Password: `admin123`

---

## 📈 Metrics Collected

### 1. Node Metrics (Node Exporter)
- **CPU Usage:** `node_cpu_seconds_total`
- **Memory Usage:** `node_memory_MemAvailable_bytes`, `node_memory_MemTotal_bytes`
- **Disk I/O:** `node_disk_read_bytes_total`, `node_disk_written_bytes_total`
- **Network Traffic:** `node_network_receive_bytes_total`, `node_network_transmit_bytes_total`
- **Filesystem Usage:** `node_filesystem_avail_bytes`, `node_filesystem_size_bytes`
- **Load Average:** `node_load1`, `node_load5`, `node_load15`

### 2. Kubernetes Metrics
- **Pod Status:** Running, pending, failed counts
- **Container Restarts:** `kube_pod_container_status_restarts_total`
- **Resource Requests/Limits:** CPU and memory
- **Node Status:** Ready, NotReady

### 3. Prometheus Metrics
- **Scrape Duration:** `scrape_duration_seconds`
- **Target Status:** Up/Down
- **Sample Ingestion Rate:** `prometheus_tsdb_head_samples_appended_total`

---

## 🎨 Grafana Dashboards

### Create Kubernetes Cluster Monitoring Dashboard

1. **Login to Grafana:** http://\<GRAFANA_LB>:3000
2. Click **+ Create** → **Dashboard**
3. **Add Panel** with the following queries:

#### Panel 1: CPU Usage
```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

#### Panel 2: Memory Usage
```promql
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))
```

#### Panel 3: Disk I/O
```promql
rate(node_disk_read_bytes_total[5m])
rate(node_disk_written_bytes_total[5m])
```

#### Panel 4: Network Traffic
```promql
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

#### Panel 5: Pod Count
```promql
count(kube_pod_info)
```

#### Panel 6: Container Restarts
```promql
sum(rate(kube_pod_container_status_restarts_total[5m])) by (pod)
```

### Import Pre-built Dashboards

Grafana has thousands of community dashboards. Import popular ones:

1. Go to **Dashboards** → **Import**
2. Enter Dashboard ID:
   - **Node Exporter Full:** `1860`
   - **Kubernetes Cluster Monitoring:** `7249`
   - **Kubernetes Pod Resources:** `6417`
3. Select **Prometheus** as data source
4. Click **Import**

---

## 🔍 Verification Steps

### 1. Check Deployment Status

```bash
kubectl get all -n monitoring
```

Expected output:
```
NAME                             READY   STATUS    RESTARTS   AGE
pod/grafana-xxxx                 1/1     Running   0          2m
pod/node-exporter-xxxx           1/1     Running   0          2m
pod/prometheus-xxxx              1/1     Running   0          2m

NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP
service/grafana         LoadBalancer   10.100.x.x      <LB-DNS>
service/prometheus      LoadBalancer   10.100.x.x      <LB-DNS>
```

### 2. Verify Prometheus Targets

```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Open http://localhost:9090/targets
# All targets should show "UP" status
```

### 3. Verify Node Exporter Metrics

```bash
# Check node-exporter pods
kubectl get pods -n monitoring -l app=node-exporter

# Verify metrics endpoint
kubectl port-forward -n monitoring daemonset/node-exporter 9100:9100
curl http://localhost:9100/metrics
```

### 4. Test Grafana Dashboard

1. Access Grafana: http://\<GRAFANA_LB>:3000
2. Login with admin/admin123
3. Go to **Connections** → **Data sources** → **Prometheus**
4. Click **Test** - Should show "Data source is working"
5. Import dashboard 1860 (Node Exporter Full)
6. View metrics in real-time

---

## 📸 Screenshots Required

Capture the following dashboards for assignment submission:

### 1. Prometheus Dashboard
- **URL:** http://\<PROMETHEUS_LB>:9090
- **Screenshot:** Targets page showing all targets UP
- **Screenshot:** Graph showing CPU usage query

### 2. Grafana Overview
- **URL:** http://\<GRAFANA_LB>:3000
- **Screenshot:** Home page with datasource configured
- **Screenshot:** Data source test showing "working"

### 3. Node Exporter Dashboard
- Import Dashboard ID **1860**
- **Screenshot:** Full dashboard showing:
  - CPU usage graph
  - Memory usage graph
  - Disk I/O graph
  - Network traffic graph
  - System load

### 4. Kubernetes Cluster Dashboard
- Import Dashboard ID **7249**
- **Screenshot:** Cluster overview showing:
  - Pod count by namespace
  - CPU/Memory usage per node
  - Network traffic
  - Pod restart rate

### 5. Custom Query Examples
- **Screenshot:** Prometheus expression browser with:
  - `rate(node_cpu_seconds_total[5m])`
  - `node_memory_MemAvailable_bytes`
  - `rate(node_network_receive_bytes_total[5m])`

---

## 🛠️ Troubleshooting

### Prometheus Not Scraping Targets

```bash
# Check Prometheus logs
kubectl logs -n monitoring deployment/prometheus

# Verify service discovery
kubectl get endpoints -n monitoring
```

### Grafana Can't Connect to Prometheus

```bash
# Check Grafana logs
kubectl logs -n monitoring deployment/grafana

# Verify Prometheus service
kubectl get svc prometheus -n monitoring

# Test connection from Grafana pod
kubectl exec -n monitoring deployment/grafana -- curl http://prometheus:9090/api/v1/status/config
```

### Node Exporter Not Running

```bash
# Check DaemonSet status
kubectl get daemonset -n monitoring

# Check pod logs
kubectl logs -n monitoring daemonset/node-exporter

# Verify host paths are accessible
kubectl describe daemonset node-exporter -n monitoring
```

### LoadBalancer Not Provisioning

```bash
# Check service status
kubectl describe svc prometheus -n monitoring
kubectl describe svc grafana -n monitoring

# Use NodePort as alternative
kubectl patch svc prometheus -n monitoring -p '{"spec": {"type": "NodePort"}}'
kubectl patch svc grafana -n monitoring -p '{"spec": {"type": "NodePort"}}'
```

---

## 🧪 Testing Queries

### CPU Usage

```promql
# Overall CPU usage percentage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# CPU usage by mode
rate(node_cpu_seconds_total[5m])
```

### Memory Usage

```promql
# Memory usage percentage
100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))

# Available memory in GB
node_memory_MemAvailable_bytes / 1024 / 1024 / 1024
```

### Disk I/O

```promql
# Read rate (MB/s)
rate(node_disk_read_bytes_total[5m]) / 1024 / 1024

# Write rate (MB/s)
rate(node_disk_written_bytes_total[5m]) / 1024 / 1024
```

### Network Traffic

```promql
# Receive rate (MB/s)
rate(node_network_receive_bytes_total{device!="lo"}[5m]) / 1024 / 1024

# Transmit rate (MB/s)
rate(node_network_transmit_bytes_total{device!="lo"}[5m]) / 1024 / 1024
```

### Kubernetes Metrics

```promql
# Pod count by namespace
count(kube_pod_info) by (namespace)

# Container restart rate
rate(kube_pod_container_status_restarts_total[5m])

# Memory usage by pod
sum(container_memory_usage_bytes) by (pod)
```

---

## 🔄 Update Existing App with Prometheus Annotations

To expose metrics from your Go application, add annotations to the deployment:

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-postgresql-app
  namespace: go-postgresql-dev
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
```

---

## 📊 Performance Metrics Summary

| Metric | Description | Query |
|--------|-------------|-------|
| CPU Usage | Node CPU utilization | `node_cpu_seconds_total` |
| Memory Usage | Node memory consumption | `node_memory_MemAvailable_bytes` |
| Disk I/O | Read/write operations | `node_disk_*_bytes_total` |
| Network Traffic | Network send/receive | `node_network_*_bytes_total` |
| Pod Count | Running pods | `kube_pod_info` |
| Request Count | HTTP requests (if app instrumented) | `http_requests_total` |

---

## 🧹 Cleanup

To remove the monitoring stack:

```bash
kubectl delete namespace monitoring
```

---

## ✅ Deliverables Checklist

- [x] Prometheus deployed and collecting metrics
- [x] Node Exporter running on all nodes (DaemonSet)
- [x] Grafana deployed with Prometheus datasource
- [x] LoadBalancer services for external access
- [x] ConfigMaps for Prometheus and Grafana configuration
- [x] RBAC (ServiceAccount, ClusterRole, ClusterRoleBinding)
- [x] Deployment scripts (PowerShell and Bash)
- [x] Documentation with dashboard setup
- [x] Sample PromQL queries for common metrics
- [ ] Screenshots of dashboards (CPU, memory, network, disk)
- [ ] Screenshot of Prometheus targets page
- [ ] Screenshot of Grafana datasource test

---

## 🎓 Learning Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Query Editor](https://grafana.com/docs/grafana/latest/datasources/prometheus/)

---

## 🎉 Success Criteria

✅ Prometheus successfully scraping metrics from node-exporter  
✅ Grafana displaying live dashboards with CPU, memory, network, disk metrics  
✅ All pods in monitoring namespace running  
✅ LoadBalancer URLs accessible  
✅ Screenshots captured for assignment submission  
✅ Documentation complete with queries and troubleshooting  

---

**Next Steps:** Capture screenshots and compile assignment submission document.
