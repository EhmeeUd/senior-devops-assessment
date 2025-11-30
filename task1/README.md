# Task 1: Terraform Modular Infrastructure

## Overview

This repository contains a production-ready Terraform implementation for deploying a multi-tier AWS infrastructure. The configuration provisions a VPC with public and private subnets, an EC2 instance, and an RDS database instance across multiple availability zones.

## Architecture

The infrastructure implements a standard three-tier architecture pattern:

- **Network Layer**: VPC with public and private subnets spanning two availability zones
- **Compute Layer**: EC2 instance in public subnet with internet gateway access
- **Data Layer**: RDS instance in private subnets with multi-AZ support

## Prerequisites

Before deploying this infrastructure, ensure you have:

- **AWS CLI**: Installed and configured with appropriate credentials
- **Terraform**: Version 1.0 or higher
- **AWS Account**: With sufficient permissions to create VPC, EC2, RDS, S3, and DynamoDB resources
- **Remote State Backend**: 
  - S3 bucket for state storage
  - DynamoDB table for state locking

## Project Structure

```
task1/
├── main.tf                    # Root module configuration
├── variables.tf               # Input variable definitions
├── outputs.tf                 # Output value definitions
├── backend.tf                 # Remote state backend configuration
├── deploy.sh                  # Deployment automation script
├── destroy.sh                 # Teardown automation script
├── modules/
│   ├── vpc/                   # VPC module (networking resources)
│   ├── ec2/                   # EC2 module (compute resources)
│   └── rds/                   # RDS module (database resources)
├── environments/
│   ├── staging/               # Staging environment variables
│   └── production/            # Production environment variables
└── README.md
```

## Initial Setup

### 1. Configure Remote State Backend

Update `backend.tf` with your S3 bucket and DynamoDB table details:

```hcl
bucket         = "your-terraform-state-bucket"
key            = "infrastructure/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "your-terraform-lock-table"
```

### 2. Configure Environment Variables

Copy the example variables file and customize for your environment:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific configuration requirements.

## Deployment

### Using Terraform CLI

#### Initialize Terraform

```bash
terraform init
```

This command initializes the working directory, downloads required providers, and configures the remote backend.

#### Review Planned Changes

```bash
terraform plan
```

Review the execution plan to verify the resources that will be created.

#### Apply Configuration

```bash
terraform apply
```

Confirm the prompt to provision the infrastructure.

### Using Terraform Workspaces

Workspaces allow you to manage multiple environments with the same configuration:

#### Create Workspaces

```bash
terraform workspace new staging
terraform workspace new production
```

#### Switch Between Workspaces

```bash
terraform workspace select staging
terraform apply
```

#### List Available Workspaces

```bash
terraform workspace list
```

### Using Deployment Scripts

Automated deployment scripts are provided for streamlined operations:

#### Deploy Environment

```bash
./deploy.sh production
./deploy.sh staging
```

#### Destroy Environment

```bash
./destroy.sh production
./destroy.sh staging
```

**Note**: Exercise caution when using destroy scripts in production environments.

## Modules

### VPC Module

Creates the foundational network infrastructure:

- VPC with configurable CIDR block
- Public and private subnets across multiple AZs
- Internet Gateway for public subnet connectivity
- NAT Gateway for private subnet internet access
- Route tables and associations

### EC2 Module

Provisions compute resources:

- EC2 instance with configurable instance type
- Security group with customizable ingress/egress rules
- IMDSv2 enforcement for enhanced security
- Encrypted EBS volumes

### RDS Module

Deploys managed database infrastructure:

- RDS instance in private subnets
- DB subnet group spanning multiple AZs
- Security group restricting access to EC2 security group
- Automated backups with configurable retention
- Multi-AZ deployment for high availability
- Encrypted storage at rest

## Design Decisions & Best Practices

### Security

- **Network Isolation**: RDS instances deployed exclusively in private subnets with no public internet access
- **Least Privilege**: Security groups configured with minimal required access
- **Encryption**: 
  - EBS volumes encrypted using AWS-managed keys
  - RDS storage encrypted at rest
- **Metadata Service**: IMDSv2 enforced on EC2 instances to prevent SSRF attacks
- **Secrets Management**: Sensitive variables marked as sensitive to prevent console exposure

### High Availability

- **Multi-AZ Deployment**: RDS configured with standby replica in separate AZ
- **Zone Distribution**: Resources distributed across two availability zones
- **NAT Gateway**: Enables private subnet resources to access internet for updates

### Cost Optimization

- **NAT Gateway**: Single NAT Gateway configuration to minimize data transfer costs
- **Instance Sizing**: t3.micro instances selected (free tier eligible)
- **Storage**: GP3 volumes for cost-effective performance

### Operational Excellence

- **Modularity**: Reusable modules enabling consistent deployments
- **Parameterization**: Extensive use of variables for environment flexibility
- **Observability**: Comprehensive outputs for resource discovery
- **Disaster Recovery**: Automated RDS backups with configurable retention periods
- **Monitoring**: CloudWatch logs enabled for RDS instances

### Idempotency

- **Safe Reapplication**: Configuration can be applied multiple times without unintended changes
- **Dynamic References**: No hardcoded values; all references use Terraform data sources or variables
- **Dependency Management**: Explicit and implicit resource dependencies properly defined

## Assumptions

- AWS credentials are configured via AWS CLI or environment variables
- Required AWS service quotas are available in the target region
- S3 bucket and DynamoDB table for remote state exist prior to initialization
- Network CIDR ranges do not conflict with existing infrastructure

## Outputs

After successful deployment, the following information is available:

- VPC ID and CIDR block
- Subnet IDs (public and private)
- EC2 instance ID and public IP
- RDS endpoint and connection details
- Security group IDs

Access outputs using:

```bash
terraform output
```

## Cleanup

### Remove All Resources

```bash
terraform destroy
```

### Delete Workspace

```bash
terraform workspace select default
terraform workspace delete staging
```

**Warning**: Ensure you've selected a different workspace before deleting the current one.

## Contributing

When contributing to this repository:

1. Follow HashiCorp Configuration Language (HCL) style guidelines
2. Use meaningful resource names following the pattern: `<resource_type>_<environment>_<purpose>`
3. Document all variables with descriptions
4. Test changes in a non-production workspace first

## Support

For issues or questions regarding this infrastructure:

- Review AWS CloudWatch logs for service-specific issues
- Verify AWS service limits in your account
- Check Terraform state lock in DynamoDB if experiencing locking issues
