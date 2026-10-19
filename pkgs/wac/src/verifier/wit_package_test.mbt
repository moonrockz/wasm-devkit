// Original pinned inputs and acceptance table: tests/semantic/wac-wit-providers.

///|
// Reference projections compare ordered structure, named uses, item sorts and
// nominal resource equivalence. Numeric arena IDs and transparent aliases are
// representation details and do not participate in this comparison.
fn wit_projection(model : @verifier.WitPackage) -> Array[String] raise {
  let work : Array[BinaryProjectionWork] = []
  for i = model.definitions().length() - 1; i >= 0; i = i - 1 {
    work.push(Item(model.definitions()[i]))
  }
  work.push(Text(model.definitions().length().to_string()))
  work.push(Text("definitions"))
  work.push(Type(model.instance()))
  work.push(Text("instance"))
  work.push(Type(model.world()))
  project_graph(model.types(), id => model.resource_identity(id), work)
}

///|
fn wit_document(name : String, source : String) -> @wit_verifier.Document {
  @wit_verifier.Document::from_parse(
    name,
    source,
    @wit_parser.parse(source, features={
      ..@wit_parser.Features::default(),
      fixed_lists: true,
      external_ids: true,
    }),
  )
}

///|
test "adapt pinned WIT basic" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {f: func();} world app {import api;export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
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
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "0", "1",
    "f", "func", "function", "false", "0", "none", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none",
  ])
}

///|
test "adapt pinned WIT instantiate-types" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {f: func();} world app {import api;export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
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
  let source = "package test:app;let i=new lookup:types {};export i...;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "0", "2", "api", "type", "world", "", "0", "0", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none",
  ])
}

///|
test "adapt pinned WIT type-wrapper-access" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance", "interface", "", "0", "1", "api", "type", "world",
    "", "0", "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "1",
    "api", "type", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none",
  ])
  let source = "package test:app;let i=new lookup:types {};export i.api;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none",
  ])
}

///|
test "adapt pinned WIT type-wrapper-call" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance", "interface", "", "0", "1", "api", "type", "world",
    "", "0", "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "1",
    "api", "type", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none",
  ])
  let source = "package test:app;let i=new lookup:types {};export i.api.f;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT world-import" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {f: func();} world app {import api;export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
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
  let source = "package test:app;import implementation: lookup:types/app;export implementation;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "1",
    "example:types/api", "instance", "interface", "example:types/api", "0", "1",
    "f", "func", "function", "false", "0", "none", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none", "1", "lookup:types/app", "component", "world", "example:types/app",
    "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none",
  ])
}

///|
test "adapt pinned WIT world-include" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {f: func();} world app {import api;export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
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
  let source = "package test:app;world composed {include lookup:types/app;}"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "0", "1", "composed", "type", "world", "test:app/composed", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none",
  ])
}

///|
test "adapt pinned WIT resource" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {resource handle {constructor(); take: func(); create: static func() -> handle;}}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "4", "handle", "type", "resource",
    "0", "[constructor]handle", "func", "function", "false", "0", "some", "own",
    "0", "[method]handle.take", "func", "function", "false", "1", "self", "borrow",
    "0", "none", "[static]handle.create", "func", "function", "false", "0", "some",
    "own", "0", "instance", "interface", "", "0", "1", "api", "type", "world", "",
    "0", "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "4", "handle", "type", "resource", "0", "[constructor]handle", "func", "function",
    "false", "0", "some", "own", "0", "[method]handle.take", "func", "function",
    "false", "1", "self", "borrow", "0", "none", "[static]handle.create", "func",
    "function", "false", "0", "some", "own", "0", "definitions", "1", "api", "type",
    "interface", "example:types/api", "0", "4", "handle", "type", "resource", "0",
    "[constructor]handle", "func", "function", "false", "0", "some", "own", "0",
    "[method]handle.take", "func", "function", "false", "1", "self", "borrow", "0",
    "none", "[static]handle.create", "func", "function", "false", "0", "some", "own",
    "0",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "0", "4",
    "handle", "type", "resource", "0", "[constructor]handle", "func", "function",
    "false", "0", "some", "own", "0", "[method]handle.take", "func", "function",
    "false", "1", "self", "borrow", "0", "none", "[static]handle.create", "func",
    "function", "false", "0", "some", "own", "0", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "4", "handle", "type", "resource", "0",
    "[constructor]handle", "func", "function", "false", "0", "some", "own", "0",
    "[method]handle.take", "func", "function", "false", "1", "self", "borrow", "0",
    "none", "[static]handle.create", "func", "function", "false", "0", "some", "own",
    "0",
  ])
}

///|
test "adapt pinned WIT resource-world-import-export" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {resource handle;take: func(h: handle);} world app {import api;export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "app",
    "type", "world", "", "0", "0", "1", "example:types/app", "component", "world",
    "example:types/app", "0", "1", "example:types/api", "instance", "interface",
    "example:types/api", "0", "2", "handle", "type", "resource", "1", "take", "func",
    "function", "false", "1", "h", "own", "1", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "2", "handle", "type", "resource",
    "2", "take", "func", "function", "false", "1", "h", "own", "2", "none", "instance",
    "interface", "", "0", "2", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "app",
    "type", "world", "", "0", "0", "1", "example:types/app", "component", "world",
    "example:types/app", "0", "1", "example:types/api", "instance", "interface",
    "example:types/api", "0", "2", "handle", "type", "resource", "1", "take", "func",
    "function", "false", "1", "h", "own", "1", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "2", "handle", "type", "resource",
    "2", "take", "func", "function", "false", "1", "h", "own", "2", "none", "definitions",
    "2", "api", "type", "interface", "example:types/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "app", "type", "world", "example:types/app", "0", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "2", "handle", "type", "resource", "1",
    "take", "func", "function", "false", "1", "h", "own", "1", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "2", "handle", "type", "resource",
    "2", "take", "func", "function", "false", "1", "h", "own", "2", "none",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "1",
    "example:types/api", "instance", "interface", "example:types/api", "0", "2",
    "handle", "type", "resource", "0", "take", "func", "function", "false", "1",
    "h", "own", "0", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "2", "handle", "type", "resource", "1", "take", "func", "function", "false",
    "1", "h", "own", "1", "none", "0",
  ])
}

///|
test "adapt pinned WIT resource-use" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface types {resource handle;} interface api {use types.{handle};take: func(h: handle);} world app {import api;export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "3", "types", "type", "world", "", "0", "0", "1", "example:types/types",
    "instance", "interface", "example:types/types", "0", "1", "handle", "type", "resource",
    "0", "api", "type", "world", "", "0", "1", "example:types/types", "instance",
    "interface", "example:types/types", "0", "1", "handle", "type", "resource", "1",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:types/types", "2", "handle", "type", "resource",
    "1", "take", "func", "function", "false", "1", "h", "own", "1", "none", "app",
    "type", "world", "", "0", "0", "1", "example:types/app", "component", "world",
    "example:types/app", "0", "2", "example:types/types", "instance", "interface",
    "example:types/types", "0", "1", "handle", "type", "resource", "2", "example:types/api",
    "instance", "interface", "example:types/api", "1", "handle", "handle", "example:types/types",
    "2", "handle", "type", "resource", "2", "take", "func", "function", "false",
    "1", "h", "own", "2", "none", "1", "example:types/api", "instance", "interface",
    "example:types/api", "1", "handle", "handle", "example:types/types", "2", "handle",
    "type", "resource", "2", "take", "func", "function", "false", "1", "h", "own",
    "2", "none", "instance", "interface", "", "0", "3", "types", "type", "world",
    "", "0", "0", "1", "example:types/types", "instance", "interface", "example:types/types",
    "0", "1", "handle", "type", "resource", "0", "api", "type", "world", "", "0",
    "1", "example:types/types", "instance", "interface", "example:types/types", "0",
    "1", "handle", "type", "resource", "1", "1", "example:types/api", "instance",
    "interface", "example:types/api", "1", "handle", "handle", "example:types/types",
    "2", "handle", "type", "resource", "1", "take", "func", "function", "false",
    "1", "h", "own", "1", "none", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "2", "example:types/types", "instance",
    "interface", "example:types/types", "0", "1", "handle", "type", "resource", "2",
    "example:types/api", "instance", "interface", "example:types/api", "1", "handle",
    "handle", "example:types/types", "2", "handle", "type", "resource", "2", "take",
    "func", "function", "false", "1", "h", "own", "2", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "handle", "handle", "example:types/types",
    "2", "handle", "type", "resource", "2", "take", "func", "function", "false",
    "1", "h", "own", "2", "none", "definitions", "3", "types", "type", "interface",
    "example:types/types", "0", "1", "handle", "type", "resource", "0", "api", "type",
    "interface", "example:types/api", "1", "handle", "handle", "example:types/types",
    "2", "handle", "type", "resource", "1", "take", "func", "function", "false",
    "1", "h", "own", "1", "none", "app", "type", "world", "example:types/app", "0",
    "2", "example:types/types", "instance", "interface", "example:types/types", "0",
    "1", "handle", "type", "resource", "2", "example:types/api", "instance", "interface",
    "example:types/api", "1", "handle", "handle", "example:types/types", "2", "handle",
    "type", "resource", "2", "take", "func", "function", "false", "1", "h", "own",
    "2", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "handle", "handle", "example:types/types", "2", "handle", "type", "resource",
    "2", "take", "func", "function", "false", "1", "h", "own", "2", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "handle",
    "handle", "example:types/types", "2", "handle", "type", "resource", "0", "take",
    "func", "function", "false", "1", "h", "own", "0", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "handle", "handle", "example:types/types",
    "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none",
  ])
}

