///|
/// Binary positions count bytes. None means the semantic validator supplied no
/// precise offset. These positions are never rendered as source UTF-16 spans.
pub(all) struct Diagnostic {
  source : String
  offset : Int32?
  code : String
  message : String
} derive(Eq, Debug)

///|
/// Evidence for a validated type-only component encoding. This does not claim
/// that the component decodes to a WIT package or satisfies a source dependency.
pub struct ValidatedComponent {
  bytes : Bytes
}

///|
pub fn ValidatedComponent::bytes(self : ValidatedComponent) -> Bytes {
  self.bytes
}

///|
/// Validate the binary framing and component type semantics without execution.
/// WIT package reconstruction is a separate operation. Runtime sections and
/// physical type scopes deeper than 256 are outside this encoding boundary.
pub fn validate_type_component(
  bytes : Bytes,
  source_id~ : String = "<binary>",
) -> Result[ValidatedComponent, ReadOnlyArray[Diagnostic]] {
  try {
    preflight(bytes)
    let component = @component.parse_component(bytes) catch {
      error => raise Failure(None, "WIT-B001", error.to_string())
    }
    @validation.validate_component(component) catch {
      error => raise Failure(None, "WIT-B003", error.to_string())
    }
    Ok({ bytes, })
  } catch {
    Failure(offset, code, message) =>
      Err([{ source: source_id, offset, code, message, }])
  }
}

///|
pub extend Diagnostic with Eq::{equal, not_equal}

///|
pub extend Diagnostic with @debug.Debug::{to_repr}
