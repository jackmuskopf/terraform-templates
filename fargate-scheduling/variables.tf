variable "subnets" {
  type = "list"

  description = <<DESCRIPTION
A list of subnet ids for the Fargate task to use
eg. ["subnet-1234abcd", "subnet-5678efgh"]
DESCRIPTION
}

variable "security_groups" {
  type = "list"

  description = <<DESCRIPTION
A list of security_group ids for the Fargate task to use
eg. ["sg-123456abcdef"]
DESCRIPTION
}

variable "image_uri" {
  type        = "string"
  description = "the full image uri of the image to use"
}

variable "aws_profile" {
  type        = "string"
  description = "the aws cli profile to use for deployment"
}

variable "stage" {
  type        = "string"
  default     = "test"
  description = "a string to differentiate deployments"
}