///|
test "adapt pinned WIT resource-world-use" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface types {resource handle;} world app {use types.{handle};import take: func(h: handle);export make: func() -> handle;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "types", "type", "world", "", "0", "0", "1", "example:types/types",
    "instance", "interface", "example:types/types", "0", "1", "handle", "type", "resource",
    "0", "app", "type", "world", "", "0", "0", "1", "example:types/app", "component",
    "world", "example:types/app", "1", "handle", "handle", "example:types/types",
    "3", "example:types/types", "instance", "interface", "example:types/types", "0",
    "1", "handle", "type", "resource", "1", "handle", "type", "resource", "1", "take",
    "func", "function", "false", "1", "h", "own", "1", "none", "1", "make", "func",
    "function", "false", "0", "some", "own", "1", "instance", "interface", "", "0",
    "2", "types", "type", "world", "", "0", "0", "1", "example:types/types", "instance",
    "interface", "example:types/types", "0", "1", "handle", "type", "resource", "0",
    "app", "type", "world", "", "0", "0", "1", "example:types/app", "component",
    "world", "example:types/app", "1", "handle", "handle", "example:types/types",
    "3", "example:types/types", "instance", "interface", "example:types/types", "0",
    "1", "handle", "type", "resource", "1", "handle", "type", "resource", "1", "take",
    "func", "function", "false", "1", "h", "own", "1", "none", "1", "make", "func",
    "function", "false", "0", "some", "own", "1", "definitions", "2", "types", "type",
    "interface", "example:types/types", "0", "1", "handle", "type", "resource", "0",
    "app", "type", "world", "example:types/app", "1", "handle", "handle", "example:types/types",
    "3", "example:types/types", "instance", "interface", "example:types/types", "0",
    "1", "handle", "type", "resource", "1", "handle", "type", "resource", "1", "take",
    "func", "function", "false", "1", "h", "own", "1", "none", "1", "make", "func",
    "function", "false", "0", "some", "own", "1",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "1", "handle",
    "handle", "example:types/types", "3", "example:types/types", "instance", "interface",
    "example:types/types", "0", "1", "handle", "type", "resource", "0", "handle",
    "type", "resource", "0", "take", "func", "function", "false", "1", "h", "own",
    "0", "none", "1", "make", "func", "function", "false", "0", "some", "own", "0",
    "0",
  ])
}

///|
test "adapt pinned WIT world-resource" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; world app {resource handle {constructor();take: func();} export make: func() -> handle;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "3", "handle", "type", "resource",
    "0", "[constructor]handle", "func", "function", "false", "0", "some", "own",
    "0", "[method]handle.take", "func", "function", "false", "1", "self", "borrow",
    "0", "none", "1", "make", "func", "function", "false", "0", "some", "own", "0",
    "instance", "interface", "", "0", "1", "app", "type", "world", "", "0", "0",
    "1", "example:types/app", "component", "world", "example:types/app", "0", "3",
    "handle", "type", "resource", "0", "[constructor]handle", "func", "function",
    "false", "0", "some", "own", "0", "[method]handle.take", "func", "function",
    "false", "1", "self", "borrow", "0", "none", "1", "make", "func", "function",
    "false", "0", "some", "own", "0", "definitions", "1", "app", "type", "world",
    "example:types/app", "0", "3", "handle", "type", "resource", "0", "[constructor]handle",
    "func", "function", "false", "0", "some", "own", "0", "[method]handle.take",
    "func", "function", "false", "1", "self", "borrow", "0", "none", "1", "make",
    "func", "function", "false", "0", "some", "own", "0",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "3",
    "handle", "type", "resource", "0", "[constructor]handle", "func", "function",
    "false", "0", "some", "own", "0", "[method]handle.take", "func", "function",
    "false", "1", "self", "borrow", "0", "none", "1", "make", "func", "function",
    "false", "0", "some", "own", "0", "0",
  ])
}

///|
test "adapt pinned WIT aggregates" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {record rec {a: u32,b: string} variant v {a(rec),b} flags mask {a,b} enum e {a,b} type many=tuple<list<option<result<rec,v>>>,mask,e>; f: func(x: many) -> result<list<u8>,string>;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "6", "rec", "type", "record",
    "2", "a", "scalar", "u32", "b", "scalar", "string", "v", "type", "variant", "2",
    "a", "some", "record", "2", "a", "scalar", "u32", "b", "scalar", "string", "b",
    "none", "mask", "type", "flags", "2", "a", "b", "e", "type", "enum", "2", "a",
    "b", "many", "type", "tuple", "3", "list", "option", "result", "some", "record",
    "2", "a", "scalar", "u32", "b", "scalar", "string", "some", "variant", "2", "a",
    "some", "record", "2", "a", "scalar", "u32", "b", "scalar", "string", "b", "none",
    "flags", "2", "a", "b", "enum", "2", "a", "b", "f", "func", "function", "false",
    "1", "x", "tuple", "3", "list", "option", "result", "some", "record", "2", "a",
    "scalar", "u32", "b", "scalar", "string", "some", "variant", "2", "a", "some",
    "record", "2", "a", "scalar", "u32", "b", "scalar", "string", "b", "none", "flags",
    "2", "a", "b", "enum", "2", "a", "b", "some", "result", "some", "list", "scalar",
    "u8", "some", "scalar", "string", "instance", "interface", "", "0", "1", "api",
    "type", "world", "", "0", "0", "1", "example:types/api", "instance", "interface",
    "example:types/api", "0", "6", "rec", "type", "record", "2", "a", "scalar", "u32",
    "b", "scalar", "string", "v", "type", "variant", "2", "a", "some", "record",
    "2", "a", "scalar", "u32", "b", "scalar", "string", "b", "none", "mask", "type",
    "flags", "2", "a", "b", "e", "type", "enum", "2", "a", "b", "many", "type", "tuple",
    "3", "list", "option", "result", "some", "record", "2", "a", "scalar", "u32",
    "b", "scalar", "string", "some", "variant", "2", "a", "some", "record", "2",
    "a", "scalar", "u32", "b", "scalar", "string", "b", "none", "flags", "2", "a",
    "b", "enum", "2", "a", "b", "f", "func", "function", "false", "1", "x", "tuple",
    "3", "list", "option", "result", "some", "record", "2", "a", "scalar", "u32",
    "b", "scalar", "string", "some", "variant", "2", "a", "some", "record", "2",
    "a", "scalar", "u32", "b", "scalar", "string", "b", "none", "flags", "2", "a",
    "b", "enum", "2", "a", "b", "some", "result", "some", "list", "scalar", "u8",
    "some", "scalar", "string", "definitions", "1", "api", "type", "interface", "example:types/api",
    "0", "6", "rec", "type", "record", "2", "a", "scalar", "u32", "b", "scalar",
    "string", "v", "type", "variant", "2", "a", "some", "record", "2", "a", "scalar",
    "u32", "b", "scalar", "string", "b", "none", "mask", "type", "flags", "2", "a",
    "b", "e", "type", "enum", "2", "a", "b", "many", "type", "tuple", "3", "list",
    "option", "result", "some", "record", "2", "a", "scalar", "u32", "b", "scalar",
    "string", "some", "variant", "2", "a", "some", "record", "2", "a", "scalar",
    "u32", "b", "scalar", "string", "b", "none", "flags", "2", "a", "b", "enum",
    "2", "a", "b", "f", "func", "function", "false", "1", "x", "tuple", "3", "list",
    "option", "result", "some", "record", "2", "a", "scalar", "u32", "b", "scalar",
    "string", "some", "variant", "2", "a", "some", "record", "2", "a", "scalar",
    "u32", "b", "scalar", "string", "b", "none", "flags", "2", "a", "b", "enum",
    "2", "a", "b", "some", "result", "some", "list", "scalar", "u8", "some", "scalar",
    "string",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "0", "6",
    "rec", "type", "record", "2", "a", "scalar", "u32", "b", "scalar", "string",
    "v", "type", "variant", "2", "a", "some", "record", "2", "a", "scalar", "u32",
    "b", "scalar", "string", "b", "none", "mask", "type", "flags", "2", "a", "b",
    "e", "type", "enum", "2", "a", "b", "many", "type", "tuple", "3", "list", "option",
    "result", "some", "record", "2", "a", "scalar", "u32", "b", "scalar", "string",
    "some", "variant", "2", "a", "some", "record", "2", "a", "scalar", "u32", "b",
    "scalar", "string", "b", "none", "flags", "2", "a", "b", "enum", "2", "a", "b",
    "f", "func", "function", "false", "1", "x", "tuple", "3", "list", "option", "result",
    "some", "record", "2", "a", "scalar", "u32", "b", "scalar", "string", "some",
    "variant", "2", "a", "some", "record", "2", "a", "scalar", "u32", "b", "scalar",
    "string", "b", "none", "flags", "2", "a", "b", "enum", "2", "a", "b", "some",
    "result", "some", "list", "scalar", "u8", "some", "scalar", "string", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "6", "rec", "type", "record",
    "2", "a", "scalar", "u32", "b", "scalar", "string", "v", "type", "variant", "2",
    "a", "some", "record", "2", "a", "scalar", "u32", "b", "scalar", "string", "b",
    "none", "mask", "type", "flags", "2", "a", "b", "e", "type", "enum", "2", "a",
    "b", "many", "type", "tuple", "3", "list", "option", "result", "some", "record",
    "2", "a", "scalar", "u32", "b", "scalar", "string", "some", "variant", "2", "a",
    "some", "record", "2", "a", "scalar", "u32", "b", "scalar", "string", "b", "none",
    "flags", "2", "a", "b", "enum", "2", "a", "b", "f", "func", "function", "false",
    "1", "x", "tuple", "3", "list", "option", "result", "some", "record", "2", "a",
    "scalar", "u32", "b", "scalar", "string", "some", "variant", "2", "a", "some",
    "record", "2", "a", "scalar", "u32", "b", "scalar", "string", "b", "none", "flags",
    "2", "a", "b", "enum", "2", "a", "b", "some", "result", "some", "list", "scalar",
    "u8", "some", "scalar", "string",
  ])
}

