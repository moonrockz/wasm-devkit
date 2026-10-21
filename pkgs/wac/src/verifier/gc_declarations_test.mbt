///|
test "GC declarative binary recursive-outer-alias" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x1a\x02\x4e\x02\x5f\x01\x63\x01\x00\x5e\x63\x00\x00\x50\x02\x02\x10\x01\x01\x01\x03\x01\x67\x03\x63\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x02\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x26\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x0c\x00\x10\x03\x00\x01\x73\x01\x01\x61\x02\x01\x6d\x01\x07\x00\x11\x01\x00\x02\x6d\x30",
  )
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core rec (type $s (struct (field (ref null $a)))) (type $a (array (ref null $s)))) (core type $m (module (alias outer 1 $a (type $local)) (export \"g\" (global (ref null 0))))) (import \"m\" (core module $m0 (type $m))) (export \"m\" (core module $m0)))\n",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(result.unwrap()),
    binary_projection(text.unwrap()),
  )
  let expected = @verifier.TypeKind::Module(gc_declaration_contract(0))
  assert_true(result.unwrap().types().any(t => t.kind == expected))
}

///|
test "GC declarative binary module-gap" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x18\x04\x50\x00\x5f\x01\x7f\x00\x60\x01\x63\x01\x00\x50\x02\x02\x10\x01\x01\x02\x03\x01\x66\x00\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x03\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x2f\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x15\x00\x10\x04\x00\x07\x69\x67\x6e\x6f\x72\x65\x64\x01\x01\x73\x02\x01\x66\x03\x01\x6d\x01\x07\x00\x11\x01\x00\x02\x6d\x30",
  )
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $ignored (module)) (core type $s (struct (field i32))) (core type $f (func (param (ref null $s)))) (core type $m (module (alias outer 1 $f (type $mf)) (export \"f\" (func (type 0))))) (import \"m\" (core module $m0 (type $m))) (export \"m\" (core module $m0)))\n",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(result.unwrap()),
    binary_projection(text.unwrap()),
  )
  let expected = @verifier.TypeKind::Module(gc_declaration_contract(1))
  assert_true(result.unwrap().types().any(t => t.kind == expected))
}

///|
test "GC declarative binary nested-self-reference" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1f\x01\x41\x03\x00\x5f\x01\x63\x00\x00\x00\x50\x02\x02\x10\x01\x01\x00\x03\x01\x67\x03\x63\x00\x00\x03\x00\x01\x6d\x00\x11\x01\x0a\x06\x01\x00\x01\x63\x04\x00\x0b\x07\x01\x00\x01\x63\x04\x00\x00\x00\x1e\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x05\x03\x01\x00\x01\x63\x01\x06\x04\x01\x00\x02\x63\x30",
  )
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (type $c (component (core type $s (struct (field (ref null 0)))) (core type $m (module (alias outer 1 $s (type $local)) (export \"g\" (global (ref null 0))))) (import \"m\" (core module (type $m))))) (import \"c\" (component $c0 (type $c))) (export \"c\" (component $c0)))\n",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(result.unwrap()),
    binary_projection(text.unwrap()),
  )
  let expected = @verifier.TypeKind::Module(gc_declaration_contract(2))
  assert_true(result.unwrap().types().any(t => t.kind == expected))
}

///|
test "GC declarative binary module-local-recursive" {
  let result = @verifier.decode_component_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x03\x16\x01\x50\x02\x01\x4e\x02\x5f\x01\x63\x01\x00\x5e\x63\x00\x00\x03\x01\x67\x03\x63\x01\x00\x0a\x07\x01\x00\x01\x6d\x00\x11\x00\x0b\x08\x01\x00\x01\x6d\x00\x11\x00\x00\x00\x20\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x06\x00\x10\x01\x00\x01\x6d\x01\x07\x00\x11\x01\x00\x02\x6d\x30",
  )
  assert_true(
    result is Ok(_),
    msg=match result {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  let text = @verifier.decode_wat_component_package(
    "(component (core type $m (module (rec (type $s (struct (field (ref null 1)))) (type $a (array (ref null 0)))) (export \"g\" (global (ref null 1))))) (import \"m\" (core module $m0 (type $m))) (export \"m\" (core module $m0)))\n",
  )
  assert_true(
    text is Ok(_),
    msg=match text {
      Ok(_) => "accepted"
      Err(e) => e[0].render()
    },
  )
  assert_eq(
    binary_projection(result.unwrap()),
    binary_projection(text.unwrap()),
  )
  let expected = @verifier.TypeKind::Module(gc_declaration_contract(0))
  assert_true(result.unwrap().types().any(t => t.kind == expected))
}

///|
fn gc_declaration_contract(mode : Int32) -> @core_types.Module {
  let graph : ReadOnlyArray[@core_types.HeapDefinition] = if mode == 1 {
    [
      {
        final_: true,
        shared: false,
        supertype: None,
        group_start: 0,
        group_size: 1,
        composite: Struct([{ storage: Value(Number("i32")), mutable: false, }]),
      },
      {
        final_: true,
        shared: false,
        supertype: None,
        group_start: 1,
        group_size: 1,
        composite: Function([Ref(true, false, 0)], []),
      },
    ]
  } else if mode == 2 {
    [
      {
        final_: true,
        shared: false,
        supertype: None,
        group_start: 0,
        group_size: 1,
        composite: Struct([
          { storage: Value(Ref(true, false, 0)), mutable: false, },
        ]),
      },
    ]
  } else {
    [
      {
        final_: true,
        shared: false,
        supertype: None,
        group_start: 0,
        group_size: 2,
        composite: Struct([
          { storage: Value(Ref(true, false, 1)), mutable: false, },
        ]),
      },
      {
        final_: true,
        shared: false,
        supertype: None,
        group_start: 0,
        group_size: 2,
        composite: Array({
          storage: Value(Ref(true, false, 0)),
          mutable: false,
        }),
      },
    ]
  }
  let kind : @core_types.External = if mode == 1 {
    TypedFunc({ types: graph, index: 1, })
  } else {
    Global(
      Concrete(true, { types: graph, index: if mode == 2 { 0 } else { 1 }, }),
      false,
      false,
    )
  }
  {
    imports: [],
    exports: [{ name: if mode == 1 { "f" } else { "g" }, kind, }],
  }
}
