///|
fn BinaryGraph::runtime_instance(
  self : BinaryGraph,
  scope : BinaryScope,
  instance : @component.Instance,
) -> Unit raise BinaryFailure {
  match instance.expr {
    InlineExports(exports) => {
      let items : Array[Extern] = []
      for exported in exports {
        self.step()
        items.push({
          name: exported.name,
          kind: scope.lookup(exported.sortidx.sort, exported.sortidx.idx),
          location: self.location,
        })
      }
      scope.instances.push(
        self.add(Interface(None, [], ReadOnlyArray::from_array(items))),
      )
    }
    Instantiate(component, arguments) => {
      let template = self.instantiate_type(
        scope,
        binary_index(scope.components, component),
      )
      guard self.types[template].kind is World(_, uses, imports, exports) else {
        raise Invalid("runtime component has no complete world type")
      }
      let actual : Map[String, ItemKind] = Map([])
      for argument in arguments {
        self.step()
        actual[argument.name] = scope.lookup(
          argument.sortidx.sort,
          argument.sortidx.idx,
        )
      }
      let mapping : Map[Int32, Int32] = Map([])
      let work : Array[(ItemKind, ItemKind)] = []
      for imported in imports {
        self.step()
        guard actual.get(imported.name) is Some(value) else {
          raise Invalid("missing runtime component argument")
        }
        work.push((imported.kind, value))
      }
      while work.pop() is Some((expected, supplied)) {
        self.step()
        match (expected, supplied) {
          (Type(expected), Type(supplied)) => {
            mapping[expected] = supplied
            let expected = self.follow(expected)
            let supplied = self.follow(supplied)
            if self.types[expected].kind is Resource(_) {
              let mut a = expected
              let mut b = supplied
              while self.types[a].kind is Resource(Some(next)) {
                self.step()
                a = next
              }
              while self.types[b].kind is Resource(Some(next)) {
                self.step()
                b = next
              }
              mapping[a] = b
            }
          }
          (Instance(expected), Instance(supplied)) => {
            guard self.types[self.follow(expected)].kind
              is Interface(_, _, expected) &&
              self.types[self.follow(supplied)].kind
              is Interface(_, _, supplied) else {
              raise Invalid("runtime argument has no interface contract")
            }
            let members : Map[String, ItemKind] = Map([])
            for item in supplied {
              self.step()
              members[item.name] = item.kind
            }
            for item in expected {
              self.step()
              guard members.get(item.name) is Some(actual) else {
                raise Invalid("runtime argument member is missing")
              }
              work.push((item.kind, actual))
            }
          }
          _ => ()
        }
      }
      let result = self.add(Interface(None, [], []))
      mapping[template] = result
      let pending : Array[(Int32, Bool)] = []
      for item in exports {
        pending.push((binary_kind_id(item.kind), false))
      }
      let visited : Map[Int32, Bool] = Map([])
      let order : Array[Int32] = []
      while pending.pop() is Some((id, finish)) {
        self.step()
        if mapping.contains(id) {
          continue
        }
        if finish {
          order.push(id)
          match self.types[id].kind {
            Resource(None) | Scalar(_) | Module(_) => ()
            _ =>
              mapping[id] = self.add(
                self.types[id].kind,
                name=self.types[id].name,
              )
          }
          continue
        }
        if visited.contains(id) {
          continue
        }
        visited[id] = true
        pending.push((id, true))
        for child in binary_children(self.types[id].kind) {
          self.step()
          pending.push((child, false))
        }
      }
      for old in order {
        self.step()
        guard mapping.get(old) is Some(id) else { continue }
        self.types[id] = {
          ..self.types[id],
          kind: binary_remap(self.types[old].kind, mapping),
        }
        if self.bound_resources.get(old) is Some(resources) {
          self.bound_resources[id] = resources.map(r => {
            mapping.get(r).unwrap_or(r)
          })
        }
        if self.implements_names.get(old) is Some(names) {
          self.implements_names[id] = names
        }
        if self.owners.get(old) is Some((owner, name)) {
          self.owners[id] = (mapping.get(owner).unwrap_or(owner), name)
        }
      }
      let runtime_uses : Array[UsedType] = []
      for used in uses {
        self.step()
        runtime_uses.push(used)
      }
      for item in exports {
        self.step()
        if item.kind is Type(old) {
          let id = mapping.get(old).unwrap_or(old)
          let referenced = match self.types[id].kind {
            Alias(next) | Resource(Some(next)) => next
            _ => id
          }
          if self.find_owner(referenced) is Some((owner, original_name)) &&
            owner != result &&
            self.types[owner].kind is Interface(_, _, _) {
            runtime_uses.push({
              name: item.name,
              original_name,
              interface: owner,
              ty: id,
              location: self.location,
            })
          }
        }
      }
      let remapped = binary_remap(
        Interface(None, ReadOnlyArray::from_array(runtime_uses), exports),
        mapping,
      )
      self.types[result] = { ..self.types[result], kind: remapped, }
      scope.instances.push(result)
    }
  }
}
