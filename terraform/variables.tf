variable "aws_region" {
    type = string
    description = "The AWS region to deploy to"
    default = "us-east-1"
}

variable "vpc_cidr" {
    type = string
    description = "The CIDR block for the VPC"
    default = "10.0.0.0/16"
}

variable "availability_zones" {
    type = list(string)
    description = "The availability zones to deploy to"
    default = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_count" {
    type = number
    description = "The number of public subnets to create"
    default = 2
}

variable "private_subnet_count" {
    type = number
    description = "The number of private subnets to create"
    default = 2
}

variable "project_name" {
    type = string
    description = "The name of the project"
    default = "my-project"
}

variable "author" {
    type = string
    description = "The author of the project"
    default = "John Doe"
}

