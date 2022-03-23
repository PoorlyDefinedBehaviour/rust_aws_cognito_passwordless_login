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


resource "aws_cognito_user_pool" "tfer--TestPool123" {
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = "1"
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = "2"
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = "false"
  }

  auto_verified_attributes = ["email"]

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  lambda_config {
    pre_sign_up                    = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_pre_signup_function_name}"
    define_auth_challenge          = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_define_auth_challenge_function_name}"
    create_auth_challenge          = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_create_auth_challenge_function_name}"
    verify_auth_challenge_response = "arn:aws:lambda:${var.region}:${var.account_id}:function:${var.cognito_verify_auth_challenge_function_name}"
  }

  mfa_configuration = "OFF"
  name              = "terraform-cognito-user-pool"

  password_policy {
    minimum_length                   = "8"
    require_lowercase                = "true"
    require_numbers                  = "true"
    require_symbols                  = "true"
    require_uppercase                = "true"
    temporary_password_validity_days = "7"
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = "false"
    mutable                  = "true"
    name                     = "email"
    required                 = "true"

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  username_configuration {
    case_sensitive = "false"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}


resource "aws_cognito_user_pool_client" "passwordless_cognito_user_pool_client" {
  access_token_validity                = "60"
  allowed_oauth_flows_user_pool_client = false
  enable_token_revocation              = true
  explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  id_token_validity                    = "60"
  name                                 = "passwordless-app-client"
  prevent_user_existence_errors        = "ENABLED"
  read_attributes                      = ["address", "birthdate", "email", "email_verified", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "phone_number_verified", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]
  refresh_token_validity               = "30"
  supported_identity_providers         = ["COGNITO"]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  user_pool_id     = aws_cognito_user_pool.cognito_user_pool.id
  write_attributes = ["address", "birthdate", "email", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]
}
