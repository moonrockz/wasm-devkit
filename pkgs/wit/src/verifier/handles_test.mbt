///|
fn handle_model(
  text : String,
) -> Result[@verifier.Verified, ReadOnlyArray[@verifier.Diagnostic]] {
  @verifier.verify(
    @parser.parse(text, features=@parser.Features::reference()),
    source=text,
    source_id="handles.wit",
  )
}

///|
test "resource aliases stay nominal while value positions become owned handles" {
  let source = "package example:app; interface api {type a=r;type b=a;resource r;record data{value:b} f:func(x:b,y:own<a>,z:borrow<b>)->r;}"
  let model = handle_model(source).unwrap()
  let types = model.types()
  let resource = types.filter(t => t.kind is Resource)[0].id
  let a = types.filter(t => t.name == Some("a"))[0]
  assert_true(a.kind is Alias(_))
  let function = model.functions()[0]
  for param in function.params[0:2] {
    assert_true(types.any(t => t.id == param.ty && t.kind == Own(resource)))
  }
  assert_true(
    types.any(t => t.id == function.params[2].ty && t.kind == Borrow(resource)),
  )
  assert_true(
    types.any(t => Some(t.id) == function.result && t.kind == Own(resource)),
  )
  guard types.filter(t => t.name == Some("data"))[0].kind is Record(fields) else {
    fail("missing record")
  }
  assert_true(types.any(t => t.id == fields[0].ty && t.kind == Own(resource)))
  assert_eq(model.text(), source)
  assert_eq(handle_model(source).unwrap().types(), types)
}

///|
test "handle targets reject scalars composites and aliases to handles" {
  for
    body in [
      "type t=u8;f:func(x:own<t>);", "record t{value:u8}f:func(x:borrow<t>);", "resource r;type t=own<r>;f:func(x:own<t>);",
      "resource r;type t=borrow<r>;f:func(x:borrow<t>);", "resource r;type t=option<r>;f:func(x:own<t>);",
    ] {
    let source = "package example:app;interface api{" + body + "}"
    guard handle_model(source) is Err(errors) else {
      fail("invalid handle accepted")
    }
    assert_eq(errors[0].code, "WIT-S007")
    assert_true(errors[0].primary.message.contains("resource"))
  }
  assert_true(
    handle_model("package example:app;interface api{type a=own<a>;}")
    is Err(errors) &&
    errors.any(d => d.code == "WIT-S006"),
  )
}

///|
test "borrowed handles are allowed in parameters and unused aliases but never results" {
  for
    ty in [
      "borrow<r>", "list<option<borrow<r>>>", "future<borrow<r>>", "stream<borrow<r>>",
      "tuple<u8,borrow<r>>", "result<_,borrow<r>>", "map<string,borrow<r>>", "record-data",
      "variant-data",
    ] {
    let prefix = "package example:app;interface api{resource r;record record-data{value:borrow<r>}variant variant-data{empty,value(borrow<r>)}type a=" +
      ty +
      ";type b=a;"
    assert_true(handle_model(prefix + "}") is Ok(_))
    assert_true(handle_model(prefix + "f:func(x:b);}") is Ok(_))
    guard handle_model(prefix + "f:func()->b;}") is Err(errors) else {
      fail("borrowed result accepted")
    }
    assert_eq(errors[0].code, "WIT-S007")
    assert_eq(errors[0].related.length(), 1)
    assert_eq(errors[0].related[0].location.source, "handles.wit")
  }
}

///|
test "handle and borrow analysis use bounded stacks on deep shared type graphs" {
  let source = StringBuilder()
  source.write_string(
    "package example:app;interface api{resource r;type a0=borrow<r>;",
  )
  for i in 1..<5000 {
    source.write_string("type a\{i}=tuple<a\{i-1},a\{i-1}>;")
  }
  source.write_string("f:func(x:a4999);}")
  let text = source.to_string()
  assert_true(handle_model(text) is Ok(_))
  let result = text.replace(old="f:func(x:a4999);", new="f:func()->a4999;")
  assert_true(handle_model(result) is Err(errors) && errors.length() == 1)
}

