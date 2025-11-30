# Task 2: AWS Cloud Security Infrastructure - Terraform Implementation

## Overview

This repository contains an enterprise-grade Terraform implementation focused on security best practices for AWS cloud infrastructure. The configuration establishes a secure, monitored, and compliant multi-tier environment suitable for production workloads.

## Architecture

The infrastructure implements a defense-in-depth security architecture:

- **Network Layer**: Segmented VPC with public/private subnet isolation and network flow logging
- **Compute Layer**: Bastion host for controlled access and application servers in private subnets
- **Security Layer**: Multi-layered security controls including security groups, NACLs, and IAM policies
- **Monitoring Layer**: Comprehensive audit logging, compliance monitoring, and centralized log management
- **Encryption Layer**: Encryption at rest using AWS KMS with automatic key rotation

## Prerequisites

Before deploying this infrastructure, ensure you have:

- **AWS CLI**: Installed and configured with appropriate credentials (`aws configure`)
- **Terraform**: Version 1.0 or higher
- **AWS Account**: With sufficient permissions to create VPC, EC2, IAM, CloudTrail, CloudWatch, and KMS resources
- **SSH Key Pair**: Created in the target AWS region for EC2 instance access
- **IP Whitelist**: Your public IP address for SSH access restrictions

## Project Structure

```
task2/
├── main.tf                    # Root module orchestration
├── variables.tf               # Input variable definitions
├── outputs.tf                 # Output value definitions
├── backend.tf                 # Remote state backend configuration
├── deploy.sh                  # Deployment automation script
├── destroy.sh                 # Teardown automation script
├── terraform.tfvars.example   # Example variable configuration
├── modules/
│   ├── vpc/                   # Network infrastructure module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/              # Security groups and NACLs module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/                   # Identity and access management module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── monitoring/            # Logging and compliance module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/               # EC2 instance provisioning module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
└── README.md
```

## Initial Setup

### 1. Configure Remote State Backend (Optional)

For team environments or production deployments, configure remote state in `backend.tf`:

```hcl
bucket         = "your-terraform-state-bucket"
key            = "security-infrastructure/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "your-terraform-lock-table"
```

### 2. Configure Environment Variables

Create your variable configuration file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your environment-specific values:

```hcl
aws_region        = "us-west-2"
vpc_cidr          = "10.0.0.0/16"
key_name          = "your-ssh-key-name"
allowed_ssh_cidrs = ["YOUR.PUBLIC.IP.ADDRESS/32"]  # Replace with your IP
instance_type     = "t3.micro"
enable_aws_config = true  # Set to false to reduce costs in dev/test
```

**Important**: Replace `YOUR.PUBLIC.IP.ADDRESS/32` with your actual public IP address to restrict SSH access.

### 3. Initialize Terraform

```bash
terraform init
```

This command initializes the working directory, downloads required providers, and configures the backend.

## Deployment

### Using Terraform CLI

#### Review Planned Changes

```bash
terraform plan
```

Carefully review the execution plan to verify all resources and configurations.

#### Apply Configuration

```bash
terraform apply
```

Review the plan output and confirm the prompt to provision the infrastructure.

### Using Deployment Script

For automated deployment with validation:

```bash
chmod +x deploy.sh
./deploy.sh
```

The deployment script includes pre-flight checks and error handling.

## Teardown

### Using Terraform CLI

```bash
terraform destroy
```

**Warning**: This will permanently delete all provisioned resources. Ensure you have backups of any critical data.

### Using Destroy Script

```bash
chmod +x destroy.sh
./destroy.sh
```

## Module Descriptions

### VPC Module

Creates the foundational network security architecture:

- VPC with configurable CIDR block
- Public subnets for internet-facing resources (bastion hosts)
- Private subnets for application workloads (no direct internet access)
- Internet Gateway for public subnet connectivity
- NAT Gateway enabling private subnet outbound internet access
- **VPC Flow Logs**: Captures network traffic metadata for security analysis

### Security Module

Implements multi-layered network security controls:

- **Security Groups**: Stateful firewall rules at the instance level
  - Bastion host security group (restricted SSH access)
  - Private instance security group (allows only bastion access)
- **Network ACLs**: Stateless subnet-level traffic filtering for defense-in-depth
- **Least Privilege**: All rules follow the principle of minimum necessary access

### IAM Module

Manages identity and access control following AWS best practices:

- **EC2 Instance Role**: Assigned to EC2 instances via instance profile
- **S3 Read Access**: Minimal permissions for accessing application data
- **CloudWatch Logs**: Write permissions for application logging
- **Systems Manager**: Enables automated patch management and session access
- **Least Privilege Principle**: Policies grant only required permissions

