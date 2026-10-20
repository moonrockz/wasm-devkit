// Retained from Milky2018/wasm_component@0.16.0.
// Modified by wasm-devkit: parse nested type scopes with an explicit work stack.

///|
fn parse_name_annot(reader : Reader) -> Bytes raise ComponentParseError {
  let len = reader.read_leb_u32()
  reader.read_bytes(len)
}

///|
fn parse_versionsuffix(reader : Reader) -> Bytes raise ComponentParseError {
  let len = reader.read_leb_u32()
  reader.read_bytes(len)
}

///|
fn parse_attribute(reader : Reader) -> NameAttribute raise ComponentParseError {
  let tag = reader.read_u8()
  if tag == 0x00 {
    Implements(parse_name_annot(reader))
  } else if tag == 0x01 {
    VersionSuffix(parse_versionsuffix(reader))
  } else if tag == 0x02 {
    ExternalId(parse_name_annot(reader))
  } else {
    raise InvalidTypeSection
  }
}

///|
fn parse_attributes(
  reader : Reader,
) -> Array[NameAttribute] raise ComponentParseError {
  let count = reader.read_leb_u32()
  let attributes : Array[NameAttribute] = []
  for _ in 0..<count {
    attributes.push(parse_attribute(reader))
  }
  attributes
}
