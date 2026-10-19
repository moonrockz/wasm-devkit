///|
fn options(args : ArrayView[String]) -> @cli.Options raise {
  guard @cli.arguments(args) is Ok(Run(options)) else {
    fail("expected runnable arguments")
  }
  options
}

///|
test "language inference stdin explicit paths and option validation" {
  assert_eq(options(["parse", "a.wit"]).language, Wit)
  assert_eq(options(["ast", "a.wac"]).language, Wac)
  assert_eq(options(["parse", "--language", "wit"]).path, "-")
  assert_eq(
    options(["parse", "--language", "wac", "--", "--file"]).path,
    "--file",
  )
  assert_true(@cli.arguments([]) is Ok(Help))
  assert_true(@cli.arguments(["--version"]) is Ok(Version))
  for
    args in [
      ["parse"],
      ["parse", "a.txt"],
      ["parse", "a.wit", "b.wit"],
      ["parse", "a.wit", "--write"],
      ["format", "a.wit", "--write", "--check"],
      ["format", "--language", "wit", "--write"],
      ["parse", "--language", "other"],
      ["format", "a.wit", "--indent", "9"],
      ["format", "a.wit", "--indent"],
      ["parse", "a.wit", "--unknown"],
      ["unknown"],
    ] {
    assert_true(@cli.arguments(args[:]) is Err(_))
  }
}

///|
test "WIT and WAC parsing diagnostics use source coordinates and useful exit codes" {
  let good = @cli.execute(options(["parse", "a.wit"]), "interface i {}")
  assert_eq(good.exit_code, 0)
  assert_eq(good.stdout, "a.wit: valid wit\n")
  let wac = @cli.execute(
    options(["parse", "a.wac"]),
    "package a:b; let x = host;",
  )
  assert_eq(wac.exit_code, 0)
  let bad = @cli.execute(options(["parse", "--language", "wit"]), "\n?")
  assert_eq(bad.exit_code, 1)
  assert_true(bad.stderr.contains("<stdin>:2:1: error WIT-L001"))
  assert_eq(bad.stdout, "")
}

///|
test "inspection preserves recovered AST CST and token data" {
  for command in ["ast", "cst", "tokens"] {
    for language in ["wit", "wac"] {
      let result = @cli.execute(
        options([command, "--language", language]),
        "???; //raw",
      )
      assert_eq(result.exit_code, 1)
      assert_true(result.stderr.contains("error"))
      assert_false(result.stdout.is_empty())
      if command == "cst" || command == "tokens" {
        assert_true(result.stdout.contains("//raw"))
      }
    }
  }
}

///|
test "format check write and stdout modes leave source decisions to the executable" {
  let source = "package a:b;let x=host; //tail"
  let display = @cli.execute(options(["format", "a.wac"]), source)
  assert_eq(display.exit_code, 0)
  assert_true(display.stdout.contains("//tail"))
  let check = @cli.execute(options(["format", "a.wac", "--check"]), source)
  assert_eq(check.exit_code, 1)
  assert_eq(check.stdout, "")
  assert_true(check.write_text is None)
  let clean = @cli.execute(
    options(["format", "a.wac", "--check"]),
    display.stdout,
  )
  assert_eq(clean.exit_code, 0)
  let write = @cli.execute(options(["format", "a.wac", "--write"]), source)
  assert_eq(write.write_text, Some(display.stdout))
  assert_eq(write.stdout, "")
  let bad = @cli.execute(
    options(["format", "a.wac", "--write"]),
    "package a:b;let x=",
  )
  assert_eq(bad.exit_code, 1)
  assert_true(bad.write_text is None)
}

///|
test "printing rejects original syntax errors and feature switches are explicit" {
  assert_eq(
    @cli.execute(options(["print", "a.wit"]), "interface i {type t = u8}").exit_code,
    1,
  )
  let source = "package a:b; type f = func() -> (a: u8);"
  assert_eq(@cli.execute(options(["print", "a.wac"]), source).exit_code, 1)
  let result = @cli.execute(
    options(["print", "a.wac", "--all-features"]),
    source,
  )
  assert_eq(result.exit_code, 0)
  assert_true(result.stdout.contains("(a: u8)"))
}

