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
}

variable JENKINS_USERNAME {
  type = string
  sensitive = true
}

variable JENKINS_PASSWORD {
  type = string
  sensitive = true
}

variable SSH_KEY {
  type = string
  sensitive = true
}

locals {
  timestamp = formatdate("YYYY-MM-DD-hhmmss", timestamp())
}

source "amazon-ebs" "jenkins-master" {
  profile         = "${var.aws_profile}"
  region          = "${var.region}"
  instance_type   = "${var.instance_type}"
  ssh_username    = "ec2-user"
  ami_name        = "jenkins-master-2.426.2-${local.timestamp}"
  ami_description = "Amazon Linux 2 Image with Master Jenkins Server v2.426.2"
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
  name = "jenkins-master"
  sources = [
    "source.amazon-ebs.jenkins-master"
  ]

  provisioner "file" {
    source = "./scripts"
    destination = "/tmp/"
  }

  provisioner "file" {
    source = "./config"
    destination = "/tmp/"
  }

  provisioner "file" {
    source = "${var.SSH_KEY}"
    destination = "/tmp/id_ed25519"
  }

  provisioner "shell" {
    inline = [
              "echo -e '\ndef hudsonRealm = new HudsonPrivateSecurityRealm(false)' >> /tmp/scripts/basic-security.groovy",
              "echo 'hudsonRealm.createAccount(\"${var.JENKINS_USERNAME}\", \"${var.JENKINS_PASSWORD}\")' >> /tmp/scripts/basic-security.groovy",
              "echo 'jenkins.setSecurityRealm(hudsonRealm)' >> /tmp/scripts/basic-security.groovy",
              "echo 'def strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()' >> /tmp/scripts/basic-security.groovy",
              "echo 'instance.setAuthorizationStrategy(strategy)' >> /tmp/scripts/basic-security.groovy",
              "echo 'instance.save()' >> /tmp/scripts/basic-security.groovy"
    ]
  }

  provisioner "shell" {
    script          = "./setup.sh"
    execute_command = "sudo -E -S sh '{{.Path}}'"
  }
}