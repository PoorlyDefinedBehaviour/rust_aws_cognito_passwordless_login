use aws_lambda_events::event::cognito::CognitoEventUserPoolsDefineAuthChallenge;
use lambda_runtime::{service_fn, Error, LambdaEvent};

#[tokio::main]
async fn main() -> Result<(), Error> {
  lambda_runtime::run(service_fn(handler)).await?;
  Ok(())
}

/// We only accept our own custom challenge.
fn is_type_of_challenge_valid(event: &CognitoEventUserPoolsDefineAuthChallenge) -> bool {
  event.request.session.iter().any(|attempt| match attempt {
    None => false,
    Some(challenge) => challenge.challenge_name != Some(String::from("CUSTOM_CHALLENGE")),
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

async fn handler(
  event: LambdaEvent<CognitoEventUserPoolsDefineAuthChallenge>,
) -> Result<CognitoEventUserPoolsDefineAuthChallenge, Error> {
  let (mut event, _context) = event.into_parts();

  if !is_type_of_challenge_valid(&event) || user_has_failed_the_challenge_too_many_times(&event) {
    event.response.issue_tokens = false;
    event.response.fail_authentication = true;
  } else if user_passed_the_challenge(&event) {
    event.response.issue_tokens = true;
    event.response.fail_authentication = false;
  } else {
    // Its the first time the user is trying to sign in, give them a challenge.
    event.response.issue_tokens = false;
    event.response.fail_authentication = false;
    event.response.challenge_name = Some(String::from("CUSTOM_CHALLENGE"));
  }

  Ok(event)
}
