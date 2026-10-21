///|
priv struct CoreRender {
  out : StringBuilder
  mut serial : Int32
  mut remaining : Int32
  component : Bool
}

///|
fn CoreRender::charge(self : CoreRender, count : Int32) -> Unit raise Failure {
  if count < 0 || count > self.remaining {
    reject("core type rendering exceeds its work limit")
  }
  self.remaining -= count
}

///|
fn core_heap_name(heap : Int32) -> String raise Failure {
  match heap {
    -16 => "func"
    -17 => "extern"
    -18 => "any"
    -19 => "eq"
    -20 => "i31"
    -21 => "struct"
    -22 => "array"
    -23 => "exn"
    -15 => "none"
    -14 => "noextern"
    -13 => "nofunc"
    -12 => "noexn"
    _ => reject("unknown abstract core heap type")
  }
}

///|
fn core_heap_value(
  value : @core_types.HeapValue,
  prefix : String,
) -> String raise Failure {
  match value {
    Number(name) => name
    Ref(nullable, shared, heap) => {
      let target = if heap >= 0 {
        prefix + heap.to_string()
      } else if shared {
        "(shared " + core_heap_name(heap) + ")"
      } else {
        core_heap_name(heap)
      }
      "(ref " + (if nullable { "null " } else { "" }) + target + ")"
    }
  }
}

///|
fn core_heap_field(
  field : @core_types.HeapField,
  prefix : String,
) -> String raise Failure {
  let storage = match field.storage {
    Packed(name) => name
    Value(value) => core_heap_value(value, prefix)
  }
  if field.mutable {
    "(mut " + storage + ")"
  } else {
    storage
  }
}

///|
fn core_identity(
  identity : @core_types.TypeIdentity,
  render : CoreRender,
) -> String raise Failure {
  render.charge(identity.types.length())
  guard identity.types.get(identity.index) is Some(_) else {
    reject("invalid concrete core type index")
  }
  let prefix = "$heap-n" + render.serial.to_string() + "-"
  render.serial += 1
  let mut end = 0
  for index, node in identity.types {
    if index == end {
      if node.group_start != index ||
        node.group_size <= 0 ||
        node.group_size > identity.types.length() - index {
        reject("invalid recursive core group")
      }
      end = index + node.group_size
      render.out.write_string(
        if render.component {
          "(core rec\n"
        } else {
          "(rec\n"
        },
      )
    }
    let composite = match node.composite {
      Function(params, results) => {
        render.charge(params.length())
        render.charge(results.length())
        let out = StringBuilder()
        out.write_string("(func")
        for value in params {
          out.write_string(" (param " + core_heap_value(value, prefix) + ")")
        }
        for value in results {
          out.write_string(" (result " + core_heap_value(value, prefix) + ")")
        }
        out.write_char(')')
        out.to_string()
      }
      Struct(fields) => {
        render.charge(fields.length())
        let out = StringBuilder()
        out.write_string("(struct")
        for field in fields {
          out.write_string(" (field " + core_heap_field(field, prefix) + ")")
        }
        out.write_char(')')
        out.to_string()
      }
      Array(field) => "(array " + core_heap_field(field, prefix) + ")"
    }
    let composite = if node.shared {
      "(shared " + composite + ")"
    } else {
      composite
    }
    let body = if node.final_ && node.supertype is None {
      composite
    } else {
      "(sub " +
      (if node.final_ { "final " } else { "" }) +
      node.supertype.map(i => prefix + i.to_string() + " ").unwrap_or("") +
      composite +
      ")"
    }
    render.out.write_string(
      "(type " + prefix + index.to_string() + " " + body + ")\n",
    )
    if index + 1 == end {
      render.out.write_string(")\n")
    }
  }
  prefix + identity.index.to_string()
}

///|
fn core_heap_value_json(value : @core_types.HeapValue) -> Json {
  match value {
    Number(name) => { "kind": "scalar", "name": Json::string(name) }
    Ref(nullable, shared, heap) =>
      {
        "kind": "reference",
        "nullable": Json::boolean(nullable),
        "shared": Json::boolean(shared),
        "heap": optional_int(Some(heap)),
      }
  }
}

///|
fn core_heap_field_json(field : @core_types.HeapField) -> Json {
  {
    "mutable": Json::boolean(field.mutable),
    "storage": match field.storage {
      Value(value) => core_heap_value_json(value)
      Packed(name) => { "kind": "packed", "name": Json::string(name) }
    },
  }
}

///|
fn core_identity_json(identity : @core_types.TypeIdentity) -> Json {
  let nodes = identity.types.map(node => {
    let composite : Json = match node.composite {
      Function(params, results) =>
        {
          "kind": "func",
          "params": Json::array(
            params.map(core_heap_value_json).iter().to_array(),
          ),
          "results": Json::array(
            results.map(core_heap_value_json).iter().to_array(),
          ),
        }
      Struct(fields) =>
        {
          "kind": "struct",
          "fields": Json::array(
            fields.map(core_heap_field_json).iter().to_array(),
          ),
        }
      Array(field) => { "kind": "array", "field": core_heap_field_json(field) }
    }
    Json::object({
      "final": Json::boolean(node.final_),
      "shared": Json::boolean(node.shared),
      "supertype": optional_int(node.supertype),
      "group-start": optional_int(Some(node.group_start)),
      "group-size": optional_int(Some(node.group_size)),
      "composite": composite,
    })
  })
  {
    "index": optional_int(Some(identity.index)),
    "types": Json::array(nodes.iter().to_array()),
  }
}