///|
test "adapt pinned WIT async" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {f: async func(x: future<u32>) -> stream<string>;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "true", "1", "x", "future", "some", "scalar", "u32", "some", "stream", "some",
    "scalar", "string", "instance", "interface", "", "0", "1", "api", "type", "world",
    "", "0", "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "true", "1", "x", "future", "some", "scalar",
    "u32", "some", "stream", "some", "scalar", "string", "definitions", "1", "api",
    "type", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "true", "1", "x", "future", "some", "scalar", "u32", "some", "stream", "some",
    "scalar", "string",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "0", "1",
    "f", "func", "function", "true", "1", "x", "future", "some", "scalar", "u32",
    "some", "stream", "some", "scalar", "string", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "true",
    "1", "x", "future", "some", "scalar", "u32", "some", "stream", "some", "scalar",
    "string",
  ])
}

///|
test "adapt pinned WIT fixed-list" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {type bytes=list<u8,4>;f: func(x: bytes);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "2", "bytes", "type", "fixed-list",
    "4", "scalar", "u8", "f", "func", "function", "false", "1", "x", "fixed-list",
    "4", "scalar", "u8", "none", "instance", "interface", "", "0", "1", "api", "type",
    "world", "", "0", "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "2", "bytes", "type", "fixed-list", "4", "scalar", "u8", "f", "func", "function",
    "false", "1", "x", "fixed-list", "4", "scalar", "u8", "none", "definitions",
    "1", "api", "type", "interface", "example:types/api", "0", "2", "bytes", "type",
    "fixed-list", "4", "scalar", "u8", "f", "func", "function", "false", "1", "x",
    "fixed-list", "4", "scalar", "u8", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "0", "2",
    "bytes", "type", "fixed-list", "4", "scalar", "u8", "f", "func", "function",
    "false", "1", "x", "fixed-list", "4", "scalar", "u8", "none", "0",
  ])
}

///|
test "adapt pinned WIT map" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {type lookup=map<string,u32>;f: func(x: lookup);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "2", "lookup", "type", "map",
    "scalar", "string", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "map", "scalar", "string", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "2", "lookup", "type", "map",
    "scalar", "string", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "map", "scalar", "string", "scalar", "u32", "none", "definitions", "1", "api",
    "type", "interface", "example:types/api", "0", "2", "lookup", "type", "map",
    "scalar", "string", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "map", "scalar", "string", "scalar", "u32", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "0", "2",
    "lookup", "type", "map", "scalar", "string", "scalar", "u32", "f", "func", "function",
    "false", "1", "x", "map", "scalar", "string", "scalar", "u32", "none", "0",
  ])
}

///|
test "adapt pinned WIT alias-chain" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface a {resource handle;type first=handle;} interface b {use a.{first};type second=first;} interface api {use b.{second};f: func(x: second);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "3", "a", "type", "world", "", "0", "0", "1", "example:types/a",
    "instance", "interface", "example:types/a", "0", "2", "handle", "type", "resource",
    "0", "first", "type", "resource", "0", "b", "type", "world", "", "0", "1", "example:types/a",
    "instance", "interface", "example:types/a", "0", "2", "handle", "type", "resource",
    "1", "first", "type", "resource", "1", "1", "example:types/b", "instance", "interface",
    "example:types/b", "2", "first", "handle", "example:types/a", "second", "handle",
    "example:types/a", "2", "first", "type", "resource", "1", "second", "type", "resource",
    "1", "api", "type", "world", "", "0", "2", "example:types/a", "instance", "interface",
    "example:types/a", "0", "2", "handle", "type", "resource", "2", "first", "type",
    "resource", "2", "example:types/b", "instance", "interface", "example:types/b",
    "2", "first", "handle", "example:types/a", "second", "handle", "example:types/a",
    "2", "first", "type", "resource", "2", "second", "type", "resource", "2", "1",
    "example:types/api", "instance", "interface", "example:types/api", "1", "second",
    "handle", "example:types/a", "2", "second", "type", "resource", "2", "f", "func",
    "function", "false", "1", "x", "own", "2", "none", "instance", "interface", "",
    "0", "3", "a", "type", "world", "", "0", "0", "1", "example:types/a", "instance",
    "interface", "example:types/a", "0", "2", "handle", "type", "resource", "0",
    "first", "type", "resource", "0", "b", "type", "world", "", "0", "1", "example:types/a",
    "instance", "interface", "example:types/a", "0", "2", "handle", "type", "resource",
    "1", "first", "type", "resource", "1", "1", "example:types/b", "instance", "interface",
    "example:types/b", "2", "first", "handle", "example:types/a", "second", "handle",
    "example:types/a", "2", "first", "type", "resource", "1", "second", "type", "resource",
    "1", "api", "type", "world", "", "0", "2", "example:types/a", "instance", "interface",
    "example:types/a", "0", "2", "handle", "type", "resource", "2", "first", "type",
    "resource", "2", "example:types/b", "instance", "interface", "example:types/b",
    "2", "first", "handle", "example:types/a", "second", "handle", "example:types/a",
    "2", "first", "type", "resource", "2", "second", "type", "resource", "2", "1",
    "example:types/api", "instance", "interface", "example:types/api", "1", "second",
    "handle", "example:types/a", "2", "second", "type", "resource", "2", "f", "func",
    "function", "false", "1", "x", "own", "2", "none", "definitions", "3", "a", "type",
    "interface", "example:types/a", "0", "2", "handle", "type", "resource", "0",
    "first", "type", "resource", "0", "b", "type", "interface", "example:types/b",
    "2", "first", "handle", "example:types/a", "second", "handle", "example:types/a",
    "2", "first", "type", "resource", "1", "second", "type", "resource", "1", "api",
    "type", "interface", "example:types/api", "1", "second", "handle", "example:types/a",
    "2", "second", "type", "resource", "2", "f", "func", "function", "false", "1",
    "x", "own", "2", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "second",
    "handle", "example:types/a", "2", "second", "type", "resource", "0", "f", "func",
    "function", "false", "1", "x", "own", "0", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "second", "handle", "example:types/a",
    "2", "second", "type", "resource", "0", "f", "func", "function", "false", "1",
    "x", "own", "0", "none",
  ])
}

