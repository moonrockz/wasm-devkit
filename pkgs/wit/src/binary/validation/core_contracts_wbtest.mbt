///|
test "core instance contracts share the operation work allowance" {
  let contract : @core_types.Module = {
    imports: [],
    exports: [{ name: "f", kind: Func({ params: [], results: [], }), }],
  }
  let scope = @core_types.ContractScope::new(
    [],
    [(0x111, [Module(contract)])],
    [],
  )
  let instance : @component.CoreInstanceDecl = { expr: Instantiate(0, []), }
  let work : CoreContractWork = { remaining: 2, }
  assert_eq(
    core_contract_instance(instance, scope, [], Map([]), work).length(),
    1,
  )
  assert_eq(
    core_contract_instance(instance, scope, [], Map([]), work).length(),
    1,
  )
  let exhausted = try {
    ignore(core_contract_instance(instance, scope, [], Map([]), work))
    false
  } catch {
    CoreContractBudgetExceeded => true
    _ => false
  }
  assert_true(exhausted)
}
