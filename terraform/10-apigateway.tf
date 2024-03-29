resource "aws_api_gateway_rest_api" "api" {
  name        = "GitHubWebHookAPI"
  description = "GitHub Webhook forwarder"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name   = "GitHubWebHookAPI-${var.project_name}"
    Author = var.author
  }
}

resource "aws_api_gateway_resource" "path" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.path.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "request_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.request_method.resource_id
  http_method = aws_api_gateway_method.request_method.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.lambda.invoke_arn

  # AWS lambdas can only be invoked with the POST method
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  function_name = aws_lambda_function.lambda.arn
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_method_response" "response_method" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.request_method.resource_id
  http_method = aws_api_gateway_integration.request_integration.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "response_method_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.request_method.resource_id
  http_method = aws_api_gateway_method_response.response_method.http_method
  status_code = aws_api_gateway_method_response.response_method.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "stage" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "v1"

  depends_on = [
    aws_api_gateway_integration.request_integration,
    aws_api_gateway_integration_response.response_method_integration,
    aws_api_gateway_method_response.response_method,
    aws_acm_certificate.main
  ]
}

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "api.${var.root_domain_name}"
  regional_certificate_arn = aws_acm_certificate.main.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  depends_on = [ aws_acm_certificate.main ]
}

resource "aws_api_gateway_base_path_mapping" "api" {
  domain_name = aws_api_gateway_domain_name.api.domain_name
  stage_name  = aws_api_gateway_deployment.stage.stage_name
  api_id      = aws_api_gateway_rest_api.api.id
}