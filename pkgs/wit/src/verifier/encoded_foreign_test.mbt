///|
fn encoded_foreign_wat() -> String {
  "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"example:dep/base@2.0.0\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"run\" (func (type 5)))\n        )\n      )\n      (export (;1;) \"example:foreign/api@1.0.0\" (instance (type 3)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n              (type (;3;) (func (result string)))\n              (export (;0;) \"extra\" (func (type 3)))\n            )\n          )\n          (import \"example:dep/base@2.0.0\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"run\" (func (type 5)))\n            )\n          )\n          (import \"example:foreign/api@1.0.0\" (instance (;1;) (type 3)))\n        )\n      )\n      (export (;0;) \"example:foreign/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n"
}

///|
test "foreign encoded projections form one inferred closure" {
  let wat = encoded_foreign_wat()
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x8b\x01\x01\x41\x06\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x16\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x62\x61\x73\x65\x40\x32\x2e\x30\x2e\x30\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x02\x69\x64\x01\x42\x07\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x02\x69\x64\x03\x00\x02\x01\x68\x01\x01\x40\x01\x01\x78\x04\x00\x03\x04\x00\x03\x72\x75\x6e\x01\x05\x04\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x66\x6f\x72\x65\x69\x67\x6e\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x03\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\xbb\x01\x01\x41\x02\x01\x41\x06\x01\x42\x05\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x01\x40\x00\x00\x73\x04\x00\x05\x65\x78\x74\x72\x61\x01\x03\x03\x00\x16\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x62\x61\x73\x65\x40\x32\x2e\x30\x2e\x30\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x02\x69\x64\x01\x42\x07\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x02\x69\x64\x03\x00\x02\x01\x68\x01\x01\x40\x01\x01\x78\x04\x00\x03\x04\x00\x03\x72\x75\x6e\x01\x05\x03\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x66\x6f\x72\x65\x69\x67\x6e\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x03\x04\x00\x19\x65\x78\x61\x6d\x70\x6c\x65\x3a\x66\x6f\x72\x65\x69\x67\x6e\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30"
  let source = "package example:foreign@1.0.0;\ninterface api { use example:dep/base@2.0.0.{r,id}; run:func(x:borrow<r>)->id; }\nworld app { import api; }\npackage example:dep@2.0.0 { interface base { resource r; type id=u32; extra:func()->string; } }\n"
  let expected = @verifier.resolve({
    documents: [section_document("source.wit", source)],
  }).unwrap()
  for
    input in [
      @verifier.decode_package(bytes, source_id="dep.wasm").unwrap(),
      @verifier.decode_wat_package(wat, source_id="dep.wat").unwrap(),
    ] {
    let model = @verifier.resolve_packages(Encoded(input)).unwrap()
    assert_eq(model.world_summary(), expected.world_summary())
    assert_eq(
      encoded_alias_model(model, reachable_only=true),
      encoded_alias_model(expected, reachable_only=true),
    )
    assert_eq(model.sources().length(), 0)
    assert_eq(model.binaries().length(), 1)
  }
}

///|
test "inferred closure unions supplied interfaces and keeps source origins" {
  let input = @verifier.decode_wat_package(
    encoded_foreign_wat(),
    source_id="foreign.wat",
  ).unwrap()
  for
    body in [
      "resource r;", "resource r; type id=u32; extra:func()->string; other:func();",
    ] {
    let document = section_document(
      "supplied.wit",
      "package example:dep@2.0.0; interface base{" + body + "}",
    )
    let model = @verifier.resolve_packages(Encoded(input), dependencies=[
      Source({ documents: [document], }),
    ]).unwrap()
    assert_eq(model.sources().length(), 1)
    assert_eq(model.sources()[0].text, document.text)
    assert_eq(model.binaries().length(), 1)
    let base = model
      .interfaces()
      .iter()
      .filter(i => i.name == Some("base"))
      .to_array()[0]
    assert_eq(base.location.source, "supplied.wit")
    let r = base.types.iter().filter(t => t.name == "r").to_array()[0]
    assert_eq(
      model.types().iter().filter(t => t.id == r.ty).to_array()[0].location.source,
      "supplied.wit",
    )
    let origin = model.origin(r.ty).unwrap()
    assert_eq(origin.location.source, "supplied.wit")
    assert_true(
      document.ast.nodes[origin.node.unwrap()].data is Resource(name="r", ..),
    )
    assert_true(base.types.iter().any(t => t.name == "id"))
    assert_true(base.functions.iter().any(f => f.name == "extra"))
  }
}

