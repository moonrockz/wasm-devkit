///|
// Scope IDs and type IDs never escape the decoder. Each physical declaration has
// one identity; aliases retain edges instead of copying structural definitions.
priv enum EncodedNode {
  Value(@component.TypeDef, Int32)
  Link(Int32)
  Resource
  Scope(Int32)
}

///|
priv enum EncodedItem {
  TypeItem(String, Int32, Bool)
  FunctionItem(String, Int32, Bool)
  InstanceItem(String, Int32, Bool)
  WorldItem(String, Int32)
}

///|
priv struct EncodedScope {
  interface_scope : Bool
  parent : Int32?
  declarations : Array[@component.ComponentDecl]
  types : Array[Int32]
  instances : Array[Int32]
  items : Array[EncodedItem]
  exported_types : Map[String, Int32]
  exported_functions : Map[String, Bool]
}

///|
priv struct EncodedGraph {
  mut remaining : Int32
  node_scopes : Array[Int32]
  nodes : Array[EncodedNode]
  scopes : Array[EncodedScope]
  bindings : Map[Int32, Int32]
}

///|
fn encoded_graph_step(graph : EncodedGraph) -> Unit raise EncodedFailure {
  guard graph.remaining > 0 else {
    raise Unsupported("encoded scope graph exceeds the decoding work limit")
  }
  graph.remaining -= 1
}

///|
fn encoded_graph_scope(
  graph : EncodedGraph,
  parent : Int32?,
  definition : @component.TypeDef,
) -> Int32 raise EncodedFailure {
  let declarations = match definition {
    ComponentType(declarations) => declarations
    InstanceType(declarations) =>
      declarations.map(declaration => {
        match declaration {
          Type(value) => @component.ComponentDecl::Type(value)
          Export(name, attributes, desc) => Export(name, attributes, desc)
          AliasOuter(kind, count, index) => AliasOuter(kind, count, index)
          AliasInstanceExport(kind, instance, name) =>
            AliasInstanceExport(kind, instance, name)
          CoreType(bytes) => CoreType(bytes)
        }
      })
    InstanceTypeEmpty => []
    _ => raise Invalid("expected an encoded type scope")
  }
  let id = graph.scopes.length()
  graph.scopes.push({
    interface_scope: definition is InstanceType(_) ||
    definition is InstanceTypeEmpty,
    parent,
    declarations,
    types: [],
    instances: [],
    items: [],
    exported_types: Map([]),
    exported_functions: Map([]),
  })
  id
}

///|
fn encoded_graph_index(
  graph : EncodedGraph,
  scope : Int32,
  index : Int32,
) -> Int32 raise EncodedFailure {
  let types = graph.scopes[scope].types
  guard index >= 0 && index < types.length() else {
    raise Invalid("component type index is outside its scope")
  }
  types[index]
}

///|
fn encoded_graph_node(
  graph : EncodedGraph,
  scope : Int32,
  node : EncodedNode,
) -> Int32 {
  let id = graph.nodes.length()
  graph.nodes.push(node)
  graph.node_scopes.push(scope)
  graph.scopes[scope].types.push(id)
  id
}

///|
fn encoded_graph_follow(
  graph : EncodedGraph,
  id : Int32,
) -> Int32 raise EncodedFailure {
  let mut id = id
  let mut steps = 0
  while graph.bindings.get(id) is Some(next) {
    encoded_graph_step(graph)
    steps += 1
    guard steps <= graph.nodes.length() else {
      raise Invalid("cyclic encoded type binding")
    }
    id = next
  }
  id
}

///|
fn encoded_graph_scope_type(
  graph : EncodedGraph,
  scope : Int32,
  index : Int32,
) -> Int32 raise EncodedFailure {
  let mut id = encoded_graph_index(graph, scope, index)
  for _ in 0..<=graph.nodes.length() {
    encoded_graph_step(graph)
    match graph.nodes[id] {
      Scope(scope) => return scope
      Link(target) => id = target
      _ => raise Invalid("component reference is not a type scope")
    }
  }
  raise Invalid("cyclic component scope alias")
}

