///|
priv enum ModuleWork {
  Component(Bytes)
  Module(Bytes)
}

///|
fn physical_modules(bytes : Bytes) -> Array[Bytes] raise {
  let modules = []
  let work = [ModuleWork::Component(bytes)]
  while work.pop() is Some(task) {
    match task {
      Module(bytes) => modules.push(bytes)
      Component(bytes) => {
        let sections = @component.parse_component_binary(bytes).sections
        for i = sections.length() - 1; i >= 0; i = i - 1 {
          match sections[i].id {
            1 => work.push(Module(sections[i].payload))
            4 => work.push(Component(sections[i].payload))
            _ => ()
          }
        }
      }
    }
  }
  modules
}

///|
fn same_leaf_module(left : Bytes, right : Bytes) -> Unit raise {
  let left = @core_parser.parse_module(left)
  let right = @core_parser.parse_module(right)
  assert_eq(right.types, left.types)
  assert_eq(right.imports, left.imports)
  assert_eq(right.funcs, left.funcs)
  assert_eq(right.exports, left.exports)
  assert_eq(right.codes.length(), left.codes.length())
  for i, code in left.codes {
    assert_eq(right.codes[i].locals, code.locals)
    // This witness has flat bodies. Deep laws use explicit instruction stacks
    // in the WIT printer tests.
    assert_eq(right.codes[i].body, code.body)
  }
}

///|
test "law: single compatibility full split and selected modules retain the same bodies" {
  let source =
    #|(component
    #|  (component (core module
    #|    (func (export "id") (param i32) (result i32) local.get 0)))
    #|  (component (core module
    #|    (func (export "answer") (result i64) i64.const 42))))
  let bytes = binary(source)
  let original = physical_modules(bytes)
  assert_eq(original.length(), 2)
  for compatibility in [None, Some(@wat.Compatibility::WasmTools)] {
    let document = @wat.print_binary(bytes, compatibility~).unwrap().root().text
    let readback = physical_modules(binary(document))
    assert_eq(readback.length(), original.length())
    for i, module_ in original {
      same_leaf_module(module_, readback[i])
    }
  }
  let full = @decompiler.split(bytes).unwrap()
  let selected_id = full.inventory.entries[1].id
  let selected = @decompiler.split(bytes, select=Some([selected_id])).unwrap()
  assert_eq(selected.inventory.to_json(), full.inventory.to_json())
  assert_eq(selected.documents.length(), 1)
  assert_eq(selected.documents[0].id, selected_id)
  let mut full_leaf = None
  for document in full.documents {
    if document.id == selected_id {
      full_leaf = Some(document.text)
    }
  }
  let full_modules = physical_modules(binary(full_leaf.unwrap()))
  let selected_modules = physical_modules(binary(selected.documents[0].text))
  assert_eq(full_modules.length(), 1)
  assert_eq(selected_modules.length(), 1)
  same_leaf_module(original[0], full_modules[0])
  same_leaf_module(original[0], selected_modules[0])
  let empty = @decompiler.split(bytes, select=Some([])).unwrap()
  assert_eq(empty.documents.length(), 0)
  assert_eq(empty.inventory.to_json(), full.inventory.to_json())
}
