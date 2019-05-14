provider "aws" {
  region  = "us-east-1"
  version = "2.6.0"
  profile = "${var.aws_profile}"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  region     = "${data.aws_region.current.name}"
  account_id = "${data.aws_caller_identity.current.account_id}"
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "ApiGatewayLambda-${var.stage}"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  # date in uri is api version of lambda?
  uri = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}/${aws_api_gateway_resource.resource.path}"
}

resource "aws_lambda_function" "lambda" {
  filename      = "zips/lambda.zip"
  function_name = "ApiGatewayLambda-${var.stage}"
  role          = "${aws_iam_role.role.arn}"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.7"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda.zip"))}"
  source_code_hash = "${filebase64sha256("zips/lambda.zip")}"
}

# IAM
resource "aws_iam_role" "role" {
  name = "ApiGatewayLambda-${var.stage}"

  assume_role_policy = <<POLICY
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
POLICY
}
