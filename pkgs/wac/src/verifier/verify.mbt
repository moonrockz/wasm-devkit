///|
priv suberror SemanticFailure {
  Problem(Diagnostic)
}

///|
priv struct LocalItem {
  kind : ItemKind
  node : Int32
  external_name : String?
  value : Int32?
}

///|
priv struct Scope {
  names : Map[String, LocalItem]
  imports : Array[Extern]
  exports : Array[Extern]
  import_nodes : Map[String, Int32]
  export_nodes : Map[String, Int32]
  uses : Array[UsedType]
}

///|
fn Scope::new() -> Scope {
  {
    names: Map([]),
    imports: [],
    exports: [],
    import_nodes: Map([]),
    export_nodes: Map([]),
    uses: [],
  }
}

///|
priv struct Check {
  tree : @ast.Tree
  source_id : String
  types : Array[ResolvedType]
  borrowed : Array[Bool]
  values : Array[Int32]
  scopes : Array[Scope]
  bindings : Array[Binding]
  declarations : Array[ResolvedDeclaration]
  composition_nodes : Array[CompositionNode]
  composition_outputs : Array[CompositionExport]
  composition_aliases : Map[(Int32, String), Int32]
  root_resources : Map[Int32, Int32]
  mut next_resource_identity : Int32
  mut package_name : String
  mut package_version : String?
  dependencies : Map[String, PackageSource]
  loaded_packages : Map[String, LoadedPackage]
}

///|
fn Check::location(self : Check, node : Int32) -> Location {
  Location::text(self.source_id, self.tree.nodes[node].span)
}

///|
fn Check::problem(
  self : Check,
  node : Int32,
  code : String,
  message : String,
  first~ : Int32? = None,
) -> Diagnostic {
  let diagnostic = error(
    self.source_id,
    self.tree.nodes[node].span,
    code,
    message,
  )
  match first {
    None => diagnostic
    Some(first) =>
      {
        ..diagnostic,
        related: [
          { location: self.location(first), message: "first declared here", },
        ],
      }
  }
}

///|
fn Check::name(
  self : Check,
  node : Int32,
  name : String,
) -> Unit raise SemanticFailure {
  guard identifier(name) else {
    raise Problem(
      self.problem(
        node,
        "WAC-S001",
        "invalid decoded identifier `" + name + "`",
      ),
    )
  }
}

///|
fn Check::lookup(
  self : Check,
  scope : Int32,
  node : Int32,
  name : String,
  root_fallback~ : Bool = false,
) -> LocalItem raise SemanticFailure {
  self.name(node, name)
  let item = match self.scopes[scope].names.get(name) {
    Some(item) => item
    None =>
      if root_fallback && self.scopes[0].names.get(name) is Some(item) {
        item
      } else {
        raise Problem(
          self.problem(
            node,
            "WAC-S005",
            "unresolved name `" +
            name +
            "`; declarations are visible only after their definition",
          ),
        )
      }
  }
  self.bindings.push({ name, scope, node, target: item.node, })
  item
}

///|
fn Check::bind(
  self : Check,
  scope : Int32,
  node : Int32,
  name : String,
  item : LocalItem,
) -> Unit raise SemanticFailure {
  self.name(node, name)
  if self.scopes[scope].names.get(name) is Some(first) {
    raise Problem(
      self.problem(
        node,
        "WAC-S004",
        "duplicate declaration `" + name + "`",
        first=Some(first.node),
      ),
    )
  }
  let value = if scope == 0 && item.value is None {
    let operation = match item.external_name {
      Some(name) => CompositionOperation::Import(name)
      None => Definition
    }
    Some(self.composition_node(node, operation, item.kind))
  } else {
    item.value
  }
  if scope == 0 && item.kind is Type(ty) && value is Some(value) {
    if self.resource_root(ty) is Some(resource) &&
      resource_binding(self.composition_nodes[value].resources, resource)
      is Some(identity) {
      self.root_resources[resource] = identity
    }
  }
  self.scopes[scope].names[name] = { ..item, node, value, }
  self.bindings.push({ name, scope, node, target: node, })
  self.declarations.push({ name, scope, node, kind: item.kind, })
}

