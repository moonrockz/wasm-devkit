///|
fn Reader::skip(self : Reader, count : Int32) -> Unit raise Failure {
  if count < 0 || count > self.end - self.position {
    self.fail(Malformed, "truncated core module field")
  }
  self.position += count
}

///|
fn Reader::signed(self : Reader, bits : Int32) -> Int64 raise Failure {
  let mut result = 0L
  let count = (bits + 6) / 7
  for i in 0..<count {
    let byte = self.byte()
    let remaining = bits - i * 7
    if remaining < 7 {
      let mask = 127 ^ ((1 << (remaining - 1)) - 1)
      if (byte & mask) != 0 && (byte & mask) != mask {
        self.fail(Malformed, "core signed LEB exceeds its width")
      }
    }
    result = result | ((byte & 127).to_int64() << (i * 7))
    if byte < 128 {
      let shift = (i + 1) * 7
      if (byte & 64) != 0 && shift < 64 {
        result = result | (-1L << shift)
      }
      return result
    }
  }
  self.fail(Malformed, "unterminated core signed LEB")
  0L
}

///|
/// Frame supported expressions before the retained instruction parser runs.
/// Explicit control frames bound nesting and record local-state copy work.
fn Reader::expression(self : Reader, constant : Bool) -> Int32 raise Failure {
  let controls : Array[Int32] = []
  let mut count = 0
  while true {
    match self.byte() {
      0x0b => {
        if controls.is_empty() {
          return count
        }
        controls.pop() |> ignore
      }
      0x02 | 0x03 | 0x04 as opcode if !constant => {
        if controls.length() >= 256 {
          self.fail(Unsupported, "core control nesting exceeds 256")
        }
        let first = self.byte()
        if first == 0x40 {
          ()
        } else if (first >= 0x63 && first <= 0x75) ||
          (first >= 0x7b && first <= 0x7f) {
          self.position -= 1
          ignore(self.value())
        } else {
          self.position -= 1
          if self.signed(33) < 0L {
            self.fail(Malformed, "invalid core block type")
          }
        }
        controls.push(opcode)
        count += 1
      }
      0x05 if !constant => {
        if controls.last() != Some(0x04) {
          self.fail(Malformed, "unexpected core else")
        }
        controls[controls.length() - 1] = 0x05
      }
      0x41 => ignore(self.signed(32))
      0x42 => ignore(self.signed(64))
      0x43 => self.skip(4)
      0x44 => self.skip(8)
      0x23 | 0xd2 => ignore(self.index())
      0xd0 => {
        // Heap types use the same abstract reference grammar as value types.
        // A concrete heap index is deliberately unsupported here.
        let heap = self.byte()
        if heap >= 0x80 {
          self.position -= 1
          let index = self.signed(33)
          if index >= 0L {
            self.fail(Unsupported, "concrete core heap initializer")
          }
          self.fail(Malformed, "invalid abstract heap type encoding")
        }
        if heap < 0x68 || heap > 0x75 {
          self.fail(Unsupported, "concrete or extended core heap initializer")
        }
      }
      0x6a..<=0x6c | 0x7c..<=0x7e => ()
      0xfd => {
        if self.index() != 12 {
          self.fail(
            Unsupported,
            "SIMD instructions other than v128.const are outside the module profile",
          )
        }
        self.skip(16)
      }
      opcode if !constant =>
        match opcode {
          0x00 | 0x01 | 0x0f | 0x1a | 0x1b | 0x45..<=0xc4 | 0xd1 | 0xd3 => ()
          0x0c | 0x0d | 0x10 | 0x12 | 0x20..<=0x22 | 0x24 | 0x25 | 0x26 =>
            ignore(self.index())
          0x11 | 0x13 => {
            ignore(self.index())
            ignore(self.index())
          }
          0x0e => {
            let count = self.count()
            for _ in 0..<count {
              ignore(self.index())
            }
            ignore(self.index())
          }
          0x1c => {
            let count = self.count()
            for _ in 0..<count {
              ignore(self.value())
            }
          }
          0x28..<=0x3e => {
            let flags = self.index()
            if flags >= 128 {
              self.fail(Malformed, "invalid core memory argument flags")
            }
            if (flags & 64) != 0 {
              ignore(self.index())
            }
            ignore(self.unsigned(64))
          }
          0x3f | 0x40 => ignore(self.index())
          0xfc =>
            match self.index() {
              0..<=7 => ()
              8 | 10 | 12 | 14 => {
                ignore(self.index())
                ignore(self.index())
              }
              9 | 11 | 13 | 15..<=17 => ignore(self.index())
              _ =>
                self.fail(
                  Unsupported,
                  "extended core instruction is outside the module profile",
                )
            }
          _ =>
            self.fail(
              Unsupported,
              "proposal core instructions are outside the module profile",
            )
        }
      _ =>
        self.fail(
          Unsupported,
          "core initializer instruction is outside the module profile",
        )
    }
  } nobreak {
    count
  }
}

