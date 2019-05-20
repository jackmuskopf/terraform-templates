# an IAM role necessary for cloudwatch events to run ecs tasks
resource "aws_iam_role" "ecs_events" {
  name = "ecs_events-${var.stage}"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role" {
  name = "ecs_events_run_task_with_any_role"
  role = "${aws_iam_role.ecs_events.id}"

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:RunTask",
                "iam:PassRole"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
DOC
}

resource "aws_ecs_cluster" "main" {
  name = "run-scheduled-fargate-${var.stage}"
}
