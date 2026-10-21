///|
fn reference_chain(count : Int32, leaf : ValueType) -> Array[SubType] {
  Array::makei(count, i => {
    SubType::from_func({
      params: [if i == 0 { leaf } else { RefNullFuncTyped(i - 1) }],
      results: [],
    })
  })
}

///|
test "deep independent reference graphs compare without recursion" {
  let left = reference_chain(6000, I32)
  let right = reference_chain(6000, I32)
  let mismatch = reference_chain(6000, I64)
  let equal = TypeEquivalenceContext::cross_module(left, right)
  assert_true(equal.types_equivalent(5999, 5999))
  assert_false(equal.exhausted)
  let different = TypeEquivalenceContext::cross_module(left, mismatch)
  assert_false(different.types_equivalent(5999, 5999))
  assert_false(different.exhausted)
}

///|
test "a failed deep comparison cannot poison cached descendants" {
  let left = func_types_to_subtypes([
    { params: [I32], results: [], },
    { params: [RefFuncTyped(0)], results: [], },
    { params: [RefFuncTyped(1)], results: [], },
  ])
  let right = func_types_to_subtypes([
    { params: [I64], results: [], },
    { params: [RefFuncTyped(0)], results: [], },
    { params: [RefFuncTyped(1)], results: [], },
  ])
  let ctx = TypeEquivalenceContext::cross_module(left, right)
  assert_false(ctx.types_equivalent(2, 2))
  assert_false(ctx.types_equivalent(1, 1))
  assert_false(ctx.types_equivalent(0, 0))
}

///|
test "isorecursive identity includes the whole group and local reference scope" {
  let types = func_types_to_subtypes([
    { params: [RefFuncTyped(0)], results: [], },
    { params: [I32], results: [], },
  ])
  let changed = func_types_to_subtypes([
    { params: [RefFuncTyped(0)], results: [], },
    { params: [I64], results: [], },
  ])
  assert_false(
    TypeEquivalenceContext::cross_module(types, changed, rec_groups1=[0, 0], rec_groups2=[
      0, 0,
    ]).types_equivalent(0, 0),
  )
  let external = func_types_to_subtypes([
    { params: [RefFuncTyped(0)], results: [], },
    { params: [RefFuncTyped(0)], results: [], },
  ])
  assert_false(
    TypeEquivalenceContext::cross_module(types, external).types_equivalent(0, 1),
  )
}

///|
test "sharedness and exact nullable bottoms participate in identity" {
  let refs : Array[ValueType] = [
    HeapRef(false, false, -23),
    HeapRef(true, false, -23),
    HeapRef(false, true, -23),
    HeapRef(true, true, -23),
    HeapRef(false, false, -13),
    HeapRef(true, false, -13),
  ]
  let types = refs.map(v => SubType::from_func({ params: [v], results: [], }))
  let ctx = TypeEquivalenceContext::same_module(types)
  for i in 0..<refs.length() {
    for j in 0..<refs.length() {
      assert_eq(ctx.types_equivalent(i, j), i == j)
    }
  }
}

///|
test "type comparison exhaustion is explicit and never cached as success" {
  let left = reference_chain(30, I32)
  let ctx = TypeEquivalenceContext::cross_module(left, reference_chain(30, I32))
  ctx.remaining = 5
  assert_false(ctx.types_equivalent(29, 29))
  assert_true(ctx.exhausted)
  assert_false(ctx.visited.contains((29, 29)))
  assert_true(
    compute_canonical_type_indices_checked(reference_chain(2000, I32)) is Err(_),
  )
}

///|
test "supertype chains use a bounded explicit stack" {
  let types = Array::makei(6000, i => SubType::{
    final_: false,
    supertypes: if i == 0 {
      []
    } else {
      [i - 1]
    },
    composite: Func({ params: [], results: [], }),
  })
  let ctx = SubtypingContext::same_module(
    types,
    canonical=Array::makei(6000, i => i),
  )
  assert_true(ctx.is_subtype(5999, 0))
  assert_false(ctx.is_subtype(0, 5999))
}

///|
test "cross-module contravariant parameters keep their own index spaces" {
  let structure = SubType::simple(
    Struct({ fields: [{ storage_type: Val(I32), mutable: false, }], }),
  )
  let left = [
    structure,
    SubType::from_func({ params: [I64], results: [], }),
    SubType::from_func({ params: [RefNullStruct(0)], results: [], }),
  ]
  let right = [
    SubType::from_func({ params: [I32], results: [], }),
    structure,
    SubType::{
      final_: false,
      supertypes: [],
      composite: Func({ params: [RefNullStruct(1)], results: [], }),
    },
  ]
  assert_true(
    SubtypingContext::cross_module(left, right).validate_declared_subtype(2, 2),
  )
  right[1] = SubType::simple(
    Struct({ fields: [{ storage_type: Val(I64), mutable: false, }], }),
  )
  assert_false(
    SubtypingContext::cross_module(left, right).validate_declared_subtype(2, 2),
  )
}