### Monitoring Module

Establishes comprehensive security monitoring and compliance:

- **CloudTrail**: Records all AWS API calls for security audit and compliance
- **CloudWatch Log Groups**: Centralized log aggregation with configurable retention
- **KMS Encryption**: Customer-managed keys for encrypting sensitive log data
- **AWS Config** (Optional): Continuous compliance monitoring and resource inventory
- **S3 Log Archive**: Long-term encrypted storage for audit trails

### Compute Module

Provisions secure EC2 infrastructure:

- **Bastion Host**: Deployed in public subnet for controlled SSH access
- **Application Instance**: Deployed in private subnet with no direct internet exposure
- **Encrypted EBS Volumes**: All storage encrypted using AWS KMS
- **IMDSv2**: Metadata service v2 enforced to prevent SSRF attacks
- **SSM Agent**: Pre-configured for secure remote management

## Security Best Practices Implementation

### Network Security

- **Private Subnet Deployment**: Application instances isolated from direct internet access
- **Bastion Host Architecture**: Single, auditable entry point for SSH access
- **Defense-in-Depth**: Security groups and NACLs provide layered protection
- **VPC Flow Logs**: Network traffic monitoring for anomaly detection
- **Least Privilege Network Rules**: Only essential ports and protocols allowed

### Identity & Access Management

- **IAM Roles Over Access Keys**: No long-term credentials stored on instances
- **Instance Profiles**: Secure credential delivery to EC2 instances
- **Service-Specific Policies**: Granular permissions scoped to specific resources
- **No Hardcoded Credentials**: All authentication via AWS STS temporary credentials

### Data Protection & Encryption

- **EBS Encryption**: All volumes encrypted at rest using AWS KMS
- **S3 Bucket Encryption**: Server-side encryption enabled on all buckets
- **KMS Key Rotation**: Automatic annual key rotation enabled
- **CloudTrail Encryption**: API logs encrypted with customer-managed keys
- **VPC Flow Log Encryption**: Network logs encrypted in CloudWatch

### Monitoring & Compliance

- **CloudTrail Audit Logging**: Complete API call history for forensics
- **Centralized Logging**: CloudWatch Logs for all infrastructure components
- **AWS Config Monitoring**: Continuous compliance rule evaluation (optional)
- **Log Retention Policies**: Configurable retention for cost optimization
- **S3 Log Archival**: Immutable audit trail with versioning enabled

### Infrastructure Security Hardening

- **IMDSv2 Enforcement**: Protects against SSRF and credential theft
- **S3 Public Access Block**: Prevents accidental data exposure
- **S3 Versioning**: Enables recovery from accidental deletions
- **Resource Tagging**: Supports governance and cost allocation
- **Multi-AZ Deployment**: Enhances availability and resilience

## Design Decisions & Rationale

### Bastion Host Architecture

**Decision**: Implement a dedicated bastion host in the public subnet for SSH access.

**Rationale**:
- Provides a single, auditable entry point for administrative access
- Reduces attack surface by limiting public-facing resources
- Can be stopped when not in use to minimize costs and exposure
- Enables centralized access logging and monitoring

### Private Subnet Application Deployment

**Decision**: Deploy application workloads exclusively in private subnets.

**Rationale**:
- Eliminates direct internet exposure of application servers
- Forces all outbound traffic through NAT Gateway for monitoring
- Significantly reduces risk of unauthorized access and DDoS attacks
- Aligns with AWS Well-Architected Framework security pillar

### AWS KMS for Encryption

**Decision**: Use customer-managed KMS keys for all encryption requirements.

**Rationale**:
- Centralized key management and policy control
- Comprehensive audit trail for all key usage via CloudTrail
- Automatic key rotation capabilities
- Fine-grained access control through key policies
- Compliance requirement for many regulatory frameworks

### CloudTrail Implementation

**Decision**: Enable CloudTrail for all regions with log file validation.

**Rationale**:
- Required for security compliance (SOC 2, ISO 27001, PCI-DSS)
- Enables forensic investigation and incident response
- Detects unusual activity patterns and unauthorized actions
- Provides non-repudiable audit trail of all API calls

### AWS Config (Optional)

**Decision**: Make AWS Config optional but enabled by default.

**Rationale**:
- Provides continuous compliance monitoring
- Enables resource inventory and change tracking
- Cost consideration for development/test environments
- Essential for production and regulated workloads

## Cost Optimization Considerations

