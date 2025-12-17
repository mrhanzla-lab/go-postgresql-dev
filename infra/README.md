# Step 2: Infrastructure Provisioning with Terraform

## Overview

This directory contains Terraform configurations to provision AWS infrastructure for the go-postgresql-dev project. The infrastructure includes VPC networking, EKS Kubernetes cluster, and RDS PostgreSQL database.

## Architecture

### Provisioned Resources

1. **VPC & Networking**
   - VPC with CIDR 10.0.0.0/16
   - 2 Public Subnets (for load balancers)
   - 2 Private Subnets (for EKS nodes and RDS)
   - Internet Gateway
   - NAT Gateways (one per public subnet)
   - Route Tables (public and private)

2. **Security Groups**
   - EKS Cluster Security Group
   - EKS Nodes Security Group
   - RDS Security Group
   - Application Load Balancer Security Group

3. **EKS Cluster (Kubernetes)**
   - EKS Control Plane (Kubernetes v1.28)
   - Managed Node Group (2-4 t3.medium instances)
   - OIDC Provider for IRSA (IAM Roles for Service Accounts)
   - CloudWatch logging enabled

4. **RDS PostgreSQL**
   - PostgreSQL 16.1
   - db.t3.micro instance
   - 20GB storage (auto-scaling enabled)
   - Encrypted at rest
   - Automated backups (7-day retention)
   - Password stored in AWS Secrets Manager

## Prerequisites

### Required Tools

```bash
# Install Terraform
# Windows (using Chocolatey):
choco install terraform

# macOS (using Homebrew):
brew install terraform

# Verify installation
terraform version
```

### AWS Configuration

```bash
# Install AWS CLI
# Windows:
choco install awscli

# Configure AWS credentials
aws configure

# Verify credentials
aws sts get-caller-identity
```

**Required AWS Permissions:**
- VPC creation and management
- EKS cluster and node group management
- RDS instance creation
- IAM role and policy management
- Security group management
- Secrets Manager access

## File Structure

```
infra/
├── main.tf                 # Provider configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values (customize this)
├── vpc.tf                  # VPC and networking resources
├── security_groups.tf      # Security group definitions
├── eks.tf                  # EKS cluster and node groups
├── rds.tf                  # RDS PostgreSQL instance
├── .gitignore             # Git ignore patterns
└── README.md              # This file
```

## Usage

### 1. Initialize Terraform

```bash
cd infra
terraform init
```

This downloads required providers and prepares the working directory.

### 2. Configure Variables

Edit `terraform.tfvars` or set environment variables:

```bash
# Option 1: Edit terraform.tfvars
# (Already configured with sensible defaults)

# Option 2: Set environment variables
export TF_VAR_db_password="your_secure_password_here"
export TF_VAR_aws_region="us-east-1"
```

### 3. Plan Infrastructure

```bash
terraform plan
```

Review the planned changes. This shows what resources will be created.

**Expected Output:**
- Plan: XX to add, 0 to change, 0 to destroy

### 4. Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. This process takes approximately 15-20 minutes.

**Note:** EKS cluster creation takes ~10-15 minutes.

### 5. View Outputs

```bash
terraform output
```

Or view specific outputs:

```bash
# Get EKS cluster name
terraform output eks_cluster_name

# Get RDS endpoint
terraform output rds_endpoint

# Get kubeconfig command
terraform output kubeconfig_command
```

### 6. Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name go-postgresql-dev-eks

# Verify connection
kubectl get nodes
```

### 7. Test Connection to RDS

```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)

# Connect using psql (from EKS pod or bastion)
kubectl run psql-test --rm -it --image=postgres:16 -- \
  psql -h $RDS_ENDPOINT -U dbadmin -d postgresqldb
