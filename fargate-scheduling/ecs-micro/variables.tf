data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = "${data.aws_caller_identity.current.account_id}"
  region     = "${data.aws_region.current.name}"
  lg_name    = "${var.task_name}-ecs-task"
}

variable "command" {
  type = "list"

  description = <<DESCRIPTION
the command for the task; eg: ["python", "hello_world.py"]
DESCRIPTION
}

variable "cluster" {
  type        = "map"
  description = "map for cluster id and arn"
}

variable "schedule_expression" {
  type        = "string"
  description = "a valid cloudwatch events schedule expression to trigger the task"
}

variable "task_name" {
  type        = "string"
  description = "an identifier for the task"
}

variable "image_uri" {
  type        = "string"
  description = "the URI of the docker image to run"
}

variable "cwe_target_role_arn" {
  type        = "string"
  description = "role for CWE target"
}

variable "subnets" {
  type        = "list"
  description = "subnets for task"
}

variable "security_groups" {
  default = [
    "sg-03bc0418bda3523a7",
  ]
}
