variable "cognito_create_auth_challenge_function_name" {
  default = "cognito_create_auth_challenge"
}

resource "aws_cloudwatch_log_group" "cognito_create_auth_challenge_log_group" {
  name = "/aws/lambda/${var.cognito_create_auth_challenge_function_name}"
}

resource "aws_iam_role" "cognito_create_auth_challenge_role" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
      ],
      "Resource": "arn:aws:logs:${var.region}:${var.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ],
      "Resource": "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cognito_create_auth_challenge_log_group.name}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "${aws_s3_bucket.cognito_passwordless_signin_lambda_deploys.arn}/cognito_create_auth_challenge_lambda"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail"
      ],
      "Resource": ${aws_ses_email_identity.ses_email_identity.arn}
    }
  ]
}
EOF
}

resource "aws_lambda_function" "cognito_create_auth_challenge" {
  function_name     = var.cognito_create_auth_challenge_function_name
  role              = aws_iam_role.cognito_create_auth_challenge_role.arn
  s3_bucket         = "lambda_deploys"
  s3_key            = "cognito_create_auth_challenge_lambda"
  s3_object_version = "latest"
  handler           = "bootstrap"
  runtime           = "provided.al2"
}
