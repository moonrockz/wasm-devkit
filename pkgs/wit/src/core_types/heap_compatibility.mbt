///|
fn lower_heap_value(
  value : HeapValue,
  graph : ReadOnlyArray[HeapDefinition],
  budget : CompatibilityBudget,
) -> @model.ValueType? raise CompatibilityFailure {
  budget.charge(1)
  match value {
    Number(name) =>
      match name {
        "i32" => Some(I32)
        "i64" => Some(I64)
        "f32" => Some(F32)
        "f64" => Some(F64)
        "v128" => Some(V128)
        _ => None
      }
    Ref(nullable, shared, heap) => {
      if heap >= 0 {
        guard graph.get(heap) is Some(target) && target.shared == shared else {
          return None
        }
      } else if @model.ValueType::from_abstract_heap_type(heap, nullable)
        is None ||
        heap == -24 ||
        heap == -11 {
        return None
      }
      Some(HeapRef(nullable, shared, heap))
    }
  }
}

///|
fn lower_heap_field(
  field : HeapField,
  graph : ReadOnlyArray[HeapDefinition],
  budget : CompatibilityBudget,
) -> @model.FieldType? raise CompatibilityFailure {
  budget.charge(1)
  let storage_type : @model.StorageType = match field.storage {
    Packed("i8") => Packed(I8)
    Packed("i16") => Packed(I16)
    Packed(_) => return None
    Value(value) => {
      guard lower_heap_value(value, graph, budget) is Some(value) else {
        return None
      }
      Val(value)
    }
  }
  Some({ storage_type, mutable: field.mutable, })
}

///|
/// Copy the immutable flat graph into the internal comparison representation.
/// Every node and field consumes the caller's shared work allowance before
/// allocation. Caller-built malformed graph indices reject without panicking.
fn lower_identity(
  identity : TypeIdentity,
  budget : CompatibilityBudget,
) -> (Array[@model.SubType], Array[Int32])? raise CompatibilityFailure {
  let graph = identity.types
  budget.charge(graph.length())
  guard graph.get(identity.index) is Some(_) else { return None }
  let types : Array[@model.SubType] = []
  let groups : Array[Int32] = []
  let mut group_end = 0
  let mut group_start = 0
  for index, node in graph {
    if index == group_end {
      if node.group_start != index ||
        node.group_size <= 0 ||
        node.group_size > graph.length() - index {
        return None
      }
      group_start = index
      group_end = index + node.group_size
    }
    if node.group_start != group_start ||
      node.group_size != group_end - group_start {
      return None
    }
    if node.supertype is Some(parent) &&
      (parent < 0 || parent >= graph.length()) {
      return None
    }
    let composite : @model.CompositeType = match node.composite {
      Function(params, results) => {
        budget.charge(params.length())
        budget.charge(results.length())
        let ps = []
        let rs = []
        for value in params {
          guard lower_heap_value(value, graph, budget) is Some(value) else {
            return None
          }
          ps.push(value)
        }
        for value in results {
          guard lower_heap_value(value, graph, budget) is Some(value) else {
            return None
          }
          rs.push(value)
        }
        let function : @model.FuncType = { params: ps, results: rs, }
        if node.shared {
          SharedFunc(function)
        } else {
          Func(function)
        }
      }
      Struct(fields) => {
        budget.charge(fields.length())
        let lowered = []
        for field in fields {
          guard lower_heap_field(field, graph, budget) is Some(field) else {
            return None
          }
          lowered.push(field)
        }
        if node.shared {
          SharedStruct({ fields: lowered, })
        } else {
          Struct({ fields: lowered, })
        }
      }
      Array(field) => {
        guard lower_heap_field(field, graph, budget) is Some(field) else {
          return None
        }
        if node.shared {
          SharedArray({ element: field, })
        } else {
          Array({ element: field, })
        }
      }
    }
    types.push({
      final_: node.final_,
      supertypes: match node.supertype {
        Some(parent) => [parent]
        None => []
      },
      composite,
    })
    groups.push(group_start)
  }
  Some((types, groups))
}

///|
fn identity_subtype(
  actual : TypeIdentity,
  expected : TypeIdentity,
  equal : Bool,
  budget : CompatibilityBudget,
) -> Bool raise CompatibilityFailure {
  guard lower_identity(actual, budget) is Some((types1, groups1)) &&
    lower_identity(expected, budget) is Some((types2, groups2)) else {
    return false
  }
  let context = @model.SubtypingContext::cross_module(
    types1,
    types2,
    rec_groups1=groups1,
    rec_groups2=groups2,
  )
  context.restrict_work_limit(budget.remaining)
  let result = if equal {
    context.reference_types_equal(actual.index, expected.index)
  } else {
    context.is_subtype(actual.index, expected.index)
  }
  budget.remaining = context.remaining_work()
  if context.work_exhausted() {
    raise CompatibilityFailure(WorkLimit)
  }
  result
}