```

## Outputs

After successful deployment, Terraform provides the following outputs:

### VPC Outputs
```bash
vpc_id                    # VPC identifier
vpc_cidr                  # VPC CIDR block
public_subnet_ids         # Public subnet IDs
private_subnet_ids        # Private subnet IDs
```

### EKS Outputs
```bash
eks_cluster_id            # EKS cluster ID
eks_cluster_name          # EKS cluster name
eks_cluster_endpoint      # EKS API endpoint
eks_cluster_version       # Kubernetes version
kubeconfig_command        # Command to configure kubectl
```

### RDS Outputs
```bash
rds_endpoint              # PostgreSQL endpoint (host:port)
rds_instance_id           # RDS instance identifier
rds_database_name         # Database name
rds_connection_string     # Full connection string
```

### Security Group Outputs
```bash
eks_cluster_sg_id         # EKS cluster security group
eks_node_sg_id           # EKS nodes security group
rds_security_group_id     # RDS security group
```

## Cost Estimation

**Approximate Monthly Costs (us-east-1):**

| Resource | Configuration | Est. Cost |
|----------|--------------|-----------|
| EKS Cluster | Control Plane | $73/month |
| EC2 Instances | 2x t3.medium | ~$60/month |
| NAT Gateway | 2x NAT | ~$65/month |
| RDS | db.t3.micro | ~$15/month |
| Data Transfer | Varies | ~$10/month |
| **Total** | | **~$223/month** |

**Cost Optimization Tips:**
- Use 1 NAT Gateway instead of 2 (single AZ)
- Use smaller instance types for dev
- Stop EKS nodes when not in use
- Enable RDS auto-stop for dev environments

## Customization

### Change Instance Types

Edit `terraform.tfvars`:

```hcl
eks_node_instance_types = ["t3.small"]  # Smaller instances
db_instance_class = "db.t3.small"       # Larger RDS
```

### Enable Multi-AZ RDS

```hcl
db_multi_az = true
```

### Change Regions

```hcl
aws_region = "us-west-2"
availability_zones = ["us-west-2a", "us-west-2b"]
```

## Cleanup

### Destroy All Resources

```bash
terraform destroy
```

Type `yes` when prompted. This removes all created resources.

**Warning:** This will delete:
- EKS cluster and nodes
- RDS database (with final snapshot)
- VPC and all networking
- Security groups
- IAM roles

**Time:** Approximately 10-15 minutes

## Verification Steps

### 1. Check AWS Console

**VPC:**
- Navigate to VPC Dashboard
- Verify VPC, Subnets, Route Tables, NAT Gateways

**EKS:**
- Navigate to EKS Console
- Verify cluster status: ACTIVE
- Check node group: ACTIVE with 2 nodes

**RDS:**
- Navigate to RDS Console
- Verify instance status: Available
- Check connectivity from EKS

### 2. Test EKS Cluster

```bash
# Get nodes
kubectl get nodes

# Expected output:
# NAME                          STATUS   ROLE    AGE   VERSION
# ip-10-0-10-xxx.ec2.internal   Ready    <none>  5m    v1.28.x
# ip-10-0-11-xxx.ec2.internal   Ready    <none>  5m    v1.28.x

# Check system pods
kubectl get pods -n kube-system
```

### 3. Test RDS Connection

```bash
# Deploy test pod
kubectl run postgres-test --rm -it --image=postgres:16 --restart=Never -- bash

# Inside pod:
export PGPASSWORD='your_password'
psql -h <rds-endpoint> -U dbadmin -d postgresqldb

# Run test query
SELECT version();
```

## Troubleshooting

### Issue: Terraform Init Fails

**Solution:**
```bash
# Clear cache and retry
rm -rf .terraform
terraform init
```

### Issue: AWS Authentication Error

**Solution:**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Reconfigure if needed
aws configure
```

### Issue: EKS Cluster Creation Timeout

**Solution:**
- Check AWS Console for errors
- Verify IAM permissions
- Ensure sufficient EC2 capacity in region

### Issue: kubectl Connection Error

**Solution:**
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name go-postgresql-dev-eks

# Test AWS credentials
aws eks describe-cluster --name go-postgresql-dev-eks --region us-east-1
```

### Issue: RDS Connection Refused

**Solution:**
- Verify security group allows traffic from EKS nodes
- Check RDS instance status (must be "Available")
- Ensure correct endpoint and credentials
- Test from within EKS cluster (not from local machine)

## Security Best Practices

1. **Secrets Management**
   - Use AWS Secrets Manager for RDS password
   - Never commit passwords to git
   - Use environment variables or secure vaults

2. **Network Security**
   - RDS in private subnets (not publicly accessible)
   - Minimal security group rules
   - Use VPC peering for additional security

3. **Access Control**
   - Use IRSA for pod-level IAM permissions
   - Enable EKS audit logging
   - Implement RBAC in Kubernetes

4. **Encryption**
   - RDS encryption at rest enabled
   - Use TLS for data in transit
   - Encrypt secrets in Kubernetes

## Next Steps

After infrastructure is provisioned:

1. **Step 3:** Deploy application to EKS using Kubernetes manifests
2. **Step 4:** Configure Ansible for automation
3. **Step 5:** Set up CI/CD pipeline
4. **Step 6:** Configure Grafana and Prometheus monitoring

## Support

For issues or questions:
1. Check Terraform logs: `terraform apply -auto-approve 2>&1 | tee terraform.log`
2. Review AWS CloudWatch logs
3. Consult Terraform AWS Provider documentation

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [RDS PostgreSQL Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [VPC Design Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-design-best-practices.html)
