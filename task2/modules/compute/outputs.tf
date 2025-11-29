output "bastion_instance_id" {
  description = "Bastion instance ID"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Bastion private IP"
  value       = aws_instance.bastion.private_ip
}

output "private_instance_id" {
  description = "Private EC2 instance ID"
  value       = aws_instance.private.id
}

output "private_instance_private_ip" {
  description = "Private EC2 instance IP"
  value       = aws_instance.private.private_ip
}

output "app_data_volume_id" {
  description = "App data EBS volume ID"
  value       = aws_ebs_volume.app_data.id
}