terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Generate SSH key pair
resource "tls_private_key" "debug_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "debug_key" {
  key_name   = "${var.key_name_prefix}-${var.vpc_id}-${var.subnet_id}"
  public_key = tls_private_key.debug_key.public_key_openssh
  tags       = var.tags
}

# Write private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.debug_key.private_key_pem
  filename        = "${path.module}/debug-key.pem"
  file_permission = "0400"
}

# Security group for SSH access
resource "aws_security_group" "debug_sg" {
  name_prefix = "vpc-debug-sg-"
  description = "Security group for debug EC2 instance - SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from allowed CIDR blocks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "vpc-debug-sg"
    },
    var.tags
  )
}

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 instance
resource "aws_instance" "debug_instance" {
  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.debug_sg.id]
  key_name                    = aws_key_pair.debug_key.key_name
  associate_public_ip_address = var.associate_public_ip
  monitoring                  = var.enable_detailed_monitoring
  user_data                   = var.user_data

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}
