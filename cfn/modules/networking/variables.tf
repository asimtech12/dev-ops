variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
}

variable "environment" {
  description = "The environment"
}

variable "region" {
  description = "The region to launch the bastion host"
}

variable "availability_zone" {
  description = "The az that the resources will be launched"
}

variable "bastion_ami" {
  type = "map"
  default = {
    "us-east-1" = "ami-1853ac65"
    "us-east-2" = "ami-25615740"
    "us-west-1" = "ami-bf5540df"
  }
}

variable "key_name" {
  description = "The public key for the bastion host"
}