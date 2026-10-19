///|
/// Semantic selection is independent of syntax extensions. Names match exactly.
pub(all) struct SemanticFeatures {
  enabled : ReadOnlyArray[String]
  all_enabled : Bool
} derive(Eq, Debug)

///|
pub fn SemanticFeatures::default() -> SemanticFeatures {
  { enabled: [], all_enabled: false, }
}

///|
pub fn SemanticFeatures::all() -> SemanticFeatures {
  { enabled: [], all_enabled: true, }
}

///|
fn SemanticFeatures::includes(
  self : SemanticFeatures,
  stability : Stability,
) -> Bool {
  match stability {
    Unstable(feature, _) => self.all_enabled || self.enabled.contains(feature)
    _ => true
  }
}

///|
priv struct Selection {
  nodes : ReadOnlyArray[Bool]
  functions : ReadOnlyArray[Bool]
  types : ReadOnlyArray[Bool]
  features : SemanticFeatures
}

///|
fn unavailable(
  prepared : Prepared,
  arena : SemanticArena,
  at : Int32,
  target : Int32,
) -> Diagnostic {
  let d = prepared_error(
    prepared, at, "WIT-S013", "reference to a declaration excluded by semantic feature selection",
  )
  {
    ..d,
    related: [
      {
        location: arena.origins[target].location,
        message: "excluded declaration",
      },
    ],
  }
}

///|
fn select_features(
  prepared : Prepared,
  arena : SemanticArena,
  infos : ReadOnlyArray[StabilityInfo],
  references : Map[Int32, Int32],
  features : SemanticFeatures,
  foreign_versions : ReadOnlyArray[Bool],
  errors : Array[Diagnostic],
) -> Selection {
  let tree = prepared.tree
  let owners = lexical_owners(tree)
  let nodes = infos.map(info => features.includes(info.value)).iter().to_array()
  let functions = Array::make(tree.nodes.length(), false)
  let relevant = Array::make(tree.nodes.length(), false)
  for id, node in tree.nodes {
    let owner_active = owners[id] < 0 || nodes[owners[id]]
    match node.data {
      Interface(..) | World(..) => relevant[id] = true
      Function(signature~, ..) => {
        relevant[id] = owner_active
        relevant[signature] = owner_active
        functions[signature] = owner_active && nodes[id]
        nodes[id] = functions[signature]
        nodes[signature] = functions[signature]
      }
      Constructor(..) => {
        relevant[id] = owner_active
        functions[id] = owner_active && nodes[id]
        nodes[id] = functions[id]
      }
      Import(target~, ..) | Export(target~, ..) => {
        relevant[id] = owner_active
        if tree.nodes[target].data is Signature(..) {
          relevant[target] = owner_active
          functions[target] = owner_active && nodes[id]
          nodes[target] = functions[target]
        }
        nodes[id] = owner_active && nodes[id]
      }
      Include(..) => {
        relevant[id] = owner_active
        nodes[id] = owner_active && nodes[id]
      }
      _ =>
        if type_declaration(node.data) || node.data is Rename(..) {
          relevant[id] = true
        }
    }
  }
  for id in 0..<relevant.length() {
    relevant[id] = relevant[id] || foreign_versions[id]
  }
  verify_stable_versions(
    prepared,
    infos,
    ReadOnlyArray::from_array(relevant),
    errors,
  )
  let selected_types = Array::make(arena.origins.length(), false)
  let witnesses = Array::make(arena.origins.length(), -2)
  for id in arena.type_order {
    selected_types[id] = features.includes(arena.types[id].stability)
  }
  // Every graph edge is visited once. Bridge nodes used by the source-backed
  // public graph propagate availability without becoming extra global checks.
  for start in arena.type_order {
    let pending = [(start, false)]
    while pending.pop() is Some((id, leaving)) {
      if witnesses[id] != -2 {
        continue
      }
      if !selected_types[id] {
        witnesses[id] = id
        continue
      }
      let ty = arena.types[id]
      let children : ReadOnlyArray[Int32] = if id < tree.nodes.length() {
        match tree.nodes[id].data {
          NamedType(..) =>
            match references.get(id) {
              Some(target) => [target]
              None => []
            }
          OwnType(resource~) | BorrowType(resource~) => [resource]
          _ => kind_children(ty.kind)
        }
      } else {
        kind_children(ty.kind)
      }
      if !leaving {
        pending.push((id, true))
        for child in children {
          pending.push((child, false))
        }
      } else {
        witnesses[id] = -1
        for child in children {
          if witnesses[child] >= 0 {
            witnesses[id] = witnesses[child]
            break
          }
        }
      }
    }
  }
  for id in arena.type_order {
    let ty = arena.types[id]
    let real = if id < tree.nodes.length() {
      match tree.nodes[id].data {
        PrimitiveType(..) | NamedType(..) | OwnType(..) => false
        _ => true
      }
    } else {
      false
    }
    if selected_types[id] && real && witnesses[id] >= 0 {
      errors.push(unavailable(prepared, arena, id, witnesses[id]))
    }
    if ty.name is Some(_) &&
      selected_types[id] &&
      ty.scope >= 0 &&
      !nodes[ty.scope] {
      errors.push(unavailable(prepared, arena, id, ty.scope))
    }
    selected_types[id] = selected_types[id] && witnesses[id] < 0
    if id < nodes.length() && arena.types[id].name is Some(_) {
      nodes[id] = selected_types[id]
    }
  }
  for id in arena.function_order {
    if id >= functions.length() || !functions[id] {
      continue
    }
    let function = arena.functions[id]
    let roots = function.params.map(p => p.ty).iter().to_array()
    if function.result is Some(result) {
      roots.push(result)
    }
    match function.kind {
      Method(resource) | Static(resource) | Constructor(resource) =>
        roots.push(resource)
      Freestanding => ()
    }
    for root in roots {
      if witnesses[root] >= 0 {
        errors.push(unavailable(prepared, arena, id, witnesses[root]))
      }
    }
  }
  for id, node in tree.nodes {
    if node.data is Use(path~, names~, ..) {
      nodes[path] = nodes[id] && names.any(selector => selected_types[selector])
    }
  }
  let types = ReadOnlyArray::from_array(selected_types)
  let selected_functions = arena.function_order.filter(id => {
    id < functions.length() && functions[id]
  })
  let selected_interfaces = arena.interface_order.filter(id => nodes[id])
  for id in selected_interfaces {
    let interface_ = arena.interfaces[id]
    arena.interfaces[id] = {
      ..interface_,
      types: interface_.types.filter(t => types[t.ty]),
      functions: interface_.functions.filter(f => functions[f.id]),
    }
  }
  let selected_order = arena.type_order.filter(id => types[id])
  arena.type_order.clear()
  arena.type_order.append(selected_order)
  arena.function_order.clear()
  arena.function_order.append(selected_functions)
  arena.interface_order.clear()
  arena.interface_order.append(selected_interfaces)
  {
    nodes: ReadOnlyArray::from_array(nodes),
    functions: ReadOnlyArray::from_array(functions),
    types,
    features,
  }
}

