// Original wasm-devkit checks supplementing the retained component validator.

///|
priv enum AscriptionWork {
  Value(@component.ValType, @component.ValType)
  Definition(@component.TypeDef, @component.TypeDef)
  Resource(Int32, Int32)
}

///|
fn ascription_optional(
  work : Array[AscriptionWork],
  actual : @component.ValType?,
  expected : @component.ValType?,
) -> Unit raise ComponentValidationError {
  match (actual, expected) {
    (None, None) => ()
    (Some(a), Some(b)) => work.push(Value(a, b))
    _ => raise AscribedExportTypeIncompatible
  }
}

///|
// Function ascriptions are invariant in parameter names and value types. Keep
// resource identity checks separate from structurally equal value definitions.
fn check_function_ascription(
  actual : @component.FuncType,
  expected : @component.FuncType,
  types : Array[@component.TypeDef?],
  resources : Array[Int32?],
  budget~ : Int32 = 1000000,
) -> Int32 raise ComponentValidationError {
  if actual.is_async != expected.is_async ||
    actual.params.length() != expected.params.length() {
    raise AscribedExportTypeIncompatible
  }
  if actual.params.length() >= budget {
    raise SectionParseError(
      11, "function ascription exceeds the verification work limit",
    )
  }
  let work : Array[AscriptionWork] = []
  for i in 0..<actual.params.length() {
    if actual.params[i].label != expected.params[i].label {
      raise AscribedExportTypeIncompatible
    }
    work.push(Value(actual.params[i].ty, expected.params[i].ty))
  }
  ascription_optional(work, actual.result, expected.result)
  let seen : Map[(Int32, Int32), Bool] = Map([])
  let mut remaining = budget - actual.params.length() - 1
  while work.pop() is Some(item) {
    remaining -= 1
    if remaining < 0 {
      raise SectionParseError(
        11, "function ascription exceeds the verification work limit",
      )
    }
    match item {
      Value(a, b) => {
        if a == b {
          continue
        }
        let ad = match a {
          Prim(p) => @component.TypeDef::DefValType(p)
          TypeIdx(id) => {
            guard types.get(id) is Some(Some(td)) else {
              raise UnsupportedFunctionAscription
            }
            td
          }
        }
        let bd = match b {
          Prim(p) => @component.TypeDef::DefValType(p)
          TypeIdx(id) => {
            guard types.get(id) is Some(Some(td)) else {
              raise UnsupportedFunctionAscription
            }
            td
          }
        }
        if a is TypeIdx(ai) && b is TypeIdx(bi) {
          if seen.contains((ai, bi)) {
            continue
          }
          seen[(ai, bi)] = true
        }
        work.push(Definition(ad, bd))
      }
      Resource(a, b) => {
        guard resources.get(a) is Some(Some(ar)) &&
          resources.get(b) is Some(Some(br)) else {
          raise UnsupportedFunctionAscription
        }
        if ar != br {
          raise AscribedExportTypeIncompatible
        }
      }
      Definition(a, b) =>
        match (a, b) {
          (DefValType(a), DefValType(b)) =>
            if a != b {
              raise AscribedExportTypeIncompatible
            }
          (List(a), List(b)) | (Option(a), Option(b)) => work.push(Value(a, b))
          (FixedList(a, al), FixedList(b, bl)) => {
            if al != bl {
              raise AscribedExportTypeIncompatible
            }
            work.push(Value(a, b))
          }
          (MapType(ak, av), MapType(bk, bv)) => {
            work.push(Value(ak, bk))
            work.push(Value(av, bv))
          }
          (Own(a), Own(b)) | (Borrow(a), Borrow(b)) => work.push(Resource(a, b))
          (Future(a), Future(b)) | (Stream(a), Stream(b)) =>
            ascription_optional(work, a, b)
          (Result(ao, ae), Result(bo, be)) => {
            ascription_optional(work, ao, bo)
            ascription_optional(work, ae, be)
          }
          (Tuple(a), Tuple(b)) => {
            if a.length() != b.length() {
              raise AscribedExportTypeIncompatible
            }
            remaining -= a.length()
            if remaining < 0 {
              raise SectionParseError(
                11, "function ascription exceeds the verification work limit",
              )
            }
            for i in 0..<a.length() {
              work.push(Value(a[i], b[i]))
            }
          }
          (Record(a), Record(b)) => {
            if a.length() != b.length() {
              raise AscribedExportTypeIncompatible
            }
            remaining -= a.length()
            if remaining < 0 {
              raise SectionParseError(
                11, "function ascription exceeds the verification work limit",
              )
            }
            for i in 0..<a.length() {
              if a[i].label != b[i].label {
                raise AscribedExportTypeIncompatible
              }
              work.push(Value(a[i].ty, b[i].ty))
            }
          }
          (Variant(a), Variant(b)) => {
            if a.length() != b.length() {
              raise AscribedExportTypeIncompatible
            }
            for i in 0..<a.length() {
              remaining -= 1
              if remaining < 0 {
                raise SectionParseError(
                  11, "function ascription exceeds the verification work limit",
                )
              }
              if a[i].label != b[i].label || a[i].refines != b[i].refines {
                raise AscribedExportTypeIncompatible
              }
              ascription_optional(work, a[i].ty, b[i].ty)
            }
          }
          (Flags(a), Flags(b)) | (Enum(a), Enum(b)) => {
            if a.length() != b.length() {
              raise AscribedExportTypeIncompatible
            }
            for i in 0..<a.length() {
              remaining -= 1
              if remaining < 0 {
                raise SectionParseError(
                  11, "function ascription exceeds the verification work limit",
                )
              }
              if a[i] != b[i] {
                raise AscribedExportTypeIncompatible
              }
            }
          }
          _ => raise AscribedExportTypeIncompatible
        }
    }
  }
  remaining
}
