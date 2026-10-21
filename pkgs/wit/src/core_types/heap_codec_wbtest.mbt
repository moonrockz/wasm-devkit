///|
fn struct_global_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x05\x01\x5f\x01\x7f\x00\x02\x09\x01\x01\x6d\x01\x67\x03\x63\x00\x00\x07\x05\x01\x01\x67\x03\x00"
}

///|
fn renumbered_struct_global_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x08\x02\x60\x00\x00\x5f\x01\x7f\x00\x02\x09\x01\x01\x6d\x01\x67\x03\x63\x01\x00\x07\x05\x01\x01\x67\x03\x00"
}

///|
fn shared_struct_global_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x65\x5f\x01\x7f\x00\x02\x09\x01\x01\x6d\x01\x67\x03\x63\x00\x02\x07\x05\x01\x01\x67\x03\x00"
}

///|
fn recursive_struct_global_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x5f\x01\x63\x00\x00\x02\x09\x01\x01\x6d\x01\x67\x03\x63\x00\x00\x07\x05\x01\x01\x67\x03\x00"
}

///|
fn recursive_function_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x60\x01\x63\x00\x00\x02\x07\x01\x01\x6d\x01\x66\x00\x00\x07\x05\x01\x01\x66\x00\x00"
}

///|
fn declared_subtype_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x10\x02\x50\x00\x5f\x01\x7f\x00\x50\x01\x00\x5f\x02\x7f\x00\x7e\x00\x02\x09\x01\x01\x6d\x01\x67\x03\x63\x01\x00\x07\x05\x01\x01\x67\x03\x00\x00\x0e\x04\x6e\x61\x6d\x65\x04\x07\x02\x00\x01\x73\x01\x01\x74"
}

///|
test "concrete module contracts retain complete immutable heap definitions" {
  let contract = decode_module(struct_global_bytes()).unwrap()
  guard contract.exports[0].kind
    is Global(Concrete(nullable, identity), false, false) else {
    fail("expected concrete global")
  }
  assert_true(nullable)
  assert_eq(identity.index, 0)
  assert_eq(identity.types.length(), 1)
  assert_eq(identity.types[0].group_start, 0)
  assert_eq(identity.types[0].group_size, 1)
  assert_eq(
    identity.types[0].composite,
    Struct([{ storage: Value(Number("i32")), mutable: false, }]),
  )
  let recursive = decode_module(recursive_struct_global_bytes()).unwrap()
  guard recursive.exports[0].kind is Global(Concrete(_, recursive), _, _) else {
    fail("expected recursive global")
  }
  assert_eq(
    recursive.types[0].composite,
    Struct([{ storage: Value(Ref(true, false, 0)), mutable: false, }]),
  )
}

///|
test "public core comparison follows recursive graph identity independent of numbering" {
  let a = decode_module(struct_global_bytes()).unwrap()
  let b = decode_module(renumbered_struct_global_bytes()).unwrap()
  assert_true(check_module_subtype(a, b) is Ok(_))
  assert_true(check_module_subtype(b, a) is Ok(_))
  let shared = decode_module(shared_struct_global_bytes()).unwrap()
  guard shared.exports[0].kind is Global(Concrete(_, identity), false, true) else {
    fail("expected shared concrete global")
  }
  assert_true(identity.types[0].shared)
  assert_true(check_module_subtype(a, shared) is Err(Mismatch(_)))
  assert_true(check_module_subtype(shared, a) is Err(Mismatch(_)))
  assert_eq(check_module_subtype(a, b, work_limit=3), Err(WorkLimit))
}

///|
test "function externs retain their recursive type identity" {
  let contract = decode_module(recursive_function_bytes()).unwrap()
  guard contract.exports[0].kind is TypedFunc(identity) else {
    fail("expected typed function")
  }
  assert_eq(identity.index, 0)
  assert_eq(identity.types[0].composite, Function([Ref(true, false, 0)], []))
  assert_true(
    check_external_subtype(contract.exports[0].kind, contract.exports[0].kind)
    is Ok(_),
  )
}

///|
test "public core identity comparison follows declared supertypes" {
  let contract = decode_module(declared_subtype_bytes()).unwrap()
  guard contract.exports[0].kind is Global(Concrete(_, subtype), _, _) else {
    fail("expected subtype global")
  }
  let supertype : TypeIdentity = { ..subtype, index: 0, }
  assert_eq(subtype.types[1].supertype, Some(0))
  assert_true(check_type_subtype(subtype, supertype) is Ok(_))
  assert_true(check_type_subtype(supertype, subtype) is Err(Mismatch(_)))
}

///|
test "caller-built malformed graph indices reject instead of panicking" {
  let invalid : TypeIdentity = {
    types: [
      {
        final_: true,
        shared: false,
        supertype: None,
        group_start: 0,
        group_size: 1,
        composite: Function([Ref(true, false, 2)], []),
      },
    ],
    index: 0,
  }
  assert_true(check_type_subtype(invalid, invalid) is Err(Mismatch(_)))
  assert_eq(check_type_subtype(invalid, invalid, work_limit=0), Err(WorkLimit))
}

