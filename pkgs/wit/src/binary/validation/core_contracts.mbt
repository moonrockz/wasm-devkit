// Complete core contracts supplement the retained validator's legacy tables.

///|
priv struct CoreContractWork {
  mut remaining : Int32
}

///|
fn CoreContractWork::charge(
  self : CoreContractWork,
  amount : Int32,
) -> Unit raise ComponentValidationError {
  if amount < 0 || amount > self.remaining {
    raise CoreContractBudgetExceeded
  }
  self.remaining -= amount
}

///|
fn core_contract_kind(kind : @core_types.External) -> Int32 {
  match kind {
    Func(_) => 0
    Table(_, _, _, _, _) => 1
    Memory(_, _, _, _, _) => 2
    Global(_, _, _) => 3
    Tag(_) => 4
  }
}

///|
fn core_contract_instance(
  instance : @component.CoreInstanceDecl,
  scope : @core_types.ContractScope,
  instances : Array[Map[String, @core_types.External]],
  externs : Map[(Int32, Int32), @core_types.External],
  work : CoreContractWork,
) -> Map[String, @core_types.External] raise ComponentValidationError {
  let exports = Map([])
  match instance.expr {
    Instantiate(module_index, arguments) => {
      guard scope.binding(0x111, module_index) is Some(Module(contract)) else {
        raise CoreModuleError("missing complete core module contract")
      }
      let providers : Map[String, Int32] = Map([])
      for argument in arguments {
        work.charge(1)
        guard argument.sortidx.sort is Core(0x12) else {
          raise CoreModuleError("core module arguments must be core instances")
        }
        if providers.contains(argument.name) {
          raise CoreModuleError("duplicate core module argument")
        }
        guard instances.get(argument.sortidx.idx) is Some(_) else {
          raise CoreModuleError("core instance argument index is out of bounds")
        }
        providers[argument.name] = argument.sortidx.idx
      }
      for required in contract.imports {
        work.charge(1)
        guard providers.get(required.module_name) is Some(provider) &&
          instances[provider].get(required.name) is Some(actual) else {
          raise CoreModuleError(
            "missing core module import `\{required.module_name}:\{required.name}`",
          )
        }
        match
          @core_types.check_external_subtype(
            actual,
            required.kind,
            work_limit=work.remaining,
          ) {
          Ok(remaining) => work.remaining = remaining
          Err(WorkLimit) => raise CoreContractBudgetExceeded
          Err(Mismatch(message)) => raise CoreModuleError(message)
        }
      }
      for exported in contract.exports {
        work.charge(1)
        exports[exported.name] = exported.kind
      }
    }
    InlineExports(items) =>
      for item in items {
        work.charge(1)
        guard item.sortidx.sort is Core(kind) &&
          externs.get((kind, item.sortidx.idx)) is Some(value) else {
          raise CoreModuleError("core instance export has no complete contract")
        }
        if exports.contains(item.name) {
          raise DuplicateExportName(item.name)
        }
        exports[item.name] = value
      }
  }
  exports
}

///|
fn core_contract_aliases(
  payload : Bytes,
  counts : Counts,
  instances : Array[Map[String, @core_types.External]],
  externs : Map[(Int32, Int32), @core_types.External],
  work : CoreContractWork,
) -> Unit raise ComponentValidationError {
  let indices = [
    counts.core_func,
    counts.core_table,
    counts.core_memory,
    counts.core_global,
    counts.core_tag,
  ]
  let aliases = @component.parse_alias_section(payload) catch {
    e => raise SectionParseError(6, e.to_string())
  }
  for entry in aliases {
    work.charge(1)
    if entry.sort is Core(kind) && kind >= 0 && kind <= 4 {
      guard entry.target is CoreExport(instance, name) &&
        instances.get(instance) is Some(exports) &&
        exports.get(name) is Some(value) else {
        raise CoreModuleError("core alias has no complete contract")
      }
      if core_contract_kind(value) != kind {
        raise CoreModuleError("core alias export kind does not match")
      }
      externs[(kind, indices[kind])] = value
      indices[kind] += 1
    }
  }
}
