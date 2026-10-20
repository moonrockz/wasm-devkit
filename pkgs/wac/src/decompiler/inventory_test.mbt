///|
test "inventory uses physical preorder and keeps complete public contracts" {
  let source =
    #|(component
    #|  (component
    #|    (component)
    #|    (core module (func (export "run") (param i32) (result i32) local.get 0)))
    #|  (core module)
    #|  (component)
    #|  (export "service" (component 0)))
  let bytes = binary(source)
  let inventory = @decompiler.inventory(bytes).unwrap()
  assert_eq(inventory.entries.length(), 6)
  assert_eq(inventory.entries[1].id, "root/service-component-n0")
  assert_eq(inventory.entries[2].id, "root/service-component-n0/component-n0")
  assert_eq(inventory.entries[3].id, "root/service-component-n0/module-n0")
  assert_eq(inventory.entries[4].id, "root/module-n0")
  assert_eq(inventory.entries[5].id, "root/component-n1")
  assert_eq(inventory.entries[1].export_names.length(), 1)
  let core = inventory.entries[3].core.unwrap()
  assert_eq(core.exports[0].name, "run")
  assert_true(inventory.to_json().stringify().contains("\"i32\""))
  assert_true(inventory.to_text().contains("service-component-n0"))
  for end in 0..<bytes.length() {
    let result = @decompiler.inventory(bytes[:end].to_owned())
    if result is Err(errors) {
      assert_eq(errors.length(), 1)
    }
  }
}

///|
test "inventory never prints WAT and accepts verifier signatures outside the print profile" {
  let bytes = b"\x00asm\x0d\x00\x01\x00\x07\x02\x01\x64"
  let inventory = @decompiler.inventory(bytes).unwrap()
  assert_true(inventory.to_json().stringify().contains("error-context"))
}

///|
test "empty, unknown and core selectors have distinct behavior" {
  let bytes = binary("(component (component (core module)))")
  assert_eq(
    @decompiler.split(bytes, select=Some([])).unwrap().documents.length(),
    0,
  )
  let inventory = @decompiler.inventory(bytes).unwrap()
  assert_true(
    @decompiler.split(bytes, select=Some([inventory.entries[2].id])) is Err(_),
  )
  assert_true(@decompiler.split(bytes, select=Some(["missing"])) is Err(_))
  let selected = @decompiler.split(
    bytes,
    select=Some([inventory.entries[1].id]),
  ).unwrap()
  assert_eq(selected.documents.length(), 1)
  assert_eq(selected.documents[0].id, inventory.entries[1].id)
}

///|
test "arbitrary binary inputs return a complete inventory or one diagnostic" {
  @quickcheck.check(
    fn(input : Array[Byte]) {
      let bytes = Bytes::from_array(input)
      match @decompiler.inventory(bytes) {
        Ok(inventory) => inventory.entries.length() > 0
        Err(errors) => errors.length() == 1
      }
    },
    count=500,
    max_size=128,
    seed=1333,
  )
}
