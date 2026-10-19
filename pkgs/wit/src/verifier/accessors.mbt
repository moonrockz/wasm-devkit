///|
fn flavor_prefix(flavor : FunctionFlavor) -> String {
  match flavor {
    Plain => ""
    Getter => "[get]"
    Setter => "[set]"
  }
}

///|
fn signature_name(tree : @ast.Tree, signature : Int32, name : String) -> String {
  match tree.nodes[signature].data {
    Signature(flavor=Get, ..) => "[get]" + name
    Signature(flavor=Set, ..) => "[set]" + name
    _ => name
  }
}

///|
fn verify_setter_results(
  prepared : Prepared,
  references : Map[Int32, Int32],
  errors : Array[Diagnostic],
  binary_sources~ : Map[String, Bool] = Map([]),
) -> Unit {
  let tree = prepared.tree
  for id, node in tree.nodes {
    guard node.data is Signature(flavor=Set, result=Some(output), ..) else {
      continue
    }
    let mut result = output
    if binary_sources.contains(prepared.origins[id].location.source) {
      result = binary_type_root(tree, references, output).unwrap_or(output)
    } else if tree.nodes[result].data is NamedType(..) &&
      references.get(result) is Some(target) &&
      tree.nodes[target].data is Alias(ty~, ..) {
      result = ty
    }
    if !(tree.nodes[result].data is ResultType(ok=None, ..)) {
      errors.push(
        prepared_error(
          prepared, output, "WIT-S007", "a declared setter result must be a result type with no success type",
        ),
      )
    }
  }
}

///|
fn setter_getter(name : String) -> String {
  name.replace(old="[set]", new="[get]")
}

///|
fn check_accessor_pairs(
  functions : ReadOnlyArray[ResolvedFunction],
  errors : Array[Diagnostic],
) -> Unit {
  let getters : Map[String, Location] = Map([])
  let canonical_getters : Map[String, Location] = Map([])
  for function in functions {
    if function.flavor is Getter {
      getters[function.name] = function.location
      canonical_getters[component_name_key(function.name)] = function.location
    }
  }
  for function in functions {
    if function.flavor is Setter {
      let getter = setter_getter(function.name)
      if !getters.contains(getter) {
        let related : Array[Label] = []
        if canonical_getters.get(component_name_key(getter)) is Some(location) {
          related.push({
            location,
            message: "getter spelling or resource-function kind differs",
          })
        }
        let message = "setter `" +
          function.name +
          "` has no corresponding getter `" +
          getter +
          "`"
        errors.push({
          code: "WIT-S007",
          message,
          primary: { location: function.location, message, },
          related: ReadOnlyArray::from_array(related),
        })
      }
    }
  }
}

///|
fn verify_accessor_pairs(
  arena : SemanticArena,
  tables : WorldTables,
  errors : Array[Diagnostic],
) -> Unit {
  for sides in [tables.imports, tables.exports] {
    for _, items in sides {
      let functions : Array[ResolvedFunction] = []
      for item in items {
        if item.kind is Function(id) {
          functions.push(arena.functions[id])
        }
      }
      check_accessor_pairs(ReadOnlyArray::from_array(functions), errors)
    }
  }
}

///|
fn verify_interface_accessors(
  arena : SemanticArena,
  errors : Array[Diagnostic],
) -> Unit {
  for id in arena.interface_order {
    check_accessor_pairs(arena.interfaces[id].functions, errors)
  }
}

///|
/// Move only setters that precede their getter. Already ordered setters and
/// unrelated declarations keep their original positions relative to each other.
/// This produces the reference permutation in linear time without array moves.
fn accessor_order(
  functions : ReadOnlyArray[(String, FunctionFlavor)],
) -> ReadOnlyArray[Int32] {
  let getters : Map[String, Int32] = Map([])
  let deferred : Map[String, Int32] = Map([])
  for i, entry in functions {
    let (name, flavor) = entry
    if flavor is Getter {
      getters[name] = i
    }
  }
  let order : Array[Int32] = []
  for i, entry in functions {
    let (name, flavor) = entry
    if flavor is Setter {
      let getter = setter_getter(name)
      if getters.get(getter) is Some(at) && at > i {
        deferred[getter] = i
        continue
      }
    }
    order.push(i)
    if flavor is Getter && deferred.get(name) is Some(setter) {
      order.push(setter)
    }
  }
  ReadOnlyArray::from_array(order)
}

///|
fn ordered_functions(
  functions : ReadOnlyArray[ResolvedFunction],
) -> ReadOnlyArray[ResolvedFunction] {
  accessor_order(functions.map(f => (f.name, f.flavor))).map(i => functions[i])
}

///|
fn ordered_world_items(
  items : Array[WorldItem],
  arena : SemanticArena,
) -> ReadOnlyArray[WorldItem] {
  let metadata = items.map(item => {
    match item.kind {
      Function(id) => (arena.functions[id].name, arena.functions[id].flavor)
      _ => (item.name, Plain)
    }
  })
  accessor_order(ReadOnlyArray::from_array(metadata)).map(i => items[i])
}

///|
fn include_annotation_length(name : String) -> Int32 {
  let mut at = 0
  while at < name.length() && name.code_unit_at(at) == 91 {
    while at < name.length() && name.code_unit_at(at) != 93 {
      at += 1
    }
    if at < name.length() {
      at += 1
    }
  }
  at
}

///|
fn include_rename_subject(name : String) -> String {
  let rest = name[include_annotation_length(name):]
  rest.split(".").to_array()[0].to_owned()
}

///|
fn include_item_name(
  name : String,
  replacements : Map[String, (String, Int32)],
) -> String {
  let subject = include_rename_subject(name)
  match replacements.get(subject) {
    Some((replacement, _)) => {
      let prefix = include_annotation_length(name)
      name[:prefix].to_owned() +
      replacement +
      name[prefix + subject.length():].to_owned()
    }
    None => name
  }
}
