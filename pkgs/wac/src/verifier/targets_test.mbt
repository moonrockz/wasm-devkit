// Original target-world probes against pinned WAC 0.12.0 API and CLI.

///|
test "pinned targets empty" {
  let source = "package test:app targets test:app/w; world w {}"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "0", "1", "w", "type", "world", "test:app/w", "0", "0", "0",
  ])
  let unconstrained = "package test:app; world w {}"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets function" {
  let source = "package test:app targets test:app/w; world w {import f: func(); export out: func();} import f: func(); export f as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "0", "none", "2", "w", "type", "world",
    "test:app/w", "0", "1", "f", "func", "function", "false", "0", "none", "1", "out",
    "func", "function", "false", "0", "none", "out", "func", "function", "false",
    "0", "none",
  ])
  let unconstrained = "package test:app; world w {import f: func(); export out: func();} import f: func(); export f as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets unused-import" {
  let source = "package test:app targets test:app/w; world w {import f: func();}"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "0", "1", "w", "type", "world", "test:app/w", "0", "1", "f", "func", "function",
    "false", "0", "none", "0",
  ])
  let unconstrained = "package test:app; world w {import f: func();}"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets extra-import" {
  let source = "package test:app targets test:app/w; world w {} import f: func();"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T001")
  let unconstrained = "package test:app; world w {} import f: func();"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets missing-export" {
  let source = "package test:app targets test:app/w; world w {export out: func();}"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T002")
  let unconstrained = "package test:app; world w {export out: func();}"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets import-parameter" {
  let source = "package test:app targets test:app/w; world w {import f: func(x: u32);} import f: func(x: u16);"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T003")
  let unconstrained = "package test:app; world w {import f: func(x: u32);} import f: func(x: u16);"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets export-result" {
  let source = "package test:app targets test:app/w; world w {import f: func() -> u16; export out: func() -> u32;} import f: func() -> u16; export f as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T003")
  let unconstrained = "package test:app; world w {import f: func() -> u16; export out: func() -> u32;} import f: func() -> u16; export f as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets import-narrower" {
  let source = "package test:app targets test:app/w; world w {import i: interface {f: func();g: func();};} import i: interface {f: func();};"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "none", "1", "w", "type", "world", "test:app/w", "0", "1", "i", "instance",
    "interface", "", "0", "2", "f", "func", "function", "false", "0", "none", "g",
    "func", "function", "false", "0", "none", "0",
  ])
  let unconstrained = "package test:app; world w {import i: interface {f: func();g: func();};} import i: interface {f: func();};"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets import-wider" {
  let source = "package test:app targets test:app/w; world w {import i: interface {f: func();};} import i: interface {f: func();g: func();};"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T003")
  let unconstrained = "package test:app; world w {import i: interface {f: func();};} import i: interface {f: func();g: func();};"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets export-wider" {
  let source = "package test:app targets test:app/w; world w {import i: interface {f: func();g: func();}; export out: interface {f: func();};} import i: interface {f: func();g: func();}; export i as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "i", "instance", "interface", "", "0", "2", "f", "func", "function", "false",
    "0", "none", "g", "func", "function", "false", "0", "none", "2", "w", "type",
    "world", "test:app/w", "0", "1", "i", "instance", "interface", "", "0", "2",
    "f", "func", "function", "false", "0", "none", "g", "func", "function", "false",
    "0", "none", "1", "out", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "out", "instance", "interface", "", "0", "2",
    "f", "func", "function", "false", "0", "none", "g", "func", "function", "false",
    "0", "none",
  ])
  let unconstrained = "package test:app; world w {import i: interface {f: func();g: func();}; export out: interface {f: func();};} import i: interface {f: func();g: func();}; export i as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets export-narrower" {
  let source = "package test:app targets test:app/w; world w {import i: interface {f: func();}; export out: interface {f: func();g: func();};} import i: interface {f: func();}; export i as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T003")
  let unconstrained = "package test:app; world w {import i: interface {f: func();}; export out: interface {f: func();g: func();};} import i: interface {f: func();}; export i as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets export-spread" {
  let source = "package test:app targets test:app/w; world w {import i: interface {f: func();}; export f: func();} import i: interface {f: func();}; export i...;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "i", "instance", "interface", "", "0", "1", "f", "func", "function", "false",
    "0", "none", "2", "w", "type", "world", "test:app/w", "0", "1", "i", "instance",
    "interface", "", "0", "1", "f", "func", "function", "false", "0", "none", "1",
    "f", "func", "function", "false", "0", "none", "f", "func", "function", "false",
    "0", "none",
  ])
  let unconstrained = "package test:app; world w {import i: interface {f: func();}; export f: func();} import i: interface {f: func();}; export i...;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets missing-world" {
  let source = "package test:app targets test:app/absent; world w {}"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
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
  let unconstrained = "package test:app; world w {}"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets interface-target" {
  let source = "package test:app targets test:app/api; interface api {}"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T001")
  let unconstrained = "package test:app; interface api {}"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets scalar-target" {
  let source = "package test:app targets test:app/t; type t=u32;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T001")
  let unconstrained = "package test:app; type t=u32;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets alias-target" {
  let source = "package test:app targets test:app/alias; world w {} let alias=w;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "0", "1", "w", "type", "world", "test:app/w", "0", "0", "0",
  ])
  let unconstrained = "package test:app; world w {} let alias=w;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets forward-target" {
  let source = "package test:app targets test:app/w; import f: func(); export f; world w {import f: func(); export f: func();}"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "f", "func", "function", "false", "0", "none", "2", "f", "func", "function",
    "false", "0", "none", "w", "type", "world", "test:app/w", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "f", "func", "function", "false", "0",
    "none",
  ])
  let unconstrained = "package test:app; import f: func(); export f; world w {import f: func(); export f: func();}"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-captured-export" {
  let source = "package test:app targets test:app/w; interface api {resource handle;take: func(h: handle);} world w {use api.{handle};import b: api;export out: func(h: handle);} import a as \"test:app/api\": api;import b as b: api;export a.take as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "test:app/api", "instance", "interface", "test:app/api", "0", "2", "handle",
    "type", "resource", "0", "take", "func", "function", "false", "1", "h", "own",
    "0", "none", "b", "instance", "interface", "test:app/api", "0", "2", "handle",
    "type", "resource", "0", "take", "func", "function", "false", "1", "h", "own",
    "0", "none", "3", "api", "type", "interface", "test:app/api", "0", "2", "handle",
    "type", "resource", "0", "take", "func", "function", "false", "1", "h", "own",
    "0", "none", "w", "type", "world", "test:app/w", "1", "handle", "handle", "test:app/api",
    "2", "handle", "type", "resource", "0", "b", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "1", "out", "func", "function", "false", "1", "h",
    "own", "0", "none", "out", "func", "function", "false", "1", "h", "own", "0",
    "none",
  ])
  let unconstrained = "package test:app; interface api {resource handle;take: func(h: handle);} world w {use api.{handle};import b: api;export out: func(h: handle);} import a as \"test:app/api\": api;import b as b: api;export a.take as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-crossed-export" {
  let source = "package test:app targets test:app/w; interface api {resource handle;take: func(h: handle);} world w {use api.{handle};import b: api;export out: func(h: handle);} import a as \"test:app/api\": api;import b as b: api;export b.take as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T003")
  let unconstrained = "package test:app; interface api {resource handle;take: func(h: handle);} world w {use api.{handle};import b: api;export out: func(h: handle);} import a as \"test:app/api\": api;import b as b: api;export b.take as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-instance" {
  let source = "package test:app targets test:app/w; interface api {resource handle;take: func(h: handle);} world w {import a: api;export out: api;} import a as a: api;export a as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "3", "api", "type", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "w", "type", "world", "test:app/w", "0", "1", "a", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "1", "out", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "out", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none",
  ])
  let unconstrained = "package test:app; interface api {resource handle;take: func(h: handle);} world w {import a: api;export out: api;} import a as a: api;export a as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-two-instances" {
  let source = "package test:app targets test:app/w; interface api {resource handle;take: func(h: handle);} world w {import a: api;import b: api;export out: api;} import a as a: api;import b as b: api;export a as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "b", "instance", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "3",
    "api", "type", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "w",
    "type", "world", "test:app/w", "0", "2", "a", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "b", "instance", "interface", "test:app/api", "0",
    "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "1", "out", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "out", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none",
  ])
  let unconstrained = "package test:app; interface api {resource handle;take: func(h: handle);} world w {import a: api;import b: api;export out: api;} import a as a: api;import b as b: api;export a as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-two-instances-second" {
  let source = "package test:app targets test:app/w; interface api {resource handle;take: func(h: handle);} world w {import a: api;import b: api;export out: api;} import a as a: api;import b as b: api;export b as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "b", "instance", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "3",
    "api", "type", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "w",
    "type", "world", "test:app/w", "0", "2", "a", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "b", "instance", "interface", "test:app/api", "0",
    "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "1", "out", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "out", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none",
  ])
  let unconstrained = "package test:app; interface api {resource handle;take: func(h: handle);} world w {import a: api;import b: api;export out: api;} import a as a: api;import b as b: api;export b as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-implicit-use" {
  let source = "package test:app targets test:app/w; interface api {resource handle;} world w {use api.{handle};import f: func(h: handle);export out: func(h: handle);} import a as \"test:app/api\": api;let handle=a.handle;import f: func(h: handle);export f as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "test:app/api", "instance", "interface", "test:app/api", "0", "1", "handle",
    "type", "resource", "0", "f", "func", "function", "false", "1", "h", "own", "0",
    "none", "3", "api", "type", "interface", "test:app/api", "0", "1", "handle",
    "type", "resource", "0", "w", "type", "world", "test:app/w", "1", "handle", "handle",
    "test:app/api", "2", "handle", "type", "resource", "0", "f", "func", "function",
    "false", "1", "h", "own", "0", "none", "1", "out", "func", "function", "false",
    "1", "h", "own", "0", "none", "out", "func", "function", "false", "1", "h", "own",
    "0", "none",
  ])
  let unconstrained = "package test:app; interface api {resource handle;} world w {use api.{handle};import f: func(h: handle);export out: func(h: handle);} import a as \"test:app/api\": api;let handle=a.handle;import f: func(h: handle);export f as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-type" {
  let source = "package test:app targets test:app/w; interface api {resource handle;} world w {resource handle;import take: func(h: handle);export out: func(h: handle);} import handle as handle: test:app/api/handle;import take: func(h: handle);export take as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "3", "api", "type", "interface", "test:app/api",
    "0", "1", "handle", "type", "resource", "0", "w", "type", "world", "test:app/w",
    "0", "2", "handle", "type", "resource", "1", "take", "func", "function", "false",
    "1", "h", "own", "1", "none", "1", "out", "func", "function", "false", "1", "h",
    "own", "1", "none", "out", "func", "function", "false", "1", "h", "own", "0",
    "none",
  ])
  let unconstrained = "package test:app; interface api {resource handle;} world w {resource handle;import take: func(h: handle);export out: func(h: handle);} import handle as handle: test:app/api/handle;import take: func(h: handle);export take as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-alias-consistent" {
  let source = "package test:app targets test:app/w; interface api {resource handle;} world w {resource handle;type other=handle;} import handle as handle: test:app/api/handle;let other=handle;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "handle", "type", "resource", "0", "2", "api", "type", "interface", "test:app/api",
    "0", "1", "handle", "type", "resource", "0", "w", "type", "world", "test:app/w",
    "0", "2", "handle", "type", "resource", "1", "other", "type", "resource", "1",
    "0",
  ])
  let unconstrained = "package test:app; interface api {resource handle;} world w {resource handle;type other=handle;} import handle as handle: test:app/api/handle;let other=handle;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-alias-crossed" {
  let source = "package test:app targets test:app/w; interface api {resource handle;} world w {resource handle;type other=handle;} import handle as handle: test:app/api/handle;import other as other: test:app/api/handle;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "handle", "type", "resource", "0", "other", "type", "resource", "0", "2",
    "api", "type", "interface", "test:app/api", "0", "1", "handle", "type", "resource",
    "0", "w", "type", "world", "test:app/w", "0", "2", "handle", "type", "resource",
    "1", "other", "type", "resource", "1", "0",
  ])
  let unconstrained = "package test:app; interface api {resource handle;} world w {resource handle;type other=handle;} import handle as handle: test:app/api/handle;import other as other: test:app/api/handle;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

