variable "aws_profile" {
  type        = "string"
  description = "aws profile to use to deploy resources"
}

variable "stage" {
  type        = "string"
  description = "name of stage for parallel deployments; update backend state file s3 key"
}
