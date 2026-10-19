///|
test "export spreading through deep groups preserves cached aliases" {
  let text = StringBuilder()
  text.write_string(
    "package test:app; import i: interface {f: func();}; let f=i.f; export f as first; export ",
  )
  for _ in 0..<2000 {
    text.write_string("(")
  }
  text.write_string("i")
  for _ in 0..<2000 {
    text.write_string(")")
  }
  text.write_string("...;")
  let source = text.to_string()
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  assert_eq(model.composition().length(), 2)
  assert_eq(model.composition_exports().map(item => item.value), [1, 1])
  let changed = model
    .composition_exports()
    .map(item => { ..item, name: "changed", })
  assert_eq(changed[0].name, "changed")
  assert_eq(model.composition_exports()[0].name, "first")
}

///|
test "export spread keeps resource contexts of the selected members" {
  let source = "package test:app; import a: interface {resource handle;}; import b: interface {resource handle; take: func(h: handle);}; export a...; export b...;"
  let model = @verifier.verify(@parser.parse(source), source~).unwrap()
  let nodes = model.composition()
  assert_eq(nodes.length(), 4)
  assert_eq(nodes[2].resources, nodes[0].resources)
  assert_eq(nodes[3].resources, nodes[1].resources)
  assert_true(nodes[0].resources[0].identity != nodes[1].resources[0].identity)
  assert_eq(model.composition_exports().map(item => item.value), [2, 3])
}

///|
test "export spread accepts an instantiated expression" {
  let source = "package test:app; import f: func(x: u32) -> u32; export new lookup:dep {f}...;"
  let model = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "lookup:dep",
      version: None,
      source: "dep.wasm",
      bytes: instantiation_function_bytes(),
    },
  ]).unwrap()
  assert_eq(model.exports().map(item => item.name), ["out"])
  assert_true(model.composition()[2].operation is Access(1, "out"))
}

///|
test "export spread no-effect errors are deterministic source locations" {
  let source = "// 😀\npackage test:app; import i: interface {f: func();}; export i.f; export i...;"
  let first = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="spread.wac",
  ).unwrap_err()
  let second = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="spread.wac",
  ).unwrap_err()
  assert_eq(first, second)
  assert_eq(first[0].code, "WAC-C007")
  assert_eq(first[0].primary.location.source, "spread.wac")
  assert_true(first[0].primary.location.span().unwrap().start > 60)
}

///|
test "caller-built exports cannot combine spread and rename" {
  let source = "package test:app; import i: interface {f: func();}; export i as renamed;"
  let parsed = @parser.parse(source)
  let tree : @ast.Tree = {
    nodes: parsed.ast.nodes.map(node => {
      let data : @ast.Data = match node.data {
        Export(expression~, renamed~, ..) =>
          Export(expression~, renamed~, spread=true)
        _ => node.data
      }
      { ..node, data, }
    }),
  }
  assert_true(tree.validate())
  let errors = @verifier.verify_ast(tree, source~).unwrap_err()
  assert_eq(errors[0].code, "WAC-S001")
}
