# Task 1: Terraform Modular Infrastructure

## Prerequisites
- AWS CLI configured
- Terraform >= 1.0
- AWS account with appropriate permissions
- S3 bucket for remote state
- DynamoDB table for state locking

## Setup
1. Update `backend.tf` with your S3 bucket name
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Update variables as needed

## Usage

### Initialize
terraform init

### Plan
terraform plan

### Apply
terraform apply

### Using Workspaces
terraform workspace new staging
terraform workspace new production
terraform workspace select staging
terraform apply

## Modules
- **vpc**: Creates VPC, subnets, IGW, NAT
- **ec2**: Launches EC2 with security group
- **rds**: Creates RDS instance in private subnet

## Design Decisions
- Private subnets for RDS (security)
- Public subnet for EC2 (bastion/app server)
- Variables for reusability
- Remote state for team collaboration
```