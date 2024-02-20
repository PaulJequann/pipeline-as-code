resource "aws_iam_role" "role" {
  name = "GitHubWebhookForwarderRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "github_webhook_lambda" {
  type        = "zip"
  source_dir  = "./lambda"
  output_path = "lambda.zip"
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_security_group" "github_lambda_sg" {
  name        = "github_lambda_sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow traffic to port 8080 on Jenkins master"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.github_webhook_lambda.output_path
  function_name    = "GitHubWebhookForwarder"
  role             = aws_iam_role.role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  timeout          = 30
  source_code_hash = data.archive_file.github_webhook_lambda.output_base64sha256

  environment {
    variables = {
      JENKINS_URL = "https://${aws_instance.jenkins_master.private_ip}:8080/github-webhook/"
    }
  }

  vpc_config {
    subnet_ids         = [for subnet in aws_subnet.private_subnets : subnet.id]
    security_group_ids = [aws_security_group.elb_jenkins_sg.id]
  }
}