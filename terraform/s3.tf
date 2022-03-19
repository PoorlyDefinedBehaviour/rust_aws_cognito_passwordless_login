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

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.cognito_passwordless_signin_lambda_deploys.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
