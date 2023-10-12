variable "aws_region" {
  description = "AWS Region"
  type        = string
  validation {
    condition     = length(var.aws_region) > 0
    error_message = "Please provide a valid AWS region"
  }
}

variable "aws_resource_prefix" {
  description = "Prefix for all resources"
  type        = string
  validation {
    condition     = length(var.aws_resource_prefix) > 0
    error_message = "Please provide a valid resource prefix"
  }
  default = "gh-act"
}

variable "aws_vpc_cidr" {
  default = { cidr = "10.68.0.0/16", newbits = 8, azs_count = 3 }
  type = object({
    cidr      = string
    newbits   = number
    azs_count = number
  })
  description = "The cidr for the VPC that the runners run in, must have at enough blocks available with a subnet in each Availability Zone, for example 10.68.0.0/16, with a newbits of 8 and a azs_count of 3 will result in 6 subnets being provisioned in the ranges of 10.68.1.0/24, 10.68.2.0/24, and 10.68.3.0/24 in the private subnet and 10.68.4.0/24, 10.68.5.0/24, and 10.68.6.0/24 in the public subnet, with one private and one public per availability zone. Note the \"/24\" here, 16+8 == 24, you may also choose different ranges with less tidy ip blocks"
  validation {
    condition     = can(cidrsubnet(var.aws_vpc_cidr.cidr, var.aws_vpc_cidr.newbits, var.aws_vpc_cidr.azs_count))
    error_message = "Please provide a valid cidr block"
  }
}

variable "github_app_key" {
  type        = string
  description = "The private key of the GitHub App. PEM formatted."
  validation {
    condition     = substr(var.github_app_key, 0, length("-----BEGIN RSA PRIVATE KEY-----")) == "-----BEGIN RSA PRIVATE KEY-----"
    error_message = "github_app_key must be a PEM formatted private key"
  }
}

variable "github_app_id" {
  type = string
  validation {
    condition     = length(var.github_app_id) > 0
    error_message = "github_app_id must be set"
  }

  description = "This is ID from App in developer settings"
}

variable "github_app_install_id" {
  type = string
  validation {
    condition     = length(var.github_app_install_id) > 0
    error_message = "github_app_install_id must be set"
  }

  description = "You can find this in the URL when viewing the installed app in the GitHub UI"
}

variable "github_organisation" {
  type = string
  validation {
    condition     = length(var.github_organisation) > 0
    error_message = "github_organisation must be set"
  }
  description = "The github organisation to use"
}

variable "ami_name_filter" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  validation {
    condition     = length(var.ami_name_filter) > 0
    error_message = "ami_name_filter must be set"
  }
  description = "The name filter to use when searching for the AMI to use for the runner"
}
variable "ami_owner_filter" {
  type    = string
  default = "099720109477"
  validation {
    condition     = length(var.ami_owner_filter) > 0
    error_message = "ami_owner_filter must be set"
  }
  description = "The owner filter to use when searching for the AMI to use for the runner. The default is canonicals account"
}

variable "runner_run_as" {
  type    = string
  default = "ubuntu"
  validation {
    condition     = length(var.runner_run_as) > 0
    error_message = "input_runner_run_as must be set"
  }
  description = "The user to run things as on the host, defaults to ubuntu, as this is the username on the ubuntu AMI, however if you might want to change it to whatever you use, perhaps ec2-user"
}

variable "additional_install_script" {
  type        = string
  default     = ""
  description = "A script that will be executed before setup of the runner, this can be used to install additional software, or configure the runner in some way"
}

variable "enable" {
  type        = bool
  default     = true
  description = "Disable or enable everything in this module"
}
