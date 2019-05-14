variable "ssh_key_name" {
  type        = "string"
  description = "the name of the EXISTING ssh key to use for the EC2 instance"
}

variable "stage" {
  type        = "string"
  description = "a stage name to mark the deployment resources"
}

variable "aws_profile" {
  type        = "string"
  description = "aws profile to use to deploy resources"
}

variable "trusted_ips" {
  type    = "list"
  default = []

  description = <<DESC
a list of public ips that you ec2 will trust; 
configure whichever ports you want in the security group; 
example: ["1.2.3.4/32","5.6.7.8/32"]
DESC
}
