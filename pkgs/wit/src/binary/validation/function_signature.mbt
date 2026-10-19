// Original wasm-devkit metadata for lossless function-alias ascriptions.

///|
priv struct CompleteFunctionSignature {
  work : Int32
  function : @component.FuncType
  types : Array[@component.TypeDef?]
  resources : Array[Int32?]
}

///|
priv suberror IncompleteFunctionSignature {
  IncompleteFunctionSignature
  SignatureBudgetExceeded
}

///|
fn signature_definition(
  td : @component.TypeDef,
  value : (@component.ValType) -> @component.ValType raise IncompleteFunctionSignature,
) -> @component.TypeDef raise IncompleteFunctionSignature {
  match td {
    DefValType(_) | ResourceType(_, _, _, _) | Flags(_) | Enum(_) => td
    List(v) => List(value(v))
    FixedList(v, n) => FixedList(value(v), n)
    MapType(k, v) => MapType(value(k), value(v))
    Option(v) => Option(value(v))
    Tuple(values) => Tuple(values.map(v => value(v)))
    Record(fields) => Record(fields.map(f => { ..f, ty: value(f.ty), }))
    Variant(cases) =>
      Variant(cases.map(c => { ..c, ty: c.ty.map(v => value(v)), }))
    Result(ok, err) => Result(ok.map(v => value(v)), err.map(v => value(v)))
    Future(v) => Future(v.map(v => value(v)))
    Stream(v) => Stream(v.map(v => value(v)))
    Own(id) =>
      match value(TypeIdx(id)) {
        TypeIdx(id) => Own(id)
        _ => raise IncompleteFunctionSignature
      }
    Borrow(id) =>
      match value(TypeIdx(id)) {
        TypeIdx(id) => Borrow(id)
        _ => raise IncompleteFunctionSignature
      }
    _ => raise IncompleteFunctionSignature
  }
}

///|
// Retain only reachable value definitions. Queue entries refer to the source
// table; normalized indices never depend on the caller's local type namespace.
fn complete_function_signature(
  ft : @component.FuncType,
  local_types : Array[@component.TypeDef],
  local_resources : Array[Int32?],
  global_types : Array[@component.TypeDef?],
  global_resources : Array[Int32?],
  local_origins~ : Map[Int32, Int32] = Map([]),
  global_function~ : Bool = false,
  budget~ : Int32 = 1000000,
) -> CompleteFunctionSignature? {
  try {
    let types : Array[@component.TypeDef?] = []
    let resources : Array[Int32?] = []
    let mapping : Map[(Bool, Int32), Int32] = Map([])
    let pending : Array[(Bool, Int32)] = []
    let mut remaining = budget
    fn value(
      v : @component.ValType,
      global : Bool,
    ) -> @component.ValType raise IncompleteFunctionSignature {
      remaining -= 1
      if remaining < 0 {
        raise SignatureBudgetExceeded
      }
      match v {
        Prim(_) => v
        TypeIdx(id) => {
          if id < 0 {
            raise IncompleteFunctionSignature
          }
          let (global, id) = if !global && local_origins.get(id) is Some(origin) {
            (true, origin)
          } else {
            (global, id)
          }
          let key = (global, id)
          let target = match mapping.get(key) {
            Some(id) => id
            None => {
              let next = types.length()
              types.push(None)
              resources.push(None)
              mapping[key] = next
              pending.push(key)
              next
            }
          }
          TypeIdx(target)
        }
      }
    }
    let initial_global = global_function || local_types.is_empty()
    let params = ft.params.map(p => { ..p, ty: value(p.ty, initial_global), })
    let result = ft.result.map(v => value(v, initial_global))
    while pending.pop() is Some((global, id)) {
      remaining -= 1
      if remaining < 0 {
        raise SignatureBudgetExceeded
      }
      let td = if global {
        global_types.get(id).bind(x => x)
      } else {
        local_types.get(id)
      }
      guard td is Some(td) else { raise IncompleteFunctionSignature }
      let resource = if global {
        global_resources.get(id).bind(x => x)
      } else {
        local_resources.get(id).bind(x => x)
      }
      let slot = mapping[(global, id)]
      if td is ResourceType(_, _, _, _) {
        guard resource is Some(_) else { raise IncompleteFunctionSignature }
        resources[slot] = resource
      }
      match td {
        Flags(names) | Enum(names) => remaining -= names.length()
        _ => ()
      }
      if remaining < 0 {
        raise SignatureBudgetExceeded
      }
      types[slot] = Some(signature_definition(td, v => value(v, global)))
    }
    Some({
      work: budget - remaining,
      function: { ..ft, params, result, },
      types,
      resources,
    })
  } catch {
    IncompleteFunctionSignature | SignatureBudgetExceeded => None
  }
}

///|
fn complete_signature_substitute(
  signature : CompleteFunctionSignature?,
  substitutions : Map[Int32, Int32],
) -> CompleteFunctionSignature? {
  signature.map(signature => {
    ..signature,
    resources: signature.resources.map(resource => {
      resource.map(id => substitutions.get(id).unwrap_or(id))
    }),
  })
}
