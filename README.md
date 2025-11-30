# DevOps Assessment - Iniemem Udosen

This repository contains solutions for the first 2 DevOps Code Challenge assessment.

## Repository Structure
```
devops-assessment/
├── task1/              # Terraform Modular Infrastructure
├── task2/              # AWS Cloud Security
└── README.md  
```

## Task 1: Terraform Modules
Modular Terraform setup for VPC, EC2, and RDS with remote state management.

[Full documentation →](task1/README.md)

**Key Features:**
- Reusable modules
- Remote state (S3 + DynamoDB)
- Workspace support
- Security groups
- Proper tagging

## Task 2: AWS Cloud Security
Secure infrastructure with IAM, CloudTrail, encryption, and monitoring.

[Full documentation →](task2/README.md)

**Security Features:**
- Private/public subnet architecture
- Least privilege IAM
- CloudTrail API logging
- VPC Flow Logs
- Encryption at rest (EBS, S3, RDS)
- CloudWatch alarms for unauthorized access
- AWS Config (bonus)