///|
fn Check::extern_item(
  self : Check,
  scope : Int32,
  node : Int32,
  name : String,
  kind : ItemKind,
  importing : Bool,
  value~ : Int32? = None,
) -> Unit raise SemanticFailure {
  if scope == 0 && !valid_external_name(name, importing) {
    raise Problem(
      self.problem(node, "WAC-S005", "invalid external name `" + name + "`"),
    )
  }
  let target = self.scopes[scope]
  let seen = if importing { target.import_nodes } else { target.export_nodes }
  if seen.get(name) is Some(first) {
    raise Problem(
      self.problem(
        node,
        "WAC-S004",
        "duplicate " +
        (if importing { "import" } else { "export" }) +
        " `" +
        name +
        "`",
        first=Some(first),
      ),
    )
  }
  seen[name] = node
  let items = if importing { target.imports } else { target.exports }
  items.push({ name, kind, location: self.location(node), })
  if scope == 0 && !importing {
    let value = match value {
      Some(value) => value
      None =>
        match target.names.get(name) {
          Some(item) =>
            match item.value {
              Some(value) => value
              None =>
                raise Problem(
                  self.problem(node, "WAC-S001", "missing composition value"),
                )
            }
          None =>
            raise Problem(
              self.problem(node, "WAC-S001", "missing composition value"),
            )
        }
    }
    self.composition_outputs.push({
      name,
      value,
      location: self.location(node),
    })
  }
}

///|
fn Check::add_type(
  self : Check,
  node : Int32,
  kind : TypeKind,
  name~ : String? = None,
) -> Int32 {
  let contains_borrow = match kind {
    Borrow(_) => true
    Alias(id) | List(id) | FixedList(id, _) | Option(id) => self.borrowed[id]
    Map(key, value) => self.borrowed[key] || self.borrowed[value]
    Tuple(ids) => ids.any(id => self.borrowed[id])
    Result(ok, error) =>
      ok.map(id => self.borrowed[id]).unwrap_or(false) ||
      error.map(id => self.borrowed[id]).unwrap_or(false)
    Future(payload) | Stream(payload) =>
      payload.map(id => self.borrowed[id]).unwrap_or(false)
    Record(fields) => fields.any(field => self.borrowed[field.ty])
    Variant(cases) =>
      cases.any(case => {
        case.payload.map(id => self.borrowed[id]).unwrap_or(false)
      })
    _ => false
  }
  let id = self.types.length()
  self.types.push({ id, name, kind, location: self.location(node), })
  self.borrowed.push(contains_borrow)
  id
}

///|
fn value_kind(kind : TypeKind) -> Bool {
  match kind {
    Resource(_) | Function(_, _, _) | Interface(_, _, _) | World(_, _, _, _) =>
      false
    _ => true
  }
}

///|
fn Check::promote(self : Check, kind : ItemKind) -> ItemKind {
  match kind {
    Type(id) =>
      match self.types[id].kind {
        Function(_, _, _) => Function(id)
        Interface(_, _, _) => Instance(id)
        World(_, _, _, _) => Component(id)
        _ => kind
      }
    _ => kind
  }
}

