variable "cognito_define_auth_challenge_function_name" {
  default = "cognito_define_auth_challenge"
}

resource "aws_cloudwatch_log_group" "cognito_define_auth_challenge_log_group" {
  name = "/aws/lambda/${var.cognito_define_auth_challenge_function_name}"
}

resource "aws_iam_role" "cognito_define_auth_challenge_role" {
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
      "Resource": "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.cognito_define_auth_challenge_log_group.name}:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "${aws_s3_bucket.cognito_passwordless_signin_lambda_deploys.arn}/cognito_define_auth_challenge_lambda",
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

resource "aws_lambda_function" "cognito_define_auth_challenge" {
  function_name     = var.cognito_define_auth_challenge_function_name
  role              = aws_iam_role.cognito_define_auth_challenge_role.arn
  s3_bucket         = "lambda_deploys"
  s3_key            = "cognito_define_auth_challenge_lambda"
  s3_object_version = "latest"
  handler           = "bootstrap"
  runtime           = "provided.al2"
}
