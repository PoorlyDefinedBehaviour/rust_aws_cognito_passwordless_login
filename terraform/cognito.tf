resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "cognito-passwordless-user-pool"
  lambda_config {
    pre_sign_up = aws_lambda_function.cognito_pre_signup.arn
  }
}
