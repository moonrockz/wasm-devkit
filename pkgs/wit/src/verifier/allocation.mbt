///|
priv enum Allocation {
  Scope(Int32)
  Type(Int32)
  Receiver(Int32, Int32)
}

///|
/// The graph has already passed cycle validation. Preserve source order among
/// ready nodes, matching the reference's stable topological allocation order.
fn allocation_toposort(
  vertices : Array[Int32],
  dependencies : Array[(Int32, Int32)],
) -> Array[Int32] {
  let remaining : Map[Int32, Int32] = Map([])
  let reverse : Map[Int32, Array[Int32]] = Map([])
  for id in vertices {
    remaining[id] = 0
    reverse[id] = []
  }
  for (owner, target) in dependencies {
    if remaining.contains(owner) && remaining.contains(target) {
      remaining[owner] = remaining[owner] + 1
      reverse[target].push(owner)
    }
  }
  let ready : @priority_queue.PriorityQueue[Int32] = @priority_queue.PriorityQueue([],
  )
  for id in vertices {
    if remaining[id] == 0 {
      ready.push(-id)
    }
  }
  let order = []
  while ready.pop() is Some(next) {
    let id = -next
    order.push(id)
    for parent in reverse[id] {
      remaining[parent] = remaining[parent] - 1
      if remaining[parent] == 0 {
        ready.push(-parent)
      }
    }
  }
  order
}

///|
fn function_allocations(
  tree : @ast.Tree,
  id : Int32,
  resources : Map[Int32, Int32],
) -> Array[Allocation] {
  let node = tree.nodes[id].data
  let signature = match node {
    Function(signature~, ..) => signature
    Import(target~, ..) | Export(target~, ..) => target
    _ => id
  }
  let result : Array[Allocation] = []
  if resources.get(id) is Some(resource) &&
    node is Function(is_static=false, ..) {
    result.push(Receiver(signature, resource))
  }
  match tree.nodes[signature].data {
    Signature(params~, result=output, ..)
    | Constructor(params~, result=output, ..) => {
      for parameter in params {
        if tree.nodes[parameter].data is Parameter(ty~, ..) {
          result.push(Type(ty))
        }
      }
      if output is Some(id) {
        result.push(Type(id))
      }
    }
    _ => ()
  }
  result
}

///|
fn allocation_order(
  prepared : Prepared,
  references : Map[Int32, Int32],
  interface_edges : Array[(Int32, Int32, Int32)],
) -> Array[Allocation] {
  let tree = prepared.tree
  let top_scopes = Array::make(tree.nodes.length(), -1)
  let scopes : Array[Int32] = []
  let visited = Array::make(tree.nodes.length(), false)
  let pending : Array[(Int32, Int32)] = []
  for root in prepared.roots {
    pending.push((root, -1))
  }
  while pending.pop() is Some((id, inherited)) {
    if visited[id] {
      continue
    }
    visited[id] = true
    let owner = if inherited < 0 &&
      (tree.nodes[id].data is Interface(..) || tree.nodes[id].data is World(..)) {
      scopes.push(id)
      id
    } else {
      inherited
    }
    top_scopes[id] = owner
    for child in tree.nodes[id].data.children() {
      pending.push((child, owner))
    }
  }
  scopes.sort()
  let scope_dependencies : Array[(Int32, Int32)] = []
  for source, target in references {
    let owner = top_scopes[source]
    let dependency = top_scopes[target]
    if owner >= 0 && dependency >= 0 && owner != dependency {
      scope_dependencies.push((owner, dependency))
    }
  }
  for (source, target, _) in interface_edges {
    let owner = top_scopes[source]
    let dependency = top_scopes[target]
    if owner >= 0 && dependency >= 0 && owner != dependency {
      scope_dependencies.push((owner, dependency))
    }
  }
  let type_owners = Array::make(tree.nodes.length(), -1)
  for id, node in tree.nodes {
    if type_declaration(node.data) {
      let children = [id]
      while children.pop() is Some(child) {
        type_owners[child] = id
        for nested in type_edges(tree.nodes[child].data) {
          children.push(nested)
        }
      }
    }
  }
  let type_dependencies : Map[Int32, Array[(Int32, Int32)]] = Map([])
  let owners = lexical_owners(tree)
  for source, target in references {
    let declaration = type_owners[source]
    if declaration < 0 || !type_declaration(tree.nodes[target].data) {
      continue
    }
    let scope = owners[declaration]
    if scope != owners[target] {
      continue
    }
    if !type_dependencies.contains(scope) {
      type_dependencies[scope] = []
    }
    type_dependencies[scope].push((declaration, target))
  }
  let resources = resource_members(tree)
  let ordered = allocation_toposort(scopes, scope_dependencies)
  let work : Array[Allocation] = []
  for i = ordered.length() - 1; i >= 0; i = i - 1 {
    work.push(Scope(ordered[i]))
  }
  let result : Array[Allocation] = []
  while work.pop() is Some(action) {
    guard action is Scope(id) else {
      result.push(action)
      continue
    }
    let items = match tree.nodes[id].data {
      Interface(items~, ..) | World(items~, ..) => items
      _ => []
    }
    let types = items
      .filter(item => type_declaration(tree.nodes[item].data))
      .iter()
      .to_array()
    let actions : Array[Allocation] = allocation_toposort(
      types,
      type_dependencies.get(id).unwrap_or([]),
    ).map(id => Type(id))
    for item in items {
      match tree.nodes[item].data {
        Function(..) =>
          actions.append(function_allocations(tree, item, resources))
        Resource(methods~, ..) =>
          for func_id in methods {
            actions.append(function_allocations(tree, func_id, resources))
          }
        Import(target~, ..) | Export(target~, ..) =>
          if tree.nodes[target].data is Interface(..) {
            actions.push(Scope(target))
          } else {
            actions.append(function_allocations(tree, item, resources))
          }
        _ => ()
      }
    }
    for i = actions.length() - 1; i >= 0; i = i - 1 {
      work.push(actions[i])
    }
  }
  result
}

///|
fn anonymous_key(data : @ast.Data, canonical : Array[String]) -> String? {
  let part = fn(id : Int32?) { id.map(i => canonical[i]).unwrap_or("none") }
  match data {
    BorrowType(resource~) => Some("borrow:" + canonical[resource])
    ListType(element~, length~) =>
      Some(
        "list:" +
        canonical[element] +
        ":" +
        length
        .map(size => fixed_size(size).unwrap().to_string())
        .unwrap_or("dynamic"),
      )
    TupleType(elements~) =>
      Some(
        "tuple:" + elements.map(id => canonical[id]).iter().to_array().join(","),
      )
    OptionType(payload~) => Some("option:" + canonical[payload])
    ResultType(ok~, error~) => Some("result:" + part(ok) + ":" + part(error))
    FutureType(payload~) => Some("future:" + part(payload))
    StreamType(payload~) => Some("stream:" + part(payload))
    MapType(key~, value~) =>
      Some("map:" + canonical[key] + ":" + canonical[value])
    _ => None
  }
}
