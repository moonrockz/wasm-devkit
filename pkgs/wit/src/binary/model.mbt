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
    validate_layouts(component)
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

///|
/// A component containing types, imports, aliases, exports and flat core module
/// bodies. Nested component definitions, instantiation and canonical functions remain
/// outside this boundary. The immutable bytes are the validated snapshot.
pub struct ValidatedDeclarativeComponent {
  bytes : Bytes
}

///|
pub fn ValidatedDeclarativeComponent::bytes(
  self : ValidatedDeclarativeComponent,
) -> Bytes {
  self.bytes
}

///|
/// Validate declarative component metadata against the WAC 0.12.0 encoding
/// profile without executing or resolving it. This profile does not apply the
/// newer wasmparser 0.262.0 memory64 layout bound or map-key restrictions used
/// by type-only WIT inputs.
/// Physical type scopes are limited to 256, as in validate_type_component.
/// Package reconstruction and dependency resolution are separate operations.
pub fn validate_declarative_component(
  bytes : Bytes,
  source_id~ : String = "<binary>",
) -> Result[ValidatedDeclarativeComponent, ReadOnlyArray[Diagnostic]] {
  try {
    preflight(bytes, declarations=true)
    let component = @component.parse_component(bytes) catch {
      error => raise Failure(None, "WIT-B001", error.to_string())
    }
    let (core_ascriptions, core_contracts) = validate_core_definitions(
      component,
    )
    let mut core_work = 1000000
    for pair in core_ascriptions {
      match
        @core_types.check_module_subtype(
          pair.actual,
          pair.expected,
          work_limit=core_work,
        ) {
        Ok(remaining) => core_work = remaining
        Err(Mismatch(message)) => raise Failure(None, "WIT-B003", message)
        Err(WorkLimit) =>
          raise Failure(
            None,
            "WIT-B002",
            "core module ascription comparison work limit exceeded",
          )
      }
    }
    @validation.validate_component_with_config(
      component,
      @validation.ComponentValidationConfig(
        true,
        restricted_map_keys=false,
        canonical_version_suffix=false,
      ),
      core_contracts=Some(core_contracts),
    ) catch {
      @validation.UnsupportedComponentAscription =>
        raise Failure(
          None,
          "WIT-B002",
          "component ascription requires complete supported contracts",
        )
      @validation.UnsupportedInstanceAscription =>
        raise Failure(
          None,
          "WIT-B002",
          "instance ascription requires complete supported export contracts",
        )
      @validation.CoreContractBudgetExceeded =>
        raise Failure(
          None,
          "WIT-B002",
          "core runtime contract work limit exceeded",
        )
      @validation.CanonicalBudgetExceeded =>
        raise Failure(
          None,
          "WIT-B002",
          "canonical ABI graph exceeds its work budget",
        )
      @validation.UnsupportedCanonical =>
        raise Failure(
          None,
          "WIT-B002",
          "canonical function form is outside the supported profile",
        )
      @validation.UnsupportedFunctionAscription =>
        raise Failure(
          None,
          "WIT-B002",
          "function ascription requires a fully described function signature",
        )
      error => raise Failure(None, "WIT-B003", error.to_string())
    }
    Ok({ bytes, })
  } catch {
    Failure(offset, code, message) =>
      Err([{ source: source_id, offset, code, message, }])
  }
}
