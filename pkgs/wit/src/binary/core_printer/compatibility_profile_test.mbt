///|
test "direct compatibility rejects out-of-profile try_table without text" {
  let bytes = b"\x00asm\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x0a\x09\x01\x07\x00\x1f\x40\x00\x01\x0b\x0b"
  let module_ = @core_parser.parse_module(bytes)
  for
    mode in [
      @core_printer.Compatibility::WasmTools,
      @core_printer.Compatibility::Wabt,
    ] {
    let rejected = try {
      ignore(@core_printer.render_compatible(module_, bytes, mode))
      false
    } catch {
      @core_printer.ReferenceUnsupported(_) => true
      _ => false
    }
    assert_true(rejected)
  }
}
