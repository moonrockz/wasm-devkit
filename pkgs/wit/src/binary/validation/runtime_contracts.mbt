// Complete metadata for runtime component instances. No component executes here.

///|
priv struct RuntimeContractBuilder {
  counts : Counts
  type_bound : Int32
  types : Array[@component.TypeDef?]
  resources : Array[Int32?]
  nodes : Array[ScopedContractNode]
  locals : Map[Int32, Bool]
}

///|
fn RuntimeContractBuilder::charge(
  self : RuntimeContractBuilder,
  count : Int32,
) -> Unit raise ComponentValidationError {
  if count < 0 || count > self.counts.metadata_remaining {
    raise SectionParseError(5, "runtime contract metadata work limit exceeded")
  }
  self.counts.metadata_remaining -= count
}

///|
fn RuntimeContractBuilder::graph(
  self : RuntimeContractBuilder,
) -> ScopedContractMetadata {
  {
    types: self.types,
    resources: self.resources,
    nodes: self.nodes,
    locals: self.locals,
  }
}

///|
fn RuntimeContractBuilder::append_types(
  self : RuntimeContractBuilder,
  types : Array[@component.TypeDef?],
  resources : Array[Int32?],
) -> Int32 raise ComponentValidationError {
  self.charge(types.length() + resources.length())
  let base = self.types.length()
  fn value(
    v : @component.ValType,
  ) -> @component.ValType raise IncompleteFunctionSignature {
    self.charge(1) catch {
      _ => raise SignatureBudgetExceeded
    }
    match v {
      Prim(_) => v
      TypeIdx(i) => TypeIdx(base + i)
    }
  }
  for i in 0..<types.length() {
    let td = match types[i] {
      None => None
      Some(ComponentType(_) | InstanceType(_) | InstanceTypeEmpty) => None
      Some(FuncType(ft)) =>
        Some(
          @component.TypeDef::FuncType({
            ..ft,
            params: ft.params.map(p => {
              ..p,
              ty: value(p.ty) catch {
                _ => raise UnsupportedComponentAscription
              },
            }),
            result: ft.result.map(v => {
              value(v) catch {
                _ => raise UnsupportedComponentAscription
              }
            }),
          }),
        )
      Some(td) =>
        Some(
          signature_definition(td, value) catch {
            _ => raise UnsupportedComponentAscription
          },
        )
    }
    self.types.push(td)
    self.resources.push(resources.get(i).bind(r => r))
  }
  base
}

///|
fn RuntimeContractBuilder::append(
  self : RuntimeContractBuilder,
  graph : ScopedContractMetadata,
  root : Int32,
) -> Int32 raise ComponentValidationError {
  self.charge(graph.nodes.length() + graph.locals.length())
  guard root >= 0 && root < graph.nodes.length() else {
    raise UnsupportedComponentAscription
  }
  let type_base = self.append_types(graph.types, graph.resources)
  let node_base = self.nodes.length()
  fn members(
    source : ContractMembers,
  ) -> ContractMembers raise ComponentValidationError {
    self.charge(
      source.sorts.length() +
      source.types.length() +
      source.functions.length() +
      source.children.length() +
      source.modules.length() +
      source.direct_modules.length() +
      source.binders.length(),
    )
    let result = ContractMembers::new()
    for (name, sort) in source.sorts {
      // Runtime value contracts require origin and consumption evidence before
      // they can pass through this builder. Never silently drop their graphs.
      if sort is Value {
        raise UnsupportedComponentAscription
      }
      result.sorts[name] = sort
    }
    for (name, ty) in source.types {
      result.types[name] = type_base + ty
    }
    for (name, function) in source.functions {
      result.functions[name] = function
    }
    for (name, child) in source.children {
      result.children[name] = node_base + child
    }
    for (name, index) in source.modules {
      result.modules[name] = index
    }
    for (name, contract) in source.direct_modules {
      result.direct_modules[name] = contract
    }
    for (name, binder) in source.binders {
      result.binders[name] = binder
    }
    result
  }
  for node in graph.nodes {
    self.nodes.push({
      ..node,
      imports: members(node.imports),
      exports: members(node.exports),
    })
  }
  for (resource, is_local) in graph.locals {
    self.locals[resource] = is_local
  }
  node_base + root
}

