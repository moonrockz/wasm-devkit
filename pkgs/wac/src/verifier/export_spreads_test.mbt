// Original export probes compared with pinned WAC 0.12.0 Document::resolve.
// Validating compose agrees except the resource constructor case; the pin
// reports the same export-name error when explicit exports replace the spread.

// (component
//   (type (component
//     (type (instance
//       (type (instance (type (func)) (export "f" (func (type 0)))))
//       (export "test:api/run@1.0.0" (instance (type 0)))
//       (export "test:api/run@1.2.0" (instance (type 0)))))
//     (export "test:dep/api" (instance (type 0)))))
//   (export "api" (type 0)))

///|
fn export_qualified_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x53\x01\x41\x02\x01\x42\x03\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x30\x2e\x30\x05\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x04\x00\x0c\x74\x65\x73\x74\x3a\x64\x65\x70\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x00\x00"
}

///|
test "pinned export spread simple" {
  let source = "package test:app; import i: interface {f: func(); g: func();}; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "import:i", "instance", "interface", "", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "alias:0:f",
    "func", "function", "false", "0", "none", "alias:0:g", "func", "function", "false",
    "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "1", "alias", "0", "f", "2", "alias", "0", "g",
  ])
  assert_eq(model.composition_exports().map(item => item.name), ["f", "g"])
  assert_eq(model.exports().map(item => item.name), ["f", "g"])
}

///|
test "pinned export spread named" {
  let source = "package test:app; interface api {f: func(); g: func();} import i: api; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "4", "definition", "type", "interface", "test:app/api", "0", "2", "f", "func",
    "function", "false", "0", "none", "g", "func", "function", "false", "0", "none",
    "import:i", "instance", "interface", "test:app/api", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "alias:1:f",
    "func", "function", "false", "0", "none", "alias:1:g", "func", "function", "false",
    "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "2", "alias", "1", "f", "3", "alias", "1", "g",
  ])
  assert_eq(model.composition_exports().map(item => item.name), [
    "api", "f", "g",
  ])
  assert_eq(model.exports().map(item => item.name), ["api", "f", "g"])
}

///|
test "pinned export spread group" {
  let source = "package test:app; import i: interface {f: func();}; export (((i)))...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "2", "import:i", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "0", "none", "alias:0:f", "func", "function", "false", "0", "none",
    "0",
  ])
  assert_eq(composition_edges(model), ["1", "alias", "0", "f"])
  assert_eq(model.composition_exports().map(item => item.name), ["f"])
  assert_eq(model.exports().map(item => item.name), ["f"])
}

///|
test "pinned export spread alias" {
  let source = "package test:app; import i: interface {f: func();}; let j=i; export j...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "2", "import:i", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "0", "none", "alias:0:f", "func", "function", "false", "0", "none",
    "0",
  ])
  assert_eq(composition_edges(model), ["1", "alias", "0", "f"])
  assert_eq(model.composition_exports().map(item => item.name), ["f"])
  assert_eq(model.exports().map(item => item.name), ["f"])
}

///|
test "pinned export spread prior-explicit" {
  let source = "package test:app; import i: interface {f: func();g: func();}; import f: func(x: u32); export f; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "import:i", "instance", "interface", "", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "import:f",
    "func", "function", "false", "1", "x", "scalar", "u32", "none", "alias:0:g",
    "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), ["2", "alias", "0", "g"])
  assert_eq(model.composition_exports().map(item => item.name), ["f", "g"])
  assert_eq(model.exports().map(item => item.name), ["f", "g"])
}

///|
test "pinned export spread prior-spread" {
  let source = "package test:app; import i: interface {f: func();g: func();}; import j: interface {f: func(x: u32);h: func();}; export i...; export j...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "5", "import:i", "instance", "interface", "", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "import:j",
    "instance", "interface", "", "0", "2", "f", "func", "function", "false", "1",
    "x", "scalar", "u32", "none", "h", "func", "function", "false", "0", "none",
    "alias:0:f", "func", "function", "false", "0", "none", "alias:0:g", "func", "function",
    "false", "0", "none", "alias:1:h", "func", "function", "false", "0", "none",
    "0",
  ])
  assert_eq(composition_edges(model), [
    "2", "alias", "0", "f", "3", "alias", "0", "g", "4", "alias", "1", "h",
  ])
  assert_eq(model.composition_exports().map(item => item.name), ["f", "g", "h"])
  assert_eq(model.exports().map(item => item.name), ["f", "g", "h"])
}

///|
test "pinned export spread prior-rename" {
  let source = "package test:app; import i: interface {f: func();g: func();}; export i.g as f; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "2", "import:i", "instance", "interface", "", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "alias:0:g",
    "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), ["1", "alias", "0", "g"])
  assert_eq(model.composition_exports().map(item => item.name), ["f", "g"])
  assert_eq(model.exports().map(item => item.name), ["f", "g"])
}

