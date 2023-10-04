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
}

variable "github_app_install_id" {
  type = string
  validation {
    condition     = length(var.github_app_install_id) > 0
    error_message = "github_app_install_id must be set"
  }
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
  description = "The owner filter to use when searching for the AMI to use for the runner"
}

variable "userdata_template" {
  type    = string
  default = "./templates/user-data.sh"
  validation {
    condition     = can(file(var.userdata_template))
    error_message = "userdata_template must be set to a valid file, see ./templates/user-data.sh for an example of what this should look like"
  }
  description = "The script that runs on worker startup, can be used to install additional software"
}