///|
fn runtime_contract_builder(
  counts : Counts,
  types : Array[@component.TypeDef?],
  resources : Array[Int32?],
) -> RuntimeContractBuilder raise ComponentValidationError {
  let type_bound = types.length()
  let (types, resources, remaining) = metadata_global_types(
    types,
    resources,
    counts.type_metadata,
    counts.metadata_remaining,
  ) catch {
    _ => raise UnsupportedComponentAscription
  }
  counts.metadata_remaining = remaining
  {
    counts,
    type_bound,
    types,
    resources,
    nodes: [
      {
        imports: ContractMembers::new(),
        exports: ContractMembers::new(),
        component: false,
        core_scope: Some(0),
      },
    ],
    locals: Map([]),
  }
}

///|
fn runtime_argument(
  builder : RuntimeContractBuilder,
  members : ContractMembers,
  name : String,
  argument : @component.SortIdx,
  functions : Array[FuncSigShape?],
) -> Unit raise ComponentValidationError {
  builder.charge(1)
  check_sortidx(argument, builder.counts, builder.type_bound)
  if members.sorts.contains(name) {
    raise DuplicateInstantiationArg(name)
  }
  members.sorts[name] = argument.sort
  match argument.sort {
    Type => members.types[name] = argument.idx
    Func => {
      guard functions.get(argument.idx) is Some(Some(function)) &&
        function.complete is Some(_) else {
        raise UnsupportedComponentAscription
      }
      members.functions[name] = function
    }
    Instance | Component => {
      let binding = match argument.sort {
        Instance => builder.counts.instance_contracts.get(argument.idx)
        _ => builder.counts.component_contracts.get(argument.idx)
      }
      guard binding is Some((graph, node)) else {
        raise UnsupportedComponentAscription
      }
      members.children[name] = builder.append(graph, node)
    }
    Core(0x11) => {
      guard builder.counts.core_contracts is Some(graph) &&
        graph.scope(0) is Some(scope) &&
        scope.binding(0x111, argument.idx) is Some(Module(contract)) else {
        raise UnsupportedComponentAscription
      }
      members.direct_modules[name] = contract
    }
    _ => raise UnsupportedComponentAscription
  }
}

///|
fn runtime_fresh_exports(
  graph : ScopedContractMetadata,
  root : Int32,
  substitutions : Map[Int32, Int32],
  next : Int32,
  counts : Counts,
) -> Int32 raise ComponentValidationError {
  let mut next = next
  let work = [root]
  let seen : Map[Int32, Bool] = Map([])
  while work.pop() is Some(node) {
    counts.metadata_remaining -= 1
    if counts.metadata_remaining < 0 {
      raise UnsupportedComponentAscription
    }
    if seen.contains(node) {
      continue
    }
    seen[node] = true
    guard graph.nodes.get(node) is Some(node) else {
      raise UnsupportedComponentAscription
    }
    let names = node.exports.sorts.keys().to_array()
    names.sort()
    for name in names {
      counts.metadata_remaining -= 1
      if counts.metadata_remaining < 0 {
        raise UnsupportedComponentAscription
      }
      if node.exports.binders.contains(name) &&
        node.exports.types.get(name) is Some(ty) &&
        graph.resources.get(ty) is Some(Some(resource)) &&
        !substitutions.contains(resource) {
        substitutions[resource] = next
        next += 1
      }
      if node.exports.sorts[name] is Instance &&
        node.exports.children.get(name) is Some(child) {
        work.push(child)
      }
    }
  }
  next
}

///|
fn runtime_substitute(
  graph : ScopedContractMetadata,
  substitutions : Map[Int32, Int32],
  counts : Counts,
) -> ScopedContractMetadata raise ComponentValidationError {
  let builder : RuntimeContractBuilder = {
    counts,
    type_bound: 0,
    types: [],
    resources: [],
    nodes: [],
    locals: Map([]),
  }
  ignore(builder.append(graph, 0))
  for i in 0..<builder.resources.length() {
    builder.charge(1)
    builder.resources[i] = builder.resources[i].map(r => {
      substitutions.get(r).unwrap_or(r)
    })
  }
  for node in builder.nodes {
    for members in [node.imports, node.exports] {
      let names = members.functions.keys().to_array()
      names.sort()
      for name in names {
        builder.charge(1)
        guard members.functions[name].complete is Some(signature) else {
          raise UnsupportedComponentAscription
        }
        builder.charge(signature.resources.length())
        let resources = signature.resources.map(r => {
          r.map(r => substitutions.get(r).unwrap_or(r))
        })
        let (function, remaining) = metadata_function(
          signature.function,
          signature.types,
          resources,
          counts.metadata_remaining,
        ) catch {
          _ => raise UnsupportedComponentAscription
        }
        counts.metadata_remaining = remaining
        members.functions[name] = function
      }
    }
  }
  builder.charge(substitutions.length())
  for resource in substitutions.keys() {
    builder.locals.remove(resource) |> ignore
  }
  builder.graph()
}