///|
test "pinned export spread cached-alias" {
  let source = "package test:app; import i: interface {f: func();g: func();}; let f=i.f; export f as other; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "import:i", "instance", "interface", "", "0", "2", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "0", "none", "alias:0:f",
    "func", "function", "false", "0", "none", "alias:0:g", "func", "function", "false",
    "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "1", "alias", "0", "f", "2", "alias", "0", "g",
  ])
  assert_eq(model.composition_exports().map(item => item.name), [
    "other", "f", "g",
  ])
  assert_eq(model.exports().map(item => item.name), ["other", "f", "g"])
}

///|
test "pinned export spread empty" {
  let source = "package test:app; import i: interface {}; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C007")
}

///|
test "pinned export spread repeated" {
  let source = "package test:app; import i: interface {f: func();}; export i...; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C007")
}

///|
test "pinned export spread all-prior" {
  let source = "package test:app; import i: interface {f: func();}; export i.f; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C007")
}

///|
test "pinned export spread function" {
  let source = "package test:app; import f: func(); export f...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C007")
}

///|
test "pinned export spread definition" {
  let source = "package test:app; interface api {f: func();} export api...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C007")
}

///|
test "pinned export spread scalar" {
  let source = "package test:app; type t=u32; export t...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C007")
}

///|
test "pinned export spread component" {
  let source = "package test:app; world api {} import c: api; export c...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-C007")
}

///|
test "pinned export spread duplicate-after" {
  let source = "package test:app; import i: interface {f: func();}; export i...; export i.f;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-S004")
}

///|
test "pinned export spread new-export-after" {
  let source = "package test:app; import i: interface {f: func();}; export i...; export i.f as other;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "2", "import:i", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "0", "none", "alias:0:f", "func", "function", "false", "0", "none",
    "0",
  ])
  assert_eq(composition_edges(model), ["1", "alias", "0", "f"])
  assert_eq(model.composition_exports().map(item => item.name), ["f", "other"])
  assert_eq(model.exports().map(item => item.name), ["f", "other"])
}

///|
test "pinned export spread definition-skip" {
  let source = "package test:app; type t=u32; import i: interface {type t=string;f: func();}; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "definition", "type", "scalar", "u32", "import:i", "instance", "interface",
    "", "0", "2", "t", "type", "scalar", "string", "f", "func", "function", "false",
    "0", "none", "alias:1:f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), ["2", "alias", "1", "f"])
  assert_eq(model.composition_exports().map(item => item.name), ["t", "f"])
  assert_eq(model.exports().map(item => item.name), ["t", "f"])
}

///|
test "pinned export spread definition-alias-conflict" {
  let source = "package test:app; interface api {x: func();} let x=api; import i: api; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-S004")
}

///|
test "pinned export spread explicit-definition-alias-conflict" {
  let source = "package test:app; interface api {x: func();} let x=api; import i: api; export i.x;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-S004")
}

///|
test "pinned export spread resources" {
  let source = "package test:app; import i: interface {resource handle {constructor(); take: func();} type handles=list<handle>;}; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "5", "import:i", "instance", "interface", "", "0", "4", "handle", "type", "resource",
    "0", "[constructor]handle", "func", "function", "false", "0", "some", "own",
    "0", "[method]handle.take", "func", "function", "false", "1", "self", "borrow",
    "0", "none", "handles", "type", "list", "own", "0", "alias:0:handle", "type",
    "resource", "0", "alias:0:[constructor]handle", "func", "function", "false",
    "0", "some", "own", "0", "alias:0:[method]handle.take", "func", "function", "false",
    "1", "self", "borrow", "0", "none", "alias:0:handles", "type", "list", "own",
    "0", "0",
  ])
  assert_eq(composition_edges(model), [
    "1", "alias", "0", "handle", "2", "alias", "0", "[constructor]handle", "3", "alias",
    "0", "[method]handle.take", "4", "alias", "0", "handles",
  ])
  assert_eq(model.composition_exports().map(item => item.name), [
    "handle", "[constructor]handle", "[method]handle.take", "handles",
  ])
  assert_eq(model.exports().map(item => item.name), [
    "handle", "[constructor]handle", "[method]handle.take", "handles",
  ])
}

///|
test "pinned export spread resource-cache" {
  let source = "package test:app; import i: interface {resource handle; take: func(h: handle);}; let h=i.handle; export h as renamed; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "import:i", "instance", "interface", "", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "alias:0:handle",
    "type", "resource", "0", "alias:0:take", "func", "function", "false", "1", "h",
    "own", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "1", "alias", "0", "handle", "2", "alias", "0", "take",
  ])
  assert_eq(model.composition_exports().map(item => item.name), [
    "renamed", "handle", "take",
  ])
  assert_eq(model.exports().map(item => item.name), [
    "renamed", "handle", "take",
  ])
}

///|
test "pinned export spread resource-skip" {
  let source = "package test:app; import a: interface {resource handle;}; import b: interface {resource handle; take: func(h: handle);}; export a...; export b...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "4", "import:a", "instance", "interface", "", "0", "1", "handle", "type", "resource",
    "0", "import:b", "instance", "interface", "", "0", "2", "handle", "type", "resource",
    "1", "take", "func", "function", "false", "1", "h", "own", "1", "none", "alias:0:handle",
    "type", "resource", "0", "alias:1:take", "func", "function", "false", "1", "h",
    "own", "1", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "2", "alias", "0", "handle", "3", "alias", "1", "take",
  ])
  assert_eq(model.composition_exports().map(item => item.name), [
    "handle", "take",
  ])
  assert_eq(model.exports().map(item => item.name), ["handle", "take"])
}

