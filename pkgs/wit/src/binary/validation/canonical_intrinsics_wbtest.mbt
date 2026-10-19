///|
test "canonical handle validation shares its work allowance" {
  let work : CoreContractWork = { remaining: 2, }
  let empty : Map[(Int32, Int32), @core_types.External] = Map([])
  assert_eq(canonical_handle_function(TaskCancel, [], empty, work), {
    params: [],
    results: [],
  })
  assert_eq(canonical_handle_function(SubtaskCancel(true), [], empty, work), {
    params: [@types.I32],
    results: [@types.I32],
  })
  let result = try {
    ignore(canonical_handle_function(WaitableSetNew, [], empty, work))
    "accepted"
  } catch {
    error => error.to_string()
  }
  assert_eq(result, "CoreContractBudgetExceeded")
}

///|
test "canonical handles retain deep payloads without walking them" {
  let types : Array[@component.TypeDef?] = [Some(DefValType(U32))]
  for i in 0..<6000 {
    types.push(Some(Stream(Some(TypeIdx(i)))))
  }
  let signature = canonical_handle_function(StreamNew(6000), types, Map([]), {
    remaining: 1,
  })
  assert_eq(signature, { params: [], results: [@types.I64], })
  let gc = try {
    ignore(
      canonical_gc_function(
        {
          is_async: false,
          params: [{ label: "p", ty: TypeIdx(6000), }],
          result: None,
        },
        types,
        { remaining: 1, },
      ),
    )
    "accepted"
  } catch {
    error => error.to_string()
  }
  assert_eq(gc, "UnsupportedCanonical")
}

///|
test "scalar GC ABI charges every argument across calls" {
  let budget : CanonicalBudget = { remaining: 21, }
  let params : Array[@component.Param] = []
  for i in 0..<20 {
    params.push({ label: "p\{i}", ty: Prim(U32), })
  }
  let function : @component.FuncType = {
    is_async: false,
    params,
    result: Some(Prim(U64)),
  }
  let core = canonical_gc_function(function, [], budget)
  assert_eq(core.params.length(), 20)
  assert_eq(core.results, [@types.I64])
  assert_eq(budget.remaining, 0)
  let result = try {
    ignore(canonical_gc_function(function, [], budget))
    "accepted"
  } catch {
    error => error.to_string()
  }
  assert_eq(result, "CanonicalBudgetExceeded")
}

///|
test "canonical handles reject wrong sorts and shared memory" {
  let externs : Map[(Int32, Int32), @core_types.External] = Map([
    ((2, 0), Memory(1UL, Some(1UL), false, true, None)),
  ])
  let declarations : Array[@component.Canon] = [
    WaitableSetWait(false, 0),
    StreamNew(0),
    FutureNew(1),
  ]
  for declaration in declarations {
    let result = try {
      ignore(
        canonical_handle_function(
          declaration,
          [Some(Future(None)), Some(Stream(None))],
          externs,
          { remaining: 1, },
        ),
      )
      false
    } catch {
      _ => true
    }
    assert_true(result)
  }
}
