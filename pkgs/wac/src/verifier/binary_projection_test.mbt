///|
priv enum BinaryProjectionWork {
  Text(String)
  Type(Int32)
  Item(@verifier.Extern)
  Resource(Int32)
}

///|
// Reference projections compare ordered structure, named uses, item sorts and
// nominal resource equivalence. Numeric arena IDs and transparent aliases are
// representation details and do not participate in this comparison.
fn binary_projection(model : @verifier.BinaryPackage) -> Array[String] raise {
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
fn source_projection(model : @verifier.Verified) -> Array[String] raise {
  let work : Array[BinaryProjectionWork] = []
  for i = model.exports().length() - 1; i >= 0; i = i - 1 {
    work.push(Item(model.exports()[i]))
  }
  work.push(Text(model.exports().length().to_string()))
  for i = model.imports().length() - 1; i >= 0; i = i - 1 {
    work.push(Item(model.imports()[i]))
  }
  work.push(Text(model.imports().length().to_string()))
  project_graph(model.types(), id => model.resource_identity(id), work)
}

///|
fn project_graph(
  types : ReadOnlyArray[@verifier.ResolvedType],
  resource_identity : (Int32) -> Int32?,
  work : Array[BinaryProjectionWork],
) -> Array[String] raise {
  let output : Array[String] = []
  let resources : Map[Int32, Int32] = Map([])
  let mut steps = 0
  while work.pop() is Some(current) {
    steps += 1
    assert_true(steps < 1000000)
    let next : Array[BinaryProjectionWork] = []
    match current {
      Text(text) => output.push(text)
      Resource(id) => {
        let id = resource_identity(id).unwrap()
        let ordinal = match resources.get(id) {
          Some(ordinal) => ordinal
          None => {
            let ordinal = resources.length()
            resources[id] = ordinal
            ordinal
          }
        }
        output.push(ordinal.to_string())
      }
      Item(item) => {
        output.push(item.name)
        let (sort, id) = match item.kind {
          Type(id) => ("type", id)
          Function(id) => ("func", id)
          Instance(id) => ("instance", id)
          Component(id) => ("component", id)
        }
        output.push(sort)
        next.push(Type(id))
      }
      Type(id) => {
        guard id >= 0 && id < types.length() else { fail("dangling type") }
        let kind = types[id].kind
        match kind {
          Alias(id) => next.push(Type(id))
          Scalar(name) => {
            output.push("scalar")
            output.push(name)
          }
          Resource(_) => {
            output.push("resource")
            next.push(Resource(id))
          }
          Own(id) => {
            output.push("own")
            next.push(Resource(id))
          }
          Borrow(id) => {
            output.push("borrow")
            next.push(Resource(id))
          }
          List(id) => {
            output.push("list")
            next.push(Type(id))
          }
          FixedList(id, size) => {
            output.push("fixed-list")
            output.push(size.to_string())
            next.push(Type(id))
          }
          Map(key, value) => {
            output.push("map")
            next.push(Type(key))
            next.push(Type(value))
          }
          Option(id) => {
            output.push("option")
            next.push(Type(id))
          }
          Tuple(ids) => {
            output.push("tuple")
            output.push(ids.length().to_string())
            for id in ids {
              next.push(Type(id))
            }
          }
          Result(ok, error) => {
            output.push("result")
            for value in [ok, error] {
              if value is Some(id) {
                next.push(Text("some"))
                next.push(Type(id))
              } else {
                next.push(Text("none"))
              }
            }
          }
          Future(value) | Stream(value) => {
            output.push(if kind is Future(_) { "future" } else { "stream" })
            if value is Some(id) {
              next.push(Text("some"))
              next.push(Type(id))
            } else {
              next.push(Text("none"))
            }
          }
          Record(fields) => {
            output.push("record")
            output.push(fields.length().to_string())
            for field in fields {
              next.push(Text(field.name))
              next.push(Type(field.ty))
            }
          }
          Enum(names) | Flags(names) => {
            output.push(if kind is Enum(_) { "enum" } else { "flags" })
            output.push(names.length().to_string())
            for name in names {
              output.push(name)
            }
          }
          Variant(cases) => {
            output.push("variant")
            output.push(cases.length().to_string())
            for case in cases {
              next.push(Text(case.name))
              if case.payload is Some(id) {
                next.push(Text("some"))
                next.push(Type(id))
              } else {
                next.push(Text("none"))
              }
            }
          }
          Function(params, result, is_async) => {
            output.push("function")
            output.push(is_async.to_string())
            output.push(params.length().to_string())
            for param in params {
              next.push(Text(param.name))
              next.push(Type(param.ty))
            }
            if result is Some(id) {
              next.push(Text("some"))
              next.push(Type(id))
            } else {
              next.push(Text("none"))
            }
          }
          Interface(identity, uses, exports)
          | World(identity, uses, _, exports) => {
            output.push(
              if kind is Interface(_, _, _) {
                "interface"
              } else {
                "world"
              },
            )
            output.push(identity.unwrap_or(""))
            output.push(uses.length().to_string())
            for used in uses {
              output.push(used.name)
              output.push(used.original_name)
              guard types[used.interface].kind is Interface(name, _, _) else {
                fail("invalid use owner")
              }
              output.push(name.unwrap_or(""))
            }
            if kind is World(_, _, imports, _) {
              next.push(Text(imports.length().to_string()))
              for item in imports {
                next.push(Item(item))
              }
            }
            next.push(Text(exports.length().to_string()))
            for item in exports {
              next.push(Item(item))
            }
          }
        }
      }
    }
    for i = next.length() - 1; i >= 0; i = i - 1 {
      work.push(next[i])
    }
  }
  output
}
