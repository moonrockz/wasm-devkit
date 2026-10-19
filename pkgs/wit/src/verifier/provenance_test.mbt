///|
test "binary diagnostics preserve byte offsets without manufacturing source spans" {
  for offset in [None, Some(0), Some(17)] {
    let diagnostic = @verifier.Diagnostic::from_binary({
      source: "dep.wasm",
      offset,
      code: "WIT-B001",
      message: "invalid encoding",
    })
    assert_eq(diagnostic.primary.location.position, BinaryOffset(offset))
    assert_eq(diagnostic.primary.location.span(), None)
    assert_eq(diagnostic.primary.location.source, "dep.wasm")
    assert_eq(diagnostic.code, "WIT-B001")
    assert_true(
      diagnostic
      .render()
      .contains(
        if offset is Some(byte) {
          "[byte \{byte}]"
        } else {
          "[binary]"
        },
      ),
    )
  }
}

///|
test "source positions and syntax-node provenance remain original UTF16 coordinates" {
  let text = "// 😀\npackage example:app;interface api{resource r;}"
  let document = section_document("api.wit", text)
  let model = @verifier.resolve({ documents: [document], }).unwrap()
  let resource = model.types().filter(t => t.kind is Resource)[0]
  let origin = model.origin(resource.id).unwrap()
  let syntax_node = origin.node.unwrap()
  assert_eq(
    origin.location.position,
    SourceSpan(document.ast.nodes[syntax_node].span),
  )
  assert_eq(origin.location.span(), Some(document.ast.nodes[syntax_node].span))
  assert_eq(origin.location, resource.location)
  let changed = model
    .types()
    .map(t => { ..t, location: @verifier.Location::binary("replacement.wasm"), })
  assert_true(changed.all(t => t.location.span() is None))
  assert_eq(
    model.types().filter(t => t.id == resource.id)[0].location,
    origin.location,
  )
}
