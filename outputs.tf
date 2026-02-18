output "instance_id" {
  description = "ID of the debug EC2 instance"
  value       = aws_instance.debug_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the debug instance"
  value       = aws_instance.debug_instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the debug instance"
  value       = aws_instance.debug_instance.private_ip
}

output "security_group_id" {
  description = "ID of the security group attached to the instance"
  value       = aws_security_group.debug_sg.id
}

output "private_key_file" {
  description = "Path to the private key file"
  value       = var.create_instance_profile ? null : local_file.private_key[0].filename
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = var.create_instance_profile ? null : "ssh -i ${local_file.private_key[0].filename} ec2-user@${aws_instance.debug_instance.public_ip}"
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile attached to the instance (null if create_instance_profile is false)"
  value       = var.create_instance_profile ? aws_iam_instance_profile.ssm_profile[0].name : null
}
