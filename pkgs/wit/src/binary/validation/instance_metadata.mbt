// Original wasm-devkit scoped metadata for imported instance aliases.

///|
priv struct InstanceMetadataNode {
  exports : Map[String, @component.Sort]
  types : Map[String, Int32]
  functions : Map[String, FuncSigShape]
  children : Map[String, Int32]
}

///|
priv struct InstanceMetadata {
  nodes : Array[InstanceMetadataNode]
  signatures : Array[InstanceSig]
  types : Array[@component.TypeDef?]
  resources : Array[Int32?]
}

///|
priv struct InstanceMetadataScope {
  parent : Int32?
  types : Array[Int32]
  instances : Array[Int32]
  declarations : Array[@component.InstanceDecl]
  mut position : Int32
  node : Int32
}

///|
fn imported_instance_metadata(
  td : @component.TypeDef,
  global_types : Array[@component.TypeDef?],
  global_resources : Array[Int32?],
  root_resources : Map[String, Int32],
  bindings : Map[Int32, (InstanceMetadata, Int32)],
  next_resource : Int32,
  budget : Int32,
) -> (InstanceMetadata?, Int32, Int32) {
  let mut next_resource = next_resource
  let mut remaining = budget
  try {
    let (types, resources, rest) = metadata_global_types(
      global_types, global_resources, bindings, remaining,
    )
    remaining = rest
    let nodes : Array[InstanceMetadataNode] = []
    let scopes : Array[InstanceMetadataScope] = [
      {
        parent: None,
        types: Array::makei(global_types.length(), i => i),
        instances: [],
        declarations: [],
        position: 0,
        node: -1,
      },
    ]
    let origins : Map[Int32, Int32] = Map([])
    fn step() -> Unit raise IncompleteFunctionSignature {
      remaining -= 1
      if remaining < 0 {
        raise SignatureBudgetExceeded
      }
    }
    fn declarations(
      td : @component.TypeDef,
    ) -> Array[@component.InstanceDecl] raise IncompleteFunctionSignature {
      match td {
        InstanceType(ds) => ds
        InstanceTypeEmpty => []
        _ => raise IncompleteFunctionSignature
      }
    }
    fn add_scope(
      td : @component.TypeDef,
      parent : Int32,
    ) -> Int32 raise IncompleteFunctionSignature {
      step()
      let node = nodes.length()
      nodes.push({
        exports: Map([]),
        types: Map([]),
        functions: Map([]),
        children: Map([]),
      })
      let index = scopes.length()
      scopes.push({
        parent: Some(parent),
        types: [],
        instances: [],
        declarations: declarations(td),
        position: 0,
        node,
      })
      index
    }
    fn type_index(
      scope : Int32,
      index : Int32,
    ) -> Int32 raise IncompleteFunctionSignature {
      step()
      guard scopes[scope].types.get(index) is Some(index) else {
        raise IncompleteFunctionSignature
      }
      index
    }
    fn value(
      scope : Int32,
      ty : @component.ValType,
    ) -> @component.ValType raise IncompleteFunctionSignature {
      step()
      match ty {
        Prim(_) => ty
        TypeIdx(index) => TypeIdx(type_index(scope, index))
      }
    }
    let root = add_scope(td, 0)
    let stack = [root]
    while stack.last() is Some(index) {
      step()
      let scope = scopes[index]
      if scope.position >= scope.declarations.length() {
        ignore(stack.pop())
        continue
      }
      let declaration = scope.declarations[scope.position]
      scope.position += 1
      let node = nodes[scope.node]
      match declaration {
        Type(td) => {
          let slot = types.length()
          let mapped = match td {
            InstanceType(_) | InstanceTypeEmpty | ComponentType(_) => td
            FuncType(ft) =>
              FuncType({
                ..ft,
                params: ft.params.map(p => { ..p, ty: value(index, p.ty), }),
                result: ft.result.map(t => value(index, t)),
              })
            _ => signature_definition(td, t => value(index, t))
          }
          types.push(Some(mapped))
          resources.push(None)
          origins[slot] = index
          scope.types.push(slot)
        }
        AliasOuter(kind, count, original) => {
          guard kind == 0x03 && count >= 0 else {
            raise IncompleteFunctionSignature
          }
          let mut owner = index
          for depth = 0; depth < count; depth = depth + 1 {
            step()
            guard scopes[owner].parent is Some(parent) else {
              raise IncompleteFunctionSignature
            }
            owner = parent
          }
          scope.types.push(type_index(owner, original))
        }
        AliasInstanceExport(kind, instance, name) => {
          guard scope.instances.get(instance) is Some(child) else {
            raise IncompleteFunctionSignature
          }
          if kind == 0x03 {
            guard nodes[child].types.get(name) is Some(ty) else {
              raise IncompleteFunctionSignature
            }
            scope.types.push(ty)
          } else {
            raise IncompleteFunctionSignature
          }
        }
        Export(name, _, desc) => {
          node.exports[name] = sort_of_externdesc(desc)
          match desc {
            Type(SubResource) => {
              let resource = if index == root &&
                root_resources.get(name) is Some(id) {
                id
              } else {
                let id = next_resource
                next_resource += 1
                id
              }
              let slot = types.length()
              types.push(Some(ResourceType(-1, 0x7f, None, HostDefined)))
              resources.push(Some(resource))
              scope.types.push(slot)
              node.types[name] = slot
            }
            Type(Eq(original)) => {
              let ty = type_index(index, original)
              scope.types.push(ty)
              node.types[name] = ty
            }
            FuncType(original) => {
              let ty = type_index(index, original)
              guard types.get(ty) is Some(Some(FuncType(ft))) else {
                raise IncompleteFunctionSignature
              }
              let (signature, rest) = metadata_function(
                ft, types, resources, remaining,
              )
              remaining = rest
              node.functions[name] = signature
            }
            InstanceType(original) => {
              let ty = type_index(index, original)
              guard types.get(ty) is Some(Some(child)) else {
                raise IncompleteFunctionSignature
              }
              let child_scope = add_scope(child, origins.get(ty).unwrap_or(0))
              let child_node = scopes[child_scope].node
              node.children[name] = child_node
              scope.instances.push(child_node)
              stack.push(child_scope)
            }
            _ => ()
          }
        }
        CoreType(_) => ()
      }
    }
    let signatures : Array[InstanceSig] = Array::makei(nodes.length(), _ => {
      InstanceSig::empty()
    })
    for index = nodes.length() - 1; index >= 0; index = index - 1 {
      step()
      let nested : Map[String, InstanceSig] = Map([])
      for name, child in nodes[index].children {
        step()
        nested[name] = signatures[child]
      }
      signatures[index] = { exports: nodes[index].exports, nested, }
    }
    (Some({ nodes, signatures, types, resources, }), next_resource, remaining)
  } catch {
    SignatureBudgetExceeded => (None, next_resource, 0)
    IncompleteFunctionSignature => (None, next_resource, remaining.max(0))
  }
}

