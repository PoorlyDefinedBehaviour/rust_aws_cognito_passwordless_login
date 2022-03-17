use aws_lambda_events::event::cognito::CognitoEventUserPoolsVerifyAuthChallenge;
use lambda_runtime::{service_fn, Error, LambdaEvent};
use tracing::{info, instrument};

#[tokio::main]
async fn main() -> Result<(), Error> {
  log::setup();
  lambda_runtime::run(service_fn(handler)).await?;
  Ok(())
}

#[instrument(skip_all, fields(event = ?event))]
async fn handler(
  event: LambdaEvent<CognitoEventUserPoolsVerifyAuthChallenge>,
) -> Result<CognitoEventUserPoolsVerifyAuthChallenge, Error> {
  let (mut event, _context) = event.into_parts();

  let expected_secret_code = event
    .request
    .private_challenge_parameters
    .get("secret_code")
    .unwrap();

  event.response.answer_correct = Some(match &event.request.challenge_answer {
    None => false,
    Some(answer) => match answer.as_str() {
      None => false,
      Some(s) => s == expected_secret_code,
    },
  });

  info!(answer_correct = event.response.answer_correct);

  Ok(event)
}
