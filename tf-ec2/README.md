 - `terraform init`
 - `terraform apply`

also, if you want a remote state, you might add a file `backend.tf` with contents something like:

```
terraform {
  backend "s3" {
    profile        = "my_aws_profile"
    bucket         = "my-terraform-state-bucket"
    key            = "my-ec2.tfstate"
    region         = "us-east-1"
  }
}
```
