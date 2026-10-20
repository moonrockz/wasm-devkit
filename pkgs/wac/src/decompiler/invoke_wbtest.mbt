///|
test "invocation adapters preserve parameterized imported function contracts" {
  let source = "(component (type (func (param \"x\" u32))) (import \"f\" (func (type 0))) (type (component (type (func (param \"x\" u32))) (import \"f\" (func (type 0))) (export \"f\" (func (type 0))))) (import \"c\" (component (type 1))) (instance (instantiate 0 (with \"f\" (func 0)))) (alias export 0 \"f\" (func)) (export \"out\" (func 1)))"
  let bytes = @component_text.parse_normalized_component_wat(source)
  let inspection = inspect(bytes, "original")
  let scope = inspection.snapshots[0].scope.unwrap()
  let text = invoke_component(inspection.inventory.types, scope.components[0], [
    {
      name: "f",
      kind: @verifier.Function(scope.functions[0]),
      location: @verifier.Location::binary("original"),
    },
  ])
  let result = @verifier.decode_component_package(compile(text))
  guard result is Ok(_) else {
    fail(text + "\n" + result.unwrap_err()[0].render())
  }
}
