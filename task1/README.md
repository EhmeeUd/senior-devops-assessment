# Task 1: Terraform Modular Infrastructure

## Prerequisites
- AWS CLI configured
- `Terraform >= 1.0`
- AWS account with appropriate permissions
- S3 bucket for remote state
- DynamoDB table for state locking

## Setup
1. Update `backend.tf` with your S3 bucket name
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Update variables as needed

## Usage

### Initialize
`terraform init`

### Plan
`terraform plan`

### Apply
`terraform apply`

### Using Workspaces
`terraform workspace new staging`
`terraform workspace new production`
`terraform workspace select staging`
`terraform apply`

### Destroy
`terraform destroy`

### Destroy Workspace
`terraform workspace select production`
`terraform workspace delete staging`

### Using the deploy Script
`./deploy.sh production`
`./deploy.sh staging`

### Destroy using the destroy script
`./destroy.sh production`
`./destroy.sh staging`

## Modules
- **vpc**: Creates VPC, subnets, IGW, NAT
- **ec2**: Launches EC2 with security group
- **rds**: Creates RDS instance in private subnet

## Design Decisions & Best Practices

### Security
- ✅ RDS in private subnets (no public access)
- ✅ Security groups with least privilege
- ✅ Encrypted EBS volumes
- ✅ Encrypted RDS storage
- ✅ IMDSv2 enforced on EC2
- ✅ Sensitive variables marked as sensitive

### High Availability
- ✅ Multi-AZ support for RDS
- ✅ Resources spread across 2 AZs
- ✅ NAT Gateway for private subnet internet access

### Cost Optimization
- ✅ Single NAT Gateway
- ✅ t3.micro instances (Free tier eligible)
- ✅ GP3 storage (cost-effective)

### Operational Excellence
- ✅ Modular design for reusability
- ✅ Variables for flexibility
- ✅ Comprehensive outputs
- ✅ Automated backups
- ✅ CloudWatch logs for RDS

### Idempotency
- ✅ Can run `terraform apply` multiple times safely
- ✅ No hardcoded values
- ✅ Proper resource dependencies

---
