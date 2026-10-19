///|
fn document(id : String, text : String) -> @verifier.Document {
  @verifier.Document::from_parse(
    id,
    text,
    @parser.parse(text, features=@parser.Features::reference()),
  )
}

///|
fn package_input(id : String, text : String) -> @verifier.SourcePackage {
  { documents: [document(id, text)], }
}

///|
test "resolve a versioned WIT dependency and retain its runtime interface import" {
  let root = package_input(
    "wit/world.wit", "package example:app@1.0.0; world app { import example:dep/api@1.0.0; }",
  )
  let dep = package_input(
    "wit/deps/dep/api.wit", "package example:dep@1.0.0; interface api { greet: func(name: string) -> string; }",
  )
  let model = @verifier.resolve(root, dependencies=[dep]).unwrap()
  assert_eq(model.root().name, "app")
  assert_eq(model.identities().length(), 2)
  let worlds = model.worlds()
  assert_eq(worlds.length(), 1)
  assert_eq(worlds[0].imports.length(), 1)
  assert_eq(worlds[0].imports[0].name, "example:dep/api@1.0.0")
  assert_true(worlds[0].imports[0].kind is Interface(_))
  assert_eq(model.sources()[0].ast, root.documents[0].ast)
  assert_true(
    @verifier.resolve(root) is Err(errors) && errors[0].code == "WIT-S009",
  )
}

///|
test "same-package files share interfaces and use aliases retain dependency provenance" {
  let root : @verifier.SourcePackage = {
    documents: [
      document(
        "b.wit", "interface consumer { use api.{item as local}; type result-item = list<local>; }",
      ),
      document(
        "a.wit", "package example:app; interface api { record item { value: u8 } }",
      ),
    ],
  }
  let model = @verifier.resolve(root).unwrap()
  assert_eq(model.sources().length(), 2)
  let imported = model
    .declarations()
    .filter(b => b.name == "local" && b.node != b.target)
  assert_eq(imported.length(), 2)
  let reference = imported[0]
  assert_eq(model.origin(reference.node).unwrap().location.source, "b.wit")
  assert_eq(model.origin(reference.target).unwrap().location.source, "a.wit")
  let reverse : @verifier.SourcePackage = {
    documents: [root.documents[1], root.documents[0]],
  }
  let again = @verifier.resolve(reverse).unwrap()
  assert_eq(model.types(), again.types())
  assert_eq(model.declarations(), again.declarations())
}

///|
test "transitive diamond imports resolve to one original type identity" {
  let root = package_input(
    "root.wit", "package example:root; interface api { use example:left/api.{item as left}; use example:right/api.{item as right}; type both = tuple<left, right>; }",
  )
  let left = package_input(
    "left.wit", "package example:left; interface api { use example:base/api.{item}; }",
  )
  let right = package_input(
    "right.wit", "package example:right; interface api { use example:base/api.{item}; }",
  )
  let base = package_input(
    "base.wit", "package example:base; interface api { resource item; }",
  )
  let model = @verifier.resolve(root, dependencies=[right, base, left]).unwrap()
  assert_eq(model.types().filter(t => t.kind is Resource).length(), 1)
  assert_eq(model.identities().length(), 4)
  let again = @verifier.resolve(root, dependencies=[left, right, base]).unwrap()
  assert_eq(model.types(), again.types())
}

///|
test "missing interfaces types versions and wrong kinds fail with original file labels" {
  let dep = package_input(
    "dep.wit", "package example:dep@1.0.0; interface api { type item = u8; run: func(); } world other {}",
  )
  for
    source in [
      "package example:app; world app { import example:dep/missing@1.0.0; }", "package example:app; world app { import example:dep/api@2.0.0; }",
      "package example:app; interface api { use example:dep/api@1.0.0.{missing}; }",
      "package example:app; interface api { use example:dep/api@1.0.0.{run}; }",
      "package example:app; interface api { use example:dep/other@1.0.0.{item}; }",
    ] {
    let root = package_input("root.wit", source)
    guard @verifier.resolve(root, dependencies=[dep]) is Err(errors) else {
      fail("invalid dependency accepted")
    }
    assert_eq(errors[0].primary.location.source, "root.wit")
  }
  let root = package_input(
    "root.wit", "package example:app; interface api { use example:dep/api@1.0.0.{run}; }",
  )
  guard @verifier.resolve(root, dependencies=[dep]) is Err(errors) else {
    fail("non-type selector accepted")
  }
  assert_eq(errors[0].related[0].location.source, "dep.wit")
}

