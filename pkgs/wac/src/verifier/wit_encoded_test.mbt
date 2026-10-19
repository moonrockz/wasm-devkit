// Encodings from pinned WAC WIT 0.258.0; original sources in tests/semantic/wac-wit-providers.

///|
test "adapt encoded WIT package input" {
  let encoded = @wit_verifier.decode_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x27\x01\x41\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x79\x70\x65\x73\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00\x07\x64\x01\x41\x02\x01\x41\x04\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x79\x70\x65\x73\x2f\x61\x70\x69\x05\x00\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x79\x70\x65\x73\x2f\x61\x70\x69\x05\x01\x04\x00\x11\x65\x78\x61\x6d\x70\x6c\x65\x3a\x74\x79\x70\x65\x73\x2f\x61\x70\x70\x04\x00\x0b\x09\x01\x00\x03\x61\x70\x70\x03\x02\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x35\x38\x2e\x30",
    source_id="encoded.wasm",
  ).unwrap()
  let adapted = @verifier.resolve_wit_package(
    @wit_verifier.PackageInput::Encoded(encoded),
  ).unwrap()
  assert_eq(wit_projection(adapted), [
    "world", "", "0", "0", "2", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "instance", "interface",
    "", "0", "2", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "2",
    "api", "type", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "app", "type", "world", "example:types/app", "0", "1",
    "example:types/api", "instance", "interface", "example:types/api", "0", "1",
    "f", "func", "function", "false", "0", "none", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none",
  ])
  assert_true(adapted.types().any(ty => ty.location.source == "encoded.wasm"))
}

///|
test "adapt a mixed WIT source and encoded closure" {
  let encoded = @wit_verifier.decode_package(
    b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x2d\x01\x41\x02\x01\x42\x01\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x04\x00\x17\x65\x78\x61\x6d\x70\x6c\x65\x3a\x64\x65\x70\x2f\x74\x79\x70\x65\x73\x40\x31\x2e\x32\x2e\x33\x05\x00\x0b\x0b\x01\x00\x05\x74\x79\x70\x65\x73\x03\x00\x00\x00\x10\x0c\x70\x61\x63\x6b\x61\x67\x65\x2d\x64\x6f\x63\x73\x01\x7b\x7d\x00\x2f\x09\x70\x72\x6f\x64\x75\x63\x65\x72\x73\x01\x0c\x70\x72\x6f\x63\x65\x73\x73\x65\x64\x2d\x62\x79\x01\x0d\x77\x69\x74\x2d\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x07\x30\x2e\x32\x35\x38\x2e\x30",
    source_id="dep.wasm",
  ).unwrap()
  let adapted = @verifier.resolve_wit_package(
    @wit_verifier.PackageInput::Source({
      documents: [
        wit_document(
          "root.wit", "package example:types; interface api {use example:dep/types@1.2.3.{handle};take: func(h: handle);} world app {import api;export api;}",
        ),
        wit_document(
          "second.wit", "package example:types; interface extra {f: func();}",
        ),
      ],
    }),
    dependencies=[@wit_verifier.PackageInput::Encoded(encoded)],
  ).unwrap()
  assert_eq(wit_projection(adapted), [
    "world", "", "0", "0", "3", "api", "type", "world", "", "0", "1", "example:dep/types@1.2.3",
    "instance", "interface", "example:dep/types@1.2.3", "0", "1", "handle", "type",
    "resource", "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "handle", "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "extra",
    "type", "world", "", "0", "0", "1", "example:types/extra", "instance", "interface",
    "example:types/extra", "0", "1", "f", "func", "function", "false", "0", "none",
    "app", "type", "world", "", "0", "0", "1", "example:types/app", "component",
    "world", "example:types/app", "0", "2", "example:dep/types@1.2.3", "instance",
    "interface", "example:dep/types@1.2.3", "0", "1", "handle", "type", "resource",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource",
    "1", "take", "func", "function", "false", "1", "h", "own", "1", "none", "1",
    "example:types/api", "instance", "interface", "example:types/api", "1", "handle",
    "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource", "1",
    "take", "func", "function", "false", "1", "h", "own", "1", "none", "instance",
    "interface", "", "0", "3", "api", "type", "world", "", "0", "1", "example:dep/types@1.2.3",
    "instance", "interface", "example:dep/types@1.2.3", "0", "1", "handle", "type",
    "resource", "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "handle", "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "extra",
    "type", "world", "", "0", "0", "1", "example:types/extra", "instance", "interface",
    "example:types/extra", "0", "1", "f", "func", "function", "false", "0", "none",
    "app", "type", "world", "", "0", "0", "1", "example:types/app", "component",
    "world", "example:types/app", "0", "2", "example:dep/types@1.2.3", "instance",
    "interface", "example:dep/types@1.2.3", "0", "1", "handle", "type", "resource",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource",
    "1", "take", "func", "function", "false", "1", "h", "own", "1", "none", "1",
    "example:types/api", "instance", "interface", "example:types/api", "1", "handle",
    "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource", "1",
    "take", "func", "function", "false", "1", "h", "own", "1", "none", "definitions",
    "3", "api", "type", "interface", "example:types/api", "1", "handle", "handle",
    "example:dep/types@1.2.3", "2", "handle", "type", "resource", "0", "take", "func",
    "function", "false", "1", "h", "own", "0", "none", "extra", "type", "interface",
    "example:types/extra", "0", "1", "f", "func", "function", "false", "0", "none",
    "app", "type", "world", "example:types/app", "0", "2", "example:dep/types@1.2.3",
    "instance", "interface", "example:dep/types@1.2.3", "0", "1", "handle", "type",
    "resource", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "handle", "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource",
    "1", "take", "func", "function", "false", "1", "h", "own", "1", "none", "1",
    "example:types/api", "instance", "interface", "example:types/api", "1", "handle",
    "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource", "1",
    "take", "func", "function", "false", "1", "h", "own", "1", "none",
  ])
  assert_true(adapted.types().any(ty => ty.location.source == "dep.wasm"))
}
