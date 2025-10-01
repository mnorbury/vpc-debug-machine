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

  vpc_id    = "vpc-xxxxxxxxxxxxx"    # Replace with your VPC ID
  subnet_id = "subnet-xxxxxxxxxxxxx" # Replace with your subnet ID
}

output "ssh_command" {
  value       = module.debug_instance.ssh_command
  description = "Command to SSH into the debug instance"
}

output "instance_id" {
  value       = module.debug_instance.instance_id
  description = "ID of the created EC2 instance"
}

output "instance_public_ip" {
  value       = module.debug_instance.instance_public_ip
  description = "Public IP of the debug instance"
}
