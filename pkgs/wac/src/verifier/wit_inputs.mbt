///|
/// WIT provider data supplied by the caller. Lookup identity is independent of
/// WIT package identities. Resolution is lazy and consumes only this closure.
pub(all) struct WitPackageSource {
  name : String
  version : String?
  source : String
  root : @wit_verifier.PackageInput
  dependencies : ReadOnlyArray[@wit_verifier.PackageInput]
}

///|
fn wit_diagnostic(problem : @wit_verifier.Diagnostic) -> Diagnostic {
  {
    code: problem.code,
    message: problem.message,
    primary: {
      location: wit_location(problem.primary.location),
      message: problem.primary.message,
    },
    related: problem.related.map(label => {
      location: wit_location(label.location),
      message: label.message,
    }),
  }
}

///|
/// Resolve a supplied WIT closure and adapt it using WAC's WIT compatibility
/// profile. No paths are opened; text and encoded providers remain caller data.
pub fn resolve_wit_package(
  root : @wit_verifier.PackageInput,
  dependencies~ : ReadOnlyArray[@wit_verifier.PackageInput] = [],
) -> Result[WitPackage, ReadOnlyArray[Diagnostic]] {
  match @wit_verifier.resolve_packages(root, dependencies~) {
    Ok(resolution) => adapt_wit_package(resolution)
    Err(errors) => Err(errors.map(wit_diagnostic))
  }
}

///|
fn Check::register_wit_packages(
  self : Check,
  inputs : ReadOnlyArray[WitPackageSource],
) -> Unit raise SemanticFailure {
  for input in inputs {
    let parts = input.name.split(":").to_array()
    let location = Location::text(input.source, { start: 0, end: 0, })
    if parts.length() < 2 ||
      !parts.all(part => identifier(part.to_owned())) ||
      !input.version.map(semantic_version).unwrap_or(true) {
      raise Problem({
        ..wit_problem(location, "invalid WIT package lookup identity"),
        code: "WAC-P001",
      })
    }
    let key = package_key(input.name, input.version)
    let first = match self.dependencies.get(key) {
      Some(first) => Some(Location::binary(first.source))
      None =>
        self.wit_dependencies
        .get(key)
        .map(first => Location::text(first.source, { start: 0, end: 0, }))
    }
    if first is Some(first) {
      let message = "duplicate package input `" + key + "`"
      raise Problem({
        code: "WAC-P002",
        message,
        primary: { location, message, },
        related: [{ location: first, message: "first package input", }],
      })
    }
    self.wit_dependencies[key] = input
  }
}
