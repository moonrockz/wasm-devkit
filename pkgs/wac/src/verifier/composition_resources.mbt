///|
/// A static resource parameter bound to a nominal identity in one graph value.
pub(all) struct ResourceBinding {
  ty : Int32
  identity : Int32
} derive(Eq, Debug)

///|
pub extend ResourceBinding with Eq::{equal, not_equal}

///|
pub extend ResourceBinding with @debug.Debug::{to_repr}

///|
fn Check::resource_root(self : Check, id : Int32) -> Int32? {
  let mut current = id
  for _ in 0..<self.types.length() {
    match self.types[current].kind {
      Resource(None) => return Some(current)
      Resource(Some(next)) | Alias(next) => current = next
      _ => return None
    }
  }
  None
}

///|
fn Check::new_resource_identity(self : Check) -> Int32 {
  let identity = self.next_resource_identity
  self.next_resource_identity += 1
  identity
}

///|
// Collect resource parameters and the declarations that bind fresh resources.
// Following a handle or alias does not turn a captured resource into a binder.
fn Check::resource_parameters(
  self : Check,
  node : Int32,
  kind : ItemKind,
  budget~ : VerificationBudget? = None,
) -> (Array[Int32], Map[Int32, Bool]) raise SemanticFailure {
  let pending = [binary_kind_id(kind)]
  let seen : Map[Int32, Bool] = Map([])
  let resources : Map[Int32, Bool] = Map([])
  let owned : Map[Int32, Bool] = Map([])
  if kind is Type(id) && self.types[id].kind is Resource(None) {
    owned[id] = true
  }
  let mut remaining = 1000000
  while pending.pop() is Some(id) {
    if budget is Some(budget) {
      self.verification_step(budget, node)
    }
    if seen.contains(id) {
      continue
    }
    seen[id] = true
    remaining -= 1
    if remaining < 0 {
      raise Problem(
        self.problem(
          node, "WAC-C006", "resource context exceeds the verification work limit",
        ),
      )
    }
    if self.resource_root(id) is Some(resource) {
      resources[resource] = true
    }
    let ty = self.types[id].kind
    let externs = match ty {
      Interface(_, _, exports) =>
        Array::makei(exports.length(), i => exports[i])
      World(_, _, imports, exports) => {
        let items = Array::makei(imports.length(), i => imports[i])
        for item in exports {
          items.push(item)
        }
        items
      }
      _ => []
    }
    for item in externs {
      if budget is Some(budget) {
        self.verification_step(budget, node)
      }
      if item.kind is Type(resource) &&
        self.types[resource].kind is Resource(None) {
        owned[resource] = true
      }
    }
    for child in binary_children(ty) {
      if budget is Some(budget) {
        self.verification_step(budget, node)
      }
      pending.push(child)
    }
  }
  let ids : Array[Int32] = []
  for id, _ in resources {
    ids.push(id)
  }
  ids.sort()
  (ids, owned)
}

///|
fn Check::import_resource_context(
  self : Check,
  node : Int32,
  kind : ItemKind,
) -> ReadOnlyArray[ResourceBinding] raise SemanticFailure {
  let (resources, owned) = self.resource_parameters(node, kind)
  let result = []
  for ty in resources {
    let identity = if owned.contains(ty) {
      self.new_resource_identity()
    } else {
      match self.root_resources.get(ty) {
        Some(identity) => identity
        None => self.new_resource_identity()
      }
    }
    result.push({ ty, identity, })
    self.root_resources[ty] = identity
  }
  ReadOnlyArray::from_array(result)
}

///|
fn resource_binding(
  bindings : ReadOnlyArray[ResourceBinding],
  ty : Int32,
) -> Int32? {
  for binding in bindings {
    if binding.ty == ty {
      return Some(binding.identity)
    }
  }
  None
}
