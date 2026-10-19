///|
fn package_unsigned(out : Array[Byte], value : Int32) -> Unit {
  let mut value = value
  while value >= 128 {
    out.push(((value & 127) | 128).to_byte())
    value = value >> 7
  }
  out.push(value.to_byte())
}

///|
fn package_section(section : Int32, payload : Array[Byte]) -> Bytes {
  let bytes : Array[Byte] = [0, 97, 115, 109, 13, 0, 1, 0, section.to_byte()]
  package_unsigned(bytes, payload.length())
  bytes.append(payload)
  Bytes::from_array(bytes)
}

///|
test "binary package resource alias chains are iterative and immutable" {
  let payload : Array[Byte] = []
  package_unsigned(payload, 5001)
  for i in 0..<5001 {
    payload.push(0)
    let name = @utf8.encode("r-\{i}")
    package_unsigned(payload, name.length())
    for byte in name {
      payload.push(byte)
    }
    payload.push(3)
    if i == 0 {
      payload.push(1)
    } else {
      payload.push(0)
      package_unsigned(payload, i - 1)
    }
  }
  let bytes = package_section(10, payload)
  let result = @verifier.decode_component_package(bytes, source_id="chain.wasm")
  guard result is Ok(model) else { fail(result.unwrap_err()[0].message) }
  guard model.types()[model.world()].kind is World(None, [], imports, []) else {
    fail("missing package world")
  }
  assert_eq(imports.length(), 5001)
  guard imports[0].kind is Type(first) && imports[5000].kind is Type(last) else {
    fail("resource imports lost their type sort")
  }
  assert_eq(model.resource_identity(last), Some(first))
  assert_eq(model.resource_identity(-1), None)
  assert_eq(model.resource_identity(model.types().length()), None)
  assert_eq(model.resource_identity(model.world()), None)
  assert_eq(model.source(), "chain.wasm")
  assert_eq(model.bytes(), bytes)
  let copy = model.types().map(ty => { ..ty, name: Some("changed"), })
  assert_eq(copy[first].name, Some("changed"))
  assert_eq(model.types()[first].name, Some("r-0"))
  let copied_imports = imports.map(item => { ..item, name: "changed", })
  assert_eq(copied_imports[0].name, "changed")
  assert_eq(imports[0].name, "r-0")
}

///|
test "binary package rejects physical nesting before parsing recursively" {
  let payload : Array[Byte] = [1]
  for _ in 0..<10000 {
    payload.append([0x41, 1, 1])
  }
  payload.push(0x79)
  guard @verifier.decode_component_package(package_section(7, payload))
    is Err([error]) else {
    fail("unbounded physical scope accepted")
  }
  assert_eq(error.code, "WAC-B002")
  guard error.primary.location.position is BinaryOffset(Some(offset)) else {
    fail("missing binary framing position")
  }
  assert_true(offset < 1000)
}

///|
test "binary package prefixes retain deterministic binary provenance" {
  let bytes = b"\x00asm\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01f\x01\x00\x0b\x07\x01\x00\x01f\x01\x00\x00"
  for end in 0..<=bytes.length() {
    let input = bytes[0:end].to_owned()
    let first = @verifier.decode_component_package(
      input,
      source_id="original.wasm",
    )
    let second = @verifier.decode_component_package(
      input,
      source_id="original.wasm",
    )
    match (first, second) {
      (Ok(first), Ok(second)) => {
        assert_eq(first.types(), second.types())
        assert_eq(first.bytes(), input)
        for ty in first.types() {
          assert_eq(ty.location.source, "original.wasm")
          assert_eq(ty.location.span(), None)
        }
      }
      (Err(first), Err(second)) => {
        assert_eq(first, second)
        for error in first {
          assert_eq(error.primary.location.source, "original.wasm")
          assert_eq(error.primary.location.span(), None)
        }
      }
      _ => fail("nondeterministic package decode")
    }
  }
}

///|
test "binary package malformed declarations are total" {
  @quickcheck.check(
    (payload : Array[Byte]) => {
      for section in [6, 7, 10, 11] {
        let bytes = package_section(section, payload)
        match
          @verifier.decode_component_package(bytes, source_id="mutated.wasm") {
          Ok(model) => if model.bytes() != bytes { return false }
          Err(errors) =>
            if !errors.all(error => {
                error.primary.location.source == "mutated.wasm" &&
                error.primary.location.span() is None
              }) {
              return false
            }
        }
      }
      true
    },
    count=200,
    max_size=128,
    seed=258120,
  )
}
