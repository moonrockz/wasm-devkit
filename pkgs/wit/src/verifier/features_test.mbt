///|
fn feature_model(
  source : String,
  features : @verifier.SemanticFeatures,
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.verify(
    @parser.parse(source, features=@parser.Features::reference()),
    source~,
    semantic_features=features,
  )
}

///|
test "semantic selection changes models without changing the immutable parse" {
  let source = "package example:app;interface api{@unstable(feature=foo)@deprecated(version=1.0.0)f:func();g:func();}world app{export api;}@unstable(feature=foo)interface optional{}"
  let parsed = @parser.parse(source)
  let disabled = @verifier.verify(parsed, source~).unwrap()
  let enabled = @verifier.verify(parsed, source~, semantic_features={
    enabled: ["foo"],
    all_enabled: false,
  }).unwrap()
  assert_eq(disabled.functions().map(f => f.name), ["g"])
  assert_eq(enabled.functions().map(f => f.name), ["f", "g"])
  assert_eq(enabled.functions()[0].stability, Unstable("foo", Some("1.0.0")))
  assert_eq(disabled.interfaces().length(), 1)
  assert_eq(enabled.interfaces().length(), 2)
  assert_eq(enabled.ast(), parsed.ast)
  assert_eq(disabled.ast(), parsed.ast)
  assert_eq(
    feature_model(source, @verifier.SemanticFeatures::all())
    .unwrap()
    .functions(),
    enabled.functions(),
  )
  assert_eq(
    feature_model(source, { enabled: ["FOO", "other"], all_enabled: false, })
    .unwrap()
    .functions(),
    disabled.functions(),
  )
}

///|
test "selection preserves prefilter name type and accessor validation" {
  for
    body in [
      "@unstable(feature=foo)f:func(x:missing);", "@unstable(feature=foo)f:func();f:func();",
      "@unstable(feature=foo)type t=t;", "@unstable(feature=foo)f:func(x:own<u8>);",
      "@unstable(feature=foo)x:set(value:u8);", "@unstable(feature=foo)x:get(value:u8)->u8;",
      "@unstable(feature=foo)@unstable(feature=bar)f:func();",
    ] {
    let source = "package example:app;interface api{" + body + "}"
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::default()) is Err(_),
      msg=source,
    )
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::all()) is Err(_),
      msg=source,
    )
  }
}

///|
test "inactive functions defer borrowed return and package since checks" {
  for
    source in [
      "package example:app;interface api{resource r;@unstable(feature=foo)f:func()->borrow<r>;}",
      "package example:app;@unstable(feature=foo)interface api{@unstable(feature=foo)resource r;f:func()->borrow<r>;}",
      "package example:app@1.0.0;@unstable(feature=foo)interface api{@since(version=2.0.0)f:func();}",
      "package example:app@1.0.0;@unstable(feature=foo)world app{@since(version=2.0.0)include base;}world base{}",
    ] {
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::default()) is Ok(_),
      msg=source,
    )
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::all()) is Err(_),
      msg=source,
    )
  }
}

///|
test "surviving types cannot lose their owners or referenced declarations" {
  for
    source in [
      "package example:app;@unstable(feature=foo)interface api{type t=u8;}", "package example:app;@unstable(feature=foo)world app{type t=u8;}",
      "package example:app;world app{@unstable(feature=foo)type t=u8;}", "package example:app;interface api{@unstable(feature=foo)type t=u8;f:func(x:t);}",
      "package example:app;interface api{@unstable(feature=foo)resource r{f:func();}}",
      "package example:app;@unstable(feature=foo)interface api{}world app{import api;}",
      "package example:app;world app{@unstable(feature=foo)import api:interface{type t=u8;}}",
      "package example:app;@unstable(feature=foo)world base{}world app{include base;}",
    ] {
    guard feature_model(source, @verifier.SemanticFeatures::default())
      is Err(errors) else {
      fail(source)
    }
    assert_true(errors.any(d => d.code == "WIT-S013"), msg=source)
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::all()) is Ok(_),
      msg=source,
    )
  }
  for
    source in [
      "package example:app;@unstable(feature=foo)interface api{@unstable(feature=foo)type t=u8;}",
      "package example:app;interface api{@unstable(feature=foo)resource r{@unstable(feature=foo)f:func();}}",
      "package example:app;world app{@unstable(feature=foo)import api:interface{@unstable(feature=foo)type t=u8;}}",
    ] {
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::default()) is Ok(_),
      msg=source,
    )
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::all()) is Ok(_),
      msg=source,
    )
  }
}

