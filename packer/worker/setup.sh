#!/bin/bash

echo "Installing Amazon Linux extras"
amazon-linux-extras install epel -y

echo "Installing Java JDK 11"
yum update
amazon-linux-extras install java-openjdk11 -y

echo "Installing Docker Engine"
amazon-linux-extras install docker -y
usermod -aG docker ec2-user
systemctl enable docker

echo "Install git"
yum install -y git
