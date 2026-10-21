///|
fn Reader::field_type(
  self : Reader,
  compatibility : Bool,
) -> String raise PrintFailure {
  let storage = if self.position < self.bytes.length() &&
    self.bytes[self.position] == b'\x78' {
    self.position += 1
    "i8"
  } else if self.position < self.bytes.length() &&
    self.bytes[self.position] == b'\x77' {
    self.position += 1
    "i16"
  } else {
    self.value_type(compatibility~)
  }
  if self.byte() == 1 {
    "(mut " + storage + ")"
  } else {
    storage
  }
}

///|
fn Reader::heap_subtype(
  self : Reader,
  opcode : Int32,
  scope : Scope,
  index : Int32,
) -> String raise PrintFailure {
  let mut opcode = opcode
  if opcode == 0 {
    opcode = self.byte()
  }
  let mut final_ = true
  let supers : Array[Int32] = []
  let explicit = opcode == 0x4f || opcode == 0x50
  if explicit {
    final_ = opcode == 0x4f
    let count = self.u32()
    for _ in 0..<count {
      supers.push(self.u32())
    }
    opcode = self.byte()
  }
  let shared = opcode == 0x65
  if shared {
    opcode = self.byte()
  }
  let body = match opcode {
    0x60 => {
      let signature = self.func_type(compatibility=scope.compatibility)
      scope.core_signatures[index] = signature[5:signature.length() - 1].to_owned()
      signature
    }
    0x5f => {
      let out = StringBuilder()
      out.write_string("(struct")
      let count = self.u32()
      for _ in 0..<count {
        out.write_string(
          " (field " + self.field_type(scope.compatibility) + ")",
        )
      }
      out.write_char(')')
      out.to_string()
    }
    0x5e => "(array " + self.field_type(scope.compatibility) + ")"
    _ => unsupported("unsupported composite core type")
  }
  let body = if shared { "(shared " + body + ")" } else { body }
  if final_ && supers.is_empty() {
    body
  } else {
    let out = StringBuilder()
    out.write_string("(sub")
    if final_ {
      out.write_string(" final")
    }
    for supertype in supers {
      out.write_string(" " + scope.reference(0x110, supertype))
    }
    out.write_string(" " + body + ")")
    out.to_string()
  }
}

///|
// Groups and their fields are flat binary vectors. Recursive references are
// printed as indices, so even mutually recursive groups use no recursive walk.
fn Reader::heap_group_text(
  self : Reader,
  opcode : Int32,
  depth : Int32,
  index : Int32,
  core : Bool,
  scope : Scope,
) -> (String, Int32) raise PrintFailure {
  let explicit = opcode == 0x4e
  let count = if explicit { self.u32() } else { 1 }
  let pad = indent(depth)
  let out = StringBuilder()
  if explicit {
    out.write_string(pad + (if core { "(core rec\n" } else { "(rec\n" }))
  }
  for i in 0..<count {
    let opcode = if explicit { self.byte() } else { opcode }
    let body = self.heap_subtype(opcode, scope, index + i)
    let label = scope.declaration(0x110, index + i)
    if explicit {
      out.write_string(pad + "  (type " + label + " " + body + ")\n")
    } else {
      out.write_string(
        pad +
        (if core { "(core type " } else { "(type " }) +
        label +
        " " +
        body +
        ")\n",
      )
    }
  }
  if explicit {
    out.write_string(pad + ")\n")
  }
  (out.to_string(), count)
}