///|
test "pinned targets resource-export-owned" {
  let source = "package test:app targets test:app/w; interface api {resource handle;take: func(h: handle);} world w {import a: api;import b: api;export first: api;export second: api;} import a as a: api;import b as b: api;export a as first;export b as second;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = []
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "2", "a", "instance", "interface", "test:app/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "b", "instance", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "4",
    "api", "type", "interface", "test:app/api", "0", "2", "handle", "type", "resource",
    "0", "take", "func", "function", "false", "1", "h", "own", "0", "none", "w",
    "type", "world", "test:app/w", "0", "2", "a", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "b", "instance", "interface", "test:app/api", "0",
    "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "2", "first", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "second", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "first", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none", "second", "instance", "interface", "test:app/api",
    "0", "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none",
  ])
  let unconstrained = "package test:app; interface api {resource handle;take: func(h: handle);} world w {import a: api;import b: api;export first: api;export second: api;} import a as a: api;import b as b: api;export a as first;export b as second;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $expected (component (type (func)) (export "f" (func (type 0))))) (type $provided (component (type (func)) (import "f" (func (type 0))) (export "f" (func (type 0))))) (type $world (component (alias outer 1 $expected (type $expected)) (import "c" (component (type $expected))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)) (type $provider (component (alias outer 1 $provided (type $provided)) (export "test:target/provider" (component (type $provided))))) (export "provider" (type $provider)))

