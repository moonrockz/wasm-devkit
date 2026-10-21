///|
/// Validate a complete module
pub fn validate_module(
  mod : @types.Module,
  bulk_memory~ : Bool = true,
  stack_switching~ : Bool = false,
) -> Unit raise ValidationError {
  let ctx = ValidationContext::ValidationContext(
    mod,
    bulk_memory~,
    stack_switching~,
  )
  errdefer (if ctx.subtyping_ctx.work_exhausted() { raise TypeWorkLimit })
  validate_module_in_scope(mod, ctx, bulk_memory, stack_switching, false)
  if ctx.subtyping_ctx.work_exhausted() {
    raise TypeWorkLimit
  }
}

///|
fn validate_module_in_scope(
  mod : @types.Module,
  ctx : ValidationContext,
  bulk_memory : Bool,
  stack_switching : Bool,
  with_context : Bool,
) -> Unit raise ValidationError {
  validate_segment_features(mod, bulk_memory)
  validate_continuation_types(mod, stack_switching)
  let num_types = ctx.types.length()

  // Validate that all function type indices are valid
  for i, type_idx in ctx.funcs {
    if type_idx < 0 || type_idx >= num_types {
      raise InvalidTypeIndex(type_idx)
    }
    ignore(ctx.get_func_type(type_idx))
    ignore(i)
  }

  // Validate type indices in function types (parameters and results)
  for subtype in mod.types {
    for vt in collect_value_types_from_subtype(subtype) {
      validate_value_type(vt, num_types, stack_switching~)
      validate_reference_metadata(vt, mod.types)
      if subtype.composite.is_shared() && vt.heap() is Some((_, false, _)) {
        raise TypeMismatch(
          "shared composite types require shared reference fields and signatures",
        )
      }
    }
  }

  // Validate forward type references are only within rec groups
  for type_idx, subtype in mod.types {
    for vt in collect_value_types_from_subtype(subtype) {
      validate_type_forward_refs(vt, type_idx, mod.type_rec_groups)
    }
  }

  // Validate subtype declarations: supertypes must not be final, must have matching kind,
  // and must satisfy structural subtyping rules
  let subtyping_ctx = ctx.subtyping_ctx
  let subtype_depths = Array::make(num_types, 0)
  for type_idx, subtype in mod.types {
    if subtype.supertypes.length() > 1 {
      raise TypeMismatch("multiple core supertypes are invalid")
    }
    for super_idx in subtype.supertypes {
      if super_idx < 0 || super_idx >= num_types {
        raise InvalidTypeIndex(super_idx)
      }
      if super_idx >= type_idx {
        raise TypeMismatch("core supertypes must precede their subtypes")
      }
      subtype_depths[type_idx] = subtype_depths[super_idx] + 1
      if subtype_depths[type_idx] > 63 {
        raise TypeMismatch("core subtype depth exceeds 63")
      }
      let supertype = mod.types[super_idx]
      if supertype.final_ {
        raise TypeMismatch(
          "sub type: type \{type_idx} cannot extend final type \{super_idx}",
        )
      }
      // Validate composite type kinds match
      let valid_kind = match
        (subtype.composite.unshared(), supertype.composite.unshared()) {
        (Func(_), Func(_)) => true
        (Struct(_), Struct(_)) => true
        (Array(_), Array(_)) => true
        (Cont(_), Cont(_)) => true
        _ => false
      }
      if !valid_kind {
        raise TypeMismatch(
          "sub type: type \{type_idx} has incompatible kind with supertype \{super_idx}",
        )
      }
      // Validate structural subtyping: subtype's structure must be compatible with supertype
      if !subtyping_ctx.validate_declared_subtype(type_idx, super_idx) {
        raise TypeMismatch(
          "sub type: type \{type_idx} is not a valid structural subtype of \{super_idx}",
        )
      }
    }
    ignore(type_idx)
  }

  // Validate type indices in global types
  for global in ctx.globals {
    validate_value_type(global.value_type, num_types, stack_switching~)
    validate_reference_metadata(global.value_type, mod.types)
    if global.is_shared && !is_shared_value_type(global.value_type) {
      raise TypeMismatch("shared globals require shared values")
    }
  }

  // Validate type indices in table element types
  for table in ctx.tables {
    validate_value_type(table.elem_type, num_types, stack_switching~)
    validate_reference_metadata(table.elem_type, mod.types)
    validate_table_limits(table.limits, is_table64=table.is_table64)
    if table.is_shared && !is_shared_value_type(table.elem_type) {
      raise TypeMismatch("shared tables require shared references")
    }
    if !is_ref_type(table.elem_type) {
      raise TypeMismatch("core table requires a reference type")
    }
  }

  // Validate type indices in elem segment types
  for elem in mod.elems {
    validate_value_type(elem.type_, num_types, stack_switching~)
    validate_reference_metadata(elem.type_, mod.types)
  }

  // Multi-memory support is now enabled
  // The restriction has been removed to support WebAssembly multi-memory proposal

  // Multi-table support is now enabled
  // The restriction has been removed to support WebAssembly reference types proposal

  // Validate memory limits
  for mem in ctx.mems {
    validate_memory_limits(mem)
  }

  // Validate table types and limits
  let table_ctx : ValidationContext = {
    ..ctx,
    globals: ctx.globals[:count_global_imports(mod.imports)],
  }
  for table in mod.tables {
    validate_table_type(table, table_ctx, ctx.funcs)
  }

  // Validate global initialization expressions
  // For each global, its init expression can only reference previously defined globals
  // (imported globals are already in ctx.globals from imports)
  let num_imported_globals = count_global_imports(mod.imports)
  for i, global in mod.globals {
    // Validate init expression (pass funcs to allow ref.func in global init)
    validate_const_expr(
      ctx.globals[:num_imported_globals + i],
      global.init,
      global.type_.value_type,
      funcs=ctx.funcs,
      types=ctx.types,
      subtyping_ctx=Some(ctx.subtyping_ctx),
      stack_switching=ctx.stack_switching,
    )
  }

  // Validate data segments reference valid memory and have valid offset expressions
  for data in mod.datas {
    // Passive data segments have no offset expression to validate.
    if data.memory_idx < 0 {
      continue
    }
    if data.memory_idx < 0 || data.memory_idx >= ctx.mems.length() {
      raise InvalidMemoryIndex(data.memory_idx)
    }
    // Validate offset expression with the target memory's address type.
    let offset_type = ctx.mems[data.memory_idx].addr_type()
    validate_const_expr(
      ctx.globals,
      data.offset,
      offset_type,
      types=ctx.types,
      subtyping_ctx=Some(ctx.subtyping_ctx),
      stack_switching=ctx.stack_switching,
    )
  }

  // Validate elem segments
  for elem in mod.elems {
    // Validate offset expression for active elem segments
    if elem.mode is Active(table_idx, offset_expr) {
      // Check table index is valid
      if table_idx >= ctx.tables.length() {
        raise InvalidTableIndex(table_idx)
      }
      // Check element type matches table element type
      let table_elem_type = ctx.tables[table_idx].elem_type
      if !ctx.subtyping_ctx.value_type_subtype(elem.type_, table_elem_type) {
        raise TypeMismatch(
          "element segment type \{elem.type_} is not subtype of table element type \{table_elem_type}",
        )
      }
      // Validate offset expression - i32 for table32, i64 for table64
      let offset_type = if ctx.tables[table_idx].is_table64 {
        @types.ValueType::I64
      } else {
        I32
      }
      validate_const_expr(
        ctx.globals,
        offset_expr,
        offset_type,
        types=ctx.types,
        subtyping_ctx=Some(ctx.subtyping_ctx),
        stack_switching=ctx.stack_switching,
      )
    }
    // Validate each init expression is a constant expression producing the element type
    for init in elem.init {
      validate_const_expr(
        ctx.globals,
        init,
        elem.type_,
        funcs=ctx.funcs,
        types=ctx.types,
        subtyping_ctx=Some(ctx.subtyping_ctx),
        stack_switching=ctx.stack_switching,
      )
    }
  }

  // Validate exports
  let export_names : Map[String, Unit] = Map([])
  for exp in mod.exports {
    // Check for duplicate export names
    if export_names.contains(exp.name) {
      raise DuplicateExportName(exp.name)
    }
    export_names.set(exp.name, ())
    // Check that export references a valid entity
    match exp.desc {
      Func(idx) =>
        if idx >= ctx.funcs.length() {
          raise UnknownExport("unknown function \{idx}")
        }
      Global(idx) =>
        if idx >= ctx.globals.length() {
          raise UnknownExport("unknown global \{idx}")
        }
      Table(idx) =>
        if idx >= ctx.tables.length() {
          raise UnknownExport("unknown table \{idx}")
        }
      Memory(idx) =>
        if idx >= ctx.mems.length() {
          raise UnknownExport("unknown memory \{idx}")
        }
      Tag(idx) => {
        // Validate tag index - count imported tags plus defined tags
        let num_imported_tags = count_tag_imports(mod.imports)
        let total_tags = num_imported_tags + mod.tags.length()
        if idx >= total_tags {
          raise UnknownExport("unknown tag \{idx}")
        }
      }
    }
  }

  // Validate start function if present
  if mod.start is Some(start_idx) {
    // Check that the function index is valid
    if start_idx >= ctx.funcs.length() {
      raise InvalidFunctionIndex(start_idx)
    }
    // Get the function type
    let type_idx = ctx.funcs[start_idx]
    let func_type = ctx.get_func_type(type_idx)
    // Start function must have type [] -> [] (no params, no results)
    if func_type.params.length() != 0 || func_type.results.length() != 0 {
      raise InvalidStartFunction("start function")
    }
  }

  // Validate all function bodies
  let num_imports = count_func_imports(mod.imports)
  for i, code in mod.codes {
    let func_idx = num_imports + i
    let type_idx = ctx.funcs[func_idx]
    if type_idx < 0 || type_idx >= ctx.types.length() {
      raise InvalidTypeIndex(type_idx)
    }
    let func_type = ctx.get_func_type(type_idx)
    if with_context {
      validate_function_with_offset(
        ctx,
        func_type,
        code,
        func_idx,
        shared=ctx.types[type_idx].composite.is_shared(),
      )
    } else {
      validate_function(
        ctx,
        func_type,
        code,
        shared=ctx.types[type_idx].composite.is_shared(),
      )
    }
  }
}

