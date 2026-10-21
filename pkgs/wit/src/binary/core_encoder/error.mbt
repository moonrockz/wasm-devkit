///|
/// An encoding failure returns no partial module bytes.
pub(all) suberror EncodingError {
  EncodingError(String)
} derive(Debug)

///|
pub impl Show for EncodingError with fn output(self, logger) {
  match self {
    EncodingError(message) => logger.write_string(message)
  }
}

///|
pub extend EncodingError with @debug.Debug::{to_repr}

///|
pub extend EncodingError with Show::{to_string, output}
