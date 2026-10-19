// Original wasm-devkit code. These operations describe contracts only; no
// component, task, stream, future or error-context operation is executed.

///|
fn canonical_handle_function(
  declaration : @component.Canon,
  types : Array[@component.TypeDef?],
  externs : Map[(Int32, Int32), @core_types.External],
  work : CoreContractWork,
) -> @types.FuncType raise ComponentValidationError {
  work.charge(1)
  let stream_index = match declaration {
    StreamNew(index)
    | StreamDropReadable(index)
    | StreamDropWritable(index)
    | StreamCancelRead(index, _)
    | StreamCancelWrite(index, _) => Some(index)
    _ => None
  }
  let future_index = match declaration {
    FutureNew(index)
    | FutureDropReadable(index)
    | FutureDropWritable(index)
    | FutureCancelRead(index, _)
    | FutureCancelWrite(index, _) => Some(index)
    _ => None
  }
  if stream_index is Some(index) {
    guard types.get(index) is Some(Some(Stream(_))) else {
      raise SectionParseError(8, "canonical operation requires a stream type")
    }
  }
  if future_index is Some(index) {
    guard types.get(index) is Some(Some(Future(_))) else {
      raise SectionParseError(8, "canonical operation requires a future type")
    }
  }
  match declaration {
    BackpressureInc | BackpressureDec | TaskCancel =>
      { params: [], results: [], }
    WaitableSetNew => { params: [], results: [I32], }
    WaitableSetWait(_, index) | WaitableSetPoll(_, index) => {
      guard externs.get((2, index)) is Some(Memory(_, _, memory64, shared, _)) else {
        raise InvalidCoreMemoryIndex(index)
      }
      if shared {
        raise CanonCoreFuncTypeMismatch("canonical memory must not be shared")
      }
      { params: [I32, if memory64 { I64 } else { I32 }], results: [I32], }
    }
    WaitableJoin => { params: [I32, I32], results: [], }
    WaitableSetDrop
    | SubtaskDrop
    | ErrorContextDrop
    | StreamDropReadable(_)
    | StreamDropWritable(_)
    | FutureDropReadable(_)
    | FutureDropWritable(_) => { params: [I32], results: [], }
    SubtaskCancel(_)
    | StreamCancelRead(_, _)
    | StreamCancelWrite(_, _)
    | FutureCancelRead(_, _)
    | FutureCancelWrite(_, _) => { params: [I32], results: [I32], }
    StreamNew(_) | FutureNew(_) => { params: [], results: [I64], }
    _ => raise UnsupportedCanonical
  }
}

///|
// GC ABI arguments have one core slot each, with no flat-ABI arity cutoff.
// GC reference/aggregate shapes remain outside this scalar profile.
fn canonical_gc_function(
  function : @component.FuncType,
  types : Array[@component.TypeDef?],
  budget : CanonicalBudget,
) -> @types.FuncType raise ComponentValidationError {
  fn scalar(
    value : @component.ValType,
  ) -> @types.ValueType raise ComponentValidationError {
    budget.step()
    let primitive = match value {
      Prim(value) => value
      TypeIdx(index) => {
        guard types.get(index) is Some(Some(definition)) else {
          raise InvalidTypeIndex(index)
        }
        match definition {
          DefValType(value) => value
          Enum(_) | Flags(_) => return I32
          _ => raise UnsupportedCanonical
        }
      }
    }
    match primitive {
      String | ErrorContext => raise UnsupportedCanonical
      _ => canonical_primitive(primitive, I32).flat[0]
    }
  }
  let params = function.params.map(param => scalar(param.ty))
  let results = match function.result {
    Some(result) => [scalar(result)]
    None => []
  }
  { params, results, }
}