///|
test "adapt pinned WIT inline-world" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; world app {import i: interface {resource handle;f: func(h: handle);} export o: interface {f: func();}}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "1", "i", "instance", "interface",
    "", "0", "2", "handle", "type", "resource", "0", "f", "func", "function", "false",
    "1", "h", "own", "0", "none", "1", "o", "instance", "interface", "", "0", "1",
    "f", "func", "function", "false", "0", "none", "instance", "interface", "", "0",
    "1", "app", "type", "world", "", "0", "0", "1", "example:types/app", "component",
    "world", "example:types/app", "0", "1", "i", "instance", "interface", "", "0",
    "2", "handle", "type", "resource", "0", "f", "func", "function", "false", "1",
    "h", "own", "0", "none", "1", "o", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "0", "none", "definitions", "1", "app", "type",
    "world", "example:types/app", "0", "1", "i", "instance", "interface", "", "0",
    "2", "handle", "type", "resource", "0", "f", "func", "function", "false", "1",
    "h", "own", "0", "none", "1", "o", "instance", "interface", "", "0", "1", "f",
    "func", "function", "false", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "1",
    "i", "instance", "interface", "", "0", "2", "handle", "type", "resource", "0",
    "f", "func", "function", "false", "1", "h", "own", "0", "none", "1", "o", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
}

///|
test "adapt pinned WIT version" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package embedded:types@1.2.3+build; interface api {f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "embedded:types/api@1.2.3+build",
    "instance", "interface", "embedded:types/api@1.2.3+build", "0", "1", "f", "func",
    "function", "false", "0", "none", "instance", "interface", "", "0", "1", "api",
    "type", "world", "", "0", "0", "1", "embedded:types/api@1.2.3+build", "instance",
    "interface", "embedded:types/api@1.2.3+build", "0", "1", "f", "func", "function",
    "false", "0", "none", "definitions", "1", "api", "type", "interface", "embedded:types/api@1.2.3+build",
    "0", "1", "f", "func", "function", "false", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "embedded:types/api@1.2.3+build",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
}

///|
test "adapt pinned WIT forward-interface" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {use base.{handle};f: func(h: handle);} interface base {resource handle;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "handle", "type", "resource",
    "0", "api", "type", "world", "", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "1",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:types/base", "2", "handle", "type", "resource",
    "1", "f", "func", "function", "false", "1", "h", "own", "1", "none", "instance",
    "interface", "", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "handle", "type", "resource",
    "0", "api", "type", "world", "", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "1",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:types/base", "2", "handle", "type", "resource",
    "1", "f", "func", "function", "false", "1", "h", "own", "1", "none", "definitions",
    "2", "base", "type", "interface", "example:types/base", "0", "1", "handle", "type",
    "resource", "0", "api", "type", "interface", "example:types/api", "1", "handle",
    "handle", "example:types/base", "2", "handle", "type", "resource", "1", "f",
    "func", "function", "false", "1", "h", "own", "1", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "handle",
    "handle", "example:types/base", "2", "handle", "type", "resource", "0", "f",
    "func", "function", "false", "1", "h", "own", "0", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "handle", "handle", "example:types/base",
    "2", "handle", "type", "resource", "0", "f", "func", "function", "false", "1",
    "h", "own", "0", "none",
  ])
}

///|
test "adapt pinned WIT scalar-use" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface base {type value=u32;} interface api {use base.{value};f: func(v: value);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "value", "type", "scalar",
    "u32", "api", "type", "world", "", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "value", "type", "scalar", "u32",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "value", "value", "example:types/base", "2", "value", "type", "scalar", "u32",
    "f", "func", "function", "false", "1", "v", "scalar", "u32", "none", "instance",
    "interface", "", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "value", "type", "scalar",
    "u32", "api", "type", "world", "", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "value", "type", "scalar", "u32",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "value", "value", "example:types/base", "2", "value", "type", "scalar", "u32",
    "f", "func", "function", "false", "1", "v", "scalar", "u32", "none", "definitions",
    "2", "base", "type", "interface", "example:types/base", "0", "1", "value", "type",
    "scalar", "u32", "api", "type", "interface", "example:types/api", "1", "value",
    "value", "example:types/base", "2", "value", "type", "scalar", "u32", "f", "func",
    "function", "false", "1", "v", "scalar", "u32", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "value",
    "value", "example:types/base", "2", "value", "type", "scalar", "u32", "f", "func",
    "function", "false", "1", "v", "scalar", "u32", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "value", "value", "example:types/base",
    "2", "value", "type", "scalar", "u32", "f", "func", "function", "false", "1",
    "v", "scalar", "u32", "none",
  ])
}

///|
test "adapt pinned WIT record-use" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface base {record value {x:u32}} interface api {use base.{value as renamed};f: func(v: renamed);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "api", "type", "world", "", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "1", "example:types/api", "instance", "interface",
    "example:types/api", "1", "renamed", "value", "example:types/base", "2", "renamed",
    "type", "record", "1", "x", "scalar", "u32", "f", "func", "function", "false",
    "1", "v", "record", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "api", "type", "world", "", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "1", "example:types/api", "instance", "interface",
    "example:types/api", "1", "renamed", "value", "example:types/base", "2", "renamed",
    "type", "record", "1", "x", "scalar", "u32", "f", "func", "function", "false",
    "1", "v", "record", "1", "x", "scalar", "u32", "none", "definitions", "2", "base",
    "type", "interface", "example:types/base", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "api", "type", "interface", "example:types/api", "1",
    "renamed", "value", "example:types/base", "2", "renamed", "type", "record", "1",
    "x", "scalar", "u32", "f", "func", "function", "false", "1", "v", "record", "1",
    "x", "scalar", "u32", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "renamed",
    "value", "example:types/base", "2", "renamed", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "v", "record", "1", "x", "scalar",
    "u32", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "renamed", "value", "example:types/base", "2", "renamed", "type", "record",
    "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "v", "record",
    "1", "x", "scalar", "u32", "none",
  ])
}

///|
test "adapt pinned WIT record-alias-chain" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface a {record value {x:u32}} interface b {use a.{value};type second=value;} interface api {use b.{second};f: func(v: second);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "3", "a", "type", "world", "", "0", "0", "1", "example:types/a",
    "instance", "interface", "example:types/a", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "b", "type", "world", "", "0", "1", "example:types/a",
    "instance", "interface", "example:types/a", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "1", "example:types/b", "instance", "interface", "example:types/b",
    "2", "value", "value", "example:types/a", "second", "value", "example:types/a",
    "2", "value", "type", "record", "1", "x", "scalar", "u32", "second", "type",
    "record", "1", "x", "scalar", "u32", "api", "type", "world", "", "0", "2", "example:types/a",
    "instance", "interface", "example:types/a", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "example:types/b", "instance", "interface", "example:types/b",
    "2", "value", "value", "example:types/a", "second", "value", "example:types/a",
    "2", "value", "type", "record", "1", "x", "scalar", "u32", "second", "type",
    "record", "1", "x", "scalar", "u32", "1", "example:types/api", "instance", "interface",
    "example:types/api", "1", "second", "value", "example:types/a", "2", "second",
    "type", "record", "1", "x", "scalar", "u32", "f", "func", "function", "false",
    "1", "v", "record", "1", "x", "scalar", "u32", "none", "instance", "interface",
    "", "0", "3", "a", "type", "world", "", "0", "0", "1", "example:types/a", "instance",
    "interface", "example:types/a", "0", "1", "value", "type", "record", "1", "x",
    "scalar", "u32", "b", "type", "world", "", "0", "1", "example:types/a", "instance",
    "interface", "example:types/a", "0", "1", "value", "type", "record", "1", "x",
    "scalar", "u32", "1", "example:types/b", "instance", "interface", "example:types/b",
    "2", "value", "value", "example:types/a", "second", "value", "example:types/a",
    "2", "value", "type", "record", "1", "x", "scalar", "u32", "second", "type",
    "record", "1", "x", "scalar", "u32", "api", "type", "world", "", "0", "2", "example:types/a",
    "instance", "interface", "example:types/a", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "example:types/b", "instance", "interface", "example:types/b",
    "2", "value", "value", "example:types/a", "second", "value", "example:types/a",
    "2", "value", "type", "record", "1", "x", "scalar", "u32", "second", "type",
    "record", "1", "x", "scalar", "u32", "1", "example:types/api", "instance", "interface",
    "example:types/api", "1", "second", "value", "example:types/a", "2", "second",
    "type", "record", "1", "x", "scalar", "u32", "f", "func", "function", "false",
    "1", "v", "record", "1", "x", "scalar", "u32", "none", "definitions", "3", "a",
    "type", "interface", "example:types/a", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "b", "type", "interface", "example:types/b", "2",
    "value", "value", "example:types/a", "second", "value", "example:types/a", "2",
    "value", "type", "record", "1", "x", "scalar", "u32", "second", "type", "record",
    "1", "x", "scalar", "u32", "api", "type", "interface", "example:types/api", "1",
    "second", "value", "example:types/a", "2", "second", "type", "record", "1", "x",
    "scalar", "u32", "f", "func", "function", "false", "1", "v", "record", "1", "x",
    "scalar", "u32", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "second",
    "value", "example:types/a", "2", "second", "type", "record", "1", "x", "scalar",
    "u32", "f", "func", "function", "false", "1", "v", "record", "1", "x", "scalar",
    "u32", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "second", "value", "example:types/a", "2", "second", "type", "record", "1",
    "x", "scalar", "u32", "f", "func", "function", "false", "1", "v", "record", "1",
    "x", "scalar", "u32", "none",
  ])
}