///|
test "pinned export spread unresolved" {
  let source = "package test:app; export missing...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-S005")
}

///|
test "pinned export spread qualified" {
  let source = "package test:app; import i: lookup:dep/api; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
    dependencies=[
      {
        name: "lookup:dep",
        version: None,
        source: "qualified.wasm",
        bytes: export_qualified_bytes(),
      },
    ],
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "import:lookup:dep/api", "instance", "interface", "test:dep/api", "0", "2",
    "test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0", "0", "1",
    "f", "func", "function", "false", "0", "none", "test:api/run@1.2.0", "instance",
    "interface", "test:api/run@1.0.0", "0", "1", "f", "func", "function", "false",
    "0", "none", "alias:0:test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@1.2.0",
    "instance", "interface", "test:api/run@1.0.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "1", "alias", "0", "test:api/run@1.0.0", "2", "alias", "0", "test:api/run@1.2.0",
  ])
  assert_eq(model.composition_exports().map(item => item.name), [
    "test:api/run@1.0.0", "test:api/run@1.2.0",
  ])
  assert_eq(model.exports().map(item => item.name), [
    "test:api/run@1.0.0", "test:api/run@1.2.0",
  ])
}

///|
test "pinned export spread qualified-prior" {
  let source = "package test:app; import i: lookup:dep/api; export i[\"test:api/run@1.0.0\"]; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
    dependencies=[
      {
        name: "lookup:dep",
        version: None,
        source: "qualified.wasm",
        bytes: export_qualified_bytes(),
      },
    ],
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "import:lookup:dep/api", "instance", "interface", "test:dep/api", "0", "2",
    "test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0", "0", "1",
    "f", "func", "function", "false", "0", "none", "test:api/run@1.2.0", "instance",
    "interface", "test:api/run@1.0.0", "0", "1", "f", "func", "function", "false",
    "0", "none", "alias:0:test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@1.2.0",
    "instance", "interface", "test:api/run@1.0.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "1", "alias", "0", "test:api/run@1.0.0", "2", "alias", "0", "test:api/run@1.2.0",
  ])
  assert_eq(model.composition_exports().map(item => item.name), [
    "test:api/run@1.0.0", "test:api/run@1.2.0",
  ])
  assert_eq(model.exports().map(item => item.name), [
    "test:api/run@1.0.0", "test:api/run@1.2.0",
  ])
}

///|
test "pinned export spread qualified-distinct-version" {
  let source = "package test:app; import i: lookup:dep/api; export i[\"test:api/run@1.0.0\"] as \"test:api/run@1.1.0\"; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
    dependencies=[
      {
        name: "lookup:dep",
        version: None,
        source: "qualified.wasm",
        bytes: export_qualified_bytes(),
      },
    ],
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "import:lookup:dep/api", "instance", "interface", "test:dep/api", "0", "2",
    "test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0", "0", "1",
    "f", "func", "function", "false", "0", "none", "test:api/run@1.2.0", "instance",
    "interface", "test:api/run@1.0.0", "0", "1", "f", "func", "function", "false",
    "0", "none", "alias:0:test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:0:test:api/run@1.2.0",
    "instance", "interface", "test:api/run@1.0.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "1", "alias", "0", "test:api/run@1.0.0", "2", "alias", "0", "test:api/run@1.2.0",
  ])
  assert_eq(model.composition_exports().map(item => item.name), [
    "test:api/run@1.1.0", "test:api/run@1.0.0", "test:api/run@1.2.0",
  ])
  assert_eq(model.exports().map(item => item.name), [
    "test:api/run@1.1.0", "test:api/run@1.0.0", "test:api/run@1.2.0",
  ])
}

///|
test "pinned export spread qualified-nested" {
  let source = "package test:app; import i: lookup:dep/api; export i[\"test:api/run@1.0.0\"]...;"
  assert_true(@parser.parse(source).is_valid())
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="exports.wac",
    dependencies=[
      {
        name: "lookup:dep",
        version: None,
        source: "qualified.wasm",
        bytes: export_qualified_bytes(),
      },
    ],
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  let model = result.unwrap()
  assert_eq(composition_projection(model), [
    "3", "import:lookup:dep/api", "instance", "interface", "test:dep/api", "0", "2",
    "test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0", "0", "1",
    "f", "func", "function", "false", "0", "none", "test:api/run@1.2.0", "instance",
    "interface", "test:api/run@1.0.0", "0", "1", "f", "func", "function", "false",
    "0", "none", "alias:0:test:api/run@1.0.0", "instance", "interface", "test:api/run@1.0.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "alias:1:f", "func",
    "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "1", "alias", "0", "test:api/run@1.0.0", "2", "alias", "1", "f",
  ])
  assert_eq(model.composition_exports().map(item => item.name), ["f"])
  assert_eq(model.exports().map(item => item.name), ["f"])
}
