///|
fn instantiate_source(
  source : String,
  bytes : Bytes,
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.verify(@parser.parse(source), source~, source_id="root.wac", dependencies=[
    { name: "lookup:dep", version: None, source: "dep.wasm", bytes, },
  ])
}

///|
test "deep instantiation expressions preserve ordered graph edges" {
  let source = StringBuilder()
  source.write_string(
    "package test:app; import f: func(x: u32) -> u32; let output = ",
  )
  for _ in 0..<2000 {
    source.write_string("(new lookup:dep {f: ")
  }
  source.write_string("f")
  for _ in 0..<2000 {
    source.write_string("}).out")
  }
  source.write_string("; export output;")
  let model = instantiate_source(
    source.to_string(),
    instantiation_function_bytes(),
  ).unwrap()
  assert_eq(model.composition().length(), 4001)
  for node in model.composition() {
    match node.operation {
      Instantiate("lookup:dep", None, [argument]) => {
        assert_eq(argument.name, "f")
        assert_eq(argument.value, node.id - 1)
      }
      Access(instance, "out") => assert_eq(instance, node.id - 1)
      Import("f") => assert_eq(node.id, 0)
      _ => fail("unexpected composition operation")
    }
  }
}

///|
test "structural compatibility follows deep aliases on success and mismatch" {
  let wat = StringBuilder()
  wat.write_string("(component (type (list u32))")
  for i in 1..<64 {
    wat.write_string("(type (list \{i-1}))")
  }
  wat.write_string(
    "(type (func (param \"x\" 63))) (import \"f\" (func (type 64))))",
  )
  let decoded = @verifier.decode_wat_component_package(wat.to_string())
  guard decoded is Ok(decoded_package) else {
    fail(decoded.unwrap_err()[0].render())
  }
  let bytes = decoded_package.bytes()
  for scalar in ["u32", "u16"] {
    let source = StringBuilder()
    source.write_string("package test:app; type t0 = ")
    for _ in 0..<64 {
      source.write_string("list<")
    }
    source.write_string(scalar)
    for _ in 0..<64 {
      source.write_string(">")
    }
    source.write_string(";")
    for i in 1..<5000 {
      source.write_string("type t\{i} = t\{i-1};")
    }
    source.write_string(
      "import f: func(x: t4999); let output = new lookup:dep {f};",
    )
    let result = instantiate_source(source.to_string(), bytes)
    assert_eq(result is Ok(_), scalar == "u32")
    if result is Err(errors) {
      assert_eq(errors[0].code, "WAC-C005")
    }
  }
}

///|
test "runtime resource identities distinguish repeated imports and preserve aliases" {
  let source = "package test:app; interface a {resource handle; take: func(h: handle);} import first: a; import second: a; let alias = first; let i = new lookup:dep {api: alias}; let j = new lookup:dep {api: i.api}; export j as output;"
  let model = instantiate_source(source, instantiation_resource_bytes()).unwrap()
  let first = model.composition()[1]
  let second = model.composition()[2]
  assert_eq(first.kind, second.kind)
  assert_eq(first.resources.length(), 1)
  assert_eq(second.resources.length(), 1)
  assert_eq(first.resources[0].ty, second.resources[0].ty)
  assert_true(first.resources[0].identity != second.resources[0].identity)
  for node in model.composition() {
    if node.operation is Instantiate(_, _, _) || node.operation is Access(_, _) {
      assert_eq(node.resources.length(), 1)
      assert_eq(node.resources[0].identity, first.resources[0].identity)
    }
    if node.operation is Instantiate(_, _, arguments) {
      let copy = arguments.map(argument => { ..argument, value: -1, })
      assert_eq(copy[0].value, -1)
      assert_true(arguments[0].value >= 0)
    }
  }
  let copy = first.resources.map(binding => { ..binding, identity: -1, })
  assert_eq(copy[0].identity, -1)
  assert_true(first.resources[0].identity >= 0)
}

///|
test "each instantiation freshens its exported resources" {
  let source = "package test:app; let first = new lookup:dep {}; let second = new lookup:dep {}; export first as first; export second as second;"
  let model = instantiate_source(
    source,
    instantiation_resource_generator_bytes(),
  ).unwrap()
  let first = model.composition()[0]
  let second = model.composition()[1]
  assert_eq(first.kind, second.kind)
  assert_eq(first.resources.length(), 1)
  assert_eq(second.resources.length(), 1)
  assert_eq(first.resources[0].ty, second.resources[0].ty)
  assert_true(first.resources[0].identity != second.resources[0].identity)
}

///|
test "instantiation failures retain both source and binary type provenance" {
  let source = "// 😀\npackage test:app; import f: func(x: u16) -> u32; let i = new lookup:dep {f};"
  guard instantiate_source(source, instantiation_function_bytes())
    is Err(errors) else {
    fail("mismatched signature accepted")
  }
  assert_eq(errors[0].code, "WAC-C005")
  assert_eq(errors[0].primary.location.source, "root.wac")
  assert_true(errors[0].primary.location.span().unwrap().start > 60)
  assert_eq(errors[0].related[0].location.source, "dep.wasm")
  assert_true(errors[0].related[0].location.position is BinaryOffset(_))
  assert_eq(errors[0].related[1].location.source, "root.wac")
  guard instantiate_source(source, instantiation_function_bytes()) is Err(again) else {
    fail("nondeterministic result")
  }
  assert_eq(errors, again)
}

///|
test "caller-built argument nodes cannot escape their semantic role" {
  let source = "package test:app; import f: func(x: u32) -> u32; let alias = f; let i = new lookup:dep {f};"
  let parsed = @parser.parse(source)
  for misplaced in [true, false] {
    let tree : @ast.Tree = {
      nodes: parsed.ast.nodes.map(node => {
        let data : @ast.Data = match node.data {
          InferredArgument(name~) if misplaced => Reference(name~)
          Reference(name~) if !misplaced => InferredArgument(name~)
          _ => node.data
        }
        { ..node, data, }
      }),
    }
    assert_true(tree.validate())
    guard @verifier.verify_ast(tree, source~, dependencies=[
        {
          name: "lookup:dep",
          version: None,
          source: "dep.wasm",
          bytes: instantiation_function_bytes(),
        },
      ])
      is Err(errors) else {
      fail("invalid argument role accepted")
    }
    assert_eq(errors[0].code, "WAC-S001")
  }
}
