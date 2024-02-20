terraform {
  cloud {
    organization = "pauljequann"

    workspaces {
      name = "pipeline-as-code"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.4.2"
}

provider "aws" {
  region = var.aws_region
}