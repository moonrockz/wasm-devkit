///|
// Compare public contracts and nominal equivalence, not source-oriented arena
// IDs, private anonymous nodes, documentation text or provenance coordinates.
priv enum ModelProjectionWork {
  Text(String)
  Value(Int32)
  Definition(Int32)
  Interface(Int32)
  World(@verifier.ResolvedWorld)
  Function(@verifier.ResolvedFunction)
  Extern(@verifier.WorldItem)
}

///|
fn projection_identity(
  identity : @verifier.PackageIdentity,
  name : String,
) -> String {
  identity.namespace_name +
  ":" +
  identity.name +
  "/" +
  name +
  identity.version.map(version => "@" + version).unwrap_or("")
}

///|
fn projection_metadata(
  work : Array[ModelProjectionWork],
  stability : @verifier.Stability,
  external : String?,
) -> Unit {
  work.push(Text(external.unwrap_or("")))
  match stability {
    Unknown => work.push(Text("unknown"))
    Stable(since, deprecated) => {
      work.push(Text("stable"))
      work.push(Text(since))
      work.push(Text(deprecated.unwrap_or("")))
    }
    Unstable(feature, deprecated) => {
      work.push(Text("unstable"))
      work.push(Text(feature))
      work.push(Text(deprecated.unwrap_or("")))
    }
  }
}

///|
fn projection_optional(work : Array[ModelProjectionWork], id : Int32?) -> Unit {
  match id {
    None => work.push(Text("none"))
    Some(id) => {
      work.push(Text("some"))
      work.push(Value(id))
    }
  }
}

///|
fn projection_resource(
  types : Map[Int32, @verifier.ResolvedType],
  initial : Int32,
  resources : Map[Int32, Int32],
) -> String raise {
  let mut id = initial
  for _ in 0..<types.length() {
    match types[id].kind {
      Alias(next) => id = next
      Resource => {
        let ordinal = resources
          .get(id)
          .unwrap_or_else(() => {
            let ordinal = resources.length()
            resources[id] = ordinal
            ordinal
          })
        return ordinal.to_string()
      }
      _ => fail("non-resource nominal target")
    }
  }
  fail("cyclic nominal target")
}

