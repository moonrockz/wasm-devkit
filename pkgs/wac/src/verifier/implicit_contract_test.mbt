///|
fn implicit_import_projection(
  model : @verifier.Verified,
) -> Array[String] raise {
  let work : Array[BinaryProjectionWork] = [Text("0")]
  for i = model.imports().length() - 1; i >= 0; i = i - 1 {
    work.push(Item(model.imports()[i]))
  }
  work.push(Text(model.imports().length().to_string()))
  project_graph(model.types(), id => model.resource_identity(id), work)
}

///|
test "implicit import chains keep topological composition edges" {
  let source = StringBuilder()
  source.write_string("package test:app; let i0=new test:dep {...};")
  for i in 1..<3000 {
    source.write_string(
      "let i" +
      i.to_string() +
      "=new test:dep {f: i" +
      (i - 1).to_string() +
      ".out,...};",
    )
  }
  source.write_string("export i2999.out;")
  let source = source.to_string()
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x09\x01\x00\x03\x6f\x75\x74\x01\x00\x00",
    },
  ])
  guard result is Ok(model) else { fail(result.unwrap_err()[0].render()) }
  assert_eq(model.imports().length(), 1)
  assert_eq(model.imports()[0].name, "f")
  assert_eq(
    model
    .composition()
    .filter(node => node.operation is Instantiate(_, _, _))
    .length(),
    3000,
  )
  for node in model.composition() {
    match node.operation {
      Access(parent, _) => assert_true(parent < node.id)
      Instantiate(_, _, arguments) =>
        for argument in arguments {
          assert_true(argument.value < node.id)
        }
      _ => ()
    }
  }
}

///|
test "implicit captured handles use the explicit imported declaration" {
  let source = "package test:app; interface api {resource handle;} import a: api; let i=new test:dep {handle: a.handle,...}; export i.take;"
  let result = @verifier.verify(@parser.parse(source), source~, dependencies=[
    {
      name: "test:dep",
      version: None,
      source: "dep.wasm",
      bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0a\x0b\x01\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x07\x0a\x02\x69\x00\x40\x01\x01\x68\x01\x01\x00\x0a\x09\x01\x00\x04\x74\x61\x6b\x65\x01\x02\x0b\x0a\x01\x00\x04\x74\x61\x6b\x65\x01\x00\x00",
    },
  ])
  guard result is Ok(model) else { fail(result.unwrap_err()[0].render()) }
  let mut captured : Int32? = None
  let mut declared : Int32? = None
  let mut capture_identity : Int32? = None
  let mut declaration_identity : Int32? = None
  for node in model.composition() {
    if node.operation is Import("take") &&
      node.kind is Function(ty) &&
      model.types()[ty].kind is Function(params, _, _) &&
      model.types()[params[0].ty].kind is Own(resource) {
      captured = model.resource_identity(resource)
      capture_identity = Some(node.resources[0].identity)
    }
    if node.operation is Import("a") &&
      node.kind is Instance(ty) &&
      model.types()[ty].kind is Interface(_, _, exports) &&
      exports[0].kind is Type(resource) {
      declared = model.resource_identity(resource)
      declaration_identity = Some(node.resources[0].identity)
    }
  }
  assert_true(captured is Some(_))
  assert_eq(captured, declared)
  assert_eq(capture_identity, declaration_identity)
}

///|
fn implicit_wat_bytes(text : String) -> Bytes raise {
  match @verifier.decode_wat_component_package(text) {
    Ok(input) => input.bytes()
    Err(errors) => fail(errors[0].render())
  }
}

///|
fn implicit_resource_binding(
  model : @verifier.Verified,
  name : String,
) -> (Int32, Int32) raise {
  for node in model.composition() {
    if node.operation != Import(name) {
      continue
    }
    let resource = match node.kind {
      Function(ty) =>
        match model.types()[ty].kind {
          Function(params, _, _) =>
            match model.types()[params[0].ty].kind {
              Own(resource) => resource
              _ => fail("expected owned handle")
            }
          _ => fail("expected function")
        }
      Instance(ty) =>
        match model.types()[ty].kind {
          Interface(_, _, exports) =>
            match exports[0].kind {
              Type(resource) => resource
              _ => fail("expected resource export")
            }
          _ => fail("expected interface")
        }
      _ => fail("expected resource-bearing import")
    }
    let resource = model.resource_identity(resource).unwrap()
    for binding in node.resources {
      if binding.ty == resource {
        return (resource, binding.identity)
      }
    }
    fail("resource has no runtime binding")
  }
  fail("missing import " + name)
}
