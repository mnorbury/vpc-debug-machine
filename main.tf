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
  key_name   = "vpc-debug-${var.vpc_id}-${var.subnet_id}"
  public_key = tls_private_key.debug_key.public_key_openssh
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
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-debug-sg"
  }
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
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.debug_sg.id]
  key_name                    = aws_key_pair.debug_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "vpc-debug-instance"
  }
}
