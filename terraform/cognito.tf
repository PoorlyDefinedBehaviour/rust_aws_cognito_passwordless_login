resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = "cognito-passwordless-user-pool"
  username_configuration {
    case_sensitive = false
  }

  username_attributes = ["email", "phone_number"]

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = true
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }


  schema {
    name                     = "phone_number"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    required                 = false
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  lambda_config {
    pre_sign_up                    = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_pre_signup_function_name}"
    define_auth_challenge          = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_define_auth_challenge_function_name}"
    create_auth_challenge          = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_create_auth_challenge_function_name}"
    verify_auth_challenge_response = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_verify_auth_challenge_function_name}"
  }
}

resource "aws_cognito_user_pool_client" "passwordless_cognito_user_pool_client" {
  name                                 = "passwordless-client"
  user_pool_id                         = aws_cognito_user_pool.cognito_user_pool.id
  allowed_oauth_flows_user_pool_client = false
  enable_token_revocation              = true
  explicit_auth_flows                  = ["CUSTOM_AUTH_FLOW_ONLY"]
  generate_secret                      = false
  prevent_user_existence_errors        = "ENABLED"
  read_attributes                      = ["email"]
}
