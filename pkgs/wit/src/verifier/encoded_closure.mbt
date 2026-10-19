///|
priv struct EncodedMergeBudget {
  mut remaining : Int32
}

///|
fn encoded_merge_charge(
  budget : EncodedMergeBudget,
  count : Int32,
) -> Unit raise EncodedFailure {
  guard count <= budget.remaining else {
    raise Unsupported("inferred closure exceeds the decoding work limit")
  }
  budget.remaining -= count
}

///|
// Merge only decoder-inferred package blocks. Supplied source declarations stay
// in their original Documents; all edits here affect the private prepared arena.
fn encoded_merge_sections(
  nodes : Array[@ast.Node],
  origins : Array[Origin],
  roots : Array[Int32],
  packages : Map[Int32, Int32],
  partial : Map[Int32, Bool],
  errors : Array[Diagnostic],
) -> Unit raise EncodedFailure {
  if partial.is_empty() {
    return
  }
  let budget : EncodedMergeBudget = { remaining: 1000000, }
  encoded_merge_charge(budget, nodes.length())
  let interfaces : Map[(Int32, String), Int32] = Map([])
  let inferred : Map[(Int32, String), Bool] = Map([])
  let order : Array[Int32] = []
  for root in roots {
    if !partial.contains(root) {
      order.push(root)
    }
  }
  for root in roots {
    if partial.contains(root) {
      order.push(root)
    }
  }
  for root in order {
    encoded_merge_charge(budget, 1)
    let items : Array[Int32] = []
    for id in section_items(nodes[root].data) {
      encoded_merge_charge(budget, 1)
      guard nodes[id].data is Interface(name~, ..) else {
        items.push(id)
        continue
      }
      let key = (packages[root], name)
      match interfaces.get(key) {
        Some(previous) =>
          if partial.contains(root) || inferred.contains(key) {
            encoded_merge_interface(
              nodes, origins, previous, id, errors, budget,
            )
          } else {
            items.push(id)
          }
        None => {
          interfaces[key] = id
          if partial.contains(root) {
            inferred[key] = true
          }
          items.push(id)
        }
      }
    }
    let items = ReadOnlyArray::from_array(items)
    let data = match nodes[root].data {
      File(..) => @ast.Data::File(items~)
      Package(attributes~, path~, nested~, ..) =>
        Package(attributes~, path~, nested~, items~)
      data => data
    }
    nodes[root] = { ..nodes[root], data, }
  }
}

///|
fn encoded_member_name(data : @ast.Data) -> String? {
  match data {
    Resource(name~, ..)
    | Alias(name~, ..)
    | Record(name~, ..)
    | Flags(name~, ..)
    | Enum(name~, ..)
    | Variant(name~, ..)
    | Function(name~, ..) => Some(name)
    Constructor(..) => Some("[constructor]")
    Rename(name~, renamed~) => Some(renamed.unwrap_or(name))
    _ => None
  }
}

///|
fn encoded_merge_interface(
  nodes : Array[@ast.Node],
  origins : Array[Origin],
  target : Int32,
  source : Int32,
  errors : Array[Diagnostic],
  budget : EncodedMergeBudget,
) -> Unit raise EncodedFailure {
  guard nodes[target].data is Interface(name~, attributes~, items=old) &&
    nodes[source].data is Interface(items=new, ..) else {
    return
  }
  encoded_merge_charge(budget, old.length())
  encoded_merge_charge(budget, new.length())
  let items = old.iter().to_array()
  let members : Map[String, Int32] = Map([])
  for id in old {
    if nodes[id].data is Use(names~, ..) {
      encoded_merge_charge(budget, names.length())
      for selector in names {
        if encoded_merge_member_key(nodes, selector) is Some(name) {
          members[name] = selector
        }
      }
    } else if encoded_merge_member_key(nodes, id) is Some(name) {
      members[name] = id
    }
  }
  for id in new {
    if nodes[id].data is Use(attributes~, path~, names~, renamed~) {
      let retained : Array[Int32] = []
      encoded_merge_charge(budget, names.length())
      for selector in names {
        if encoded_merge_member_key(nodes, selector) is Some(name) &&
          !members.contains(name) {
          retained.push(selector)
          members[name] = selector
        }
      }
      if !retained.is_empty() {
        nodes[id] = {
          ..nodes[id],
          data: Use(
            attributes~,
            path~,
            names=ReadOnlyArray::from_array(retained),
            renamed~,
          ),
        }
        items.push(id)
      }
      continue
    }
    guard encoded_merge_member_key(nodes, id) is Some(member_name) else {
      items.push(id)
      continue
    }
    match members.get(member_name) {
      None => {
        members[member_name] = id
        items.push(id)
      }
      Some(previous) =>
        if nodes[previous].data
          is Resource(name~, attributes~, methods=old_methods, ..) &&
          nodes[id].data is Resource(methods=new_methods, ..) {
          encoded_merge_charge(budget, old_methods.length())
          encoded_merge_charge(budget, new_methods.length())
          let methods = old_methods.iter().to_array()
          let known : Map[String, Int32] = Map([])
          for method_id in old_methods {
            if encoded_merge_member_key(nodes, method_id) is Some(name) {
              known[name] = method_id
            }
          }
          for method_id in new_methods {
            if encoded_merge_member_key(nodes, method_id) is Some(name) {
              if known.get(name) is Some(previous) {
                encoded_merge_function(
                  nodes, origins, previous, method_id, errors, budget,
                )
              } else {
                known[name] = method_id
                methods.push(method_id)
              }
            }
          }
          nodes[previous] = {
            ..nodes[previous],
            data: Resource(
              name~,
              attributes~,
              methods=ReadOnlyArray::from_array(methods),
              has_body=true,
            ),
          }
        } else if nodes[id].data is Function(..) ||
          nodes[previous].data is Function(..) {
          encoded_merge_function(nodes, origins, previous, id, errors, budget)
        }
      // Pinned Resolve::merge maps shared named types by name without
      // comparing their definitions. Preserve the existing declaration.
    }
  }
  nodes[target] = {
    ..nodes[target],
    data: Interface(name~, attributes~, items=ReadOnlyArray::from_array(items)),
  }
}