///|
fn encoded_graph(
  definition : @component.TypeDef,
) -> EncodedGraph raise EncodedFailure {
  let graph : EncodedGraph = {
    remaining: 1000000,
    node_scopes: [],
    nodes: [],
    scopes: [],
    bindings: Map([]),
  }
  ignore(encoded_graph_scope(graph, None, definition))
  let work : Array[(Int32, Int32)] = [(0, 0)]
  while work.pop() is Some((scope, position)) {
    encoded_graph_step(graph)
    let current = graph.scopes[scope]
    if position >= current.declarations.length() {
      continue
    }
    work.push((scope, position + 1))
    match current.declarations[position] {
      Type(definition) =>
        match definition {
          ComponentType(_) | InstanceType(_) | InstanceTypeEmpty => {
            let child = encoded_graph_scope(graph, Some(scope), definition)
            ignore(encoded_graph_node(graph, scope, Scope(child)))
            work.push((child, 0))
          }
          _ =>
            ignore(encoded_graph_node(graph, scope, Value(definition, scope)))
        }
      AliasOuter(kind, count, index) => {
        guard kind == 3 && count >= 0 else {
          raise Unsupported("non-type outer alias")
        }
        let mut outer = scope
        for _ in 0..<count {
          guard graph.scopes[outer].parent is Some(parent) else {
            raise Invalid("outer alias exceeds lexical scopes")
          }
          outer = parent
        }
        current.types.push(encoded_graph_index(graph, outer, index))
      }
      AliasInstanceExport(kind, instance, name) => {
        guard kind == 3 else {
          raise Unsupported("non-type instance export alias")
        }
        guard instance >= 0 && instance < current.instances.length() else {
          raise Invalid("instance alias index is outside its scope")
        }
        let target = graph.scopes[current.instances[instance]].exported_types.get(
          name,
        )
        guard target is Some(id) else {
          raise Invalid("instance alias references a missing type")
        }
        current.types.push(id)
      }
      Import(name, attributes, desc) | Export(name, attributes, desc) => {
        guard attributes.is_empty() else {
          raise Unsupported("encoded name attributes")
        }
        let imported = current.declarations[position] is Import(_, _, _)
        match desc {
          Type(Eq(index)) => {
            let target = encoded_graph_index(graph, scope, index)
            let id = encoded_graph_node(graph, scope, Link(target))
            current.items.push(TypeItem(name, id, imported))
            if !imported {
              current.exported_types[name] = id
            }
          }
          Type(SubResource) => {
            let id = encoded_graph_node(graph, scope, Resource)
            current.items.push(TypeItem(name, id, imported))
            if !imported {
              current.exported_types[name] = id
            }
          }
          FuncType(index) => {
            current.items.push(
              FunctionItem(
                name,
                encoded_graph_index(graph, scope, index),
                imported,
              ),
            )
            if !imported {
              current.exported_functions[name] = true
            }
          }
          InstanceType(index) => {
            let template = encoded_graph_scope_type(graph, scope, index)
            let child = encoded_graph_instance(graph, template)
            current.instances.push(child)
            current.items.push(InstanceItem(name, child, imported))
          }
          ComponentType(index) => {
            guard !imported else {
              raise Unsupported("imported component type")
            }
            current.items.push(
              WorldItem(name, encoded_graph_scope_type(graph, scope, index)),
            )
          }
          _ => raise Unsupported("non-WIT scope item")
        }
      }
      CoreType(_) => raise Unsupported("core type in WIT scope")
    }
  }
  graph
}

///|
// Rewrite local indices once. The existing explicit expression stack can then
// follow aliases across scopes without recursive substitutions or copied types.
fn encoded_map_definition(
  definition : @component.TypeDef,
  index : (Int32) -> Int32 raise EncodedFailure,
  erase_primitives~ : Bool = false,
) -> @component.TypeDef raise EncodedFailure {
  let value = fn(
    value : @component.ValType,
  ) -> @component.ValType raise EncodedFailure {
    match value {
      Prim(_) => if erase_primitives { Prim(Bool) } else { value }
      TypeIdx(id) => TypeIdx(index(id))
    }
  }
  let optional = fn(item : @component.ValType?) raise EncodedFailure {
    match item {
      None => None
      Some(item) => Some(value(item))
    }
  }
  match definition {
    DefValType(_) =>
      if erase_primitives {
        DefValType(Bool)
      } else {
        definition
      }
    Flags(_) | Enum(_) => definition
    FuncType(function) =>
      FuncType({
        ..function,
        params: function.params.map(parameter => {
          ..parameter,
          ty: value(parameter.ty),
        }),
        result: optional(function.result),
      })
    List(item) => List(value(item))
    FixedList(item, length) => FixedList(value(item), length)
    MapType(key, item) => MapType(value(key), value(item))
    Record(fields) =>
      Record(fields.map(field => { ..field, ty: value(field.ty), }))
    Variant(cases) =>
      Variant(cases.map(case => { ..case, ty: optional(case.ty), }))
    Tuple(items) => Tuple(items.map(value))
    Option(item) => Option(value(item))
    Result(ok, error) => Result(optional(ok), optional(error))
    Own(id) => Own(index(id))
    Borrow(id) => Borrow(index(id))
    Stream(item) => Stream(optional(item))
    Future(item) => Future(optional(item))
    _ => raise Unsupported("non-value encoded definition")
  }
}

