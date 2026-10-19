///|
// Full named graph and resource edges agree with the unsuffixed source package.
test "canonical suffixes expand WIT identities and preserve metadata" {
  let source = "package test:root@1.2.3; interface api { @since(version=1.2.3) resource r { @since(version=1.2.3) constructor(); @since(version=1.2.3) method:func(x:list<u32>); } @since(version=1.2.3) type t=list<u32>; @since(version=1.2.3) f:func(x:option<t>)->tuple<t,r>; } world app { import api; export api; }"
  let text = "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (instance\n          (export (;0;) \"r\" (type (sub resource)))\n          (type (;1;) (list u32))\n          (export (;2;) \"t\" (type (eq 1)))\n          (type (;3;) (own 0))\n          (type (;4;) (func (result 3)))\n          (export (;0;) \"[constructor]r\" (func (type 4)))\n          (type (;5;) (borrow 0))\n          (type (;6;) (list u32))\n          (type (;7;) (func (param \"self\" 5) (param \"x\" 6)))\n          (export (;1;) \"[method]r.method\" (func (type 7)))\n          (type (;8;) (option 2))\n          (type (;9;) (tuple 2 3))\n          (type (;10;) (func (param \"x\" 8) (result 9)))\n          (export (;2;) \"f\" (func (type 10)))\n        )\n      )\n      (export (;0;) \"test:root/api@1\" (version-suffix \".2.3\") (instance (type 0)))\n    )\n  )\n  (export (;1;) \"api\" (type 0))\n  (type (;2;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (list u32))\n              (export (;2;) \"t\" (type (eq 1)))\n              (type (;3;) (own 0))\n              (type (;4;) (func (result 3)))\n              (export (;0;) \"[constructor]r\" (func (type 4)))\n              (type (;5;) (borrow 0))\n              (type (;6;) (list u32))\n              (type (;7;) (func (param \"self\" 5) (param \"x\" 6)))\n              (export (;1;) \"[method]r.method\" (func (type 7)))\n              (type (;8;) (option 2))\n              (type (;9;) (tuple 2 3))\n              (type (;10;) (func (param \"x\" 8) (result 9)))\n              (export (;2;) \"f\" (func (type 10)))\n            )\n          )\n          (import \"test:root/api@1\" (version-suffix \".2.3\") (instance (;0;) (type 0)))\n          (type (;1;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (list u32))\n              (export (;2;) \"t\" (type (eq 1)))\n              (type (;3;) (own 0))\n              (type (;4;) (func (result 3)))\n              (export (;0;) \"[constructor]r\" (func (type 4)))\n              (type (;5;) (borrow 0))\n              (type (;6;) (list u32))\n              (type (;7;) (func (param \"self\" 5) (param \"x\" 6)))\n              (export (;1;) \"[method]r.method\" (func (type 7)))\n              (type (;8;) (option 2))\n              (type (;9;) (tuple 2 3))\n              (type (;10;) (func (param \"x\" 8) (result 9)))\n              (export (;2;) \"f\" (func (type 10)))\n            )\n          )\n          (export (;1;) \"test:root/api@1\" (version-suffix \".2.3\") (instance (type 1)))\n        )\n      )\n      (export (;0;) \"test:root/app@1.2.3\" (component (type 0)))\n    )\n  )\n  (export (;3;) \"app\" (type 2))\n  (@custom \"package-docs\" \"\\01{\\22interfaces\\22:{\\22api\\22:{\\22funcs\\22:{\\22[constructor]r\\22:{\\22stability\\22:{\\22stable\\22:{\\22since\\22:\\221.2.3\\22}}},\\22[method]r.method\\22:{\\22stability\\22:{\\22stable\\22:{\\22since\\22:\\221.2.3\\22}}},\\22f\\22:{\\22stability\\22:{\\22stable\\22:{\\22since\\22:\\221.2.3\\22}}}},\\22types\\22:{\\22r\\22:{\\22stability\\22:{\\22stable\\22:{\\22since\\22:\\221.2.3\\22}}},\\22t\\22:{\\22stability\\22:{\\22stable\\22:{\\22since\\22:\\221.2.3\\22}}}}}}}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x8b\x01\x01\x41\x02\x01\x42\x0e\x04\x00\x01\x72\x03\x01\x01\x70\x79\x04\x00\x01\x74\x03\x00\x01\x01\x69\x00\x01\x40\x00\x00\x03\x04\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x04\x01\x68\x00\x01\x70\x79\x01\x40\x02\x04\x73\x65\x6c\x66\x05\x01\x78\x06\x01\x00\x04\x00\x10\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x6d\x65\x74\x68\x6f\x64\x01\x07\x01\x6b\x02\x01\x6f\x02\x02\x03\x01\x40\x01\x01\x78\x08\x00\x09\x04\x00\x01\x66\x01\x0a\x04\x02\x0f\x74\x65\x73\x74\x3a\x72\x6f\x6f\x74\x2f\x61\x70\x69\x40\x31\x01\x01\x04\x2e\x32\x2e\x33\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\xae\x02\x01\x41\x02\x01\x41\x04\x01\x42\x0e\x04\x00\x01\x72\x03\x01\x01\x70\x79\x04\x00\x01\x74\x03\x00\x01\x01\x69\x00\x01\x40\x00\x00\x03\x04\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x04\x01\x68\x00\x01\x70\x79\x01\x40\x02\x04\x73\x65\x6c\x66\x05\x01\x78\x06\x01\x00\x04\x00\x10\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x6d\x65\x74\x68\x6f\x64\x01\x07\x01\x6b\x02\x01\x6f\x02\x02\x03\x01\x40\x01\x01\x78\x08\x00\x09\x04\x00\x01\x66\x01\x0a\x03\x02\x0f\x74\x65\x73\x74\x3a\x72\x6f\x6f\x74\x2f\x61\x70\x69\x40\x31\x01\x01\x04\x2e\x32\x2e\x33\x05\x00\x01\x42\x0e\x04\x00\x01\x72\x03\x01\x01\x70\x79\x04\x00\x01\x74\x03\x00\x01\x01\x69\x00\x01\x40\x00\x00\x03\x04\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x04\x01\x68\x00\x01\x70\x79\x01\x40\x02\x04\x73\x65\x6c\x66\x05\x01\x78\x06\x01\x00\x04\x00\x10\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x6d\x65\x74\x68\x6f\x64\x01\x07\x01\x6b\x02\x01\x6f\x02\x02\x03\x01\x40\x01\x01\x78\x08\x00\x09\x04\x00\x01\x66\x01\x0a\x04\x02\x0f\x74\x65\x73\x74\x3a\x72\x6f\x6f\x74\x2f\x61\x70\x69\x40\x31\x01\x01\x04\x2e\x32\x2e\x33\x05\x01\x04\x00\x13\x74\x65\x73\x74\x3a\x72\x6f\x6f\x74\x2f\x61\x70\x70\x40\x31\x2e\x32\x2e\x33\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\xc1\x02\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x22\x69\x6e\x74\x65\x72\x66\x61\x63\x65\x73\x22\x3a\x7b\x22\x61\x70\x69\x22\x3a\x7b\x22\x66\x75\x6e\x63\x73\x22\x3a\x7b\x22\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x73\x69\x6e\x63\x65\x22\x3a\x22\x31\x2e\x32\x2e\x33\x22\x7d\x7d\x7d\x2c\x22\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x6d\x65\x74\x68\x6f\x64\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x73\x69\x6e\x63\x65\x22\x3a\x22\x31\x2e\x32\x2e\x33\x22\x7d\x7d\x7d\x2c\x22\x66\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x73\x69\x6e\x63\x65\x22\x3a\x22\x31\x2e\x32\x2e\x33\x22\x7d\x7d\x7d\x7d\x2c\x22\x74\x79\x70\x65\x73\x22\x3a\x7b\x22\x72\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x73\x69\x6e\x63\x65\x22\x3a\x22\x31\x2e\x32\x2e\x33\x22\x7d\x7d\x7d\x2c\x22\x74\x22\x3a\x7b\x22\x73\x74\x61\x62\x69\x6c\x69\x74\x79\x22\x3a\x7b\x22\x73\x74\x61\x62\x6c\x65\x22\x3a\x7b\x22\x73\x69\x6e\x63\x65\x22\x3a\x22\x31\x2e\x32\x2e\x33\x22\x7d\x7d\x7d\x7d\x7d\x7d\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30"

  let expected = @verifier.resolve({
    documents: [section_document("model.wit", source)],
  }).unwrap()
  for
    decoded in [
      @verifier.decode_package(bytes),
      @verifier.decode_wat_package(text),
    ] {
    let input = decoded.unwrap()
    let model = @verifier.resolve_packages(Encoded(input)).unwrap()
    assert_eq(model.root().key(), "test:root@1.2.3")
    assert_eq(
      encoded_alias_model(model, reachable_only=true),
      encoded_alias_model(expected, reachable_only=true),
    )
    assert_eq(
      model.interfaces().map(info => info.stability),
      expected.interfaces().map(info => info.stability),
    )
    assert_eq(
      model.functions().map(info => (info.name, info.stability)),
      expected.functions().map(info => (info.name, info.stability)),
    )
    let named = model.types().filter(info => info.name is Some(_))
    let expected_named = expected.types().filter(info => info.name is Some(_))
    assert_eq(
      named.map(info => (info.name, info.stability)),
      expected_named.map(info => (info.name, info.stability)),
    )
    assert_eq(model.worlds()[0].imports.length(), 1)
    assert_eq(model.worlds()[0].exports.length(), 1)
    assert_eq(model.sources().length(), 0)
    for info in model.types() {
      assert_eq(info.location.position, BinaryOffset(None))
    }
  }
}

