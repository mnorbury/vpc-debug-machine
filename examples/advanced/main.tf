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
  subnet_id = "subnet-xxxxxxxxxxxxx" # Replace with your subnet ID

  # Instance configuration
  instance_type = "t3.small"
  instance_name = "advanced-debug-instance"

  # Network configuration
  associate_public_ip = true
  ssh_cidr_blocks     = ["203.0.113.0/24"] # Replace with your IP/CIDR

  # Storage configuration
  root_volume_size = 20
  root_volume_type = "gp3"

  # User data - install useful debugging tools
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update system
    yum update -y

    # Install debugging and monitoring tools
    yum install -y \
      htop \
      tmux \
      vim \
      curl \
      wget \
      tcpdump \
      net-tools \
      bind-utils \
      telnet \
      nc \
      traceroute \
      iperf3

    # Configure vim
    echo "syntax on" >> /home/ec2-user/.vimrc
    echo "set number" >> /home/ec2-user/.vimrc

    # Create a welcome message
    cat >> /etc/motd << 'MOTD'

    ================================================
    Welcome to the VPC Debug Instance
    ================================================

    Installed tools:
    - htop: System monitoring
    - tmux: Terminal multiplexer
    - tcpdump: Network packet analyzer
    - iperf3: Network performance testing

    ================================================
    MOTD
  EOF

  # Enable detailed monitoring
  enable_detailed_monitoring = true

  # Tags
  tags = {
    Environment = "development"
    Project     = "network-debugging"
    ManagedBy   = "terraform"
    Owner       = "platform-team"
  }
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

output "security_group_id" {
  value       = module.debug_instance.security_group_id
  description = "ID of the security group"
}
