output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

# EC2 Outputs
output "private_ec2_instance_id" {
  description = "Private EC2 instance ID"
  value       = module.compute.private_instance_id
}

output "private_ec2_private_ip" {
  description = "Private EC2 instance IP"
  value       = module.compute.private_instance_private_ip
}

output "bastion_instance_id" {
  description = "Bastion host instance ID"
  value       = module.compute.bastion_instance_id
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.compute.bastion_public_ip
}

# Security Outputs
output "private_ec2_security_group_id" {
  description = "Private EC2 security group ID"
  value       = module.security.private_ec2_sg_id
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = module.security.bastion_sg_id
}

# IAM Outputs
output "ec2_iam_role_arn" {
  description = "EC2 IAM role ARN"
  value       = module.iam.ec2_role_arn
}

# Monitoring Outputs
output "cloudtrail_name" {
  description = "CloudTrail trail name"
  value       = module.monitoring.cloudtrail_name
}

output "cloudtrail_bucket" {
  description = "CloudTrail S3 bucket"
  value       = module.monitoring.cloudtrail_bucket
}

output "kms_key_id" {
  description = "KMS key ID for encryption"
  value       = module.monitoring.kms_key_id
}

output "ssh_to_bastion" {
  description = "SSH command to bastion"
  value       = var.key_name != "" ? "ssh -i ${var.key_name}.pem ec2-user@${module.compute.bastion_public_ip}" : "No key pair configured"
}

output "ssh_to_private_via_bastion" {
  description = "SSH to private instance via bastion"
  value       = var.key_name != "" ? "ssh -i ${var.key_name}.pem -J ec2-user@${module.compute.bastion_public_ip} ec2-user@${module.compute.private_instance_private_ip}" : "No key pair configured"
}

# Security
output "security_summary" {
  description = "Security features enabled"
  value = {
    vpc_flow_logs_enabled    = true
    cloudtrail_enabled       = true
    encryption_at_rest       = true
    iam_least_privilege      = true
    private_subnet_isolation = true
    aws_config_enabled       = var.enable_aws_config
  }
}