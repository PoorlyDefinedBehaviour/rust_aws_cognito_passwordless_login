use aws_lambda_events::event::cognito::CognitoEventUserPoolsCreateAuthChallenge;
use lambda_runtime::{service_fn, Error, LambdaEvent};
use rusoto_ses::{Body, Content, Destination, Message, SendEmailRequest, Ses, SesClient};
use tracing::{info, instrument};

#[tokio::main]
async fn main() -> Result<(), Error> {
  log::setup();
  lambda_runtime::run(service_fn(handler)).await?;
  Ok(())
}

#[instrument(skip_all, fields(event = ?event))]
async fn handler(
  event: LambdaEvent<CognitoEventUserPoolsCreateAuthChallenge>,
) -> Result<CognitoEventUserPoolsCreateAuthChallenge, Error> {
  let (mut event, _context) = event.into_parts();

  let user_email = event.request.user_attributes.get("email").unwrap().clone();

  let secret_code = if event.request.session.is_empty() {
    // If it is a new auth session, send the email to the user
    // for the first time.
    let secret_code = String::from("123456");
    let ses = SesClient::new(rusoto_core::Region::SaEast1);
    let input = SendEmailRequest {
      source: std::env::var("SES_FROM_ADDRESS").expect("SES_FROM_ADDRESS is not set"),
      destination: Destination {
        bcc_addresses: None,
        cc_addresses: None,
        to_addresses: Some(vec![user_email.clone()]),
      },
      message: Message {
        body: Body {
          text: None,
          html: Some(Content {
            charset: Some(String::from("UTF-8")),
            data: format!("Your secret login code: {}", &secret_code),
          }),
        },
        subject: Content {
          charset: Some(String::from("UTF-8")),
          data: String::from("foo"),
        },
      },
      ..Default::default()
    };

    println!("aaaaaa input {:?}", input);

    info!(?user_email, "sending OTP through email");

    ses
      .send_email(input)
      .await
      .expect("unable to send OTP code through email");

    secret_code
  } else {
    info!(
      retry_count = event.request.session.len(),
      ?user_email,
      "user is retrying a challenge"
    );
    // SAFETY: session is not empty because we checked it in the first if condition.
    let previous_challenge = event.request.session.last().unwrap().as_ref().unwrap();
    previous_challenge
      .challenge_metadata
      .as_ref()
      .unwrap()
      .clone()
  };

  event
    .response
    .public_challenge_parameters
    .insert(String::from("email"), user_email);

  event
    .response
    .private_challenge_parameters
    .insert(String::from("secret_code"), secret_code.clone());

  event.response.challenge_metadata = Some(secret_code);

  Ok(event)
}
