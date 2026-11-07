///|
/// An encoding failure returns no partial module bytes.
#derive(Debug)
pub(all) suberror EncodingError {
  EncodingError(String)
}

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
