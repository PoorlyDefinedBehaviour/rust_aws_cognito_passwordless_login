variable "cognito_pre_signup_function_name" {
  default = "cognito_pre_signup"
}

resource "aws_cloudwatch_log_group" "cognito_pre_signup_log_group" {
  name = "/aws/lambda/${var.cognito_pre_signup_function_name}"
}

resource "aws_iam_role" "cognito_pre_signup_role" {
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
      "Resource": "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cognito_pre_signup_log_group.name}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "${aws_s3_bucket.cognito_passwordless_signin_lambda_deploys.arn}/${var.cognito_verify_auth_challenge_function_name}",
      "Condition": {
        "StringEquals": {
          "s3:ResourceAccount": ${var.account_id}
        }
      }
    },
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

resource "aws_lambda_function" "cognito_pre_signup" {
  function_name     = var.cognito_pre_signup_function_name
  role              = aws_iam_role.cognito_pre_signup_role.arn
  s3_bucket         = var.cognito_passwordless_signin_lambda_deploys_bucket_name
  s3_key            = var.cognito_pre_signup_function_name
  s3_object_version = "latest"
  handler           = "bootstrap"
  runtime           = "provided.al2"
}