///|
fn runtime_instance_metadata(
  graph : ScopedContractMetadata,
  root : Int32,
  counts : Counts,
) -> InstanceMetadata raise ComponentValidationError {
  if graph.nodes.length() > counts.metadata_remaining {
    raise UnsupportedComponentAscription
  }
  counts.metadata_remaining -= graph.nodes.length()
  let nodes : Array[InstanceMetadataNode] = []
  let signatures : Array[InstanceSig] = []
  for node in graph.nodes {
    nodes.push({
      exports: node.exports.sorts,
      types: node.exports.types,
      functions: node.exports.functions,
      children: node.exports.children,
    })
    signatures.push({ exports: node.exports.sorts, nested: Map([]), })
  }
  let work = [root]
  let seen : Map[Int32, Bool] = Map([])
  while work.pop() is Some(id) {
    counts.metadata_remaining -= 1
    if counts.metadata_remaining < 0 {
      raise UnsupportedComponentAscription
    }
    if seen.contains(id) {
      continue
    }
    seen[id] = true
    for (name, child) in nodes[id].children {
      counts.metadata_remaining -= 1
      if counts.metadata_remaining < 0 {
        raise UnsupportedComponentAscription
      }
      guard signatures.get(child) is Some(signature) else {
        raise UnsupportedComponentAscription
      }
      signatures[id].nested[name] = signature
      work.push(child)
    }
  }
  { nodes, signatures, types: graph.types, resources: graph.resources, }
}

///|
fn runtime_component_instance(
  declaration : @component.Instance,
  cfg : ComponentValidationConfig,
  counts : Counts,
  types : Array[@component.TypeDef?],
  resources : Array[Int32?],
  functions : Array[FuncSigShape?],
  next_resource : Int32,
) -> (ScopedContractMetadata, Int32, Int32) raise ComponentValidationError {
  let builder = runtime_contract_builder(counts, types, resources)
  let members = builder.nodes[0].exports
  match declaration.expr {
    InlineExports(exports) => {
      for item in exports {
        validate_name_attributes_string(
          5,
          item.name,
          item.attributes,
          item.sortidx.sort,
          cfg,
        )
        if cfg.wit_names && parse_bracket_resource_name(item.name) is Some(_) {
          raise SectionParseError(
            5, "resource used in function does not have a name in this context",
          )
        }
        validate_extern_name_string(item.name, cfg)
        runtime_argument(builder, members, item.name, item.sortidx, functions)
      }
      (builder.graph(), 0, next_resource)
    }
    Instantiate(index, arguments) => {
      if index < 0 || index >= counts.component {
        raise InvalidComponentIndex(index)
      }
      guard counts.component_contracts.get(index) is Some((template, root)) &&
        template.nodes.get(root) is Some(node) &&
        node.component else {
        raise UnsupportedComponentAscription
      }
      for argument in arguments {
        if argument.sortidx.sort is Type &&
          !(resources.get(argument.sortidx.idx) is Some(Some(_))) {
          raise UnsupportedComponentAscription
        }
        runtime_argument(
          builder,
          members,
          argument.name,
          argument.sortidx,
          functions,
        )
      }
      builder.charge(template.nodes.length())
      let nodes = template.nodes.copy()
      nodes[root] = {
        ..node,
        component: false,
        imports: ContractMembers::new(),
        exports: node.imports,
      }
      let required = { ..template, nodes, }
      let substitutions : Map[Int32, Int32] = Map([])
      counts.ascription_remaining = check_scoped_contract(
        builder.graph(),
        required,
        counts.ascription_remaining,
        core_contracts=counts.core_contracts,
        expected_node=root,
        binders=true,
        bindings=Some(substitutions),
      )
      let next = runtime_fresh_exports(
        template, root, substitutions, next_resource, counts,
      )
      let result = runtime_substitute(template, substitutions, counts)
      result.nodes[root] = {
        ..result.nodes[root],
        component: false,
        imports: ContractMembers::new(),
      }
      (result, root, next)
    }
  }
}
