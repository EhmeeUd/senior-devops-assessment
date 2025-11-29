# Task 2: AWS Cloud Security Infrastructure

## Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- AWS account with appropriate permissions
- SSH key pair created in AWS (for EC2 access)

## Project Structure
```
task2/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── destroy.sh
├── deploy.sh
├── terraform.tfvars.example
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── monitoring/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md
```

## Setup

### 1. Configure Backend
If using remote state, update `backend.tf` with your S3 bucket name and DynamoDB table:
```hcl
bucket         = "your-terraform-state-bucket"
dynamodb_table = "your-terraform-lock-table"
```

### 2. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
aws_region        = "us-west-2"
vpc_cidr          = "10.0.0.0/16"
key_name          = "your-ssh-key-name"
allowed_ssh_cidrs = ["YOUR_IP/32"]  # Replace with your IP
instance_type     = "t3.micro"
enable_aws_config = true
```

### 3. Initialize Terraform
```bash
terraform init
```

## Deployment

### Manual Deployment
```bash
terraform plan # to preview changes

terraform apply # to apply changes
```

### Using Deploy Script
```bash
chmod +x deploy.sh
./deploy.sh
```

## Destruction

### Manual Destroy
```bash
terraform destroy
```

### Using Destroy Script
```bash
chmod +x destroy.sh
./destroy.sh
```

## Modules

### VPC Module
- Creates VPC with public and private subnets across multiple AZs
- Internet Gateway for public subnets
- NAT Gateway for private subnet internet access
- VPC Flow Logs enabled (logs to CloudWatch)

### Security Module
- Security groups for bastion host and private EC2
- Network ACLs for additional subnet-level protection
- Least privilege access rules

### IAM Module
- EC2 instance role with minimal required permissions
- S3 read access for application data
- CloudWatch Logs write permissions
- Systems Manager access for patching

### Monitoring Module
- CloudTrail for API call logging
- CloudWatch Log Groups for centralized logging
- KMS key for encryption
- AWS Config for compliance monitoring (optional)
- S3 bucket for logs with encryption

### Compute Module
- Bastion host in public subnet (controlled access)
- Application EC2 in private subnet
- EBS volumes encrypted with KMS
- IMDSv2 enforced
- SSM agent for patch management

## Security Best Practices Implemented

### Network Security
- ✅ EC2 instances in private subnets (no direct internet access)
- ✅ Bastion host for secure SSH access
- ✅ Security groups with least privilege rules
- ✅ Network ACLs for defense in depth
- ✅ VPC Flow Logs enabled for traffic monitoring

### Identity & Access Management
- ✅ IAM roles with least privilege principle
- ✅ No hardcoded credentials
- ✅ Instance profiles for EC2 permissions
- ✅ Service-specific policies only

### Data Protection
- ✅ EBS volumes encrypted with KMS
- ✅ S3 buckets encrypted at rest
- ✅ KMS key rotation enabled
- ✅ CloudTrail log encryption
- ✅ VPC Flow Logs encrypted

### Monitoring & Compliance
- ✅ CloudTrail enabled for API audit logging
- ✅ CloudWatch Logs for centralized logging
- ✅ AWS Config for compliance rules (optional)
- ✅ Log retention policies configured
- ✅ S3 bucket for long-term log storage

### Infrastructure Security
- ✅ IMDSv2 enforced on EC2 instances
- ✅ Public access blocked on S3 buckets
- ✅ Versioning enabled on log buckets
- ✅ Resource tagging for governance
- ✅ Multi-AZ deployment for availability

## Design Decisions

### Why Bastion Host?
- Provides secure, auditable access to private resources
- Single point of entry reduces attack surface
- Can be stopped when not in use to save costs

### Why Private Subnets for Application?
- Eliminates direct internet exposure
- Forces all outbound traffic through NAT Gateway
- Reduces risk of unauthorized access

### Why KMS for Encryption?
- Centralized key management
- Audit trail for key usage
- Key rotation capabilities
- Fine-grained access control

### Why CloudTrail?
- Complete audit log of all API calls
- Required for security compliance
- Enables incident investigation
- Detects unusual activity patterns

### Cost Optimization
- ✅ Single NAT Gateway (can add more for HA in production)
- ✅ t3.micro instances (Free tier eligible)
- ✅ 7-day log retention (reduce for cost savings)
- ✅ Optional AWS Config (disable to reduce costs)

## Accessing Your Infrastructure

### SSH to Private EC2 (via Bastion)
```bash
# Get instance IPs from outputs
terraform output

# SSH to bastion first
ssh -i your-key.pem ec2-user@<bastion-public-ip>

# From bastion, SSH to private instance
ssh ec2-user@<private-instance-ip>
```

### Using AWS Systems Manager Session Manager
```bash
# No SSH keys needed
aws ssm start-session --target <private-instance-id>
```

## Outputs
After deployment, Terraform provides:
- VPC ID
- Subnet IDs
- Bastion public IP
- Private instance ID
- Security group IDs
- S3 log bucket name
- CloudTrail name

## Assumptions

1. **Region**: Deploys to specified AWS region with at least 2 AZs
2. **SSH Access**: You have created an SSH key pair in AWS
3. **IP Restrictions**: SSH limited to specified CIDR blocks
4. **Cost**: Uses minimal resources suitable for testing/development
5. **Compliance**: AWS Config is optional - enable for compliance requirements

## Clean Up
```bash
./destroy.sh #destroy resources

terraform destroy -auto-approve # Or manually
```

---

## Author
**Iniemem Udosen**  
DevOps Engineer  
iniememudosen@gmail.com