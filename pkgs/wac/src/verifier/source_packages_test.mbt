///|
test "source package dependencies resolve in dependency order and retain public models" {
  let packages : ReadOnlyArray[@verifier.SourcePackage] = [
    {
      name: "test:outer",
      version: None,
      source: "outer.wac",
      text: "package test:outer; let i = new test:inner {}; export i as \"inner\";",
    },
    {
      name: "test:inner",
      version: None,
      source: "inner.wac",
      text: "package test:inner;",
    },
  ]
  let resolved = @verifier.resolve_composition_packages(packages).unwrap()
  assert_eq(resolved.length(), 2)
  assert_eq(resolved[0].name, "test:inner")
  let source = "package test:root; let i = new test:outer {}; export i as \"out\";"
  assert_true(
    @verifier.verify(@parser.parse(source), source~, compositions=resolved)
    is Ok(_),
  )
}

///|
test "source package dependency cycles and lookup collisions fail explicitly" {
  let a : @verifier.SourcePackage = {
    name: "test:a",
    version: None,
    source: "a.wac",
    text: "package test:a; let i = new test:b {};",
  }
  let b : @verifier.SourcePackage = {
    name: "test:b",
    version: None,
    source: "b.wac",
    text: "package test:b; let i = new test:a {};",
  }
  let cycle = @verifier.resolve_composition_packages([a, b]).unwrap_err()
  assert_eq(cycle[0].code, "WAC-P007")
  assert_eq(
    @verifier.resolve_composition_packages([a, a]).unwrap_err()[0].code,
    "WAC-P002",
  )
}

///|
test "source package resolution retains the caller grammar profile" {
  let source : @verifier.SourcePackage = {
    name: "test:dependency",
    version: None,
    source: "dependency.wac",
    text: "package test:dependency; import f: func() -> (x: u8);",
  }
  let default_errors = @verifier.resolve_composition_packages([source]).unwrap_err()
  assert_eq(default_errors[0].code, "WAC-P005")
  let extended_errors = @verifier.resolve_composition_packages(
    [source],
    features=@parser.Features::all(),
  ).unwrap_err()
  // The selected grammar reaches semantic checking, which still explicitly
  // rejects named results under the pinned semantic profile.
  assert_eq(extended_errors[0].code, "WAC-S003")
}
