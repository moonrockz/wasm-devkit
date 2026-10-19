///|
priv struct ComponentValue {
  signature : CompleteFunctionSignature
  mut used : Bool
}

///|
// A synthetic one-result signature retains a complete value graph without
// assigning function semantics or imposing function-result borrow restrictions.
fn complete_value_signature(
  value : @component.ValType,
  types : Array[@component.TypeDef?],
  resources : Array[Int32?],
  budget : Int32,
  origins~ : Array[TypeOrigin?] = [],
) -> (CompleteFunctionSignature, Int32) raise IncompleteFunctionSignature {
  guard complete_function_signature(
      { is_async: false, params: [], result: Some(value), },
      [],
      [],
      types,
      resources,
      budget~,
      global_type_origins=origins,
    )
    is Some(signature) else {
    raise IncompleteFunctionSignature
  }
  (signature, budget - signature.work)
}

///|
fn Counts::value_signature(
  self : Counts,
  value : @component.ValType,
  types : Array[@component.TypeDef?],
  resources : Array[Int32?],
) -> CompleteFunctionSignature raise ComponentValidationError {
  try {
    let global_origins = self.origin_table(types.length())
    let origins : Array[TypeOrigin?] = []
    let (types, resources, rest) = metadata_global_types(
      types,
      resources,
      self.type_metadata,
      self.metadata_remaining,
      origins=Some(origins),
      global_origins~,
    )
    let (signature, remaining) = complete_value_signature(
      value,
      types,
      resources,
      rest,
      origins~,
    )
    self.metadata_remaining = remaining
    signature
  } catch {
    _ =>
      raise SectionParseError(
        10, "value requires complete metadata within the work limit",
      )
  }
}

///|
fn Counts::consume_value(
  self : Counts,
  index : Int32,
  section : Int32,
) -> CompleteFunctionSignature raise ComponentValidationError {
  guard self.values.get(index) is Some(value) else {
    raise SectionParseError(section, "value index out of bounds")
  }
  if value.used {
    raise SectionParseError(section, "value cannot be used more than once")
  }
  value.used = true
  value.signature
}

///|

///|
fn validate_component_start(
  start : @component.Start,
  counts : Counts,
  func_types : Array[@component.FuncType?],
  type_table : Array[@component.TypeDef?],
  resource_ids : Array[Int32?],
) -> Unit raise ComponentValidationError {
  if counts.started {
    raise SectionParseError(
      9, "component cannot have more than one start function",
    )
  }
  counts.started = true
  guard func_types.get(start.func_idx) is Some(Some(ft)) else {
    raise InvalidFuncIndex(start.func_idx)
  }
  if ft.params.length() != start.args.length() {
    raise SectionParseError(
      9,
      "component start function requires \{ft.params.length()} arguments but was given \{start.args.length()}",
    )
  }
  let type_results = if ft.result is Some(_) { 1 } else { 0 }
  if start.results != type_results {
    raise SectionParseError(
      9,
      "component start function has a result count of \{start.results} but the function type has a result count of \{type_results}",
    )
  }
  for i, arg in start.args {
    let actual = counts.consume_value(arg, 9)
    let expected = counts.value_signature(
      ft.params[i].ty,
      type_table,
      resource_ids,
    )
    try {
      counts.ascription_remaining = check_function_ascription(
        actual.function,
        expected.function,
        actual.types,
        actual.resources,
        budget=counts.ascription_remaining,
        expected_types=Some(expected.types),
        expected_resources=Some(expected.resources),
      )
    } catch {
      AscribedExportTypeIncompatible =>
        raise SectionParseError(
          9,
          "value type mismatch for component start function argument \{i}",
        )
      error => raise error
    }
  }
  if ft.result is Some(result) {
    let signature = counts.value_signature(result, type_table, resource_ids)
    counts.values.push({ signature, used: false, })
    counts.value += 1
  }
}

///|
fn check_value_export(
  signature : CompleteFunctionSignature,
  cfg : ComponentValidationConfig,
) -> Unit raise ComponentValidationError {
  guard signature.function.result is Some(value) else {
    raise SectionParseError(11, "incomplete value type")
  }
  if !cfg.borrowed_value_exports &&
    valtype_contains_borrow(value, signature.types, Map([])) {
    raise SectionParseError(
      11, "exported value type cannot contain a borrow type",
    )
  }
  // The caller separately checks complete origin visibility after any explicit
  // ascription. Runtime-produced values follow the same escaping-type rule.
}
