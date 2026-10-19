///|
/// Compile portable component text, then validate and decode the declarative
/// binary profile. Compiled byte positions are not positions in the WAT source,
/// so diagnostics retain the source identity with an unknown binary offset.
pub fn decode_wat_component_package(
  text : String,
  source_id~ : String = "<wat>",
) -> Result[BinaryPackage, ReadOnlyArray[Diagnostic]] {
  let bytes = @component_text.parse_normalized_component_wat(text) catch {
    @component_text.ParseError(message) =>
      return Err([binary_problem(source_id, "WAC-B001", message)])
    @component_text.Unsupported(message) =>
      return Err([binary_problem(source_id, "WAC-B002", message)])
  }
  decode_component_package(bytes, source_id~).map_err(errors => {
    errors.map(problem => {
      ..problem,
      primary: { ..problem.primary, location: Location::binary(source_id), },
    })
  })
}