///|
fn target_component_import_fewer_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x47\x04\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x03\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x41\x02\x02\x03\x02\x01\x00\x03\x00\x01\x63\x04\x00\x41\x02\x02\x03\x02\x01\x02\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x03\x00\x07\x21\x01\x41\x02\x02\x03\x02\x01\x01\x04\x00\x14\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x70\x72\x6f\x76\x69\x64\x65\x72\x04\x00\x0b\x0e\x01\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x03\x05\x00\x00\x41\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x30\x03\x05\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x08\x70\x72\x6f\x76\x69\x64\x65\x64\x02\x05\x77\x6f\x72\x6c\x64\x03\x07\x77\x72\x61\x70\x70\x65\x72\x05\x08\x70\x72\x6f\x76\x69\x64\x65\x72"
}

///|
test "pinned targets component-import-fewer" {
  let source = "package test:app targets lookup:target/w; import c as c: lookup:target/provider;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "component-import-fewer.wasm",
      bytes: target_component_import_fewer_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "c", "component", "world", "test:target/provider", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "f", "func", "function", "false", "0",
    "none", "0",
  ])
  let unconstrained = "package test:app; import c as c: lookup:target/provider;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $expected (component (type (func)) (import "f" (func (type 0))) (export "f" (func (type 0))))) (type $provided (component (type (func)) (export "f" (func (type 0))))) (type $world (component (alias outer 1 $expected (type $expected)) (import "c" (component (type $expected))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)) (type $provider (component (alias outer 1 $provided (type $provided)) (export "test:target/provider" (component (type $provided))))) (export "provider" (type $provider)))

