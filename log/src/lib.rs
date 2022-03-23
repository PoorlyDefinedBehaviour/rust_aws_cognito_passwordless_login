// use tracing_appender::non_blocking::WorkerGuard;
// use tracing_bunyan_formatter::{BunyanFormattingLayer, JsonStorageLayer};
// use tracing_subscriber::layer::SubscriberExt;
// use tracing_subscriber::Registry;

// pub struct LoggerGuard {
//   _worker_guard: WorkerGuard,
// }

pub fn setup() {
  // The runtime logging can be enabled here by initializing `tracing` with `tracing-subscriber`
  // While `tracing` is used internally, `log` can be used as well if preferred.
  tracing_subscriber::fmt()
    .with_max_level(tracing::Level::INFO)
    // this needs to be set to false, otherwise ANSI color codes will
    // show up in a confusing manner in CloudWatch logs.
    .with_ansi(false)
    // disabling time is handy because CloudWatch will add the ingestion time.
    .without_time()
    .init();

  // let (non_blocking_writer, worker_guard) = tracing_appender::non_blocking(std::io::stdout());

  // let app_name = concat!(env!("CARGO_PKG_NAME"), "-", env!("CARGO_PKG_VERSION")).to_string();

  // let bunyan_formatting_layer = BunyanFormattingLayer::new(app_name, non_blocking_writer);

  // let subscriber = Registry::default()
  // .with(EnvFilter::)
  //   .with(JsonStorageLayer)
  //   .with(bunyan_formatting_layer);

  // tracing::subscriber::set_global_default(subscriber).unwrap();

  // LoggerGuard {
  //   _worker_guard: worker_guard,
  // }
}
