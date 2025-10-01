# Advanced Example

This example demonstrates advanced usage of the vpc-debug-machine module with custom configuration, security restrictions, and automated tool installation.

## Features

- Larger instance type (t3.small) for more demanding debugging tasks
- Increased root volume size (20 GB)
- Restricted SSH access to specific CIDR blocks
- User data script that installs debugging and monitoring tools
- CloudWatch detailed monitoring enabled
- Custom resource tags

## Usage

1. Update the `vpc_id`, `subnet_id`, and `ssh_cidr_blocks` in `main.tf` with your values.

2. Initialize and apply:
```bash
terraform init
terraform apply
```

3. Connect to the instance:
```bash
terraform output -raw ssh_command | bash
```

## Installed Tools

The user data script automatically installs:
- **htop**: Interactive process viewer
- **tmux**: Terminal multiplexer
- **tcpdump**: Network packet analyzer
- **iperf3**: Network performance testing
- **vim**: Text editor with syntax highlighting
- **bind-utils**: DNS debugging tools (dig, nslookup)
- **net-tools**: Network utilities (netstat, ifconfig)
- **telnet, nc, traceroute**: Network connectivity tools

## Security Considerations

This example restricts SSH access to a specific CIDR block. Make sure to:
1. Replace `203.0.113.0/24` with your actual IP range
2. Use the smallest CIDR block that meets your needs
3. Consider using AWS Systems Manager Session Manager as an alternative to SSH

## Clean Up

```bash
terraform destroy
```