///|
fn target_component_import_more_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x47\x04\x41\x03\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x02\x02\x03\x02\x01\x00\x03\x00\x01\x63\x04\x00\x41\x02\x02\x03\x02\x01\x02\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x03\x00\x07\x21\x01\x41\x02\x02\x03\x02\x01\x01\x04\x00\x14\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x70\x72\x6f\x76\x69\x64\x65\x72\x04\x00\x0b\x0e\x01\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x03\x05\x00\x00\x41\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x30\x03\x05\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x08\x70\x72\x6f\x76\x69\x64\x65\x64\x02\x05\x77\x6f\x72\x6c\x64\x03\x07\x77\x72\x61\x70\x70\x65\x72\x05\x08\x70\x72\x6f\x76\x69\x64\x65\x72"
}

///|
test "pinned targets component-import-more" {
  let source = "package test:app targets lookup:target/w; import c as c: lookup:target/provider;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "component-import-more.wasm",
      bytes: target_component_import_more_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T003")
  let unconstrained = "package test:app; import c as c: lookup:target/provider;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $expected (component (type (func)) (export "f" (func (type 0))))) (type $provided (component (type (func)) (export "f" (func (type 0))))) (type $out (component (type (func)) (import "f" (func (type 0))) (export "f" (func (type 0))))) (type $world (component (alias outer 1 $expected (type $expected)) (import "c" (component (type $expected))) (alias outer 1 $out (type $out)) (export "out" (component (type $out))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)) (type $provider (component (alias outer 1 $provided (type $provided)) (export "test:target/provider" (component (type $provided))))) (export "provider" (type $provider)))

///|
fn target_component_export_fewer_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x61\x05\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x03\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x41\x04\x02\x03\x02\x01\x00\x03\x00\x01\x63\x04\x00\x02\x03\x02\x01\x02\x04\x00\x03\x6f\x75\x74\x04\x01\x41\x02\x02\x03\x02\x01\x03\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x04\x00\x07\x21\x01\x41\x02\x02\x03\x02\x01\x01\x04\x00\x14\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x70\x72\x6f\x76\x69\x64\x65\x72\x04\x00\x0b\x0e\x01\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x03\x06\x00\x00\x46\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x35\x03\x06\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x08\x70\x72\x6f\x76\x69\x64\x65\x64\x02\x03\x6f\x75\x74\x03\x05\x77\x6f\x72\x6c\x64\x04\x07\x77\x72\x61\x70\x70\x65\x72\x06\x08\x70\x72\x6f\x76\x69\x64\x65\x72"
}

