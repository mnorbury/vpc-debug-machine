# Private Instance Example

This example demonstrates deploying a debug instance in a private subnet without a public IP address, suitable for production environments or networks with strict security requirements.

## Features

- No public IP address assigned
- Placed in a private subnet
- SSH access restricted to internal VPC CIDR
- Accessible via bastion host, VPN, or AWS Systems Manager Session Manager

## Prerequisites

To access this instance, you need one of the following:
1. **AWS Systems Manager Session Manager**: Instance must have an IAM role with SSM permissions
2. **Bastion Host**: A jump server in a public subnet
3. **VPN Connection**: AWS VPN or Direct Connect to your VPC

## Usage

1. Update the `vpc_id`, `subnet_id`, and `ssh_cidr_blocks` in `main.tf`:
   - Use a **private subnet** ID (no internet gateway route)
   - Set `ssh_cidr_blocks` to your VPC CIDR or bastion host security group

2. Initialize and apply:
```bash
terraform init
terraform apply
```

3. Connect to the instance:

### Option 1: AWS Systems Manager Session Manager (Recommended)

```bash
# View connection instructions
terraform output -raw connection_info

# Connect via SSM
aws ssm start-session --target $(terraform output -raw instance_id)
```

**Note**: For SSM access, add an IAM instance profile with the `AmazonSSMManagedInstanceCore` policy:

```hcl
# Add to your main.tf
resource "aws_iam_role" "ssm_role" {
  name = "debug-instance-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "debug-instance-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# Update the module configuration
module "debug_instance" {
  # ... existing configuration ...
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}
```

### Option 2: SSH via Bastion Host

```bash
# Get the private IP
PRIVATE_IP=$(terraform output -raw instance_private_ip)

# SSH through bastion
ssh -i debug-key.pem -J ec2-user@<bastion-public-ip> ec2-user@$PRIVATE_IP
```

## Security Benefits

- No direct internet exposure
- SSH access only from within the VPC
- Suitable for production environments
- Compliant with most security policies requiring private networking

## Clean Up

```bash
terraform destroy
```
