mock_provider "aws" {}

run "validate_resources_created" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "subnet-12345678"
  }

  assert {
    condition     = aws_instance.debug_instance.instance_type == "t3.micro"
    error_message = "Default instance type should be t3.micro"
  }

  assert {
    condition     = aws_instance.debug_instance.associate_public_ip_address == true
    error_message = "Default should associate public IP"
  }

  assert {
    condition     = aws_security_group.debug_sg.vpc_id == "vpc-12345678"
    error_message = "Security group should be in the correct VPC"
  }

  assert {
    condition     = length(aws_security_group.debug_sg.ingress) == 1
    error_message = "Security group should have one ingress rule"
  }

  assert {
    condition     = one([for rule in aws_security_group.debug_sg.ingress : rule.from_port == 22])
    error_message = "Security group should allow SSH on port 22"
  }
}

run "validate_custom_instance_type" {
  command = plan

  variables {
    vpc_id        = "vpc-12345678"
    subnet_id     = "subnet-12345678"
    instance_type = "t3.small"
  }

  assert {
    condition     = aws_instance.debug_instance.instance_type == "t3.small"
    error_message = "Instance type should be customizable"
  }
}

run "validate_public_ip_disabled" {
  command = plan

  variables {
    vpc_id              = "vpc-12345678"
    subnet_id           = "subnet-12345678"
    associate_public_ip = false
  }

  assert {
    condition     = aws_instance.debug_instance.associate_public_ip_address == false
    error_message = "Should be able to disable public IP association"
  }
}

run "validate_ssh_cidr_blocks" {
  command = plan

  variables {
    vpc_id          = "vpc-12345678"
    subnet_id       = "subnet-12345678"
    ssh_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]
  }

  assert {
    condition     = length(aws_security_group.debug_sg.ingress) == 1
    error_message = "Security group should have exactly one ingress rule"
  }

  assert {
    condition = (
      length(aws_security_group.debug_sg.ingress) > 0 &&
      contains(one([for rule in aws_security_group.debug_sg.ingress : rule]).cidr_blocks, "10.0.0.0/8") &&
      contains(one([for rule in aws_security_group.debug_sg.ingress : rule]).cidr_blocks, "172.16.0.0/12")
    )
    error_message = "SSH ingress rule should include custom CIDR blocks: 10.0.0.0/8 and 172.16.0.0/12"
  }
}

run "validate_tags" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "subnet-12345678"
    tags = {
      Environment = "test"
      Project     = "debug"
    }
  }

  assert {
    condition     = aws_instance.debug_instance.tags["Environment"] == "test"
    error_message = "Tags should be applied to instance"
  }

  assert {
    condition     = aws_security_group.debug_sg.tags["Environment"] == "test"
    error_message = "Tags should be applied to security group"
  }
}

run "validate_root_volume" {
  command = plan

  variables {
    vpc_id           = "vpc-12345678"
    subnet_id        = "subnet-12345678"
    root_volume_size = 50
    root_volume_type = "gp3"
  }

  assert {
    condition     = aws_instance.debug_instance.root_block_device[0].volume_size == 50
    error_message = "Root volume size should be customizable"
  }

  assert {
    condition     = aws_instance.debug_instance.root_block_device[0].volume_type == "gp3"
    error_message = "Root volume type should be customizable"
  }
}

run "validate_monitoring" {
  command = plan

  variables {
    vpc_id                     = "vpc-12345678"
    subnet_id                  = "subnet-12345678"
    enable_detailed_monitoring = true
  }

  assert {
    condition     = aws_instance.debug_instance.monitoring == true
    error_message = "Detailed monitoring should be configurable"
  }
}

run "validate_key_pair_name" {
  command = plan

  variables {
    vpc_id          = "vpc-12345678"
    subnet_id       = "subnet-12345678"
    key_name_prefix = "custom-prefix"
  }

  assert {
    condition     = aws_key_pair.debug_key.key_name == "custom-prefix-vpc-12345678-subnet-12345678"
    error_message = "Key pair name should include prefix, VPC ID, and subnet ID"
  }
}
