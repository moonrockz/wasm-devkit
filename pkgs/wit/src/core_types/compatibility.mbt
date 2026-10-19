///|
/// A mismatch between validated core contracts, or exhausted comparison work.
pub(all) enum CompatibilityError {
  Mismatch(String)
  WorkLimit
} derive(Eq, Debug)

///|
pub extend CompatibilityError with Eq::{equal, not_equal}

///|
pub extend CompatibilityError with @debug.Debug::{to_repr}

///|
priv suberror CompatibilityFailure {
  CompatibilityFailure(CompatibilityError)
}

///|
priv struct CompatibilityBudget {
  mut remaining : Int32
}

///|
fn CompatibilityBudget::charge(
  self : CompatibilityBudget,
  count : Int32,
) -> Unit raise CompatibilityFailure {
  if count < 0 || count > self.remaining {
    raise CompatibilityFailure(WorkLimit)
  }
  self.remaining -= count
}

///|
fn limits_subtype(ai : UInt64, am : UInt64?, bi : UInt64, bm : UInt64?) -> Bool {
  if ai < bi {
    return false
  }
  match (am, bm) {
    (Some(a), Some(b)) => a <= b
    (None, Some(_)) => false
    _ => true
  }
}

///|
fn external_subtype(
  a : External,
  b : External,
  budget : CompatibilityBudget,
) -> Bool raise CompatibilityFailure {
  budget.charge(1)
  match (a, b) {
    (Func(a), Func(b)) | (Tag(a), Tag(b)) => {
      budget.charge(a.params.length())
      budget.charge(a.results.length())
      budget.charge(b.params.length())
      budget.charge(b.results.length())
      a == b
    }
    (Table(ae, ai, am, a64, ash), Table(be, bi, bm, b64, bsh)) =>
      ae == be && a64 == b64 && ash == bsh && limits_subtype(ai, am, bi, bm)
    (Memory(ai, am, a64, ash, ap), Memory(bi, bm, b64, bsh, bp)) =>
      a64 == b64 && ash == bsh && ap == bp && limits_subtype(ai, am, bi, bm)
    (Global(at, am, ash), Global(bt, bm, bsh)) =>
      at == bt && am == bm && ash == bsh
    _ => false
  }
}

///|
/// Check whether an already validated actual extern satisfies an expected
/// extern. Success returns the unused work allowance. This compares signatures;
/// it does not validate executable instructions or certify caller-built types.
pub fn check_external_subtype(
  actual : External,
  expected : External,
  work_limit~ : Int32 = 1000000,
) -> Result[Int32, CompatibilityError] {
  let budget = { remaining: work_limit, }
  try {
    if external_subtype(actual, expected, budget) {
      Ok(budget.remaining)
    } else {
      Err(Mismatch("incompatible core external type"))
    }
  } catch {
    CompatibilityFailure(error) => Err(error)
  }
}

///|
/// Compare validated module contracts: actual imports are contravariant and
/// exports covariant. Import keys are separate module/name pairs. Success
/// returns the unused work allowance; loops and signature comparisons consume
/// that same allowance. Duplicate contract keys reject deterministically.
pub fn check_module_subtype(
  actual : Module,
  expected : Module,
  work_limit~ : Int32 = 1000000,
) -> Result[Int32, CompatibilityError] {
  let budget = { remaining: work_limit, }
  try {
    budget.charge(1)
    let imports : Map[(String, String), External] = Map([])
    for item in expected.imports {
      budget.charge(1)
      let key = (item.module_name, item.name)
      if imports.contains(key) {
        return Err(Mismatch("duplicate expected core module import"))
      }
      imports[key] = item.kind
    }
    let actual_imports : Map[(String, String), Bool] = Map([])
    for item in actual.imports {
      budget.charge(1)
      let key = (item.module_name, item.name)
      if actual_imports.contains(key) {
        return Err(Mismatch("duplicate actual core module import"))
      }
      actual_imports[key] = true
      guard imports.get(key) is Some(required) else {
        return Err(
          Mismatch(
            "unexpected core module import `" +
            item.module_name +
            "::" +
            item.name +
            "`",
          ),
        )
      }
      if !external_subtype(required, item.kind, budget) {
        return Err(
          Mismatch(
            "incompatible core module import `" +
            item.module_name +
            "::" +
            item.name +
            "`",
          ),
        )
      }
    }
    let exports : Map[String, External] = Map([])
    for item in actual.exports {
      budget.charge(1)
      if exports.contains(item.name) {
        return Err(Mismatch("duplicate actual core module export"))
      }
      exports[item.name] = item.kind
    }
    let expected_exports : Map[String, Bool] = Map([])
    for item in expected.exports {
      budget.charge(1)
      if expected_exports.contains(item.name) {
        return Err(Mismatch("duplicate expected core module export"))
      }
      expected_exports[item.name] = true
      guard exports.get(item.name) is Some(provided) else {
        return Err(Mismatch("missing core module export `" + item.name + "`"))
      }
      if !external_subtype(provided, item.kind, budget) {
        return Err(
          Mismatch("incompatible core module export `" + item.name + "`"),
        )
      }
    }
    Ok(budget.remaining)
  } catch {
    CompatibilityFailure(error) => Err(error)
  }
}
