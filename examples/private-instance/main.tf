terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "debug_instance" {
  source = "../.."

  # Required parameters
  vpc_id    = "vpc-xxxxxxxxxxxxx"    # Replace with your VPC ID
  subnet_id = "subnet-xxxxxxxxxxxxx" # Replace with your private subnet ID

  # Instance configuration
  instance_type = "t3.micro"
  instance_name = "private-debug-instance"

  # Network configuration - No public IP
  associate_public_ip = false

  # Restrict SSH to internal VPC CIDR or specific bastion host
  ssh_cidr_blocks = ["10.0.0.0/16"] # Replace with your VPC CIDR

  # Tags
  tags = {
    Environment = "production"
    Project     = "network-debugging"
    Visibility  = "private"
  }
}

output "instance_id" {
  value       = module.debug_instance.instance_id
  description = "ID of the created EC2 instance"
}

output "instance_private_ip" {
  value       = module.debug_instance.instance_private_ip
  description = "Private IP of the debug instance"
}

output "security_group_id" {
  value       = module.debug_instance.security_group_id
  description = "ID of the security group"
}

output "connection_info" {
  value       = <<-EOT
    To connect to this private instance, use one of these methods:

    1. Via AWS Systems Manager Session Manager:
       aws ssm start-session --target ${module.debug_instance.instance_id}

    2. Via SSH from a bastion host or VPN:
       ssh -i ${module.debug_instance.private_key_file} ec2-user@${module.debug_instance.instance_private_ip}

    Note: For SSM Session Manager, ensure the instance has the required IAM role.
  EOT
  description = "Instructions for connecting to the private instance"
}
