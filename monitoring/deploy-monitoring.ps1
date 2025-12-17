# Deploy Monitoring Stack (Prometheus + Grafana + Node Exporter) - PowerShell

Write-Host "🚀 Deploying Monitoring Stack to Kubernetes..." -ForegroundColor Cyan
Write-Host ""

# Create monitoring namespace
Write-Host "📦 Creating monitoring namespace..." -ForegroundColor Yellow
kubectl apply -f namespace.yaml

Write-Host ""
Write-Host "🔧 Deploying Prometheus..." -ForegroundColor Yellow
kubectl apply -f prometheus-rbac.yaml
kubectl apply -f prometheus-config.yaml
kubectl apply -f prometheus-deployment.yaml

Write-Host ""
Write-Host "📊 Deploying Node Exporter..." -ForegroundColor Yellow
kubectl apply -f node-exporter.yaml

Write-Host ""
Write-Host "📈 Deploying Grafana..." -ForegroundColor Yellow
kubectl apply -f grafana-config.yaml
kubectl apply -f grafana-deployment.yaml

Write-Host ""
Write-Host "⏳ Waiting for deployments to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

Write-Host ""
Write-Host "✅ Monitoring stack deployed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Getting service endpoints..." -ForegroundColor Cyan
Write-Host ""

# Get Prometheus LoadBalancer
$PROMETHEUS_LB = kubectl get svc prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
if ($PROMETHEUS_LB) {
    Write-Host "🔍 Prometheus: http://${PROMETHEUS_LB}:9090" -ForegroundColor Green
} else {
    Write-Host "⏳ Prometheus LoadBalancer provisioning... (check with: kubectl get svc -n monitoring)" -ForegroundColor Yellow
}

# Get Grafana LoadBalancer
$GRAFANA_LB = kubectl get svc grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
if ($GRAFANA_LB) {
    Write-Host "📈 Grafana: http://${GRAFANA_LB}:3000" -ForegroundColor Green
    Write-Host "   Username: admin" -ForegroundColor White
    Write-Host "   Password: admin123" -ForegroundColor White
} else {
    Write-Host "⏳ Grafana LoadBalancer provisioning... (check with: kubectl get svc -n monitoring)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 All resources in monitoring namespace:" -ForegroundColor Cyan
kubectl get all -n monitoring

Write-Host ""
Write-Host "💡 To access services, use:" -ForegroundColor Cyan
Write-Host "   kubectl get svc -n monitoring"
Write-Host ""
Write-Host "💡 To view Prometheus targets:" -ForegroundColor Cyan
Write-Host "   kubectl port-forward -n monitoring svc/prometheus 9090:9090"
Write-Host "   Then open: http://localhost:9090/targets"
Write-Host ""
Write-Host "💡 To view Grafana dashboards:" -ForegroundColor Cyan
Write-Host "   kubectl port-forward -n monitoring svc/grafana 3000:3000"
Write-Host "   Then open: http://localhost:3000"
Write-Host "   Login: admin / admin123"
