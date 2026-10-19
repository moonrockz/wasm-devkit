///|
test "nested component customs and producers retain payloads" {
  let bytes = parse_normalized_component_wat(
    "(component (component (@custom \"blob\" \"\\ff\\00\\80\") (@producers (processed-by \"tool\" \"1\"))))",
  )
  let parsed = @component.parse_component(bytes)
  assert_eq(parsed.components.length(), 1)
  let mut blob = false
  let mut producers = false
  for section in parsed.components[0].binary.sections {
    if section.id == 0 {
      if section.payload == b"\x04blob\xff\x00\x80" {
        blob = true
      }
      if section.payload ==
        b"\x09producers\x01\x0cprocessed-by\x01\x04tool\x011" {
        producers = true
      }
    }
  }
  assert_true(blob)
  assert_true(producers)
}