///|
test "pinned targets component-export-fewer" {
  let source = "package test:app targets lookup:target/w; import c as c: lookup:target/provider;export c as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "component-export-fewer.wasm",
      bytes: target_component_export_fewer_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "c", "component", "world", "test:target/provider", "0", "0", "1", "f", "func",
    "function", "false", "0", "none", "1", "out", "component", "world", "test:target/provider",
    "0", "0", "1", "f", "func", "function", "false", "0", "none",
  ])
  let unconstrained = "package test:app; import c as c: lookup:target/provider;export c as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $expected (component (type (func)) (import "f" (func (type 0))) (export "f" (func (type 0))))) (type $provided (component (type (func)) (import "f" (func (type 0))) (export "f" (func (type 0))))) (type $out (component (type (func)) (export "f" (func (type 0))))) (type $world (component (alias outer 1 $expected (type $expected)) (import "c" (component (type $expected))) (alias outer 1 $out (type $out)) (export "out" (component (type $out))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)) (type $provider (component (alias outer 1 $provided (type $provided)) (export "test:target/provider" (component (type $provided))))) (export "provider" (type $provider)))

///|
fn target_component_export_more_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x67\x05\x41\x03\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x41\x03\x01\x40\x00\x01\x00\x03\x00\x01\x66\x01\x00\x04\x00\x01\x66\x01\x00\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x04\x02\x03\x02\x01\x00\x03\x00\x01\x63\x04\x00\x02\x03\x02\x01\x02\x04\x00\x03\x6f\x75\x74\x04\x01\x41\x02\x02\x03\x02\x01\x03\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x04\x00\x07\x21\x01\x41\x02\x02\x03\x02\x01\x01\x04\x00\x14\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x70\x72\x6f\x76\x69\x64\x65\x72\x04\x00\x0b\x0e\x01\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x03\x06\x00\x00\x46\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x35\x03\x06\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x08\x70\x72\x6f\x76\x69\x64\x65\x64\x02\x03\x6f\x75\x74\x03\x05\x77\x6f\x72\x6c\x64\x04\x07\x77\x72\x61\x70\x70\x65\x72\x06\x08\x70\x72\x6f\x76\x69\x64\x65\x72"
}

///|
test "pinned targets component-export-more" {
  let source = "package test:app targets lookup:target/w; import c as c: lookup:target/provider;export c as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "component-export-more.wasm",
      bytes: target_component_export_more_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T003")
  let unconstrained = "package test:app; import c as c: lookup:target/provider;export c as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $expected (component (type (func)) (export "f" (func (type 0))) (export "g" (func (type 0))))) (type $provided (component (type (func)) (export "f" (func (type 0))) (export "g" (func (type 0))))) (type $out (component (type (func)) (export "f" (func (type 0))))) (type $world (component (alias outer 1 $expected (type $expected)) (import "c" (component (type $expected))) (alias outer 1 $out (type $out)) (export "out" (component (type $out))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)) (type $provider (component (alias outer 1 $provided (type $provided)) (export "test:target/provider" (component (type $provided))))) (export "provider" (type $provider)))

///|
fn target_component_export_extra_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x67\x05\x41\x03\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x67\x01\x00\x41\x03\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x67\x01\x00\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x04\x02\x03\x02\x01\x00\x03\x00\x01\x63\x04\x00\x02\x03\x02\x01\x02\x04\x00\x03\x6f\x75\x74\x04\x01\x41\x02\x02\x03\x02\x01\x03\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x04\x00\x07\x21\x01\x41\x02\x02\x03\x02\x01\x01\x04\x00\x14\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x70\x72\x6f\x76\x69\x64\x65\x72\x04\x00\x0b\x0e\x01\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x03\x06\x00\x00\x46\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x35\x03\x06\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x08\x70\x72\x6f\x76\x69\x64\x65\x64\x02\x03\x6f\x75\x74\x03\x05\x77\x6f\x72\x6c\x64\x04\x07\x77\x72\x61\x70\x70\x65\x72\x06\x08\x70\x72\x6f\x76\x69\x64\x65\x72"
}

