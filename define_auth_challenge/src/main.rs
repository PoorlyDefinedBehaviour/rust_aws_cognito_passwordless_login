use lambda_runtime::{service_fn, Error, LambdaEvent};
use serde_json::{json, Value};

#[tokio::main]
async fn main() -> Result<(), Error> {
  lambda_runtime::run(service_fn(handler)).await?;
  Ok(())
}

async fn handler(event: LambdaEvent<Value>) -> Result<Value, Error> {
  let (event, _context) = event.into_parts();
  let first_name = event["firstName"].as_str().unwrap_or("world");

  Ok(json!({ "message": format!("Hello, {}!", first_name) }))
}
