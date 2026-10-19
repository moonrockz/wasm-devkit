// Upstream WAC0.12.0 resolution groups; original inputs/licenses in tests/semantic/wac-upstream/.

///|
test "upstream WAC alias.wac" {
  let source = "package test:comp@1.0.0;\n\ntype a = u32;\n\ntype b = string;\n\ntype c = func();\n\nexport a as \"a2\";\nexport b as \"b2\";\nexport c as \"c2\";\n"
  let result = corpus_verify(source~, source_id="alias.wac", dependencies=[], wit_dependencies=[])
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
    "3", "definition", "type", "scalar", "u32", "definition", "type", "scalar", "string",
    "definition", "type", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["a:0", "b:1", "c:2", "a2:0", "b2:1", "c2:2"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["a2", "b2", "c2"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["a2", "b2", "c2"])
}

///|
test "upstream WAC duplicate-world-item.wac" {
  let source = "package test:comp@2.0.0;\n\nworld w {\n    import x: func();\n    export x: func();\n}"
  let result = corpus_verify(
    source~,
    source_id="duplicate-world-item.wac",
    dependencies=[],
    wit_dependencies=[],
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
    "1", "definition", "type", "world", "test:comp/w@2.0.0", "0", "1", "x", "func",
    "function", "false", "0", "none", "1", "x", "func", "function", "false", "0",
    "none", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["w:0"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["w"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["w"])
}

///|
test "upstream WAC fail/borrow-in-func-result.wac" {
  let source = "package test:comp;\n\ninterface foo {\n    resource x;\n    type a = borrow<x>;\n    f: func() -> result<a>;\n}\n"
  let result = corpus_verify(
    source~,
    source_id="fail/borrow-in-func-result.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-enum-case.wac" {
  let source = "package test:comp;\n\nenum e {\n    a,\n    b,\n    c,\n    b,\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-enum-case.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-export.wac" {
  let source = "package test:comp;\n\nimport foo: func();\n\nexport foo as \"foo\";\nexport foo as foo;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-export.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-flag.wac" {
  let source = "package test:comp;\n\nflags f {\n    a,\n    b,\n    c,\n    d,\n    a,\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-flag.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-func-param.wac" {
  let source = "package test:comp;\n\ntype f = func(x: u32, x: string);"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-func-param.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-import.wac" {
  let source = "package test:comp;\n\nimport foo as \"foo\": func();\nimport bar as foo: func();\n"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-import.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-inst-args.wac" {
  let source = "package test:comp;\n\nimport bar: func();\n\nlet x = new foo:bar { foo: bar, foo: bar };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-inst-args.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/duplicate-inst-args/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x08\x01\x00\x03\x66\x6f\x6f\x01\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-interface-export.wac" {
  let source = "package test:comp;\n\ninterface x {\n    x: func();\n    x: func();\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-interface-export.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-name-in-include.wac" {
  let source = "package test:comp;\n\nworld w1 {\n\n}\n\nworld w2 {\n    include w1 with { a as b, a as c};\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-name-in-include.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-record-field.wac" {
  let source = "package test:comp;\n\ntype x = string;\n\nrecord r {\n    a: s8,\n    b: u8,\n    c: x,\n    b: string,\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-record-field.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-resource-constructor-param.wac" {
  let source = "package test:comp;\n\ninterface foo {\n    resource x {\n        constructor(a: u32, a: string);\n    }\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-resource-constructor-param.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-resource-constructor.wac" {
  let source = "package test:comp;\n\ninterface foo {\n    resource x {\n        constructor();\n        constructor(x: u32);\n    }\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-resource-constructor.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-resource-method.wac" {
  let source = "package test:comp;\n\nworld foo {\n    resource x {\n        x: func();\n        x: static func();\n    }\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-resource-method.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-use-in-interface.wac" {
  let source = "package foo:bar;\n\ninterface i {\n    type x = u32;\n}\n\ninterface i2 {\n    x: func();\n    use i.{x};\n}\n"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-use-in-interface.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-use-in-world.wac" {
  let source = "package foo:bar;\n\ninterface i {\n    type x = u32;\n}\n\nworld w {\n    import x: func();\n    use i.{x};\n}\n"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-use-in-world.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-variant-case.wac" {
  let source = "package test:comp;\n\ntype x = string;\n\nvariant x {\n    a(x),\n    b,\n    a,\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-variant-case.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-world-export.wac" {
  let source = "package test:comp;\n\nworld w {\n    export x: func();\n    export x: func();\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-world-export.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/duplicate-world-import.wac" {
  let source = "package test:comp;\n\nworld w {\n    import x: func();\n    import x: func();\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/duplicate-world-import.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/expected-result-named.wac" {
  assert_true(
    @verifier.decode_wat_component_package(
      "(component\n  (instance (import \"x\")\n    (export \"f\" (func (result \"a\" string)))\n  )\n)\n",
    )
    is Err(_),
  )
}

///|
test "upstream WAC fail/expected-result-scalar.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func();\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/expected-result-scalar.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/expected-result-scalar/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-conflict-alias.wac" {
  let source = "package test:comp;\n\nimport f as \"x\": func();\n\ntype x = u32;\n\nexport f;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/export-conflict-alias.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-conflict-interface.wac" {
  let source = "package test:comp;\n\nimport f: func();\n\ninterface foo {\n\n}\n\nexport f as \"foo\";\n"
  let result = corpus_verify(
    source~,
    source_id="fail/export-conflict-interface.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-conflict-type.wac" {
  let source = "package test:comp;\n\nimport f as \"x\": func();\n\nrecord x {\n    a: u32\n}\n\nexport f as \"x\";\n"
  let result = corpus_verify(
    source~,
    source_id="fail/export-conflict-type.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-conflict-world.wac" {
  let source = "package test:comp;\n\nimport f: func();\n\nworld foo {\n\n}\n\nexport f as \"foo\";\n"
  let result = corpus_verify(
    source~,
    source_id="fail/export-conflict-world.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-dep-name.wac" {
  let source = "package test:comp;\n\nimport f: func();\nexport f as \"locked-dep=<foo:bar>\";"
  let result = corpus_verify(
    source~,
    source_id="fail/export-dep-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-duplicate-name.wac" {
  let source = "package test:comp;\n\nimport f: func();\nexport f as \"x\";\nexport f as \"x\";\n"
  let result = corpus_verify(
    source~,
    source_id="fail/export-duplicate-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-hash-name.wac" {
  let source = "package test:comp;\n\nimport f: func();\nexport f as \"integrity=<sha256-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855>\";"
  let result = corpus_verify(
    source~,
    source_id="fail/export-hash-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-invalid-name.wac" {
  let source = "package test:comp;\n\nimport f: func();\nexport f as \"INVALID!\";"
  let result = corpus_verify(
    source~,
    source_id="fail/export-invalid-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-needs-with.wac" {
  let source = "package test:comp;\n\nlet i = new foo:bar {};\nexport i;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/export-needs-with.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/export-needs-with/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/export-url-name.wac" {
  let source = "package test:comp;\n\nimport f: func();\nexport f as \"url=<https://example.com/foo>\";"
  let result = corpus_verify(
    source~,
    source_id="fail/export-url-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/fill-not-last.wac" {
  let source = "package test:comp;\n\nlet x = new foo:bar { ..., a };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/fill-not-last.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/fill-not-last/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/func-results-not-present.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func();\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/func-results-not-present.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/func-results-not-present/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/func-results-present.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> string;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/func-results-present.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/func-results-present/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/import-duplicate-name.wac" {
  let source = "package test:comp;\n\nimport x as \"foo\": func();\nimport y as \"foo\": interface {};\n"
  let result = corpus_verify(
    source~,
    source_id="fail/import-duplicate-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/import-id-span.wac" {
  let source = "package test:comp;\n\nimport env-foo: wasi:cli/environment;\n\nimport env-bar: wasi:cli/environment;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/import-id-span.wac",
    dependencies=[],
    wit_dependencies=[
      {
        name: "wasi:cli",
        version: None,
        source: "fail/import-id-span/wasi/cli",
        root: Source({
          documents: [
            wit_document(
              "fail/import-id-span/wasi/cli/package.wit", "package wasi:cli;\n\ninterface environment {\n}\n",
            ),
          ],
        }),
        dependencies: [],
      },
    ],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/import-invalid-name.wac" {
  let source = "package test:comp;\n\nimport x as \"NOT-VALID-NAME!\": func();\n"
  let result = corpus_verify(
    source~,
    source_id="fail/import-invalid-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/inaccessible.wac" {
  let source = "package test:comp;\n\nimport f: func();\n\nlet x = f.foo;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/inaccessible.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-alias.wac" {
  let source = "package test:comp;\n\ninterface a {\n\n}\n\ntype x = a;"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-alias.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-borrow.wac" {
  let source = "package test:comp;\n\ntype x = u32;\n\ntype y = borrow<x>;"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-borrow.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-func-type-ref.wac" {
  let source = "package test:comp;\n\ninterface i {\n    type x = u32;\n\n    x: x;\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-func-type-ref.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-use-alias.wac" {
  let source = "package test:comp;\n\ninterface a {\n    type a = u32;\n}\n\ninterface b {\n    type b = u32;\n    use a.{a as b};\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-use-alias.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-use.wac" {
  let source = "package test:comp;\n\ntype x = u32;\n\ninterface a {\n    use x.{a};\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-use.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-value-type.wac" {
  let source = "package test:comp;\n\ninterface i {\n\n}\n\ntype x = func(i: i);"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-value-type.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-world-export.wac" {
  let source = "package test:comp;\n\ntype x = u32;\n\nworld w {\n    import x: x;\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-world-export.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-world-import.wac" {
  let source = "package test:comp;\n\ntype x = u32;\n\nworld w {\n    import x: x;\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-world-import.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-world-include.wac" {
  let source = "package test:comp;\n\ntype x = func();\n\nworld w {\n    include x;\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-world-include.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-world-interface-export.wac" {
  let source = "package test:comp;\n\ntype x = u32;\n\nworld w {\n    export x;\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-world-interface-export.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/invalid-world-interface-import.wac" {
  let source = "package test:comp;\n\ntype x = u32;\n\nworld w {\n    import x;\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/invalid-world-interface-import.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-async.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> string;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-async.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-async/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x43\x00\x00\x73\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-enum-cases.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    enum e {\n        a,\n        c,\n        b,\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-enum-cases.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-enum-cases/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x6d\x03\x01\x61\x01\x62\x01\x63\x04\x00\x01\x65\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-enum-count.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    enum e {\n        a,\n        b,\n        c,\n        d,\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-enum-count.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-enum-count/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x6d\x03\x01\x61\x01\x62\x01\x63\x04\x00\x01\x65\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-err-result-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> result<_, string>;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-err-result-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-err-result-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x03\x01\x6a\x00\x01\x7d\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-flags-count.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    flags f {\n        a,\n        b,\n        c,\n        d,\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-flags-count.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-flags-count/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x6e\x03\x01\x61\x01\x62\x01\x63\x04\x00\x01\x66\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-flags.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    flags f {\n        a,\n        c,\n        b,\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-flags.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-flags/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x02\x01\x6e\x03\x01\x61\x01\x62\x01\x63\x04\x00\x01\x66\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-func-param-name.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func(b: u32);\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-func-param-name.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-func-param-name/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x61\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-func-param-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    resource r;\n    f: func(r: string);\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-func-param-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-func-param-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1a\x01\x42\x04\x04\x00\x01\x72\x03\x01\x01\x68\x00\x01\x40\x01\x01\x72\x01\x01\x00\x04\x00\x01\x66\x01\x02\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-func-params.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func();\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-func-params.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-func-params/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x11\x01\x42\x02\x01\x40\x01\x01\x78\x79\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-func-scalar-result.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> string;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-func-scalar-result.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-func-scalar-result/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x00\x7d\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-kind.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    type x = u32;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-kind.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-kind/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x78\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-list-element.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func(l: list<string>);\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-list-element.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-list-element/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x42\x03\x01\x70\x7d\x01\x40\x01\x01\x6c\x00\x01\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-ok-result-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> result<string>;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-ok-result-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-ok-result-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x03\x01\x6a\x01\x7d\x00\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-option.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func(o: option<u8>);\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-option.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-option/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x42\x03\x01\x6b\x73\x01\x40\x01\x01\x6f\x00\x01\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-record-field-count.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    record r {\n        a: u8,\n        b: u16,\n        c: u32,\n        d: u64,\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-record-field-count.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-record-field-count/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x02\x01\x72\x03\x01\x61\x7d\x01\x62\x7b\x01\x63\x79\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-record-field-name.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    record r {\n        a: u8,\n        c: u16,\n        b: u32,\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-record-field-name.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-record-field-name/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x02\x01\x72\x03\x01\x61\x7d\x01\x62\x7b\x01\x63\x79\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-record-field-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    record r {\n        a: u8,\n        b: string,\n        c: u32,\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-record-field-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-record-field-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x02\x01\x72\x03\x01\x61\x7d\x01\x62\x7b\x01\x63\x79\x04\x00\x01\x72\x03\x00\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-resource-types.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    resource x;\n    resource y;\n    f: func(x: y);\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-resource-types.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-resource-types/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x05\x04\x00\x01\x78\x03\x01\x04\x00\x01\x79\x03\x01\x01\x69\x00\x01\x40\x01\x01\x78\x02\x01\x00\x04\x00\x01\x66\x01\x03\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-tuple-size.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    type t = tuple<u8, string, tuple<u32>, u16>;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-tuple-size.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-tuple-size/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x42\x03\x01\x6f\x01\x79\x01\x6f\x03\x7d\x73\x00\x04\x00\x01\x74\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-tuple-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    type t = tuple<u8, string, tuple<string>>;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-tuple-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-tuple-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x14\x01\x42\x03\x01\x6f\x01\x79\x01\x6f\x03\x7d\x73\x00\x04\x00\x01\x74\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-variant-case-count.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    variant v {\n        a,\n        b(u16),\n        c(tuple<string, u16>),\n        d,\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-variant-case-count.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-variant-case-count/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-variant-case-name.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    variant v {\n        a,\n        c(u16),\n        b(tuple<string, u16>),\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-variant-case-name.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-variant-case-name/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/mismatched-variant-case-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    variant v {\n        a,\n        b(u16),\n        c(tuple<string, string>),\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/mismatched-variant-case-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/mismatched-variant-case-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-access-export.wac" {
  let source = "package test:comp;\n\nimport i: interface {\n\n};\n\nlet x = i.foo;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-access-export.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-constructor.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    resource r;\n    f: func(r: r);\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-constructor.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-constructor/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x32\x01\x42\x06\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x40\x01\x01\x72\x01\x01\x00\x04\x00\x01\x66\x01\x02\x01\x40\x00\x00\x01\x04\x00\x0e\x5b\x63\x6f\x6e\x73\x74\x72\x75\x63\x74\x6f\x72\x5d\x72\x01\x03\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-err-result-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> result;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-err-result-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-err-result-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x03\x01\x6a\x00\x01\x73\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-inst-arg.wac" {
  let source = "package test:comp;\n\nlet x = new foo:bar {};\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-inst-arg.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-inst-arg/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x08\x01\x00\x03\x66\x6f\x6f\x01\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-interface-export.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-interface-export.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-interface-export/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-method.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    resource r;\n    f: func(r: r);\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-method.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-method/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x3a\x01\x42\x07\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x68\x00\x01\x40\x01\x01\x72\x01\x01\x00\x04\x00\x01\x66\x01\x03\x01\x40\x01\x04\x73\x65\x6c\x66\x02\x01\x00\x04\x00\x0d\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x72\x2e\x66\x6f\x6f\x01\x04\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-ok-result-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> result<_>;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-ok-result-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-ok-result-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x13\x01\x42\x03\x01\x6a\x01\x73\x00\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-package-definition.wac" {
  let source = "package test:comp;\n\ninterface i {\n    use foo:bar/nonexistent.{a};\n}\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-package-definition.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-package-definition/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x08\x01\x00\x03\x66\x6f\x6f\x01\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-static-method.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    resource r;\n    f: func(r: r);\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-static-method.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-static-method/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x34\x01\x42\x07\x04\x00\x01\x72\x03\x01\x01\x69\x00\x01\x68\x00\x01\x40\x01\x01\x72\x01\x01\x00\x04\x00\x01\x66\x01\x03\x01\x40\x00\x01\x00\x04\x00\x0d\x5b\x73\x74\x61\x74\x69\x63\x5d\x72\x2e\x66\x6f\x6f\x01\x04\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-target-export.wac" {
  let source = "package test:comp targets foo:bar/baz;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-target-export.wac",
    dependencies=[],
    wit_dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/missing-target-export/foo/bar",
        root: Source({
          documents: [
            wit_document(
              "fail/missing-target-export/foo/bar/bar.wit", "package foo:bar;\n\nworld baz {\n    export hello: func() -> string;\n}\n",
            ),
          ],
        }),
        dependencies: [],
      },
    ],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-type-in-use.wac" {
  let source = "package test:comp;\n\ninterface a {\n\n}\n\ninterface b {\n    use a.{x};\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-type-in-use.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/missing-world-include-name.wac" {
  let source = "package test:comp;\n\nworld w1 {\n\n}\n\nworld w2 {\n    include w1 with { a as b };\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/missing-world-include-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/no-err-result-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> result<_, string>;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/no-err-result-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/no-err-result-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x42\x03\x01\x6a\x00\x00\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/no-import.wac" {
  let source = "package test:comp;\n\nimport x: interface {};\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/no-import.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/no-import/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/no-ok-result-type.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    f: func() -> result<string>;\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/no-ok-result-type.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/no-ok-result-type/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x12\x01\x42\x03\x01\x6a\x00\x00\x01\x40\x00\x00\x00\x04\x00\x01\x66\x01\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/non-instance-spread.wac" {
  let source = "package test:comp;\n\nimport f: func();\n\nlet x = new foo:bar { ...f };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/non-instance-spread.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/non-instance-spread/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/package-invalid-wasm.wac" {
  let source = "package test:comp;\n\nimport foo: foo:bar/qux;"
  let result = corpus_verify(
    source~,
    source_id="fail/package-invalid-wasm.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/package-invalid-wasm/foo/bar.wasm",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x0b\x07\x01\x00\x01\x74\x03\x00\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/package-not-component.wac" {
  let source = "package test:comp;\n\nimport foo: foo:bar/qux;"
  let result = corpus_verify(
    source~,
    source_id="fail/package-not-component.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/package-not-component/foo/bar.wasm",
        bytes: b"\x00\x61\x73\x6d\x01\x00\x00\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/package-not-wasm.wac" {
  let source = "package test:comp;\n\nimport foo: foo:bar/qux;"
  let result = corpus_verify(
    source~,
    source_id="fail/package-not-wasm.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/package-not-wasm/foo/bar.wasm",
        bytes: b"\x74\x68\x69\x73\x20\x69\x73\x20\x6e\x6f\x74\x20\x61\x20\x77\x61\x73\x6d\x20\x66\x69\x6c\x65\x0a",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/redefined-name.wac" {
  let source = "package test:comp;\n\ntype x = u32;\ntype x = string;"
  let result = corpus_verify(
    source~,
    source_id="fail/redefined-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/self-instantiation.wac" {
  let source = "package foo:bar;\n\nlet i = new foo:bar {};\n"
  let result = corpus_verify(
    source~,
    source_id="fail/self-instantiation.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/spread-export-no-effect.wac" {
  let source = "package test:comp;\n\nimport i: interface {};\n\nexport i...;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/spread-export-no-effect.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/spread-instantiation-no-match.wac" {
  let source = "package test:comp;\n\nimport i: interface {\n};\n\nlet x = new foo:bar { ...i };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/spread-instantiation-no-match.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/spread-instantiation-no-match/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/target-export-mismatch.wac" {
  let source = "package test:comp targets test:comp/world;\n\nworld %world {\n    import foo: interface {\n        foo: func(x: u32);\n    };\n    export foo: interface {\n        foo: func(x: string);\n    };\n}\n\nimport foo: interface {\n    foo: func(x: u32);\n};\nexport foo;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/target-export-mismatch.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/target-extraneous-import.wac" {
  let source = "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: func();\n}\n\nimport bar: func();\n"
  let result = corpus_verify(
    source~,
    source_id="fail/target-extraneous-import.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/target-import-mismatch-resource.wac" {
  let source = "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: interface {\n        resource x {\n            constructor();\n        }\n    };\n}\n\nimport foo2 as foo: interface {\n    resource y {\n        constructor();\n    }\n};\n"
  let result = corpus_verify(
    source~,
    source_id="fail/target-import-mismatch-resource.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/target-import-mismatch.wac" {
  let source = "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: func();\n}\n\nimport foo2 as foo: interface {\n\n};\n"
  let result = corpus_verify(
    source~,
    source_id="fail/target-import-mismatch.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/target-import-param-name-mismatch.wac" {
  let source = "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: interface {\n        foo: func(a: string);\n    };\n}\n\nimport foo2 as foo: interface {\n    foo: func(x: u32);\n};\n"
  let result = corpus_verify(
    source~,
    source_id="fail/target-import-param-name-mismatch.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/target-import-param-type-mismatch.wac" {
  let source = "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: interface {\n        foo: func(a: u32);\n    };\n}\n\nimport foo2 as foo: interface {\n    foo: func(a: string);\n};\n"
  let result = corpus_verify(
    source~,
    source_id="fail/target-import-param-type-mismatch.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/target-import-unexpected-method.wac" {
  let source = "package test:comp targets test:comp/foo;\n\nworld foo {\n    import foo: interface {\n        resource x {\n            constructor();\n        }\n    };\n}\n\nimport foo2 as foo: interface {\n    resource x {\n        constructor();\n        f: func(a: u32);\n    }\n};\n"
  let result = corpus_verify(
    source~,
    source_id="fail/target-import-unexpected-method.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/target-is-not-a-world.wac" {
  let source = "package test:comp targets test:comp/foo;\n\ninterface foo {   \n}"
  let result = corpus_verify(
    source~,
    source_id="fail/target-is-not-a-world.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/targets-interface-use.wac" {
  let source = "package test:comp targets test:comp/foo;\n\ninterface indirect-dependency {\n    variant my-variant {\n        foo,\n        // Extra variant that the instance does not have\n        bar\n    }\n}\n\ninterface direct-dependency {\n    use indirect-dependency.{my-variant};\n    \n    fun: func() -> my-variant;\n}\n\nworld foo {   \n    import direct-dependency;\n}\n\n\nlet i = new foo:bar { ... };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/targets-interface-use.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/targets-interface-use/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x1c\x01\x42\x02\x01\x71\x01\x03\x66\x6f\x6f\x00\x00\x04\x00\x0a\x6d\x79\x2d\x76\x61\x72\x69\x61\x6e\x74\x03\x00\x00\x0a\x22\x01\x00\x1d\x74\x65\x73\x74\x3a\x63\x6f\x6d\x70\x2f\x69\x6e\x64\x69\x72\x65\x63\x74\x2d\x64\x65\x70\x65\x6e\x64\x65\x6e\x63\x79\x05\x00\x06\x0f\x01\x03\x00\x00\x0a\x6d\x79\x2d\x76\x61\x72\x69\x61\x6e\x74\x07\x25\x01\x42\x04\x02\x03\x02\x01\x01\x04\x00\x0a\x6d\x79\x2d\x76\x61\x72\x69\x61\x6e\x74\x03\x00\x00\x01\x40\x00\x00\x01\x04\x00\x03\x66\x75\x6e\x01\x02\x0a\x20\x01\x00\x1b\x74\x65\x73\x74\x3a\x63\x6f\x6d\x70\x2f\x64\x69\x72\x65\x63\x74\x2d\x64\x65\x70\x65\x6e\x64\x65\x6e\x63\x79\x05\x02",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/targets-world-use.wac" {
  let source = "package test:comp targets test:comp/foo;\n\ninterface indirect-dependency {\n    // The resource is actually named \"other-resource\" in the instance\n    resource my-resource {}\n}\n\nworld foo {   \n    use indirect-dependency.{my-resource};\n    import my-func: func() -> my-resource;\n}\n\nlet i = new foo:bar { ... };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/targets-world-use.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/targets-world-use/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x16\x01\x42\x01\x04\x00\x0e\x6f\x74\x68\x65\x72\x2d\x72\x65\x73\x6f\x75\x72\x63\x65\x03\x01\x0a\x22\x01\x00\x1d\x74\x65\x73\x74\x3a\x63\x6f\x6d\x70\x2f\x69\x6e\x64\x69\x72\x65\x63\x74\x2d\x64\x65\x70\x65\x6e\x64\x65\x6e\x63\x79\x05\x00\x06\x13\x01\x03\x00\x00\x0e\x6f\x74\x68\x65\x72\x2d\x72\x65\x73\x6f\x75\x72\x63\x65\x0a\x11\x01\x00\x0b\x6d\x79\x2d\x72\x65\x73\x6f\x75\x72\x63\x65\x03\x00\x01\x07\x07\x02\x69\x02\x40\x00\x00\x03\x0a\x0c\x01\x00\x07\x6d\x79\x2d\x66\x75\x6e\x63\x01\x04\x06\x13\x01\x03\x00\x00\x0e\x6f\x74\x68\x65\x72\x2d\x72\x65\x73\x6f\x75\x72\x63\x65",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/type-decl-conflict.wac" {
  let source = "package test:comp;\n\nimport foo: func();\nexport foo as i;\n\ninterface i {\n\n}\n"
  let result = corpus_verify(
    source~,
    source_id="fail/type-decl-conflict.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/undefined-name.wac" {
  let source = "package test:comp;\n\ntype x = x;"
  let result = corpus_verify(
    source~,
    source_id="fail/undefined-name.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/unknown-package.wac" {
  let source = "package test:comp;\n\nimport foo: bar:baz/qux;"
  let result = corpus_verify(
    source~,
    source_id="fail/unknown-package.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/unknown-target-path.wac" {
  let source = "package test:comp targets foo:bar/baz;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/unknown-target-path.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/unknown-targets-path.wac" {
  let source = "package test:comp targets test:comp/foo;\n"
  let result = corpus_verify(
    source~,
    source_id="fail/unknown-targets-path.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/variant-case-typed.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    variant v {\n        a,\n        b,\n        c(tuple<string, u16>),\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/variant-case-typed.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/variant-case-typed/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/variant-case-untyped.wac" {
  let source = "package test:comp;\n\nimport x: interface {\n    variant v {\n        a(string),\n        b(u16),\n        c(tuple<string, u16>),\n    }\n};\n\nlet i = new foo:bar { x };\n"
  let result = corpus_verify(
    source~,
    source_id="fail/variant-case-untyped.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "fail/variant-case-untyped/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x20\x01\x42\x03\x01\x6f\x02\x73\x7b\x01\x71\x03\x01\x61\x00\x00\x01\x62\x01\x7b\x00\x01\x63\x01\x00\x00\x04\x00\x01\x76\x03\x00\x01\x0a\x06\x01\x00\x01\x78\x05\x00",
      },
    ],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/windows-file.wac" {
  let source = "package foo:bar;\n\nimport x: func();\nimport x: func();\n"
  let result = corpus_verify(
    source~,
    source_id="fail/windows-file.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/world-include-conflict.wac" {
  let source = "package test:comp;\n\nworld w1 {\n    export a: func();\n}\n\nworld w2 {\n    include w1;\n    export a: interface {\n\n    };\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/world-include-conflict.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC fail/world-include-with-conflict.wac" {
  let source = "package test:comp;\n\nworld w1 {\n    export a: func();\n}\n\nworld w2 {\n    include w1 with { a as x };\n    export x: interface {\n\n    };\n}"
  let result = corpus_verify(
    source~,
    source_id="fail/world-include-with-conflict.wac",
    dependencies=[],
    wit_dependencies=[],
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
}

///|
test "upstream WAC import.wac" {
  let source = "package test:comp@0.0.1-beta;\n\n/// Import by func type\nimport a: func();\n\n/// Import by ident\ntype x = func();\nimport b: x;\n\n/// Import by package path\n//import c: foo:bar/baz;\n\n/// Import by func type with kebab name \nimport d as \"hello-world\": func(name: string);\n\n/// Import by inline interface\nimport e: interface {\n    x: func();\n};\n\n/// Import by package path with version\nimport f: foo:bar/baz;\n\nexport d;\nexport e as \"e\";\nexport f;"
  let result = corpus_verify(source~, source_id="import.wac", dependencies=[], wit_dependencies=[
    {
      name: "foo:bar",
      version: None,
      source: "import/foo/bar",
      root: Source({
        documents: [
          wit_document(
            "import/foo/bar/package.wit", "package foo:bar;\n\ninterface baz {\n}",
          ),
        ],
      }),
      dependencies: [],
    },
  ])
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
    "6", "import:a", "func", "function", "false", "0", "none", "definition", "type",
    "function", "false", "0", "none", "import:b", "func", "function", "false", "0",
    "none", "import:hello-world", "func", "function", "false", "1", "name", "scalar",
    "string", "none", "import:e", "instance", "interface", "", "0", "1", "x", "func",
    "function", "false", "0", "none", "import:foo:bar/baz", "instance", "interface",
    "foo:bar/baz", "0", "0", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), [
    "5", "a", "func", "function", "false", "0", "none", "b", "func", "function",
    "false", "0", "none", "hello-world", "func", "function", "false", "1", "name",
    "scalar", "string", "none", "e", "instance", "interface", "", "0", "1", "x",
    "func", "function", "false", "0", "none", "foo:bar/baz", "instance", "interface",
    "foo:bar/baz", "0", "0", "0",
  ])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["e:4", "x:1", "foo:bar/baz:5", "hello-world:3"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["e", "x", "foo:bar/baz", "hello-world"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["", "x", "", "hello-world", "e", "foo:bar/baz"])
}

///|
test "upstream WAC let-statements.wac" {
  let source = "package test:comp@1.0.0;\n\nimport streams: wasi:io/streams;\n\nlet i = new foo:bar { streams, baz: new foo:bar { streams, ... }.baz };\n\nexport i.baz;\nexport i as \"i\";\n"
  let result = corpus_verify(
    source~,
    source_id="let-statements.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "let-statements/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\xb8\x02\x01\x42\x10\x04\x00\x0d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x03\x01\x01\x69\x00\x01\x6d\x02\x15\x6c\x61\x73\x74\x2d\x6f\x70\x65\x72\x61\x74\x69\x6f\x6e\x2d\x66\x61\x69\x6c\x65\x64\x06\x63\x6c\x6f\x73\x65\x64\x04\x00\x0b\x77\x72\x69\x74\x65\x2d\x65\x72\x72\x6f\x72\x03\x00\x02\x04\x00\x0c\x69\x6e\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x03\x01\x01\x68\x00\x01\x6a\x01\x77\x01\x03\x01\x40\x01\x04\x73\x65\x6c\x66\x05\x00\x06\x04\x00\x21\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x2e\x63\x68\x65\x63\x6b\x2d\x77\x72\x69\x74\x65\x01\x07\x01\x70\x7d\x01\x6a\x00\x01\x03\x01\x40\x02\x04\x73\x65\x6c\x66\x05\x08\x63\x6f\x6e\x74\x65\x6e\x74\x73\x08\x00\x09\x04\x00\x1b\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x2e\x77\x72\x69\x74\x65\x01\x0a\x04\x00\x2e\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x2e\x62\x6c\x6f\x63\x6b\x69\x6e\x67\x2d\x77\x72\x69\x74\x65\x2d\x61\x6e\x64\x2d\x66\x6c\x75\x73\x68\x01\x0a\x01\x40\x01\x04\x73\x65\x6c\x66\x05\x00\x09\x04\x00\x24\x5b\x6d\x65\x74\x68\x6f\x64\x5d\x6f\x75\x74\x70\x75\x74\x2d\x73\x74\x72\x65\x61\x6d\x2e\x62\x6c\x6f\x63\x6b\x69\x6e\x67\x2d\x66\x6c\x75\x73\x68\x01\x0b\x0a\x28\x01\x00\x23\x77\x61\x73\x69\x3a\x69\x6f\x2f\x73\x74\x72\x65\x61\x6d\x73\x40\x30\x2e\x32\x2e\x30\x2d\x72\x63\x2d\x32\x30\x32\x33\x2d\x31\x30\x2d\x31\x38\x05\x00\x07\x0e\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x0a\x16\x01\x00\x11\x66\x6f\x6f\x3a\x62\x61\x72\x2f\x62\x61\x7a\x40\x30\x2e\x31\x2e\x30\x05\x01\x0b\x17\x01\x00\x11\x66\x6f\x6f\x3a\x62\x61\x72\x2f\x62\x61\x7a\x40\x30\x2e\x31\x2e\x30\x05\x01\x00",
      },
    ],
    wit_dependencies=[
      {
        name: "wasi:io",
        version: None,
        source: "let-statements/wasi/io",
        root: Source({
          documents: [
            wit_document(
              "let-statements/wasi/io/package.wit", "package wasi:io@0.2.0-rc-2023-10-18;\n\n/// WASI I/O is an I/O abstraction API which is currently focused on providing\n/// stream types.\n///\n/// In the future, the component model is expected to add built-in stream types;\n/// when it does, they are expected to subsume this API.\ninterface streams {\n    resource pollable;\n\n    /// Streams provide a sequence of data and then end; once they end, they\n    /// no longer provide any further data.\n    ///\n    /// For example, a stream reading from a file ends when the stream reaches\n    /// the end of the file. For another example, a stream reading from a\n    /// socket ends when the socket is closed.\n    enum stream-status {\n        /// The stream is open and may produce further data.\n        open,\n        /// When reading, this indicates that the stream will not produce\n        /// further data.\n        /// When writing, this indicates that the stream will no longer be read.\n        /// Further writes are still permitted.\n        ended,\n    }\n\n    /// An input bytestream.\n    ///\n    /// `input-stream`s are *non-blocking* to the extent practical on underlying\n    /// platforms. I/O operations always return promptly; if fewer bytes are\n    /// promptly available than requested, they return the number of bytes promptly\n    /// available, which could even be zero. To wait for data to be available,\n    /// use the `subscribe` function to obtain a `pollable` which can be polled\n    /// for using `wasi:io/poll`.\n    resource input-stream {\n        /// Perform a non-blocking read from the stream.\n        ///\n        /// This function returns a list of bytes containing the data that was\n        /// read, along with a `stream-status` which, indicates whether further\n        /// reads are expected to produce data. The returned list will contain up to\n        /// `len` bytes; it may return fewer than requested, but not more. An\n        /// empty list and `stream-status:open` indicates no more data is\n        /// available at this time, and that the pollable given by `subscribe`\n        /// will be ready when more data is available.\n        ///\n        /// Once a stream has reached the end, subsequent calls to `read` or\n        /// `skip` will always report `stream-status:ended` rather than producing more\n        /// data.\n        ///\n        /// When the caller gives a `len` of 0, it represents a request to read 0\n        /// bytes. This read should  always succeed and return an empty list and\n        /// the current `stream-status`.\n        ///\n        /// The `len` parameter is a `u64`, which could represent a list of u8 which\n        /// is not possible to allocate in wasm32, or not desirable to allocate as\n        /// as a return value by the callee. The callee may return a list of bytes\n        /// less than `len` in size while more bytes are available for reading.\n        read: func(\n            /// The maximum number of bytes to read\n            len: u64\n        ) -> result<tuple<list<u8>, stream-status>>;\n\n        /// Read bytes from a stream, after blocking until at least one byte can\n        /// be read. Except for blocking, identical to `read`.\n        blocking-read: func(\n            /// The maximum number of bytes to read\n            len: u64\n        ) -> result<tuple<list<u8>, stream-status>>;\n\n        /// Skip bytes from a stream.\n        ///\n        /// This is similar to the `read` function, but avoids copying the\n        /// bytes into the instance.\n        ///\n        /// Once a stream has reached the end, subsequent calls to read or\n        /// `skip` will always report end-of-stream rather than producing more\n        /// data.\n        ///\n        /// This function returns the number of bytes skipped, along with a\n        /// `stream-status` indicating whether the end of the stream was\n        /// reached. The returned value will be at most `len`; it may be less.\n        skip: func(\n            /// The maximum number of bytes to skip.\n            len: u64,\n        ) -> result<tuple<u64, stream-status>>;\n\n        /// Skip bytes from a stream, after blocking until at least one byte\n        /// can be skipped. Except for blocking behavior, identical to `skip`.\n        blocking-skip: func(\n            /// The maximum number of bytes to skip.\n            len: u64,\n        ) -> result<tuple<u64, stream-status>>;\n\n        /// Create a `pollable` which will resolve once either the specified stream\n        /// has bytes available to read or the other end of the stream has been\n        /// closed.\n        /// The created `pollable` is a child resource of the `input-stream`.\n        /// Implementations may trap if the `input-stream` is dropped before\n        /// all derived `pollable`s created with this function are dropped.\n        subscribe: func() -> pollable;\n    }\n\n    /// An error for output-stream operations.\n    ///\n    /// Contrary to input-streams, a closed output-stream is reported using\n    /// an error.\n    enum write-error {\n        /// The last operation (a write or flush) failed before completion.\n        last-operation-failed,\n        /// The stream is closed: no more input will be accepted by the\n        /// stream. A closed output-stream will return this error on all\n        /// future operations.\n        closed\n    }\n\n    /// An output bytestream.\n    ///\n    /// `output-stream`s are *non-blocking* to the extent practical on\n    /// underlying platforms. Except where specified otherwise, I/O operations also\n    /// always return promptly, after the number of bytes that can be written\n    /// promptly, which could even be zero. To wait for the stream to be ready to\n    /// accept data, the `subscribe` function to obtain a `pollable` which can be\n    /// polled for using `wasi:io/poll`.\n    resource output-stream {\n        /// Check readiness for writing. This function never blocks.\n        ///\n        /// Returns the number of bytes permitted for the next call to `write`,\n        /// or an error. Calling `write` with more bytes than this function has\n        /// permitted will trap.\n        ///\n        /// When this function returns 0 bytes, the `subscribe` pollable will\n        /// become ready when this function will report at least 1 byte, or an\n        /// error.\n        check-write: func() -> result<u64, write-error>;\n\n        /// Perform a write. This function never blocks.\n        ///\n        /// Precondition: check-write gave permit of Ok(n) and contents has a\n        /// length of less than or equal to n. Otherwise, this function will trap.\n        ///\n        /// returns Err(closed) without writing if the stream has closed since\n        /// the last call to check-write provided a permit.\n        write: func(\n            contents: list<u8>\n        ) -> result<_, write-error>;\n\n        /// Perform a write of up to 4096 bytes, and then flush the stream. Block\n        /// until all of these operations are complete, or an error occurs.\n        ///\n        /// This is a convenience wrapper around the use of `check-write`,\n        /// `subscribe`, `write`, and `flush`, and is implemented with the\n        /// following pseudo-code:\n        ///\n        /// ```text\n        /// let pollable = this.subscribe();\n        /// while !contents.is_empty() {\n        ///     // Wait for the stream to become writable\n        ///     poll-one(pollable);\n        ///     let Ok(n) = this.check-write(); // eliding error handling\n        ///     let len = min(n, contents.len());\n        ///     let (chunk, rest) = contents.split_at(len);\n        ///     this.write(chunk  );            // eliding error handling\n        ///     contents = rest;\n        /// }\n        /// this.flush();\n        /// // Wait for completion of `flush`\n        /// poll-one(pollable);\n        /// // Check for any errors that arose during `flush`\n        /// let _ = this.check-write();         // eliding error handling\n        /// ```\n        blocking-write-and-flush: func(\n            contents: list<u8>\n        ) -> result<_, write-error>;\n\n        /// Request to flush buffered output. This function never blocks.\n        ///\n        /// This tells the output-stream that the caller intends any buffered\n        /// output to be flushed. the output which is expected to be flushed\n        /// is all that has been passed to `write` prior to this call.\n        ///\n        /// Upon calling this function, the `output-stream` will not accept any\n        /// writes (`check-write` will return `ok(0)`) until the flush has\n        /// completed. The `subscribe` pollable will become ready when the\n        /// flush has completed and the stream can accept more writes.\n        flush: func() -> result<_, write-error>;\n\n        /// Request to flush buffered output, and block until flush completes\n        /// and stream is ready for writing again.\n        blocking-flush: func() -> result<_, write-error>;\n\n        /// Create a `pollable` which will resolve once the output-stream\n        /// is ready for more writing, or an error has occured. When this\n        /// pollable is ready, `check-write` will return `ok(n)` with n>0, or an\n        /// error.\n        ///\n        /// If the stream is closed, this pollable is always ready immediately.\n        ///\n        /// The created `pollable` is a child resource of the `output-stream`.\n        /// Implementations may trap if the `output-stream` is dropped before\n        /// all derived `pollable`s created with this function are dropped.\n        subscribe: func() -> pollable;\n\n        /// Write zeroes to a stream.\n        ///\n        /// this should be used precisely like `write` with the exact same\n        /// preconditions (must use check-write first), but instead of\n        /// passing a list of bytes, you simply pass the number of zero-bytes\n        /// that should be written.\n        write-zeroes: func(\n            /// The number of zero-bytes to write\n            len: u64\n        ) -> result<_, write-error>;\n\n        /// Perform a write of up to 4096 zeroes, and then flush the stream.\n        /// Block until all of these operations are complete, or an error\n        /// occurs.\n        ///\n        /// This is a convenience wrapper around the use of `check-write`,\n        /// `subscribe`, `write-zeroes`, and `flush`, and is implemented with\n        /// the following pseudo-code:\n        ///\n        /// ```text\n        /// let pollable = this.subscribe();\n        /// while num_zeroes != 0 {\n        ///     // Wait for the stream to become writable\n        ///     poll-one(pollable);\n        ///     let Ok(n) = this.check-write(); // eliding error handling\n        ///     let len = min(n, num_zeroes);\n        ///     this.write-zeroes(len);         // eliding error handling\n        ///     num_zeroes -= len;\n        /// }\n        /// this.flush();\n        /// // Wait for completion of `flush`\n        /// poll-one(pollable);\n        /// // Check for any errors that arose during `flush`\n        /// let _ = this.check-write();         // eliding error handling\n        /// ```\n        blocking-write-zeroes-and-flush: func(\n            /// The number of zero-bytes to write\n            len: u64\n        ) -> result<_, write-error>;\n\n        /// Read from one stream and write to another.\n        ///\n        /// This function returns the number of bytes transferred; it may be less\n        /// than `len`.\n        ///\n        /// Unlike other I/O functions, this function blocks until all the data\n        /// read from the input stream has been written to the output stream.\n        splice: func(\n            /// The stream to read from\n            src: input-stream,\n            /// The number of bytes to splice\n            len: u64,\n        ) -> result<tuple<u64, stream-status>>;\n\n        /// Read from one stream and write to another, with blocking.\n        ///\n        /// This is similar to `splice`, except that it blocks until at least\n        /// one byte can be read.\n        blocking-splice: func(\n            /// The stream to read from\n            src: input-stream,\n            /// The number of bytes to splice\n            len: u64,\n        ) -> result<tuple<u64, stream-status>>;\n\n        /// Forward the entire contents of an input stream to an output stream.\n        ///\n        /// This function repeatedly reads from the input stream and writes\n        /// the data to the output stream, until the end of the input stream\n        /// is reached, or an error is encountered.\n        ///\n        /// Unlike other I/O functions, this function blocks until the end\n        /// of the input stream is seen and all the data has been written to\n        /// the output stream.\n        ///\n        /// This function returns the number of bytes transferred, and the status of\n        /// the output stream.\n        forward: func(\n            /// The stream to read from\n            src: input-stream\n        ) -> result<tuple<u64, stream-status>>;\n    }\n}\n",
            ),
          ],
        }),
        dependencies: [],
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
    "6", "import:wasi:io/streams", "instance", "interface", "wasi:io/streams@0.2.0-rc-2023-10-18",
    "0", "21", "pollable", "type", "resource", "0", "stream-status", "type", "enum",
    "2", "open", "ended", "input-stream", "type", "resource", "1", "write-error",
    "type", "enum", "2", "last-operation-failed", "closed", "output-stream", "type",
    "resource", "2", "[method]input-stream.read", "func", "function", "false", "2",
    "self", "borrow", "1", "len", "scalar", "u64", "some", "result", "some", "tuple",
    "2", "list", "scalar", "u8", "enum", "2", "open", "ended", "none", "[method]input-stream.blocking-read",
    "func", "function", "false", "2", "self", "borrow", "1", "len", "scalar", "u64",
    "some", "result", "some", "tuple", "2", "list", "scalar", "u8", "enum", "2",
    "open", "ended", "none", "[method]input-stream.skip", "func", "function", "false",
    "2", "self", "borrow", "1", "len", "scalar", "u64", "some", "result", "some",
    "tuple", "2", "scalar", "u64", "enum", "2", "open", "ended", "none", "[method]input-stream.blocking-skip",
    "func", "function", "false", "2", "self", "borrow", "1", "len", "scalar", "u64",
    "some", "result", "some", "tuple", "2", "scalar", "u64", "enum", "2", "open",
    "ended", "none", "[method]input-stream.subscribe", "func", "function", "false",
    "1", "self", "borrow", "1", "some", "own", "0", "[method]output-stream.check-write",
    "func", "function", "false", "1", "self", "borrow", "2", "some", "result", "some",
    "scalar", "u64", "some", "enum", "2", "last-operation-failed", "closed", "[method]output-stream.write",
    "func", "function", "false", "2", "self", "borrow", "2", "contents", "list",
    "scalar", "u8", "some", "result", "none", "some", "enum", "2", "last-operation-failed",
    "closed", "[method]output-stream.blocking-write-and-flush", "func", "function",
    "false", "2", "self", "borrow", "2", "contents", "list", "scalar", "u8", "some",
    "result", "none", "some", "enum", "2", "last-operation-failed", "closed", "[method]output-stream.flush",
    "func", "function", "false", "1", "self", "borrow", "2", "some", "result", "none",
    "some", "enum", "2", "last-operation-failed", "closed", "[method]output-stream.blocking-flush",
    "func", "function", "false", "1", "self", "borrow", "2", "some", "result", "none",
    "some", "enum", "2", "last-operation-failed", "closed", "[method]output-stream.subscribe",
    "func", "function", "false", "1", "self", "borrow", "2", "some", "own", "0",
    "[method]output-stream.write-zeroes", "func", "function", "false", "2", "self",
    "borrow", "2", "len", "scalar", "u64", "some", "result", "none", "some", "enum",
    "2", "last-operation-failed", "closed", "[method]output-stream.blocking-write-zeroes-and-flush",
    "func", "function", "false", "2", "self", "borrow", "2", "len", "scalar", "u64",
    "some", "result", "none", "some", "enum", "2", "last-operation-failed", "closed",
    "[method]output-stream.splice", "func", "function", "false", "3", "self", "borrow",
    "2", "src", "own", "1", "len", "scalar", "u64", "some", "result", "some", "tuple",
    "2", "scalar", "u64", "enum", "2", "open", "ended", "none", "[method]output-stream.blocking-splice",
    "func", "function", "false", "3", "self", "borrow", "2", "src", "own", "1", "len",
    "scalar", "u64", "some", "result", "some", "tuple", "2", "scalar", "u64", "enum",
    "2", "open", "ended", "none", "[method]output-stream.forward", "func", "function",
    "false", "2", "self", "borrow", "2", "src", "own", "1", "some", "result", "some",
    "tuple", "2", "scalar", "u64", "enum", "2", "open", "ended", "none", "import:foo:bar/baz@0.1.0",
    "instance", "interface", "foo:bar/baz@0.1.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance:foo:bar", "instance", "interface", "", "0", "1",
    "foo:bar/baz@0.1.0", "instance", "interface", "foo:bar/baz@0.1.0", "0", "1",
    "f", "func", "function", "false", "0", "none", "alias:2:foo:bar/baz@0.1.0", "instance",
    "interface", "foo:bar/baz@0.1.0", "0", "1", "f", "func", "function", "false",
    "0", "none", "instance:foo:bar", "instance", "interface", "", "0", "1", "foo:bar/baz@0.1.0",
    "instance", "interface", "foo:bar/baz@0.1.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "alias:4:foo:bar/baz@0.1.0", "instance", "interface", "foo:bar/baz@0.1.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [
    "2", "foo:bar/baz@0.1.0", "1", "2", "wasi:io/streams@0.2.0-rc-2023-10-18", "0",
    "3", "alias", "2", "foo:bar/baz@0.1.0", "4", "foo:bar/baz@0.1.0", "3", "4", "wasi:io/streams@0.2.0-rc-2023-10-18",
    "0", "5", "alias", "4", "foo:bar/baz@0.1.0",
  ])
  assert_eq(implicit_import_projection(model), [
    "2", "foo:bar/baz@0.1.0", "instance", "interface", "foo:bar/baz@0.1.0", "0",
    "1", "f", "func", "function", "false", "0", "none", "wasi:io/streams", "instance",
    "interface", "wasi:io/streams@0.2.0-rc-2023-10-18", "0", "21", "pollable", "type",
    "resource", "0", "stream-status", "type", "enum", "2", "open", "ended", "input-stream",
    "type", "resource", "1", "write-error", "type", "enum", "2", "last-operation-failed",
    "closed", "output-stream", "type", "resource", "2", "[method]input-stream.read",
    "func", "function", "false", "2", "self", "borrow", "1", "len", "scalar", "u64",
    "some", "result", "some", "tuple", "2", "list", "scalar", "u8", "enum", "2",
    "open", "ended", "none", "[method]input-stream.blocking-read", "func", "function",
    "false", "2", "self", "borrow", "1", "len", "scalar", "u64", "some", "result",
    "some", "tuple", "2", "list", "scalar", "u8", "enum", "2", "open", "ended", "none",
    "[method]input-stream.skip", "func", "function", "false", "2", "self", "borrow",
    "1", "len", "scalar", "u64", "some", "result", "some", "tuple", "2", "scalar",
    "u64", "enum", "2", "open", "ended", "none", "[method]input-stream.blocking-skip",
    "func", "function", "false", "2", "self", "borrow", "1", "len", "scalar", "u64",
    "some", "result", "some", "tuple", "2", "scalar", "u64", "enum", "2", "open",
    "ended", "none", "[method]input-stream.subscribe", "func", "function", "false",
    "1", "self", "borrow", "1", "some", "own", "0", "[method]output-stream.check-write",
    "func", "function", "false", "1", "self", "borrow", "2", "some", "result", "some",
    "scalar", "u64", "some", "enum", "2", "last-operation-failed", "closed", "[method]output-stream.write",
    "func", "function", "false", "2", "self", "borrow", "2", "contents", "list",
    "scalar", "u8", "some", "result", "none", "some", "enum", "2", "last-operation-failed",
    "closed", "[method]output-stream.blocking-write-and-flush", "func", "function",
    "false", "2", "self", "borrow", "2", "contents", "list", "scalar", "u8", "some",
    "result", "none", "some", "enum", "2", "last-operation-failed", "closed", "[method]output-stream.flush",
    "func", "function", "false", "1", "self", "borrow", "2", "some", "result", "none",
    "some", "enum", "2", "last-operation-failed", "closed", "[method]output-stream.blocking-flush",
    "func", "function", "false", "1", "self", "borrow", "2", "some", "result", "none",
    "some", "enum", "2", "last-operation-failed", "closed", "[method]output-stream.subscribe",
    "func", "function", "false", "1", "self", "borrow", "2", "some", "own", "0",
    "[method]output-stream.write-zeroes", "func", "function", "false", "2", "self",
    "borrow", "2", "len", "scalar", "u64", "some", "result", "none", "some", "enum",
    "2", "last-operation-failed", "closed", "[method]output-stream.blocking-write-zeroes-and-flush",
    "func", "function", "false", "2", "self", "borrow", "2", "len", "scalar", "u64",
    "some", "result", "none", "some", "enum", "2", "last-operation-failed", "closed",
    "[method]output-stream.splice", "func", "function", "false", "3", "self", "borrow",
    "2", "src", "own", "1", "len", "scalar", "u64", "some", "result", "some", "tuple",
    "2", "scalar", "u64", "enum", "2", "open", "ended", "none", "[method]output-stream.blocking-splice",
    "func", "function", "false", "3", "self", "borrow", "2", "src", "own", "1", "len",
    "scalar", "u64", "some", "result", "some", "tuple", "2", "scalar", "u64", "enum",
    "2", "open", "ended", "none", "[method]output-stream.forward", "func", "function",
    "false", "2", "self", "borrow", "2", "src", "own", "1", "some", "result", "some",
    "tuple", "2", "scalar", "u64", "enum", "2", "open", "ended", "none", "0",
  ])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["i:4", "foo:bar/baz@0.1.0:5"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["i", "foo:bar/baz@0.1.0"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["", "", "", "", "i", "foo:bar/baz@0.1.0"])
}

///|
test "upstream WAC no-imports.wac" {
  let source = "package test:comp@0.3.0;\n\nlet i = new foo:bar {};\n\nexport i as \"i\";\n"
  let result = corpus_verify(
    source~,
    source_id="no-imports.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "no-imports/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00",
      },
    ],
    wit_dependencies=[],
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
    "1", "instance:foo:bar", "instance", "interface", "", "0", "0", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["i:0"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["i"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["i"])
}

///|
test "upstream WAC package-import.wac" {
  let source = "package test:comp@1.0.0;\n\nimport i: foo:bar/i;\n\nexport i;\n"
  let result = corpus_verify(
    source~,
    source_id="package-import.wac",
    dependencies=[],
    wit_dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "package-import/foo/bar",
        root: Source({
          documents: [
            wit_document(
              "package-import/foo/bar/package.wit", "package foo:bar;\n\ninterface i {\n    type x = string;\n\n    resource r {\n        x: func(r: r);\n    }\n\n    y: func(r: borrow<r>);\n}",
            ),
          ],
        }),
        dependencies: [],
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
    "1", "import:foo:bar/i", "instance", "interface", "foo:bar/i", "0", "4", "x",
    "type", "scalar", "string", "r", "type", "resource", "0", "[method]r.x", "func",
    "function", "false", "2", "self", "borrow", "0", "r", "own", "0", "none", "y",
    "func", "function", "false", "1", "r", "borrow", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), [
    "1", "foo:bar/i", "instance", "interface", "foo:bar/i", "0", "4", "x", "type",
    "scalar", "string", "r", "type", "resource", "0", "[method]r.x", "func", "function",
    "false", "2", "self", "borrow", "0", "r", "own", "0", "none", "y", "func", "function",
    "false", "1", "r", "borrow", "0", "none", "0",
  ])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["foo:bar/i:0"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["foo:bar/i"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["foo:bar/i"])
}

///|
test "upstream WAC package-use-item.wac" {
  let source = "package test:comp@0.0.1;\n\ninterface i {\n    use foo:bar/baz.{a, b, c};\n}\n\nworld w {\n    use foo:bar/qux.{x, y, z};\n}\n"
  let result = corpus_verify(
    source~,
    source_id="package-use-item.wac",
    dependencies=[],
    wit_dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "package-use-item/foo/bar",
        root: Source({
          documents: [
            wit_document(
              "package-use-item/foo/bar/package.wit", "package foo:bar;\n\ninterface baz {\n    type a = u8;\n    type b = s64;\n    type c = string;\n}\n\ninterface qux {\n    resource x;\n    type y = borrow<x>;\n    use baz.{c as z};\n}\n",
            ),
          ],
        }),
        dependencies: [],
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
    "2", "definition", "type", "interface", "test:comp/i@0.0.1", "3", "a", "a", "foo:bar/baz",
    "b", "b", "foo:bar/baz", "c", "c", "foo:bar/baz", "3", "a", "type", "scalar",
    "u8", "b", "type", "scalar", "s64", "c", "type", "scalar", "string", "definition",
    "type", "world", "test:comp/w@0.0.1", "3", "x", "x", "foo:bar/qux", "y", "y",
    "foo:bar/qux", "z", "z", "foo:bar/qux", "3", "x", "type", "resource", "0", "y",
    "type", "borrow", "0", "z", "type", "scalar", "string", "0", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["i:0", "w:1"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["i", "w"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["i", "w"])
}

///|
test "upstream WAC package-world-include.wac" {
  let source = "package test:comp@1.2.3-prerelease;\n\nworld w {\n    include foo:bar/baz;\n}"
  let result = corpus_verify(
    source~,
    source_id="package-world-include.wac",
    dependencies=[],
    wit_dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "package-world-include/foo/bar",
        root: Source({
          documents: [
            wit_document(
              "package-world-include/foo/bar/package.wit", "package foo:bar;\n\ninterface i {\n    resource x {\n        constructor();\n        a: func();\n        b: static func();\n    }\n}\n\nworld baz {\n    use i.{x};\n    import i;\n    export i;\n}",
            ),
          ],
        }),
        dependencies: [],
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
    "1", "definition", "type", "world", "test:comp/w@1.2.3-prerelease", "0", "2",
    "foo:bar/i", "instance", "interface", "foo:bar/i", "0", "4", "x", "type", "resource",
    "0", "[constructor]x", "func", "function", "false", "0", "some", "own", "0",
    "[method]x.a", "func", "function", "false", "1", "self", "borrow", "0", "none",
    "[static]x.b", "func", "function", "false", "0", "none", "x", "type", "resource",
    "0", "1", "foo:bar/i", "instance", "interface", "foo:bar/i", "0", "4", "x", "type",
    "resource", "1", "[constructor]x", "func", "function", "false", "0", "some",
    "own", "1", "[method]x.a", "func", "function", "false", "1", "self", "borrow",
    "1", "none", "[static]x.b", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["w:0"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["w"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["w"])
}

///|
test "upstream WAC package-world-item.wac" {
  let source = "package test:comp;\n\nworld w {\n    import foo:bar/baz;\n    export bar:baz/qux;\n}\n"
  let result = corpus_verify(
    source~,
    source_id="package-world-item.wac",
    dependencies=[],
    wit_dependencies=[
      {
        name: "bar:baz",
        version: None,
        source: "package-world-item/bar/baz",
        root: Source({
          documents: [
            wit_document(
              "package-world-item/bar/baz/package.wit", "package bar:baz;\n\ninterface qux {\n    type x = string;\n}",
            ),
          ],
        }),
        dependencies: [],
      },
      {
        name: "foo:bar",
        version: None,
        source: "package-world-item/foo/bar",
        root: Source({
          documents: [
            wit_document(
              "package-world-item/foo/bar/package.wit", "package foo:bar;\n\ninterface baz {\n    resource z {\n        constructor();\n    }\n    \n    x: func();\n}",
            ),
          ],
        }),
        dependencies: [],
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
    "1", "definition", "type", "world", "test:comp/w", "0", "1", "foo:bar/baz", "instance",
    "interface", "foo:bar/baz", "0", "3", "z", "type", "resource", "0", "[constructor]z",
    "func", "function", "false", "0", "some", "own", "0", "x", "func", "function",
    "false", "0", "none", "1", "bar:baz/qux", "instance", "interface", "bar:baz/qux",
    "0", "1", "x", "type", "scalar", "string", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["w:0"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["w"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["w"])
}

///|
test "upstream WAC resource.wac" {
  let source = "package test:comp;\n\ninterface foo {\n    resource x;\n    type f = func(x: borrow<x>);\n    f2: f;\n\n    type x2 = x;\n    f3: func(x: x, x2: x2, x3: borrow<x>, x4: borrow<x2>);\n}\n"
  let result = corpus_verify(
    source~,
    source_id="resource.wac",
    dependencies=[],
    wit_dependencies=[],
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
    "1", "definition", "type", "interface", "test:comp/foo", "0", "5", "x", "type",
    "resource", "0", "f", "type", "function", "false", "1", "x", "borrow", "0", "none",
    "f2", "func", "function", "false", "1", "x", "borrow", "0", "none", "x2", "type",
    "resource", "0", "f3", "func", "function", "false", "4", "x", "own", "0", "x2",
    "own", "0", "x3", "borrow", "0", "x4", "borrow", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["foo:0"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["foo"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["foo"])
}

///|
test "upstream WAC targets-empty-world.wac" {
  let source = "package test:comp targets test:comp/foo;\n\nworld foo {   \n}\n"
  let result = corpus_verify(
    source~,
    source_id="targets-empty-world.wac",
    dependencies=[],
    wit_dependencies=[],
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
    "1", "definition", "type", "world", "test:comp/foo", "0", "0", "0", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["foo:0"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["foo"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["foo"])
}

///|
test "upstream WAC targets-world.wac" {
  let source = "package test:comp targets test:comp/world;\n\nworld %world {\n    import f: func();\n    export i: interface {\n        f: func();\n    };\n}\n\nimport f: func();\n\nexport new foo:bar { f } as i;\n"
  let result = corpus_verify(
    source~,
    source_id="targets-world.wac",
    dependencies=[
      {
        name: "foo:bar",
        version: None,
        source: "targets-world/foo/bar.wat",
        bytes: b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x05\x01\x40\x00\x01\x00\x0a\x06\x01\x00\x01\x66\x01\x00\x0b\x07\x01\x00\x01\x66\x01\x00\x00",
      },
    ],
    wit_dependencies=[],
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
    "3", "definition", "type", "world", "test:comp/world", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "i", "instance", "interface", "", "0",
    "1", "f", "func", "function", "false", "0", "none", "import:f", "func", "function",
    "false", "0", "none", "instance:foo:bar", "instance", "interface", "", "0", "1",
    "f", "func", "function", "false", "0", "none", "0",
  ])
  assert_eq(composition_edges(model), ["2", "f", "1"])
  assert_eq(implicit_import_projection(model), [
    "1", "f", "func", "function", "false", "0", "none", "0",
  ])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, ["i:2", "world:0"])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, ["i", "world"])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, ["world", "", "i"])
}

///|
test "upstream WAC types.wac" {
  let source = "package test:comp;\n\n/// Defining an interface\ninterface i {\n    /// Type alias a\n    type a = func();\n    /// Record type\n    record r {\n        x: u32\n    }\n    /// Export func\n    x: func();\n    /// Export func of type a\n    y: a;\n}\n\n/// Defining a second interface\ninterface i2 {\n    /// Use type r from i\n    use i.{r};\n\n    /// Use type r from i as z\n    use i.{r as z};\n}\n\ntype c = func();\ntype f = c;\n\n/// Defining a world\nworld w1 {\n    /// Use type r from foo:bar/i\n    use foo:bar/i.{r};\n\n    /// Import a function\n    import a: func();\n    /// Import an interface\n    import i;\n    /// Import by name with type `c`\n    import c: c;\n\n    /// Export an inline interface\n    export d: interface {\n        x: func();\n    };\n    /// Export an interface\n    export i2;\n    /// Export by name with type `f`\n    export f: f;\n}\n\n/// Defining a second world\nworld w2 {\n    /// Include the first world\n    include w1;\n\n    /// Include a world by path\n    include foo:bar/baz;\n\n    /// Defining a resource\n\n    resource res {\n        constructor();\n    }\n}\n\ntype x = u32;\n\n/// Defining a variant\nvariant v {\n    a(x),\n    b(string),\n    c(u32),\n    d,\n}\n\n/// Defining a record\nrecord r {\n    x: u32,\n    y: string,\n    z: v,\n}\n\n/// Defining flags\nflags %flags {\n    a,\n    b,\n    c,\n}\n\n/// Defining an enum\nenum e {\n    a,\n    b,\n    c,\n}\n\n/// Type aliases\ntype t = e;\ntype t2 = string;\ntype t3 = func(a: u32, b: r) -> u32;\n"
  let result = corpus_verify(source~, source_id="types.wac", dependencies=[], wit_dependencies=[
    {
      name: "foo:bar",
      version: None,
      source: "types/foo/bar",
      root: Source({
        documents: [
          wit_document(
            "types/foo/bar/package.wit", "package foo:bar;\n\ninterface i {\n    resource r;\n}\n\nworld baz {\n}\n",
          ),
        ],
      }),
      dependencies: [],
    },
  ])
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
    "14", "definition", "type", "interface", "test:comp/i", "0", "4", "a", "type",
    "function", "false", "0", "none", "r", "type", "record", "1", "x", "scalar",
    "u32", "x", "func", "function", "false", "0", "none", "y", "func", "function",
    "false", "0", "none", "definition", "type", "interface", "test:comp/i2", "2",
    "r", "r", "test:comp/i", "z", "r", "test:comp/i", "2", "r", "type", "record",
    "1", "x", "scalar", "u32", "z", "type", "record", "1", "x", "scalar", "u32",
    "definition", "type", "function", "false", "0", "none", "definition", "type",
    "function", "false", "0", "none", "definition", "type", "world", "test:comp/w1",
    "1", "r", "r", "foo:bar/i", "4", "r", "type", "resource", "0", "a", "func", "function",
    "false", "0", "none", "test:comp/i", "instance", "interface", "test:comp/i",
    "0", "4", "a", "type", "function", "false", "0", "none", "r", "type", "record",
    "1", "x", "scalar", "u32", "x", "func", "function", "false", "0", "none", "y",
    "func", "function", "false", "0", "none", "c", "func", "function", "false", "0",
    "none", "3", "d", "instance", "interface", "", "0", "1", "x", "func", "function",
    "false", "0", "none", "test:comp/i2", "instance", "interface", "test:comp/i2",
    "2", "r", "r", "test:comp/i", "z", "r", "test:comp/i", "2", "r", "type", "record",
    "1", "x", "scalar", "u32", "z", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "0", "none", "definition", "type", "world",
    "test:comp/w2", "0", "6", "res", "type", "resource", "1", "[constructor]res",
    "func", "function", "false", "0", "some", "own", "1", "r", "type", "resource",
    "0", "a", "func", "function", "false", "0", "none", "test:comp/i", "instance",
    "interface", "test:comp/i", "0", "4", "a", "type", "function", "false", "0",
    "none", "r", "type", "record", "1", "x", "scalar", "u32", "x", "func", "function",
    "false", "0", "none", "y", "func", "function", "false", "0", "none", "c", "func",
    "function", "false", "0", "none", "3", "d", "instance", "interface", "", "0",
    "1", "x", "func", "function", "false", "0", "none", "test:comp/i2", "instance",
    "interface", "test:comp/i2", "2", "r", "r", "test:comp/i", "z", "r", "test:comp/i",
    "2", "r", "type", "record", "1", "x", "scalar", "u32", "z", "type", "record",
    "1", "x", "scalar", "u32", "f", "func", "function", "false", "0", "none", "definition",
    "type", "scalar", "u32", "definition", "type", "variant", "4", "a", "some", "scalar",
    "u32", "b", "some", "scalar", "string", "c", "some", "scalar", "u32", "d", "none",
    "definition", "type", "record", "3", "x", "scalar", "u32", "y", "scalar", "string",
    "z", "variant", "4", "a", "some", "scalar", "u32", "b", "some", "scalar", "string",
    "c", "some", "scalar", "u32", "d", "none", "definition", "type", "flags", "3",
    "a", "b", "c", "definition", "type", "enum", "3", "a", "b", "c", "definition",
    "type", "enum", "3", "a", "b", "c", "definition", "type", "scalar", "string",
    "definition", "type", "function", "false", "2", "a", "scalar", "u32", "b", "record",
    "3", "x", "scalar", "u32", "y", "scalar", "string", "z", "variant", "4", "a",
    "some", "scalar", "u32", "b", "some", "scalar", "string", "c", "some", "scalar",
    "u32", "d", "none", "some", "scalar", "u32", "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, [
    "c:2", "f:3", "i:0", "r:8", "v:7", "x:6", "e:10", "i2:1", "t:11", "w1:4", "w2:5",
    "t2:12", "t3:13", "flags:9",
  ])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, [
    "c", "e", "f", "i", "r", "t", "v", "x", "i2", "t2", "t3", "w1", "w2", "flags",
  ])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, [
    "i", "i2", "c", "f", "w1", "w2", "x", "v", "r", "flags", "e", "t", "t2", "t3",
  ])
}

///|
test "upstream WAC wasip3-types.wac" {
  let source = "package test:comp;\n\n// wasip3 value types: stream, future, error-context\ntype stream1 = stream;\ntype stream2 = stream<u32>;\ntype stream3 = stream<list<string>>;\n\ntype future1 = future;\ntype future2 = future<u32>;\ntype future3 = future<option<string>>;\n\ntype ec = error-context;\n\n// async function types\ntype async-fn = async func() -> string;\ntype async-fn-with-stream = async func(data: list<u8>) -> stream<u8>;\ntype sync-fn = func() -> string;\n\n/// Interface mixing async and sync functions and wasip3 types\ninterface async-iface {\n    process: async func(input: list<u8>) -> stream<u8>;\n    get-result: async func() -> future<string>;\n    sync-op: func(x: u32) -> u32;\n    type my-stream = stream<u32>;\n    type my-future = future<string>;\n    type my-ec = error-context;\n}\n\n/// World with async imports and exports\nworld async-world {\n    import run: async func() -> string;\n    import fetch: async func(url: string) -> stream<u8>;\n    export process: async func(data: list<u8>) -> future<u32>;\n}\n"
  let result = corpus_verify(
    source~,
    source_id="wasip3-types.wac",
    dependencies=[],
    wit_dependencies=[],
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
    "12", "definition", "type", "stream", "none", "definition", "type", "stream",
    "some", "scalar", "u32", "definition", "type", "stream", "some", "list", "scalar",
    "string", "definition", "type", "future", "none", "definition", "type", "future",
    "some", "scalar", "u32", "definition", "type", "future", "some", "option", "scalar",
    "string", "definition", "type", "scalar", "error-context", "definition", "type",
    "function", "true", "0", "some", "scalar", "string", "definition", "type", "function",
    "true", "1", "data", "list", "scalar", "u8", "some", "stream", "some", "scalar",
    "u8", "definition", "type", "function", "false", "0", "some", "scalar", "string",
    "definition", "type", "interface", "test:comp/async-iface", "0", "6", "process",
    "func", "function", "true", "1", "input", "list", "scalar", "u8", "some", "stream",
    "some", "scalar", "u8", "get-result", "func", "function", "true", "0", "some",
    "future", "some", "scalar", "string", "sync-op", "func", "function", "false",
    "1", "x", "scalar", "u32", "some", "scalar", "u32", "my-stream", "type", "stream",
    "some", "scalar", "u32", "my-future", "type", "future", "some", "scalar", "string",
    "my-ec", "type", "scalar", "error-context", "definition", "type", "world", "test:comp/async-world",
    "0", "2", "run", "func", "function", "true", "0", "some", "scalar", "string",
    "fetch", "func", "function", "true", "1", "url", "scalar", "string", "some",
    "stream", "some", "scalar", "u8", "1", "process", "func", "function", "true",
    "1", "data", "list", "scalar", "u8", "some", "future", "some", "scalar", "u32",
    "0",
  ])
  assert_eq(composition_edges(model), [])
  assert_eq(implicit_import_projection(model), ["0", "0"])
  let named_exports = model
    .composition_exports()
    .iter()
    .map(entry => entry.name + ":" + entry.value.to_string())
    .to_array()
  named_exports.sort()
  assert_eq(named_exports, [
    "ec:6", "future1:3", "future2:4", "future3:5", "stream1:0", "stream2:1", "stream3:2",
    "sync-fn:9", "async-fn:7", "async-iface:10", "async-world:11", "async-fn-with-stream:8",
  ])
  let encoded_names = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    encoded_names[item.value] = item.name
  }
  let emitted = encoded_names.filter(name => name != "")
  emitted.sort()
  assert_eq(emitted, [
    "ec", "future1", "future2", "future3", "stream1", "stream2", "stream3", "sync-fn",
    "async-fn", "async-iface", "async-world", "async-fn-with-stream",
  ])
  let last_exports = Array::make(model.composition().length(), "")
  for item in model.composition_exports() {
    last_exports[item.value] = item.name
  }
  assert_eq(last_exports, [
    "stream1", "stream2", "stream3", "future1", "future2", "future3", "ec", "async-fn",
    "async-fn-with-stream", "sync-fn", "async-iface", "async-world",
  ])
}
