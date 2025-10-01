variable "vpc_id" {
  description = "The VPC ID where the debug instance will be created"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the debug instance will be launched"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "vpc-debug-instance"
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
}

variable "ami_id" {
  description = "AMI ID to use for the instance. If not specified, latest Amazon Linux 2023 will be used"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script to run on instance startup"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for the EC2 instance"
  type        = bool
  default     = false
}

variable "key_name_prefix" {
  description = "Prefix for the SSH key pair name"
  type        = string
  default     = "vpc-debug"
}
