///|
priv struct TargetResourceEquation {
  actual : Int32
  expected : Int32
  variable : Bool
  location : Location
}

///|
// These identities describe supplying a composition's imports from a target
// environment. They never rewrite the composition's own nominal identities.
priv struct TargetResources {
  globals : Map[Int32, Int32]
  actual : Map[Int32, Int32]
  outputs : Map[Int32, Int32]
  pending : Array[TargetResourceEquation]
  mut steps : Int32
  mut next : Int32
}

///|
fn TargetResources::fresh(self : TargetResources) -> Int32 {
  let id = self.next
  self.next += 1
  id
}

///|
fn TargetResources::global(self : TargetResources, ty : Int32) -> Int32 {
  match self.globals.get(ty) {
    Some(id) => id
    None => {
      let id = self.fresh()
      self.globals[ty] = id
      id
    }
  }
}

///|
fn Check::target_import_contexts(
  self : Check,
  path : Int32,
  imports : Map[String, Extern],
  state : TargetResources,
) -> Map[String, Map[Int32, Int32]] raise SemanticFailure {
  let names : Array[String] = []
  for name, _ in imports {
    names.push(name)
  }
  names.sort_by((a, b) => a.lexical_compare(b))
  let contexts : Map[String, Map[Int32, Int32]] = Map([])
  let parameters : Map[String, Array[Int32]] = Map([])
  // Allocate binders before captures so dependency order does not affect their
  // identity. Repeated instance templates introduce separate resource binders.
  for name in names {
    let item = imports[name]
    let (resources, owned) = self.resource_parameters(path, item.kind)
    parameters[name] = resources
    let context : Map[Int32, Int32] = Map([])
    let instance = match item.kind {
      Instance(_) | Component(_) => true
      _ => false
    }
    let canonical = match self.types[binary_kind_id(item.kind)].kind {
      Interface(Some(identity), _, _) => identity == name
      _ => false
    }
    for ty in resources {
      if owned.contains(ty) {
        let id = if instance { state.fresh() } else { state.global(ty) }
        context[ty] = id
        if canonical || !state.globals.contains(ty) {
          state.globals[ty] = id
        }
      }
    }
    contexts[name] = context
  }
  for name in names {
    let context = contexts[name]
    for ty in parameters[name] {
      if !context.contains(ty) {
        context[ty] = state.global(ty)
      }
    }
  }
  contexts
}

///|
fn Check::target_export_context(
  self : Check,
  path : Int32,
  kind : ItemKind,
  state : TargetResources,
) -> (Map[Int32, Int32], Map[Int32, Bool]) raise SemanticFailure {
  let (resources, owned) = self.resource_parameters(path, kind)
  let context : Map[Int32, Int32] = Map([])
  let variables : Map[Int32, Bool] = Map([])
  let instance = match kind {
    Instance(_) | Component(_) => true
    _ => false
  }
  for ty in resources {
    if owned.contains(ty) && (instance || !state.globals.contains(ty)) {
      let id = state.fresh()
      context[ty] = id
      variables[id] = true
      if !instance {
        state.globals[ty] = id
      }
    } else {
      context[ty] = state.global(ty)
    }
  }
  (context, variables)
}

///|
fn Check::target_resource_pairs(
  self : Check,
  path : Int32,
  world : Int32,
  value : Int32,
  location : Location,
  pairs : Array[(Int32, Int32, Bool)],
  context : Map[Int32, Int32],
  variables : Map[Int32, Bool],
  state : TargetResources,
  importing : Bool,
) -> Unit raise SemanticFailure {
  for (actual, expected, bind) in pairs {
    guard resource_binding(self.composition_nodes[value].resources, actual)
      is Some(actual) &&
      context.get(expected) is Some(expected) else {
      raise Problem(
        self.target_error(
          path, world, location, "WAC-T003", "target resource has no binding",
        ),
      )
    }
    let variable = variables.contains(expected)
    if importing && bind {
      if state.actual.get(actual) is Some(previous) && previous != expected {
        raise Problem(
          self.target_error(
            path, world, location, "WAC-T003", "composition import requires resource equality absent from the target",
          ),
        )
      }
      state.actual[actual] = expected
    }
    if !importing {
      let provided = match state.actual.get(actual) {
        Some(id) => id
        None => {
          let id = state.fresh()
          state.actual[actual] = id
          id
        }
      }
      if bind && variable {
        if state.outputs.get(expected) is Some(previous) && previous != provided {
          raise Problem(
            self.target_error(
              path, world, location, "WAC-T003", "target export requires matching resource identities",
            ),
          )
        }
        state.outputs[expected] = provided
      }
    }
    state.pending.push({ actual, expected, variable, location, })
  }
}
