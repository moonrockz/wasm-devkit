///|
fn binary(source : String) -> Bytes raise {
  @component_text.parse_normalized_component_wat(source)
}

///|
fn split_source(source : String) -> @decompiler.Split raise {
  match @decompiler.split(binary(source)) {
    Ok(split) => split
    Err(errors) => fail(errors[0].message)
  }
}

///|
test "empty and composed components split into verified WAC documents" {
  let split = split_source(
    (
      #|(component
      #|  (component (core module))
      #|  (instance (instantiate 0))
      #|  (export "app" (instance 0)))
    ),
  )
  assert_eq(split.documents.length(), 2)
  assert_true(
    split.documents[0].text.contains(
      "let n0 = new " + split.documents[1].package_name,
    ),
  )
  assert_eq(split.documents[1].kind, @decompiler.Wat)
  assert_eq(split.inventory.entries.length(), 3)
  assert_eq(split.inventory.entries[2].kind, @decompiler.CoreModule)
}

///|
test "imports preserve function signatures without executable carrier bodies" {
  let split = split_source(
    (
      #|(component
      #|  (type (func (param "x" string) (result u32)))
      #|  (import "f" (func (type 0)))
      #|  (component
      #|    (type (func (param "x" string) (result u32)))
      #|    (import "f" (func (type 0)))
      #|    (export "f" (func 0)))
      #|  (instance (instantiate 0 (with "f" (func 0))))
      #|  (alias export 0 "f" (func))
      #|  (export "g" (func 1)))
    ),
  )
  assert_eq(split.documents.length(), 2)
}

///|
test "imported instance resources retain their use in later function imports" {
  let source =
    #|(component
    #|  (type (instance
    #|    (export "r" (type (sub resource)))
    #|    (type (own 0))
    #|    (type (func (result 1)))
    #|    (export "make" (func (type 2)))))
    #|  (import "api" (instance (type 0)))
    #|  (alias export 0 "r" (type))
    #|  (type (borrow 1))
    #|  (type (func (param "x" 2)))
    #|  (import "consume" (func (type 3)))
    #|  (export "api" (instance 0))
    #|  (export "consume" (func 0)))
  ignore(split_source(source))
}

///|
test "nested pure compositions resolve from generated source documents" {
  let source =
    #|(component
    #|  (component
    #|    (component (core module))
    #|    (instance (instantiate 0))
    #|    (export "inner" (instance 0)))
    #|  (instance (instantiate 0))
    #|  (export "outer" (instance 0)))
  let split = split_source(source)
  let binary_dependencies : Array[@verifier.PackageSource] = []
  let source_dependencies : Array[@verifier.SourcePackage] = []
  for document in split.documents {
    match document.kind {
      Wat =>
        binary_dependencies.push({
          name: document.package_name,
          version: None,
          source: document.path,
          bytes: binary(document.text),
        })
      Wac =>
        source_dependencies.push({
          name: document.package_name,
          version: None,
          source: document.path,
          text: document.text,
        })
    }
  }
  let resolved = @verifier.resolve_composition_packages(
    ReadOnlyArray::from_array(source_dependencies),
    dependencies=ReadOnlyArray::from_array(binary_dependencies),
  )
  assert_true(
    resolved is Ok(_),
    msg=match resolved {
      Ok(_) => ""
      Err(e) => e[0].render()
    },
  )
}

///|
test "inline instances lift through forwarding components without copying bodies" {
  let source =
    #|(component
    #|  (type (func))
    #|  (import "f" (func (type 0)))
    #|  (instance (export "run" (func 0)))
    #|  (export "api" (instance 0)))
  let split = split_source(source)
  assert_eq(split.documents.length(), 2)
  assert_true(split.documents[1].text.contains("(export \"run\" (func $i0))"))
}

///|
test "defined types remain type exports rather than becoming root imports" {
  let source =
    #|(component
    #|  (type (record (field "value" string)))
    #|  (export "item" (type 0)))
  let split = split_source(source)
  assert_eq(split.documents.length(), 2)
  assert_true(!split.documents[0].text.contains("import "))
}

