///|
fn binary_children(kind : TypeKind) -> Array[Int32] {
  let result = []
  match kind {
    Alias(id)
    | Resource(Some(id))
    | Own(id)
    | Borrow(id)
    | List(id)
    | FixedList(id, _)
    | Option(id) => result.push(id)
    Map(key, value) => {
      result.push(key)
      result.push(value)
    }
    Tuple(types) =>
      for ty in types {
        result.push(ty)
      }
    Result(ok, error) => {
      if ok is Some(id) {
        result.push(id)
      }
      if error is Some(id) {
        result.push(id)
      }
    }
    Future(value) | Stream(value) => if value is Some(id) { result.push(id) }
    Record(fields) | Function(fields, _, _) => {
      for field in fields {
        result.push(field.ty)
      }
      if kind is Function(_, Some(id), _) {
        result.push(id)
      }
    }
    Variant(cases) =>
      for case in cases {
        if case.payload is Some(id) {
          result.push(id)
        }
      }
    Interface(_, _, exports) =>
      for item in exports {
        result.push(binary_kind_id(item.kind))
      }
    World(_, _, imports, exports) => {
      for item in imports {
        result.push(binary_kind_id(item.kind))
      }
      for item in exports {
        result.push(binary_kind_id(item.kind))
      }
    }
    _ => ()
  }
  result
}

///|
fn binary_remap(kind : TypeKind, ids : Map[Int32, Int32]) -> TypeKind {
  let remap = fn(id : Int32) { ids.get(id).unwrap_or(id) }
  let remap_member = fn(field : TypeMember) {
    { ..field, ty: remap(field.ty), }
  }
  let item = fn(item : Extern) {
    {
      ..item,
      kind: binary_kind_with_id(item.kind, remap(binary_kind_id(item.kind))),
    }
  }
  let used = fn(value : UsedType) {
    { ..value, interface: remap(value.interface), ty: remap(value.ty), }
  }
  match kind {
    Alias(id) => Alias(remap(id))
    Resource(Some(id)) => Resource(Some(remap(id)))
    Own(id) => Own(remap(id))
    Borrow(id) => Borrow(remap(id))
    List(id) => List(remap(id))
    FixedList(id, length) => FixedList(remap(id), length)
    Map(key, value) => Map(remap(key), remap(value))
    Tuple(types) => Tuple(types.map(remap))
    Option(id) => Option(remap(id))
    Result(ok, error) => Result(ok.map(remap), error.map(remap))
    Future(value) => Future(value.map(remap))
    Stream(value) => Stream(value.map(remap))
    Record(fields) => Record(fields.map(remap_member))
    Variant(cases) =>
      Variant(cases.map(case => { ..case, payload: case.payload.map(remap), }))
    Function(params, result, is_async) =>
      Function(params.map(remap_member), result.map(remap), is_async)
    Interface(name, uses, exports) =>
      Interface(name, uses.map(used), exports.map(item))
    World(name, uses, imports, exports) =>
      World(name, uses.map(used), imports.map(item), exports.map(item))
    other => other
  }
}

///|
// Importing the same instance template twice creates distinct resources. Types
// captured from an outer scope retain their identity. Only types affected by a
// fresh resource, and the containing instance/world, need new arena entries.
fn BinaryGraph::instantiate_type(
  self : BinaryGraph,
  scope : BinaryScope,
  template : Int32,
) -> Int32 raise BinaryFailure {
  let template = self.follow(template)
  let bound : Map[Int32, Bool] = Map([])
  for id in self.bound_resources.get(template).unwrap_or([]) {
    bound[id] = true
  }
  if bound.is_empty() {
    return template
  }
  let ids : Map[Int32, Int32] = Map([])
  let seen : Map[Int32, Bool] = Map([])
  let order : Array[Int32] = []
  let work : Array[(Int32, Bool)] = [(template, false)]
  while work.pop() is Some((id, finish)) {
    self.step()
    if finish {
      order.push(id)
      if id == template ||
        bound.contains(id) ||
        self.owners.get(id).map(owner => owner.0 == template).unwrap_or(false) ||
        binary_children(self.types[id].kind).any(child => ids.contains(child)) {
        ids[id] = self.add(self.types[id].kind, name=self.types[id].name)
      }
      continue
    }
    if seen.contains(id) {
      continue
    }
    seen[id] = true
    work.push((id, true))
    let children = binary_children(self.types[id].kind)
    for i = children.length() - 1; i >= 0; i = i - 1 {
      work.push((children[i], false))
    }
  }
  for old in order {
    self.step()
    guard ids.get(old) is Some(id) else { continue }
    let kind = binary_remap(self.types[old].kind, ids)
    self.types[id] = { ..self.types[id], kind, }
    if self.bound_resources.get(old) is Some(resources) {
      self.bound_resources[id] = resources.map(resource => {
        ids.get(resource).unwrap_or(resource)
      })
    }
    if self.owners.get(old) is Some((owner, name)) {
      self.owners[id] = (ids.get(owner).unwrap_or(owner), name)
    }
    if self.implements_names.get(old) is Some(names) {
      self.implements_names[id] = names
    }
  }
  let result = ids[template]
  for resource in self.bound_resources.get(result).unwrap_or([]) {
    scope.resources.push(resource)
  }
  result
}

///|
fn BinaryGraph::find_owner(
  self : BinaryGraph,
  ty : Int32,
) -> (Int32, String)? raise BinaryFailure {
  let mut ty = ty
  for _ in 0..<self.types.length() {
    self.step()
    if self.owners.get(ty) is Some(owner) {
      return Some(owner)
    }
    match self.types[ty].kind {
      Alias(next) | Resource(Some(next)) => ty = next
      _ => return None
    }
  }
  raise Invalid("cyclic type ownership")
}

///|
fn BinaryGraph::own_or_use(
  self : BinaryGraph,
  scope : BinaryScope,
  name : String,
  referenced : Int32,
  created : Int32,
) -> Unit raise BinaryFailure {
  match self.find_owner(referenced) {
    Some((owner, original_name)) =>
      if owner != scope.owner && self.types[owner].kind is Interface(_, _, _) {
        scope.uses.push({
          name,
          original_name,
          interface: owner,
          ty: created,
          location: self.location,
        })
      }
    None => self.owners[created] = (scope.owner, name)
  }
}
