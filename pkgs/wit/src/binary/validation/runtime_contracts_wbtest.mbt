///|
test "runtime contracts freshen deep instance exports without changing templates" {
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
  exports.sorts["r"] = Type
  exports.types["r"] = 0
  exports.binders["r"] = true
  nodes.push({
    imports: ContractMembers::new(),
    exports,
    component: false,
    core_scope: None,
  })
  let graph : ScopedContractMetadata = {
    nodes,
    types: [Some(ResourceType(-1, 0x7f, None, HostDefined))],
    resources: [Some(7)],
    locals: Map([(7, true)]),
  }
  let counts = Counts::Counts()
  let substitutions : Map[Int32, Int32] = Map([])
  assert_eq(runtime_fresh_exports(graph, 0, substitutions, 20, counts), 21)
  assert_eq(substitutions.get(7), Some(20))
  let result = runtime_substitute(graph, substitutions, counts)
  assert_eq(result.resources[0], Some(20))
  assert_eq(graph.resources[0], Some(7))
  assert_true(graph.locals.contains(7))
  assert_false(result.locals.contains(7))
  let metadata = runtime_instance_metadata(result, 0, counts)
  assert_eq(metadata.nodes.length(), 6001)
  assert_eq(metadata.resources[0], Some(20))
  counts.metadata_remaining = 10
  let exhausted = try {
    runtime_substitute(graph, substitutions, counts) |> ignore
    false
  } catch {
    SectionParseError(5, _) => true
    _ => false
  }
  assert_true(exhausted)
}

///|
test "runtime freshening preserves captured resources and component binders" {
  let root = ContractMembers::new()
  root.sorts["captured"] = Type
  root.types["captured"] = 0
  root.sorts["child"] = Component
  root.children["child"] = 1
  let child = ContractMembers::new()
  child.sorts["r"] = Type
  child.types["r"] = 1
  child.binders["r"] = true
  let graph : ScopedContractMetadata = {
    nodes: [
      {
        imports: ContractMembers::new(),
        exports: root,
        component: true,
        core_scope: None,
      },
      {
        imports: ContractMembers::new(),
        exports: child,
        component: true,
        core_scope: None,
      },
    ],
    types: [
      Some(ResourceType(-1, 0x7f, None, HostDefined)),
      Some(ResourceType(-1, 0x7f, None, HostDefined)),
    ],
    resources: [Some(7), Some(8)],
    locals: Map([(8, true)]),
  }
  let counts = Counts::Counts()
  let substitutions : Map[Int32, Int32] = Map([])
  assert_eq(runtime_fresh_exports(graph, 0, substitutions, 20, counts), 20)
  assert_true(substitutions.is_empty())
  root.sorts["shared"] = Instance
  root.children["shared"] = 1
  assert_eq(runtime_fresh_exports(graph, 0, substitutions, 20, counts), 21)
  assert_eq(substitutions.get(8), Some(20))
}