///|
test "pinned targets component-export-extra" {
  let source = "package test:app targets lookup:target/w; import c as c: lookup:target/provider;export c as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "component-export-extra.wasm",
      bytes: target_component_export_extra_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "c", "component", "world", "test:target/provider", "0", "0", "2", "f", "func",
    "function", "false", "0", "none", "g", "func", "function", "false", "0", "none",
    "1", "out", "component", "world", "test:target/provider", "0", "0", "2", "f",
    "func", "function", "false", "0", "none", "g", "func", "function", "false", "0",
    "none",
  ])
  let unconstrained = "package test:app; import c as c: lookup:target/provider;export c as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $expected (component (type (func)) (export "f" (func (type 0))))) (type $provided (component (type (func)) (export "f" (func (type 0))))) (type $out (component (type (func)) (export "f" (func (type 0))) (export "g" (func (type 0))))) (type $world (component (alias outer 1 $expected (type $expected)) (import "c" (component (type $expected))) (alias outer 1 $out (type $out)) (export "out" (component (type $out))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)) (type $provider (component (alias outer 1 $provided (type $provided)) (export "test:target/provider" (component (type $provided))))) (export "provider" (type $provider)))

///|
fn target_component_export_missing_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x61\x05\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x41\x03\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x04\x00\x01\x67\x01\x00\x41\x04\x02\x03\x02\x01\x00\x03\x00\x01\x63\x04\x00\x02\x03\x02\x01\x02\x04\x00\x03\x6f\x75\x74\x04\x01\x41\x02\x02\x03\x02\x01\x03\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x04\x00\x07\x21\x01\x41\x02\x02\x03\x02\x01\x01\x04\x00\x14\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x70\x72\x6f\x76\x69\x64\x65\x72\x04\x00\x0b\x0e\x01\x00\x08\x70\x72\x6f\x76\x69\x64\x65\x72\x03\x06\x00\x00\x46\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x35\x03\x06\x00\x08\x65\x78\x70\x65\x63\x74\x65\x64\x01\x08\x70\x72\x6f\x76\x69\x64\x65\x64\x02\x03\x6f\x75\x74\x03\x05\x77\x6f\x72\x6c\x64\x04\x07\x77\x72\x61\x70\x70\x65\x72\x06\x08\x70\x72\x6f\x76\x69\x64\x65\x72"
}

///|
test "pinned targets component-export-missing" {
  let source = "package test:app targets lookup:target/w; import c as c: lookup:target/provider;export c as out;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "component-export-missing.wasm",
      bytes: target_component_export_missing_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T003")
  let unconstrained = "package test:app; import c as c: lookup:target/provider;export c as out;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $world (component (type $api (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.2.0" (instance (type $api))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)))

