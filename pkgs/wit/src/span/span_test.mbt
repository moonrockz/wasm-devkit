///|
test "positions count UTF-16 units and retain final empty lines" {
  let source = @span.Source::new("a😀\r\n雪\rX\n")
  assert_eq(source.span(), { start: 0, end: 9, })
  assert_eq(source.line_count(), 3)
  assert_eq(source.position(0), Some({ line: 0, column: 0, }))
  assert_eq(source.position(3), Some({ line: 0, column: 3, }))
  assert_eq(source.position(5), Some({ line: 1, column: 0, }))
  assert_eq(source.position(7), Some({ line: 1, column: 2, }))
  assert_eq(source.position(9), Some({ line: 2, column: 0, }))
  assert_eq(source.position(-1), None)
  assert_eq(source.position(10), None)
  assert_eq(source.slice({ start: 1, end: 3, }), Some("😀"))
  // UTF-16 editor ranges can split a scalar. Preserve the requested code units.
  let half = source.slice({ start: 1, end: 2, }).unwrap()
  assert_eq(half.length(), 1)
  assert_eq(half.code_unit_at(0).to_int(), 0xd83d)
  assert_eq(source.slice({ start: 5, end: 5, }), Some(""))
  assert_eq(source.slice({ start: -1, end: 2, }), None)
  assert_eq(source.slice({ start: 3, end: 2, }), None)
  assert_eq(source.slice({ start: 0, end: 10, }), None)
}

///|
test "empty source and span containment include zero-width children" {
  let source = @span.Source::new("")
  assert_eq(source.line_count(), 1)
  assert_eq(source.position(0), Some({ line: 0, column: 0, }))
  let parent : @span.Span = { start: 2, end: 5, }
  assert_eq(parent.length(), 3)
  assert_true(parent.contains({ start: 2, end: 5, }))
  assert_true(parent.contains({ start: 5, end: 5, }))
  assert_false(parent.contains({ start: 4, end: 3, }))
  assert_false(parent.contains({ start: 1, end: 5, }))
}
