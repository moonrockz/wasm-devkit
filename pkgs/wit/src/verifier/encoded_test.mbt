///|
// Original fixture encoded with wasm-tools 1.262.0, e22db44da4eaf17a0e46ec55b911c7539589a3cc.
fn encoded_fixture() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x4b\x01\x41\x02\x01\x42\x06\x01\x79\x04\x00\x02\x69\x64\x03\x00\x00\x01\x72\x01\x02\x69\x64\x01\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x02\x01\x40\x01\x01\x78\x03\x00\x73\x04\x00\x03\x72\x75\x6e\x01\x04\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\xb0\x01\x01\x41\x02\x01\x41\x04\x01\x42\x06\x01\x79\x04\x00\x02\x69\x64\x03\x00\x00\x01\x72\x01\x02\x69\x64\x01\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x02\x01\x40\x01\x01\x78\x03\x00\x73\x04\x00\x03\x72\x75\x6e\x01\x04\x03\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x42\x06\x01\x79\x04\x00\x02\x69\x64\x03\x00\x00\x01\x72\x01\x02\x69\x64\x01\x04\x00\x04\x69\x74\x65\x6d\x03\x00\x02\x01\x40\x01\x01\x78\x03\x00\x73\x04\x00\x03\x72\x75\x6e\x01\x04\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x01\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30"
}

///|
fn encoded_source() -> @verifier.SourcePackage {
  {
    documents: [
      section_document(
        "dep.wit", "package example:dep@1.0.0;interface api{type id=u32;record item{id:id}run:func(x:item)->string;}world app{import api;export api;}",
      ),
    ],
  }
}

///|
test "encoded package root matches source semantics and retains only binary provenance" {
  let bytes = encoded_fixture()
  let package_input = @verifier.decode_package(bytes, source_id="dep.wasm").unwrap()
  assert_eq(package_input.bytes(), bytes)
  assert_eq(package_input.source(), "dep.wasm")
  let binary = @verifier.resolve_packages(Encoded(package_input)).unwrap()
  let source = @verifier.resolve(encoded_source()).unwrap()
  assert_eq(binary.root(), source.root())
  assert_eq(binary.world_summary(), source.world_summary())
  assert_eq(
    binary.types().map(ty => (ty.name, ty.kind)),
    source
    .types()
    .map(ty => {
      let kind : @verifier.TypeKind = match ty.kind {
        Record(fields) =>
          Record(
            fields.map(field => {
              ..field,
              location: @verifier.Location::binary("dep.wasm"),
            }),
          )
        kind => kind
      }
      (ty.name, kind)
    }),
  )
  assert_eq(
    binary
    .functions()
    .map(function => (function.name, function.kind, function.result)),
    source
    .functions()
    .map(function => (function.name, function.kind, function.result)),
  )
  assert_eq(binary.sources().length(), 0)
  assert_eq(binary.binaries().length(), 1)
  assert_eq(binary.binaries()[0].bytes(), bytes)
  for ty in binary.types() {
    assert_eq(ty.location.position, BinaryOffset(None))
    let origin = binary.origin(ty.id).unwrap()
    assert_eq(origin.node, None)
    assert_eq(origin.location, ty.location)
    if ty.kind is Record(fields) {
      assert_true(
        fields.all(field => field.location.position == BinaryOffset(None)),
      )
    }
  }
  for interface_info in binary.interfaces() {
    assert_eq(interface_info.location.position, BinaryOffset(None))
    assert_true(
      interface_info.types.all(member_info => {
        member_info.location.position == BinaryOffset(None)
      }),
    )
    for function in interface_info.functions {
      assert_eq(function.location.position, BinaryOffset(None))
      assert_true(
        function.params.all(parameter => {
          parameter.location.position == BinaryOffset(None)
        }),
      )
    }
  }
  for world in binary.worlds() {
    assert_eq(world.location.position, BinaryOffset(None))
    assert_true(
      world.imports.all(item => item.location.position == BinaryOffset(None)),
    )
    assert_true(
      world.exports.all(item => item.location.position == BinaryOffset(None)),
    )
  }
}

