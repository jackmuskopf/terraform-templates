make zip
terraform init
terraform apply

also, you might add a file `backend.tf` with contents something like:

```
terraform {
  backend "s3" {
    profile        = "my_aws_profile"
    bucket         = "my-terraform-state-bucket"
    key            = "api-gateway-lambda.tfstate"
    region         = "us-east-1"
  }
}
```
