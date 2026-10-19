// Canonical ABI checks against complete, unsigned core contract metadata.

///|
fn canonical_contract_function(
  ft : @types.FuncType,
) -> @core_types.Function raise ComponentValidationError {
  fn value(
    v : @types.ValueType,
  ) -> @core_types.Value raise ComponentValidationError {
    match v {
      I32 => Scalar("i32")
      I64 => Scalar("i64")
      F32 => Scalar("f32")
      F64 => Scalar("f64")
      _ => raise UnsupportedCanonical
    }
  }
  {
    params: ReadOnlyArray::from_array(ft.params.map(value)),
    results: ReadOnlyArray::from_array(ft.results.map(value)),
  }
}

///|
fn check_canonical_core_function(
  index : Int32,
  expected : @types.FuncType,
  externs : Map[(Int32, Int32), @core_types.External],
  work : CoreContractWork,
) -> Unit raise ComponentValidationError {
  guard externs.get((0, index)) is Some(Func(actual)) else {
    raise InvalidCoreFuncIndex(index)
  }
  match
    @core_types.check_external_subtype(
      Func(actual),
      Func(canonical_contract_function(expected)),
      work_limit=work.remaining,
    ) {
    Ok(remaining) => work.remaining = remaining
    Err(WorkLimit) => raise CoreContractBudgetExceeded
    Err(Mismatch(message)) => raise CanonCoreFuncTypeMismatch(message)
  }
}

///|
fn check_canonical_contract(
  declaration : @component.Canon,
  types : Array[@component.TypeDef?],
  functions : Array[@component.FuncType?],
  signatures : Array[FuncSigShape?],
  externs : Map[(Int32, Int32), @core_types.External],
  budget : CanonicalBudget,
  work : CoreContractWork,
) -> @types.FuncType? raise ComponentValidationError {
  work.charge(1)
  let (lifting, index, opts, ft, type_table) = match declaration {
    Lift(index, opts, type_index) => {
      guard types.get(type_index) is Some(Some(FuncType(ft))) else {
        raise CanonExpectedFuncType(type_index)
      }
      (true, index, opts, ft, types)
    }
    Lower(index, opts) => {
      if index < 0 || index >= functions.length() {
        raise InvalidFuncIndex(index)
      }
      if signatures.get(index) is Some(Some(signature)) &&
        signature.complete is Some(complete) {
        (false, index, opts, complete.function, complete.types)
      } else {
        guard functions.get(index) is Some(Some(ft)) else {
          raise UnsupportedCanonical
        }
        (false, index, opts, ft, types)
      }
    }
    _ => raise UnsupportedCanonical
  }
  validate_canon_opts(opts)
  let asynchronous = canon_has_async(opts)
  let callback = canon_callback_idx(opts)
  if asynchronous && !ft.is_async {
    raise SectionParseError(
      8, "the async canonical option requires an async function type",
    )
  }
  if !asynchronous && callback is Some(_) {
    raise SectionParseError(8, "cannot specify callback without async")
  }
  if asynchronous && canon_has_post_return(opts) {
    raise SectionParseError(8, "cannot specify post-return function in async")
  }
  if !lifting && callback is Some(_) {
    raise SectionParseError(
      8, "canonical option `callback` cannot be specified for lowerings",
    )
  }
  let mut pointer : @types.ValueType = I32
  for option in opts {
    work.charge(1)
    match option {
      Memory(index) => {
        guard externs.get((2, index)) is Some(Memory(_, _, memory64, shared, _)) else {
          raise InvalidCoreMemoryIndex(index)
        }
        if shared {
          raise CanonCoreFuncTypeMismatch("canonical memory must not be shared")
        }
        pointer = if memory64 { I64 } else { I32 }
      }
      StringEncoding(_) | Realloc(_) | PostReturn(_) | Async | Callback(_) => ()
      _ => raise UnsupportedCanonical
    }
  }
  let context : CanonicalContext = {
    types: type_table,
    pointer,
    budget,
    cache: Map([]),
  }
  let abi = context.abi(ft, lifting, asynchronous, callback is Some(_))
  if abi.memory && !canon_has_memory(opts) {
    raise MissingCanonOption("memory")
  }
  if abi.realloc && !canon_has_realloc(opts) {
    raise MissingCanonOption("realloc")
  }
  if canon_realloc_idx(opts) is Some(realloc) {
    if !canon_has_memory(opts) {
      raise MissingCanonOption("memory")
    }
    check_canonical_core_function(
      realloc,
      { params: [pointer, pointer, pointer, pointer], results: [pointer], },
      externs,
      work,
    )
  }
  if canon_post_return_idx(opts) is Some(post_return) {
    if !lifting {
      raise CanonOptionNotAllowed("post-return")
    }
    check_canonical_core_function(
      post_return,
      { params: abi.core.results, results: [], },
      externs,
      work,
    )
  }
  if callback is Some(callback_index) {
    check_canonical_core_function(
      callback_index,
      { params: [I32, I32, I32], results: [I32], },
      externs,
      work,
    )
  }
  if lifting {
    check_canonical_core_function(index, abi.core, externs, work)
    None
  } else {
    Some(abi.core)
  }
}

///|
fn canonical_resource_function(
  declaration : @component.Canon,
  types : Array[@component.TypeDef?],
  locals : Array[Bool],
  identities : Array[Int32?],
  work : CoreContractWork,
) -> @types.FuncType raise ComponentValidationError {
  work.charge(1)
  let index = match declaration {
    ResourceNew(index) | ResourceDrop(index) | ResourceRep(index) => index
    _ => raise UnsupportedCanonical
  }
  guard identities.get(index) is Some(Some(_)) else {
    raise SectionParseError(8, "canonical operation requires a resource type")
  }
  if declaration is ResourceDrop(_) {
    return { params: [I32], results: [], }
  }
  guard locals.get(index) is Some(true) &&
    types.get(index) is Some(Some(ResourceType(_, rep, _, _))) else {
    raise SectionParseError(8, "canonical operation requires a local resource")
  }
  let representation : @types.ValueType = match rep {
    0x7f => I32
    0x7e => I64
    _ => raise SectionParseError(8, "invalid resource representation")
  }
  match declaration {
    ResourceNew(_) => { params: [representation], results: [I32], }
    ResourceRep(_) => { params: [I32], results: [representation], }
    _ => raise UnsupportedCanonical
  }
}
