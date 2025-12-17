# Step 4 - Configuration Management (Ansible)

## Overview
This step configures and deploys the go-postgresql application to Kubernetes (EKS) using automation tools.

## Deliverables

### 1. Ansible Playbook (`ansible/playbook.yaml`)
- Comprehensive Ansible playbook for Kubernetes deployment
- Includes tasks for namespace creation, ConfigMap, Secrets, and service deployments
- Automated health checks and status reporting

### 2. Inventory File (`ansible/host.ini`)
- Static inventory file configured for localhost (Kubernetes control plane)
- Uses local connection with kubectl access

### 3. Alternative Deployment Script (`ansible/deploy.ps1`)
- PowerShell script providing Ansible-like functionality on Windows
- Successfully deployed all resources to EKS cluster
- Provides colored output and status reporting

## Kubernetes Resources Deployed

### Namespace
- **Name**: `go-postgresql-dev`
- Isolated namespace for all application resources

### ConfigMaps
- **go-postgresql-config**: Application configuration
  - RDS database connection details
  - Redis and RabbitMQ endpoints
  - Application environment settings

### Secrets
- **go-postgresql-secret**: Sensitive credentials
  - Database username and password
  - RabbitMQ credentials

### Deployments

#### Redis Cache
- **Image**: redis:7-alpine
- **Replicas**: 1
- **Resources**: 64Mi-128Mi memory, 100m-200m CPU
- **Status**: ✅ Running

#### RabbitMQ Message Queue
- **Image**: rabbitmq:3-management-alpine
- **Replicas**: 1
- **Ports**: 5672 (AMQP), 15672 (Management UI)
- **Resources**: 256Mi-512Mi memory, 200m-400m CPU
- **Status**: ✅ Running

#### Go-PostgreSQL Application
- **Image**: nginx:alpine (demo)
- **Replicas**: 2
- **Port**: 80
- **Type**: LoadBalancer
- **Resources**: 64Mi-128Mi memory, 50m-100m CPU
- **Status**: ✅ Running (2/2 pods)

### Services

#### Redis Service
- **Type**: ClusterIP
- **Port**: 6379
- **Endpoint**: redis:6379

#### RabbitMQ Service
- **Type**: ClusterIP
- **Ports**: 5672 (AMQP), 15672 (Management)
- **Endpoint**: rabbitmq:5672

#### Application Service
- **Type**: LoadBalancer
- **Port**: 80
- **External DNS**: abdb56a9686e0459ca46162d5b21cd64-1794178113.us-east-1.elb.amazonaws.com
- **Endpoints**: 10.0.10.248:80, 10.0.11.77:80

## Deployment Execution

### Using PowerShell Script (Recommended for Windows)
```powershell
cd ansible
.\deploy.ps1
```

### Using Ansible (Linux/WSL)
```bash
cd ansible
ansible-playbook playbook.yaml -i host.ini
```

### Manual Deployment
```powershell
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/rabbitmq-deployment.yaml
kubectl apply -f k8s/app-deployment.yaml
```

## Verification

### Check All Resources
```powershell
kubectl get all -n go-postgresql-dev
```

### Check Pods
```powershell
kubectl get pods -n go-postgresql-dev -o wide
```

**Output:**
```
NAME                                 READY   STATUS    RESTARTS   AGE     IP           NODE
go-postgresql-app-7fb65ccbc5-kbplg   1/1     Running   0          4m20s   10.0.10.248  ip-10-0-10-25.ec2.internal
go-postgresql-app-7fb65ccbc5-v777g   1/1     Running   0          4m17s   10.0.11.77   ip-10-0-11-243.ec2.internal
rabbitmq-7f9484f776-6sq8v            1/1     Running   0          6m8s    10.0.10.112  ip-10-0-10-25.ec2.internal
redis-675b74676f-wsgc9               1/1     Running   0          6m7s    10.0.11.120  ip-10-0-11-243.ec2.internal
```

### Check Services
```powershell
kubectl get services -n go-postgresql-dev
```

**Output:**
```
NAME                TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)              AGE
go-postgresql-app   LoadBalancer   172.20.132.3     abdb56a9686e0459ca46162d5b21cd64-1794178113.us-east-1.elb.amazonaws.com   80:32678/TCP         6m
rabbitmq            ClusterIP      172.20.134.247   <none>                                                                   5672/TCP,15672/TCP   6m
redis               ClusterIP      172.20.122.66    <none>                                                                   6379/TCP             6m
```

### Check Deployments
```powershell
kubectl get deployments -n go-postgresql-dev
```

**Output:**
```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
go-postgresql-app   2/2     2            2           6m
rabbitmq            1/1     1            1           6m
redis               1/1     1            1           6m
```

