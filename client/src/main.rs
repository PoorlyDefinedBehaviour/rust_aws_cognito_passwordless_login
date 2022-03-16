use rusoto_cognito_idp::{
  AttributeType, CognitoIdentityProvider, CognitoIdentityProviderClient, SignUpRequest,
};
use uuid::Uuid;

fn main() {
  let client = CognitoIdentityProviderClient::new(rusoto_core::Region::SaEast1);

  client.sign_up(SignUpRequest {
    username: String::from("brunotj2015@hotmail.com"),
    password: Uuid::new_v4().to_string(),
    user_attributes: Some(vec![AttributeType {
      name: String::from("email"),
      value: Some(String::from("brunotj2015@hotmail.com")),
    }]),
    ..Default::default()
  });
}