///|
test "source roots resolve encoded dependencies and preserve original source documents" {
  let root = @verifier.SourcePackage::{
    documents: [
      section_document(
        "app.wit", "package example:app;world app{import example:dep/api@1.0.0;}",
      ),
    ],
  }
  let encoded = @verifier.decode_package(
    encoded_fixture(),
    source_id="dep.wasm",
  ).unwrap()
  let binary = @verifier.resolve_packages(Source(root), dependencies=[
    Encoded(encoded),
  ]).unwrap()
  let source = @verifier.resolve(root, dependencies=[encoded_source()]).unwrap()
  assert_eq(binary.world_summary(), source.world_summary())
  assert_eq(binary.identities(), source.identities())
  assert_eq(binary.sources().length(), 1)
  assert_eq(binary.sources()[0].id, root.documents[0].id)
  assert_eq(binary.sources()[0].text, root.documents[0].text)
  assert_true(binary.sources()[0].ast.equivalent(root.documents[0].ast))
  for interface_info in binary.interfaces() {
    assert_eq(interface_info.location.source, "dep.wasm")
    assert_eq(interface_info.location.position, BinaryOffset(None))
  }
  assert_eq(binary.worlds()[0].location.source, "app.wit")
  assert_true(binary.worlds()[0].location.span() is Some(_))
}

///|
test "binary lowering never escapes through errors or missing world selection" {
  let encoded = @verifier.decode_package(
    encoded_fixture(),
    source_id="dep.wasm",
  ).unwrap()
  let resolved = @verifier.resolve_packages(Encoded(encoded)).unwrap()
  let errors = resolved.select_world(name=Some("missing")).unwrap_err()
  assert_true(
    errors.all(error => error.primary.location.position == BinaryOffset(None)),
  )
  let missing = @verifier.SourcePackage::{
    documents: [
      section_document(
        "app.wit", "package example:app;interface api{use example:dep/api@1.0.0.{absent};}",
      ),
    ],
  }
  let errors = @verifier.resolve_packages(Source(missing), dependencies=[
    Encoded(encoded),
  ]).unwrap_err()
  assert_true(errors.all(error => error.primary.location.source == "app.wit"))
  assert_true(
    errors.all(error => {
      error.related.all(label => {
        label.location.source != "dep.wasm" ||
        label.location.position == BinaryOffset(None)
      })
    }),
  )
}

///|
test "decoding is deterministic and rejects a validated empty component" {
  let errors = @verifier.decode_package(
    b"\x00asm\x0d\x00\x01\x00",
    source_id="empty.wasm",
  ).unwrap_err()
  assert_eq(errors[0].code, "WIT-B004")
  assert_eq(errors[0].primary.location.position, BinaryOffset(None))
  for end in 0..<encoded_fixture().length() {
    let bytes = encoded_fixture()[0:end].to_owned()
    let first = @verifier.decode_package(bytes, source_id="prefix.wasm")
    match first {
      Err(errors) =>
        assert_eq(
          @verifier.decode_package(bytes, source_id="prefix.wasm").unwrap_err(),
          errors,
        )
      Ok(package_input) =>
        assert_eq(package_input.identity().key(), "example:dep@1.0.0")
    }
  }
}

