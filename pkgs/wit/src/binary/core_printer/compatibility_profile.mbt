///|
// The public decompiler rejects this proposal before constructing its model.
// Keep direct calls to the lower-level compatibility renderer atomic too.
fn validate_compatibility_control(
  mod_ : @types.Module,
) -> Unit raise WatPrintError {
  let work = mod_.codes.map(code => code.body)
  while work.pop() is Some(body) {
    for instruction in body {
      match instruction {
        TryTable(_) | LegacyTry(_) | Rethrow(_) =>
          raise ReferenceUnsupported(
            "exception control is outside the compatibility input profile",
          )
        Block(_, nested) | Loop(_, nested) => work.push(nested)
        If(_, then_, else_) => {
          work.push(then_)
          work.push(else_)
        }
        _ => ()
      }
    }
  }
}

///|
fn wabt_value(value : String) -> Unit raise WatPrintError {
  if ![
      "i32", "i64", "f32", "f64", "v128", "funcref", "externref", "exnref", "(ref func)",
      "(ref extern)", "",
    ].contains(value) {
    raise ReferenceUnsupported(
      "WABT 1.0.42 does not support value type " + value,
    )
  }
}

///|
fn validate_wabt_types(
  mod_ : @types.Module,
  metadata : @core_parser.ModuleTextMetadata,
) -> Unit raise WatPrintError {
  if metadata.import_global_flags.any(pair => (pair.1 & 2) != 0) ||
    metadata.global_flags.any(pair => (pair.1 & 2) != 0) {
    raise ReferenceUnsupported("WABT 1.0.42 does not support shared globals")
  }
  for type_ in mod_.types {
    if !(type_.composite is Func(_)) {
      raise ReferenceUnsupported(
        "WABT 1.0.42 does not support GC or shared composite types",
      )
    }
  }
  for code in mod_.codes {
    if code.locals.length() > 50000 {
      raise ReferenceUnsupported("WABT 1.0.42 limits function locals to 50000")
    }
  }
  if !metadata.explicit_rec_groups.is_empty() {
    raise ReferenceUnsupported(
      "WABT 1.0.42 does not support explicit recursive type groups",
    )
  }
  if metadata.subtype_encodings.any(value => value) {
    raise ReferenceUnsupported("WABT 1.0.42 does not support subtype encodings")
  }
  for type_ in metadata.type_values {
    for value in type_.params {
      wabt_value(value)
    }
    for value in type_.results {
      wabt_value(value)
    }
  }
  for
    values in [
      metadata.import_values,
      metadata.table_values,
      metadata.global_values,
      metadata.element_values,
    ] {
    for value in values {
      wabt_value(value)
    }
  }
  for values in metadata.local_values {
    for value in values {
      wabt_value(value)
    }
  }
  for instructions in metadata.instruction_values {
    for (_, values) in instructions {
      for value in values {
        wabt_value(value)
      }
    }
  }
  let work : Array[Array[@types.Instruction]] = []
  for global in mod_.globals {
    work.push(global.init)
  }
  for table in mod_.tables {
    if table.init is Some(init) {
      work.push(init)
    }
  }
  for elem in mod_.elems {
    for init in elem.init {
      work.push(init)
    }
  }
  for code in mod_.codes {
    work.push(code.body)
  }
  while work.pop() is Some(body) {
    for instruction in body {
      match instruction {
        RefNull(type_) => wabt_value(compatible_value_type(type_))
        RefEqInstr =>
          raise ReferenceUnsupported("WABT 1.0.42 does not support ref.eq")
        Block(_, nested) | Loop(_, nested) => work.push(nested)
        If(_, then_, else_) => {
          work.push(then_)
          work.push(else_)
        }
        _ => ()
      }
    }
  }
}

///|
fn validate_wabt_names(
  mod_ : @types.Module,
  names : Names,
) -> Unit raise WatPrintError {
  let functions = imported_function_count(mod_) + mod_.funcs.length()
  if names.map_counts.get((1, 0)) is Some(count) &&
    count > functions.reinterpret_as_uint() {
    raise BinaryMetadata("function name count exceeds the WABT function count")
  }
  for (kind, scope), count in names.map_counts {
    if kind != 2 {
      continue
    }
    if scope < 0 || scope >= functions {
      raise BinaryMetadata("invalid function index in local names")
    }
    let imported = imported_function_count(mod_)
    let signature = if scope < imported {
      let mut at = 0
      let mut type_ = -1
      for import_ in mod_.imports {
        if import_.desc is Func(i) {
          if at == scope {
            type_ = i
            break
          }
          at += 1
        }
      }
      type_
    } else {
      mod_.funcs[scope - imported]
    }
    let locals = if scope < imported {
      0
    } else {
      mod_.codes[scope - imported].locals.length()
    }
    let params = mod_
      .func_type_at(signature)
      .map(t => t.params.length())
      .unwrap_or(0)
    if count > (params + locals).reinterpret_as_uint() {
      raise BinaryMetadata("local name count exceeds the WABT local count")
    }
  }
  let (tables, memories, globals, tags) = imported_counts(mod_)
  for index in names.named_functions {
    if index < 0 || index >= functions {
      raise BinaryMetadata("invalid function name index")
    }
  }
  for (kind, _, index), _ in names.entries {
    let limit = match kind {
      1 => functions
      4 => mod_.types.length()
      5 => tables + mod_.tables.length()
      6 => memories + mod_.memories.length()
      7 => globals + mod_.globals.length()
      8 => mod_.elems.length()
      9 => mod_.datas.length()
      11 => tags + mod_.tags.length()
      _ => continue
    }
    if index < 0 || index >= limit {
      raise BinaryMetadata("debug-name index is outside the WABT index space")
    }
  }
}
