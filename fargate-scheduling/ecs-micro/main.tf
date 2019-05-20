resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${local.lg_name}"
  retention_in_days = "30"
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "${var.task_name}-ECS-Trigger"
  description         = "event to trigger task ${var.task_name}"
  schedule_expression = "${var.schedule_expression}"
}

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  target_id = "run-scheduled-task-every-hour"
  arn       = "${var.cluster["arn"]}"
  rule      = "${aws_cloudwatch_event_rule.event_rule.name}"
  role_arn  = "${var.cwe_target_role_arn}"

  ecs_target = {
    task_count          = 1
    task_definition_arn = "${aws_ecs_task_definition.main.arn}"
    launch_type         = "FARGATE"
    platform_version    = "LATEST"

    network_configuration {
      subnets          = "${var.subnets}"
      security_groups  = "${var.security_groups}"
      assign_public_ip = true
    }
  }

  # need this here
  input = <<DOC
{}
DOC
}

resource "aws_iam_role" "service" {
  name = "${var.task_name}-service"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "service" {
  role = "${aws_iam_role.service.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "dynamodb:*",
        "sqs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "execution" {
  name = "${var.task_name}-task"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "execution" {
  role = "${aws_iam_role.execution.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.task_name}"
  task_role_arn            = "${aws_iam_role.service.arn}"
  execution_role_arn       = "${aws_iam_role.execution.arn}"
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions    = "${local.container_definition}"
}
