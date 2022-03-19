variable "cognito_passwordless_signin_lambda_deploys_bucket_name" {
  default = "cognito-passwordless-signin-lambda-deploys"
}

resource "aws_s3_bucket" "cognito_passwordless_signin_lambda_deploys" {
  bucket = var.cognito_passwordless_signin_lambda_deploys_bucket_name
  acl    = "private"
  tags = {
    Name = var.cognito_passwordless_signin_lambda_deploys_bucket_name
  }
}

resource "aws_s3_bucket_versioning" "cognito_passwordless_signin_lambda_deploys_versioning" {
  bucket = aws_s3_bucket.cognito_passwordless_signin_lambda_deploys.id
  versioning_configuration {
    status = "Enabled"
  }
}
