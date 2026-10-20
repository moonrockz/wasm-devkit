///|
priv enum SourceTypeTask {
  Text(String)
  Type(Int32)
}

///|
// Function signatures can refer to the actual source-level resource bindings.
// Keeping those references in WAC prevents signature-only packages from
// replacing the identities selected by earlier imports and instance aliases.
fn source_type(
  types : ReadOnlyArray[@verifier.ResolvedType],
  root : Int32,
  names : Map[Int32, String],
  materialize : (Int32) -> String raise Failure,
) -> String raise Failure {
  let out = StringBuilder()
  let work : Array[SourceTypeTask] = [Type(root)]
  let mut remaining = 1000000
  while work.pop() is Some(task) {
    remaining -= 1
    if remaining < 0 {
      reject("source signature exceeds its work limit")
    }
    match task {
      Text(value) => out.write_string(value)
      Type(id) => {
        if names.get(id) is Some(name) {
          out.write_string(name)
          continue
        }
        let children : Array[SourceTypeTask] = []
        match types[id].kind {
          Scalar(value) => out.write_string(value)
          Alias(next) | Resource(Some(next)) => children.push(Type(next))
          Own(next) => children.push(Type(next))
          Borrow(next) | List(next) | Option(next) => {
            let tag = match types[id].kind {
              Borrow(_) => "borrow"
              List(_) => "list"
              _ => "option"
            }
            children.append([Text(tag + "<"), Type(next), Text(">")])
          }
          Tuple(ids) => {
            children.push(Text("tuple<"))
            for i, id in ids {
              if i > 0 {
                children.push(Text(", "))
              }
              children.push(Type(id))
            }
            children.push(Text(">"))
          }
          Result(a, b) => {
            children.push(Text("result<"))
            children.push(
              match a {
                Some(id) => Type(id)
                None => Text("_")
              },
            )
            children.push(Text(", "))
            children.push(
              match b {
                Some(id) => Type(id)
                None => Text("_")
              },
            )
            children.push(Text(">"))
          }
          Future(value) | Stream(value) => {
            children.push(
              Text(
                if types[id].kind is Future(_) {
                  "future"
                } else {
                  "stream"
                },
              ),
            )
            if value is Some(id) {
              children.append([Text("<"), Type(id), Text(">")])
            }
          }
          Function(params, result, async_) => {
            children.push(Text(if async_ { "async func(" } else { "func(" }))
            for i, param in params {
              if i > 0 {
                children.push(Text(", "))
              }
              children.append([Text("%" + param.name + ": "), Type(param.ty)])
            }
            children.push(Text(")"))
            if result is Some(id) {
              children.append([Text(" -> "), Type(id)])
            }
          }
          _ => out.write_string(materialize(id))
        }
        for i = children.length() - 1; i >= 0; i = i - 1 {
          work.push(children[i])
        }
      }
    }
  }
  out.to_string()
}

///|
fn capturable_type(
  types : ReadOnlyArray[@verifier.ResolvedType],
  initial : Int32,
) -> Bool {
  let mut id = initial
  for _ in 0..<types.length() {
    match types[id].kind {
      Alias(next) | Resource(Some(next)) => id = next
      Function(_) | Interface(_) | World(_) | Module(_) => return false
      _ => return true
    }
  }
  false
}

///|
fn type_captures(
  types : ReadOnlyArray[@verifier.ResolvedType],
  names : Map[Int32, String],
  source : String,
  roots~ : ReadOnlyArray[Int32]? = None,
) -> Array[(@verifier.Extern, String)] {
  let reachable : Map[Int32, Bool] = Map([])
  if roots is Some(values) {
    let work = values.iter().to_array()
    while work.pop() is Some(id) {
      if reachable.contains(id) {
        continue
      }
      reachable[id] = true
      work.append(type_edges(types[id].kind))
    }
  }
  let ids = names.keys().to_array()
  ids.sort()
  let captures : Array[(@verifier.Extern, String)] = []
  let resources : Map[Int32, Bool] = Map([])
  let used_names : Map[String, Bool] = Map([])
  let data : Array[(@verifier.Extern, String)] = []
  for id in ids {
    if roots is Some(_) && !reachable.contains(id) {
      continue
    }
    if !capturable_type(types, id) {
      continue
    }
    let mut root = id
    for _ in 0..<types.length() {
      match types[root].kind {
        Alias(next) | Resource(Some(next)) => root = next
        _ => break
      }
    }
    if types[root].kind is Resource(None) {
      if resources.contains(root) {
        continue
      }
      resources[root] = true
      let original = types[root].name.unwrap_or("resource")
      let name = if used_names.contains(original) {
        "capture-resource-n\{root}"
      } else {
        original
      }
      used_names[name] = true
      captures.push(
        (
          {
            name,
            kind: @verifier.Type(root),
            location: @verifier.Location::binary(source),
          },
          names[id],
        ),
      )
    } else {
      data.push(
        (
          {
            name: "capture-type-n\{id}",
            kind: @verifier.Type(id),
            location: @verifier.Location::binary(source),
          },
          names[id],
        ),
      )
    }
  }
  captures.append(data)
  captures
}

///|
fn resource_base(
  types : ReadOnlyArray[@verifier.ResolvedType],
  initial : Int32,
) -> Int32? {
  let mut id = initial
  for _ in 0..<types.length() {
    match types[id].kind {
      Alias(next) | Resource(Some(next)) => id = next
      Resource(None) => return Some(id)
      _ => return None
    }
  }
  None
}
