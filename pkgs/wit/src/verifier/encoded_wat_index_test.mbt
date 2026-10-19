///|
// Acceptance expectations come from wasm-tools 1.262.0 and wit-parser 0.262.0.
test "encoded WAT indices follow unsigned literal spelling" {
  let source = "(component(type(component(type(component (type (instance (export \"r\" (type (sub resource))))) (import \"example:dep/api\" (instance (type 0))) (alias export 0 \"r\" (type)) (type (own 1)) (type (func (param \"x\" 2))) (import \"f\" (func (type 3)))))(export \"example:test/app\" (component(type 0)))))(export \"app\"(type 0)))"
  let expected = @verifier.decode_wat_package(source).unwrap()
  for
    (spelling, accepted) in [
      ("0", true),
      ("+0", true),
      ("-0", false),
      ("00", true),
      ("0_0", true),
      ("0__0", false),
      ("_0", false),
      ("0_", false),
      ("+0_0", true),
      ("+_0", false),
      ("0x0", true),
      ("+0x0", true),
      ("-0x0", false),
      ("0X0", false),
      ("0x00", true),
      ("0x0_0", true),
      ("0x_0", false),
      ("0x0_", false),
      ("0x0__0", false),
      ("0x", false),
      ("+", false),
      ("0x80000000", false),
      ("4294967296", false),
      ("0x100000000", false),
      ("+4294967296", false),
      ("4_294_967_296", false),
    ] {
    let input = source.replace(old="(type 0)", new="(type " + spelling + ")")
    let decoded = @verifier.decode_wat_package(input)
    if accepted {
      let decoded = decoded.unwrap()
      assert_eq(decoded.bytes(), expected.bytes())
      let actual = @verifier.resolve_packages(Encoded(decoded)).unwrap()
      let expected_model = @verifier.resolve_packages(Encoded(expected)).unwrap()
      assert_eq(actual.world_summary(), expected_model.world_summary())
      assert_eq(
        encoded_alias_model(actual, reachable_only=true),
        encoded_alias_model(expected_model, reachable_only=true),
      )
    } else {
      assert_true(decoded is Err(_))
    }
  }
}