///|
fn encoded_merge_function(
  nodes : Array[@ast.Node],
  origins : Array[Origin],
  target : Int32,
  source : Int32,
  errors : Array[Diagnostic],
  budget : EncodedMergeBudget,
) -> Unit raise EncodedFailure {
  if encoded_function_shape(nodes, target, budget) !=
    encoded_function_shape(nodes, source, budget) {
    let message = "incompatible function in inferred encoded interface"
    errors.push({
      ..error_at(origins[source].location, "WIT-B004", message),
      related: [
        {
          location: origins[target].location,
          message: "existing function declaration",
        },
      ],
    })
  }
}

///|
fn encoded_function_shape(
  nodes : Array[@ast.Node],
  id : Int32,
  budget : EncodedMergeBudget,
) -> String raise EncodedFailure {
  let out = StringBuilder()
  let (params, result) = match nodes[id].data {
    Function(name~, signature~, is_static~, ..) => {
      out.write_string(name + ":" + is_static.to_string())
      guard nodes[signature].data
        is Signature(flavor~, asynchronous~, params~, result~) else {
        return "invalid"
      }
      out.write_string(
        (match flavor {
          Func => "func"
          Get => "get"
          Set => "set"
        }) +
        asynchronous.to_string(),
      )
      (params, result)
    }
    Constructor(params~, ..) => {
      out.write_string("constructor")
      (params, None)
    }
    _ => return "not-function"
  }
  encoded_merge_charge(budget, params.length())
  for param in params {
    if nodes[param].data is Parameter(name~, ty~) {
      out.write_string("/" + name + ":" + encoded_merge_value(nodes[ty].data))
    }
  }
  out.write_string(
    "->" +
    (match result {
      Some(id) => encoded_merge_value(nodes[id].data)
      None => "none"
    }),
  )
  out.to_string()
}

///|
fn encoded_merge_value(data : @ast.Data) -> String {
  match data {
    PrimitiveType(name~) => name
    _ => "id"
  }
}

///|
fn encoded_merge_member_key(nodes : Array[@ast.Node], id : Int32) -> String? {
  if nodes[id].data is Function(name~, signature~, ..) &&
    nodes[signature].data is Signature(flavor~, ..) {
    return Some(
      (match flavor {
        Func => "[func]"
        Get => "[get]"
        Set => "[set]"
      }) +
      name,
    )
  }
  encoded_member_name(nodes[id].data)
}

///|
fn encoded_compact_closure(
  nodes : Array[@ast.Node],
  origins : Array[Origin],
  roots : Array[Int32],
  packages : Array[Int32],
) -> Unit {
  let seen = Array::make(nodes.length(), false)
  let order : Array[Int32] = []
  let work : Array[(Int32, Bool)] = []
  for i = roots.length() - 1; i >= 0; i = i - 1 {
    work.push((roots[i], false))
  }
  while work.pop() is Some((id, leaving)) {
    if leaving {
      order.push(id)
      continue
    }
    if seen[id] {
      continue
    }
    seen[id] = true
    work.push((id, true))
    let children = nodes[id].data.children()
    for i = children.length() - 1; i >= 0; i = i - 1 {
      work.push((children[i], false))
    }
  }
  let mapping = Array::make(nodes.length(), -1)
  for fresh, old in order {
    mapping[old] = fresh
  }
  let retained_nodes : Array[@ast.Node] = []
  let retained_origins : Array[Origin] = []
  let retained_packages : Array[Int32] = []
  for id in order {
    retained_nodes.push({
      ..nodes[id],
      data: nodes[id].data.map_children(child => mapping[child]),
    })
    retained_origins.push(origins[id])
    retained_packages.push(packages[id])
  }
  for index in 0..<roots.length() {
    roots[index] = mapping[roots[index]]
  }
  nodes.clear()
  nodes.append(retained_nodes)
  origins.clear()
  origins.append(retained_origins)
  packages.clear()
  packages.append(retained_packages)
}