///|
fn encoded_graph_definition(
  graph : EncodedGraph,
  scope : Int32,
  definition : @component.TypeDef,
) -> @component.TypeDef raise EncodedFailure {
  encoded_map_definition(definition, index => {
    encoded_graph_index(graph, scope, index)
  })
}

///|
fn encoded_graph_shape(
  graph : EncodedGraph,
  definition : @component.TypeDef,
  scope : Int32,
) -> (@component.TypeDef, Array[Int32]) raise EncodedFailure {
  let edges : Array[Int32] = []
  let shape = encoded_map_definition(
    definition,
    index => {
      edges.push(encoded_graph_index(graph, scope, index))
      0
    },
    erase_primitives=true,
  )
  (shape, edges)
}

///|
fn encoded_graph_bind(
  graph : EncodedGraph,
  projected : Int32,
  authoritative : Int32,
  authoritative_nodes : Map[Int32, Bool],
  named_nodes : Map[Int32, Bool],
) -> Unit raise EncodedFailure {
  let work : Array[(Int32, Int32)] = [(projected, authoritative)]
  let visited : Map[(Int32, Int32), Bool] = Map([])
  while work.pop() is Some((left, right)) {
    encoded_graph_step(graph)
    let left = encoded_graph_follow(graph, left)
    let right = encoded_graph_follow(graph, right)
    if left == right || visited.contains((left, right)) {
      continue
    }
    visited[(left, right)] = true
    match (graph.nodes[left], graph.nodes[right]) {
      (Resource, _) => ()
      (Value(DefValType(_) | Flags(_) | Enum(_) | Own(_) | Borrow(_), _), _) =>
        if !authoritative_nodes.contains(left) {
          graph.bindings[left] = right
        }
      (Link(a), Link(b)) => {
        if !authoritative_nodes.contains(left) {
          graph.bindings[left] = right
        }
        if !named_nodes.contains(b) {
          work.push((a, b))
        }
      }
      (Link(a), _) => work.push((a, right))
      (_, Link(b)) => if !named_nodes.contains(b) { work.push((left, b)) }
      (Value(a, a_scope), Value(b, b_scope)) => {
        let (a_shape, a_edges) = encoded_graph_shape(graph, a, a_scope)
        let (b_shape, b_edges) = encoded_graph_shape(graph, b, b_scope)
        guard a_shape == b_shape && a_edges.length() == b_edges.length() else {
          raise Invalid("interface projection has an incompatible type")
        }
        if !authoritative_nodes.contains(left) {
          graph.bindings[left] = right
        }
        for i in 0..<a_edges.length() {
          work.push((a_edges[i], b_edges[i]))
        }
      }
      _ => raise Invalid("interface projection has an incompatible type kind")
    }
  }
}

