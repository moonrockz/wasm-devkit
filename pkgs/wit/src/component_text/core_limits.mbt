///|
fn parse_core_unsigned(
  expr : SExpr,
  wide : Bool,
) -> UInt64 raise ComponentTextError {
  guard expr is Atom(atom) else {
    raise Unsupported("core limit must be an unsigned integer")
  }
  let mut start = if atom.has_prefix("+") { 1 } else { 0 }
  let radix = if start + 1 < atom.length() &&
    atom.code_unit_at(start) == 48 &&
    atom.code_unit_at(start + 1) == 120 {
    start += 2
    16UL
  } else {
    10UL
  }
  let bound = if wide { 18446744073709551615UL } else { 4294967295UL }
  let mut value = 0UL
  let mut previous = false
  for i in start..<atom.length() {
    let c = atom.code_unit_at(i).to_int()
    if c == 95 {
      if !previous {
        raise Unsupported("invalid core limit separator")
      }
      previous = false
      continue
    }
    let digit = if c >= 48 && c <= 57 {
      c - 48
    } else if c >= 65 && c <= 70 {
      c - 65 + 10
    } else if c >= 97 && c <= 102 {
      c - 97 + 10
    } else {
      raise Unsupported("invalid core limit digit")
    }
    let digit = digit.to_uint64()
    if digit >= radix || value > (bound - digit) / radix {
      raise Unsupported("core limit exceeds its unsigned width")
    }
    value = value * radix + digit
    previous = true
  }
  if !previous {
    raise Unsupported("missing core limit digit")
  }
  value
}

///|
fn ByteBuf::push_core_unsigned(self : ByteBuf, input : UInt64) -> Unit {
  let mut value = input
  while value >= 128UL {
    self.push_u8((value & 127UL).to_int() | 128)
    value = value >> 7
  }
  self.push_u8(value.to_int())
}

///|
fn core_unique_name(
  state : ComponentBuildState,
  bindings : Array[NamedBinding],
  name : String?,
  start : Int32,
) -> Unit raise ComponentTextError {
  if name is Some(name) {
    for i in start..<bindings.length() {
      if state.core_name_work <= 0 {
        raise Unsupported(
          "core name resolution exceeds the compilation work limit",
        )
      }
      state.core_name_work -= 1
      if bindings[i].name == name {
        raise Unsupported("duplicate core type identifier")
      }
    }
  }
}
