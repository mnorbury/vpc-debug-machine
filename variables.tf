variable "vpc_id" {
  description = "The VPC ID where the debug instance will be created"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the debug instance will be launched"
  type        = string
}
