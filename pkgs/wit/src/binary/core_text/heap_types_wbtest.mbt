///|
test "heap type text preserves exact nullability including exception and bottom heaps" {
  let source =
    #|(module (type (func
    #| (param (ref exn) (ref null exn) (ref none) (ref null none)
    #|        (ref nofunc) (ref null nofunc) (ref noextern) (ref null noextern)
    #|        (ref noexn) (ref null noexn)))))
  let mod_ = parse(source)
  let params = mod_.func_type_at(0).unwrap().params
  let heaps = [-23, -15, -13, -14, -12]
  for i, heap in heaps {
    assert_eq(params[i * 2].heap(), Some((false, false, heap)))
    assert_eq(params[i * 2 + 1].heap(), Some((true, false, heap)))
  }
}

///|
test "shared composite singleton and recursive placeholders infer shared references" {
  let source =
    #|(module
    #| (type $self (shared (struct (field (ref null $self)))))
    #| (rec
    #|  (type $s (sub (shared (struct (field (ref null $a))))))
    #|  (type $a (shared (array (mut (ref null $s))))))
    #| (type $f (shared (func (param (ref (shared any))) (result (ref null $s))))))
  let mod_ = parse(source)
  assert_true(mod_.types[0].composite.is_shared())
  guard mod_.struct_type_at(0) is Some(st) else {
    fail("expected shared struct")
  }
  guard st.fields[0].storage_type is Val(self_ref) else {
    fail("expected reference")
  }
  assert_eq(self_ref.heap(), Some((true, true, 0)))
  guard mod_.struct_type_at(1) is Some(st) else {
    fail("expected recursive shared struct")
  }
  guard st.fields[0].storage_type is Val(array_ref) else {
    fail("expected reference")
  }
  assert_eq(array_ref.heap(), Some((true, true, 2)))
  let function = mod_.func_type_at(3).unwrap()
  assert_eq(function.params[0].heap(), Some((false, true, -18)))
  assert_eq(function.results[0].heap(), Some((true, true, 1)))
}

///|
test "shared abstract heaps parse in locals and reference immediates" {
  let source =
    #|(module (func (local (ref null (shared any)))
    #|  ref.null (shared any) drop))
  let mod_ = parse(source)
  assert_eq(mod_.codes[0].locals[0].heap(), Some((true, true, -18)))
  guard mod_.codes[0].body[0] is RefNull(reference) else {
    fail("expected ref.null")
  }
  assert_eq(reference.heap(), Some((true, true, -18)))
}

///|
test "unknown and recursively wrapped shared heap spellings fail" {
  for
    source in [
      "(module (type (func (param (ref mystery)))))", "(module (type (func (param (ref (shared 0))))))",
      "(module (type (func (param (ref (shared (shared any)))))))",
    ] {
    try parse(source) catch {
      _ => ()
    } noraise {
      _ => fail("expected invalid heap spelling to fail")
    }
  }
}