///|
test "inferred closure checks overlapping function signatures" {
  let input = @verifier.decode_wat_package(
    encoded_foreign_wat(),
    source_id="foreign.wat",
  ).unwrap()
  for
    signature in [
      "func()->u32", "func(x:string)->string", "async func()->string",
    ] {
    let document = section_document(
      "supplied.wit",
      "package example:dep@2.0.0; interface base { extra:" + signature + "; }",
    )
    let errors = @verifier.resolve_packages(Encoded(input), dependencies=[
      Source({ documents: [document], }),
    ]).unwrap_err()
    assert_true(errors.iter().any(e => e.code == "WIT-B004"))
    assert_true(
      errors.iter().any(e => e.primary.location.source == "foreign.wat"),
    )
  }
}

///|
test "foreign projections preserve source binary and WAT graphs" {
  for
    (name, source, wat, bytes) in [
      (
        "distinct", "package example:distinct; interface api { use dep:one/first.{r as left}; use dep:two/second.{r as right}; f:func(x:borrow<left>,y:borrow<right>); } world app { import api; } package dep:one { interface first { resource r; } } package dep:two { interface second { resource r; } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n        )\n      )\n      (import \"dep:one/first\" (instance (;0;) (type 0)))\n      (type (;1;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n        )\n      )\n      (import \"dep:two/second\" (instance (;1;) (type 1)))\n      (alias export 0 \"r\" (type (;2;)))\n      (alias export 1 \"r\" (type (;3;)))\n      (type (;4;)\n        (instance\n          (alias outer 1 2 (type (;0;)))\n          (export (;1;) \"left\" (type (eq 0)))\n          (alias outer 1 3 (type (;2;)))\n          (export (;3;) \"right\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (borrow 3))\n          (type (;6;) (func (param \"x\" 4) (param \"y\" 5)))\n          (export (;0;) \"f\" (func (type 6)))\n        )\n      )\n      (export (;2;) \"example:distinct/api\" (instance (type 4)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n            )\n          )\n          (import \"dep:one/first\" (instance (;0;) (type 0)))\n          (type (;1;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n            )\n          )\n          (import \"dep:two/second\" (instance (;1;) (type 1)))\n          (alias export 0 \"r\" (type (;2;)))\n          (alias export 1 \"r\" (type (;3;)))\n          (type (;4;)\n            (instance\n              (alias outer 1 2 (type (;0;)))\n              (export (;1;) \"left\" (type (eq 0)))\n              (alias outer 1 3 (type (;2;)))\n              (export (;3;) \"right\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (borrow 3))\n              (type (;6;) (func (param \"x\" 4) (param \"y\" 5)))\n              (export (;0;) \"f\" (func (type 6)))\n            )\n          )\n          (import \"example:distinct/api\" (instance (;2;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:distinct/app\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x98\x01\x01\x41\x08\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0d\x64\x65\x70\x3a\x6f\x6e\x65\x2f\x66\x69\x72\x73\x74\x05\x00\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0e\x64\x65\x70\x3a\x74\x77\x6f\x2f\x73\x65\x63\x6f\x6e\x64\x05\x01\x02\x03\x00\x00\x01\x72\x02\x03\x00\x01\x01\x72\x01\x42\x08\x02\x03\x02\x01\x02\x04\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x02\x03\x02\x01\x03\x04\x00\x05\x72\x69\x67\x68\x74\x03\x00\x02\x01\x68\x01\x01\x68\x03\x01\x40\x02\x01\x78\x04\x01\x79\x05\x01\x00\x04\x00\x01\x66\x01\x06\x04\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x69\x73\x74\x69\x6e\x63\x74\x2f\x61\x70\x69\x05\x04\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\xb4\x01\x01\x41\x02\x01\x41\x08\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0d\x64\x65\x70\x3a\x6f\x6e\x65\x2f\x66\x69\x72\x73\x74\x05\x00\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0e\x64\x65\x70\x3a\x74\x77\x6f\x2f\x73\x65\x63\x6f\x6e\x64\x05\x01\x02\x03\x00\x00\x01\x72\x02\x03\x00\x01\x01\x72\x01\x42\x08\x02\x03\x02\x01\x02\x04\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x02\x03\x02\x01\x03\x04\x00\x05\x72\x69\x67\x68\x74\x03\x00\x02\x01\x68\x01\x01\x68\x03\x01\x40\x02\x01\x78\x04\x01\x79\x05\x01\x00\x04\x00\x01\x66\x01\x06\x03\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x69\x73\x74\x69\x6e\x63\x74\x2f\x61\x70\x69\x05\x04\x04\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x69\x73\x74\x69\x6e\x63\x74\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "reserved", "package example:reserved; world app { import dep:%world/%interface; } package dep:%world { interface %interface { type %type=u32; } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (type (;0;) u32)\n              (export (;1;) \"type\" (type (eq 0)))\n            )\n          )\n          (import \"dep:world/interface\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"example:reserved/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x46\x01\x41\x02\x01\x41\x02\x01\x42\x02\x01\x79\x04\x00\x04\x74\x79\x70\x65\x03\x00\x00\x03\x00\x13\x64\x65\x70\x3a\x77\x6f\x72\x6c\x64\x2f\x69\x6e\x74\x65\x72\x66\x61\x63\x65\x05\x00\x04\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x72\x65\x73\x65\x72\x76\x65\x64\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "accessors", "package example:accessors; world app { import dep:base/core; } package dep:base { interface core { p:get()->u32; p:set(x:u32); resource r { value:get()->u8; value:set(x:u8); } } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (borrow 0))\n              (type (;2;) (func (param \"self\" 1) (result u8)))\n              (export (;0;) \"[method][get]r.value\" (func (type 2)))\n              (type (;3;) (func (param \"self\" 1) (param \"x\" u8)))\n              (export (;1;) \"[method][set]r.value\" (func (type 3)))\n              (type (;4;) (func (result u32)))\n              (export (;2;) \"[get]p\" (func (type 4)))\n              (type (;5;) (func (param \"x\" u32)))\n              (export (;3;) \"[set]p\" (func (type 5)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"example:accessors/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\xac\x01\x01\x41\x02\x01\x41\x02\x01\x42\x0a\x04\x00\x01\x72\x03\x01\x01\x68\x00\x01\x40\x01\x04\x73\x65\x6c\x66\x01\x00\x7d\x04\x00\x14\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x67\x65\x74\x5d\x72\x2e\x76\x61\x6c\x75\x65\x01\x02\x01\x40\x02\x04\x73\x65\x6c\x66\x01\x01\x78\x7d\x01\x00\x04\x00\x14\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x73\x65\x74\x5d\x72\x2e\x76\x61\x6c\x75\x65\x01\x03\x01\x40\x00\x00\x79\x04\x00\x06\x5b\x67\x65\x74\x5d\x70\x01\x04\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x06\x5b\x73\x65\x74\x5d\x70\x01\x05\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x63\x63\x65\x73\x73\x6f\x72\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "metadata", "package example:metadata@1.0.0; interface api { @unstable(feature=preview) use dep:base/core.{r}; @unstable(feature=preview) f:func(x:borrow<r>); } world app { import api; } package dep:base { interface core { resource r; } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n        )\n      )\n      (import \"dep:base/core\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (type (;2;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (type (;2;) (borrow 1))\n          (type (;3;) (func (param \"x\" 2)))\n          (export (;0;) \"f\" (func (type 3)))\n        )\n      )\n      (export (;1;) \"example:metadata/api@1.0.0\" (instance (type 2)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (type (;2;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (type (;2;) (borrow 1))\n              (type (;3;) (func (param \"x\" 2)))\n              (export (;0;) \"f\" (func (type 3)))\n            )\n          )\n          (import \"example:metadata/api@1.0.0\" (instance (;1;) (type 2)))\n        )\n      )\n      (export (;0;) \"example:metadata/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{\\22interfaces\\22:{\\22api\\22:{\\22funcs\\22:{\\22f\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22preview\\22}}}},\\22types\\22:{\\22r\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22preview\\22}}}}}}}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x63\x01\x41\x05\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x01\x72\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x04\x00\x1a\x65\x78\x61\x6d\x70\x6c\x65\x3a\x6d\x65\x74\x61\x64\x61\x74\x61\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x02\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\x85\x01\x01\x41\x02\x01\x41\x05\x01\x42\x01\x04\x00\x01\x72\x03\x01\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x01\x72\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x03\x00\x1a\x65\x78\x61\x6d\x70\x6c\x65\x3a\x6d\x65\x74\x61\x64\x61\x74\x61\x2f\x61\x70\x69\x40\x31\x2e\x30\x2e\x30\x05\x02\x04\x00\x1a\x65\x78\x61\x6d\x70\x6c\x65\x3a\x6d\x65\x74\x61\x64\x61\x74\x61\x2f\x61\x70\x70\x40\x31\x2e\x30\x2e\x30\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\xa4\x01\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x22\x69\x6e\x74\x65\x72\x66\x61\x63\x65\x73\x22\x3a\x7b\x22\x61\x70\x69\x22\x3a\x7b\x22\x66\x75\x6e\x63\x73\x22\x3a\x7b\x22\x66\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x75\x6e\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x66\x65\x61\x74\x75\x72\x65\x22\x3a\x22\x70\x72\x65\x76\x69\x65\x77\x22\x7d\x7d\x7d\x7d\x2c\x22\x74\x79\x70\x65\x73\x22\x3a\x7b\x22\x72\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x75\x6e\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x66\x65\x61\x74\x75\x72\x65\x22\x3a\x22\x70\x72\x65\x76\x69\x65\x77\x22\x7d\x7d\x7d\x7d\x7d\x7d\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "union", "package example:union; interface left { use dep:base/core.{r}; f:func(x:borrow<r>); } interface right { use dep:base/core.{id}; g:func()->id; } world app { import left; import right; } package dep:base { interface core { resource r; type id=u32; extra:func(); } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"dep:base/core\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (type (;2;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (type (;2;) (borrow 1))\n          (type (;3;) (func (param \"x\" 2)))\n          (export (;0;) \"f\" (func (type 3)))\n        )\n      )\n      (export (;1;) \"example:union/left\" (instance (type 2)))\n    )\n  )\n  (export (;1;) \"left\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"dep:base/core\" (instance (;0;) (type 0)))\n      (alias export 0 \"id\" (type (;1;)))\n      (type (;2;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"id\" (type (eq 0)))\n          (type (;2;) (func (result 1)))\n          (export (;0;) \"g\" (func (type 2)))\n        )\n      )\n      (export (;1;) \"example:union/right\" (instance (type 2)))\n    )\n  )\n  (export (;3;) \"right\" (type 2))\n  (type (;4;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n              (type (;3;) (func))\n              (export (;0;) \"extra\" (func (type 3)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (type (;2;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (type (;2;) (borrow 1))\n              (type (;3;) (func (param \"x\" 2)))\n              (export (;0;) \"f\" (func (type 3)))\n            )\n          )\n          (import \"example:union/left\" (instance (;1;) (type 2)))\n          (alias export 0 \"id\" (type (;3;)))\n          (type (;4;)\n            (instance\n              (alias outer 1 3 (type (;0;)))\n              (export (;1;) \"id\" (type (eq 0)))\n              (type (;2;) (func (result 1)))\n              (export (;0;) \"g\" (func (type 2)))\n            )\n          )\n          (import \"example:union/right\" (instance (;2;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:union/app\" (component (type 0)))\n    )\n  )\n  (export (;5;) \"app\" (type 4))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x65\x01\x41\x05\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x01\x72\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x75\x6e\x69\x6f\x6e\x2f\x6c\x65\x66\x74\x05\x02\x0b\x0a\x01\x00\x04\x6c\x65\x66\x74\x03\x00\x00\x07\x62\x01\x41\x05\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x02\x69\x64\x01\x42\x04\x02\x03\x02\x01\x01\x04\x00\x02\x69\x64\x03\x00\x00\x01\x40\x00\x00\x01\x04\x00\x01\x67\x01\x02\x04\x00\x13\x65\x78\x61\x6d\x70\x6c\x65\x3a\x75\x6e\x69\x6f\x6e\x2f\x72\x69\x67\x68\x74\x05\x02\x0b\x0b\x01\x00\x05\x72\x69\x67\x68\x74\x03\x02\x00\x07\xc7\x01\x01\x41\x02\x01\x41\x08\x01\x42\x05\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x01\x40\x00\x01\x00\x04\x00\x05\x65\x78\x74\x72\x61\x01\x03\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x01\x72\x01\x42\x05\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x01\x68\x01\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x03\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x75\x6e\x69\x6f\x6e\x2f\x6c\x65\x66\x74\x05\x02\x02\x03\x00\x00\x02\x69\x64\x01\x42\x04\x02\x03\x02\x01\x03\x04\x00\x02\x69\x64\x03\x00\x00\x01\x40\x00\x00\x01\x04\x00\x01\x67\x01\x02\x03\x00\x13\x65\x78\x61\x6d\x70\x6c\x65\x3a\x75\x6e\x69\x6f\x6e\x2f\x72\x69\x67\x68\x74\x05\x04\x04\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x75\x6e\x69\x6f\x6e\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x04\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "chain", "package example:chain; interface api { use dep:middle/mid.{r,id}; f:func(x:borrow<r>)->id; } world app { import api; } package dep:base { interface core { resource r; type id=u32; } } package dep:middle { interface mid { use dep:base/core.{r,id}; extra:func(x:borrow<r>); } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) u32)\n          (export (;2;) \"id\" (type (eq 1)))\n        )\n      )\n      (import \"dep:base/core\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (alias export 0 \"id\" (type (;2;)))\n      (type (;3;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 2 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n        )\n      )\n      (import \"dep:middle/mid\" (instance (;1;) (type 3)))\n      (alias export 1 \"r\" (type (;4;)))\n      (alias export 1 \"id\" (type (;5;)))\n      (type (;6;)\n        (instance\n          (alias outer 1 4 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (alias outer 1 5 (type (;2;)))\n          (export (;3;) \"id\" (type (eq 2)))\n          (type (;4;) (borrow 1))\n          (type (;5;) (func (param \"x\" 4) (result 3)))\n          (export (;0;) \"f\" (func (type 5)))\n        )\n      )\n      (export (;2;) \"example:chain/api\" (instance (type 6)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (alias export 0 \"id\" (type (;2;)))\n          (type (;3;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 2 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4)))\n              (export (;0;) \"extra\" (func (type 5)))\n            )\n          )\n          (import \"dep:middle/mid\" (instance (;1;) (type 3)))\n          (alias export 1 \"r\" (type (;4;)))\n          (alias export 1 \"id\" (type (;5;)))\n          (type (;6;)\n            (instance\n              (alias outer 1 4 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (alias outer 1 5 (type (;2;)))\n              (export (;3;) \"id\" (type (eq 2)))\n              (type (;4;) (borrow 1))\n              (type (;5;) (func (param \"x\" 4) (result 3)))\n              (export (;0;) \"f\" (func (type 5)))\n            )\n          )\n          (import \"example:chain/api\" (instance (;2;) (type 6)))\n        )\n      )\n      (export (;0;) \"example:chain/app\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\xb4\x01\x01\x41\x0a\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x02\x69\x64\x01\x42\x04\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x02\x69\x64\x03\x00\x02\x03\x00\x0e\x64\x65\x70\x3a\x6d\x69\x64\x64\x6c\x65\x2f\x6d\x69\x64\x05\x03\x02\x03\x00\x01\x01\x72\x02\x03\x00\x01\x02\x69\x64\x01\x42\x07\x02\x03\x02\x01\x04\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x05\x04\x00\x02\x69\x64\x03\x00\x02\x01\x68\x01\x01\x40\x01\x01\x78\x04\x00\x03\x04\x00\x01\x66\x01\x05\x04\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x61\x70\x69\x05\x06\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\xe2\x01\x01\x41\x02\x01\x41\x0a\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x01\x72\x02\x03\x00\x00\x02\x69\x64\x01\x42\x07\x02\x03\x02\x01\x01\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x02\x04\x00\x02\x69\x64\x03\x00\x02\x01\x68\x01\x01\x40\x01\x01\x78\x04\x01\x00\x04\x00\x05\x65\x78\x74\x72\x61\x01\x05\x03\x00\x0e\x64\x65\x70\x3a\x6d\x69\x64\x64\x6c\x65\x2f\x6d\x69\x64\x05\x03\x02\x03\x00\x01\x01\x72\x02\x03\x00\x01\x02\x69\x64\x01\x42\x07\x02\x03\x02\x01\x04\x04\x00\x01\x72\x03\x00\x00\x02\x03\x02\x01\x05\x04\x00\x02\x69\x64\x03\x00\x02\x01\x68\x01\x01\x40\x01\x01\x78\x04\x00\x03\x04\x00\x01\x66\x01\x05\x03\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x61\x70\x69\x05\x06\x04\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x63\x68\x61\x69\x6e\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "methods", "package example:methods; world app { import dep:base/core; } package dep:base { interface core { resource r { constructor(); f:func(x:u32)->string; } } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (own 0))\n              (type (;2;) (func (result 1)))\n              (export (;0;) \"[constructor]r\" (func (type 2)))\n              (type (;3;) (borrow 0))\n              (type (;4;) (func (param \"self\" 3) (param \"x\" u32) (result string)))\n              (export (;1;) \"[method]r.f\" (func (type 4)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"example:methods/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x75\x01\x41\x02\x01\x41\x02\x01\x42\x07\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x02\x01\x68\x00\x01\x40\x02\x04\x73\x65\x6c\x66\x03\x01\x78\x79\x00\x73\x04\x00\x0b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x01\x04\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x04\x00\x13\x65\x78\x61\x6d\x70\x6c\x65\x3a\x6d\x65\x74\x68\x6f\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "empty", "package example:empty; world app { import dep:base/core; } package dep:base { interface core {} }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance)\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"example:empty/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x31\x01\x41\x02\x01\x41\x02\x01\x42\x00\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x04\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x65\x6d\x70\x74\x79\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "world-use", "package example:worlduses; world app { use dep:base/core.{r as renamed,id}; export f:func(x:borrow<renamed>)->id; } package dep:base { interface core { resource r; type id=u32; } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) u32)\n              (export (;2;) \"id\" (type (eq 1)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (import \"renamed\" (type (;2;) (eq 1)))\n          (alias export 0 \"id\" (type (;3;)))\n          (import \"id\" (type (;4;) (eq 3)))\n          (type (;5;) (borrow 2))\n          (type (;6;) (func (param \"x\" 5) (result 4)))\n          (export (;0;) \"f\" (func (type 6)))\n        )\n      )\n      (export (;0;) \"example:worlduses/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x78\x01\x41\x02\x01\x41\x09\x01\x42\x03\x04\x00\x01\x72\x03\x01\x01\x79\x04\x00\x02\x69\x64\x03\x00\x01\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x01\x72\x03\x00\x07\x72\x65\x6e\x61\x6d\x65\x64\x03\x00\x01\x02\x03\x00\x00\x02\x69\x64\x03\x00\x02\x69\x64\x03\x00\x03\x01\x68\x02\x01\x40\x01\x01\x78\x05\x00\x04\x04\x00\x01\x66\x01\x06\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x75\x73\x65\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "aggregates", "package example:aggregates; interface api { use dep:base/core.{payload}; f:func(x:payload); } world app { import dep:base/core; import api; } package dep:base { interface core { resource r; record payload { key:string, value:list<borrow<r>> } f:func(x:payload); } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) (borrow 0))\n          (type (;2;) (list 1))\n          (type (;3;) (record (field \"key\" string) (field \"value\" 2)))\n          (export (;4;) \"payload\" (type (eq 3)))\n        )\n      )\n      (import \"dep:base/core\" (instance (;0;) (type 0)))\n      (alias export 0 \"payload\" (type (;1;)))\n      (type (;2;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"payload\" (type (eq 0)))\n          (type (;2;) (func (param \"x\" 1)))\n          (export (;0;) \"f\" (func (type 2)))\n        )\n      )\n      (export (;1;) \"example:aggregates/api\" (instance (type 2)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (borrow 0))\n              (type (;2;) (list 1))\n              (type (;3;) (record (field \"key\" string) (field \"value\" 2)))\n              (export (;4;) \"payload\" (type (eq 3)))\n              (type (;5;) (func (param \"x\" 4)))\n              (export (;0;) \"f\" (func (type 5)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n          (alias export 0 \"payload\" (type (;1;)))\n          (type (;2;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"payload\" (type (eq 0)))\n              (type (;2;) (func (param \"x\" 1)))\n              (export (;0;) \"f\" (func (type 2)))\n            )\n          )\n          (import \"example:aggregates/api\" (instance (;1;) (type 2)))\n        )\n      )\n      (export (;0;) \"example:aggregates/app\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x8a\x01\x01\x41\x05\x01\x42\x05\x04\x00\x01\x72\x03\x01\x01\x68\x00\x01\x70\x01\x01\x72\x02\x03\x6b\x65\x79\x73\x05\x76\x61\x6c\x75\x65\x02\x04\x00\x07\x70\x61\x79\x6c\x6f\x61\x64\x03\x00\x03\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x07\x70\x61\x79\x6c\x6f\x61\x64\x01\x42\x04\x02\x03\x02\x01\x01\x04\x00\x07\x70\x61\x79\x6c\x6f\x61\x64\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x04\x00\x16\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x73\x2f\x61\x70\x69\x05\x02\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\xb6\x01\x01\x41\x02\x01\x41\x05\x01\x42\x07\x04\x00\x01\x72\x03\x01\x01\x68\x00\x01\x70\x01\x01\x72\x02\x03\x6b\x65\x79\x73\x05\x76\x61\x6c\x75\x65\x02\x04\x00\x07\x70\x61\x79\x6c\x6f\x61\x64\x03\x00\x03\x01\x40\x01\x01\x78\x04\x01\x00\x04\x00\x01\x66\x01\x05\x03\x00\x0d\x64\x65\x70\x3a\x62\x61\x73\x65\x2f\x63\x6f\x72\x65\x05\x00\x02\x03\x00\x00\x07\x70\x61\x79\x6c\x6f\x61\x64\x01\x42\x04\x02\x03\x02\x01\x01\x04\x00\x07\x70\x61\x79\x6c\x6f\x61\x64\x03\x00\x00\x01\x40\x01\x01\x78\x01\x01\x00\x04\x00\x01\x66\x01\x02\x03\x00\x16\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x73\x2f\x61\x70\x69\x05\x02\x04\x00\x16\x65\x78\x61\x6d\x70\x6c\x65\x3a\x61\x67\x67\x72\x65\x67\x61\x74\x65\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
    ] {
    let expected = @verifier.resolve(
      { documents: [section_document("source.wit", source)], },
      semantic_features=@verifier.SemanticFeatures::all(),
    ).unwrap()
    for
      input in [
        @verifier.decode_package(bytes).unwrap(),
        @verifier.decode_wat_package(wat).unwrap(),
      ] {
      let model = @verifier.resolve_packages(
        Encoded(input),
        semantic_features=@verifier.SemanticFeatures::all(),
      ).unwrap()
      assert_eq(model.world_summary(), expected.world_summary(), msg=name)
      assert_eq(
        encoded_alias_model(model, reachable_only=true),
        encoded_alias_model(expected, reachable_only=true),
        msg=name,
      )
    }
  }
}

///|
test "reused instance templates freshen foreign resources" {
  let wat = "(component\n (type (component\n  (type (component\n   (type (instance (export \"r\" (type (sub resource)))))\n   (import \"dep:a/first\" (instance (type 0)))\n   (import \"dep:b/second\" (instance (type 0)))\n   (alias export 0 \"r\" (type))\n   (import \"left\" (type (eq 1)))\n   (alias export 1 \"r\" (type))\n   (import \"right\" (type (eq 3)))\n   (type (borrow 2))\n   (type (borrow 4))\n   (type (func (param \"a\" 5) (param \"b\" 6)))\n   (export \"run\" (func (type 7)))\n  ))\n  (export \"example:shared/app\" (component (type 0)))\n ))\n (export \"app\" (type 0))\n)\n"
  let source = "package example:shared; world app { use dep:a/first.{r as left}; use dep:b/second.{r as right}; export run:func(a:borrow<left>,b:borrow<right>); } package dep:a { interface first { resource r; } } package dep:b { interface second { resource r; } }"
  let input = @verifier.decode_wat_package(wat).unwrap()
  let model = @verifier.resolve_packages(Encoded(input)).unwrap()
  let expected = @verifier.resolve({
    documents: [section_document("source.wit", source)],
  }).unwrap()
  assert_eq(model.world_summary(), expected.world_summary())
  assert_eq(
    encoded_alias_model(model, reachable_only=true),
    encoded_alias_model(expected, reachable_only=true),
  )
}

///|
test "foreign closure compaction retains binary alias metadata" {
  let wat = "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n        )\n      )\n      (import \"dep:base/core\" (instance (;0;) (type 0)))\n      (alias export 0 \"r\" (type (;1;)))\n      (type (;2;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"r\" (type (eq 0)))\n          (type (;2;) (borrow 1))\n          (type (;3;) (func (param \"x\" 2)))\n          (export (;0;) \"f\" (func (type 3)))\n        )\n      )\n      (export (;1;) \"example:metadata/api@1.0.0\" (instance (type 2)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n          (alias export 0 \"r\" (type (;1;)))\n          (type (;2;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"r\" (type (eq 0)))\n              (type (;2;) (borrow 1))\n              (type (;3;) (func (param \"x\" 2)))\n              (export (;0;) \"f\" (func (type 3)))\n            )\n          )\n          (import \"example:metadata/api@1.0.0\" (instance (;1;) (type 2)))\n        )\n      )\n      (export (;0;) \"example:metadata/app@1.0.0\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{\\22interfaces\\22:{\\22api\\22:{\\22funcs\\22:{\\22f\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22preview\\22}}}},\\22types\\22:{\\22r\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22preview\\22}}}}}}}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n"
  let input = @verifier.decode_wat_package(wat, source_id="metadata.wat").unwrap()
  let supplied = section_document(
    "base.wit", "package dep:base; interface core { resource r; }",
  )
  for
    features in [
      @verifier.SemanticFeatures::default(),
      @verifier.SemanticFeatures::all(),
    ] {
    let model = match
      @verifier.resolve_packages(
        Encoded(input),
        dependencies=[Source({ documents: [supplied], })],
        semantic_features=features,
      ) {
      Ok(model) => model
      Err(errors) => fail(@debug.Repr(errors).to_string())
    }
    let api = model.interfaces().filter(i => i.name == Some("api"))[0]
    let alias_type = api.types.filter(t => t.name == "r")[0]
    assert_eq(
      model.types().filter(t => t.id == alias_type.ty)[0].stability,
      Unstable("preview", None),
    )
    assert_eq(model.origin(alias_type.ty).unwrap().node, None)
    assert_eq(alias_type.location.position, BinaryOffset(None))
    assert_eq(
      api.functions.length(),
      if features == @verifier.SemanticFeatures::all() {
        1
      } else {
        0
      },
    )
  }
}

///|
test "wide inferred interface rendering obeys its work budget" {
  let text = StringBuilder()
  text.write_string(
    "(component(type(component(type(component(type(instance(export \"r\"(type(sub resource)))))",
  )
  for i in 0..<1200 {
    text.write_string(
      "(import \"dep:wide/i" + i.to_string() + "\"(instance(type 0)))",
    )
  }
  text.write_string(
    "))(export \"example:wide/app\"(component(type 0)))))(export \"app\"(type 0)))",
  )
  let errors = @verifier.decode_wat_package(text.to_string()).unwrap_err()
  assert_eq(errors[0].code, "WIT-B002")
  assert_true(errors[0].message.contains("work limit"))
}

///|
test "foreign projections retain pinned structural and function checks" {
  for
    (wat, accepted) in [
      (
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) (borrow 0))\n          (type (;2;) (list 1))\n          (type (;3;) (record (field \"key\" string) (field \"value\" 2)))\n          (export (;4;) \"payload\" (type (eq 3)))\n        )\n      )\n      (import \"dep:base/core\" (instance (;0;) (type 0)))\n      (alias export 0 \"payload\" (type (;1;)))\n      (type (;2;)\n        (instance\n          (alias outer 1 1 (type (;0;)))\n          (export (;1;) \"payload\" (type (eq 0)))\n          (type (;2;) (func (param \"x\" 1)))\n          (export (;0;) \"f\" (func (type 2)))\n        )\n      )\n      (export (;1;) \"example:aggregates/api\" (instance (type 2)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (borrow 0))\n              (type (;2;) (list 1))\n              (type (;3;) (record (field \"other\" string) (field \"value\" 2)))\n              (export (;4;) \"payload\" (type (eq 3)))\n              (type (;5;) (func (param \"x\" 4)))\n              (export (;0;) \"f\" (func (type 5)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n          (alias export 0 \"payload\" (type (;1;)))\n          (type (;2;)\n            (instance\n              (alias outer 1 1 (type (;0;)))\n              (export (;1;) \"payload\" (type (eq 0)))\n              (type (;2;) (func (param \"x\" 1)))\n              (export (;0;) \"f\" (func (type 2)))\n            )\n          )\n          (import \"example:aggregates/api\" (instance (;1;) (type 2)))\n        )\n      )\n      (export (;0;) \"example:aggregates/app\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        false,
      ),
      (
        "(component (type(component(type(component(type(instance(type(func(result u32)))(export \"f\"(func(type 0)))))(import \"dep:base/core\"(instance(type 0)))))(export \"example:projections/first\"(component(type 0)))))(export \"first\"(type 0))(type(component(type(component(type(instance(type(func(param \"different\" string)))(export \"f\"(func(type 0)))))(import \"dep:base/core\"(instance(type 0)))))(export \"example:projections/second\"(component(type 0)))))(export \"second\"(type 2)))",
        true,
      ),
    ] {
    assert_eq(@verifier.decode_wat_package(wat) is Ok(_), accepted)
  }
}

///|
test "disabled overlapping source views fail closed before merge" {
  let input = @verifier.decode_wat_package(encoded_foreign_wat()).unwrap()
  for
    text in [
      "package example:dep@2.0.0; @unstable(feature=hidden) interface base { resource r; }",
      "package example:dep@2.0.0; interface base { @unstable(feature=hidden) resource r; }",
      "package example:dep@2.0.0; interface base { @unstable(feature=hidden) extra:func()->string; }",
    ] {
    let supplied : @verifier.PackageInput = Source({
      documents: [section_document("supplied.wit", text)],
    })
    let errors = @verifier.resolve_packages(Encoded(input), dependencies=[
      supplied,
    ]).unwrap_err()
    assert_eq(errors[0].code, "WIT-B002")
    assert_true(
      @verifier.resolve_packages(
        Encoded(input),
        dependencies=[supplied],
        semantic_features=@verifier.SemanticFeatures::all(),
      )
      is Ok(_),
    )
  }
}

///|
test "supplied resource methods merge in either caller order" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (own 0))\n              (type (;2;) (func (result 1)))\n              (export (;0;) \"[constructor]r\" (func (type 2)))\n              (type (;3;) (borrow 0))\n              (type (;4;) (func (param \"self\" 3) (param \"x\" u32) (result string)))\n              (export (;1;) \"[method]r.f\" (func (type 4)))\n            )\n          )\n          (import \"dep:base/core\" (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"example:methods/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="methods.wat",
  ).unwrap()
  let document = section_document(
    "base.wit", "package dep:base; interface core { resource r { constructor(); f:func(x:u32)->string; g:func(); } }",
  )
  let source : @verifier.PackageInput = Source({ documents: [document], })
  let encoded : @verifier.PackageInput = Encoded(input)
  let a = @verifier.resolve_packages(encoded, dependencies=[source]).unwrap()
  let b = @verifier.resolve_packages(source, dependencies=[encoded]).unwrap()
  assert_eq(
    encoded_alias_model(a, reachable_only=true),
    encoded_alias_model(b, reachable_only=true),
  )
  for model in [a, b] {
    let core = model.interfaces().filter(i => i.name == Some("core"))[0]
    assert_eq(core.functions.length(), 3)
    assert_true(core.functions.all(f => f.location.source == "base.wit"))
  }
  let partial : @verifier.PackageInput = Source({
    documents: [
      section_document(
        "partial.wit", "package dep:base;interface core{resource r;}",
      ),
    ],
  })
  let model = @verifier.resolve_packages(partial, dependencies=[encoded]).unwrap()
  let core = model.interfaces().filter(i => i.name == Some("core"))[0]
  assert_eq(core.functions.length(), 2)
  assert_true(core.functions.all(f => f.location.source == "methods.wat"))
  assert_true(core.functions.any(f => f.kind is Constructor(_)))
  assert_true(core.functions.any(f => f.kind is Method(_)))
  for function in core.functions {
    for parameter in function.params {
      assert_eq(
        model.types().filter(t => t.id == parameter.ty)[0].scope,
        core.id,
      )
    }
  }
}
