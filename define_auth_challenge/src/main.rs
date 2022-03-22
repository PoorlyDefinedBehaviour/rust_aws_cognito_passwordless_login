use aws_lambda_events::event::cognito::CognitoEventUserPoolsDefineAuthChallenge;
use lambda_runtime::{service_fn, Error, LambdaEvent};
use tracing::{info, instrument};

#[tokio::main]
async fn main() -> Result<(), Error> {
  let _guard = log::setup();
  lambda_runtime::run(service_fn(handler)).await?;
  Ok(())
}

/// We only accept our own custom challenge.
fn is_custom_challenge(event: &CognitoEventUserPoolsDefineAuthChallenge) -> bool {
  event.request.session.iter().all(|attempt| match attempt {
    None => false,
    Some(challenge) => challenge.challenge_name == Some(String::from("CUSTOM_CHALLENGE")),
  })
}

/// Returns true if the user has failed the challenge 3 or more times.
fn user_has_failed_the_challenge_too_many_times(
  event: &CognitoEventUserPoolsDefineAuthChallenge,
) -> bool {
  if event.request.session.len() < 3 {
    return false;
  }

  let last_challenge_attempt = event.request.session.last().unwrap();

  match last_challenge_attempt {
    None => true,
    Some(attempt) => attempt.challenge_result,
  }
}

/// Returns true if the user has provided the correct OTP.
fn user_passed_the_challenge(event: &CognitoEventUserPoolsDefineAuthChallenge) -> bool {
  match event.request.session.last() {
    Some(Some(attempt)) => {
      attempt.challenge_name == Some(String::from("CUSTOM_CHALLENGE")) && attempt.challenge_result
    }
    _ => false,
  }
}

/*
Object({
    "callerContext": Object({
        "awsSdkVersion": String("aws-sdk-unknown-unknown"),
        "clientId": String("n2esrif084paec58gmj0hm2jr")
    }),
  "region": String("sa-east-1"),
  "request": Object({"session": Array([]),
    "userAttributes": Object({"cognito:email_alias": String("brunotj2015@hotmail.com"),
    "cognito:user_status": String("CONFIRMED"),
    "email": String("brunotj2015@hotmail.com"),
    "email_verified": String("true"),
    "sub": String("b6f0341c-367f-44ea-9b46-dc3f29d058a9")
  }),
   "userNotFound": Bool(false)}),
   "response": Object({
     "challengeName": Null, "failAuthentication": Null, "issueTokens": Null
    }),
   "triggerSource": String("DefineAuthChallenge_Authentication"),
   "userName": String("b6f0341c-367f-44ea-9b46-dc3f29d058a9"),
   "userPoolId": String("sa-east-1_pIOZ2IwVH"),
   "version": String("1")})
*/

#[instrument(skip_all, fields(event = ?event))]
async fn handler(
  event: LambdaEvent<CognitoEventUserPoolsDefineAuthChallenge>,
) -> Result<CognitoEventUserPoolsDefineAuthChallenge, Error> {
  let (mut event, _context) = event.into_parts();

  if !is_custom_challenge(&event) || user_has_failed_the_challenge_too_many_times(&event) {
    info!("challenge is not valid or user has failed the challenge too many times");
    event.response.issue_tokens = Some(false);
    event.response.fail_authentication = Some(true);
  } else if user_passed_the_challenge(&event) {
    info!("user has passed the challenge");
    event.response.issue_tokens = Some(true);
    event.response.fail_authentication = Some(false);
  } else {
    info!("user is trying to sign in for the first time, giving them a challenge.");

    event.response.issue_tokens = Some(false);
    event.response.fail_authentication = Some(false);
    event.response.challenge_name = Some(String::from("CUSTOM_CHALLENGE"));
  }

  info!(?event);

  Ok(event)
}
