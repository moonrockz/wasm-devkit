///|
/// WIT package types translated into WAC's semantic domain, with original WIT
/// provenance. This model does not claim to contain executable component bytes.
pub struct WitPackage {
  priv arena : ReadOnlyArray[ResolvedType]
  priv world_type : Int32
  priv instance_type : Int32
  priv defined_items : ReadOnlyArray[Extern]
}

///|
pub fn WitPackage::types(self : WitPackage) -> ReadOnlyArray[ResolvedType] {
  self.arena
}

///|
pub fn WitPackage::world(self : WitPackage) -> Int32 {
  self.world_type
}

///|
pub fn WitPackage::instance(self : WitPackage) -> Int32 {
  self.instance_type
}

///|
pub fn WitPackage::definitions(self : WitPackage) -> ReadOnlyArray[Extern] {
  self.defined_items
}

///|
priv struct WitAdapter {
  types : Map[Int32, @wit_verifier.ResolvedType]
  interfaces : Map[Int32, @wit_verifier.ResolvedInterface]
  functions : Map[Int32, @wit_verifier.ResolvedFunction]
  owners : Map[Int32, Int32]
  roots : Map[Int32, Int32]
  arena : Array[ResolvedType]
  mut remaining : Int32
}

///|
priv struct WitContext {
  types : Map[Int32, Int32]
  interfaces : Map[Int32, Int32]
}

///|
fn wit_location(location : @wit_verifier.Location) -> Location {
  let position : Position = match location.position {
    SourceSpan(span) => SourceSpan({ start: span.start, end: span.end, })
    BinaryOffset(offset) => BinaryOffset(offset)
  }
  { source: location.source, position, }
}

///|
fn wit_problem(location : Location, message : String) -> Diagnostic {
  { code: "WAC-W001", message, primary: { location, message, }, related: [], }
}

///|
fn WitAdapter::step(
  self : WitAdapter,
  location : Location,
) -> Unit raise SemanticFailure {
  self.remaining -= 1
  if self.remaining < 0 {
    raise Problem(
      wit_problem(
        location, "WIT adaptation exceeds the verification work limit",
      ),
    )
  }
}

///|
fn WitAdapter::add(
  self : WitAdapter,
  name : String?,
  kind : TypeKind,
  location : Location,
) -> Int32 {
  let id = self.arena.length()
  self.arena.push({ id, name, kind, location, })
  id
}

///|
fn wit_children(kind : @wit_verifier.TypeKind) -> Array[Int32] {
  match kind {
    Alias(id) | Own(id) | Borrow(id) | Option(id) | List(id, _) => [id]
    Tuple(ids) => ids.iter().to_array()
    Map(a, b) => [a, b]
    Result(a, b) => {
      let result = []
      if a is Some(id) {
        result.push(id)
      }
      if b is Some(id) {
        result.push(id)
      }
      result
    }
    Future(id) | Stream(id) =>
      match id {
        Some(id) => [id]
        None => []
      }
    Record(fields) => fields.map(field => field.ty).iter().to_array()
    Variant(cases) => {
      let result = []
      for c in cases {
        if c.payload is Some(id) {
          result.push(id)
        }
      }
      result
    }
    _ => []
  }
}

///|
fn WitAdapter::root(
  self : WitAdapter,
  initial : Int32,
) -> Int32 raise SemanticFailure {
  let mut id = initial
  let path = []
  while self.types[id].kind is Alias(next) {
    if self.roots.get(id) is Some(root) {
      id = root
      break
    }
    self.step(wit_location(self.types[id].location))
    path.push(id)
    id = next
  }
  for previous in path {
    self.roots[previous] = id
  }
  id
}

///|
fn WitAdapter::copy_type(
  self : WitAdapter,
  root : Int32,
  context : WitContext,
) -> Int32 raise SemanticFailure {
  let pending = [(root, false)]
  while pending.pop() is Some((id, finish)) {
    if context.types.contains(id) {
      continue
    }
    let ty = self.types[id]
    let location = wit_location(ty.location)
    self.step(location)
    if !finish {
      pending.push((id, true))
      for child in wit_children(ty.kind) {
        if !context.types.contains(child) {
          pending.push((child, false))
        }
      }
      continue
    }
    let get = fn(id : Int32) { context.types[id] }
    let kind : TypeKind = match ty.kind {
      Scalar(name) => Scalar(name)
      Resource => Resource(None)
      Alias(target) =>
        if self.types[self.root(target)].kind is Resource {
          Resource(Some(get(self.root(target))))
        } else {
          Alias(get(target))
        }
      Own(target) => Own(get(self.root(target)))
      Borrow(target) => Borrow(get(self.root(target)))
      List(element, None) => List(get(element))
      List(element, Some(length)) =>
        FixedList(get(element), length.reinterpret_as_int())
      Tuple(elements) => Tuple(elements.map(get))
      Option(element) => Option(get(element))
      Result(ok, error) => Result(ok.map(get), error.map(get))
      Future(element) => Future(element.map(get))
      Stream(element) => Stream(element.map(get))
      Map(key, value) => Map(get(key), get(value))
      Record(fields) =>
        Record(
          fields.map(field => {
            name: field.name,
            ty: get(field.ty),
            location: wit_location(field.location),
          }),
        )
      Flags(names) => Flags(names)
      Enum(names) => Enum(names)
      Variant(cases) =>
        Variant(
          cases.map(c => {
            name: c.name,
            payload: c.payload.map(get),
            location: wit_location(c.location),
          }),
        )
    }
    context.types[id] = self.add(ty.name, kind, location)
  }
  context.types[root]
}

///|
fn WitAdapter::copy_function(
  self : WitAdapter,
  function : @wit_verifier.ResolvedFunction,
  context : WitContext,
) -> Int32 raise SemanticFailure {
  self.step(wit_location(function.location))
  let params = []
  for param in function.params {
    params.push({
      name: param.name,
      ty: self.copy_type(param.ty, context),
      location: wit_location(param.location),
    })
  }
  let result = match function.result {
    Some(id) => Some(self.copy_type(id, context))
    None => None
  }
  self.add(
    Some(function.name),
    Function(ReadOnlyArray::from_array(params), result, function.asynchronous),
    wit_location(function.location),
  )
}

///|
fn wit_identity(
  identity : @wit_verifier.PackageIdentity,
  name : String,
) -> String {
  identity.namespace_name +
  ":" +
  identity.name +
  "/" +
  name +
  identity.version.map(version => "@" + version).unwrap_or("")
}

///|
pub fn WitPackage::resource_identity(
  self : WitPackage,
  initial : Int32,
) -> Int32? {
  let mut id = initial
  for _ in 0..<self.arena.length() {
    guard id >= 0 && id < self.arena.length() else { return None }
    match self.arena[id].kind {
      Resource(None) => return Some(id)
      Resource(Some(next)) | Alias(next) => id = next
      _ => return None
    }
  }
  None
}