///|
fn metadata_instance_sig(
  metadata : InstanceMetadata,
  root : Int32,
) -> InstanceSig {
  metadata.signatures[root]
}

///|
// Preserve the legacy comparison vocabulary without recursively expanding a
// nested value graph. Complete signatures separately retain every value kind.
fn metadata_function(
  ft : @component.FuncType,
  types : Array[@component.TypeDef?],
  resources : Array[Int32?],
  budget : Int32,
) -> (FuncSigShape, Int32) raise IncompleteFunctionSignature {
  let complete = complete_function_signature(
    ft,
    [],
    [],
    types,
    resources,
    budget~,
  )
  guard complete is Some(complete) else { raise IncompleteFunctionSignature }
  let values : Map[Int32, TypeSig] = Map([])
  let active : Map[Int32, Bool] = Map([])
  let stack : Array[(Int32, Bool)] = []
  let mut remaining = budget - complete.work
  fn step() -> Unit raise IncompleteFunctionSignature {
    remaining -= 1
    if remaining < 0 {
      raise SignatureBudgetExceeded
    }
  }
  fn enqueue(
    ty : @component.ValType,
  ) -> Unit raise IncompleteFunctionSignature {
    step()
    if ty is TypeIdx(id) {
      stack.push((id, false))
    }
  }
  fn value(ty : @component.ValType) -> TypeSig {
    match ty {
      Prim(p) => Prim(p)
      TypeIdx(id) => values.get(id).unwrap_or(Other)
    }
  }
  for p in ft.params {
    enqueue(p.ty)
  }
  if ft.result is Some(v) {
    enqueue(v)
  }
  while stack.pop() is Some((id, finish)) {
    step()
    if values.contains(id) {
      continue
    }
    guard types.get(id) is Some(Some(td)) else {
      values[id] = Other
      continue
    }
    if !finish {
      if active.contains(id) {
        values[id] = Other
        continue
      }
      active[id] = true
      stack.push((id, true))
      match td {
        Tuple(vs) =>
          for v in vs {
            enqueue(v)
          }
        Record(fs) =>
          for f in fs {
            enqueue(f.ty)
          }
        Variant(cs) =>
          for c in cs {
            if c.ty is Some(v) {
              enqueue(v)
            }
          }
        Option(v) | List(v) => enqueue(v)
        Result(ok, err) => {
          if ok is Some(v) {
            enqueue(v)
          }
          if err is Some(v) {
            enqueue(v)
          }
        }
        _ => ()
      }
      continue
    }
    values[id] = match td {
      DefValType(p) => Prim(p)
      ResourceType(_, _, _, _) =>
        resources
        .get(id)
        .bind(x => x)
        .map(r => TypeSig::Resource(r))
        .unwrap_or(Other)
      Own(r) =>
        resources.get(r).bind(x => x).map(r => TypeSig::Own(r)).unwrap_or(Other)
      Borrow(r) =>
        resources
        .get(r)
        .bind(x => x)
        .map(r => TypeSig::Borrow(r))
        .unwrap_or(Other)
      Tuple(vs) => Tuple(vs.map(value))
      Record(fs) => Record(fs.map(f => { name: f.label, ty: value(f.ty), }))
      Variant(cs) =>
        Variant(cs.map(c => { name: c.label, ty: c.ty.map(value), }))
      Option(v) => Option(value(v))
      List(v) => List(value(v))
      Result(ok, err) => Result(ok.map(value), err.map(value))
      Flags(labels) => Flags(labels)
      Enum(labels) => Enum(labels)
      _ => Other
    }
  }
  (
    {
      params: ft.params.map(p => { name: p.label, ty: value(p.ty), }),
      result: ft.result.map(value),
      complete: Some(complete),
    },
    remaining,
  )
}

