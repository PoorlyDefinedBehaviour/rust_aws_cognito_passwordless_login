variable "cognito_create_auth_challenge_function_name" {
  default = "cognito_create_auth_challenge"
}

resource "aws_cloudwatch_log_group" "cognito_create_auth_challenge_log_group" {
  name = "/aws/lambda/${var.cognito_create_auth_challenge_function_name}"
}

resource "aws_iam_role" "cognito_create_auth_challenge_role" {
  name = "cognito_create_auth_challenge_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "cognito-idp.amazonaws.com"
      },
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_verify_auth_challenge_function_name}",
      "Condition": {
        "ArnLike": {
          "AWS:SourceArn": ${aws_cognito_user_pool.cognito_user_pool.arn}
        }
      }
    }
  ]
}
EOF
}

resource "aws_lambda_function" "cognito_create_auth_challenge" {
  function_name     = var.cognito_create_auth_challenge_function_name
  role              = aws_iam_role.cognito_create_auth_challenge_role.arn
  s3_bucket         = var.cognito_passwordless_signin_lambda_deploys_bucket_name
  s3_key            = var.cognito_create_auth_challenge_function_name
  s3_object_version = "latest"
  handler           = "bootstrap"
  runtime           = "provided.al2"
}
