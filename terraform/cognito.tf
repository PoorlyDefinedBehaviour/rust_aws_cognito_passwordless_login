resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "cognito-passwordless-user-pool"
  lambda_config {
    pre_sign_up                    = "arn:aws:lambda:${var.region}:${var.account_id}:${var.cognito_pre_signup_function_name}"
    define_auth_challenge          = "arn:aws:lambda:${var.region}:${var.account_id}:${var.cognito_define_auth_challenge_function_name}"
    create_auth_challenge          = "arn:aws:lambda:${var.region}:${var.account_id}:${var.cognito_create_auth_challenge_function_name}"
    verify_auth_challenge_response = "arn:aws:lambda:${var.region}:${var.account_id}:${var.cognito_verify_auth_challenge_function_name}"
  }
}
