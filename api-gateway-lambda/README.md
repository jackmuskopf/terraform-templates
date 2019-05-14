deploys an api gateway attached to a lambda function

 - `make zip`
 - `terraform init`
 - `terraform apply`
 
 once it's successfully deployed, if you've included your public IP in `trusted_ips`, try `curl <api-gateway-deployment-invoke-url>`

also, if you want a remote state, you might add a file `backend.tf` with contents something like:

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