///|
/// Check isorecursive identity and declared supertype compatibility between
/// validated flat graphs, returning the unused comparison work allowance.
pub fn check_type_subtype(
  actual : TypeIdentity,
  expected : TypeIdentity,
  work_limit~ : Int32 = 1000000,
) -> Result[Int32, CompatibilityError] {
  let budget = { remaining: work_limit, }
  try {
    if identity_subtype(actual, expected, false, budget) {
      Ok(budget.remaining)
    } else {
      Err(Mismatch("incompatible concrete core type"))
    }
  } catch {
    CompatibilityFailure(error) => Err(error)
  }
}

///|
fn value_subtype(
  actual : Value,
  expected : Value,
  equal : Bool,
  budget : CompatibilityBudget,
) -> Bool raise CompatibilityFailure {
  budget.charge(1)
  match (actual, expected) {
    (Scalar(a), Scalar(b)) => a == b
    (Concrete(an, a), Concrete(bn, b)) => {
      if (equal && an != bn) || (an && !bn) {
        return false
      }
      identity_subtype(a, b, equal, budget)
    }
    _ => {
      let ar = abstract_reference(actual)
      let br = abstract_reference(expected)
      match (ar, br) {
        (Some((an, ash, ah)), Some((bn, bsh, bh))) => {
          if ash != bsh || (equal && an != bn) || (an && !bn) {
            return false
          }
          if equal {
            ah == bh
          } else {
            @model.SubtypingContext::same_module([]).value_type_subtype(
              HeapRef(an, ash, ah),
              HeapRef(bn, bsh, bh),
            )
          }
        }
        _ => {
          if equal {
            return false
          }
          match (actual, expected) {
            (Concrete(an, a), _) => {
              guard a.types.get(a.index) is Some(node) &&
                br is Some((bn, bsh, bh)) else {
                return false
              }
              if (an && !bn) || node.shared != bsh {
                return false
              }
              let kind = match node.composite {
                Function(_, _) => -16
                Struct(_) => -21
                Array(_) => -22
              }
              @model.SubtypingContext::same_module([]).value_type_subtype(
                HeapRef(an, bsh, kind),
                HeapRef(bn, bsh, bh),
              )
            }
            (_, Concrete(bn, b)) => {
              guard b.types.get(b.index) is Some(node) &&
                ar is Some((an, ash, ah)) else {
                return false
              }
              if (an && !bn) || node.shared != ash {
                return false
              }
              let bottom = match node.composite {
                Function(_, _) => -13
                Struct(_) | Array(_) => -15
              }
              ah == bottom
            }
            _ => false
          }
        }
      }
    }
  }
}

///|
fn abstract_reference(value : Value) -> (Bool, Bool, Int32)? {
  let (nullable, shared, name) = match value {
    Reference(nullable, name) => (nullable, false, name)
    SharedReference(nullable, name) => (nullable, true, name)
    _ => return None
  }
  let heap = match name {
    "func" => -16
    "extern" => -17
    "any" => -18
    "eq" => -19
    "i31" => -20
    "struct" => -21
    "array" => -22
    "exn" => -23
    "none" => -15
    "noextern" => -14
    "nofunc" => -13
    "noexn" => -12
    _ => return None
  }
  Some((nullable, shared, heap))
}

///|
fn is_shared_value(value : Value) -> Bool {
  match value {
    Scalar(_) | SharedReference(_, _) => true
    Reference(_, _) => false
    Concrete(_, identity) =>
      identity.types.get(identity.index) is Some(node) && node.shared
  }
}

///|
fn function_identity(
  function : Function,
  budget : CompatibilityBudget,
) -> TypeIdentity raise CompatibilityFailure {
  let reader : Reader = { bytes: b"", position: 0, end: 0, }
  let scope = HeapScope::new(reader, budget)
  scope.import_definition(Function(function)) catch {
    Failure(error) => {
      if error.kind == Unsupported {
        raise CompatibilityFailure(WorkLimit)
      }
      raise CompatibilityFailure(Mismatch(error.message))
    }
  }
  let index = scope.indices[0].unwrap()
  budget.charge(scope.types.length())
  { types: ReadOnlyArray::from_array(scope.types), index, }
}
