// WABT 1.0.42 binary-reader and binary-reader-ir conventions.
// Copyright 2016 WebAssembly Community Group participants.
// Adapted under Apache-2.0; see LICENSE and THIRD_PARTY_NOTICES.md.

///|
fn MetadataReader::finish(self : MetadataReader) -> Unit raise MetadataError {
  if self.position != self.bytes.length() {
    raise MetadataError(
      self.base + self.position,
      "unfinished custom subsection",
    )
  }
}

///|
fn MetadataReader::signed32(self : MetadataReader) -> Unit raise MetadataError {
  for i in 0..<5 {
    let byte = self.byte()
    if i == 4 && byte >= 8 && byte < 120 {
      raise MetadataError(self.base + self.position, "invalid signed addend")
    }
    if byte < 128 {
      return
    }
  }
  raise MetadataError(self.base + self.position, "invalid signed addend")
}

///|
fn Names::symbol(
  self : Names,
  kind : Int32,
  index : Int32,
  name : String,
  available : Map[Int32, Int32],
  prefer_existing~ : Bool = false,
) -> Unit raise MetadataError {
  if name.is_empty() {
    return
  }
  if index < 0 || index >= available.get(kind).unwrap_or(0) {
    raise MetadataError(0, "invalid linking symbol index")
  }
  if prefer_existing && self.entries.contains((kind, 0, index)) {
    return
  }
  let used = match self.used_names.get((kind, 0)) {
    Some(used) => used
    None => {
      let used = Map([])
      self.used_names[(kind, 0)] = used
      used
    }
  }
  self.insert(kind, 0, index, name, used)
}

///|
fn wabt_available(mod_ : @types.Module, after : Int32) -> Map[Int32, Int32] {
  let (tables, memories, globals, tags) = imported_counts(mod_)
  let imported = imported_function_count(mod_)
  let imports_read = after != 0 && after != 1
  let functions_read = imports_read && after != 2
  Map([
    (
      1,
      (if imports_read { imported } else { 0 }) +
      (if functions_read { mod_.funcs.length() } else { 0 }),
    ),
    (
      5,
      (if imports_read { tables } else { 0 }) +
      (if [4, 5, 13, 6, 7, 8, 9, 10, 11].contains(after) {
        mod_.tables.length()
      } else {
        0
      }),
    ),
    (
      6,
      (if imports_read { memories } else { 0 }) +
      (if [5, 13, 6, 7, 8, 9, 10, 11].contains(after) {
        mod_.memories.length()
      } else {
        0
      }),
    ),
    (
      7,
      (if imports_read { globals } else { 0 }) +
      (if [6, 7, 8, 9, 10, 11].contains(after) {
        mod_.globals.length()
      } else {
        0
      }),
    ),
    (9, if after == 11 { mod_.datas.length() } else { 0 }),
    (
      11,
      (if imports_read { tags } else { 0 }) +
      (if [13, 6, 7, 8, 9, 10, 11].contains(after) {
        mod_.tags.length()
      } else {
        0
      }),
    ),
  ])
}

///|
fn Names::linking(
  self : Names,
  reader : MetadataReader,
  available : Map[Int32, Int32],
) -> Unit raise MetadataError {
  if reader.uint() != 2 {
    raise MetadataError(
      reader.base + reader.position,
      "invalid linking metadata version",
    )
  }
  while reader.position < reader.bytes.length() {
    let kind = reader.uint()
    let sub = reader.subreader()
    match kind {
      8 => {
        let count = sub.uint().reinterpret_as_uint()
        for remaining = count; remaining > 0U; remaining = remaining - 1U {
          let sort = sub.uint()
          let flags = sub.uint()
          match sort {
            0 | 2 | 4 | 5 => {
              let index = sub.uint()
              let name = if (flags & 16) == 0 || (flags & 64) != 0 {
                sub.string()
              } else {
                ""
              }
              let key = match sort {
                0 => 1
                2 => 7
                4 => 11
                _ => 5
              }
              self.symbol(
                key,
                index,
                name,
                available,
                prefer_existing=sort == 0,
              )
            }
            1 => {
              let name = sub.string()
              if (flags & 16) == 0 {
                let segment = sub.uint()
                let offset = sub.uint()
                ignore(sub.uint())
                if offset == 0 {
                  self.symbol(9, segment, name, available)
                }
              }
            }
            3 => ignore(sub.uint())
            _ => ()
          }
        }
      }
      5 => {
        let count = sub.uint().reinterpret_as_uint()
        for remaining = count; remaining > 0U; remaining = remaining - 1U {
          ignore(sub.string())
          let alignment = sub.uint().reinterpret_as_uint()
          if alignment >= 32U {
            raise MetadataError(
              sub.base + sub.position,
              "invalid segment alignment",
            )
          }
          ignore(sub.uint())
        }
      }
      6 => {
        let count = sub.uint().reinterpret_as_uint()
        for remaining = count; remaining > 0U; remaining = remaining - 1U {
          ignore(sub.uint())
          ignore(sub.uint())
        }
      }
      7 => {
        let count = sub.uint().reinterpret_as_uint()
        for remaining = count; remaining > 0U; remaining = remaining - 1U {
          ignore(sub.string())
          ignore(sub.uint())
          let entries = sub.uint().reinterpret_as_uint()
          for remaining = entries; remaining > 0U; remaining = remaining - 1U {
            ignore(sub.uint())
            ignore(sub.uint())
          }
        }
      }
      _ => sub.position = sub.bytes.length()
    }
    sub.finish()
  }
}