///|
test "canonical foreign names bind supplied full-version resource interfaces" {
  let source = "package test:root;world app{import test:dep/base@1.0.0;}package test:dep@1.0.0{interface base{@since(version=1.0.0) resource r{@since(version=1.0.0) constructor();@since(version=1.0.0) method:func(x:list<u32>);}@since(version=1.0.0) type t=list<u32>;@since(version=1.0.0) f:func(x:option<t>)->tuple<t,r>;}}"
  let dependency = "package test:dep@1.0.0;interface base{@since(version=1.0.0) resource r{@since(version=1.0.0) constructor();@since(version=1.0.0) method:func(x:list<u32>);}@since(version=1.0.0) type t=list<u32>;@since(version=1.0.0) f:func(x:option<t>)->tuple<t,r>;}"
  let text = "(component\n  (type (;0;)\n    (component\n      (type (;0;)\n        (component\n          (type (;0;)\n            (instance\n              (export (;0;) \"r\" (type (sub resource)))\n              (type (;1;) (list u32))\n              (export (;2;) \"t\" (type (eq 1)))\n              (type (;3;) (own 0))\n              (type (;4;) (func (result 3)))\n              (export (;0;) \"[constructor]r\" (func (type 4)))\n              (type (;5;) (borrow 0))\n              (type (;6;) (list u32))\n              (type (;7;) (func (param \"self\" 5) (param \"x\" 6)))\n              (export (;1;) \"[method]r.method\" (func (type 7)))\n              (type (;8;) (option 2))\n              (type (;9;) (tuple 2 3))\n              (type (;10;) (func (param \"x\" 8) (result 9)))\n              (export (;2;) \"f\" (func (type 10)))\n            )\n          )\n          (import \"test:dep/base@1\" (version-suffix \".0.0\") (instance (;0;) (type 0)))\n        )\n      )\n      (export (;0;) \"test:root/app\" (component (type 0)))\n    )\n  )\n  (export (;1;) \"app\" (type 0))\n  (@custom \"package-docs\" \"\\01{}\")\n  (@producers\n    (processed-by \"wit-component\" \"0.262.0\")\n  )\n)\n"
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\xa0\x01\x01\x41\x02\x01\x41\x02\x01\x42\x0e\x04\x00\x01\x72\x03\x01\x01\x70\x79\x04\x00\x01\x74\x03\x00\x01\x01\x69\x00\x01\x40\x00\x00\x03\x04\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x04\x01\x68\x00\x01\x70\x79\x01\x40\x02\x04\x73\x65\x6c\x66\x05\x01\x78\x06\x01\x00\x04\x00\x10\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x6d\x65\x74\x68\x6f\x64\x01\x07\x01\x6b\x02\x01\x6f\x02\x02\x03\x01\x40\x01\x01\x78\x08\x00\x09\x04\x00\x01\x66\x01\x0a\x03\x02\x0f\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x62\x61\x73\x65\x40\x31\x01\x01\x04\x2e\x30\x2e\x30\x05\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x72\x6f\x6f\x74\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x36\x32\x2e\x30"

  let expected = @verifier.resolve({
    documents: [section_document("source.wit", source)],
  }).unwrap()
  for
    decoded in [
      @verifier.decode_package(bytes),
      @verifier.decode_wat_package(text),
    ] {
    for binary_first in [true, false] {
      let supplied = @verifier.SourcePackage::{
        documents: [section_document("dep.wit", dependency)],
      }
      let encoded = @verifier.PackageInput::Encoded(decoded.unwrap())
      let source = @verifier.PackageInput::Source(supplied)
      let model = if binary_first {
        @verifier.resolve_packages(encoded, dependencies=[source]).unwrap()
      } else {
        @verifier.resolve_packages(source, dependencies=[encoded]).unwrap()
      }
      assert_eq(model.interfaces().length(), 1)
      assert_eq(model.interfaces()[0].package_identity.key(), "test:dep@1.0.0")
      assert_eq(
        encoded_alias_model(model, reachable_only=true),
        encoded_alias_model(expected, reachable_only=true),
      )
      assert_eq(model.sources().length(), 1)
      assert_eq(model.binaries().length(), 1)
    }
  }
}
