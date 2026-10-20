///|
/// Raw function value types, including nullability that the retained model can
/// normalize. Strings use the pinned wasm-tools value-type spellings.
pub struct FunctionTextTypes {
  params : ReadOnlyArray[String]
  results : ReadOnlyArray[String]
}

///|
/// Binary choices that the core AST normalizes away. This is not a validation
/// result. All nested collections are immutable snapshots.
pub struct ModuleTextMetadata {
  instruction_callbacks : ReadOnlyArray[ReadOnlyArray[Int32]]
  instruction_offsets : ReadOnlyArray[ReadOnlyArray[Int32]]
  function_elses : ReadOnlyArray[ReadOnlyArray[Int32]]
  element_flags : ReadOnlyArray[Int32]
  explicit_rec_groups : ReadOnlyArray[(Int32, Int32)]
  subtype_encodings : ReadOnlyArray[Bool]
  type_values : ReadOnlyArray[FunctionTextTypes]
  // Absolute flag-byte offsets and original flags, aligned with imports/globals.
  // Non-global imports use offset -1.
  import_global_flags : ReadOnlyArray[(Int32, Int32)]
  global_flags : ReadOnlyArray[(Int32, Int32)]
  import_values : ReadOnlyArray[String]
  explicit_memory_pages : ReadOnlyArray[Bool]
  table_values : ReadOnlyArray[String]
  global_values : ReadOnlyArray[String]
  element_values : ReadOnlyArray[String]
  local_values : ReadOnlyArray[ReadOnlyArray[String]]
  instruction_values : ReadOnlyArray[
    ReadOnlyArray[(Int32, ReadOnlyArray[String])],
  ]
}

///|
fn Parser::take_text(self : Parser) -> Array[String] {
  let values = self.text_values.map(pair => pair.1)
  self.text_values.clear()
  values
}