///|
fn Reader::module_external(
  self : Reader,
  raw : RawExternal,
  functions : Array[Function],
) -> External raise Failure {
  match raw {
    Value(value) => {
      match value {
        Global(_, _, true) =>
          self.fail(
            Unsupported,
            "shared globals exceed the retained core module parser",
          )
        Memory(min, max, _, _, _) | Table(_, min, max, _, _) =>
          if min > 9223372036854775807UL ||
            (max is Some(max) && max > 9223372036854775807UL) {
            self.fail(
              Unsupported,
              "unsigned core limits exceed the retained core module validator",
            )
          }
        _ => ()
      }
      value
    }
    Func(index) | Tag(index) => {
      guard functions.get(index) is Some(function) else {
        self.fail(Invalid, "core function type index is out of bounds")
        return Func({ params: [], results: [], })
      }
      if raw is Tag(_) {
        if !function.results.is_empty() {
          self.fail(Invalid, "core tag cannot return values")
        }
        Tag(function)
      } else {
        Func(function)
      }
    }
  }
}

///|
/// Read the immutable contract of a concrete core module and bound instruction
/// parsing. This is framing evidence only: callers must validate the original
/// module's metadata and instruction semantics before exposing a package.
pub fn inspect_module(bytes : Bytes) -> Result[ModuleMetadata, Diagnostic] {
  let reader : Reader = { bytes, position: 0, end: bytes.length(), }
  try {
    if bytes.length() < 8 ||
      bytes[0:8] != b"\x00asm\x01\x00\x00\x00".exact_view() {
      reader.fail(Malformed, "invalid core module header")
    }
    reader.position = 8
    let functions : Array[Function] = []
    let slots : Array[Array[External]] = [[], [], [], [], []]
    let imports : Array[Import] = []
    let exports : Array[Export] = []
    let mut last = 0
    let mut function_count = 0
    let mut code_count = 0
    let mut expanded_locals = 0UL
    let mut control_local_work = 0UL
    while reader.position < reader.end {
      let section = reader.byte()
      let length = reader.count()
      let end = reader.position + length
      let payload : Reader = { bytes, position: reader.position, end, }
      let rank = match section {
        0 => 0
        1..<=5 => section
        13 => 6
        6..<=9 => section + 1
        12 => 11
        10 => 12
        11 => 13
        _ => -1
      }
      if rank < 0 || (rank != 0 && rank <= last) {
        payload.fail(Malformed, "invalid core section order")
      }
      if rank != 0 {
        last = rank
      }
      match section {
        0 => {
          ignore(payload.name())
          payload.position = end
        }
        1 => {
          let count = payload.count()
          for _ in 0..<count {
            let opcode = payload.byte()
            if opcode == 0x4e {
              let members = payload.count()
              for _ in 0..<members {
                functions.push(payload.module_function(payload.byte()))
              }
            } else {
              functions.push(payload.module_function(opcode))
            }
          }
        }
        2 => {
          let count = payload.count()
          let names : Map[(String, String), Bool] = Map([])
          for _ in 0..<count {
            let module_name = payload.name()
            let name = payload.name()
            if names.contains((module_name, name)) {
              payload.fail(Invalid, "duplicate core module import pair")
            }
            names[(module_name, name)] = true
            let kind = payload.byte()
            let external = payload.module_external(
              payload.external(kind=Some(kind)),
              functions,
            )
            slots[kind].push(external)
            imports.push({ module_name, name, kind: external, })
          }
        }
        3 => {
          function_count = payload.count()
          for _ in 0..<function_count {
            slots[0].push(
              payload.module_external(Func(payload.index()), functions),
            )
          }
        }
        4 | 5 | 6 | 13 => {
          let kind = match section {
            4 => 1
            5 => 2
            6 => 3
            _ => 4
          }
          let count = payload.count()
          for _ in 0..<count {
            let initialized = section == 4 &&
              payload.position < end &&
              bytes[payload.position] == b'\x40'
            if initialized {
              ignore(payload.byte())
              if payload.byte() != 0 {
                payload.fail(Malformed, "invalid table initializer prefix")
              }
            }
            slots[kind].push(
              payload.module_external(
                payload.external(kind=Some(kind)),
                functions,
              ),
            )
            if section == 6 || initialized {
              ignore(payload.expression(true))
            }
          }
        }
        7 => {
          let count = payload.count()
          let names : Map[String, Bool] = Map([])
          for _ in 0..<count {
            let name = payload.name()
            if names.contains(name) {
              payload.fail(Invalid, "duplicate core export name")
            }
            names[name] = true
            let kind = payload.byte()
            let index = payload.index()
            guard slots.get(kind) is Some(table) &&
              table.get(index) is Some(kind) else {
              payload.fail(Invalid, "core export index is out of bounds")
              continue
            }
            exports.push({ name, kind, })
          }
        }
        8 | 12 => ignore(payload.index())
        9 => {
          let count = payload.count()
          for _ in 0..<count {
            let flags = payload.index()
            if flags > 7 {
              payload.fail(Malformed, "invalid core element flags")
            }
            if flags == 2 || flags == 6 {
              ignore(payload.index())
            }
            if (flags & 1) == 0 {
              ignore(payload.expression(true))
            }
            if flags != 0 && flags != 4 {
              if flags < 4 {
                if payload.byte() != 0 {
                  payload.fail(Malformed, "invalid core element kind")
                }
              } else {
                ignore(payload.value())
              }
            }
            let count = payload.count()
            for _ in 0..<count {
              if flags < 4 {
                ignore(payload.index())
              } else {
                ignore(payload.expression(true))
              }
            }
          }
        }
        10 => {
          code_count = payload.count()
          for body_index in 0..<code_count {
            let length = payload.count()
            let body : Reader = {
              bytes,
              position: payload.position,
              end: payload.position + length,
            }
            let mut body_locals = 0UL
            let count = body.count()
            for _ in 0..<count {
              let count = body.unsigned(32)
              expanded_locals += count
              body_locals += count
              if expanded_locals > 1000000UL {
                body.fail(Unsupported, "core local expansion exceeds 1000000")
              }
              ignore(body.value())
            }
            let controls = body.expression(false).to_uint64()
            let params = match
              slots[0].get(slots[0].length() - code_count + body_index) {
              Some(Func(function)) => function.params.length().to_uint64()
              _ => 0UL
            }
            control_local_work += (body_locals + params) * (controls + 1UL)
            if control_local_work > 1000000UL {
              body.fail(
                Unsupported,
                "core local-state validation work exceeds 1000000",
              )
            }
            if body.position != body.end {
              body.fail(Malformed, "trailing core function bytes")
            }
            payload.position = body.end
          }
        }
        11 => {
          let count = payload.count()
          for _ in 0..<count {
            let flags = payload.index()
            if flags > 2 {
              payload.fail(Malformed, "invalid core data flags")
            }
            if flags == 2 {
              ignore(payload.index())
            }
            if flags != 1 {
              ignore(payload.expression(true))
            }
            let count = payload.count()
            payload.skip(count)
          }
        }
        _ => ()
      }
      if payload.position != end {
        payload.fail(Malformed, "trailing core section bytes")
      }
      reader.position = end
    }
    if code_count != function_count {
      reader.fail(Invalid, "core function and code counts differ")
    }
    // Instruction stack effects are bounded by the largest signature. Type
    // canonicalization compares groups pairwise; each control frame snapshots
    // the current function's local-init state. Charge each source of work.
    let mut max_arity = 1
    for function in functions {
      max_arity = max_arity.max(
        function.params.length() + function.results.length(),
      )
    }
    let arity = max_arity.to_uint64()
    let types = functions.length().to_uint64()
    if types * types > 1000000UL / arity {
      reader.fail(
        Unsupported,
        "core type canonicalization work exceeds 1000000",
      )
    }
    let validation_work = bytes.length().to_uint64() * arity +
      types * types * arity +
      control_local_work
    if validation_work > 1000000UL {
      reader.fail(
        Unsupported,
        "core module validation work estimate exceeds 1000000",
      )
    }
    Ok({
      contract: {
        imports: ReadOnlyArray::from_array(imports),
        exports: ReadOnlyArray::from_array(exports),
      },
      validation_work: validation_work.to_int(),
    })
  } catch {
    Failure(error) => Err(error)
  }
}

///|
fn Reader::module_function(
  self : Reader,
  opcode : Int32,
) -> Function raise Failure {
  let mut opcode = opcode
  if opcode == 0x4f || opcode == 0x50 {
    if self.index() != 0 {
      self.fail(Unsupported, "core supertypes are outside the module profile")
    }
    opcode = self.byte()
  }
  if opcode != 0x60 {
    self.fail(Unsupported, "core GC types are outside the module profile")
  }
  self.function_body()
}

///|
/// Immutable framing evidence and the conservative retained-validator work
/// estimate. This does not certify instruction semantics.
pub(all) struct ModuleMetadata {
  contract : Module
  validation_work : Int32
}

///|
pub fn decode_module(bytes : Bytes) -> Result[Module, Diagnostic] {
  match inspect_module(bytes) {
    Ok(metadata) => Ok(metadata.contract)
    Err(error) => Err(error)
  }
}