///|
test "adapt pinned WIT world-use-value" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface base {record value {x:u32}} world app {use base.{value as renamed};import f: func(v: renamed);export g: func() -> renamed;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "1", "renamed", "value", "example:types/base",
    "3", "example:types/base", "instance", "interface", "example:types/base", "0",
    "1", "value", "type", "record", "1", "x", "scalar", "u32", "renamed", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "v",
    "record", "1", "x", "scalar", "u32", "none", "1", "g", "func", "function", "false",
    "0", "some", "record", "1", "x", "scalar", "u32", "instance", "interface", "",
    "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "value", "type", "record", "1",
    "x", "scalar", "u32", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "1", "renamed", "value", "example:types/base",
    "3", "example:types/base", "instance", "interface", "example:types/base", "0",
    "1", "value", "type", "record", "1", "x", "scalar", "u32", "renamed", "type",
    "record", "1", "x", "scalar", "u32", "f", "func", "function", "false", "1", "v",
    "record", "1", "x", "scalar", "u32", "none", "1", "g", "func", "function", "false",
    "0", "some", "record", "1", "x", "scalar", "u32", "definitions", "2", "base",
    "type", "interface", "example:types/base", "0", "1", "value", "type", "record",
    "1", "x", "scalar", "u32", "app", "type", "world", "example:types/app", "1",
    "renamed", "value", "example:types/base", "3", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "value", "type", "record", "1",
    "x", "scalar", "u32", "renamed", "type", "record", "1", "x", "scalar", "u32",
    "f", "func", "function", "false", "1", "v", "record", "1", "x", "scalar", "u32",
    "none", "1", "g", "func", "function", "false", "0", "some", "record", "1", "x",
    "scalar", "u32",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "1", "renamed",
    "value", "example:types/base", "3", "example:types/base", "instance", "interface",
    "example:types/base", "0", "1", "value", "type", "record", "1", "x", "scalar",
    "u32", "renamed", "type", "record", "1", "x", "scalar", "u32", "f", "func", "function",
    "false", "1", "v", "record", "1", "x", "scalar", "u32", "none", "1", "g", "func",
    "function", "false", "0", "some", "record", "1", "x", "scalar", "u32", "0",
  ])
}

///|
test "adapt pinned WIT export-only-use" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface base {resource handle;} interface api {use base.{handle};f: func(h:handle);} world app {export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "3", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "handle", "type", "resource",
    "0", "api", "type", "world", "", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "1",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:types/base", "2", "handle", "type", "resource",
    "1", "f", "func", "function", "false", "1", "h", "own", "1", "none", "app", "type",
    "world", "", "0", "0", "1", "example:types/app", "component", "world", "example:types/app",
    "0", "1", "example:types/base", "instance", "interface", "example:types/base",
    "0", "1", "handle", "type", "resource", "2", "1", "example:types/api", "instance",
    "interface", "example:types/api", "1", "handle", "handle", "example:types/base",
    "2", "handle", "type", "resource", "2", "f", "func", "function", "false", "1",
    "h", "own", "2", "none", "instance", "interface", "", "0", "3", "base", "type",
    "world", "", "0", "0", "1", "example:types/base", "instance", "interface", "example:types/base",
    "0", "1", "handle", "type", "resource", "0", "api", "type", "world", "", "0",
    "1", "example:types/base", "instance", "interface", "example:types/base", "0",
    "1", "handle", "type", "resource", "1", "1", "example:types/api", "instance",
    "interface", "example:types/api", "1", "handle", "handle", "example:types/base",
    "2", "handle", "type", "resource", "1", "f", "func", "function", "false", "1",
    "h", "own", "1", "none", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "2",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:types/base", "2", "handle", "type", "resource",
    "2", "f", "func", "function", "false", "1", "h", "own", "2", "none", "definitions",
    "3", "base", "type", "interface", "example:types/base", "0", "1", "handle", "type",
    "resource", "0", "api", "type", "interface", "example:types/api", "1", "handle",
    "handle", "example:types/base", "2", "handle", "type", "resource", "1", "f",
    "func", "function", "false", "1", "h", "own", "1", "none", "app", "type", "world",
    "example:types/app", "0", "1", "example:types/base", "instance", "interface",
    "example:types/base", "0", "1", "handle", "type", "resource", "2", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "handle", "handle", "example:types/base",
    "2", "handle", "type", "resource", "2", "f", "func", "function", "false", "1",
    "h", "own", "2", "none",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "1",
    "example:types/base", "instance", "interface", "example:types/base", "0", "1",
    "handle", "type", "resource", "0", "1", "example:types/api", "instance", "interface",
    "example:types/api", "1", "handle", "handle", "example:types/base", "2", "handle",
    "type", "resource", "0", "f", "func", "function", "false", "1", "h", "own", "0",
    "none", "0",
  ])
}

///|
test "adapt pinned WIT empty" {
  let root : @wit_verifier.SourcePackage = {
    documents: [wit_document("root.wit", "package example:types;")],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "0", "instance", "interface", "", "0", "0", "definitions",
    "0",
  ])
  let source = "package test:app;let i=new lookup:types {};"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), ["0", "0"])
}

///|
test "adapt pinned WIT multiple-worlds" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; world first {import f:func();} interface api {f:func();} world second {include first;export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "3", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "first", "type", "world", "", "0", "0", "1", "example:types/first",
    "component", "world", "example:types/first", "0", "1", "f", "func", "function",
    "false", "0", "none", "0", "second", "type", "world", "", "0", "0", "1", "example:types/second",
    "component", "world", "example:types/second", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "instance", "interface",
    "", "0", "3", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "first", "type", "world", "", "0", "0", "1", "example:types/first",
    "component", "world", "example:types/first", "0", "1", "f", "func", "function",
    "false", "0", "none", "0", "second", "type", "world", "", "0", "0", "1", "example:types/second",
    "component", "world", "example:types/second", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "3",
    "api", "type", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "first", "type", "world", "example:types/first", "0", "1",
    "f", "func", "function", "false", "0", "none", "0", "second", "type", "world",
    "example:types/second", "0", "1", "f", "func", "function", "false", "0", "none",
    "1", "example:types/api", "instance", "interface", "example:types/api", "0",
    "1", "f", "func", "function", "false", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/second;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/second", "component", "world", "example:types/second", "0",
    "1", "f", "func", "function", "false", "0", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "0",
  ])
}

///|
test "adapt pinned WIT invalid" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {type bad=missing;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(resolution is Err(_))
  let source = "package test:app;import i: lookup:types/api;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT bundle-transitive" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {use example:dep/types@1.2.3.{handle};take: func(h: handle);} world app {import api;export api;}",
      ),
      wit_document(
        "second.wit", "package example:types; interface extra {f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = [
    {
      documents: [
        wit_document(
          "deps/dep/types.wit", "package example:dep@1.2.3; interface types {resource handle;}",
        ),
      ],
    },
  ]
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
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
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "handle",
    "handle", "example:dep/types@1.2.3", "2", "handle", "type", "resource", "0",
    "take", "func", "function", "false", "1", "h", "own", "0", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "handle", "handle", "example:dep/types@1.2.3",
    "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none",
  ])
}

///|
test "adapt pinned WIT bundle-missing" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {use example:dep/types.{handle};take: func(h: handle);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(resolution is Err(_))
  let source = "package test:app;import i: lookup:types/api;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT bundle-versioned" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package embedded:types@2.1.0;interface api {f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "embedded:types/api@2.1.0",
    "instance", "interface", "embedded:types/api@2.1.0", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance", "interface", "", "0", "1", "api", "type", "world",
    "", "0", "0", "1", "embedded:types/api@2.1.0", "instance", "interface", "embedded:types/api@2.1.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "1",
    "api", "type", "interface", "embedded:types/api@2.1.0", "0", "1", "f", "func",
    "function", "false", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/api@1.2.3;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: Some("1.2.3"),
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api@1.2.3", "instance", "interface", "embedded:types/api@2.1.0",
    "0", "1", "f", "func", "function", "false", "0", "none", "0",
  ])
}