///|
fn wabt_dylink(
  reader : MetadataReader,
  legacy : Bool,
) -> Unit raise MetadataError {
  if legacy {
    for _ in 0..<4 {
      ignore(reader.uint())
    }
    let count = reader.uint().reinterpret_as_uint()
    for remaining = count; remaining > 0U; remaining = remaining - 1U {
      ignore(reader.string())
    }
    return
  }
  while reader.position < reader.bytes.length() {
    let kind = reader.uint()
    let sub = reader.subreader()
    match kind {
      1 =>
        for _ in 0..<4 {
          ignore(sub.uint())
        }
      2 | 3 | 4 => {
        let count = sub.uint().reinterpret_as_uint()
        for remaining = count; remaining > 0U; remaining = remaining - 1U {
          ignore(sub.string())
          if kind == 4 {
            ignore(sub.string())
          }
          if kind != 2 {
            ignore(sub.uint())
          }
        }
      }
      _ => sub.position = sub.bytes.length()
    }
    sub.finish()
  }
}

///|
priv struct WabtCodeMetadata {
  func : Int32
  name : String
  values : Array[(Int32, Bytes)]
}

///|
fn wabt_code_metadata(
  reader : MetadataReader,
  name : String,
  available : Int32,
  imported : Int32,
) -> Array[WabtCodeMetadata] raise MetadataError {
  let entries : Array[WabtCodeMetadata] = []
  let count = reader.uint().reinterpret_as_uint()
  let mut previous = -1
  for remaining = count; remaining > 0U; remaining = remaining - 1U {
    let func = reader.uint()
    if func < imported || func >= available || func <= previous {
      raise MetadataError(
        reader.base + reader.position,
        "invalid code-metadata function index",
      )
    }
    previous = func
    let count = reader.uint().reinterpret_as_uint()
    let values = []
    let mut previous = -1
    for remaining = count; remaining > 0U; remaining = remaining - 1U {
      let offset = reader.uint()
      if offset < 0 || offset <= previous {
        raise MetadataError(
          reader.base + reader.position,
          "invalid code-metadata instruction offset",
        )
      }
      previous = offset
      values.push((offset, reader.slice(reader.uint())))
    }
    entries.push({ func, name, values, })
  }
  entries
}

///|
fn validate_wabt_custom(
  mod_ : @types.Module,
  names : Names,
  sections : Array[CustomSection],
  metadata : @core_parser.ModuleTextMetadata,
) -> Unit raise WatPrintError {
  let queue : Array[WabtCodeMetadata] = []
  let imported = imported_function_count(mod_)
  for section in sections {
    let reader = metadata_reader(section.data, base=section.offset)
    try {
      match section.name {
        "name" => {
          names.read(section.data)
          reader.position = reader.bytes.length()
        }
        "linking" => names.linking(reader, wabt_available(mod_, section.after))
        "dylink.0" => wabt_dylink(reader, false)
        "dylink" => wabt_dylink(reader, true)
        "target_features" => {
          let count = reader.uint().reinterpret_as_uint()
          for remaining = count; remaining > 0U; remaining = remaining - 1U {
            ignore(reader.byte())
            ignore(reader.string())
          }
        }
        name if name.has_prefix("reloc.") => {
          ignore(reader.uint())
          let count = reader.uint().reinterpret_as_uint()
          for remaining = count; remaining > 0U; remaining = remaining - 1U {
            let kind = reader.uint()
            ignore(reader.uint())
            ignore(reader.uint())
            if kind < 0 || kind > 26 {
              raise MetadataError(
                reader.base + reader.position,
                "unknown relocation type",
              )
            }
            if [3, 4, 5, 8, 9, 11, 14, 15, 16, 17, 21, 22, 23, 25].contains(
                kind,
              ) {
              reader.signed32()
            }
          }
        }
        name if name.has_prefix("metadata.code.") => {
          let entries = wabt_code_metadata(
            reader,
            name,
            wabt_available(mod_, section.after).get(1).unwrap_or(0),
            imported,
          )
          if section.after != 10 && section.after != 11 {
            queue.append(entries)
          }
        }
        _ => reader.position = reader.bytes.length()
      }
      reader.finish()
    } catch {
      MetadataError(_, message) =>
        raise BinaryMetadata("WABT 1.0.42 rejected custom metadata: " + message)
    }
  }
  // WABT attaches one queued annotation per opcode, without reordering sections
  // or skipping an unmatched queue entry. Preserve that observable behavior.
  let mut entry = 0
  let mut value = 0
  for local_index, positions in metadata.instruction_callbacks {
    let func = imported + local_index
    for ordinal, position in positions {
      if entry >= queue.length() || queue[entry].func != func {
        continue
      }
      let current = queue[entry]
      if value == current.values.length() {
        entry += 1
        value = 0
        continue
      }
      if current.values[value].0 == position {
        names.annotations[(func, ordinal)] = (
          current.name,
          current.values[value].1,
        )
        value += 1
      }
    }
  }
}
