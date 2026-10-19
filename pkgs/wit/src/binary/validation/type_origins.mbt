///|
fn Counts::type_origin(self : Counts, index : Int32) -> TypeOrigin? {
  if self.type_origins.get(index) is Some(origin) {
    return Some(origin)
  }
  if self.type_metadata.get(index) is Some((metadata, root)) {
    return metadata.origins.get(root).bind(x => x)
  }
  Some({ scope: self.origin_scope, index, })
}

///|
fn Counts::origin_table(
  self : Counts,
  bound : Int32,
) -> Array[TypeOrigin?] raise ComponentValidationError {
  if bound < 0 || bound > self.metadata_remaining {
    raise UnsupportedComponentAscription
  }
  self.metadata_remaining -= bound
  Array::makei(bound, index => self.type_origin(index))
}

///|
fn Counts::new_origin_scope(
  self : Counts,
) -> Int32 raise ComponentValidationError {
  if self.metadata_remaining <= 0 {
    raise UnsupportedComponentAscription
  }
  self.metadata_remaining -= 1
  let scope = self.next_origin_scope
  self.next_origin_scope += 1
  scope
}

///|
fn Counts::function_signature(
  self : Counts,
  function : @component.FuncType,
  types : Array[@component.TypeDef?],
  resources : Array[Int32?],
) -> CompleteFunctionSignature raise ComponentValidationError {
  let origins = self.origin_table(types.length())
  let signature = metadata_global_function(
    function,
    types,
    resources,
    self.type_metadata,
    self.metadata_remaining,
    global_origins=origins,
  )
  self.metadata_remaining -= signature.work
  signature
}

///|
fn check_origin_values(
  roots : Array[@component.ValType],
  types : Array[@component.TypeDef?],
  origins : Array[TypeOrigin?],
  resources : Array[Int32?],
  named : Map[TypeOrigin, Bool],
  named_resources : Map[Int32, Bool],
  counts : Counts,
) -> Unit raise ComponentValidationError {
  if roots.length() > counts.metadata_remaining {
    raise UnsupportedComponentAscription
  }
  counts.metadata_remaining -= roots.length()
  let work = roots.copy()
  let seen : Map[Int32, Bool] = Map([])
  fn push(value : @component.ValType) -> Unit raise ComponentValidationError {
    if counts.metadata_remaining <= 0 {
      raise UnsupportedComponentAscription
    }
    counts.metadata_remaining -= 1
    work.push(value)
  }
  while work.pop() is Some(value) {
    guard value is TypeIdx(index) else { continue }
    if seen.contains(index) {
      continue
    }
    seen[index] = true
    guard types.get(index) is Some(Some(definition)) else {
      raise UnsupportedComponentAscription
    }
    if typedef_requires_name_for_interface(definition) {
      let visible = match resources.get(index) {
        Some(Some(resource)) => named_resources.contains(resource)
        _ =>
          match origins.get(index) {
            Some(Some(origin)) => named.contains(origin)
            _ => false
          }
      }
      if !visible {
        raise SectionParseError(11, "export exposes an unnamed type origin")
      }
    }
    match definition {
      Tuple(values) =>
        for value in values {
          push(value)
        }
      Record(fields) =>
        for field in fields {
          push(field.ty)
        }
      Variant(cases) =>
        for case in cases {
          if case.ty is Some(value) {
            push(value)
          }
        }
      Option(value) | List(value) | FixedList(value, _) => push(value)
      MapType(key, value) => {
        push(key)
        push(value)
      }
      Result(ok, error) => {
        if ok is Some(value) {
          push(value)
        }
        if error is Some(value) {
          push(value)
        }
      }
      Own(index) | Borrow(index) => push(TypeIdx(index))
      Future(value) | Stream(value) => if value is Some(value) { push(value) }
      FuncType(_) | ComponentType(_) | InstanceType(_) | InstanceTypeEmpty =>
        raise UnsupportedComponentAscription
      _ => ()
    }
  }
}

///|
fn Counts::check_instance_origins(
  self : Counts,
  graph : ScopedContractMetadata,
  root : Int32,
  root_names : Map[Int32, Int32],
  root_resources : Array[Int32?],
) -> Unit raise ComponentValidationError {
  let cost = self.visible_origins.length() + self.visible_resources.length()
  if cost > self.metadata_remaining {
    raise UnsupportedComponentAscription
  }
  self.metadata_remaining -= cost
  let named = self.visible_origins.copy()
  let resources = self.visible_resources.copy()
  fn charge() -> Unit raise ComponentValidationError {
    if self.metadata_remaining <= 0 {
      raise UnsupportedComponentAscription
    }
    self.metadata_remaining -= 1
  }
  for index in root_names.keys() {
    charge()
    if self.type_origin(index) is Some(origin) {
      named[origin] = true
    }
    if root_resources.get(index) is Some(Some(resource)) {
      resources[resource] = true
    }
  }
  let work = [root]
  let seen : Map[Int32, Bool] = Map([])
  let nodes : Array[Int32] = []
  while work.pop() is Some(index) {
    charge()
    if seen.contains(index) {
      continue
    }
    seen[index] = true
    guard graph.nodes.get(index) is Some(node) else {
      raise UnsupportedComponentAscription
    }
    nodes.push(index)
    for (name, sort) in node.exports.sorts {
      charge()
      if sort is Type && node.exports.types.get(name) is Some(ty) {
        if graph.origins.get(ty) is Some(Some(origin)) {
          named[origin] = true
        }
        if graph.resources.get(ty) is Some(Some(resource)) {
          resources[resource] = true
        }
      }
      if sort is Instance && node.exports.children.get(name) is Some(child) {
        work.push(child)
      }
    }
  }
  for index in nodes {
    let members = graph.nodes[index].exports
    let roots : Array[@component.ValType] = []
    for ty in members.types.values() {
      charge()
      roots.push(TypeIdx(ty))
    }
    check_origin_values(
      roots,
      graph.types,
      graph.origins,
      graph.resources,
      named,
      resources,
      self,
    )
    for signature in members.values.values() {
      charge()
      guard signature.function.result is Some(value) else {
        raise UnsupportedComponentAscription
      }
      check_origin_values(
        [value],
        signature.types,
        signature.origins,
        signature.resources,
        named,
        resources,
        self,
      )
    }
    for function in members.functions.values() {
      charge()
      guard function.complete is Some(signature) else {
        raise UnsupportedComponentAscription
      }
      let values : Array[@component.ValType] = []
      for param in signature.function.params {
        charge()
        values.push(param.ty)
      }
      if signature.function.result is Some(value) {
        charge()
        values.push(value)
      }
      check_origin_values(
        values,
        signature.types,
        signature.origins,
        signature.resources,
        named,
        resources,
        self,
      )
    }
  }
}

