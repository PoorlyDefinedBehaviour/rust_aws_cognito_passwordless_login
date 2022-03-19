resource "aws_s3_bucket" "cognito_passwordless_signin_lambda_deploys" {
  bucket = "cognito-passwordless-signin-lambda-deploys"

  tags = {
    Name = "cognito-passwordless-signin-lambda-deploys"
  }
}

resource "aws_s3_bucket_versioning" "cognito_passwordless_signin_lambda_deploys_versioning" {
  bucket = aws_s3_bucket.cognito_passwordless_signin_lambda_deploys.id
  versioning_configuration {
    status = "Enabled"
  }
}