///|
test "WAT and binary package loading produce the same model without fictitious WAT offsets" {
  let text = "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (type (;0;) u32)\n          (export (;1;) \"id\" (type (eq 0)))\n          (type (;2;) (record (field \"id\" 1)))\n          (export (;3;) \"item\" (type (eq 2)))\n          (type (;4;) (func (param \"x\" 3) (result string)))\n          (export (;0;) \"run\" (func (type 4)))\n        )\n      )\n      (export (;0;) \"example:dep/api@1.0.0\" (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) u32)\n              (export (;1;) \"id\" (type (eq 0)))\n              (type (;2;) (record (field \"id\" 1)))\n              (export (;3;) \"item\" (type (eq 2)))\n              (type (;4;) (func (param \"x\" 3) (result string)))\n              (export (;0;) \"run\" (func (type 4)))\n            )\n          )\n          (import \"example:dep/api@1.0.0\" (instance (;0;) (type 0)))\n          (type (;1;)\n            (instance\n              (type (;0;) u32)\n              (export (;1;) \"id\" (type (eq 0)))\n              (type (;2;) (record (field \"id\" 1)))\n              (export (;3;) \"item\" (type (eq 2)))\n              (type (;4;) (func (param \"x\" 3) (result string)))\n              (export (;0;) \"run\" (func (type 4)))\n            )\n          )\n          (export (;1;) \"example:dep/api@1.0.0\" (instance (type 1)))\n        )\n      )\n      (export (;0;) \"example:dep/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n)"
  let input = @verifier.decode_wat_package(text, source_id="dep.wat").unwrap()
  let model = @verifier.resolve_packages(Encoded(input)).unwrap()
  assert_eq(
    model.world_summary(),
    @verifier.resolve(encoded_source()).unwrap().world_summary(),
  )
  assert_eq(model.sources().length(), 0)
  assert_true(
    model
    .types()
    .all(ty => {
      ty.location.source == "dep.wat" &&
      ty.location.position == BinaryOffset(None)
    }),
  )
  for
    malformed in [
      "(component", "(component (type (func (param \"x\" 99))))", "(component (; unclosed",
    ] {
    let errors = @verifier.decode_wat_package(malformed, source_id="bad.wat").unwrap_err()
    assert_true(
      errors.all(error => error.primary.location.position == BinaryOffset(None)),
    )
  }
  assert_eq(
    @verifier.decode_wat_package(
      "(component (@custom \"package-docs\" \"\\01{}\"))",
    ).unwrap_err()[0].code,
    "WIT-B002",
  )
  let deep = "(component" + " (".repeat(10000) + ")".repeat(10001)
  assert_eq(@verifier.decode_wat_package(deep).unwrap_err()[0].code, "WIT-B002")
}