///|
fn model_projection(model : @verifier.Resolution) -> Array[String] raise {
  let types : Map[Int32, @verifier.ResolvedType] = Map([])
  let interfaces : Map[Int32, @verifier.ResolvedInterface] = Map([])
  let functions : Map[Int32, @verifier.ResolvedFunction] = Map([])
  for ty in model.types() {
    types[ty.id] = ty
  }
  for iface in model.interfaces() {
    interfaces[iface.id] = iface
  }
  for function in model.functions() {
    functions[function.id] = function
  }
  let packages = model
    .identities()
    .map(identity => identity.key())
    .iter()
    .to_array()
  packages.sort_by((a, b) => a.lexical_compare(b))
  let roots = model
    .interfaces()
    .filter(iface => iface.name is Some(_))
    .iter()
    .to_array()
  roots.sort_by((a, b) => {
    projection_identity(a.package_identity, a.name.unwrap()).lexical_compare(
      projection_identity(b.package_identity, b.name.unwrap()),
    )
  })
  let worlds = model.worlds().iter().to_array()
  worlds.sort_by((a, b) => {
    projection_identity(a.package_identity, a.name).lexical_compare(
      projection_identity(b.package_identity, b.name),
    )
  })
  let todo : Array[ModelProjectionWork] = [
    Text("packages"),
    Text(packages.length().to_string()),
  ]
  for key in packages {
    todo.push(Text(key))
  }
  todo.push(Text("interfaces"))
  todo.push(Text(roots.length().to_string()))
  for iface in roots {
    todo.push(Interface(iface.id))
  }
  todo.push(Text("worlds"))
  todo.push(Text(worlds.length().to_string()))
  for world in worlds {
    todo.push(World(world))
  }
  let work = todo.rev()
  let output = []
  let resources : Map[Int32, Int32] = Map([])
  let mut steps = 0
  while work.pop() is Some(current) {
    steps += 1
    assert_true(steps < 1000000)
    let next : Array[ModelProjectionWork] = []
    match current {
      Text(value) => output.push(value)
      Value(id) => {
        let kind = types[id].kind
        match kind {
          Alias(target) => next.push(Value(target))
          Scalar(name) => {
            next.push(Text("scalar"))
            next.push(Text(name))
          }
          Resource => {
            next.push(Text("resource"))
            next.push(Text(projection_resource(types, id, resources)))
          }
          Own(target) | Borrow(target) => {
            next.push(Text(if kind is Own(_) { "own" } else { "borrow" }))
            next.push(Text(projection_resource(types, target, resources)))
          }
          List(element, None) => {
            next.push(Text("list"))
            next.push(Value(element))
          }
          List(element, Some(length)) => {
            next.push(Text("fixed-list"))
            next.push(Text(length.to_string()))
            next.push(Value(element))
          }
          Option(element) => {
            next.push(Text("option"))
            next.push(Value(element))
          }
          Future(element) | Stream(element) => {
            next.push(Text(if kind is Future(_) { "future" } else { "stream" }))
            projection_optional(next, element)
          }
          Result(ok, error) => {
            next.push(Text("result"))
            projection_optional(next, ok)
            projection_optional(next, error)
          }
          Map(key, value) => {
            next.push(Text("map"))
            next.push(Value(key))
            next.push(Value(value))
          }
          Tuple(elements) => {
            next.push(Text("tuple"))
            next.push(Text(elements.length().to_string()))
            for element in elements {
              next.push(Value(element))
            }
          }
          Record(fields) => {
            next.push(Text("record"))
            next.push(Text(fields.length().to_string()))
            for field in fields {
              next.push(Text(field.name))
              next.push(Value(field.ty))
            }
          }
          Flags(names) | Enum(names) => {
            next.push(Text(if kind is Flags(_) { "flags" } else { "enum" }))
            next.push(Text(names.length().to_string()))
            for name in names {
              next.push(Text(name))
            }
          }
          Variant(cases) => {
            next.push(Text("variant"))
            next.push(Text(cases.length().to_string()))
            for c in cases {
              next.push(Text(c.name))
              projection_optional(next, c.payload)
            }
          }
        }
      }
      Definition(id) => {
        let ty = types[id]
        projection_metadata(next, ty.stability, ty.external_id)
        next.push(Value(id))
      }
      Function(function) => {
        next.push(Text(function.name))
        projection_metadata(next, function.stability, function.external_id)
        let (kind, owner) = match function.kind {
          Freestanding => ("freestanding", None)
          Method(id) => ("method", Some(id))
          Static(id) => ("static", Some(id))
          Constructor(id) => ("constructor", Some(id))
        }
        next.push(Text(kind))
        next.push(
          Text(
            match function.flavor {
              Plain => "plain"
              Getter => "get"
              Setter => "set"
            },
          ),
        )
        next.push(Text(function.asynchronous.to_string()))
        if owner is Some(id) {
          next.push(Text("resource"))
          next.push(Text(projection_resource(types, id, resources)))
        }
        next.push(Text(function.params.length().to_string()))
        for param in function.params {
          next.push(Text(param.name))
          next.push(Value(param.ty))
        }
        projection_optional(next, function.result)
      }
      Interface(id) => {
        let iface = interfaces[id]
        next.push(Text("interface"))
        next.push(
          Text(
            iface.name
            .map(name => projection_identity(iface.package_identity, name))
            .unwrap_or(""),
          ),
        )
        projection_metadata(next, iface.stability, None)
        let entries = iface.types.iter().to_array()
        entries.sort_by((a, b) => a.name.lexical_compare(b.name))
        next.push(Text(entries.length().to_string()))
        for entry in entries {
          next.push(Text(entry.name))
          next.push(Definition(entry.ty))
        }
        let funcs = iface.functions.iter().to_array()
        funcs.sort_by((a, b) => a.name.lexical_compare(b.name))
        next.push(Text(funcs.length().to_string()))
        for function in funcs {
          next.push(Function(function))
        }
      }
      World(world) => {
        next.push(Text("world"))
        next.push(Text(projection_identity(world.package_identity, world.name)))
        projection_metadata(next, world.stability, None)
        for
          (side, items) in [
            ("imports", world.imports),
            ("exports", world.exports),
          ] {
          let entries = items.iter().to_array()
          entries.sort_by((a, b) => {
            let order = a.name.lexical_compare(b.name)
            if order != 0 {
              order
            } else {
              a.by_id.compare(b.by_id)
            }
          })
          next.push(Text(side))
          next.push(Text(entries.length().to_string()))
          for entry in entries {
            next.push(Extern(entry))
          }
        }
      }
      Extern(entry) => {
        next.push(Text(entry.name))
        next.push(Text(entry.by_id.to_string()))
        match entry.kind {
          Interface(id) => {
            next.push(Text("interface"))
            projection_metadata(next, entry.stability, entry.external_id)
            next.push(Interface(id))
          }
          Function(id) => {
            next.push(Text("function"))
            next.push(Function(functions[id]))
          }
          Type(id) => {
            next.push(Text("type"))
            next.push(Definition(id))
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
