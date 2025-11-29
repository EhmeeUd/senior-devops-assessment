# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = var.key_name != "" ? var.key_name : null
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              echo "Bastion host ready" > /tmp/bastion-ready.txt
              EOF
  
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = var.kms_key_id
    
    tags = merge(var.tags, {
      Name = "${var.environment}-bastion-root-volume"
    })
  }
  
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" 
  }
  
  tags = merge(var.tags, {
    Name = "${var.environment}-bastion-host"
    Tier = "Public"
  })
}

# Private EC2 Instance
resource "aws_instance" "private" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.private_sg_id]
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name != "" ? var.key_name : null
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-cloudwatch-agent
              echo "Private instance configured" > /tmp/setup-complete.txt
              EOF
  
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = var.kms_key_id
    
    tags = merge(var.tags, {
      Name = "${var.environment}-private-ec2-root-volume"
    })
  }
  
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  
  }
  
  tags = merge(var.tags, {
    Name = "${var.environment}-private-ec2"
    Tier = "Private"
  })
}

# Additional Encrypted EBS Volume 
resource "aws_ebs_volume" "app_data" {
  availability_zone = aws_instance.private.availability_zone
  size              = 30
  encrypted         = true
  kms_key_id        = var.kms_key_id
  type              = "gp3"
  
  tags = merge(var.tags, {
    Name = "${var.environment}-app-data-volume"
  })
}

resource "aws_volume_attachment" "app_data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.app_data.id
  instance_id = aws_instance.private.id
}