///|
test "a selected core leaf captures module contracts without writing the outer module body" {
  let source =
    #|(component
    #|  (core module (func (export "run")))
    #|  (component
    #|    (alias outer 1 0 (core module))
    #|    (core instance (instantiate 0))))
  let bytes = binary(source)
  let inventory = @decompiler.inventory(bytes).unwrap()
  let id = inventory.entries[2].id
  let split = match @decompiler.split(bytes, select=Some([id])) {
    Ok(value) => value
    Err(e) => fail(e[0].message)
  }
  assert_eq(split.documents.length(), 1)
  let doc = split.documents[0]
  assert_true(doc.text.contains("capture-module"))
  let model = @verifier.decode_component_package(binary(doc.text)).unwrap()
  guard model.types()[model.world()].kind is World(_, _, imports, _) else {
    fail("world missing")
  }
  assert_eq(imports.length(), 1)
  assert_true(imports[0].kind is Module(_))
}

///|
test "a selected core leaf closes a captured core function type" {
  let source =
    #|(component
    #|  (core type (func))
    #|  (component
    #|    (alias outer 1 0 (core type))
    #|    (core module)))
  let bytes = binary(source)
  let id = @decompiler.inventory(bytes).unwrap().entries[1].id
  let split = match @decompiler.split(bytes, select=Some([id])) {
    Ok(value) => value
    Err(e) => fail(e[0].message)
  }
  assert_eq(split.documents.length(), 1)
  assert_true(
    @verifier.decode_component_package(binary(split.documents[0].text)) is Ok(_),
  )
}

///|
test "captures distinguish component values with identical world types" {
  let source =
    #|(component
    #|  (type (component))
    #|  (import "first" (component (type 0)))
    #|  (import "second" (component (type 0)))
    #|  (component
    #|    (alias outer 1 0 (component))
    #|    (instance (instantiate 0))
    #|    (export "out" (instance 0)))
    #|  (instance (instantiate 2))
    #|  (export "out" (instance 0)))
  let split = split_source(source)
  let root = split.documents[0].text
  assert_true(root.contains(": i0}"))
  assert_false(root.contains(": i1}"))
}

///|
test "selected component exports omit helpers containing unselected component bodies" {
  let source = "(component (component (core module)) (export \"child\" (component 0)))"
  let bytes = binary(source)
  let selected = @decompiler.split(bytes, select=Some(["root"])).unwrap()
  assert_eq(selected.documents.length(), 1)
  assert_eq(selected.documents[0].kind, @decompiler.Wac)
  assert_false(selected.documents[0].text.contains("(core module"))
}

///|
test "deep nested compositions split and resolve without recursive traversal" {
  let mut source = "(component (core module))"
  for _ in 0..<32 {
    source = "(component " +
      source +
      " (instance (instantiate 0)) (export \"out\" (instance 0)))"
  }
  let split = split_source(source)
  assert_eq(split.documents.length(), 33)
  assert_eq(split.inventory.entries.length(), 34)
}

///|
test "captured module contracts keep memory64 custom page sizes" {
  let source =
    #|(component
    #|  (core module (memory (export "mem") i64 1 (pagesize 1)))
    #|  (component
    #|    (alias outer 1 0 (core module))
    #|    (core instance (instantiate 0))))
  let bytes = binary(source)
  let inventory = @decompiler.inventory(bytes).unwrap()
  assert_true(inventory.to_json().stringify().contains("\"page-size-log2\":0"))
  let split = match
    @decompiler.split(bytes, select=Some([inventory.entries[2].id])) {
    Ok(value) => value
    Err(e) => fail(e[0].message)
  }
  assert_true(split.documents[0].text.contains("pagesize 1"))
  assert_true(
    @verifier.decode_component_package(binary(split.documents[0].text)) is Ok(_),
  )
}

///|
test "captured module contracts retain exception tag signatures" {
  let source =
    #|(component
    #|  (core module (tag (export "e") (param i32)))
    #|  (component
    #|    (alias outer 1 0 (core module))
    #|    (core instance (instantiate 0))))
  let bytes = binary(source)
  let inventory = @decompiler.inventory(bytes).unwrap()
  let split = match
    @decompiler.split(bytes, select=Some([inventory.entries[2].id])) {
    Ok(value) => value
    Err(e) => fail(e[0].message)
  }
  assert_true(
    @verifier.decode_component_package(binary(split.documents[0].text)) is Ok(_),
  )
}
