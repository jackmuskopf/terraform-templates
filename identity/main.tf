data "aws_caller_identity" "current" {}

variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "aws_session_token" {}
variable "aws_region" { default = "us-east-1" }

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}


output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}
