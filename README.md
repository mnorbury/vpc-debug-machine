# vpc-debug-machine

A Terraform module that creates an EC2 instance in a specified VPC and subnet for debugging purposes. The module automatically generates SSH keys, configures security groups, and provides easy SSH access.

## Features

- Creates a configurable EC2 instance (default: Amazon Linux 2023, t3.micro)
- Automatically generates and saves SSH key pair locally
- Configures security group with customizable SSH access restrictions
- Optional public IP address assignment
- Configurable instance type, AMI, storage, and more
- Support for custom user data scripts
- Outputs SSH connection command for convenience

## Usage

### Basic Usage

```hcl
module "debug_instance" {
  source = "github.com/YOUR-USERNAME/vpc-debug-machine?ref=v1.0.0"

  vpc_id    = "vpc-xxxxxxxxxxxxx"
  subnet_id = "subnet-xxxxxxxxxxxxx"
}

output "ssh_command" {
  value = module.debug_instance.ssh_command
}
```

### Advanced Configuration

```hcl
module "debug_instance" {
  source = "github.com/YOUR-USERNAME/vpc-debug-machine?ref=v1.0.0"

  vpc_id    = "vpc-xxxxxxxxxxxxx"
  subnet_id = "subnet-xxxxxxxxxxxxx"

  # Instance configuration
  instance_type = "t3.small"
  instance_name = "my-debug-instance"

  # Network configuration
  associate_public_ip = true
  ssh_cidr_blocks     = ["203.0.113.0/24"] # Restrict SSH to specific CIDR

  # Storage configuration
  root_volume_size = 20
  root_volume_type = "gp3"

  # Optional: Custom AMI
  # ami_id = "ami-xxxxxxxxxxxxx"

  # Optional: User data script
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y htop tmux
  EOF

  # Monitoring
  enable_detailed_monitoring = true

  # Tags
  tags = {
    Environment = "development"
    Project     = "network-debugging"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| local | ~> 2.0 |
| tls | ~> 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_id | The VPC ID where the debug instance will be created | `string` | - | yes |
| subnet_id | The subnet ID where the debug instance will be launched | `string` | - | yes |
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |
| instance_name | Name tag for the EC2 instance | `string` | `"vpc-debug-instance"` | no |
| ssh_cidr_blocks | CIDR blocks allowed to SSH into the instance | `list(string)` | `["0.0.0.0/0"]` | no |
| associate_public_ip | Whether to associate a public IP address with the instance | `bool` | `true` | no |
| root_volume_size | Size of the root volume in GB | `number` | `30` | no |
| root_volume_type | Type of the root volume | `string` | `"gp3"` | no |
| ami_id | AMI ID to use for the instance. If not specified, latest Amazon Linux 2023 will be used | `string` | `null` | no |
| user_data | User data script to run on instance startup | `string` | `null` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| enable_detailed_monitoring | Enable detailed monitoring for the EC2 instance | `bool` | `false` | no |
| key_name_prefix | Prefix for the SSH key pair name | `string` | `"vpc-debug"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the debug EC2 instance |
| instance_public_ip | Public IP address of the debug instance |
| instance_private_ip | Private IP address of the debug instance |
| security_group_id | ID of the security group attached to the instance |
| private_key_file | Path to the generated private key file |
| ssh_command | Complete SSH command to connect to the instance |

## Example

1. Create a `terraform.tfvars` file (see `terraform.tfvars.example`):
```hcl
vpc_id    = "vpc-0123456789abcdef0"
subnet_id = "subnet-0123456789abcdef0"
```

2. Initialize and apply:
```bash
terraform init
terraform apply
```

3. Connect to the instance:
```bash
# The SSH command is provided in the outputs
terraform output ssh_command
# Or run it directly:
ssh -i debug-key.pem ec2-user@<public-ip>
```

## Security Notes

- By default, the security group allows SSH access from anywhere (0.0.0.0/0). **Strongly recommend** restricting this using the `ssh_cidr_blocks` variable to your specific IP or network range.
- The private key (`debug-key.pem`) is generated locally. Keep this file secure and never commit it to version control.
- This module is intended for temporary debugging purposes only.
- Consider disabling public IP assignment (`associate_public_ip = false`) if you can access the instance via VPN or bastion host.

## Clean Up

To destroy the resources:
```bash
terraform destroy
```

## License

MIT
