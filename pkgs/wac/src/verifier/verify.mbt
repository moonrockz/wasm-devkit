///|
priv enum Role {
  Root
  Top
  Directive
  PackagePath
  Type
  Signature
  Parameter
  Expression
  Bind
  ExportName
  Export
  Resolve
  ImportType
}

///|
/// WAC declarations enter scope after their initializer/type is checked.
/// Every operation uses an explicit work stack rather than recursive descent.
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
    bad(-1, "WAC-S001", "invalid AST structure")
    return Err(ReadOnlyArray::from_array(errors))
  }
  for i, node in tree.nodes {
    if node.span.start < 0 || node.span.end > source.length() {
      bad(i, "WAC-S001", "AST location is outside its source")
    }
  }
  if !errors.is_empty() {
    return Err(ReadOnlyArray::from_array(errors))
  }
  let names : Map[String, Int32] = Map([])
  let exports : Map[String, Int32] = Map([])
  let bindings : Array[Binding] = []
  let values = Array::make(tree.nodes.length(), -1)
  let pending : Array[(Int32, Role)] = [(tree.nodes.length() - 1, Root)]
  while pending.pop() is Some((id, role)) {
    let data = tree.nodes[id].data
    let decoded_name = match data {
      Alias(name~, ..)
      | Import(binding=name, ..)
      | Let(name~, ..)
      | Parameter(name~, ..)
      | NamedType(name~)
      | Reference(name~) => Some(name)
      _ => None
    }
    if decoded_name is Some(name) && !identifier(name) {
      bad(id, "WAC-S001", "invalid decoded identifier")
    }

    match (role, data) {
      (Root, File(directive~, statements~)) => {
        for i = statements.length() - 1; i >= 0; i = i - 1 {
          pending.push((statements[i], Top))
        }
        match directive {
          Some(directive) => pending.push((directive, Directive))
          None => bad(id, "WAC-S001", "missing package directive")
        }
      }
      (Directive, Package(path~, targets~)) => {
        pending.push((path, PackagePath))
        if targets is Some(_) {
          bad(id, "WAC-S003", "target resolution is not yet supported")
        }
      }
      (PackagePath, Path(namespaces~, segments~, version~)) => {
        if namespaces.length() != 1 ||
          segments.length() != 1 ||
          !identifier(namespaces[0]) ||
          !identifier(segments[0]) {
          bad(id, "WAC-S001", "invalid package identity")
        }
        if version is Some(_) {
          bad(id, "WAC-S003", "version semantics are not yet supported")
        }
      }
      (Top, Alias(ty~, ..)) => {
        pending.push((id, Bind))
        pending.push((ty, Type))
      }
      (Top, Import(ty~, renamed~, ..)) => {
        if renamed is Some(_) {
          bad(id, "WAC-S003", "import name annotations are not yet supported")
        }
        pending.push((id, Bind))
        pending.push((ty, ImportType))
      }
      (Top, Let(expression~, ..)) => {
        pending.push((id, Bind))
        pending.push((expression, Expression))
      }
      (Bind, Alias(name~, ..))
      | (Bind, Import(binding=name, ..))
      | (Bind, Let(name~, ..)) =>
        if names.get(name) is Some(first) {
          let d = error(
            source_id,
            tree.nodes[id].span,
            "WAC-S004",
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
          names[name] = id
          match data {
            Import(..) => values[id] = id
            Let(expression~, ..) => values[id] = values[expression]
            _ => ()
          }
          bindings.push({ name, scope: 0, node: id, target: id, })
        }
      (Top, Export(expression~, ..)) => {
        pending.push((id, Export))
        pending.push((expression, Expression))
      }
      (Export, Export(expression~, renamed~, spread~)) => {
        if spread {
          bad(id, "WAC-S003", "export spreads are not yet supported")
        }
        let export_name = match renamed {
          Some(node) => {
            pending.push((node, ExportName))
            match tree.nodes[node].data {
              Name(value~, ..) => Some(value)
              _ => None
            }
          }
          None => {
            let target = values[expression]
            if target >= 0 {
              match tree.nodes[target].data {
                Import(binding~, ..) => Some(binding)
                _ => None
              }
            } else {
              None
            }
          }
        }
        match export_name {
          Some(name) =>
            if exports.contains(name) {
              bad(id, "WAC-S004", "duplicate export `" + name + "`")
            } else {
              exports[name] = id
            }
          None =>
            bad(
              id, "WAC-S003", "export name inference is not supported for this expression",
            )
        }
      }
      (ExportName, Name(value~, ..)) =>
        if value.is_empty() {
          bad(id, "WAC-S001", "empty export name")
        }
      (Expression, Expression(primary~, postfix~)) => {
        if !postfix.is_empty() {
          bad(id, "WAC-S003", "instance access is not yet supported")
        }
        pending.push((id, Resolve))
        pending.push((primary, Expression))
      }
      (Expression, Group(expression~)) => {
        pending.push((id, Resolve))
        pending.push((expression, Expression))
      }
      (Resolve, Expression(primary~, ..)) => values[id] = values[primary]
      (Resolve, Group(expression~)) => values[id] = values[expression]
      (Expression, Reference(name~)) =>
        match names.get(name) {
          Some(target) => {
            if tree.nodes[target].data is Alias(..) {
              bad(id, "WAC-S003", "type expressions are not yet supported")
            }
            values[id] = values[target]
            bindings.push({ name, scope: 0, node: id, target, })
          }
          None =>
            bad(
              id,
              "WAC-S005",
              "unresolved value `" +
              name +
              "`; declarations are visible only after their definition",
            )
        }
      (ImportType, Signature(..)) => pending.push((id, Signature))
      (ImportType, NamedType(..)) => pending.push((id, Type))
      (Type, NamedType(name~)) =>
        match names.get(name) {
          Some(target) =>
            if tree.nodes[target].data is Alias(..) {
              bindings.push({ name, scope: 0, node: id, target, })
            } else {
              bad(
                id, "WAC-S003", "aliases of function values are not yet supported",
              )
            }
          None => bad(id, "WAC-S005", "unresolved type `" + name + "`")
        }
      (Type, PrimitiveType(name~)) =>
        if ![
            "bool", "u8", "u16", "u32", "u64", "s8", "s16", "s32", "s64", "f32",
            "f64", "char", "string",
          ].contains(name) {
          bad(id, "WAC-S001", "unknown primitive type `" + name + "`")
        }
      (Signature, Signature(params~, result~, asynchronous~)) => {
        if asynchronous {
          bad(id, "WAC-S003", "async functions are not yet supported")
        }
        let params_seen : Map[String, Int32] = Map([])
        for param in params {
          if tree.nodes[param].data is Parameter(name~, ..) {
            if params_seen.contains(name) {
              bad(param, "WAC-S004", "duplicate parameter `" + name + "`")
            } else {
              params_seen[name] = param
            }
          }
        }
        if result is Some(result) {
          pending.push((result, Type))
        }
        for i = params.length() - 1; i >= 0; i = i - 1 {
          pending.push((params[i], Parameter))
        }
      }
      (Parameter, Parameter(ty~, ..)) => pending.push((ty, Type))
      _ => bad(id, "WAC-S003", "unsupported construct or invalid AST role")
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