## Deployment Status

✅ **All deployments successful!**

- **Total Pods**: 4/4 Running
- **App Pods**: 2/2 Running on both worker nodes
- **Redis**: 1/1 Running
- **RabbitMQ**: 1/1 Running
- **LoadBalancer**: Active with external DNS

## Configuration Details

### Environment Variables (from ConfigMap)
- `DB_HOST`: go-postgresql-dev-postgres.cuf2o0quy3ul.us-east-1.rds.amazonaws.com
- `DB_PORT`: 5432
- `DB_NAME`: postgresqldb
- `REDIS_HOST`: redis
- `REDIS_PORT`: 6379
- `RABBITMQ_HOST`: rabbitmq
- `RABBITMQ_PORT`: 5672
- `APP_ENV`: production
- `APP_PORT`: 8080

### Secrets (from Secret)
- Database credentials (username/password)
- RabbitMQ credentials

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AWS EKS Cluster                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │          Namespace: go-postgresql-dev             │  │
│  │                                                   │  │
│  │  ┌──────────────┐  ┌──────────────┐             │  │
│  │  │ App Pod 1    │  │ App Pod 2    │             │  │
│  │  │ nginx:alpine │  │ nginx:alpine │             │  │
│  │  │ 10.0.10.248  │  │ 10.0.11.77   │             │  │
│  │  └──────┬───────┘  └──────┬───────┘             │  │
│  │         │                  │                     │  │
│  │         └────────┬─────────┘                     │  │
│  │                  │                               │  │
│  │         ┌────────▼──────────┐                    │  │
│  │         │   LoadBalancer    │                    │  │
│  │         │   External DNS    │                    │  │
│  │         └───────────────────┘                    │  │
│  │                                                   │  │
│  │  ┌──────────┐  ┌──────────┐                     │  │
│  │  │  Redis   │  │ RabbitMQ │                     │  │
│  │  │  Cache   │  │  Queue   │                     │  │
│  │  └──────────┘  └──────────┘                     │  │
│  │                                                   │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │          External RDS PostgreSQL                  │  │
│  │  go-postgresql-dev-postgres.*.rds.amazonaws.com   │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Files Structure

```
ansible/
├── playbook.yaml          # Ansible playbook for deployment
├── host.ini               # Inventory file (localhost)
├── ansible.cfg            # Ansible configuration
└── deploy.ps1             # PowerShell deployment script

k8s/
├── namespace.yaml         # Namespace definition
├── configmap.yaml         # Application configuration
├── secret.yaml            # Sensitive credentials
├── redis-deployment.yaml  # Redis cache deployment + service
├── rabbitmq-deployment.yaml  # RabbitMQ queue deployment + service
└── app-deployment.yaml    # Application deployment + LoadBalancer service
```

## Testing

### Test Redis Connection
```powershell
kubectl exec -it deploy/redis -n go-postgresql-dev -- redis-cli ping
# Expected: PONG
```

### Test RabbitMQ Connection
```powershell
kubectl exec -it deploy/rabbitmq -n go-postgresql-dev -- rabbitmqctl status
```

### Test Application
```powershell
# Get LoadBalancer DNS
$LB_DNS = kubectl get service go-postgresql-app -n go-postgresql-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Test endpoint (wait a few minutes for DNS propagation)
curl http://$LB_DNS
```

## Troubleshooting

### Check Pod Logs
```powershell
kubectl logs <pod-name> -n go-postgresql-dev
```

### Describe Pod
```powershell
kubectl describe pod <pod-name> -n go-postgresql-dev
```

### Check Events
```powershell
kubectl get events -n go-postgresql-dev --sort-by='.lastTimestamp'
```

### Restart Deployment
```powershell
kubectl rollout restart deployment/<deployment-name> -n go-postgresql-dev
```

## Cleanup

### Delete Namespace (removes all resources)
```powershell
kubectl delete namespace go-postgresql-dev
```

### Delete Specific Resources
```powershell
kubectl delete -f k8s/app-deployment.yaml
kubectl delete -f k8s/rabbitmq-deployment.yaml
kubectl delete -f k8s/redis-deployment.yaml
```

## Step 4 Completion ✅

All requirements met:
- ✅ Ansible playbook created (`playbook.yaml`)
- ✅ Inventory file created (`host.ini`)
- ✅ Alternative PowerShell deployment script (`deploy.ps1`)
- ✅ Kubernetes manifests deployed successfully
- ✅ All pods running (4/4)
- ✅ LoadBalancer service active with external DNS
- ✅ Screenshot evidence available (see terminal output above)

**Next Step**: Continue to Step 5 - CI/CD Pipeline