///|
fn filter_world_items(
  prepared : Prepared,
  arena : SemanticArena,
  tables : WorldTables,
  selection : Selection,
  errors : Array[Diagnostic],
) -> Unit {
  for id, node in prepared.tree.nodes {
    if !(node.data is World(..)) {
      continue
    }
    for imported in [true, false] {
      let originals = if imported {
        tables.imports[id]
      } else {
        tables.exports[id]
      }
      let items = originals.filter(item => {
        if !selection.nodes[id] {
          return false
        }
        match item.kind {
          Type(ty) => {
            if !selection.types[ty] {
              errors.push(unavailable(prepared, arena, id, ty))
            }
            selection.types[ty]
          }
          Function(function) => selection.functions[function]
          Interface(interface_) => {
            let enabled = selection.features.includes(item.stability)
            if enabled && !selection.nodes[interface_] {
              errors.push(unavailable(prepared, arena, id, interface_))
            }
            enabled && selection.nodes[interface_]
          }
        }
      })
      let names : Map[String, WorldItem] = Map([])
      for item in items {
        names[world_key(item)] = item
      }
      if imported {
        tables.imports[id] = items
        tables.import_names[id] = names
      } else {
        tables.exports[id] = items
        tables.export_names[id] = names
      }
    }
    tables.uses[id] = tables.uses[id].filter(entry => selection.nodes[entry.1])
  }
}

///|
pub extend SemanticFeatures with Eq::{equal, not_equal}

///|
pub extend SemanticFeatures with @debug.Debug::{to_repr}