///|
// External value aliases keep their own graph space. Copy reachable nodes
// into a private signature table, never into the binary's type index space.
fn metadata_global_function(
  ft : @component.FuncType,
  global_types : Array[@component.TypeDef?],
  global_resources : Array[Int32?],
  bindings : Map[Int32, (InstanceMetadata, Int32)],
  budget : Int32,
) -> CompleteFunctionSignature raise ComponentValidationError {
  try {
    let types : Array[@component.TypeDef?] = []
    let resources : Array[Int32?] = []
    let spaces : Array[InstanceMetadata] = []
    let external : Map[Int32, (Int32, Int32)] = Map([])
    let mapped : Map[(Int32, Int32), Int32] = Map([])
    let pending : Array[(Int32, Int32)] = []
    let mut remaining = budget
    fn step() -> Unit raise IncompleteFunctionSignature {
      remaining -= 1
      if remaining < 0 {
        raise SignatureBudgetExceeded
      }
    }
    fn value(
      ty : @component.ValType,
      space : Int32,
    ) -> @component.ValType raise IncompleteFunctionSignature {
      step()
      match ty {
        Prim(_) => ty
        TypeIdx(original) => {
          let key = if space == -1 &&
            bindings.get(original) is Some((metadata, root)) {
            match external.get(original) {
              Some(key) => key
              None => {
                let key = (spaces.length(), root)
                spaces.push(metadata)
                external[original] = key
                key
              }
            }
          } else {
            (space, original)
          }
          let slot = match mapped.get(key) {
            Some(slot) => slot
            None => {
              let slot = types.length()
              mapped[key] = slot
              pending.push(key)
              types.push(None)
              resources.push(None)
              slot
            }
          }
          TypeIdx(slot)
        }
      }
    }
    let function : @component.FuncType = {
      ..ft,
      params: ft.params.map(p => { ..p, ty: value(p.ty, -1), }),
      result: ft.result.map(t => value(t, -1)),
    }
    while pending.pop() is Some((space, id)) {
      step()
      let table = if space == -1 { global_types } else { spaces[space].types }
      let resource_table = if space == -1 {
        global_resources
      } else {
        spaces[space].resources
      }
      guard table.get(id) is Some(Some(td)) else {
        raise IncompleteFunctionSignature
      }
      let slot = mapped[(space, id)]
      resources[slot] = resource_table.get(id).bind(x => x)
      match td {
        Flags(labels) | Enum(labels) => remaining -= labels.length()
        _ => ()
      }
      if remaining < 0 {
        raise SignatureBudgetExceeded
      }
      types[slot] = Some(signature_definition(td, t => value(t, space)))
    }
    { function, types, resources, work: budget - remaining, }
  } catch {
    IncompleteFunctionSignature | SignatureBudgetExceeded =>
      raise UnsupportedFunctionAscription
  }
}