///|
test "adapt pinned WIT profile-map-float" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {type value=map<f32,u32>;f: func(x: value);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(resolution is Err(_))
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT profile-map-char" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {type value=map<char,u32>;f: func(x: value);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api@1.2.3",
    "instance", "interface", "example:types/api@1.2.3", "0", "2", "value", "type",
    "map", "scalar", "char", "scalar", "u32", "f", "func", "function", "false", "1",
    "x", "map", "scalar", "char", "scalar", "u32", "none", "instance", "interface",
    "", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api@1.2.3",
    "instance", "interface", "example:types/api@1.2.3", "0", "2", "value", "type",
    "map", "scalar", "char", "scalar", "u32", "f", "func", "function", "false", "1",
    "x", "map", "scalar", "char", "scalar", "u32", "none", "definitions", "1", "api",
    "type", "interface", "example:types/api@1.2.3", "0", "2", "value", "type", "map",
    "scalar", "char", "scalar", "u32", "f", "func", "function", "false", "1", "x",
    "map", "scalar", "char", "scalar", "u32", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api@1.2.3",
    "0", "2", "value", "type", "map", "scalar", "char", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "map", "scalar", "char", "scalar", "u32", "none",
    "1", "example:types/api@1.2.3", "instance", "interface", "example:types/api@1.2.3",
    "0", "2", "value", "type", "map", "scalar", "char", "scalar", "u32", "f", "func",
    "function", "false", "1", "x", "map", "scalar", "char", "scalar", "u32", "none",
  ])
}

///|
test "adapt pinned WIT profile-map-alias" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {type key=string;type value=map<key,u32>;f: func(x: value);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(resolution is Err(_))
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT profile-map-tuple" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {type key=tuple<string,u32>;type value=map<key,u32>;f: func(x: value);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(resolution is Err(_))
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT profile-error-context" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {f: func(x: error-context) -> error-context;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api@1.2.3",
    "instance", "interface", "example:types/api@1.2.3", "0", "1", "f", "func", "function",
    "false", "1", "x", "scalar", "error-context", "some", "scalar", "error-context",
    "instance", "interface", "", "0", "1", "api", "type", "world", "", "0", "0",
    "1", "example:types/api@1.2.3", "instance", "interface", "example:types/api@1.2.3",
    "0", "1", "f", "func", "function", "false", "1", "x", "scalar", "error-context",
    "some", "scalar", "error-context", "definitions", "1", "api", "type", "interface",
    "example:types/api@1.2.3", "0", "1", "f", "func", "function", "false", "1", "x",
    "scalar", "error-context", "some", "scalar", "error-context",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api@1.2.3",
    "0", "1", "f", "func", "function", "false", "1", "x", "scalar", "error-context",
    "some", "scalar", "error-context", "1", "example:types/api@1.2.3", "instance",
    "interface", "example:types/api@1.2.3", "0", "1", "f", "func", "function", "false",
    "1", "x", "scalar", "error-context", "some", "scalar", "error-context",
  ])
}

///|
test "adapt pinned WIT profile-getter-setter" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {resource handle {value: get() -> u32;value: set(value: u32);}}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(resolution is Err(_))
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT profile-unstable" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {@unstable(feature=extra) f: func();g: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api@1.2.3",
    "instance", "interface", "example:types/api@1.2.3", "0", "1", "g", "func", "function",
    "false", "0", "none", "instance", "interface", "", "0", "1", "api", "type", "world",
    "", "0", "0", "1", "example:types/api@1.2.3", "instance", "interface", "example:types/api@1.2.3",
    "0", "1", "g", "func", "function", "false", "0", "none", "definitions", "1",
    "api", "type", "interface", "example:types/api@1.2.3", "0", "1", "g", "func",
    "function", "false", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api@1.2.3",
    "0", "1", "g", "func", "function", "false", "0", "none", "1", "example:types/api@1.2.3",
    "instance", "interface", "example:types/api@1.2.3", "0", "1", "g", "func", "function",
    "false", "0", "none",
  ])
}

///|
test "adapt pinned WIT profile-since" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {@since(version=1.0.0) f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api@1.2.3",
    "instance", "interface", "example:types/api@1.2.3", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance", "interface", "", "0", "1", "api", "type", "world",
    "", "0", "0", "1", "example:types/api@1.2.3", "instance", "interface", "example:types/api@1.2.3",
    "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "1",
    "api", "type", "interface", "example:types/api@1.2.3", "0", "1", "f", "func",
    "function", "false", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api@1.2.3",
    "0", "1", "f", "func", "function", "false", "0", "none", "1", "example:types/api@1.2.3",
    "instance", "interface", "example:types/api@1.2.3", "0", "1", "f", "func", "function",
    "false", "0", "none",
  ])
}

///|
test "adapt pinned WIT profile-future-since" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {@since(version=9.0.0) f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(resolution is Err(_))
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT profile-external-id" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types@1.2.3;interface api {@id(\"custom:api/run\") f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(resolution is Err(_))
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
    },
  ])
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
test "adapt pinned WIT profile-external-name" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {@external-id(\"custom:api/run\") f: func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none", "instance", "interface", "", "0", "1", "api", "type", "world",
    "", "0", "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "1", "f", "func", "function", "false", "0", "none", "definitions", "1",
    "api", "type", "interface", "example:types/api", "0", "1", "f", "func", "function",
    "false", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "0", "1",
    "f", "func", "function", "false", "0", "none", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "1", "f", "func", "function", "false",
    "0", "none",
  ])
}

///|
test "adapt pinned WIT forward-world" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; world app {include base;export f:func();} world base {import g:func();}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "component", "world", "example:types/base", "0", "1", "g", "func", "function",
    "false", "0", "none", "0", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "1", "g", "func", "function",
    "false", "0", "none", "1", "f", "func", "function", "false", "0", "none", "instance",
    "interface", "", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "component", "world", "example:types/base", "0", "1", "g", "func", "function",
    "false", "0", "none", "0", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "1", "g", "func", "function",
    "false", "0", "none", "1", "f", "func", "function", "false", "0", "none", "definitions",
    "2", "base", "type", "world", "example:types/base", "0", "1", "g", "func", "function",
    "false", "0", "none", "0", "app", "type", "world", "example:types/app", "0",
    "1", "g", "func", "function", "false", "0", "none", "1", "f", "func", "function",
    "false", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "1",
    "g", "func", "function", "false", "0", "none", "1", "f", "func", "function",
    "false", "0", "none", "0",
  ])
}

///|
test "adapt pinned WIT interleaved-members" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {f:func();type count=u32;g:func(n:count);record item {x:u8}}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "4", "count", "type", "scalar",
    "u32", "item", "type", "record", "1", "x", "scalar", "u8", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "1", "n", "scalar", "u32",
    "none", "instance", "interface", "", "0", "1", "api", "type", "world", "", "0",
    "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "0", "4", "count", "type", "scalar", "u32", "item", "type", "record", "1", "x",
    "scalar", "u8", "f", "func", "function", "false", "0", "none", "g", "func", "function",
    "false", "1", "n", "scalar", "u32", "none", "definitions", "1", "api", "type",
    "interface", "example:types/api", "0", "4", "count", "type", "scalar", "u32",
    "item", "type", "record", "1", "x", "scalar", "u8", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "1", "n", "scalar", "u32",
    "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "0", "4",
    "count", "type", "scalar", "u32", "item", "type", "record", "1", "x", "scalar",
    "u8", "f", "func", "function", "false", "0", "none", "g", "func", "function",
    "false", "1", "n", "scalar", "u32", "none", "1", "example:types/api", "instance",
    "interface", "example:types/api", "0", "4", "count", "type", "scalar", "u32",
    "item", "type", "record", "1", "x", "scalar", "u8", "f", "func", "function",
    "false", "0", "none", "g", "func", "function", "false", "1", "n", "scalar", "u32",
    "none",
  ])
}

