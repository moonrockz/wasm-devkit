///|
fn section_document(id : String, text : String) -> @verifier.Document {
  @verifier.Document::from_parse(
    id,
    text,
    @parser.parse(text, features=@parser.Features::reference()),
  )
}

///|
fn section_model(
  text : String,
) -> Result[@verifier.Resolution, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.resolve({ documents: [section_document("bundle.wit", text)], })
}

///|
test "nested dependency packages share one original source while retaining separate nominal owners" {
  let text = "// 😀\npackage example:root;interface api{use example:dep/api.{r as handle};read:func(x:borrow<handle>)->handle;}world app{export api;}package example:dep{interface api{resource r;}}"
  let input = section_document("bundle.wit", text)
  let model = @verifier.resolve({ documents: [input], }).unwrap()
  assert_eq(model.root().key(), "example:root")
  assert_eq(model.identities().length(), 2)
  assert_eq(model.sources().length(), 1)
  assert_eq(model.sources()[0].id, input.id)
  assert_eq(model.sources()[0].text, input.text)
  assert_eq(model.sources()[0].ast, input.ast)
  assert_eq(
    model
    .interfaces()
    .map(i => i.package_identity.key())
    .filter(k => k == "example:dep")
    .length(),
    1,
  )
  let resource = model.types().filter(t => t.kind is Resource)[0]
  assert_eq(
    model.interfaces().filter(i => i.id == resource.scope)[0].package_identity.key(),
    "example:dep",
  )
  let origin = model.origin(resource.id).unwrap()
  assert_eq(input.ast.nodes[origin.node].span, resource.location.span)
  assert_true(input.ast.nodes[origin.node].data is Resource(..))
  assert_eq(origin.location.source, "bundle.wit")
  let function = model.functions()[0]
  assert_true(
    model
    .types()
    .any(t => t.id == function.params[0].ty && t.kind == Borrow(resource.id)),
  )
  assert_true(
    model
    .types()
    .any(t => Some(t.id) == function.result && t.kind == Own(resource.id)),
  )
}

///|
test "file aliases are scoped by both package and original source" {
  let model = section_model(
    "package example:root;interface api{}use api as local;world app{import local;}package example:dep{interface api{}use api as local;world app{import local;}}",
  ).unwrap()
  assert_eq(
    model.select_world(name=Some("app")).unwrap().imports[0].name,
    "example:root/api",
  )
  assert_eq(
    model.select_world(name=Some("example:dep/app")).unwrap().imports[0].name,
    "example:dep/api",
  )
  for
    text in [
      "package example:root;interface api{}use api as local;world app{}package example:dep{world app{import local;}}",
      "package example:root;world app{import local;}package example:dep{interface api{}use api as local;world app{import local;}}",
    ] {
    assert_true(
      section_model(text) is Err(errors) &&
      errors.any(d => d.code == "WIT-S005"),
    )
  }
}

///|
test "nested packages permit transitive dependencies and forward qualified aliases" {
  let model = section_model(
    "package example:root;use example:middle/api as host;world app{import host;}package example:middle{interface api{use example:leaf/api.{r};read:func()->r;}}package example:leaf{interface api{resource r;}}",
  ).unwrap()
  assert_eq(model.identities().length(), 3)
  assert_eq(model.sources().length(), 1)
  assert_eq(model.types().filter(t => t.kind is Resource).length(), 1)
  assert_eq(model.select_world(name=Some("app")).unwrap().imports.length(), 2)
  assert_true(
    section_model(
      "package example:root;interface api{use example:dep/api.{t};}package example:dep{interface api{use example:root/api.{t};}}",
    )
    is Err(_),
  )
}

///|
test "a nested block needs a main header and cannot redefine packages or contain package blocks" {
  for
    text in [
      "package example:root{world app{}}", "package example:root;package example:dep{interface a{}}package example:dep{interface b{}}",
      "package example:root;package example:root{interface api{}}", "package example:root;package example:dep{package example:inner{interface api{}}}",
    ] {
    assert_true(section_model(text) is Err(_))
  }
  let text = "package example:root;package example:dep{interface api{}}"
  let root : @verifier.SourcePackage = {
    documents: [section_document("root.wit", text)],
  }
  let supplied : @verifier.SourcePackage = {
    documents: [
      section_document("dep.wit", "package example:dep;interface api{}"),
    ],
  }
  assert_true(
    @verifier.resolve(root, dependencies=[supplied]) is Err(errors) &&
    errors.any(d => d.code == "WIT-S011" && !d.related.is_empty()),
  )
  assert_eq(root.identity().unwrap().key(), "example:root")
}

