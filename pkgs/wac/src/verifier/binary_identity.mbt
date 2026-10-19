///|
// WAC converts root imports before exports and caches each nongeneric type.
// Its first conversion determines the optional interface/world identity. Binary
// declaration order, including unused templates, must not choose that name.
fn BinaryGraph::assign_identities(
  self : BinaryGraph,
  root : Int32,
) -> Unit raise BinaryFailure {
  let seen : Map[Int32, Bool] = Map([])
  let work : Array[(Int32, String?)] = [(root, None)]
  while work.pop() is Some((id, name)) {
    self.step()
    let id = self.follow(id)
    if seen.contains(id) {
      continue
    }
    seen[id] = true
    let kind = self.types[id].kind
    let identity = match name {
      Some(name) if name.contains(":") => Some(name)
      _ => None
    }
    let items : Array[(Extern, Bool)] = []
    match kind {
      Interface(_, uses, exports) => {
        self.types[id] = {
          ..self.types[id],
          kind: Interface(identity, uses, exports),
        }
        for item in exports {
          items.push((item, false))
        }
      }
      World(_, uses, imports, exports) => {
        self.types[id] = {
          ..self.types[id],
          kind: World(identity, uses, imports, exports),
        }
        for item in imports {
          items.push((item, true))
        }
        for item in exports {
          items.push((item, false))
        }
      }
      _ => {
        let children = binary_children(kind)
        for i = children.length() - 1; i >= 0; i = i - 1 {
          work.push((children[i], None))
        }
      }
    }
    for i = items.length() - 1; i >= 0; i = i - 1 {
      let (item, importing) = items[i]
      let name = match item.kind {
        Instance(_) => {
          let implemented = if importing {
            match self.implements_names.get(id) {
              Some(names) => names.get(item.name)
              None => None
            }
          } else {
            None
          }
          Some(implemented.unwrap_or(item.name))
        }
        Component(_) => Some(item.name)
        _ => None
      }
      work.push((binary_kind_id(item.kind), name))
    }
  }
}