///|
fn target_semver_import_same_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x02\x41\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x12\x03\x02\x00\x05\x77\x6f\x72\x6c\x64\x01\x07\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets semver-import-same" {
  let source = "package test:app targets lookup:target/w; import i as \"test:api/run@1.2.0\": interface {f: func();};"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "semver-import-same.wasm",
      bytes: target_semver_import_same_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "test:api/run@1.2.0", "instance", "interface", "", "0", "1", "f", "func",
    "function", "false", "0", "none", "0",
  ])
  let unconstrained = "package test:app; import i as \"test:api/run@1.2.0\": interface {f: func();};"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $world (component (type $api (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.2.0" (instance (type $api))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)))

///|
fn target_semver_import_compatible_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x02\x41\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x12\x03\x02\x00\x05\x77\x6f\x72\x6c\x64\x01\x07\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets semver-import-compatible" {
  let source = "package test:app targets lookup:target/w; import i as \"test:api/run@1.0.0\": interface {f: func();};"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "semver-import-compatible.wasm",
      bytes: target_semver_import_compatible_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T001")
  let unconstrained = "package test:app; import i as \"test:api/run@1.0.0\": interface {f: func();};"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $world (component (type $api (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.2.0" (instance (type $api))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)))

///|
fn target_semver_import_major_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x41\x02\x41\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x12\x03\x02\x00\x05\x77\x6f\x72\x6c\x64\x01\x07\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets semver-import-major" {
  let source = "package test:app targets lookup:target/w; import i as \"test:api/run@2.0.0\": interface {f: func();};"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "semver-import-major.wasm",
      bytes: target_semver_import_major_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T001")
  let unconstrained = "package test:app; import i as \"test:api/run@2.0.0\": interface {f: func();};"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $world (component (type $api (instance (type (func)) (export "f" (func (type 0))))) (import "test:api/run@1.2.0+second" (instance (type $api))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)))

///|
fn target_semver_import_build_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x48\x02\x41\x02\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x19\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x2b\x73\x65\x63\x6f\x6e\x64\x05\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x12\x03\x02\x00\x05\x77\x6f\x72\x6c\x64\x01\x07\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets semver-import-build" {
  let source = "package test:app targets lookup:target/w; import i as \"test:api/run@1.2.0+first\": interface {f: func();};"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "semver-import-build.wasm",
      bytes: target_semver_import_build_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T001")
  let unconstrained = "package test:app; import i as \"test:api/run@1.2.0+first\": interface {f: func();};"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $world (component (type $api (instance (type (func)) (export "f" (func (type 0))))) (import "runtime" (instance (type $api))) (export "test:api/run@1.2.0" (instance (type $api))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)))

///|
fn target_semver_export_compatible_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x4d\x02\x41\x03\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x07\x72\x75\x6e\x74\x69\x6d\x65\x05\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x12\x03\x02\x00\x05\x77\x6f\x72\x6c\x64\x01\x07\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets semver-export-compatible" {
  let source = "package test:app targets lookup:target/w; import i as \"runtime\": interface {f: func();};export i as \"test:api/run@1.0.0\";"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "semver-export-compatible.wasm",
      bytes: target_semver_export_compatible_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T002")
  let unconstrained = "package test:app; import i as \"runtime\": interface {f: func();};export i as \"test:api/run@1.0.0\";"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $world (component (type $api (instance (type (func)) (export "f" (func (type 0))))) (import "runtime" (instance (type $api))) (export "test:api/run@1.2.0" (instance (type $api))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)))

///|
fn target_semver_export_same_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x4d\x02\x41\x03\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x07\x72\x75\x6e\x74\x69\x6d\x65\x05\x00\x04\x00\x12\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x05\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x12\x03\x02\x00\x05\x77\x6f\x72\x6c\x64\x01\x07\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets semver-export-same" {
  let source = "package test:app targets lookup:target/w; import i as \"runtime\": interface {f: func();};export i as \"test:api/run@1.2.0\";"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "semver-export-same.wasm",
      bytes: target_semver_export_same_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "runtime", "instance", "interface", "", "0", "1", "f", "func", "function",
    "false", "0", "none", "1", "test:api/run@1.2.0", "instance", "interface", "",
    "0", "1", "f", "func", "function", "false", "0", "none",
  ])
  let unconstrained = "package test:app; import i as \"runtime\": interface {f: func();};export i as \"test:api/run@1.2.0\";"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $world (component (type $api (instance (type (func)) (export "f" (func (type 0))))) (import "runtime" (instance (type $api))) (export "test:api/run@1.2.0-rc.1" (instance (type $api))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)))

///|
fn target_semver_export_prerelease_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x52\x02\x41\x03\x01\x42\x02\x01\x40\x00\x01\x00\x04\x00\x01\x66\x01\x00\x03\x00\x07\x72\x75\x6e\x74\x69\x6d\x65\x05\x00\x04\x00\x17\x74\x65\x73\x74\x3a\x61\x70\x69\x2f\x72\x75\x6e\x40\x31\x2e\x32\x2e\x30\x2d\x72\x63\x2e\x31\x05\x00\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x01\x00\x00\x23\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x12\x03\x02\x00\x05\x77\x6f\x72\x6c\x64\x01\x07\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets semver-export-prerelease" {
  let source = "package test:app targets lookup:target/w; import i as \"runtime\": interface {f: func();};export i as \"test:api/run@1.2.0-rc.2\";"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "semver-export-prerelease.wasm",
      bytes: target_semver_export_prerelease_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    false,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(result.unwrap_err()[0].code, "WAC-T002")
  let unconstrained = "package test:app; import i as \"runtime\": interface {f: func();};export i as \"test:api/run@1.2.0-rc.2\";"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $api (instance (export "handle" (type $h (sub resource))) (type $f (func (param "h" (own $h)))) (export "take" (func (type $f))))) (type $world (component (alias outer 1 $api (type $api)) (import "a" (instance (type $api))) (export "handle" (type $h (sub resource))) (type $f (func (param "h" (own $h)))) (export "take" (func (type $f))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)) (type $api-wrapper (component (alias outer 1 $api (type $api)) (export "test:target/api" (instance (type $api))))) (export "api" (type $api-wrapper)))