///|
/// Read printing metadata from a core module. The decompiler validates the
/// original binary before using this metadata. Structured expressions use the
/// retained parser's explicit stacks and physical nesting limit.
pub fn module_text_metadata(
  bytes : Bytes,
) -> ModuleTextMetadata raise ParserError {
  let parser = Parser(bytes)
  if parser.read_bytes(4) != b"\x00asm" {
    raise InvalidMagicNumber
  }
  if parser.read_bytes(4) != b"\x01\x00\x00\x00" {
    raise UnsupportedVersion
  }
  let callbacks : Array[ReadOnlyArray[Int32]] = []
  let offsets : Array[ReadOnlyArray[Int32]] = []
  let elses : Array[ReadOnlyArray[Int32]] = []
  let flags : Array[Int32] = []
  let groups : Array[(Int32, Int32)] = []
  let subtype_encodings : Array[Bool] = []
  let type_values : Array[FunctionTextTypes] = []
  let import_global_flags : Array[(Int32, Int32)] = []
  let global_flags : Array[(Int32, Int32)] = []
  let import_values : Array[String] = []
  let explicit_memory_pages : Array[Bool] = []
  let table_values : Array[String] = []
  let global_values : Array[String] = []
  let element_values : Array[String] = []
  let local_values : Array[ReadOnlyArray[String]] = []
  let instruction_values : Array[ReadOnlyArray[(Int32, ReadOnlyArray[String])]] = []
  while !parser.is_eof() {
    let id = parser.read_byte()
    let size = parser.read_u32()
    let section_start = parser.pos
    let section = Parser(parser.read_bytes(size))
    section.capture_text = true
    match id {
      1 => {
        let count = section.read_u32()
        let mut index = 0
        for _ in 0..<count {
          let explicit = section.peek_byte() == 0x4e
          let members = if explicit {
            ignore(section.read_byte())
            section.read_u32()
          } else {
            1
          }
          for _ in 0..<members {
            let tag = section.peek_byte()
            subtype_encodings.push(tag == 0x4f || tag == 0x50)
            let type_ = section.read_subtype()
            let values = section.take_text()
            guard type_.composite is Func(sig) else {
              raise ParseError(
                "non-function core type is outside the text metadata profile",
              )
            }
            let params = values[:sig.params.length()].to_owned()
            let results = values[sig.params.length():].to_owned()
            type_values.push({
              params: ReadOnlyArray::from_array(params),
              results: ReadOnlyArray::from_array(results),
            })
          }
          if explicit {
            groups.push((index, members))
          }
          index += members
        }
      }
      2 => {
        let count = section.read_u32()
        for _ in 0..<count {
          ignore(section.read_string())
          ignore(section.read_string())
          let mut global_flags = (-1, 0)
          match section.read_byte() {
            0 => ignore(section.read_u32())
            1 => ignore(section.read_table_type())
            2 => {
              explicit_memory_pages.push((section.peek_byte() & 0x08) != 0)
              ignore(section.read_memory_type())
            }
            3 => {
              ignore(section.read_global_type())
              global_flags = (
                section_start + section.pos - 1,
                section.data[section.pos - 1].to_int(),
              )
            }
            4 => {
              ignore(section.read_byte())
              ignore(section.read_u32())
            }
            kind => raise InvalidImportKind(kind)
          }
          import_global_flags.push(global_flags)
          import_values.push(section.take_text().get(0).unwrap_or(""))
        }
      }
      4 => {
        let count = section.read_u32()
        for _ in 0..<count {
          ignore(section.read_table())
          table_values.push(section.take_text().get(0).unwrap_or(""))
        }
      }
      5 => {
        let count = section.read_u32()
        for _ in 0..<count {
          explicit_memory_pages.push((section.peek_byte() & 0x08) != 0)
          ignore(section.read_memory_type())
        }
      }
      6 => {
        let count = section.read_u32()
        for _ in 0..<count {
          ignore(section.read_global_type())
          global_flags.push(
            (
              section_start + section.pos - 1,
              section.data[section.pos - 1].to_int(),
            ),
          )
          ignore(section.read_expr())
          global_values.push(section.take_text().get(0).unwrap_or(""))
        }
      }
      9 => {
        let count = section.read_u32()
        for _ in 0..<count {
          let flag = section.read_u32()
          flags.push(flag)
          ignore(section.read_elem_segment(flag))
          element_values.push(section.take_text().get(0).unwrap_or("funcref"))
        }
      }
      10 => {
        section.has_data_count = true
        let count = section.read_u32()
        for _ in 0..<count {
          let code = Parser(section.read_bytes(section.read_u32()))
          code.capture_text = true
          code.has_data_count = true
          let locals = code.read_u32()
          let local_types : Array[String] = []
          for _ in 0..<locals {
            let n = code.read_u32()
            if n < 0 || n > 1000000 - local_types.length() {
              raise TooManyLocals
            }
            ignore(code.read_value_type())
            let text = code.take_text()[0]
            for _ in 0..<n {
              local_types.push(text)
            }
          }
          let labels = []
          let positions = []
          ignore(
            code.read_expr(else_labels=labels, instruction_offsets=positions),
          )
          let values : Array[(Int32, ReadOnlyArray[String])] = []
          let mut at = 0
          for ordinal, start in positions {
            let end = positions.get(ordinal + 1).unwrap_or(code.data.length())
            let spellings = []
            while at < code.text_values.length() && code.text_values[at].0 < end {
              if code.text_values[at].0 > start {
                spellings.push(code.text_values[at].1)
              }
              at += 1
            }
            if !spellings.is_empty() {
              values.push((ordinal, ReadOnlyArray::from_array(spellings)))
            }
          }
          let callback_offsets = positions.map(start => {
            let mut at = start
            if code.data[start] == 0xfc || code.data[start] == 0xfd {
              at += 1
              while code.data[at] >= 0x80 {
                at += 1
              }
            }
            at
          })
          callbacks.push(ReadOnlyArray::from_array(callback_offsets))
          offsets.push(ReadOnlyArray::from_array(positions))
          elses.push(ReadOnlyArray::from_array(labels))
          local_values.push(ReadOnlyArray::from_array(local_types))
          instruction_values.push(ReadOnlyArray::from_array(values))
        }
      }
      _ => ()
    }
  }
  {
    instruction_callbacks: ReadOnlyArray::from_array(callbacks),
    instruction_offsets: ReadOnlyArray::from_array(offsets),
    function_elses: ReadOnlyArray::from_array(elses),
    element_flags: ReadOnlyArray::from_array(flags),
    explicit_rec_groups: ReadOnlyArray::from_array(groups),
    subtype_encodings: ReadOnlyArray::from_array(subtype_encodings),
    type_values: ReadOnlyArray::from_array(type_values),
    import_global_flags: ReadOnlyArray::from_array(import_global_flags),
    global_flags: ReadOnlyArray::from_array(global_flags),
    import_values: ReadOnlyArray::from_array(import_values),
    explicit_memory_pages: ReadOnlyArray::from_array(explicit_memory_pages),
    table_values: ReadOnlyArray::from_array(table_values),
    global_values: ReadOnlyArray::from_array(global_values),
    element_values: ReadOnlyArray::from_array(element_values),
    local_values: ReadOnlyArray::from_array(local_values),
    instruction_values: ReadOnlyArray::from_array(instruction_values),
  }
}
