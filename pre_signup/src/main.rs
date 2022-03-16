use aws_lambda_events::event::cognito::CognitoEventUserPoolsPreSignup;
use lambda_runtime::{service_fn, Error, LambdaEvent};
use tracing::instrument;

#[tokio::main]
async fn main() -> Result<(), Error> {
  log::setup();
  lambda_runtime::run(service_fn(handler)).await?;
  Ok(())
}

#[instrument(skip_all, fields(event = ?event))]
async fn handler(
  event: LambdaEvent<CognitoEventUserPoolsPreSignup>,
) -> Result<CognitoEventUserPoolsPreSignup, Error> {
  let (mut event, _context) = event.into_parts();

  event.response.auto_confirm_user = true;
  event.response.auto_verify_email = true;

  Ok(event)
}
