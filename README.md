# Go-PostgreSQL DevOps Project

![CI/CD Pipeline](https://github.com/mrhanzla-lab/go-postgresql-dev/actions/workflows/ci.yml/badge.svg)

A complete DevOps implementation for a PostgreSQL-compatible server framework with containerization, CI/CD automation, Kubernetes deployment, and comprehensive monitoring.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Running Locally](#running-locally)
  - [Docker Compose](#docker-compose)
  - [Kubernetes (K8s)](#kubernetes-k8s)
- [Infrastructure Setup](#infrastructure-setup)
- [Infrastructure Teardown](#infrastructure-teardown)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)

---

## 🎯 Overview

This project implements a production-ready DevOps pipeline for a Go-based PostgreSQL-compatible server with:

- **Containerization** with Docker and Docker Compose
- **AWS Infrastructure** provisioned with Terraform (EKS, RDS, VPC)
- **Configuration Management** with Ansible/PowerShell
- **Kubernetes Deployment** with ConfigMaps, Secrets, and Services
- **CI/CD Pipeline** with GitHub Actions (7 stages)
- **Monitoring** with Prometheus and Grafana
- **Security Scanning** with gosec, Trivy, and TruffleHog

---

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- kubectl configured (for K8s deployment)
- AWS CLI configured (for infrastructure provisioning)
- Terraform 1.5+ installed
- Go 1.21+ installed (for local development)

### Clone Repository

```bash
git clone https://github.com/mrhanzla-lab/go-postgresql-dev.git
cd go-postgresql-dev
```

---

## 🐳 Running Locally

### Option 1: Docker Compose

**Start all services:**

```bash
docker-compose up -d
```

This will start:
- **PostgreSQL** database on port `5432`
- **Redis** cache on port `6379`
- **RabbitMQ** message queue on ports `5672` (AMQP), `15672` (Management UI)
- **Go-PostgreSQL** application on port `5432`

**Check status:**

```bash
docker-compose ps
```

**View logs:**

```bash
docker-compose logs -f
```

**Stop services:**

```bash
docker-compose down
```

**Clean up volumes:**

```bash
docker-compose down -v
```

### Option 2: Local Development

**Build the application:**

```bash
go mod download
go build -o bin/go-postgresqld ./examples/go-postgresqld/
```

**Run with environment variables:**

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_USER=postgres
export DB_PASSWORD=postgres
export DB_NAME=testdb
export REDIS_HOST=localhost:6379
export RABBITMQ_HOST=localhost:5672

./bin/go-postgresqld
```

**Run tests:**

```bash
go test -v ./...
```

---

## ☸️ Kubernetes (K8s)

### Deploy to Local Kubernetes (Minikube/Kind)

**Prerequisites:**
- Minikube or Kind cluster running
- kubectl configured

**Deploy application:**

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy ConfigMap and Secrets
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml

# Deploy services
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/rabbitmq-deployment.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

**Check deployment:**

```bash
kubectl get all -n go-postgresql-dev
```

**Access the application:**

```bash
# Port forward to local machine
kubectl port-forward -n go-postgresql-dev svc/go-postgresql-service 5432:5432
```

**View logs:**

```bash
kubectl logs -n go-postgresql-dev -l app=go-postgresql-app --follow
```

### Deploy to AWS EKS

**Prerequisites:**
- AWS credentials configured
- EKS cluster provisioned (see Infrastructure Setup)

**Configure kubectl for EKS:**

```bash
aws eks update-kubeconfig --region us-east-1 --name go-postgresql-dev-eks
```

**Deploy with PowerShell script:**

```powershell
cd ansible
.\deploy.ps1
```

Or manually:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/rabbitmq-deployment.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

**Get LoadBalancer URL:**

```bash
kubectl get svc go-postgresql-service -n go-postgresql-dev
```

---

## 🏗️ Infrastructure Setup

### Step 1: Provision AWS Infrastructure with Terraform

**Navigate to Terraform directory:**

```bash
cd infra
```

**Initialize Terraform:**

```bash
terraform init
```

**Review infrastructure plan:**

```bash
terraform plan
```

**Apply infrastructure:**

```bash
terraform apply
```

This creates:
- **VPC** with public and private subnets
- **EKS Cluster** (Kubernetes v1.29) with 2 t3.small worker nodes
- **RDS PostgreSQL** instance (version 16)
- **Security Groups** and IAM roles
- **NAT Gateways** for private subnet internet access

**Get infrastructure outputs:**

```bash
terraform output
```

### Step 2: Configure kubectl for EKS

```bash
aws eks update-kubeconfig --region us-east-1 --name go-postgresql-dev-eks
kubectl get nodes
```

### Step 3: Deploy Application to EKS

```bash
cd ../ansible
.\deploy.ps1  # Windows
# OR
./deploy.sh   # Linux/Mac
```

### Step 4: Deploy Monitoring Stack

```bash
cd ../monitoring
.\deploy-monitoring.ps1  # Windows
# OR
./deploy-monitoring.sh   # Linux/Mac
```

**Access monitoring dashboards:**

```bash
# Get LoadBalancer URLs
kubectl get svc -n monitoring

# Prometheus: http://<PROMETHEUS_LB>:9090
# Grafana: http://<GRAFANA_LB>:3000 (admin/admin123)
```

---

## 🧹 Infrastructure Teardown

### Step 1: Delete Kubernetes Resources

```bash
# Delete monitoring stack
kubectl delete namespace monitoring

# Delete application
kubectl delete namespace go-postgresql-dev
```

### Step 2: Destroy Terraform Infrastructure

```bash
cd infra
terraform destroy
```

**⚠️ Warning:** This will permanently delete:
- EKS cluster and worker nodes
- RDS database instance
- VPC and all networking resources
- All data stored in the database

**Estimated cost savings:** ~$50-100/month when infrastructure is destroyed

### Step 3: Clean Up Docker Resources (Local)

```bash
# Stop and remove containers
docker-compose down -v

# Remove Docker images
docker rmi $(docker images -q go-postgresql-dev*)

# Remove unused volumes
docker volume prune -f
```

---

## 🏛️ Architecture

### CI/CD Pipeline (GitHub Actions)

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Stage 1   │ -> │   Stage 2   │ -> │   Stage 3   │ -> │   Stage 4   │
│ Build&Test  │    │   Security  │    │   Docker    │    │  Terraform  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                                                                  │
                                                                  v
┌─────────────┐    ┌─────────────┐    ┌─────────────────────────────────┐
│   Stage 7   │ <- │   Stage 6   │ <- │         Stage 5                 │
│ Smoke Tests │    │   Kubectl   │    │    Kubernetes Deploy            │
└─────────────┘    └─────────────┘    └─────────────────────────────────┘
```

### AWS Infrastructure

```
┌────────────────────────────────────────────────────────────────┐
│                           AWS Cloud                             │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │                      VPC (10.0.0.0/16)                    │ │
│  │                                                            │ │
│  │  ┌─────────────────┐         ┌─────────────────┐        │ │
│  │  │ Public Subnet 1 │         │ Public Subnet 2 │        │ │
│  │  │  10.0.1.0/24    │         │  10.0.2.0/24    │        │ │
│  │  │                 │         │                 │        │ │
│  │  │  NAT Gateway    │         │  NAT Gateway    │        │ │
│  │  └────────┬────────┘         └────────┬────────┘        │ │
│  │           │                           │                  │ │
│  │  ┌────────┴────────┐         ┌───────┴─────────┐       │ │
│  │  │ Private Subnet1 │         │ Private Subnet2 │       │ │
│  │  │  10.0.10.0/24   │         │  10.0.11.0/24   │       │ │
│  │  │                 │         │                 │       │ │
│  │  │  ┌──────────┐   │         │  ┌──────────┐  │       │ │
│  │  │  │EKS Node 1│   │         │  │EKS Node 2│  │       │ │
│  │  │  │t3.small  │   │         │  │t3.small  │  │       │ │
│  │  │  └──────────┘   │         │  └──────────┘  │       │ │
│  │  └─────────────────┘         └─────────────────┘       │ │
│  │                                                          │ │
│  │  ┌───────────────────────────────────────────────────┐ │ │
│  │  │           RDS PostgreSQL 16                       │ │ │
│  │  │           db.t3.micro                             │ │ │
│  │  └───────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

### Monitoring Stack

```
┌──────────────────────────────────────────────────────────┐
│                  Monitoring Namespace                     │
│                                                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │
│  │ Prometheus  │<---│ Node Exp.   │<---│   Pods      │ │
│  │   :9090     │    │   :9100     │    │ (metrics)   │ │
│  └──────┬──────┘    └─────────────┘    └─────────────┘ │
│         │                                                │
│         │ Datasource                                     │
│         v                                                │
│  ┌─────────────┐                                        │
│  │   Grafana   │                                        │
│  │    :3000    │                                        │
│  └─────────────┘                                        │
└──────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technologies Used

### Core Stack
- **Go 1.21** - Application runtime
- **PostgreSQL 16** - Database
- **Redis 7** - Caching
- **RabbitMQ 3** - Message queue

### DevOps Tools
- **Docker & Docker Compose** - Containerization
- **Kubernetes (EKS)** - Container orchestration
- **Terraform** - Infrastructure as Code
- **Ansible/PowerShell** - Configuration management
- **GitHub Actions** - CI/CD automation

### Monitoring & Observability
- **Prometheus** - Metrics collection
- **Grafana** - Visualization dashboards
- **Node Exporter** - System metrics

### Security & Quality
- **gosec** - Go security scanner
- **Trivy** - Container vulnerability scanner
- **TruffleHog** - Secret detection
- **golangci-lint** - Go linter

---

## 📁 Project Structure

```
go-postgresql-dev/
├── .github/workflows/     # GitHub Actions CI/CD pipeline
│   └── ci.yml            # Main pipeline configuration
├── infra/                # Terraform AWS infrastructure
│   ├── main.tf
│   ├── eks.tf
│   ├── rds.tf
│   └── vpc.tf
├── k8s/                  # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── secret.yaml
├── ansible/              # Configuration management
│   ├── playbook.yaml
│   └── deploy.ps1
├── monitoring/           # Prometheus & Grafana
│   ├── prometheus-*.yaml
│   ├── grafana-*.yaml
│   └── deploy-monitoring.ps1
├── postgresql/           # Go application source
├── docker-compose.yml    # Local development stack
├── Dockerfile           # Application container
├── README.md           # This file
└── devops_report.md    # Comprehensive DevOps report
```

---

## 📚 Additional Documentation

- **[DevOps Report](devops_report.md)** - Comprehensive pipeline documentation
- **[Step-by-Step Guides](docs/)** - Detailed setup guides for each step
- **[Terraform Docs](infra/README.md)** - Infrastructure provisioning details
- **[Monitoring Guide](docs/STEP7_MONITORING.md)** - Prometheus & Grafana setup

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

**Group 7:**
- HANZLA
- ZAIN UL ABEDIN
- FAHAD AHMED SAHI

**Course:** Cloud Native Application Development  
**Date:** December 2025

---

## 🔗 Links

- **GitHub Repository:** https://github.com/mrhanzla-lab/go-postgresql-dev
- **CI/CD Pipeline:** https://github.com/mrhanzla-lab/go-postgresql-dev/actions
- **Docker Hub:** docker.io/[username]/go-postgresql

---

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Contact the team members
- Review the documentation in `/docs`