///|
test "package and interface dependency cycles fail without requiring type cycles" {
  let root = package_input(
    "root.wit", "package example:root; interface a { type first = u8; use b.{second}; } interface b { type second = u8; use a.{first}; }",
  )
  assert_true(
    @verifier.resolve(root) is Err(errors) &&
    errors.any(d => d.code == "WIT-S006"),
  )
  let self = package_input(
    "self.wit", "package example:root; interface a { type first = u8; } interface b { use example:root/a.{first}; }",
  )
  assert_true(
    @verifier.resolve(self) is Err(errors) &&
    errors.any(d => d.message.contains("package")),
  )
  let root = package_input(
    "root.wit", "package example:root; interface api { use example:dep/api.{item}; type mine = u8; }",
  )
  let dep = package_input(
    "dep.wit", "package example:dep; interface api { use example:root/api.{mine}; type item = u8; }",
  )
  assert_true(@verifier.resolve(root, dependencies=[dep]) is Err(_))
}

///|
test "source identity and conflicting package metadata cannot produce a model" {
  let a = document("a.wit", "package example:a; interface api {}")
  let b = document("b.wit", "package example:b; interface other {}")
  assert_true(@verifier.resolve({ documents: [a, b], }) is Err(_))
  assert_true(@verifier.resolve({ documents: [a, a], }) is Err(_))
  assert_true(@verifier.resolve({ documents: [], }) is Err(_))
  let root : @verifier.SourcePackage = { documents: [a], }
  assert_true(@verifier.resolve(root, dependencies=[root]) is Err(_))
  let malformed : @verifier.Document = {
    id: "bad.wit",
    text: "",
    ast: { nodes: [], },
    diagnostics: [],
  }
  assert_true(@verifier.resolve({ documents: [malformed], }) is Err(_))
}

///|
test "transitive failures carry a source-qualified dependency chain" {
  let root = package_input(
    "root.wit", "package example:root; interface api { use example:dep/api.{item}; }",
  )
  let dep = package_input(
    "dep.wit", "// 😀\npackage example:dep; interface api { type item = missing; }",
  )
  guard @verifier.resolve(root, dependencies=[dep]) is Err(errors) else {
    fail("invalid dependency accepted")
  }
  assert_eq(errors[0].primary.location.source, "dep.wit")
  assert_true(
    errors[0].related.any(label => {
      label.location.source == "root.wit" &&
      label.message.contains("required by")
    }),
  )
}

///|
test "version qualifiers select exact package identities without fallback" {
  let root = package_input(
    "root.wit", "package example:root; interface api { use example:dep/api@2.0.0.{item}; }",
  )
  let first = package_input(
    "first.wit", "package example:dep@1.0.0; interface api { type item = u8; }",
  )
  let second = package_input(
    "second.wit", "package example:dep@2.0.0; interface api { type item = string; }",
  )
  let model = @verifier.resolve(root, dependencies=[first, second]).unwrap()
  let imported = model
    .declarations()
    .filter(b => b.name == "item" && b.node != b.target)
  assert_eq(
    model.origin(imported[0].target).unwrap().location.source,
    "second.wit",
  )
  let ambiguous = package_input(
    "root.wit", "package example:root; interface api { use example:dep/api.{item}; }",
  )
  assert_true(
    @verifier.resolve(ambiguous, dependencies=[first, second]) is Err(errors) &&
    errors[0].code == "WIT-S009",
  )
  assert_true(@verifier.resolve(ambiguous, dependencies=[second]) is Err(_))
}

///|
test "deep source package chains use explicit work stacks" {
  let root = package_input(
    "root.wit", "package example:root; interface api { use example:p0/api.{item}; }",
  )
  let dependencies : Array[@verifier.SourcePackage] = []
  for i in 0..<2000 {
    let body = if i == 1999 {
      "type item = u8;"
    } else {
      "use example:p\{i+1}/api.{item};"
    }
    dependencies.push(
      package_input(
        "dep\{i}.wit",
        "package example:p\{i}; interface api { " + body + " }",
      ),
    )
  }
  let model = @verifier.resolve(
    root,
    dependencies=ReadOnlyArray::from_array(dependencies),
  ).unwrap()
  assert_eq(model.identities().length(), 2001)
  assert_true(model.types().length() >= 2001)
}

///|
test "invalid dependency discovery permutations yield identical diagnostics" {
  let root = package_input("root.wit", "package example:root; interface api {}")
  let first = package_input(
    "first.wit", "package example:first; interface api { type item = missing; }",
  )
  let second = package_input(
    "second.wit", "package example:second; interface api { type item = missing; }",
  )
  guard @verifier.resolve(root, dependencies=[first, second]) is Err(a) else {
    fail("invalid dependency accepted")
  }
  guard @verifier.resolve(root, dependencies=[second, first]) is Err(b) else {
    fail("invalid dependency accepted")
  }
  assert_eq(a, b)
}

///|
test "dependency syntax failures retain the loading chain without producing a model" {
  let root = package_input(
    "root.wit", "package example:root; interface api { use example:dep/api.{item}; }",
  )
  let dep = package_input(
    "dep.wit", "package example:dep; interface api { type item = ; }",
  )
  guard @verifier.resolve(root, dependencies=[dep]) is Err(errors) else {
    fail("syntax error accepted")
  }
  assert_true(
    errors.any(d => {
      d.primary.location.source == "dep.wit" &&
      d.related.any(label => label.location.source == "root.wit")
    }),
  )
}
