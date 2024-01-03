packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variables {
  region        = "us-east-1"
  aws_profile   = "default"
  instance_type = "t2.micro"
  ssh_key = "/home/pj/pjkp.pem"
}

locals {
  timestamp = formatdate("YYYY-MM-DD-hhmmss", timestamp())
}

source "amazon-ebs" "jenkins-worker" {
  profile         = "${var.aws_profile}"
  region          = "${var.region}"
  instance_type   = "${var.instance_type}"
  ssh_username    = "ec2-user"
  ami_name        = "jenkins-worker-2.426.2-${local.timestamp}"
  ami_description = "Amazon Linux 2 Image with Worker Jenkins Node v2.426.2"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "amzn2-ami-kernel-*"
      root-device-type    = "ebs"
    }
    owners      = ["137112412989"]
    most_recent = true
  }
  run_tags = {
    Name = "packer-builder"
  }
}

build {
  name = "jenkins-worker"
  sources = [
    "source.amazon-ebs.jenkins-worker"
  ]

  provisioner "shell" {
    script          = "./setup.sh"
    execute_command = "sudo -E -S sh '{{.Path}}'"
  }
}