///|
fn encoded_graph_imports(
  graph : EncodedGraph,
  interfaces : Map[String, Int32],
  wrappers : Map[Int32, Int32],
  member_order : Map[Int32, Int32],
) -> Array[(String, Int32)] raise EncodedFailure {
  let inferred : Array[(String, Int32)] = []
  let foreign : Map[String, Bool] = Map([])
  let active : Map[Int32, Int32] = Map([])
  let work : Array[(Int32, Int32)] = []
  for scope in 0..<graph.scopes.length() {
    if wrappers.get(scope) is Some(order) {
      work.push((scope, order))
    }
  }
  while work.pop() is Some((scope, inherited_order)) {
    encoded_graph_step(graph)
    let order = member_order.get(scope).unwrap_or(inherited_order)
    if active.get(scope) is Some(previous) && previous <= order {
      continue
    }
    active[scope] = order
    for item in graph.scopes[scope].items {
      encoded_graph_step(graph)
      match item {
        InstanceItem(_, child, _) | WorldItem(_, child) =>
          work.push((child, order))
        _ => ()
      }
    }
  }
  let authoritative_nodes : Map[Int32, Bool] = Map([])
  let named_nodes : Map[Int32, Bool] = Map([])
  for _, scope in interfaces {
    for item in graph.scopes[scope].items {
      encoded_graph_step(graph)
      if item is TypeItem(_, id, _) {
        named_nodes[id] = true
      }
    }
    for id in graph.scopes[scope].types {
      encoded_graph_step(graph)
      if graph.node_scopes[id] == scope {
        authoritative_nodes[id] = true
      }
    }
  }
  // Scope construction follows physical declaration order, so earlier wrapper
  // imports are bound before a later world reuses their exported aliases.
  for scope_id, scope in graph.scopes {
    encoded_graph_step(graph)
    guard active.get(scope_id) is Some(order) else { continue }
    for item in scope.items {
      encoded_graph_step(graph)
      if item is InstanceItem(name, projected, imported) && name.contains("/") {
        let authoritative = match interfaces.get(name) {
          Some(scope) => scope
          None => {
            encoded_qualified(name) |> ignore
            interfaces[name] = projected
            foreign[name] = true
            inferred.push((name, projected))
            for item in graph.scopes[projected].items {
              encoded_graph_step(graph)
              if item is TypeItem(_, id, _) {
                named_nodes[id] = true
              }
            }
            for id in graph.scopes[projected].types {
              encoded_graph_step(graph)
              if graph.node_scopes[id] == projected {
                authoritative_nodes[id] = true
              }
            }
            projected
          }
        }
        if !imported && wrappers.contains(scope_id) {
          continue
        }
        guard foreign.contains(name) || member_order[authoritative] < order else {
          raise Unsupported(
            "forward local interface projection requires inference",
          )
        }
        if projected == authoritative {
          continue
        }
        let name_of_interface = name
        let types = graph.scopes[authoritative].exported_types
        let functions = graph.scopes[authoritative].exported_functions
        for item in graph.scopes[projected].items {
          encoded_graph_step(graph)
          match item {
            TypeItem(name, id, _) => {
              guard types.get(name) is Some(target) else {
                guard foreign.contains(name_of_interface) else {
                  raise Invalid(
                    "instance type export is not defined in local interface",
                  )
                }
                types[name] = id
                named_nodes[id] = true
                authoritative_nodes[id] = true
                graph.scopes[authoritative].items.push(item)
                continue
              }
              encoded_graph_bind(
                graph, id, target, authoritative_nodes, named_nodes,
              )
              // Preserve the named alias, including resource aliases, as the
              // binding target. Structural matching above validates its body.
              if !authoritative_nodes.contains(id) {
                graph.bindings[id] = target
              }
            }
            FunctionItem(name, _, _) => {
              guard functions.contains(name) else {
                guard foreign.contains(name_of_interface) else {
                  raise Invalid(
                    "instance function export is not defined in local interface",
                  )
                }
                functions[name] = true
                graph.scopes[authoritative].items.push(item)
                continue
              }
              // The pinned Resolve loader checks presence, not signatures.
            }
            _ => raise Unsupported("nested item in interface projection")
          }
        }
      }
    }
  }
  inferred
}

///|
fn encoded_graph_slots(
  graph : EncodedGraph,
  scope : Int32,
  owners : Map[Int32, (String, String)],
) -> Array[EncodedSlot] raise EncodedFailure {
  let names : Map[Int32, String] = Map([])
  for item in graph.scopes[scope].items {
    if item is TypeItem(name, id, _) {
      names[id] = name
    }
  }
  let slots : Array[EncodedSlot] = []
  let cache : Map[Int32, EncodedSlot] = Map([])
  for initial in 0..<graph.nodes.length() {
    let mut id = initial
    let mut slot : EncodedSlot? = None
    let path : Array[Int32] = []
    for _ in 0..<=graph.nodes.length() {
      encoded_graph_step(graph)
      if cache.get(id) is Some(found) {
        slot = Some(found)
        break
      }
      path.push(id)
      if names.get(id) is Some(name) {
        slot = Some(Named(name))
        break
      }
      id = encoded_graph_follow(graph, id)
      if names.get(id) is Some(name) {
        slot = Some(Named(name))
        break
      }
      if owners.get(id) is Some((owner, name)) {
        slot = Some(Imported(owner, name))
        break
      }
      match graph.nodes[id] {
        Link(target) => id = target
        Value(definition, scope) => {
          slot = Some(
            Definition(encoded_graph_definition(graph, scope, definition)),
          )
          break
        }
        Resource | Scope(_) => {
          slot = Some(Unavailable)
          break
        }
      }
    }
    guard slot is Some(slot) else { raise Invalid("cyclic encoded alias") }
    for id in path {
      cache[id] = slot
    }
    slots.push(slot)
  }
  slots
}

