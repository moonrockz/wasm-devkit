///|
test "canonical ABI analysis handles deep graphs and shared expansions" {
  let types : Array[@component.TypeDef?] = [Some(DefValType(U32))]
  for i in 0..<6000 {
    types.push(Some(Tuple([TypeIdx(i), TypeIdx(i)])))
  }
  let context : CanonicalContext = {
    types,
    pointer: @types.I32,
    budget: { remaining: 1000000, },
    cache: Map([]),
  }
  let shape = context.shape(TypeIdx(6000))
  assert_eq(shape.flat.length(), 17)
  assert_false(shape.dynamic)
  let signature = context.function({
    is_async: false,
    params: [{ label: "value", ty: TypeIdx(6000), }],
    result: Some(Prim(U32)),
  })
  assert_eq(signature.lifted, { params: [@types.I32], results: [@types.I32], })
  assert_eq(signature.lowered, signature.lifted)
  assert_true(signature.memory)
  assert_true(signature.lift_realloc)
  assert_false(signature.lower_realloc)
}

///|
test "canonical ABI pointer containers and variant joins retain shape" {
  let types : Array[@component.TypeDef?] = [
    Some(MapType(Prim(String), Prim(U32))),
    Some(Result(Some(Prim(F32)), Some(Prim(U32)))),
    Some(FixedList(Prim(U64), 1000000)),
  ]
  let context : CanonicalContext = {
    types,
    pointer: @types.I64,
    budget: { remaining: 1000000, },
    cache: Map([]),
  }
  let map = context.shape(TypeIdx(0))
  assert_eq(map.flat, [@types.I64, @types.I64])
  assert_true(map.dynamic)
  assert_eq(context.shape(TypeIdx(1)).flat, [@types.I32, @types.I32])
  assert_eq(context.shape(TypeIdx(2)).flat.length(), 17)
  let function = context.function({
    is_async: false,
    params: [],
    result: Some(TypeIdx(0)),
  })
  assert_eq(function.lifted, { params: [], results: [@types.I64], })
  assert_eq(function.lowered, { params: [@types.I64], results: [], })
  assert_true(function.lower_realloc)
}

///|
test "canonical ABI work budget and cycles fail without recursion" {
  let context : CanonicalContext = {
    types: [Some(Option(TypeIdx(0)))],
    pointer: @types.I32,
    budget: { remaining: 100, },
    cache: Map([]),
  }
  let cyclic = try {
    ignore(context.shape(TypeIdx(0)))
    false
  } catch {
    SectionParseError(_, _) => true
    _ => false
  }
  assert_true(cyclic)
  let context : CanonicalContext = {
    types: [],
    pointer: @types.I32,
    budget: { remaining: 0, },
    cache: Map([]),
  }
  let bounded = try {
    ignore(context.shape(Prim(U32)))
    false
  } catch {
    CanonicalBudgetExceeded => true
    _ => false
  }
  assert_true(bounded)
}
