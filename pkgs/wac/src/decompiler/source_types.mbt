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
          Own(next) | Borrow(next) | List(next) | Option(next) => {
            let tag = match types[id].kind {
              Own(_) => "own"
              Borrow(_) => "borrow"
              List(_) => "list"
              _ => "option"
            }
            children.append([Text(tag + "<"), Type(next), Text(">")])
          }
          FixedList(next, size) =>
            children.append([
              Text("list<"),
              Type(next),
              Text(", " + size.to_string() + ">"),
            ])
          Map(a, b) =>
            children.append([
              Text("map<"),
              Type(a),
              Text(", "),
              Type(b),
              Text(">"),
            ])
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