///|
test "included world handles freshen local resources and retain named interface resources" {
  let model = handle_model(
    "package example:app;interface api{resource external;}world base{use api.{external};resource r;import f:func(x:own<r>,y:borrow<external>)->r;}world app{include base;}",
  ).unwrap()
  let functions = model.functions()
  assert_eq(functions.length(), 2)
  let original = functions[0]
  let copied = functions[1]
  let types = model.types()
  let own = types.filter(t => t.id == original.params[0].ty)[0].kind
  let copied_own = types.filter(t => t.id == copied.params[0].ty)[0].kind
  assert_false(own == copied_own)
  assert_true(own is Own(_) && copied_own is Own(_))
  let borrow = types.filter(t => t.id == original.params[1].ty)[0].kind
  let copied_borrow = types.filter(t => t.id == copied.params[1].ty)[0].kind
  assert_eq(borrow, copied_borrow)
  assert_true(borrow is Borrow(_))
  assert_eq(types.filter(t => t.kind is Resource).length(), 3)
}

///|
test "borrowed dependency results retain both source-qualified diagnostic locations" {
  let root = "package example:app;interface api{use example:dep/types.{handle};f:func()->handle;}"
  let dep = "package example:dep;interface types{resource r;type handle=borrow<r>;}"
  let result = @verifier.resolve(
    {
      documents: [
        @verifier.Document::from_parse("root.wit", root, @parser.parse(root)),
      ],
    },
    dependencies=[
      {
        documents: [
          @verifier.Document::from_parse("dep.wit", dep, @parser.parse(dep)),
        ],
      },
    ],
  )
  guard result is Err(errors) else {
    fail("borrowed dependency result accepted")
  }
  assert_eq(errors[0].code, "WIT-S007")
  assert_eq(errors[0].primary.location.source, "root.wit")
  assert_true(
    errors[0].related.any(label => label.location.source == "dep.wit"),
  )
}

///|
test "caller-built handle targets require named resource syntax" {
  let text = "package example:app;interface api{resource r;f:func(x:own<r>);}"
  let parsed = @parser.parse(text)
  let ast : @ast.Tree = {
    nodes: parsed.ast.nodes.map(node => {
      if node.data is NamedType(..) {
        { ..node, data: PrimitiveType(name="u8"), }
      } else {
        node
      }
    }),
  }
  assert_true(ast.validate())
  assert_true(
    @verifier.verify_ast(ast, source=text) is Err(errors) &&
    errors.any(d => d.code == "WIT-S001"),
  )
}

///|
test "law: generated resource alias graphs resolve every handle to a nominal resource" {
  @quickcheck.check(
    (picks : Array[Byte]) => {
      let source = StringBuilder()
      source.write_string(
        "package example:app;interface api{resource r;resource s;type a0=r;type a1=s;",
      )
      for i, pick in picks {
        source.write_string("type a\{i+2}=a\{pick.to_int() % (i+2)};")
      }
      source.write_string("f:func(")
      for i, pick in picks {
        let name = "a\{i+2}"
        let ty = match pick.to_int() % 3 {
          0 => name
          1 => "own<" + name + ">"
          _ => "borrow<" + name + ">"
        }
        source.write_string("p\{i}:" + ty + ",")
      }
      source.write_string(");}")
      let text = source.to_string()
      guard handle_model(text) is Ok(model) else { return false }
      let types = model.types()
      let resources = types.filter(t => t.kind is Resource).map(t => t.id)
      resources.length() == 2 &&
      types.all(t => {
        match t.kind {
          Own(id) | Borrow(id) => resources.contains(id)
          _ => true
        }
      }) &&
      handle_model(text) is Ok(again) &&
      again.types() == types
    },
    count=200,
    max_size=128,
    seed=262014,
  )
}