///|
test "verify distinguishes syntax and semantics without changing check" {
  for
    (language, good, bad) in [
      (
        "wit", "package example:app; interface api { type t = u8; }", "package example:app; interface api { type t = missing; }",
      ),
      (
        "wac", "package a:b; import f: func(); let x = f; export x as \"x\";", "package a:b; let x = f; import f: func();",
      ),
    ] {
    let verify = options(["verify", "--language", language, "--base", "."])
    let good = @cli.execute(verify, good)
    assert_eq(good.exit_code, 0)
    assert_true(good.stdout.contains("verified"))
    assert_true(good.write_text is None)
    assert_eq(
      @cli.execute(options(["check", "--language", language]), bad).exit_code,
      0,
    )
    let bad = @cli.execute(verify, bad)
    assert_eq(bad.exit_code, 1)
    assert_true(bad.stderr.contains("<stdin>:1:"))
    assert_true(bad.stderr.contains("-S005"))
    assert_eq(bad.stdout, "")
  }
  assert_eq(options(["verify", "a.wit"]).language, Wit)
  assert_eq(options(["verify", "a.wac"]).language, Wac)
  assert_true(@cli.arguments(["verify", "a.wit", "--write"]) is Err(_))
  assert_eq(@cli.execute(options(["verify", "a.wit"]), "?").exit_code, 1)
}

///|
test "dependency arguments require verify and stdin supplies a resolution base" {
  let parsed = options([
    "verify", "wit", "--language", "wit", "--base", "work", "--deps-dir", "deps",
    "--dep", "example:dep@1.0.0=dep.wit",
  ])
  assert_eq(parsed.base, Some("work"))
  assert_eq(parsed.deps_dir, Some("deps"))
  assert_eq(parsed.dependencies.length(), 1)
  assert_eq(parsed.dependencies[0].name, "example:dep@1.0.0")
  assert_eq(parsed.dependencies[0].path, "dep.wit")
  for
    args in [
      ["verify", "--language", "wit"],
      ["verify", "a.wit", "--dep", "broken"],
      ["verify", "a.wit", "--dep", "=path"],
      ["verify", "a.wit", "--dep", "name="],
      ["verify", "a.wit", "--deps-dir"],
      ["parse", "a.wit", "--base", "."],
      ["format", "a.wit", "--dep", "a:b=path"],
    ] {
    assert_true(@cli.arguments(args[:]) is Err(_))
  }
}

///|
test "WIT semantic feature flags are explicit and independent from grammar switches" {
  let source = "package example:app;interface api{@unstable(feature=foo)resource r;f:func(x:r);}"
  for args in [["verify", "a.wit"], ["verify", "a.wit", "--all-features"]] {
    let output = @cli.execute(options(args[:]), source)
    assert_eq(output.exit_code, 1)
    assert_true(output.stderr.contains("WIT-S013"))
  }
  for
    args in [
      ["verify", "a.wit", "--semantic-feature", "foo"],
      [
        "verify", "a.wit", "--semantic-feature", "bar", "--semantic-feature", "foo",
      ],
      ["verify", "a.wit", "--all-semantic-features"],
    ] {
    let output = @cli.execute(options(args[:]), source)
    assert_eq(output.exit_code, 0)
    assert_true(output.write_text is None)
  }
  for
    args in [
      ["verify", "a.wit", "--semantic-feature"],
      ["verify", "a.wit", "--semantic-feature", ""],
      ["verify", "a.wit", "--semantic-feature", "--json"],
      ["verify", "a.wac", "--semantic-feature", "foo"],
      ["parse", "a.wit", "--all-semantic-features"],
    ] {
    assert_true(@cli.arguments(args[:]) is Err(_))
  }
}

///|
test "world selection is explicit and summaries contain no arena indices" {
  let source = "package example:app; interface api {} world first {import api;} world second {}"
  let selected = @cli.execute(
    options(["verify", "a.wit", "--world", "first", "--json"]),
    source,
  )
  assert_eq(selected.exit_code, 0)
  assert_true(selected.stdout.contains("example:app/api"))
  assert_false(selected.stdout.contains("interface-"))
  assert_eq(
    @cli.execute(options(["verify", "a.wit", "--world", "missing"]), source).exit_code,
    1,
  )
  let ambiguous = @cli.execute(
    options(["verify", "a.wit", "--world", "example:app"]),
    source,
  )
  assert_eq(ambiguous.exit_code, 1)
  assert_true(ambiguous.stderr.contains("WIT-S010"))
  assert_eq(@cli.execute(options(["verify", "a.wit"]), source).exit_code, 0)
  for
    args in [
      ["verify", "a.wit", "--world"],
      ["verify", "a.wac", "--world", "app"],
      ["parse", "a.wit", "--json"],
    ] {
    assert_true(@cli.arguments(args[:]) is Err(_))
  }
}
