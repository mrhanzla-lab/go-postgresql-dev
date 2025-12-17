#!/bin/bash

# Deploy Monitoring Stack (Prometheus + Grafana + Node Exporter)

echo "🚀 Deploying Monitoring Stack to Kubernetes..."
echo ""

# Create monitoring namespace
echo "📦 Creating monitoring namespace..."
kubectl apply -f namespace.yaml

echo ""
echo "🔧 Deploying Prometheus..."
kubectl apply -f prometheus-rbac.yaml
kubectl apply -f prometheus-config.yaml
kubectl apply -f prometheus-deployment.yaml

echo ""
echo "📊 Deploying Node Exporter..."
kubectl apply -f node-exporter.yaml

echo ""
echo "📈 Deploying Grafana..."
kubectl apply -f grafana-config.yaml
kubectl apply -f grafana-deployment.yaml

echo ""
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

echo ""
echo "✅ Monitoring stack deployed successfully!"
echo ""
echo "📊 Getting service endpoints..."
echo ""

# Get Prometheus LoadBalancer
PROMETHEUS_LB=$(kubectl get svc prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if [ -n "$PROMETHEUS_LB" ]; then
    echo "🔍 Prometheus: http://$PROMETHEUS_LB:9090"
else
    echo "⏳ Prometheus LoadBalancer provisioning... (check with: kubectl get svc -n monitoring)"
fi

# Get Grafana LoadBalancer
GRAFANA_LB=$(kubectl get svc grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if [ -n "$GRAFANA_LB" ]; then
    echo "📈 Grafana: http://$GRAFANA_LB:3000"
    echo "   Username: admin"
    echo "   Password: admin123"
else
    echo "⏳ Grafana LoadBalancer provisioning... (check with: kubectl get svc -n monitoring)"
fi

echo ""
echo "📋 All resources in monitoring namespace:"
kubectl get all -n monitoring

echo ""
echo "💡 To access services, use:"
echo "   kubectl get svc -n monitoring"
echo ""
echo "💡 To view Prometheus targets:"
echo "   kubectl port-forward -n monitoring svc/prometheus 9090:9090"
echo "   Then open: http://localhost:9090/targets"
echo ""
echo "💡 To view Grafana dashboards:"
echo "   kubectl port-forward -n monitoring svc/grafana 3000:3000"
echo "   Then open: http://localhost:3000"
echo "   Login: admin / admin123"
