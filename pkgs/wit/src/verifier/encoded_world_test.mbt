///|
test "encoded world resources preserve source binary and WAT graphs" {
  for
    (name, source, wat, bytes) in [
      (
        "alias", "package example:worlds;world app{resource r; type alias-r=r; export f:func()->own<alias-r>;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (import \"alias-r\" (type (;1;) (eq 0)))\n          (type (;2;) (own 1))\n          (type (;3;) (func (result 2)))\n          (export (;0;) \"f\" (func (type 3)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x3e\x01\x41\x02\x01\x41\x05\x03\x00\x01\x72\x03\x01\x03\x00\x07\x61\x6c\x69\x61\x73\x2d\x72\x03\x00\x00\x01\x69\x01\x01\x40\x00\x00\x02\x04\x00\x01\x66\x01\x03\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "bare", "package example:worlds;world app{resource r; export f:func()->own<r>;}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (own 0))\n          (type (;2;) (func (result 1)))\n          (export (;0;) \"f\" (func (type 2)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x31\x01\x41\x02\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x04\x00\x01\x66\x01\x02\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "metadata", "package example:worlds;world app { @unstable(feature=hidden) resource r { @unstable(feature=ctor) constructor(); @unstable(feature=method) f:func(); } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (own 0))\n          (type (;2;) (func (result 1)))\n          (import \"[constructor]r\" (func (;0;) (type 2)))\n          (type (;3;) (borrow 0))\n          (type (;4;) (func (param \"self\" 3)))\n          (import \"[method]r.f\" (func (;1;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{\\22worlds\\22:{\\22app\\22:{\\22types\\22:{\\22r\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22hidden\\22}}}},\\22funcs\\22:{\\22[constructor]r\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22ctor\\22}}},\\22[method]r.f\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22method\\22}}}}}}}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x5c\x01\x41\x02\x01\x41\x07\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x03\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x02\x01\x68\x00\x01\x40\x01\x04\x73\x65\x6c\x66\x03\x01\x00\x03\x00\x0b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x01\x04\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\xe7\x01\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x22\x77\x6f\x72\x6c\x64\x73\x22\x3a\x7b\x22\x61\x70\x70\x22\x3a\x7b\x22\x74\x79\x70\x65\x73\x22\x3a\x7b\x22\x72\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x75\x6e\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x66\x65\x61\x74\x75\x72\x65\x22\x3a\x22\x68\x69\x64\x64\x65\x6e\x22\x7d\x7d\x7d\x7d\x2c\x22\x66\x75\x6e\x63\x73\x22\x3a\x7b\x22\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x75\x6e\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x66\x65\x61\x74\x75\x72\x65\x22\x3a\x22\x63\x74\x6f\x72\x22\x7d\x7d\x7d\x2c\x22\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x75\x6e\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x66\x65\x61\x74\x75\x72\x65\x22\x3a\x22\x6d\x65\x74\x68\x6f\x64\x22\x7d\x7d\x7d\x7d\x7d\x7d\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "methods", "package example:worlds;world app{resource r { constructor(); f:func(x:u32)->string; }}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (own 0))\n          (type (;2;) (func (result 1)))\n          (import \"[constructor]r\" (func (;0;) (type 2)))\n          (type (;3;) (borrow 0))\n          (type (;4;) (func (param \"self\" 3) (param \"x\" u32) (result string)))\n          (import \"[method]r.f\" (func (;1;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x5f\x01\x41\x02\x01\x41\x07\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x00\x00\x01\x03\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x02\x01\x68\x00\x01\x40\x02\x04\x73\x65\x6c\x66\x03\x01\x78\x79\x00\x73\x03\x00\x0b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x01\x04\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "rich", "package example:worlds;world app { resource r { constructor(x:u32); f:async func(x:string)->u32; make:static func()->r; p:get()->u32; p:set(x:u32); } }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (own 0))\n          (type (;2;) (func (param \"x\" u32) (result 1)))\n          (import \"[constructor]r\" (func (;0;) (type 2)))\n          (type (;3;) (borrow 0))\n          (type (;4;) (func async (param \"self\" 3) (param \"x\" string) (result u32)))\n          (import \"[method]r.f\" (func (;1;) (type 4)))\n          (type (;5;) (func (result 1)))\n          (import \"[static]r.make\" (func (;2;) (type 5)))\n          (type (;6;) (func (param \"self\" 3) (result u32)))\n          (import \"[method][get]r.p\" (func (;3;) (type 6)))\n          (type (;7;) (func (param \"self\" 3) (param \"x\" u32)))\n          (import \"[method][set]r.p\" (func (;4;) (type 7)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\xbd\x01\x01\x41\x02\x01\x41\x0d\x03\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x79\x00\x01\x03\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x02\x01\x68\x00\x01\x43\x02\x04\x73\x65\x6c\x66\x03\x01\x78\x73\x00\x79\x03\x00\x0b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x01\x04\x01\x40\x00\x00\x01\x03\x00\x0e\x5b\x73\x74\x61\x74\x69\x63\x5d\x72\x2e\x6d\x61\x6b\x65\x01\x05\x01\x40\x01\x04\x73\x65\x6c\x66\x03\x00\x79\x03\x00\x10\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x67\x65\x74\x5d\x72\x2e\x70\x01\x06\x01\x40\x02\x04\x73\x65\x6c\x66\x03\x01\x78\x79\x01\x00\x03\x00\x10\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x5b\x73\x65\x74\x5d\x72\x2e\x70\x01\x07\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "two", "package example:worlds;world app{resource left; resource right; import f:func(x:borrow<left>,y:borrow<right>);}",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"left\" (type (;0;) (sub resource)))\n          (import \"right\" (type (;1;) (sub resource)))\n          (type (;2;) (borrow 0))\n          (type (;3;) (borrow 1))\n          (type (;4;) (func (param \"x\" 2) (param \"y\" 3)))\n          (import \"f\" (func (;0;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x47\x01\x41\x02\x01\x41\x06\x03\x00\x04\x6c\x65\x66\x74\x03\x01\x03\x00\x05\x72\x69\x67\x68\x74\x03\x01\x01\x68\x00\x01\x68\x01\x01\x40\x02\x01\x78\x02\x01\x79\x03\x01\x00\x03\x00\x01\x66\x01\x04\x04\x00\x12\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
      (
        "worlds", "package example:worlds;world first { resource r; import f:func(x:borrow<r>); } world second { resource r; import f:func(x:borrow<r>); }",
        "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (borrow 0))\n          (type (;2;) (func (param \"x\" 1)))\n          (import \"f\" (func (;0;) (type 2)))\n        )\n      )\n      (export (;0;) \"example:worlds/first\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"first\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (borrow 0))\n          (type (;2;) (func (param \"x\" 1)))\n          (import \"f\" (func (;0;) (type 2)))\n        )\n      )\n      (export (;0;) \"example:worlds/second\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"second\" (type 2))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
        b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x36\x01\x41\x02\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x68\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x04\x00\x14\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x73\x2f\x66\x69\x72\x73\x74\x04\x00\x0b\x0b\x01\x00\x05\x66\x69\x72\x73\x74\x03\x00\x00\x07\x37\x01\x41\x02\x01\x41\x04\x03\x00\x01\x72\x03\x01\x01\x68\x00\x01\x40\x01\x01\x78\x01\x01\x00\x03\x00\x01\x66\x01\x02\x04\x00\x15\x65\x78\x61\x6d\x70\x6c\x65\x3a\x77\x6f\x72\x6c\x64\x73\x2f\x73\x65\x63\x6f\x6e\x64\x04\x00\x0b\x0c\x01\x00\x06\x73\x65\x63\x6f\x6e\x64\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30",
      ),
    ] {
    let expected = @verifier.resolve(
      { documents: [section_document(name + ".wit", source)], },
      semantic_features=@verifier.SemanticFeatures::all(),
    ).unwrap()
    for
      input in [
        @verifier.decode_package(bytes, source_id=name + ".wasm").unwrap(),
        @verifier.decode_wat_package(wat, source_id=name + ".wat").unwrap(),
      ] {
      let actual = @verifier.resolve_packages(Encoded(input)).unwrap()
      assert_eq(
        encoded_alias_model(actual, reachable_only=true),
        encoded_alias_model(expected, reachable_only=true),
        msg=name,
      )
      assert_eq(actual.sources().length(), 0)
      assert_eq(actual.binaries().length(), 1)
      for function in actual.functions() {
        assert_eq(function.location.position, BinaryOffset(None))
        assert_eq(actual.origin(function.id).unwrap().node, None)
      }
      assert_eq(actual.worlds().length(), expected.worlds().length())
      for world in actual.worlds() {
        let original = expected.worlds().filter(w => w.name == world.name)[0]
        assert_eq(
          world.imports.map(i => i.name),
          original.imports.map(i => i.name),
        )
        assert_eq(
          world.exports.map(i => i.name),
          original.exports.map(i => i.name),
        )
      }
    }
  }
}

///|
test "world resource metadata retains binary stability and nominal identity" {
  let input = @verifier.decode_wat_package(
    "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (own 0))\n          (type (;2;) (func (result 1)))\n          (import \"[constructor]r\" (func (;0;) (type 2)))\n          (type (;3;) (borrow 0))\n          (type (;4;) (func (param \"self\" 3)))\n          (import \"[method]r.f\" (func (;1;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{\\22worlds\\22:{\\22app\\22:{\\22types\\22:{\\22r\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22hidden\\22}}}},\\22funcs\\22:{\\22[constructor]r\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22ctor\\22}}},\\22[method]r.f\\22:{\\22stability\\22:{\\22unstable\\22:{\\22feature\\22:\\22method\\22}}}}}}}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    source_id="metadata.wat",
  ).unwrap()
  for
    features in [
      @verifier.SemanticFeatures::default(),
      @verifier.SemanticFeatures::all(),
    ] {
    let model = @verifier.resolve_packages(
      Encoded(input),
      semantic_features=features,
    ).unwrap()
    let world = model.worlds()[0]
    let entry = world.imports.filter(i => i.name == "r")[0]
    guard entry.kind is Type(resource_id) else {
      fail("missing world resource")
    }
    let resource_type = model.types().filter(t => t.id == resource_id)[0]
    assert_eq(resource_type.kind, Resource)
    assert_eq(resource_type.scope, world.id)
    assert_eq(resource_type.stability, Unstable("hidden", None))
    let constructor_function = model
      .functions()
      .filter(f => f.kind is Constructor(_))[0]
    assert_eq(constructor_function.kind, Constructor(resource_id))
    assert_eq(constructor_function.stability, Unstable("ctor", None))
    assert_eq(
      model.types().filter(t => t.id == constructor_function.result.unwrap())[0].kind,
      Own(resource_id),
    )
    let member_function = model.functions().filter(f => f.kind is Method(_))[0]
    assert_eq(member_function.kind, Method(resource_id))
    assert_eq(member_function.stability, Unstable("method", None))
    assert_eq(member_function.params[0].name, "self")
    assert_eq(
      model.types().filter(t => t.id == member_function.params[0].ty)[0].kind,
      Borrow(resource_id),
    )
    assert_eq(world.imports.length(), 3)
    assert_eq(
      world.imports.filter(i => i.name == "[constructor]r")[0].stability,
      constructor_function.stability,
    )
    assert_eq(
      world.imports.filter(i => i.name == "[method]r.f")[0].stability,
      member_function.stability,
    )
  }
}

///|
test "world resource alias method fails closed instead of the pinned decoder panic" {
  let errors = @verifier.decode_wat_package(
    "(component(type(component(type(component(import \"r\"(type(sub resource)))(import \"s\"(type(eq 0)))(type(borrow 1))(type(func(param \"self\" 2)))(import \"[method]s.f\"(func(type 3)))))(export \"example:worlds/app\"(component(type 0)))))(export \"app\"(type 0)))",
  ).unwrap_err()
  assert_eq(errors[0].code, "WIT-B003")
  assert_eq(errors[0].primary.location.position, BinaryOffset(None))
}

///|
test "world resource functions cannot be exported from an imported resource" {
  for
    wat in [
      "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (own 0))\n          (type (;2;) (func (result 1)))\n          (import \"[constructor]r\" (func (;0;) (type 2)))\n          (type (;3;) (borrow 0))\n          (type (;4;) (func (param \"self\" 3) (param \"x\" u32) (result string)))\n          (export \"[method]r.f\" (func (;1;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
      "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (import \"r\" (type (;0;) (sub resource)))\n          (type (;1;) (own 0))\n          (type (;2;) (func (result 1)))\n          (export \"[constructor]r\" (func (;0;) (type 2)))\n          (type (;3;) (borrow 0))\n          (type (;4;) (func (param \"self\" 3) (param \"x\" u32) (result string)))\n          (import \"[method]r.f\" (func (;1;) (type 4)))\n        )\n      )\n      (export (;0;) \"example:worlds/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n",
    ] {
    let errors = @verifier.decode_wat_package(wat).unwrap_err()
    assert_eq(errors[0].code, "WIT-B003")
  }
}