///|
test "encoded composites async functions resource aliases and inline worlds retain identities" {
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\xa6\x03\x01\x41\x02\x01\x42\x29\x01\x79\x04\x00\x06\x73\x63\x61\x6c\x61\x72\x03\x00\x00\x04\x00\x05\x61\x6c\x69\x61\x73\x03\x00\x01\x01\x70\x7d\x04\x00\x05\x62\x79\x74\x65\x73\x03\x00\x03\x01\x67\x7d\x04\x04\x00\x05\x66\x69\x78\x65\x64\x03\x00\x05\x01\x6f\x02\x7d\x73\x04\x00\x04\x70\x61\x69\x72\x03\x00\x07\x01\x6b\x08\x04\x00\x05\x6d\x61\x79\x62\x65\x03\x00\x09\x01\x6a\x01\x08\x01\x73\x04\x00\x06\x61\x6e\x73\x77\x65\x72\x03\x00\x0b\x01\x6a\x00\x01\x73\x04\x00\x05\x6e\x6f\x2d\x6f\x6b\x03\x00\x0d\x01\x6a\x01\x08\x00\x04\x00\x06\x6e\x6f\x2d\x65\x72\x72\x03\x00\x0f\x01\x6a\x00\x00\x04\x00\x0c\x65\x6d\x70\x74\x79\x2d\x72\x65\x73\x75\x6c\x74\x03\x00\x11\x01\x65\x01\x04\x04\x00\x05\x6c\x61\x74\x65\x72\x03\x00\x13\x01\x65\x00\x04\x00\x0a\x6c\x61\x74\x65\x72\x2d\x6e\x6f\x6e\x65\x03\x00\x15\x01\x66\x01\x01\x04\x00\x04\x66\x6c\x6f\x77\x03\x00\x17\x01\x66\x00\x04\x00\x09\x66\x6c\x6f\x77\x2d\x6e\x6f\x6e\x65\x03\x00\x19\x01\x63\x73\x04\x04\x00\x05\x74\x61\x62\x6c\x65\x03\x00\x1b\x01\x6e\x02\x01\x61\x01\x62\x04\x00\x07\x6f\x70\x74\x69\x6f\x6e\x73\x03\x00\x1d\x01\x6d\x02\x04\x6c\x65\x66\x74\x05\x72\x69\x67\x68\x74\x04\x00\x04\x73\x69\x64\x65\x03\x00\x1f\x01\x71\x03\x05\x65\x6d\x70\x74\x79\x00\x00\x06\x6e\x75\x6d\x62\x65\x72\x01\x79\x00\x04\x70\x61\x69\x72\x01\x08\x00\x04\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x21\x04\x00\x05\x74\x6f\x6b\x65\x6e\x03\x01\x04\x00\x0b\x61\x6c\x69\x61\x73\x2d\x74\x6f\x6b\x65\x6e\x03\x00\x23\x01\x69\x23\x01\x68\x23\x01\x43\x03\x05\x74\x6f\x6b\x65\x6e\x25\x04\x76\x69\x65\x77\x26\x05\x76\x61\x6c\x75\x65\x22\x00\x0c\x04\x00\x04\x74\x61\x6b\x65\x01\x27\x04\x00\x17\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x79\x70\x65\x73\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\x9d\x07\x01\x41\x02\x01\x41\x08\x01\x42\x29\x01\x79\x04\x00\x06\x73\x63\x61\x6c\x61\x72\x03\x00\x00\x04\x00\x05\x61\x6c\x69\x61\x73\x03\x00\x01\x01\x70\x7d\x04\x00\x05\x62\x79\x74\x65\x73\x03\x00\x03\x01\x67\x7d\x04\x04\x00\x05\x66\x69\x78\x65\x64\x03\x00\x05\x01\x6f\x02\x7d\x73\x04\x00\x04\x70\x61\x69\x72\x03\x00\x07\x01\x6b\x08\x04\x00\x05\x6d\x61\x79\x62\x65\x03\x00\x09\x01\x6a\x01\x08\x01\x73\x04\x00\x06\x61\x6e\x73\x77\x65\x72\x03\x00\x0b\x01\x6a\x00\x01\x73\x04\x00\x05\x6e\x6f\x2d\x6f\x6b\x03\x00\x0d\x01\x6a\x01\x08\x00\x04\x00\x06\x6e\x6f\x2d\x65\x72\x72\x03\x00\x0f\x01\x6a\x00\x00\x04\x00\x0c\x65\x6d\x70\x74\x79\x2d\x72\x65\x73\x75\x6c\x74\x03\x00\x11\x01\x65\x01\x04\x04\x00\x05\x6c\x61\x74\x65\x72\x03\x00\x13\x01\x65\x00\x04\x00\x0a\x6c\x61\x74\x65\x72\x2d\x6e\x6f\x6e\x65\x03\x00\x15\x01\x66\x01\x01\x04\x00\x04\x66\x6c\x6f\x77\x03\x00\x17\x01\x66\x00\x04\x00\x09\x66\x6c\x6f\x77\x2d\x6e\x6f\x6e\x65\x03\x00\x19\x01\x63\x73\x04\x04\x00\x05\x74\x61\x62\x6c\x65\x03\x00\x1b\x01\x6e\x02\x01\x61\x01\x62\x04\x00\x07\x6f\x70\x74\x69\x6f\x6e\x73\x03\x00\x1d\x01\x6d\x02\x04\x6c\x65\x66\x74\x05\x72\x69\x67\x68\x74\x04\x00\x04\x73\x69\x64\x65\x03\x00\x1f\x01\x71\x03\x05\x65\x6d\x70\x74\x79\x00\x00\x06\x6e\x75\x6d\x62\x65\x72\x01\x79\x00\x04\x70\x61\x69\x72\x01\x08\x00\x04\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x21\x04\x00\x05\x74\x6f\x6b\x65\x6e\x03\x01\x04\x00\x0b\x61\x6c\x69\x61\x73\x2d\x74\x6f\x6b\x65\x6e\x03\x00\x23\x01\x69\x23\x01\x68\x23\x01\x43\x03\x05\x74\x6f\x6b\x65\x6e\x25\x04\x76\x69\x65\x77\x26\x05\x76\x61\x6c\x75\x65\x22\x00\x0c\x04\x00\x04\x74\x61\x6b\x65\x01\x27\x03\x00\x17\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x79\x70\x65\x73\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x00\x01\x42\x04\x04\x00\x04\x69\x74\x65\x6d\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x03\x67\x65\x74\x01\x02\x03\x00\x04\x68\x6f\x73\x74\x05\x01\x01\x40\x01\x01\x78\x73\x00\x79\x04\x00\x03\x72\x75\x6e\x01\x02\x01\x42\x29\x01\x79\x04\x00\x06\x73\x63\x61\x6c\x61\x72\x03\x00\x00\x04\x00\x05\x61\x6c\x69\x61\x73\x03\x00\x01\x01\x70\x7d\x04\x00\x05\x62\x79\x74\x65\x73\x03\x00\x03\x01\x67\x7d\x04\x04\x00\x05\x66\x69\x78\x65\x64\x03\x00\x05\x01\x6f\x02\x7d\x73\x04\x00\x04\x70\x61\x69\x72\x03\x00\x07\x01\x6b\x08\x04\x00\x05\x6d\x61\x79\x62\x65\x03\x00\x09\x01\x6a\x01\x08\x01\x73\x04\x00\x06\x61\x6e\x73\x77\x65\x72\x03\x00\x0b\x01\x6a\x00\x01\x73\x04\x00\x05\x6e\x6f\x2d\x6f\x6b\x03\x00\x0d\x01\x6a\x01\x08\x00\x04\x00\x06\x6e\x6f\x2d\x65\x72\x72\x03\x00\x0f\x01\x6a\x00\x00\x04\x00\x0c\x65\x6d\x70\x74\x79\x2d\x72\x65\x73\x75\x6c\x74\x03\x00\x11\x01\x65\x01\x04\x04\x00\x05\x6c\x61\x74\x65\x72\x03\x00\x13\x01\x65\x00\x04\x00\x0a\x6c\x61\x74\x65\x72\x2d\x6e\x6f\x6e\x65\x03\x00\x15\x01\x66\x01\x01\x04\x00\x04\x66\x6c\x6f\x77\x03\x00\x17\x01\x66\x00\x04\x00\x09\x66\x6c\x6f\x77\x2d\x6e\x6f\x6e\x65\x03\x00\x19\x01\x63\x73\x04\x04\x00\x05\x74\x61\x62\x6c\x65\x03\x00\x1b\x01\x6e\x02\x01\x61\x01\x62\x04\x00\x07\x6f\x70\x74\x69\x6f\x6e\x73\x03\x00\x1d\x01\x6d\x02\x04\x6c\x65\x66\x74\x05\x72\x69\x67\x68\x74\x04\x00\x04\x73\x69\x64\x65\x03\x00\x1f\x01\x71\x03\x05\x65\x6d\x70\x74\x79\x00\x00\x06\x6e\x75\x6d\x62\x65\x72\x01\x79\x00\x04\x70\x61\x69\x72\x01\x08\x00\x04\x00\x05\x76\x61\x6c\x75\x65\x03\x00\x21\x04\x00\x05\x74\x6f\x6b\x65\x6e\x03\x01\x04\x00\x0b\x61\x6c\x69\x61\x73\x2d\x74\x6f\x6b\x65\x6e\x03\x00\x23\x01\x69\x23\x01\x68\x23\x01\x43\x03\x05\x74\x6f\x6b\x65\x6e\x25\x04\x76\x69\x65\x77\x26\x05\x76\x61\x6c\x75\x65\x22\x00\x0c\x04\x00\x04\x74\x61\x6b\x65\x01\x27\x04\x00\x17\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x79\x70\x65\x73\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x03\x04\x00\x17\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x79\x70\x65\x73\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30"
  let package_input = @verifier.decode_package(bytes).unwrap()
  let model = @verifier.resolve_packages(Encoded(package_input)).unwrap()
  assert_eq(model.interfaces()[0].types.length(), 20)
  let token = model.types().filter(ty => ty.name == Some("token"))[0]
  let alias_type = model.types().filter(ty => ty.name == Some("alias-token"))[0]
  let mut target = alias_type.id
  for _ in 0..<model.types().length() {
    let ty = model.types().filter(ty => ty.id == target)[0]
    if ty.kind is Alias(next) {
      target = next
    } else {
      break
    }
  }
  assert_eq(target, token.id)
  let take = model.functions().filter(function => function.name == "take")[0]
  assert_true(take.asynchronous)
  assert_eq(take.kind, Freestanding)
  assert_eq(take.params.length(), 3)
  let own = model.types().filter(ty => ty.id == take.params[0].ty)[0]
  let borrow = model.types().filter(ty => ty.id == take.params[1].ty)[0]
  assert_eq(own.kind, Own(token.id))
  assert_eq(borrow.kind, Borrow(token.id))
  let text = "package example:types@1.0.0;\ninterface api {\n  type scalar = u32;\n  type alias = scalar;\n  type bytes = list<u8>;\n  type fixed = list<u8, 4>;\n  type pair = tuple<u8, string>;\n  type maybe = option<pair>;\n  type answer = result<pair, string>;\n  type no-ok = result<_, string>;\n  type no-err = result<pair>;\n  type empty-result = result;\n  type later = future<bytes>;\n  type later-none = future;\n  type flow = stream<scalar>;\n  type flow-none = stream;\n  type table = map<string, bytes>;\n  flags options { a, b }\n  enum side { left, right }\n  variant value { empty, number(u32), pair(pair) }\n  resource token;\n  type alias-token = token;\n  take: async func(token: own<token>, view: borrow<token>, value: value) -> answer;\n}\nworld app {\n  import api;\n  export api;\n  import host: interface { resource item; get: func() -> item; }\n  export run: func(x: string) -> u32;\n}\n"
  let source = @verifier.resolve({
    documents: [section_document("types.wit", text)],
  }).unwrap()
  assert_eq(model.world_summary(), source.world_summary())
  assert_true(model.types().any(ty => ty.kind is List(_, Some(4))))
  assert_true(model.types().any(ty => ty.kind is Map(_, _)))
  assert_true(model.types().any(ty => ty.kind is Future(None)))
  assert_true(model.types().any(ty => ty.kind is Stream(None)))
  assert_true(
    model.types().any(ty => ty.kind is Variant(cases) && cases.length() == 3),
  )
}

///|
test "custom metadata rejects duplicates and nonempty payloads without normalizing section names" {
  // A BOM belongs to this custom section's name, so it is not package-docs.
  let custom = b"\x00\x13\x0f\xef\xbb\xbfpackage-docs\x01{}"
  let bytes = Bytes::from_array(
    encoded_fixture().iter().concat(custom.iter()).to_array(),
  )
  let input = @verifier.decode_package(bytes).unwrap()
  assert_true(@verifier.resolve_packages(Encoded(input)) is Ok(_))
  let duplicate = b"\x00\x10\x0cpackage-docs\x01{}"
  let bytes = Bytes::from_array(
    encoded_fixture().iter().concat(duplicate.iter()).to_array(),
  )
  assert_eq(@verifier.decode_package(bytes).unwrap_err()[0].code, "WIT-B004")
  // Replace the existing package-docs section with a nonempty metadata object.
  let custom = b"\x00\x1a\x0cpackage-docs\x01{\"docs\":\"x\"}"
  let bytes = Bytes::from_array(
    encoded_fixture()[0:286].iter().concat(custom.iter()).to_array(),
  )
  assert_true(@verifier.decode_package(bytes) is Ok(_))
}
