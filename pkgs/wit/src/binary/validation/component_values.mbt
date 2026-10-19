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
