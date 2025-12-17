# PowerShell script to deploy Kubernetes resources (acts as Ansible alternative on Windows)
# This script performs the same tasks as the Ansible playbook

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Starting Kubernetes Deployment" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Refresh PATH to include AWS CLI
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check kubectl
Write-Host "Checking kubectl installation..." -ForegroundColor Yellow
kubectl version --client
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: kubectl not found!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Check cluster connection
Write-Host "Verifying cluster connection..." -ForegroundColor Yellow
kubectl cluster-info
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Cannot connect to cluster!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Create namespace
Write-Host "Creating namespace..." -ForegroundColor Yellow
kubectl apply -f ..\k8s\namespace.yaml
Write-Host ""

# Wait for namespace
Start-Sleep -Seconds 3

# Apply ConfigMap
Write-Host "Applying ConfigMap..." -ForegroundColor Yellow
kubectl apply -f ..\k8s\configmap.yaml
Write-Host ""

# Apply Secrets
Write-Host "Applying Secrets..." -ForegroundColor Yellow
kubectl apply -f ..\k8s\secret.yaml
Write-Host ""

# Deploy Redis
Write-Host "Deploying Redis..." -ForegroundColor Yellow
kubectl apply -f ..\k8s\redis-deployment.yaml
Write-Host ""

# Deploy RabbitMQ
Write-Host "Deploying RabbitMQ..." -ForegroundColor Yellow
kubectl apply -f ..\k8s\rabbitmq-deployment.yaml
Write-Host ""

# Wait for Redis and RabbitMQ
Write-Host "Waiting for Redis and RabbitMQ to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Deploy Application
Write-Host "Deploying Application..." -ForegroundColor Yellow
kubectl apply -f ..\k8s\app-deployment.yaml
Write-Host ""

# Wait for application
Write-Host "Waiting for application pods to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Show deployment status
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Deployment Status" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Pods:" -ForegroundColor Cyan
kubectl get pods -n go-postgresql-dev
Write-Host ""

Write-Host "Services:" -ForegroundColor Cyan
kubectl get services -n go-postgresql-dev
Write-Host ""

Write-Host "Deployments:" -ForegroundColor Cyan
kubectl get deployments -n go-postgresql-dev
Write-Host ""

Write-Host "=========================================" -ForegroundColor Green
Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Namespace: go-postgresql-dev" -ForegroundColor Green
Write-Host "Services deployed: Redis, RabbitMQ, Go-PostgreSQL App" -ForegroundColor Green
Write-Host "Check all resources: kubectl get all -n go-postgresql-dev" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
