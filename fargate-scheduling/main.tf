provider "aws" {
  region  = "us-east-1"
  version = "2.6.0"
  profile = "${var.aws_profile}"
}

module "example1" {
  source = "./ecs-micro"

  command = ["python", "hello_world.py"]

  cluster = {
    id  = "${aws_ecs_cluster.main.id}"
    arn = "${aws_ecs_cluster.main.arn}"
  }

  schedule_expression = "rate(2 minutes)"
  task_name           = "MyHelloWorldTask"
  image_uri           = "${var.image_uri}"
  cwe_target_role_arn = "${aws_iam_role.ecs_events.arn}"

  subnets = "${var.subnets}"

  security_groups = "${var.security_groups}"
}

module "example2" {
  source = "./ecs-micro"

  command = ["echo", "hi"]

  cluster = {
    id  = "${aws_ecs_cluster.main.id}"
    arn = "${aws_ecs_cluster.main.arn}"
  }

  schedule_expression = "rate(2 minutes)"
  task_name           = "MyEchoHiTask"
  image_uri           = "${var.image_uri}"
  cwe_target_role_arn = "${aws_iam_role.ecs_events.arn}"

  subnets = "${var.subnets}"

  security_groups = "${var.security_groups}"
}
