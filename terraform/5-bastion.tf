data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "http" "allowed_ip" {
  url = "http://checkip.amazonaws.com/"
}


resource "aws_key_pair" "main" {
  key_name   = "main"
  public_key = file(var.public_key)
}

resource "aws_security_group" "bastion_host" {
  name        = "bastion_sg_${var.project_name}"
  description = "Allow SSH from specified ID"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.allowed_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "bastion_sg_${var.project_name}"
    Author = var.author
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.bastion.id
  instance_type               = var.bastion_instance_type
  key_name                    = aws_key_pair.main.id
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]
  subnet_id                   = element(aws_subnet.public_subnets, 0).id
  associate_public_ip_address = true

  tags = {
    Name   = "bastion_${var.project_name}"
    Author = var.author
  }
}