///|
test "interface accessors pair before selection and world accessors pair after selection and includes" {
  let source = "package example:app;interface api{@unstable(feature=foo)x:get()->u8;x:set(value:u8);}"
  let model = feature_model(source, @verifier.SemanticFeatures::default()).unwrap()
  assert_eq(model.interfaces()[0].functions.length(), 1)
  assert_eq(model.interfaces()[0].functions[0].flavor, Setter)
  for
    source in [
      "package example:app;world app{@unstable(feature=foo)import x:get()->u8;import x:set(value:u8);}",
      "package example:app;world base{import x:get()->u8;}world app{@unstable(feature=foo)include base;import x:set(value:u8);}",
    ] {
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::default()) is Err(_),
      msg=source,
    )
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::all()) is Ok(_),
      msg=source,
    )
  }
  let source = "package example:app;world app{@unstable(feature=foo)import x:set(value:u8);}"
  assert_true(
    feature_model(source, @verifier.SemanticFeatures::default()) is Ok(_),
  )
  assert_true(
    feature_model(source, @verifier.SemanticFeatures::all()) is Err(_),
  )
}

///|
test "anonymous interning keeps first allocation stability and allocates declared types before functions" {
  for
    source in [
      "package example:app;interface api{@unstable(feature=foo)record r{x:list<u8>}f:func(x:list<u8>);}",
      "package example:app;interface api{f:func(x:list<u8>);@unstable(feature=foo)record r{x:list<u8>}}",
      "package example:app;interface api{@unstable(feature=foo)record r{x:list<list<u8>>}f:func(x:list<list<u8>>);}",
      "package example:app;interface api{@unstable(feature=foo)type t=u8;f:func(x:own<t>);}",
    ] {
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::default()) is Err(_),
      msg=source,
    )
  }
  let source = "package example:app@2.0.0;interface api{@since(version=1.0.0)record r{x:list<u8>}@since(version=1.1.0)record s{x:list<u8>}}"
  let model = feature_model(source, @verifier.SemanticFeatures::default()).unwrap()
  assert_eq(
    model.types().filter(t => t.kind is List(_, _)).map(t => t.stability),
    [Stable("1.0.0", None), Stable("1.0.0", None)],
  )
  let source = "package example:app;interface api{record r{x:list<u8>}@unstable(feature=foo)record s{x:list<u8>}}"
  assert_true(
    feature_model(source, @verifier.SemanticFeatures::default()) is Ok(_),
  )
}

///|
test "gated resource aliases remain unavailable through explicit and shorthand owned handles" {
  for
    body in [
      "f:func(x:own<alias>);", "f:func(x:alias);", "f:func(x:borrow<alias>);",
    ] {
    let source = "package example:app;interface api{resource r;@unstable(feature=foo)type alias=r;" +
      body +
      "}"
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::default()) is Err(_),
      msg=source,
    )
    assert_true(
      feature_model(source, @verifier.SemanticFeatures::all()) is Ok(_),
      msg=source,
    )
  }
}

