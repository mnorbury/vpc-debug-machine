# Basic Example

This example demonstrates the most basic usage of the vpc-debug-machine module with only the required parameters.

## Usage

1. Update the `vpc_id` and `subnet_id` in `main.tf` with your AWS VPC and subnet IDs.

2. Initialize and apply:
```bash
terraform init
terraform apply
```

3. Connect to the instance using the provided SSH command:
```bash
terraform output -raw ssh_command | bash
```

## What This Creates

- EC2 t3.micro instance with Amazon Linux 2023
- Security group allowing SSH from anywhere (0.0.0.0/0)
- Auto-generated SSH key pair
- Public IP address for external access

## Clean Up

```bash
terraform destroy
```
