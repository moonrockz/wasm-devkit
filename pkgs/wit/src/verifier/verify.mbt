///|
priv enum Role {
  Root
  Top
  PackagePath
  Member
  Type
  Signature
  Parameter
}

///|
fn declaration(data : @ast.Data) -> String? {
  match data {
    Interface(name~, ..) | Alias(name~, ..) | Function(name~, ..) => Some(name)
    _ => None
  }
}

///|
/// Verify a caller-built tree directly. Structural validation precedes every
/// arena access; semantic roles and the supplied source bounds are then checked.
pub fn verify_ast(
  tree : @ast.Tree,
  source_id~ : String = "<input>",
  source~ : String,
) -> Result[Verified, ReadOnlyArray[Diagnostic]] {
  let errors : Array[Diagnostic] = []
  let bad = fn(id : Int32, code : String, message : String) {
    let span = if id >= 0 && id < tree.nodes.length() {
      tree.nodes[id].span
    } else {
      { start: 0, end: 0, }
    }
    errors.push(error(source_id, span, code, message))
  }
  guard tree.validate() && !tree.nodes.is_empty() else {
    bad(-1, "WIT-S001", "invalid AST structure")
    return Err(ReadOnlyArray::from_array(errors))
  }
  for i, node in tree.nodes {
    if node.span.start < 0 || node.span.end > source.length() {
      bad(i, "WIT-S001", "AST location is outside its source")
    }
  }
  if !errors.is_empty() {
    return Err(ReadOnlyArray::from_array(errors))
  }
  let scopes : Array[Map[String, Int32]] = [{}]
  let bindings : Array[Binding] = []
  let pending : Array[(Int32, Role, Int32)] = [
    (tree.nodes.length() - 1, Root, 0),
  ]
  let references : Array[(Int32, Int32)] = []
  let aliases : Array[Int32] = []
  let parameters : Map[Int32, Map[String, Int32]] = Map([])
  while pending.pop() is Some((id, role, scope)) {
    let node = tree.nodes[id]
    let data = node.data
    let decoded_name = match data {
      Interface(name~, ..)
      | Alias(name~, ..)
      | Function(name~, ..)
      | Parameter(name~, ..)
      | NamedType(name~) => Some(name)
      _ => None
    }
    if decoded_name is Some(name) && !identifier(name) {
      bad(id, "WIT-S001", "invalid decoded identifier")
    }

    let mut accepted = true
    match (role, data) {
      (Root, File(items~)) => {
        let headers = items.filter(id => tree.nodes[id].data is Package(..))
        if headers.length() != 1 ||
          items.is_empty() ||
          !(tree.nodes[items[0]].data is Package(..)) {
          bad(
            id, "WIT-S002", "a complete WIT package requires one leading package header",
          )
        }
        for i = items.length() - 1; i >= 0; i = i - 1 {
          pending.push((items[i], Top, scope))
        }
      }
      (Top, Package(path~, items~, attributes~, nested~)) => {
        if !items.is_empty() && !nested {
          bad(
            id, "WIT-S001", "non-nested package header cannot own declarations",
          )
        }
        if nested || !attributes.is_empty() {
          bad(
            id, "WIT-S003", "nested packages and attributes are not yet supported",
          )
        }
        pending.push((path, PackagePath, scope))
        for i = items.length() - 1; i >= 0; i = i - 1 {
          pending.push((items[i], Top, scope))
        }
      }
      (PackagePath, Path(namespaces~, segments~, version~)) => {
        if namespaces.length() != 1 ||
          segments.length() != 1 ||
          !identifier(namespaces[0]) ||
          !identifier(segments[0]) {
          bad(id, "WIT-S001", "invalid package identity")
        }
        if version is Some(_) {
          bad(id, "WIT-S003", "version semantics are not yet supported")
        }
      }
      (Top, Interface(items~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        let scope_id = scopes.length()
        scopes.push({})
        // WIT names are collected before resolving types, including forward references.
        for item in items {
          if declaration(tree.nodes[item].data) is Some(name) {
            if scopes[scope_id].get(name) is Some(first) {
              let d = error(
                source_id,
                tree.nodes[item].span,
                "WIT-S004",
                "duplicate declaration `" + name + "`",
              )
              errors.push({
                ..d,
                related: [
                  {
                    location: {
                      source: source_id,
                      span: tree.nodes[first].span,
                    },
                    message: "first declared here",
                  },
                ],
              })
            } else {
              scopes[scope_id][name] = item
            }
          }
        }
        for i = items.length() - 1; i >= 0; i = i - 1 {
          pending.push((items[i], Member, scope_id))
        }
      }
      (Member, Alias(ty~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        aliases.push(id)
        pending.push((ty, Type, scope))
      }
      (Member, Function(signature~, attributes~, is_static~, ..)) => {
        if is_static || !attributes.is_empty() {
          bad(
            id, "WIT-S003", "resource methods and attributes are not yet supported",
          )
        }
        pending.push((signature, Signature, scope))
      }
      (Signature, Signature(params~, result~, flavor~, asynchronous~)) => {
        if flavor != Func || asynchronous {
          bad(
            id, "WIT-S003", "accessors and async functions are not yet supported",
          )
        }
        parameters[id] = {}
        for param in params {
          if tree.nodes[param].data is Parameter(name~, ..) {
            let names = parameters[id]
            if names.contains(name) {
              bad(param, "WIT-S004", "duplicate parameter `" + name + "`")
            } else {
              names[name] = param
            }
          }
        }
        if result is Some(result) {
          pending.push((result, Type, scope))
        }
        for i = params.length() - 1; i >= 0; i = i - 1 {
          pending.push((params[i], Parameter, scope))
        }
      }
      (Parameter, Parameter(ty~, ..)) => pending.push((ty, Type, scope))
      (Type, PrimitiveType(name~)) => {
        if ![
            "bool", "u8", "u16", "u32", "u64", "s8", "s16", "s32", "s64", "f32",
            "f64", "char", "string", "error-context",
          ].contains(name) {
          bad(id, "WIT-S001", "unknown primitive type `" + name + "`")
        }
        if name == "error-context" {
          bad(id, "WIT-S003", "error-context semantics are not yet supported")
        }
      }
      (Type, NamedType(name~)) =>
        match scopes[scope].get(name) {
          Some(target) =>
            if tree.nodes[target].data is Alias(..) {
              references.push((id, target))
              bindings.push({ name, scope, node: id, target, })
            } else {
              bad(id, "WIT-S005", "expected a type, found `" + name + "`")
            }
          None => bad(id, "WIT-S005", "unresolved type `" + name + "`")
        }
      _ => accepted = false
    }
    if !accepted {
      bad(
        id,
        "WIT-S003",
        "unsupported construct or invalid AST role: " +
        @debug.to_string(node.data.kind()),
      )
    }
    if role is Top {
      if declaration(data) is Some(name) {
        if scopes[0].get(name) is Some(first) {
          let d = error(
            source_id,
            node.span,
            "WIT-S004",
            "duplicate declaration `" + name + "`",
          )
          errors.push({
            ..d,
            related: [
              {
                location: { source: source_id, span: tree.nodes[first].span, },
                message: "first declared here",
              },
            ],
          })
        } else {
          scopes[0][name] = id
        }
      }
    }
  }
  // Alias edges are followed with an explicit stack. Cycles cannot create a model.
  let edges : Map[Int32, Int32] = Map([])
  for (reference, target) in references {
    edges[reference] = target
  }
  let color = Array::make(tree.nodes.length(), 0)
  for alias_id in aliases {
    let work = [(alias_id, false)]
    while work.pop() is Some((id, leaving)) {
      if leaving {
        color[id] = 2
        continue
      }
      if color[id] == 2 {
        continue
      }
      if color[id] == 1 {
        bad(id, "WIT-S006", "cyclic type alias")
        continue
      }
      color[id] = 1
      work.push((id, true))
      match tree.nodes[id].data {
        Alias(ty~, ..) => work.push((ty, false))
        NamedType(..) =>
          if edges.get(id) is Some(target) {
            work.push((target, false))
          }
        _ => ()
      }
    }
  }
  if errors.is_empty() {
    Ok({
      source_id,
      source_text: source,
      tree,
      bindings: ReadOnlyArray::from_array(bindings),
    })
  } else {
    Err(ReadOnlyArray::from_array(errors))
  }
}
