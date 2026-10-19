// Retained from Milky2018/wasm_component@0.16.0; local formatting changes.

///|
pub extend ComponentValidationError with Debug::{to_repr}

///|
pub extend ComponentValidationError with Eq::{not_equal, equal}

///|
pub extend ComponentValidationError with Show::{to_string, output}
