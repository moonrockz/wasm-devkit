///|
priv enum Role {
  Root
  Top
  PackagePath
  Member
  Type
  Signature
  Parameter
  Field
  Case
  EmptyCase
}

///|
fn declaration(data : @ast.Data) -> String? {
  match data {
    Interface(name~, ..)
    | World(name~, ..)
    | Alias(name~, ..)
    | Record(name~, ..)
    | Flags(name~, ..)
    | Enum(name~, ..)
    | Variant(name~, ..)
    | Resource(name~, ..)
    | Function(name~, ..) => Some(name)
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
  let mut package_identity : PackageIdentity? = None
  let duplicates = fn(ids : ReadOnlyArray[Int32], kind : String) {
    let seen : Map[String, Int32] = Map([])
    for child in ids {
      let name = match tree.nodes[child].data {
        Field(name~, ..) | Case(name~, ..) | Parameter(name~, ..) => Some(name)
        _ => None
      }
      if name is Some(name) {
        if seen.get(name) is Some(first) {
          let d = error(
            source_id,
            tree.nodes[child].span,
            "WIT-S004",
            "duplicate " + kind + " `" + name + "`",
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
          seen[name] = child
        }
      }
    }
  }
  while pending.pop() is Some((id, role, scope)) {
    let node = tree.nodes[id]
    let data = node.data
    let decoded_name = match data {
      Interface(name~, ..)
      | World(name~, ..)
      | Record(name~, ..)
      | Flags(name~, ..)
      | Enum(name~, ..)
      | Variant(name~, ..)
      | Resource(name~, ..)
      | Field(name~, ..)
      | Case(name~, ..)
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
        } else {
          package_identity = Some({
            namespace_name: namespaces[0],
            name: segments[0],
            version,
          })
        }
        if version is Some(_) {
          bad(id, "WIT-S003", "version semantics are not yet supported")
        }
      }
      (Top, Interface(items~, attributes~, ..))
      | (Top, World(items~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        let scope_id = scopes.length()
        scopes.push({})
        // WIT names are collected before resolving types, including forward references.
        for item in items {
          if data is World(..) && tree.nodes[item].data is Function(..) {
            bad(item, "WIT-S001", "world functions must be imports or exports")
          }
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
              bindings.push({ name, scope: scope_id, node: item, target: item, })
            }
          }
        }
        for i = items.length() - 1; i >= 0; i = i - 1 {
          pending.push((items[i], Member, scope_id))
        }
      }
      (Member, Resource(methods~, attributes~, ..)) => {
        if !methods.is_empty() || !attributes.is_empty() {
          bad(
            id, "WIT-S003", "resource methods and attributes are not yet supported",
          )
        }
        aliases.push(id)
      }
      (Member, Alias(ty~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        aliases.push(id)
        pending.push((ty, Type, scope))
      }
      (Member, Record(fields~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        if fields.is_empty() {
          bad(id, "WIT-S007", "empty record")
        }
        duplicates(fields, "field")
        aliases.push(id)
        for i = fields.length() - 1; i >= 0; i = i - 1 {
          pending.push((fields[i], Field, scope))
        }
      }
      (Member, Flags(cases~, attributes~, ..))
      | (Member, Enum(cases~, attributes~, ..))
      | (Member, Variant(cases~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        if cases.is_empty() {
          bad(id, "WIT-S007", "empty aggregate")
        }
        if data is Flags(..) && cases.length() > 32 {
          bad(cases[32], "WIT-S007", "cannot have more than 32 flags")
        }
        duplicates(cases, "case")
        aliases.push(id)
        for i = cases.length() - 1; i >= 0; i = i - 1 {
          pending.push(
            (
              cases[i],
              if data is Variant(..) {
                Case
              } else {
                EmptyCase
              },
              scope,
            ),
          )
        }
      }
      (Field, Field(ty~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        pending.push((ty, Type, scope))
      }
      (Case, Case(payload~, attributes~, ..))
      | (EmptyCase, Case(payload~, attributes~, ..)) => {
        if !attributes.is_empty() {
          bad(id, "WIT-S003", "attributes are not yet supported")
        }
        if payload is Some(ty) {
          if role is EmptyCase {
            bad(id, "WIT-S001", "enum and flag cases cannot have payloads")
          }
          pending.push((ty, Type, scope))
        }
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
        duplicates(params, "parameter")
        if result is Some(result) {
          pending.push((result, Type, scope))
        }
        for i = params.length() - 1; i >= 0; i = i - 1 {
          pending.push((params[i], Parameter, scope))
        }
      }
      (Parameter, Parameter(ty~, ..)) => pending.push((ty, Type, scope))
      (Type, PrimitiveType(name~)) =>
        if ![
            "bool", "u8", "u16", "u32", "u64", "s8", "s16", "s32", "s64", "f32",
            "f64", "char", "string", "error-context",
          ].contains(name) {
          bad(id, "WIT-S001", "unknown primitive type `" + name + "`")
        }
      (Type, NamedType(name~)) =>
        match scopes[scope].get(name) {
          Some(target) =>
            if type_declaration(tree.nodes[target].data) {
              references.push((id, target))
              bindings.push({ name, scope, node: id, target, })
            } else {
              let d = error(
                source_id,
                node.span,
                "WIT-S008",
                "expected a type, found `" + name + "`",
              )
              errors.push({
                ..d,
                related: [
                  {
                    location: {
                      source: source_id,
                      span: tree.nodes[target].span,
                    },
                    message: "non-type declaration is here",
                  },
                ],
              })
            }
          None => bad(id, "WIT-S005", "unresolved type `" + name + "`")
        }
      (Type, ListType(element~, length~)) => {
        if length is Some(size) && fixed_size(size) is None {
          bad(id, "WIT-S007", "fixed list size must be a decimal u32")
        }
        pending.push((element, Type, scope))
      }
      (Type, TupleType(elements~)) => {
        if elements.is_empty() {
          bad(id, "WIT-S007", "empty tuple")
        }
        for i = elements.length() - 1; i >= 0; i = i - 1 {
          pending.push((elements[i], Type, scope))
        }
      }
      (Type, OptionType(payload~)) => pending.push((payload, Type, scope))
      (Type, ResultType(ok~, error~)) => {
        if error is Some(ty) {
          pending.push((ty, Type, scope))
        }
        if ok is Some(ty) {
          pending.push((ty, Type, scope))
        }
      }
      (Type, FutureType(payload~)) | (Type, StreamType(payload~)) =>
        if payload is Some(ty) {
          pending.push((ty, Type, scope))
        }
      (Type, MapType(key~, value~)) => {
        // At this reference revision only direct scalar key syntax is valid.
        // An alias to string remains a defined type and is rejected upstream.
        let valid_key = match tree.nodes[key].data {
          PrimitiveType(name~) =>
            [
              "bool", "u8", "u16", "u32", "u64", "s8", "s16", "s32", "s64", "char",
              "string",
            ].contains(name)
          _ => false
        }
        if !valid_key {
          bad(
            key, "WIT-S007", "invalid map key type; expected a direct bool, integer, char or string scalar",
          )
        }
        pending.push((value, Type, scope))
        pending.push((key, Type, scope))
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
          bindings.push({ name, scope: 0, node: id, target: id, })
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
        let related : Array[Label] = []
        // The work stack retains ancestors' leave records. Bound diagnostic
        // expansion even for a very deep or densely connected invalid graph.
        for i = work.length() - 1; i >= 0 && i >= work.length() - 64; i = i - 1 {
          let (ancestor, leaving) = work[i]
          if leaving && related.length() < 32 {
            related.push({
              location: { source: source_id, span: tree.nodes[ancestor].span, },
              message: "type dependency passes through here",
            })
          }
        }
        let d = error(
          source_id,
          tree.nodes[id].span,
          "WIT-S006",
          "cyclic type dependency",
        )
        errors.push({ ..d, related: ReadOnlyArray::from_array(related), })
        continue
      }
      color[id] = 1
      work.push((id, true))
      if edges.get(id) is Some(target) {
        work.push((target, false))
      }
      let children = type_edges(tree.nodes[id].data)
      for i = children.length() - 1; i >= 0; i = i - 1 {
        work.push((children[i], false))
      }
    }
  }
  if errors.is_empty() && package_identity is Some(package_identity) {
    Ok({
      source_id,
      source_text: source,
      tree,
      bindings: ReadOnlyArray::from_array(bindings),
      resolved_types: resolved_types(tree, source_id, edges),
      package_identity,
    })
  } else {
    Err(ReadOnlyArray::from_array(errors))
  }
}