- **Single NAT Gateway**: Suitable for development/test (scale to multiple for production HA)
- **Free Tier Instances**: t3.micro instances minimize compute costs
- **Configurable Log Retention**: 7-day default (adjust based on compliance requirements)
- **Optional AWS Config**: Disable in non-production to reduce costs (~$2/rule/month)
- **Bastion Host Control**: Can be stopped when not in use

**Production Recommendations**:
- Deploy NAT Gateways in multiple AZs for high availability
- Increase log retention to meet compliance requirements
- Enable AWS Config for continuous compliance monitoring
- Consider Reserved Instances or Savings Plans for long-term workloads

## Accessing Your Infrastructure

### SSH Access via Bastion Host

Retrieve infrastructure details:

```bash
terraform output
```

Connect to bastion host:

```bash
ssh -i /path/to/your-key.pem ec2-user@<bastion_public_ip>
```

From bastion, connect to private instance:

```bash
ssh ec2-user@<private_instance_ip>
```

### AWS Systems Manager Session Manager (Recommended)

For secure access without SSH keys:

```bash
# No SSH keys or bastion required
aws ssm start-session --target <private_instance_id>
```

**Advantages**:
- No open inbound ports required
- All sessions logged to CloudWatch and S3
- No SSH key management overhead
- Works with instances in private subnets

## Outputs

After successful deployment, the following information is available:

- **Network**: VPC ID, subnet IDs, route table IDs
- **Compute**: Bastion public IP, private instance ID
- **Security**: Security group IDs, KMS key ARN
- **Monitoring**: CloudTrail name, S3 log bucket name, CloudWatch log groups
- **IAM**: Instance profile ARN and role name

Access outputs:

```bash
terraform output
terraform output -json  # For programmatic access
```

## Compliance & Security Standards

This infrastructure implements controls aligned with:

- **AWS Well-Architected Framework**: Security pillar best practices
- **CIS AWS Foundations Benchmark**: Industry-standard security baseline
- **NIST Cybersecurity Framework**: Defense-in-depth architecture
- **Principle of Least Privilege**: Applied to all IAM and network policies

## Assumptions

1. **AWS Region**: Deployment to a region with at least two availability zones
2. **SSH Key Management**: SSH key pair pre-created in the target AWS region
3. **Network Requirements**: No conflicts with existing VPC CIDR ranges
4. **Access Control**: SSH access restricted to specified CIDR blocks
5. **Cost Profile**: Configuration optimized for development/test workloads
6. **Compliance Requirements**: AWS Config optional based on organizational needs
7. **Internet Access**: Required for package installations and updates via NAT Gateway

## Monitoring & Alerting

### CloudWatch Logs

All logs are centralized in CloudWatch Log Groups:
- VPC Flow Logs
- CloudTrail logs
- EC2 instance logs (via CloudWatch agent)

### CloudTrail

Monitors and logs:
- All API calls across your AWS account
- Who made the call, when, and from what IP
- What resources were affected

### AWS Config (Optional)

When enabled, monitors:
- Resource configuration changes
- Compliance with organizational policies
- Historical configuration data

## Troubleshooting

### Cannot Connect to Bastion Host

- Verify your IP is in `allowed_ssh_cidrs`
- Check security group rules: `terraform output bastion_security_group_id`
- Verify SSH key matches the key specified in `key_name`

### Cannot Access Private Instance from Bastion

- Ensure SSH key is forwarded: `ssh -A` or copy key to bastion
- Verify security group allows traffic from bastion
- Check network ACL rules if connectivity fails

### High AWS Costs

- Stop bastion host when not in use
- Disable AWS Config in development environments
- Reduce CloudWatch Logs retention period
- Review NAT Gateway data transfer charges

## Contributing

When contributing to this repository:

1. Follow HashiCorp Configuration Language (HCL) style guidelines
2. Run `terraform fmt` before committing
3. Update documentation for any new modules or significant changes
4. Test changes in a non-production environment first
5. Follow the principle of least privilege for all IAM policies
6. Document security considerations for new features

## Security Considerations

### Regular Maintenance

- Rotate SSH keys periodically
- Review and update security group rules quarterly
- Monitor CloudTrail logs for suspicious activity
- Keep AMIs updated with latest security patches
- Review IAM policies for privilege creep

### Incident Response

In case of security incident:
1. Isolate affected instances by modifying security groups
2. Review CloudTrail logs for the timeframe of the incident
3. Capture VPC Flow Logs for forensic analysis
4. Create snapshots of affected EBS volumes before remediation
5. Review AWS Config timeline for configuration changes

## Support & Contact

For issues or questions regarding this infrastructure:

- Review CloudWatch Logs for application and system issues
- Check CloudTrail for API call errors
- Verify AWS service quotas if resource creation fails
- Review VPC Flow Logs for network connectivity issues
