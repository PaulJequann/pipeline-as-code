data "aws_ami" "jenkins-workers" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["jenkins-worker-*"]
  }
}

data "template_file" "user_data_jenkins_worker" {
  template = file("scripts/join-cluster.tpl")

  vars = {
    jenkins_url            = "http://${aws_instance.jenkins_master.private_ip}:8080"
    jenkins_username       = var.jenkins_username
    jenkins_password       = var.jenkins_password
    jenkins_credentials_id = var.jenkins_credentials_id
  }
}

resource "aws_launch_configuration" "jenkins_workers_launch_conf" {
  name_prefix     = "jenkins-workers-config"
  image_id        = data.aws_ami.jenkins-workers.id
  instance_type   = var.jenkins_worker_instance_type
  security_groups = [aws_security_group.jenkins_workers_sg.id]
  key_name        = aws_key_pair.main.id
  user_data       = data.template_file.user_data_jenkins_worker.rendered

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = false
  }
}

resource "aws_security_group" "jenkins_workers_sg" {
  name        = "jenkins_workers_sg"
  description = "Allow traffic on port 22 from Jenkins master SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_master_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "jenkins_workers_sg_${var.project_name}"
    Author = var.author
  }
}

resource "aws_autoscaling_group" "jenkins_workers" {
  name                 = "jenkins-workers"
  launch_configuration = aws_launch_configuration.jenkins_workers_launch_conf.name
  vpc_zone_identifier  = [for subnet in aws_subnet.private_subnets : subnet.id]
  min_size             = 2
  max_size             = 10

  depends_on = [aws_instance.jenkins_master, aws_elb.jenkins_elb]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "jenkins-workers"
    propagate_at_launch = true
  }

  tag {
    key                 = "Author"
    value               = var.author
    propagate_at_launch = true
  }
}