///|
/// Validate a complete module and return detailed error context on failure
pub fn validate_module_with_context(
  mod : @types.Module,
  bulk_memory~ : Bool = true,
  stack_switching~ : Bool = false,
) -> Unit raise ValidationError {
  let ctx = ValidationContext::ValidationContext(
    mod,
    bulk_memory~,
    stack_switching~,
  )
  errdefer (if ctx.subtyping_ctx.work_exhausted() { raise TypeWorkLimit })
  validate_module_in_scope(mod, ctx, bulk_memory, stack_switching, true) catch {
    WithContext(context) => raise WithContext(context)
    TypeWorkLimit => raise TypeWorkLimit
    error => raise WithContext(ValidationErrorContext::from_error(error))
  }
  if ctx.subtyping_ctx.work_exhausted() {
    raise TypeWorkLimit
  }
}

///|
fn validate_segment_features(
  mod : @types.Module,
  bulk_memory : Bool,
) -> Unit raise ValidationError {
  if bulk_memory {
    return
  }
  for data in mod.datas {
    if data.memory_idx < 0 {
      raise TypeMismatch("bulk memory support is not enabled")
    }
  }
  for elem in mod.elems {
    match elem.mode {
      Active(_, _) => ()
      _ => raise TypeMismatch("bulk memory support is not enabled")
    }
  }
}
