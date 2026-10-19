///|
test "import resource audit follows deep reachable contracts with cumulative work" {
  let nodes : Array[ScopedContractNode] = []
  for index in 0..<6000 {
    let exports = ContractMembers::new()
    exports.sorts["child"] = Instance
    exports.children["child"] = index + 1
    nodes.push({
      imports: ContractMembers::new(),
      exports,
      component: false,
      core_scope: None,
    })
  }
  let exports = ContractMembers::new()
  exports.sorts["handle"] = Type
  exports.types["handle"] = 2
  nodes.push({
    imports: ContractMembers::new(),
    exports,
    component: false,
    core_scope: None,
  })
  let metadata : ScopedContractMetadata = {
    nodes,
    types: [
      Some(ResourceType(-1, 0x7f, None, HostDefined)),
      Some(ResourceType(-1, 0x7f, None, HostDefined)),
      Some(Own(1)),
    ],
    resources: [Some(7), Some(8), None],
    locals: Map([]),
    origins: [],
  }
  let locals = Map([(7, true)])
  let remaining = check_import_resources(Some(metadata), locals, 20000)
  assert_true(remaining > 0 && remaining < 10000)
  let exhausted = try {
    check_import_resources(Some(metadata), locals, remaining) |> ignore
    false
  } catch {
    SectionParseError(10, message) => message.contains("work limit")
    _ => false
  }
  assert_true(exhausted)
  metadata.types[2] = Some(Own(0))
  let captured = try {
    check_import_resources(Some(metadata), locals, 20000) |> ignore
    false
  } catch {
    SectionParseError(10, message) =>
      message == "local resource type found in imports"
    _ => false
  }
  assert_true(captured)
}

///|
test "import resource audit checks complete function graphs and shared value DAGs" {
  let types : Array[@component.TypeDef?] = [
    Some(ResourceType(-1, 0x7f, None, HostDefined)),
    Some(Own(0)),
  ]
  let resources : Array[Int32?] = [Some(7), None]
  for index in 1..<80 {
    types.push(Some(Tuple([TypeIdx(index), TypeIdx(index)])))
    resources.push(None)
  }
  let ft : @component.FuncType = {
    is_async: false,
    params: [],
    result: Some(TypeIdx(80)),
  }
  let complete = complete_function_signature(ft, [], [], types, resources).unwrap()
  let functions = ContractMembers::new()
  functions.sorts["f"] = Func
  functions.functions["f"] = {
    ..funcsig_of_functype({ is_async: false, params: [], result: None, }, [], []),
    complete: Some(complete),
  }
  let metadata : ScopedContractMetadata = {
    nodes: [
      {
        imports: functions,
        exports: ContractMembers::new(),
        component: true,
        core_scope: None,
      },
    ],
    types,
    resources,
    locals: Map([]),
    origins: [],
  }
  let caught = try {
    check_import_resources(Some(metadata), Map([(7, true)]), 1000) |> ignore
    false
  } catch {
    SectionParseError(10, message) =>
      message == "local resource type found in imports"
    _ => false
  }
  assert_true(caught)
  let values = ContractMembers::new()
  values.sorts["t"] = Type
  values.types["t"] = 80
  let values_metadata = {
    ..metadata,
    nodes: [
      {
        imports: ContractMembers::new(),
        exports: values,
        component: false,
        core_scope: None,
      },
    ],
  }
  assert_true(
    check_import_resources(Some(values_metadata), Map([(8, true)]), 1000) > 0,
  )
}

///|
test "import resource audit fails closed on missing contracts and bounds local scans" {
  let (locals, remaining) = import_local_resources(
    [true, false, true],
    [Some(7), Some(8), Some(7)],
    5,
  )
  assert_eq(locals.length(), 1)
  assert_eq(remaining, 2)
  assert_eq(check_import_resources(None, Map([]), 2), 2)
  let missing = try {
    check_import_resources(None, locals, 2) |> ignore
    false
  } catch {
    SectionParseError(10, _) => true
    _ => false
  }
  assert_true(missing)
  let exhausted = try {
    import_local_resources(
      [true, true, true],
      [Some(7), Some(7), Some(7)],
      remaining,
    )
    |> ignore
    false
  } catch {
    SectionParseError(10, _) => true
    _ => false
  }
  assert_true(exhausted)
}
