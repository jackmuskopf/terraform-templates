variable "aws_profile" {
  type        = "string"
  description = "aws profile to use to deploy resources"
}

variable "stage" {
  type        = "string"
  description = "name of stage for parallel deployments; update backend state file s3 key"
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
