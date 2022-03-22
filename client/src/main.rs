use tracing::info;

fn main() {
  let _guard = log::setup();
  /*
  // std::env::set_var("RUST_LOG", format!("{}=trace", env!("CARGO_PKG_NAME")));
  tracing_subscriber::fmt()
    .with_max_level(tracing::Level::INFO)
    // this needs to be set to false, otherwise ANSI color codes will
    // show up in a confusing manner in CloudWatch logs.
    .with_ansi(false)
    // disabling time is handy because CloudWatch will add the ingestion time.
    .without_time()
    .init();*/

  info!("here")
}
