///|
fn wat_text(bytes : Bytes) -> String raise EncodedFailure {
  @utf8.decode(bytes, ignore_bom=false) catch {
    _ => raise Invalid("WAT name is not UTF-8")
  }
}

///|
fn compile_encoded_wat(text : String) -> Bytes raise EncodedFailure {
  @component_text.parse_normalized_component_wat(text) catch {
    @component_text.Unsupported(message) => raise Unsupported(message)
    @component_text.ParseError(message) => raise Invalid(message)
  }
}