///|
test "law: feature selection retains closed nominal graphs and is deterministic" {
  @quickcheck.check(
    (choices : Array[Byte]) => {
      let source = StringBuilder()
      source.write_string("package example:app;interface api{")
      for i, choice in choices {
        let feature = if choice.to_int() % 2 == 0 { "foo" } else { "bar" }
        source.write_string(
          "@unstable(feature=" +
          feature +
          ")resource r\{i}{@unstable(feature=" +
          feature +
          ")constructor();@unstable(feature=" +
          feature +
          ")read:func(x:list<u8>)->r\{i};}",
        )
      }
      source.write_string("}world app{export api;}")
      let text = source.to_string()
      let profile : @verifier.SemanticFeatures = {
        enabled: ["foo"],
        all_enabled: false,
      }
      guard feature_model(text, profile) is Ok(model) else { return false }
      let ids = model.types().map(t => t.id)
      let resources = model
        .types()
        .filter(t => t.kind is Resource)
        .map(t => t.id)
      resources.length() == choices.filter(c => c.to_int() % 2 == 0).length() &&
      model
      .types()
      .all(t => {
        match t.kind {
          Own(id) | Borrow(id) => resources.contains(id)
          Alias(id) | List(id, _) => ids.contains(id)
          _ => true
        }
      }) &&
      model
      .functions()
      .all(f => {
        f.params.all(p => ids.contains(p.ty)) &&
        f.result.map(id => ids.contains(id)).unwrap_or(true)
      }) &&
      feature_model(text, profile) is Ok(again) &&
      again.types() == model.types() &&
      again.functions() == model.functions() &&
      again.interfaces() == model.interfaces() &&
      again.worlds() == model.worlds()
    },
    count=200,
    max_size=64,
    seed=262016,
  )
}

///|
test "disabled foreign selectors defer member kind checks and cannot enter public models" {
  let source = "package example:app;interface api{@unstable(feature=foo)use example:dep/api.{t};@unstable(feature=foo)f:func(x:borrow<t>);}world app{export api;}package example:dep{interface api{type t=u8;}}"
  let model = feature_model(source, @verifier.SemanticFeatures::default()).unwrap()
  assert_true(model.functions().is_empty())
  assert_true(
    model
    .types()
    .all(t => {
      !(t.kind is Resource) && !(t.kind is Borrow(_)) && !(t.kind is Own(_))
    }),
  )
  let root = model.interfaces().filter(i => i.package_identity.name == "app")[0]
  assert_true(root.types.is_empty())
  assert_true(
    feature_model(source, @verifier.SemanticFeatures::all()) is Err(_),
  )
  let source = "package example:app;interface api{@unstable(feature=foo)use example:dep/api.{t as first};@unstable(feature=bar)use example:dep/api.{t as second};}package example:dep{interface api{type t=u8;}}"
  assert_true(
    feature_model(source, @verifier.SemanticFeatures::default()) is Ok(_),
  )
  guard feature_model(source, { enabled: ["bar"], all_enabled: false, })
    is Err(errors) else {
    fail("first foreign type gate ignored")
  }
  assert_eq(errors[0].code, "WIT-S013")
  assert_eq(errors[0].related[0].message, "first foreign type gate")
  assert_true(feature_model(source, @verifier.SemanticFeatures::all()) is Ok(_))
}

///|
test "foreign path gates validate versions before owner selection and stop after an enabled path" {
  let tail = "package example:dep{interface api{}}"
  let inactive = "@unstable(feature=foo)world app{@since(version=2.0.0)import example:dep/api;}"
  let active = "world other{import example:dep/api;}"
  let early_active = "package example:app@1.0.0;" + active + inactive + tail
  let late_active = "package example:app@1.0.0;" + inactive + active + tail
  assert_true(
    feature_model(early_active, @verifier.SemanticFeatures::default()) is Ok(_),
  )
  assert_true(
    feature_model(late_active, @verifier.SemanticFeatures::default()) is Err(_),
  )
  assert_true(
    feature_model(early_active, @verifier.SemanticFeatures::all()) is Err(_),
  )
}

///|
test "foreign member kinds precede feature selection and retain first-use world aliases" {
  let mixed = "package example:app;world app{@unstable(feature=foo)import example:dep/missing;@unstable(feature=bar)include example:dep/missing;}package example:dep{interface api{}}"
  assert_true(
    feature_model(mixed, @verifier.SemanticFeatures::default()) is Err(errors) &&
    errors.any(d => d.code == "WIT-S008"),
  )
  let source = "package example:app;world first{include example:dep/base;}use example:dep/base as other;world second{include other;}package example:dep{world base{}}"
  assert_true(
    feature_model(source, @verifier.SemanticFeatures::default()) is Ok(_),
  )
  let wrong = "package example:app;use example:dep/base as other;world first{include example:dep/base;}world second{include other;}package example:dep{world base{}}"
  assert_true(
    feature_model(wrong, @verifier.SemanticFeatures::default()) is Err(_),
  )
}