///|
test "adapt pinned WIT world-inline-uses" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface base {resource handle;} world app {import x:interface {use base.{handle};f:func(h:handle);} export y:interface {use base.{handle};g:func(h:handle);}}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "handle", "type", "resource",
    "0", "app", "type", "world", "", "0", "0", "1", "example:types/app", "component",
    "world", "example:types/app", "0", "2", "example:types/base", "instance", "interface",
    "example:types/base", "0", "1", "handle", "type", "resource", "1", "x", "instance",
    "interface", "", "1", "handle", "handle", "example:types/base", "2", "handle",
    "type", "resource", "1", "f", "func", "function", "false", "1", "h", "own", "1",
    "none", "1", "y", "instance", "interface", "", "1", "handle", "handle", "example:types/base",
    "2", "handle", "type", "resource", "1", "g", "func", "function", "false", "1",
    "h", "own", "1", "none", "instance", "interface", "", "0", "2", "base", "type",
    "world", "", "0", "0", "1", "example:types/base", "instance", "interface", "example:types/base",
    "0", "1", "handle", "type", "resource", "0", "app", "type", "world", "", "0",
    "0", "1", "example:types/app", "component", "world", "example:types/app", "0",
    "2", "example:types/base", "instance", "interface", "example:types/base", "0",
    "1", "handle", "type", "resource", "1", "x", "instance", "interface", "", "1",
    "handle", "handle", "example:types/base", "2", "handle", "type", "resource",
    "1", "f", "func", "function", "false", "1", "h", "own", "1", "none", "1", "y",
    "instance", "interface", "", "1", "handle", "handle", "example:types/base", "2",
    "handle", "type", "resource", "1", "g", "func", "function", "false", "1", "h",
    "own", "1", "none", "definitions", "2", "base", "type", "interface", "example:types/base",
    "0", "1", "handle", "type", "resource", "0", "app", "type", "world", "example:types/app",
    "0", "2", "example:types/base", "instance", "interface", "example:types/base",
    "0", "1", "handle", "type", "resource", "1", "x", "instance", "interface", "",
    "1", "handle", "handle", "example:types/base", "2", "handle", "type", "resource",
    "1", "f", "func", "function", "false", "1", "h", "own", "1", "none", "1", "y",
    "instance", "interface", "", "1", "handle", "handle", "example:types/base", "2",
    "handle", "type", "resource", "1", "g", "func", "function", "false", "1", "h",
    "own", "1", "none",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "2",
    "example:types/base", "instance", "interface", "example:types/base", "0", "1",
    "handle", "type", "resource", "0", "x", "instance", "interface", "", "1", "handle",
    "handle", "example:types/base", "2", "handle", "type", "resource", "0", "f",
    "func", "function", "false", "1", "h", "own", "0", "none", "1", "y", "instance",
    "interface", "", "1", "handle", "handle", "example:types/base", "2", "handle",
    "type", "resource", "0", "g", "func", "function", "false", "1", "h", "own", "0",
    "none", "0",
  ])
}

///|
test "adapt pinned WIT diamond-use" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface base {resource handle;} interface left {use base.{handle};} interface right {use base.{handle};} interface api {use left.{handle as first};use right.{handle as second};f:func(a:first,b:second);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "4", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "handle", "type", "resource",
    "0", "left", "type", "world", "", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "1",
    "1", "example:types/left", "instance", "interface", "example:types/left", "1",
    "handle", "handle", "example:types/base", "1", "handle", "type", "resource",
    "1", "right", "type", "world", "", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "2",
    "1", "example:types/right", "instance", "interface", "example:types/right", "1",
    "handle", "handle", "example:types/base", "1", "handle", "type", "resource",
    "2", "api", "type", "world", "", "0", "3", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "3",
    "example:types/left", "instance", "interface", "example:types/left", "1", "handle",
    "handle", "example:types/base", "1", "handle", "type", "resource", "3", "example:types/right",
    "instance", "interface", "example:types/right", "1", "handle", "handle", "example:types/base",
    "1", "handle", "type", "resource", "3", "1", "example:types/api", "instance",
    "interface", "example:types/api", "2", "first", "handle", "example:types/base",
    "second", "handle", "example:types/base", "3", "first", "type", "resource", "3",
    "second", "type", "resource", "3", "f", "func", "function", "false", "2", "a",
    "own", "3", "b", "own", "3", "none", "instance", "interface", "", "0", "4", "base",
    "type", "world", "", "0", "0", "1", "example:types/base", "instance", "interface",
    "example:types/base", "0", "1", "handle", "type", "resource", "0", "left", "type",
    "world", "", "0", "1", "example:types/base", "instance", "interface", "example:types/base",
    "0", "1", "handle", "type", "resource", "1", "1", "example:types/left", "instance",
    "interface", "example:types/left", "1", "handle", "handle", "example:types/base",
    "1", "handle", "type", "resource", "1", "right", "type", "world", "", "0", "1",
    "example:types/base", "instance", "interface", "example:types/base", "0", "1",
    "handle", "type", "resource", "2", "1", "example:types/right", "instance", "interface",
    "example:types/right", "1", "handle", "handle", "example:types/base", "1", "handle",
    "type", "resource", "2", "api", "type", "world", "", "0", "3", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "handle", "type", "resource",
    "3", "example:types/left", "instance", "interface", "example:types/left", "1",
    "handle", "handle", "example:types/base", "1", "handle", "type", "resource",
    "3", "example:types/right", "instance", "interface", "example:types/right", "1",
    "handle", "handle", "example:types/base", "1", "handle", "type", "resource",
    "3", "1", "example:types/api", "instance", "interface", "example:types/api",
    "2", "first", "handle", "example:types/base", "second", "handle", "example:types/base",
    "3", "first", "type", "resource", "3", "second", "type", "resource", "3", "f",
    "func", "function", "false", "2", "a", "own", "3", "b", "own", "3", "none", "definitions",
    "4", "base", "type", "interface", "example:types/base", "0", "1", "handle", "type",
    "resource", "0", "left", "type", "interface", "example:types/left", "1", "handle",
    "handle", "example:types/base", "1", "handle", "type", "resource", "1", "right",
    "type", "interface", "example:types/right", "1", "handle", "handle", "example:types/base",
    "1", "handle", "type", "resource", "2", "api", "type", "interface", "example:types/api",
    "2", "first", "handle", "example:types/base", "second", "handle", "example:types/base",
    "3", "first", "type", "resource", "3", "second", "type", "resource", "3", "f",
    "func", "function", "false", "2", "a", "own", "3", "b", "own", "3", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "2", "first",
    "handle", "example:types/base", "second", "handle", "example:types/base", "3",
    "first", "type", "resource", "0", "second", "type", "resource", "0", "f", "func",
    "function", "false", "2", "a", "own", "0", "b", "own", "0", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "2", "first", "handle", "example:types/base",
    "second", "handle", "example:types/base", "3", "first", "type", "resource", "0",
    "second", "type", "resource", "0", "f", "func", "function", "false", "2", "a",
    "own", "0", "b", "own", "0", "none",
  ])
}

///|
test "adapt pinned WIT world-repeated-instance" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface api {resource handle;} world app {import a:api;import b:api;export c:api;export d:api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "2", "api", "type", "world", "", "0", "0", "1", "example:types/api",
    "instance", "interface", "example:types/api", "0", "1", "handle", "type", "resource",
    "0", "app", "type", "world", "", "0", "0", "1", "example:types/app", "component",
    "world", "example:types/app", "0", "2", "a", "instance", "interface", "example:types/api",
    "0", "1", "handle", "type", "resource", "1", "b", "instance", "interface", "example:types/api",
    "0", "1", "handle", "type", "resource", "2", "2", "c", "instance", "interface",
    "example:types/api", "0", "1", "handle", "type", "resource", "3", "d", "instance",
    "interface", "example:types/api", "0", "1", "handle", "type", "resource", "4",
    "instance", "interface", "", "0", "2", "api", "type", "world", "", "0", "0",
    "1", "example:types/api", "instance", "interface", "example:types/api", "0",
    "1", "handle", "type", "resource", "0", "app", "type", "world", "", "0", "0",
    "1", "example:types/app", "component", "world", "example:types/app", "0", "2",
    "a", "instance", "interface", "example:types/api", "0", "1", "handle", "type",
    "resource", "1", "b", "instance", "interface", "example:types/api", "0", "1",
    "handle", "type", "resource", "2", "2", "c", "instance", "interface", "example:types/api",
    "0", "1", "handle", "type", "resource", "3", "d", "instance", "interface", "example:types/api",
    "0", "1", "handle", "type", "resource", "4", "definitions", "2", "api", "type",
    "interface", "example:types/api", "0", "1", "handle", "type", "resource", "0",
    "app", "type", "world", "example:types/app", "0", "2", "a", "instance", "interface",
    "example:types/api", "0", "1", "handle", "type", "resource", "1", "b", "instance",
    "interface", "example:types/api", "0", "1", "handle", "type", "resource", "2",
    "2", "c", "instance", "interface", "example:types/api", "0", "1", "handle", "type",
    "resource", "3", "d", "instance", "interface", "example:types/api", "0", "1",
    "handle", "type", "resource", "4",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "2",
    "a", "instance", "interface", "example:types/api", "0", "1", "handle", "type",
    "resource", "0", "b", "instance", "interface", "example:types/api", "0", "1",
    "handle", "type", "resource", "1", "2", "c", "instance", "interface", "example:types/api",
    "0", "1", "handle", "type", "resource", "2", "d", "instance", "interface", "example:types/api",
    "0", "1", "handle", "type", "resource", "3", "0",
  ])
}

