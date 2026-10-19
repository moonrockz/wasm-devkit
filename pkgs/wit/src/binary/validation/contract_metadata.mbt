// Original wasm-devkit complete component contract metadata.

///|
priv struct ContractMembers {
  sorts : Map[String, @component.Sort]
  types : Map[String, Int32]
  functions : Map[String, FuncSigShape]
  values : Map[String, CompleteFunctionSignature]
  children : Map[String, Int32]
  modules : Map[String, Int32]
  direct_modules : Map[String, @core_types.Module]
  binders : Map[String, Bool]
}

///|
fn ContractMembers::new() -> ContractMembers {
  {
    sorts: Map([]),
    types: Map([]),
    functions: Map([]),
    values: Map([]),
    children: Map([]),
    modules: Map([]),
    direct_modules: Map([]),
    binders: Map([]),
  }
}

///|
priv struct ScopedContractNode {
  imports : ContractMembers
  exports : ContractMembers
  component : Bool
  core_scope : Int32?
}

///|
priv struct ScopedContractMetadata {
  nodes : Array[ScopedContractNode]
  types : Array[@component.TypeDef?]
  resources : Array[Int32?]
  locals : Map[Int32, Bool]
}

///|
priv struct ScopedContractScope {
  seed_node : Int32?
  parent : Int32?
  types : Array[Int32]
  instances : Array[Int32]
  declarations : Array[@component.ComponentDecl]
  mut position : Int32
  node : Int32
  core_scope : Int32?
}

///|
fn scoped_contract_metadata(
  td : @component.TypeDef,
  global_types : Array[@component.TypeDef?],
  global_resources : Array[Int32?],
  bindings : Map[Int32, (InstanceMetadata, Int32)],
  next_resource : Int32,
  budget : Int32,
  core_contracts~ : @core_types.ContractGraph? = None,
  core_scope~ : Int32? = None,
  seed~ : (InstanceMetadata, Int32)? = None,
) -> (ScopedContractMetadata?, Int32, Int32) {
  let mut next_resource = next_resource
  let mut remaining = budget
  try {
    let (types, resources, rest) = metadata_global_types(
      global_types, global_resources, bindings, remaining,
    )
    remaining = rest
    let nodes : Array[ScopedContractNode] = []
    let scopes : Array[ScopedContractScope] = [
      {
        parent: None,
        types: Array::makei(global_types.length(), i => i),
        instances: [],
        declarations: [],
        position: 0,
        node: -1,
        seed_node: None,
        core_scope: Some(0),
      },
    ]
    let locals : Map[Int32, Bool] = Map([])
    let origins : Map[Int32, Int32] = Map([])
    fn step() -> Unit raise IncompleteFunctionSignature {
      remaining -= 1
      if remaining < 0 {
        raise SignatureBudgetExceeded
      }
    }
    fn declarations(
      td : @component.TypeDef,
    ) -> Array[@component.ComponentDecl] raise IncompleteFunctionSignature {
      match td {
        ComponentType(ds) => ds
        InstanceType(ds) =>
          ds.map(d => {
            match d {
              CoreType(b) => @component.ComponentDecl::CoreType(b)
              Type(t) => Type(t)
              AliasOuter(k, c, i) => AliasOuter(k, c, i)
              AliasInstanceExport(k, i, n) => AliasInstanceExport(k, i, n)
              Export(n, a, d) => Export(n, a, d)
            }
          })
        InstanceTypeEmpty => []
        _ => raise IncompleteFunctionSignature
      }
    }
    fn add_scope(
      td : @component.TypeDef,
      parent : Int32,
      core_scope : Int32?,
      seed_node : Int32?,
    ) -> Int32 raise IncompleteFunctionSignature {
      step()
      let node = nodes.length()
      nodes.push({
        imports: ContractMembers::new(),
        exports: ContractMembers::new(),
        component: td is ComponentType(_),
        core_scope,
      })
      let index = scopes.length()
      scopes.push({
        parent: Some(parent),
        seed_node,
        types: [],
        instances: [],
        declarations: declarations(td),
        position: 0,
        node,
        core_scope,
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
    let root = add_scope(td, 0, core_scope, seed.map(pair => pair.1))
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
          if kind != 0x03 {
            continue
          }
          guard count >= 0 else { raise IncompleteFunctionSignature }
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
            guard nodes[child].exports.types.get(name) is Some(ty) else {
              raise IncompleteFunctionSignature
            }
            scope.types.push(ty)
          } else if kind == 0x05 {
            guard nodes[child].exports.sorts.get(name) is Some(Instance) &&
              nodes[child].exports.children.get(name) is Some(nested) else {
              raise IncompleteFunctionSignature
            }
            scope.instances.push(nested)
          }
        }
        Import(name, _, desc) | Export(name, _, desc) => {
          let items = if declaration is Import(_, _, _) {
            node.imports
          } else {
            node.exports
          }
          items.sorts[name] = sort_of_externdesc(desc)
          match desc {
            Type(SubResource) => {
              let resource = match (seed, scope.seed_node) {
                (Some((seed, _)), Some(node)) => {
                  guard seed.nodes.get(node) is Some(node) &&
                    node.types.get(name) is Some(ty) &&
                    seed.resources.get(ty) is Some(Some(resource)) else {
                    raise IncompleteFunctionSignature
                  }
                  resource
                }
                _ => {
                  let resource = next_resource
                  next_resource += 1
                  locals[resource] = true
                  resource
                }
              }
              items.binders[name] = true
              let slot = types.length()
              types.push(Some(ResourceType(-1, 0x7f, None, HostDefined)))
              resources.push(Some(resource))
              scope.types.push(slot)
              items.types[name] = slot
            }
            Type(Eq(original)) => {
              let ty = type_index(index, original)
              scope.types.push(ty)
              items.types[name] = ty
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
              items.functions[name] = signature
            }
            InstanceType(original) | ComponentType(original) => {
              let ty = type_index(index, original)
              guard types.get(ty) is Some(Some(child)) else {
                raise IncompleteFunctionSignature
              }
              let child_core_scope = match (core_contracts, scope.core_scope) {
                (Some(graph), Some(owner)) =>
                  match graph.scope(owner) {
                    Some(scope) =>
                      match scope.binding(3, original) {
                        Some(Scope(id)) => Some(id)
                        _ => None
                      }
                    None => None
                  }
                _ => None
              }
              let child_seed = match (seed, scope.seed_node, desc) {
                (Some((seed, _)), Some(node), InstanceType(_)) =>
                  seed.nodes[node].children.get(name)
                _ => None
              }
              let child_scope = add_scope(
                child,
                origins.get(ty).unwrap_or(0),
                child_core_scope,
                child_seed,
              )
              let child_node = scopes[child_scope].node
              items.children[name] = child_node
              if desc is InstanceType(_) {
                scope.instances.push(child_node)
              }
              stack.push(child_scope)
            }
            Value(Type(ty)) => {
              let (signature, rest) = complete_value_signature(
                value(index, ty),
                types,
                resources,
                remaining,
              )
              remaining = rest
              items.values[name] = signature
            }
            CoreModuleType(original) => items.modules[name] = original
            _ => raise IncompleteFunctionSignature
          }
        }
        CoreType(_) => ()
      }
    }
    (Some({ nodes, types, resources, locals, }), next_resource, remaining)
  } catch {
    SignatureBudgetExceeded => (None, next_resource, 0)
    IncompleteFunctionSignature => (None, next_resource, remaining.max(0))
  }
}