///|
test "multi-file packages preserve nested sources once and do not leak aliases across files" {
  let a = section_document(
    "a.wit", "package example:root;interface api{}use api as local;",
  )
  let b = section_document(
    "b.wit", "world app{import api;}package example:dep{interface api{resource r;}}",
  )
  let model = @verifier.resolve({ documents: [b, a], }).unwrap()
  let again = @verifier.resolve({ documents: [a, b], }).unwrap()
  assert_eq(model.sources().length(), 2)
  assert_eq(model.types(), again.types())
  assert_eq(model.declarations(), again.declarations())
  let bad = section_document(
    "b.wit", "world app{import local;}package example:dep{interface api{}}",
  )
  assert_true(
    @verifier.resolve({ documents: [a, bad], }) is Err(errors) &&
    errors.any(d => d.code == "WIT-S005"),
  )
}

///|
test "dependency chains distinguish package blocks within one Unicode source" {
  let text = "// 😀\npackage example:root;world app{import example:dep/api;}package example:dep{interface api{type t=missing;}}"
  guard section_model(text) is Err(errors) else {
    fail("unresolved nested type accepted")
  }
  let diagnostic = errors.filter(d => d.code == "WIT-S005")[0]
  assert_eq(diagnostic.primary.location.source, "bundle.wit")
  assert_true(
    diagnostic.related.any(label => {
      label.message == "required by dependency example:root" &&
      label.location.span.start < diagnostic.primary.location.span.start
    }),
  )
  assert_true(section_model(text) is Err(again) && errors == again)
}

///|
test "caller-built overlapping package locations never invent dependency ownership" {
  let text = "package example:root;interface api{use example:dep/api.{t};type bad=missing;}package example:dep{interface api{type t=u8;}}"
  let parsed = @parser.parse(text, features=@parser.Features::reference())
  let ast : @ast.Tree = {
    nodes: parsed.ast.nodes.map(node => { ..node, span: { start: 0, end: 0, }, }),
  }
  assert_true(ast.validate())
  guard @verifier.verify_ast(ast, source=text) is Err(errors) else {
    fail("unresolved name accepted")
  }
  assert_true(errors.any(d => d.code == "WIT-S005"))
  assert_true(
    errors.all(d => {
      !d.related.any(label => label.message.has_prefix("required by dependency"))
    }),
  )
}

///|
test "large flat package-block graphs use explicit ownership and resolution stacks" {
  let source = StringBuilder()
  source.write_string(
    "package example:root;interface api{use example:p1999/api.{t};}",
  )
  source.write_string("package example:p0{interface api{resource t;}}")
  for i in 1..<2000 {
    source.write_string(
      "package example:p\{i}{interface api{use example:p\{i-1}/api.{t};}}",
    )
  }
  let text = source.to_string()
  let model = section_model(text).unwrap()
  assert_eq(model.identities().length(), 2001)
  assert_eq(model.sources().length(), 1)
  assert_eq(model.types().filter(t => t.kind is Resource).length(), 1)
  assert_eq(model.sources()[0].text, text)
}

///|
test "law: package-block declaration permutations preserve normalized worlds and nominal resources" {
  @quickcheck.check(
    (picks : Array[Byte]) => {
      let prefix = StringBuilder()
      prefix.write_string("package example:root;world app{")
      let blocks : Array[String] = []
      for i, _ in picks {
        prefix.write_string("import example:p\{i}/api;")
        blocks.push("package example:p\{i}{interface api{resource r;}}")
      }
      prefix.write_string("}")
      let first = prefix.to_string() + blocks.join("")
      let reverse = StringBuilder()
      reverse.write_string(prefix.to_string())
      for i = blocks.length() - 1; i >= 0; i = i - 1 {
        reverse.write_string(blocks[i])
      }
      guard section_model(first) is Ok(a) &&
        section_model(reverse.to_string()) is Ok(b) else {
        return false
      }
      a.world_summary() == b.world_summary() &&
      a.sources().length() == 1 &&
      b.sources().length() == 1 &&
      a.sources()[0].text == first
    },
    count=150,
    max_size=64,
    seed=262016,
  )
}