///|
fn encoded_graph_interface(
  graph : EncodedGraph,
  scope : Int32,
  owners : Map[Int32, (String, String)],
) -> String raise EncodedFailure {
  let slots = encoded_graph_slots(graph, scope, owners)
  let items : Array[EncodedInterfaceItem] = []
  let resources : Map[String, Array[String]] = Map([])
  for item in graph.scopes[scope].items {
    match item {
      TypeItem(name, id, false) =>
        match graph.nodes[id] {
          Resource => {
            resources[name] = []
            items.push(Resource(name))
          }
          Link(target) =>
            items.push(ItemText(encoded_type(slots, name, target)))
          _ => raise Invalid("invalid named interface type")
        }
      FunctionItem(name, id, false) => {
        let (resource, text) = encoded_function(slots, name, id)
        match resource {
          None => items.push(ItemText(text))
          Some(resource) => {
            guard resources.get(resource) is Some(methods) else {
              raise Invalid("resource function names an unknown resource")
            }
            methods.push(text)
          }
        }
      }
      _ => raise Unsupported("non-WIT interface item")
    }
  }
  let out = StringBuilder()
  for item in items {
    match item {
      ItemText(text) => out.write_string(text)
      Resource(name) => {
        out.write_string("resource " + encoded_name(name) + "{")
        for text in resources[name] {
          out.write_string(text)
        }
        out.write_string("}")
      }
    }
  }
  out.to_string()
}

///|
fn encoded_graph_world(
  graph : EncodedGraph,
  scope : Int32,
  owners : Map[Int32, (String, String)],
  interface_names : Map[String, String],
) -> String raise EncodedFailure {
  let slots = encoded_graph_slots(graph, scope, owners)
  let out = StringBuilder()
  for item in graph.scopes[scope].items {
    match item {
      TypeItem(name, id, true) =>
        match graph.nodes[id] {
          Link(target) => out.write_string(encoded_type(slots, name, target))
          _ => raise Unsupported("world-owned encoded resource")
        }
      FunctionItem(name, id, imported) => {
        let (resource, text) = encoded_function(slots, name, id)
        guard resource is None else {
          raise Unsupported("world-owned resource function")
        }
        out.write_string((if imported { "import " } else { "export " }) + text)
      }
      InstanceItem(name, child, imported) => {
        out.write_string(if imported { "import " } else { "export " })
        if name.contains("/") {
          guard interface_names.get(name) is Some(local_name) else {
            raise Unsupported("foreign encoded world interface")
          }
          out.write_string(encoded_interface_path(local_name) + ";")
        } else {
          out.write_string(
            encoded_name(name) +
            ":interface{" +
            encoded_graph_interface(graph, child, owners) +
            "}",
          )
        }
      }
      _ => raise Unsupported("unsupported encoded world item")
    }
  }
  out.to_string()
}

///|
// Importing/exporting an instance type freshens resources declared in that type.
// Outer aliases keep their existing identities. Local indices retain their order
// while owned graph nodes receive new IDs, including their named alias edges.
fn encoded_graph_instance(
  graph : EncodedGraph,
  template : Int32,
) -> Int32 raise EncodedFailure {
  let original = graph.scopes[template]
  guard original.interface_scope else {
    raise Invalid("instance references a component type")
  }
  let scope = graph.scopes.length()
  let mapping : Map[Int32, Int32] = Map([])
  let owned : Array[Int32] = []
  for id in original.types {
    encoded_graph_step(graph)
    if graph.node_scopes[id] == template && !mapping.contains(id) {
      mapping[id] = graph.nodes.length()
      graph.nodes.push(graph.nodes[id])
      graph.node_scopes.push(scope)
      owned.push(id)
    }
  }
  let remap = fn(id : Int32) { mapping.get(id).unwrap_or(id) }
  for id in owned {
    encoded_graph_step(graph)
    graph.nodes[mapping[id]] = match graph.nodes[id] {
      Link(target) => Link(remap(target))
      Value(definition, _) => Value(definition, scope)
      node => node
    }
  }
  let items : Array[EncodedItem] = []
  let exported_types : Map[String, Int32] = Map([])
  let exported_functions : Map[String, Bool] = Map([])
  for item in original.items {
    encoded_graph_step(graph)
    match item {
      TypeItem(name, id, imported) => {
        let id = remap(id)
        items.push(TypeItem(name, id, imported))
        if !imported {
          exported_types[name] = id
        }
      }
      FunctionItem(name, id, imported) => {
        items.push(FunctionItem(name, remap(id), imported))
        if !imported {
          exported_functions[name] = true
        }
      }
      _ => raise Unsupported("nested instance type item")
    }
  }
  graph.scopes.push({
    interface_scope: true,
    parent: original.parent,
    declarations: [],
    types: original.types.map(remap),
    instances: [],
    items,
    exported_types,
    exported_functions,
  })
  scope
}
