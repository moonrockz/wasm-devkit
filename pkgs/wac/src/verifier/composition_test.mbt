///|
fn composition_projection(model : @verifier.Verified) -> Array[String] raise {
  let work : Array[BinaryProjectionWork] = [Text("0")]
  let nodes = model.composition()
  for i = nodes.length() - 1; i >= 0; i = i - 1 {
    let node = nodes[i]
    assert_eq(node.id, i)
    let name = match node.operation {
      Definition => "definition"
      Import(name) => "import:" + name
      Instantiate(name, version, _) =>
        "instance:" + name + version.map(value => "@" + value).unwrap_or("")
      Access(instance, name) => {
        assert_true(instance < i)
        "alias:" + instance.to_string() + ":" + name
      }
    }
    work.push(Item({ name, kind: node.kind, location: node.location, }))
  }
  work.push(Text(nodes.length().to_string()))
  project_graph(model.types(), id => model.resource_identity(id), work)
}

///|
test "composition aliases are cached and exports retain ordered graph edges" {
  let source = "package test:app; interface api { run: func(); } import i: api; let a = i.run; let b = (i).run; export a as first; export b as second;"
  let model = @verifier.verify(
    @parser.parse(source),
    source~,
    source_id="graph.wac",
  ).unwrap()
  assert_eq(model.composition().length(), 3)
  assert_true(model.composition()[0].operation is Definition)
  assert_true(model.composition()[1].operation is Import("i"))
  assert_true(model.composition()[2].operation is Access(1, "run"))
  assert_eq(model.composition_exports().map(item => item.name), [
    "api", "first", "second",
  ])
  assert_eq(model.composition_exports().map(item => item.value), [0, 2, 2])
  assert_true(
    model.composition().all(node => node.location.source == "graph.wac"),
  )
  let changed = model.composition().map(node => { ..node, id: -1, })
  assert_eq(changed[0].id, -1)
  assert_eq(model.composition()[0].id, 0)
}

///|
fn composition_edges(model : @verifier.Verified) -> Array[String] {
  let edges : Array[String] = []
  for node in model.composition() {
    match node.operation {
      Access(source, name) => {
        edges.push(node.id.to_string())
        edges.push("alias")
        edges.push(source.to_string())
        edges.push(name)
      }
      Instantiate(_, _, arguments) => {
        let names : Array[String] = []
        for argument in arguments {
          names.push(argument.name)
        }
        names.sort_by((a, b) => a.lexical_compare(b))
        for name in names {
          for argument in arguments {
            if argument.name == name {
              edges.push(node.id.to_string())
              edges.push(name)
              edges.push(argument.value.to_string())
            }
          }
        }
      }
      _ => ()
    }
  }
  edges
}
