///|
test "fragment relocation counts concrete and type scopes but not runtime instances" {
  let source =
    #|(component
    #|  (alias outer 1 2 (type))
    #|  (type (component (alias outer 2 3 (type))))
    #|  (component (alias outer 1 0 (type)))
    #|  (instance (export "t" (type 0))))
  let refs = outer_references(source)
  assert_eq(refs.length(), 2)
  assert_eq(refs[0].distance, 1)
  assert_eq(refs[1].distance, 1)
  let relocated = relocate_outer_references(source, [
    { distance: 1, sort: 3, index: 2, name: "$first", },
    { distance: 1, sort: 3, index: 3, name: "$second", },
  ])
  assert_true(relocated.contains("alias outer 1 $first"))
  assert_true(relocated.contains("alias outer 2 $second"))
  assert_true(relocated.contains("alias outer 1 0"))
}
