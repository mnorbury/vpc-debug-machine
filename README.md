# vpc-debug-machine

A Terraform module that creates an EC2 instance in a specified VPC and subnet for debugging purposes. The module automatically generates SSH keys, configures security groups, and provides easy SSH access.

## Features

- Creates an EC2 instance (Amazon Linux 2023, t3.micro)
- Automatically generates and saves SSH key pair locally
- Configures security group with SSH access (port 22)
- Assigns public IP address for external access
- Outputs SSH connection command for convenience

## Usage

### From GitHub

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

### Local Module

```hcl
module "debug_instance" {
  source = "./vpc-debug-machine"

  vpc_id    = "vpc-xxxxxxxxxxxxx"
  subnet_id = "subnet-xxxxxxxxxxxxx"
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

| Name | Description | Type | Required |
|------|-------------|------|----------|
| vpc_id | The VPC ID where the debug instance will be created | `string` | yes |
| subnet_id | The subnet ID where the debug instance will be launched | `string` | yes |

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

- The security group allows SSH access from anywhere (0.0.0.0/0). Consider restricting this to your IP address for production use.
- The private key (`debug-key.pem`) is generated locally. Keep this file secure and never commit it to version control.
- This module is intended for temporary debugging purposes only.

## Clean Up

To destroy the resources:
```bash
terraform destroy
```

## License

MIT
