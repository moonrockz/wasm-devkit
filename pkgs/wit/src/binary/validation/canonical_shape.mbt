///|
priv struct CanonicalBudget {
  mut remaining : Int32
}

///|
fn CanonicalBudget::step(
  self : CanonicalBudget,
) -> Unit raise ComponentValidationError {
  if self.remaining <= 0 {
    raise CanonicalBudgetExceeded
  }
  self.remaining -= 1
}

///|
priv struct CanonicalShape {
  flat : Array[@types.ValueType]
  dynamic : Bool
}

///|
priv enum CanonicalCombine {
  Concat
  Variant
  Repeat(Int32)
}

///|
priv enum CanonicalFrame {
  Value(@component.ValType)
  Finish(Int32, CanonicalCombine, Int32)
}

///|
priv struct CanonicalContext {
  types : Array[@component.TypeDef?]
  pointer : @types.ValueType
  budget : CanonicalBudget
  cache : Map[Int32, CanonicalShape]
}

///|
fn canonical_primitive(
  value : @component.PrimValType,
  pointer : @types.ValueType,
) -> CanonicalShape {
  {
    flat: match value {
      S64 | U64 => [I64]
      F32 => [F32]
      F64 => [F64]
      String => [pointer, pointer]
      _ => [I32]
    },
    dynamic: value is String,
  }
}

///|
fn canonical_join(
  a : @types.ValueType,
  b : @types.ValueType,
) -> @types.ValueType {
  if a == b {
    return a
  }
  match (a, b) {
    (I64 | F64, _) | (_, I64 | F64) => I64
    _ => I32
  }
}

///|
// Prefixes stop at seventeen values: enough to distinguish the canonical
// sixteen-parameter limit and the one-result limit. All recursively flattened children still visit
// the work stack, so truncating a prefix never hides an invalid graph.
fn CanonicalContext::shape(
  self : CanonicalContext,
  value : @component.ValType,
) -> CanonicalShape raise ComponentValidationError {
  let work : Array[CanonicalFrame] = [Value(value)]
  let values : Array[CanonicalShape] = []
  let visiting : Map[Int32, Bool] = Map([])
  while work.pop() is Some(frame) {
    self.budget.step()
    match frame {
      Value(Prim(value)) =>
        values.push(canonical_primitive(value, self.pointer))
      Value(TypeIdx(index)) => {
        if self.cache.get(index) is Some(shape) {
          values.push(shape)
          continue
        }
        if visiting.contains(index) {
          raise SectionParseError(8, "cyclic canonical value graph")
        }
        guard self.types.get(index) is Some(Some(definition)) else {
          raise InvalidTypeIndex(index)
        }
        visiting[index] = true
        let children : Array[@component.ValType] = []
        let combine = match definition {
          DefValType(value) => {
            let shape = canonical_primitive(value, self.pointer)
            self.cache[index] = shape
            visiting.remove(index) |> ignore
            values.push(shape)
            continue
          }
          List(_) | MapType(_, _) => {
            let shape = { flat: [self.pointer, self.pointer], dynamic: true, }
            self.cache[index] = shape
            visiting.remove(index) |> ignore
            values.push(shape)
            continue
          }
          Own(_) | Borrow(_) | Enum(_) | Stream(_) | Future(_) | Flags(_) => {
            let shape = { flat: [@types.I32], dynamic: false, }
            self.cache[index] = shape
            visiting.remove(index) |> ignore
            values.push(shape)
            continue
          }
          Record(fields) => {
            for field in fields {
              self.budget.step()
              children.push(field.ty)
            }
            Concat
          }
          Tuple(types) => {
            for ty in types {
              self.budget.step()
              children.push(ty)
            }
            Concat
          }
          FixedList(element, length) => {
            if length <= 0 {
              raise SectionParseError(8, "invalid fixed list length")
            }
            children.push(element)
            Repeat(length)
          }
          Option(element) => {
            children.push(element)
            Variant
          }
          Result(ok, err) => {
            if ok is Some(value) {
              children.push(value)
            }
            if err is Some(value) {
              children.push(value)
            }
            Variant
          }
          Variant(cases) => {
            for case in cases {
              self.budget.step()
              if case.ty is Some(value) {
                children.push(value)
              }
            }
            Variant
          }
          _ => raise TypeIndexNotDefinedType(index)
        }
        work.push(Finish(index, combine, children.length()))
        for i = children.length() - 1; i >= 0; i = i - 1 {
          work.push(Value(children[i]))
        }
      }
      Finish(index, combine, count) => {
        let start = values.length() - count
        let flat : Array[@types.ValueType] = []
        let mut dynamic = false
        for i in start..<values.length() {
          self.budget.step()
          let shape = values[i]
          dynamic = dynamic || shape.dynamic
          match combine {
            Concat =>
              for value in shape.flat {
                self.budget.step()
                if flat.length() < 17 {
                  flat.push(value)
                }
              }
            Variant =>
              for j, value in shape.flat {
                self.budget.step()
                if j < flat.length() {
                  flat[j] = canonical_join(flat[j], value)
                } else {
                  flat.push(value)
                }
              }
            Repeat(length) =>
              if !shape.flat.is_empty() {
                for _ in 0..<length {
                  if flat.length() == 17 {
                    break
                  }
                  for value in shape.flat {
                    self.budget.step()
                    if flat.length() < 17 {
                      flat.push(value)
                    }
                  }
                }
              }
          }
        }
        if combine is Variant {
          flat.insert(0, @types.I32)
          if flat.length() > 17 {
            ignore(flat.pop())
          }
        }
        for _ in 0..<count {
          ignore(values.pop())
        }
        let shape = { flat, dynamic, }
        self.cache[index] = shape
        visiting.remove(index) |> ignore
        values.push(shape)
      }
    }
  }
  values[0]
}

///|
priv struct CanonicalFunction {
  lifted : @types.FuncType
  lowered : @types.FuncType
  memory : Bool
  lift_realloc : Bool
  lower_realloc : Bool
}

///|
fn CanonicalContext::function(
  self : CanonicalContext,
  function : @component.FuncType,
) -> CanonicalFunction raise ComponentValidationError {
  let params : Array[@types.ValueType] = []
  let mut dynamic_params = false
  for param in function.params {
    self.budget.step()
    let shape = self.shape(param.ty)
    dynamic_params = dynamic_params || shape.dynamic
    for value in shape.flat {
      self.budget.step()
      if params.length() < 17 {
        params.push(value)
      }
    }
  }
  let result = match function.result {
    Some(result) => self.shape(result)
    None => { flat: [], dynamic: false, }
  }
  let indirect_params = params.length() > 16
  let indirect_result = result.flat.length() > 1
  let params = if indirect_params { [self.pointer] } else { params }
  let lowered_params = params.copy()
  if indirect_result {
    lowered_params.push(self.pointer)
  }
  {
    lifted: {
      params,
      results: if indirect_result {
        [self.pointer]
      } else {
        result.flat
      },
    },
    lowered: {
      params: lowered_params,
      results: if indirect_result {
        []
      } else {
        result.flat
      },
    },
    memory: dynamic_params ||
    result.dynamic ||
    indirect_params ||
    indirect_result,
    lift_realloc: dynamic_params || indirect_params,
    lower_realloc: result.dynamic,
  }
}
