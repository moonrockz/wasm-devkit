///|
/// A validated declarative component and its immutable WAC type graph. Package
/// lookup names belong to the caller; encoded interface names are type metadata.
pub struct BinaryPackage {
  priv source_id : String
  priv snapshot : Bytes
  priv arena : ReadOnlyArray[ResolvedType]
  priv world_type : Int32
  priv instance_type : Int32
  priv defined_items : ReadOnlyArray[Extern]
}

///|
pub fn BinaryPackage::source(self : BinaryPackage) -> String {
  self.source_id
}

///|
pub fn BinaryPackage::bytes(self : BinaryPackage) -> Bytes {
  self.snapshot
}

///|
pub fn BinaryPackage::types(
  self : BinaryPackage,
) -> ReadOnlyArray[ResolvedType] {
  self.arena
}

///|
pub fn BinaryPackage::world(self : BinaryPackage) -> Int32 {
  self.world_type
}

///|
pub fn BinaryPackage::instance(self : BinaryPackage) -> Int32 {
  self.instance_type
}

///|
pub fn BinaryPackage::definitions(
  self : BinaryPackage,
) -> ReadOnlyArray[Extern] {
  self.defined_items
}

///|
pub fn BinaryPackage::resource_identity(
  self : BinaryPackage,
  id : Int32,
) -> Int32? {
  let mut current = id
  for _ in 0..<self.arena.length() {
    guard current >= 0 && current < self.arena.length() else { return None }
    match self.arena[current].kind {
      Resource(None) => return Some(current)
      Resource(Some(next)) | Alias(next) => current = next
      _ => return None
    }
  }
  None
}

///|
priv suberror BinaryFailure {
  Unsupported(String)
  Invalid(String)
}

///|
fn binary_problem(
  source : String,
  code : String,
  message : String,
) -> Diagnostic {
  {
    code,
    message,
    primary: { location: Location::binary(source), message, },
    related: [],
  }
}

///|
/// Decode the declarative WAC component profile without executing code or
/// resolving dependencies. Flat core module bodies validate without execution.
/// Other runtime sections fail explicitly. Type scopes
/// and graph expansion have bounded work; diagnostics use binary provenance.
pub fn decode_component_package(
  bytes : Bytes,
  source_id~ : String = "<binary>",
) -> Result[BinaryPackage, ReadOnlyArray[Diagnostic]] {
  match @binary_validation.validate_declarative_component(bytes, source_id~) {
    Err(errors) =>
      return Err(
        errors.map(error => {
          let code = match error.code {
            "WIT-B001" => "WAC-B001"
            "WIT-B002" => "WAC-B002"
            _ => "WAC-B003"
          }
          {
            code,
            message: error.message,
            primary: {
              location: Location::binary(source_id, offset=error.offset),
              message: error.message,
            },
            related: [],
          }
        }),
      )
    Ok(_) => ()
  }
  try {
    let component = @component.parse_component(bytes) catch {
      _ => raise Invalid("validated component could not be read")
    }
    binary_decode(component, bytes, source_id)
  } catch {
    Unsupported(message) =>
      Err([binary_problem(source_id, "WAC-B002", message)])
    Invalid(message) => Err([binary_problem(source_id, "WAC-B004", message)])
  }
}
