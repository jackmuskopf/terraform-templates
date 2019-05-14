provider "aws" {
  region  = "us-east-1"
  version = "2.6.0"
  profile = "${var.aws_profile}"
}

resource "aws_iam_role" "ec2" {
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

// NOTE: the sts statement might include all customers?
resource "aws_iam_policy" "ec2" {
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:*",
                "dynamodb:*",
                "codecommit:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "app_policy_attach" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.ec2.arn}"
}

resource "aws_iam_instance_profile" "ec2" {
  role = "${aws_iam_role.ec2.name}"
}

resource "aws_security_group" "ec2" {
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 22
    to_port   = 22
    protocol  = "6"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.trusted_ips}"
  }

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 5000
    to_port   = 5000
    protocol  = "6"

    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = "${var.trusted_ips}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  count         = 1
  ami           = "ami-0de53d8956e8dcf80"
  instance_type = "t2.micro"

  security_groups      = ["${aws_security_group.ec2.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.ec2.name}"
  key_name             = "${var.ssh_key_name}"

  tags = {
    Name = "Terraform-Instance-${var.stage}"
  }

  user_data = <<SCRIPT
#!/bin/bash

# install git 
yum install git -y

# install docker
yum update -y
yum install docker -y
service docker start
usermod -a -G docker ec2-user

# terraform
wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
unzip terraform*
mv terraform /usr/bin/

# done
SCRIPT
}
