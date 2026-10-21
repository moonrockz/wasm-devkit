///|
fn named_heap_value(value : @types.ValueType, names : Names) -> String {
  match value.heap() {
    Some((nullable, _, heap)) if heap >= 0 =>
      "(ref " +
      (if nullable { "null " } else { "" }) +
      names.reference(4, heap) +
      ")"
    _ => compatible_value_type(value)
  }
}

///|
fn named_heap(value : @types.ValueType, names : Names) -> String {
  match value.heap() {
    Some((_, _, heap)) if heap >= 0 => names.reference(4, heap)
    _ => heap_type_to_wat(value)
  }
}

///|
fn name_heap_spelling(text : String, names : Names) -> String {
  if !text.has_prefix("(ref ") || !text.has_suffix(")") {
    return text
  }
  let body = text[5:text.length() - 1]
  let nullable = body.has_prefix("null ")
  let index_text = if nullable { body[5:].to_owned() } else { body.to_owned() }
  let index = @string.parse_int(index_text) catch { _ => return text }
  if index < 0 {
    return text
  }
  "(ref " +
  (if nullable { "null " } else { "" }) +
  names.reference(4, index) +
  ")"
}

///|
fn named_heap_metadata(
  metadata : @core_parser.ModuleTextMetadata,
  names : Names,
) -> @core_parser.ModuleTextMetadata {
  metadata.map_value_spellings(s => name_heap_spelling(s, names))
}

///|
fn compatible_composite(
  type_ : @types.CompositeType,
  index : Int32,
  names : Names,
) -> String {
  fn field(field : @types.FieldType) -> String {
    let storage = match field.storage_type {
      Val(value) => named_heap_value(value, names)
      Packed(I8) => "i8"
      Packed(I16) => "i16"
    }
    if field.mutable {
      "(mut " + storage + ")"
    } else {
      storage
    }
  }
  let inner = match type_.unshared() {
    Func(sig) =>
      "(func" +
      compatible_signature(sig, text=names.type_values.get(index)) +
      ")"
    Struct(s) => {
      let fields = s.fields
        .mapi((i, f) => {
          let name = names
            .local_declaration(10, index, i)
            .map(n => n + " ")
            .unwrap_or("")
          " (field " + name + field(f) + ")"
        })
        .join("")
      "(struct" + fields + ")"
    }
    Array(a) => "(array " + field(a.element) + ")"
    other => composite_type_to_wat(other)
  }
  if type_.is_shared() {
    "(shared " + inner + ")"
  } else {
    inner
  }
}
