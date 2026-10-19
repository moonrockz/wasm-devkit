///|
test "nested value adapter preserves original core and custom bytes" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x04\x45\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x08\x00\x61\x73\x6d\x01\x00\x00\x00\x0a\x06\x01\x00\x01\x76\x02\x79\x0b\x07\x01\x00\x01\x76\x02\x00\x00\x00\x08\x04\x62\x6c\x6f\x62\xff\x00\x80\x00\x16\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x02\x01\x00\x01\x76"
  let validated = validate_declarative_component(bytes).unwrap()
  assert_eq(validated.bytes(), bytes)
  let parsed = @component.parse_component(validated.parser_bytes())
  assert_eq(parsed.components.length(), 1)
  let child = parsed.components[0]
  assert_eq(child.core_modules[0], b"\x00asm\x01\x00\x00\x00")
  let mut found = false
  for section in child.binary.sections {
    if section.id == 0 && section.payload == b"\x04blob\xff\x00\x80" {
      found = true
    }
  }
  assert_true(found)
  assert_eq(
    child.imports[0].desc,
    @component.ExternDesc::Value(Type(Prim(U32))),
  )
}