///|
test "adapt pinned WIT world-export-capture" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; interface base {resource handle;} interface api {use base.{handle};f:func(h:handle);} world app {import base;export api;}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "3", "base", "type", "world", "", "0", "0", "1", "example:types/base",
    "instance", "interface", "example:types/base", "0", "1", "handle", "type", "resource",
    "0", "api", "type", "world", "", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "1",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:types/base", "2", "handle", "type", "resource",
    "1", "f", "func", "function", "false", "1", "h", "own", "1", "none", "app", "type",
    "world", "", "0", "0", "1", "example:types/app", "component", "world", "example:types/app",
    "0", "1", "example:types/base", "instance", "interface", "example:types/base",
    "0", "1", "handle", "type", "resource", "2", "1", "example:types/api", "instance",
    "interface", "example:types/api", "1", "handle", "handle", "example:types/base",
    "2", "handle", "type", "resource", "2", "f", "func", "function", "false", "1",
    "h", "own", "2", "none", "instance", "interface", "", "0", "3", "base", "type",
    "world", "", "0", "0", "1", "example:types/base", "instance", "interface", "example:types/base",
    "0", "1", "handle", "type", "resource", "0", "api", "type", "world", "", "0",
    "1", "example:types/base", "instance", "interface", "example:types/base", "0",
    "1", "handle", "type", "resource", "1", "1", "example:types/api", "instance",
    "interface", "example:types/api", "1", "handle", "handle", "example:types/base",
    "2", "handle", "type", "resource", "1", "f", "func", "function", "false", "1",
    "h", "own", "1", "none", "app", "type", "world", "", "0", "0", "1", "example:types/app",
    "component", "world", "example:types/app", "0", "1", "example:types/base", "instance",
    "interface", "example:types/base", "0", "1", "handle", "type", "resource", "2",
    "1", "example:types/api", "instance", "interface", "example:types/api", "1",
    "handle", "handle", "example:types/base", "2", "handle", "type", "resource",
    "2", "f", "func", "function", "false", "1", "h", "own", "2", "none", "definitions",
    "3", "base", "type", "interface", "example:types/base", "0", "1", "handle", "type",
    "resource", "0", "api", "type", "interface", "example:types/api", "1", "handle",
    "handle", "example:types/base", "2", "handle", "type", "resource", "1", "f",
    "func", "function", "false", "1", "h", "own", "1", "none", "app", "type", "world",
    "example:types/app", "0", "1", "example:types/base", "instance", "interface",
    "example:types/base", "0", "1", "handle", "type", "resource", "2", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "handle", "handle", "example:types/base",
    "2", "handle", "type", "resource", "2", "f", "func", "function", "false", "1",
    "h", "own", "2", "none",
  ])
  let source = "package test:app;import i: lookup:types/app;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/app", "component", "world", "example:types/app", "0", "1",
    "example:types/base", "instance", "interface", "example:types/base", "0", "1",
    "handle", "type", "resource", "0", "1", "example:types/api", "instance", "interface",
    "example:types/api", "1", "handle", "handle", "example:types/base", "2", "handle",
    "type", "resource", "0", "f", "func", "function", "false", "1", "h", "own", "0",
    "none", "0",
  ])
}

///|
test "adapt pinned WIT nested-package" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types; package example:dep {interface base {type count=u32;}} interface api {use example:dep/base.{count};f:func(n:count);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = []
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "1", "example:dep/base",
    "instance", "interface", "example:dep/base", "0", "1", "count", "type", "scalar",
    "u32", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "count", "count", "example:dep/base", "2", "count", "type", "scalar", "u32",
    "f", "func", "function", "false", "1", "n", "scalar", "u32", "none", "instance",
    "interface", "", "0", "1", "api", "type", "world", "", "0", "1", "example:dep/base",
    "instance", "interface", "example:dep/base", "0", "1", "count", "type", "scalar",
    "u32", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "count", "count", "example:dep/base", "2", "count", "type", "scalar", "u32",
    "f", "func", "function", "false", "1", "n", "scalar", "u32", "none", "definitions",
    "1", "api", "type", "interface", "example:types/api", "1", "count", "count",
    "example:dep/base", "2", "count", "type", "scalar", "u32", "f", "func", "function",
    "false", "1", "n", "scalar", "u32", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "count",
    "count", "example:dep/base", "2", "count", "type", "scalar", "u32", "f", "func",
    "function", "false", "1", "n", "scalar", "u32", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "count", "count", "example:dep/base",
    "2", "count", "type", "scalar", "u32", "f", "func", "function", "false", "1",
    "n", "scalar", "u32", "none",
  ])
}

///|
test "adapt pinned WIT bundle-deep" {
  let root : @wit_verifier.SourcePackage = {
    documents: [
      wit_document(
        "root.wit", "package example:types;interface api {use example:middle/types.{handle};f:func(h:handle);}",
      ),
    ],
  }
  let dependencies : ReadOnlyArray[@wit_verifier.SourcePackage] = [
    {
      documents: [
        wit_document(
          "deps/middle/types.wit", "package example:middle;interface types {use example:base/types@1.0.0.{handle};}",
        ),
      ],
    },
    {
      documents: [
        wit_document(
          "deps/base/types.wit", "package example:base@1.0.0;interface types {resource handle;}",
        ),
      ],
    },
  ]
  let resolution = @wit_verifier.resolve(root, dependencies~)
  assert_true(
    resolution is Ok(_),
    msg=match resolution {
      Ok(_) => "resolved"
      Err(errors) => errors[0].render()
    },
  )
  let adapted = @verifier.adapt_wit_package(resolution.unwrap())
  assert_true(
    adapted is Ok(_),
    msg=match adapted {
      Ok(_) => "adapted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(wit_projection(adapted.unwrap()), [
    "world", "", "0", "0", "1", "api", "type", "world", "", "0", "2", "example:base/types@1.0.0",
    "instance", "interface", "example:base/types@1.0.0", "0", "1", "handle", "type",
    "resource", "0", "example:middle/types", "instance", "interface", "example:middle/types",
    "1", "handle", "handle", "example:base/types@1.0.0", "1", "handle", "type", "resource",
    "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "handle", "handle", "example:base/types@1.0.0", "2", "handle", "type", "resource",
    "0", "f", "func", "function", "false", "1", "h", "own", "0", "none", "instance",
    "interface", "", "0", "1", "api", "type", "world", "", "0", "2", "example:base/types@1.0.0",
    "instance", "interface", "example:base/types@1.0.0", "0", "1", "handle", "type",
    "resource", "0", "example:middle/types", "instance", "interface", "example:middle/types",
    "1", "handle", "handle", "example:base/types@1.0.0", "1", "handle", "type", "resource",
    "0", "1", "example:types/api", "instance", "interface", "example:types/api",
    "1", "handle", "handle", "example:base/types@1.0.0", "2", "handle", "type", "resource",
    "0", "f", "func", "function", "false", "1", "h", "own", "0", "none", "definitions",
    "1", "api", "type", "interface", "example:types/api", "1", "handle", "handle",
    "example:base/types@1.0.0", "2", "handle", "type", "resource", "0", "f", "func",
    "function", "false", "1", "h", "own", "0", "none",
  ])
  let source = "package test:app;import i: lookup:types/api;export i;"
  let result = @verifier.verify(@parser.parse(source), source~, wit_dependencies=[
    {
      name: "lookup:types",
      version: None,
      source: "provider.wit",
      root: @wit_verifier.PackageInput::Source(root),
      dependencies: dependencies.map(dep => {
        @wit_verifier.PackageInput::Source(dep)
      }),
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
  assert_eq(source_projection(result.unwrap()), [
    "1", "lookup:types/api", "instance", "interface", "example:types/api", "1", "handle",
    "handle", "example:base/types@1.0.0", "2", "handle", "type", "resource", "0",
    "f", "func", "function", "false", "1", "h", "own", "0", "none", "1", "example:types/api",
    "instance", "interface", "example:types/api", "1", "handle", "handle", "example:base/types@1.0.0",
    "2", "handle", "type", "resource", "0", "f", "func", "function", "false", "1",
    "h", "own", "0", "none",
  ])
}
