# data "http" "bastion_ip" {
#   url = "http://checkip.amazonaws.com/"
# }

# variable "allowed_ip" {
#   type        = string
#   description = "The IP address to allow access from"
#   default     = "${chomp(data.http.bastion_ip.response_body)}/32"
# }
variable "aws_region" {
  type        = string
  description = "The AWS region to deploy to"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones to deploy to"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_count" {
  type        = number
  description = "The number of public subnets to create"
  default     = 2
}

variable "private_subnet_count" {
  type        = number
  description = "The number of private subnets to create"
  default     = 2
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "my-project"
}

variable "author" {
  type        = string
  description = "The author of the project"
  default     = "John Doe"
}

variable "bastion_instance_type" {
  type        = string
  description = "The instance type for the bastion host"
  default     = "t2.micro"
}

variable "jenkins_master_instance_type" {
  type        = string
  description = "The instance type for the Jenkins master"
  default     = "t2.large"
}

# variable "ssl_arn" {
#   type        = string
#   description = "The ARN of the SSL certificate to use for the ELB"
# }

variable "public_key" {
  type        = string
  description = "The path to the public key to use for the bastion host"
}

variable "root_domain_name" {
  type        = string
  description = "The root domain name for the project"
}