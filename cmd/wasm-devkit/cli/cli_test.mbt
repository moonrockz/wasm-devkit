///|
fn options(args : ArrayView[String]) -> @cli.Options raise {
  guard @cli.arguments(args) is Ok(Run(options)) else {
    fail("expected runnable arguments")
  }
  options
}

///|
test "binary labels are never interpreted through a textual line table" {
  let primary = @wit_verifier.Diagnostic::from_binary({
    source: "dep.wasm",
    offset: Some(3),
    code: "WIT-B003",
    message: "invalid metadata",
  })
  let diagnostic = {
    ..primary,
    related: [
      {
        location: @wit_verifier.Location::text("api.wit", { start: 3, end: 4, }),
        message: "used here",
      },
    ],
  }
  let output = @cli.render_wit_diagnostics([diagnostic], [
    ("dep.wasm", "😀\na"),
    ("api.wit", "😀\na"),
  ])
  assert_true(output.contains("dep.wasm:[byte 3]: error WIT-B003"))
  assert_true(output.contains("api.wit:2:1: used here"))
  let unknown = @wit_verifier.Diagnostic::from_binary({
    source: "dep.wasm",
    offset: None,
    code: "WIT-B003",
    message: "invalid metadata",
  })
  let output = @cli.render_wit_diagnostics([unknown], [("dep.wasm", "😀\na")])
  assert_true(output.contains("dep.wasm:[binary]: error WIT-B003"))
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

///|
test "explicit feature values retain raw encoded metadata names" {
  let parsed = options([
    "verify", "api.wasm", "--semantic-feature=", "--semantic-feature=-preview", "--semantic-feature=😀",
  ])
  assert_eq(parsed.semantic_features, ["", "-preview", "😀"])
  assert_false(parsed.all_features)
  assert_true(
    @cli.arguments(["verify", "api.wac", "--semantic-feature="]) is Err(_),
  )
}

///|
test "registry flags require explicit WAC registry and preserve offline lock settings" {
  let result = @cli.arguments([
    "verify", "app.wac", "--registry", "https://registry.example", "--offline", "--cache-dir",
    "cache", "--lockfile", "packages.lock", "--warg-provider", "custom-provider",
  ])
  guard result is Ok(Run(options)) else { fail("expected registry options") }
  guard options.registry is Some(settings) else {
    fail("missing registry settings")
  }
  assert_eq(settings.url, "https://registry.example")
  assert_eq(settings.cache_dir, Some("cache"))
  assert_eq(settings.lockfile, Some("packages.lock"))
  assert_eq(settings.provider, "custom-provider")
  assert_true(settings.offline)
  assert_true(!settings.refresh)
  for
    args in [
      ["verify", "app.wac", "--offline"],
      ["verify", "app.wit", "--registry", "https://registry.example"],
      ["parse", "app.wac", "--registry", "https://registry.example"],
      ["verify", "app.wac", "--registry", "file:///tmp/registry"],
      [
        "verify", "app.wac", "--registry", "https://registry.example", "--offline",
        "--refresh",
      ],
      [
        "verify", "app.wac", "--registry", "https://registry.example", "--registry",
        "https://other.example",
      ],
      [
        "verify", "app.wac", "--registry", "https://registry.example", "--lockfile",
      ],
    ] {
    assert_true(@cli.arguments(args[:]) is Err(_))
  }
}

///|
test "WIT verification grammar extensions require all-features independently" {
  let source = "package a:b:c;"
  for flags in [[], ["--all-semantic-features"], ["--semantic-feature", "foo"]] {
    let output = @cli.execute(options(["verify", "a.wit", ..flags]), source)
    assert_eq(output.exit_code, 1)
    assert_true(output.stderr.contains("WIT-P005"))
    let output = @cli.execute(
      options(["verify", "a.wit", "--all-features", ..flags]),
      source,
    )
    assert_eq(output.exit_code, 1)
    assert_false(output.stderr.contains("WIT-P005"))
    assert_true(output.stderr.contains("WIT-S001"))
  }
}

///|
test "WIT verification defaults to the semantic reference grammar" {
  let source = "package example:app; interface api {} world app {import a:api; import b:api;}"
  let reference = @cli.execute(options(["verify", "a.wit"]), source)
  assert_eq(reference.exit_code, 0, msg=reference.stderr)
  let extended = @cli.execute(
    options(["verify", "a.wit", "--all-features"]),
    source,
  )
  assert_eq(extended.exit_code, 1)
  assert_true(extended.stderr.contains("WIT-P003"))
}

///|
test "decompile arguments accept one binary and an optional output file" {
  assert_eq(
    @cli.arguments(["decompile", "app.wasm"]),
    Ok(Decompile({ path: "app.wasm", output: None, })),
  )
  assert_eq(
    @cli.arguments(["decompile", "-o", "app.wat", "--", "-app.wasm"]),
    Ok(Decompile({ path: "-app.wasm", output: Some("app.wat"), })),
  )
  assert_eq(
    @cli.arguments(["decompile", "--output", "app.wat"]),
    Ok(Decompile({ path: "-", output: Some("app.wat"), })),
  )
  assert_true(@cli.arguments(["decompile", "--help"]) is Ok(Help))
  for
    args in [
      ["decompile", "a.wasm", "b.wasm"],
      ["decompile", "a.wasm", "--output"],
      ["decompile", "a.wasm", "--output", "-"],
      ["decompile", "a.wasm", "-o", "x.wat", "-o", "y.wat"],
      ["decompile", "a.wasm", "--language", "wit"],
      ["decompile", "a.wasm", "--output", "a.wasm"],
    ] {
    assert_true(@cli.arguments(args[:]) is Err(_))
  }
  assert_true(@cli.help.contains("decompile [FILE.wasm|-] [--output FILE.wat]"))
}

///|
test "decompile prints one document or explicit diagnostics without a document" {
  // (module (func (export "run")))
  let bytes = b"\x00asm\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x07\x01\x03run\x00\x00\x0a\x04\x01\x02\x00\x0b"
  let expected = "(module\n  (type (;0;) (func))\n  (export \"run\" (func 0))\n  (func (;0;) (type 0)\n  )\n)\n"
  let printed = @cli.decompile({ path: "app.wasm", output: None, }, bytes)
  assert_eq(printed, {
    stdout: expected,
    stderr: "",
    exit_code: 0,
    write_text: None,
  })
  let written = @cli.decompile({ path: "-", output: Some("app.wat"), }, bytes)
  assert_eq(written, {
    stdout: "",
    stderr: "",
    exit_code: 0,
    write_text: Some(expected),
  })
  let component = @cli.decompile(
    { path: "c.wasm", output: Some("c.wat"), },
    b"\x00asm\x0d\x00\x01\x00",
  )
  assert_eq(component.exit_code, 0)
  assert_eq(component.write_text, Some("(component\n)\n"))
  // A type section that declares one entry but holds none.
  let truncated = @cli.decompile(
    { path: "c.wasm", output: Some("c.wat"), },
    b"\x00asm\x0d\x00\x01\x00\x07\x01\x01",
  )
  assert_eq(truncated.exit_code, 1)
  assert_eq(truncated.stdout, "")
  assert_eq(truncated.write_text, None)
  assert_eq(
    truncated.stderr,
    "c.wasm:[byte 11]: error WIT-D001: vector or string exceeds its enclosing section\n",
  )
  // A function declared to return i32 has an empty body.
  let invalid = @cli.decompile(
    { path: "-", output: None, },
    b"\x00asm\x01\x00\x00\x00\x01\x05\x01\x60\x00\x01\x7f\x03\x02\x01\x00\x0a\x04\x01\x02\x00\x0b",
  )
  assert_eq(invalid.exit_code, 1)
  assert_eq(invalid.write_text, None)
  assert_true(invalid.stderr.has_prefix("<stdin>:[binary]: error WIT-D002: "))
}

///|
test "inventory and component selection arguments are unambiguous" {
  assert_eq(
    @cli.arguments(["inventory", "app.wasm", "--json"]),
    Ok(Inventory({ path: "app.wasm", output: None, json: true, })),
  )
  assert_eq(
    @cli.arguments(["decompile", "app.wasm", "--split", "out", "--select-none"]),
    Ok(Split({ path: "app.wasm", directory: "out", select: Some([]), })),
  )
  for
    args in [
      ["decompile", "--select", "root"],
      ["decompile", "--split", "out", "--output", "root.wat"],
      ["decompile", "--split", "out", "--select-none", "--select", "root"],
      ["decompile", "--split", "out", "--select", "root", "--select-none"],
      ["inventory", "--split", "out"],
    ] {
    assert_true(@cli.arguments(args[:]) is Err(_))
  }
}