///|
fn metadata_global_types(
  global_types : Array[@component.TypeDef?],
  global_resources : Array[Int32?],
  bindings : Map[Int32, (InstanceMetadata, Int32)],
  budget : Int32,
) -> (Array[@component.TypeDef?], Array[Int32?], Int32) raise IncompleteFunctionSignature {
  let mut remaining = budget - global_types.length() - global_resources.length()
  if remaining < 0 {
    raise SignatureBudgetExceeded
  }
  let types = global_types.copy()
  let resources = Array::makei(types.length(), i => {
    global_resources.get(i).bind(x => x)
  })
  let mapped : Map[(Int32, Int32), Int32] = Map([])
  let pending : Array[(Int32, Int32)] = []
  // Stable source-index order keeps work-limit decisions deterministic.
  for index in 0..<global_types.length() {
    remaining -= 1
    if remaining < 0 {
      raise SignatureBudgetExceeded
    }
    if bindings.get(index) is Some((_, root)) {
      mapped[(index, root)] = index
      pending.push((index, root))
    }
  }
  fn value(
    ty : @component.ValType,
    owner : Int32,
  ) -> @component.ValType raise IncompleteFunctionSignature {
    remaining -= 1
    if remaining < 0 {
      raise SignatureBudgetExceeded
    }
    match ty {
      Prim(_) => ty
      TypeIdx(id) => {
        let key = (owner, id)
        let result = match mapped.get(key) {
          Some(result) => result
          None => {
            let result = types.length()
            mapped[key] = result
            pending.push(key)
            types.push(None)
            resources.push(None)
            result
          }
        }
        TypeIdx(result)
      }
    }
  }
  while pending.pop() is Some((owner, id)) {
    remaining -= 1
    if remaining < 0 {
      raise SignatureBudgetExceeded
    }
    let (metadata, _) = bindings[owner]
    guard metadata.types.get(id) is Some(Some(td)) else {
      raise IncompleteFunctionSignature
    }
    let result = mapped[(owner, id)]
    resources[result] = metadata.resources.get(id).bind(x => x)
    types[result] = Some(signature_definition(td, ty => value(ty, owner)))
  }
  (types, resources, remaining)
}
