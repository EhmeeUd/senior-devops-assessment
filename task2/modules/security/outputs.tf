output "bastion_sg_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion.id
}

output "private_ec2_sg_id" {
  description = "Private EC2 security group ID"
  value       = aws_security_group.private_ec2.id
}

output "private_nacl_id" {
  description = "Private subnet NACL ID"
  value       = aws_network_acl.private.id
}