///|
fn target_component_resource_export_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x67\x03\x42\x04\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x00\x01\x40\x01\x01\x68\x01\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x02\x41\x06\x02\x03\x02\x01\x00\x03\x00\x01\x61\x05\x00\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x01\x01\x40\x01\x01\x68\x02\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x03\x41\x02\x02\x03\x02\x01\x01\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x02\x00\x07\x1c\x01\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0f\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x04\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x24\x03\x04\x00\x03\x61\x70\x69\x01\x05\x77\x6f\x72\x6c\x64\x02\x07\x77\x72\x61\x70\x70\x65\x72\x04\x0b\x61\x70\x69\x2d\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets component-resource-export" {
  let source = "package test:app targets lookup:target/w; import a as a: lookup:target/api;export a.handle as handle;export a.take as take;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "component-resource-export.wasm",
      bytes: target_component_resource_export_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "a", "instance", "interface", "test:target/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "2", "handle", "type", "resource", "0", "take", "func", "function", "false",
    "1", "h", "own", "0", "none",
  ])
  let unconstrained = "package test:app; import a as a: lookup:target/api;export a.handle as handle;export a.take as take;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}

// (component (type $api (instance (export "handle" (type $h (sub resource))) (type $f (func (param "h" (own $h)))) (export "take" (func (type $f))))) (type $world (component (alias outer 1 $api (type $api)) (import "a" (instance (type $api))) (export "handle" (type $h (sub resource))) (type $f (func (param "h" (own $h)))) (export "take" (func (type $f))))) (type $wrapper (component (alias outer 1 $world (type $world)) (export "test:target/w" (component (type $world))))) (export "w" (type $wrapper)) (type $api-wrapper (component (alias outer 1 $api (type $api)) (export "test:target/api" (instance (type $api))))) (export "api" (type $api-wrapper)))

///|
fn target_component_resource_export_reordered_bytes() -> Bytes {
  b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x07\x67\x03\x42\x04\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x00\x01\x40\x01\x01\x68\x01\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x02\x41\x06\x02\x03\x02\x01\x00\x03\x00\x01\x61\x05\x00\x04\x00\x06\x68\x61\x6e\x64\x6c\x65\x03\x01\x01\x69\x01\x01\x40\x01\x01\x68\x02\x01\x00\x04\x00\x04\x74\x61\x6b\x65\x01\x03\x41\x02\x02\x03\x02\x01\x01\x04\x00\x0d\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x77\x04\x00\x0b\x07\x01\x00\x01\x77\x03\x02\x00\x07\x1c\x01\x41\x02\x02\x03\x02\x01\x00\x04\x00\x0f\x74\x65\x73\x74\x3a\x74\x61\x72\x67\x65\x74\x2f\x61\x70\x69\x05\x00\x0b\x09\x01\x00\x03\x61\x70\x69\x03\x04\x00\x00\x35\x0e\x63\x6f\x6d\x70\x6f\x6e\x65\x6e\x74\x2d\x6e\x61\x6d\x65\x01\x24\x03\x04\x00\x03\x61\x70\x69\x01\x05\x77\x6f\x72\x6c\x64\x02\x07\x77\x72\x61\x70\x70\x65\x72\x04\x0b\x61\x70\x69\x2d\x77\x72\x61\x70\x70\x65\x72"
}

///|
test "pinned targets component-resource-export-reordered" {
  let source = "package test:app targets lookup:target/w; import a as a: lookup:target/api;export a.take as take;export a.handle as handle;"
  assert_true(@parser.parse(source).is_valid())
  let dependencies : ReadOnlyArray[@verifier.PackageSource] = [
    {
      name: "lookup:target",
      version: None,
      source: "component-resource-export-reordered.wasm",
      bytes: target_component_resource_export_reordered_bytes(),
    },
  ]
  let result = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="targets.wac",
    dependencies~,
  )
  assert_eq(
    result is Ok(_),
    true,
    msg=match result {
      Ok(_) => "accepted"
      Err(errors) => errors[0].render()
    },
  )
  assert_eq(source_projection(result.unwrap()), [
    "1", "a", "instance", "interface", "test:target/api", "0", "2", "handle", "type",
    "resource", "0", "take", "func", "function", "false", "1", "h", "own", "0", "none",
    "2", "take", "func", "function", "false", "1", "h", "own", "0", "none", "handle",
    "type", "resource", "0",
  ])
  let unconstrained = "package test:app; import a as a: lookup:target/api;export a.take as take;export a.handle as handle;"
  assert_true(
    @verifier.verify(
      @parser.parse(unconstrained),
      source=unconstrained,
      dependencies~,
    )
    is Ok(_),
  )
}