///|
fn Counts::check_function_origins(
  self : Counts,
  signature : CompleteFunctionSignature,
  root_names : Map[Int32, Int32],
  root_resources : Array[Int32?],
  visible~ : Bool = true,
) -> Unit raise ComponentValidationError {
  let cost = self.visible_origins.length() + self.visible_resources.length()
  if cost > self.metadata_remaining {
    raise UnsupportedComponentAscription
  }
  self.metadata_remaining -= cost
  let named = if visible { self.visible_origins.copy() } else { Map([]) }
  let resources = if visible { self.visible_resources.copy() } else { Map([]) }
  if root_names.length() + signature.function.params.length() + 1 >
    self.metadata_remaining {
    raise UnsupportedComponentAscription
  }
  self.metadata_remaining -= root_names.length() +
    signature.function.params.length() +
    1
  for index in root_names.keys() {
    if self.type_origin(index) is Some(origin) {
      named[origin] = true
    }
    if root_resources.get(index) is Some(Some(resource)) {
      resources[resource] = true
    }
  }
  let roots = signature.function.params.map(param => param.ty)
  if signature.function.result is Some(result) {
    roots.push(result)
  }
  check_origin_values(
    roots,
    signature.types,
    signature.origins,
    signature.resources,
    named,
    resources,
    self,
  )
}

///|
fn Counts::name_instance_origins(
  self : Counts,
  graph : ScopedContractMetadata,
  root : Int32,
) -> Unit raise ComponentValidationError {
  let work = [root]
  let seen : Map[Int32, Bool] = Map([])
  while work.pop() is Some(index) {
    if self.metadata_remaining <= 0 {
      raise UnsupportedComponentAscription
    }
    self.metadata_remaining -= 1
    if seen.contains(index) {
      continue
    }
    seen[index] = true
    guard graph.nodes.get(index) is Some(node) else {
      raise UnsupportedComponentAscription
    }
    for (name, sort) in node.exports.sorts {
      if self.metadata_remaining <= 0 {
        raise UnsupportedComponentAscription
      }
      self.metadata_remaining -= 1
      if sort is Type && node.exports.types.get(name) is Some(ty) {
        if graph.origins.get(ty) is Some(Some(origin)) {
          self.visible_origins[origin] = true
        }
        if graph.resources.get(ty) is Some(Some(resource)) {
          self.visible_resources[resource] = true
        }
      }
      if sort is Instance && node.exports.children.get(name) is Some(child) {
        work.push(child)
      }
    }
  }
}

///|
fn Counts::contract_origin_scope(
  self : Counts,
  index : Int32,
  scoped : Bool,
) -> Int32 raise ComponentValidationError {
  guard self.type_origin(index) is Some(origin) else {
    raise UnsupportedComponentAscription
  }
  let key = (origin, scoped)
  if self.origin_scopes.get(key) is Some(scope) {
    return scope
  }
  let scope = self.new_origin_scope()
  self.origin_scopes[key] = scope
  scope
}

///|
fn Counts::check_outer_value_resources(
  self : Counts,
  types : Array[@component.TypeDef?],
  root : Int32,
) -> Unit raise ComponentValidationError {
  let work = [root]
  let seen : Map[Int32, Bool] = Map([])
  fn value(
    v : @component.ValType,
  ) -> @component.ValType raise IncompleteFunctionSignature {
    if self.metadata_remaining <= 0 {
      raise SignatureBudgetExceeded
    }
    self.metadata_remaining -= 1
    if v is TypeIdx(index) {
      work.push(index)
    }
    v
  }
  while work.pop() is Some(index) {
    if self.metadata_remaining <= 0 {
      raise UnsupportedComponentAscription
    }
    self.metadata_remaining -= 1
    if seen.contains(index) {
      continue
    }
    seen[index] = true
    guard types.get(index) is Some(Some(td)) else {
      raise UnsupportedComponentAscription
    }
    if td is ResourceType(_, _, _, _) || td is Own(_) || td is Borrow(_) {
      raise SectionParseError(
        6, "refers to resources not defined in the current component",
      )
    }
    try {
      match td {
        FuncType(ft) => {
          for parameter in ft.params {
            ignore(value(parameter.ty))
          }
          if ft.result is Some(result) {
            ignore(value(result))
          }
        }
        _ => ignore(signature_definition(td, value))
      }
    } catch {
      _ => raise UnsupportedComponentAscription
    }
  }
}