///|
fn Check::expression(
  self : Check,
  root : Int32,
) -> LocalItem raise SemanticFailure {
  let pending = [(root, false, false)]
  let values : Map[Int32, LocalItem] = Map([])
  let packages : Map[Int32, InstantiationPackage] = Map([])
  while pending.pop() is Some((node, finish, argument)) {
    let is_argument = match self.tree.nodes[node].data {
      NamedArgument(..)
      | InferredArgument(..)
      | SpreadArgument(..)
      | FillArgument => true
      _ => false
    }
    if is_argument != argument {
      raise Problem(
        self.problem(node, "WAC-S001", "invalid expression or argument role"),
      )
    }
    match self.tree.nodes[node].data {
      Expression(primary~, postfix~) =>
        if finish {
          let mut item = values[primary]
          let mut parent = primary
          for access in postfix {
            item = self.access(item, access, parent)
            parent = access
          }
          values[node] = item
        } else {
          pending.push((node, true, argument))
          pending.push((primary, false, false))
        }
      Group(expression~) =>
        if finish {
          values[node] = values[expression]
        } else {
          pending.push((node, true, argument))
          pending.push((expression, false, false))
        }
      Reference(name~) => values[node] = self.lookup(0, node, name)
      New(component~, arguments~) =>
        if finish {
          values[node] = self.instantiate(
            node,
            component,
            packages[node],
            arguments,
            values,
          )
        } else {
          packages[node] = self.instantiation_package(component)
          pending.push((node, true, argument))
          for i = arguments.length() - 1; i >= 0; i = i - 1 {
            pending.push((arguments[i], false, true))
          }
        }
      NamedArgument(value~, ..) =>
        if finish {
          values[node] = values[value]
        } else {
          pending.push((node, true, argument))
          pending.push((value, false, false))
        }
      InferredArgument(name~) => values[node] = self.lookup(0, node, name)
      SpreadArgument(_) => ()
      FillArgument =>
        raise Problem(
          self.problem(
            node, "WAC-S003", "implicit instantiation arguments are not yet supported",
          ),
        )
      _ =>
        raise Problem(self.problem(node, "WAC-S001", "invalid expression role"))
    }
  }
  values[root]
}

///|
/// WAC names resolve in declaration order. Each returned graph is immutable and
/// contains no unresolved names. Nested values and expressions use work stacks.
pub fn verify_ast(
  tree : @ast.Tree,
  source_id~ : String = "<input>",
  source~ : String,
  dependencies~ : ReadOnlyArray[PackageSource] = [],
) -> Result[Verified, ReadOnlyArray[Diagnostic]] {
  guard tree.validate() && !tree.nodes.is_empty() else {
    return Err([
      error(
        source_id,
        { start: 0, end: 0, },
        "WAC-S001",
        "invalid AST structure",
      ),
    ])
  }
  for node in tree.nodes {
    guard node.span.start >= 0 && node.span.end <= source.length() else {
      return Err([
        error(
          source_id,
          node.span,
          "WAC-S001",
          "AST location is outside its source",
        ),
      ])
    }
  }
  let check : Check = {
    tree,
    source_id,
    types: [],
    borrowed: [],
    values: Array::make(tree.nodes.length(), -1),
    scopes: [Scope::new()],
    bindings: [],
    declarations: [],
    composition_nodes: [],
    composition_outputs: [],
    composition_aliases: Map([]),
    root_resources: Map([]),
    next_resource_identity: 0,
    package_name: "",
    package_version: None,
    dependencies: Map([]),
    loaded_packages: Map([]),
  }
  try {
    check.register_packages(dependencies)
    check.file(tree.nodes.length() - 1)
    check.verify_target()
    Ok({
      source_id,
      source_text: source,
      composition_nodes: ReadOnlyArray::from_array(check.composition_nodes),
      composition_outputs: ReadOnlyArray::from_array(check.composition_outputs),
      tree,
      bindings: ReadOnlyArray::from_array(check.bindings),
      resolved_types: ReadOnlyArray::from_array(check.types),
      resolved_declarations: ReadOnlyArray::from_array(check.declarations),
      resolved_imports: ReadOnlyArray::from_array(check.scopes[0].imports),
      resolved_exports: ReadOnlyArray::from_array(check.scopes[0].exports),
    })
  } catch {
    Problem(diagnostic) => Err([diagnostic])
  }
}