///|
test "recursive declarations expand every lexical type index" {
  let bytes = b"\x4e\x02\x5f\x01\x63\x01\x00\x5e\x63\x00\x00"
  assert_eq(scan_type(bytes, 0, bytes.length()), Ok(bytes.length()))
  let definitions = decode_declarations(bytes).unwrap()
  assert_eq(definitions.length(), 2)
  guard definitions[0] is Heap(a) && definitions[1] is Heap(b) else {
    fail("expected recursive heap definitions")
  }
  assert_eq(a.index, 0)
  assert_eq(b.index, 1)
  assert_eq(a.types, b.types)
  assert_eq(a.types[0].group_size, 2)
  assert_eq(
    a.types[0].composite,
    Struct([{ storage: Value(Ref(true, false, 1)), mutable: false, }]),
  )
  assert_eq(
    a.types[1].composite,
    Array({ storage: Value(Ref(true, false, 0)), mutable: false, }),
  )
  assert_true(decode_type(bytes) is Err({ kind: Invalid, .. }))
}

///|
test "module-local aliases preserve outer recursive groups and remap lexical indices" {
  let root = decode_declarations(
    b"\x4e\x02\x5f\x01\x63\x01\x00\x5e\x63\x00\x00",
  ).unwrap()
  // Alias outer struct and array, then export a global naming the local array alias.
  let module_type = b"\x50\x03\x02\x10\x01\x01\x00\x02\x10\x01\x01\x01\x03\x01g\x03\x63\x01\x00"
  let definition = decode_type(module_type, current=root).unwrap()
  guard definition is Module(module_) else { fail("expected module type") }
  guard module_.exports[0].kind
    is Global(Concrete(true, identity), false, false) else {
    fail("expected concrete alias")
  }
  assert_eq(identity.index, 1)
  assert_eq(identity.types.length(), 2)
  assert_eq(identity.types[1].group_start, 0)
  assert_eq(identity.types[1].group_size, 2)
}

///|
test "declarative heap validation rejects illegal references and subtype declarations" {
  for
    bytes in [
      b"\x5f\x01\x63\x01\x00", // Unknown forward reference.
       b"\x65\x5f\x01\x6e\x00", // Unshared anyref inside a shared struct.
       b"\x4e\x02\x5f\x00\x50\x01\x00\x5f\x00", // Extends a final struct.
       b"\x4e\x02\x50\x00\x5f\x01\x7f\x00\x50\x01\x00\x5f\x00", // Removes an inherited field.
       b"\x60\x01\x63\xf0\x7f\x00", // Padded abstract heap code.
    ] {
    assert_true(decode_declarations(bytes) is Err(_))
  }
}

///|
test "declarative subtype depth accepts 63 and rejects 64" {
  for count in [64, 65] {
    let bytes : Array[Byte] = [b'\x4e', count.to_byte()]
    for index in 0..<count {
      bytes.push(b'\x50')
      bytes.push(if index == 0 { b'\x00' } else { b'\x01' })
      if index > 0 {
        bytes.push((index - 1).to_byte())
      }
      bytes.push(b'\x5f')
      bytes.push(b'\x00')
    }
    let result = decode_declarations(Bytes::from_array(bytes))
    if count == 64 {
      assert_eq(result.unwrap().length(), 64)
    } else {
      assert_true(result is Err({ kind: Invalid, .. }))
    }
  }
}

///|
test "mismatching graph comparisons still report the consumed work" {
  let a = decode_module(struct_global_bytes()).unwrap().exports[0].kind
  let b = decode_module(recursive_struct_global_bytes()).unwrap().exports[0].kind
  guard compare_external(a, b, work_limit=1000) is Ok((matched, remaining)) else {
    fail("comparison unexpectedly exhausted")
  }
  assert_false(matched)
  assert_true(remaining > 0 && remaining < 1000)
  assert_eq(compare_external(a, b, work_limit=0), Err(WorkLimit))
}

///|
test "plain and explicit function identities use the same nominal comparison" {
  let function : Function = { params: [Scalar("i32")], results: [], }
  let identity : TypeIdentity = {
    types: [
      {
        final_: true,
        shared: false,
        supertype: None,
        group_start: 0,
        group_size: 1,
        composite: Function([Number("i32")], []),
      },
    ],
    index: 0,
  }
  assert_true(
    check_external_subtype(Func(function), TypedFunc(identity)) is Ok(_),
  )
  assert_true(
    check_external_subtype(TypedFunc(identity), Func(function)) is Ok(_),
  )
  let shared = { ..identity, types: [{ ..identity.types[0], shared: true, }], }
  assert_true(
    check_external_subtype(TypedFunc(shared), Func(function))
    is Err(Mismatch(_)),
  )
}
