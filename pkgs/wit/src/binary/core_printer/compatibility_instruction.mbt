///|
fn compatible_branch(
  index : Int32,
  names : Names,
  func : Int32,
  labels : Array[Int32],
) -> String {
  if names.style == WasmTools {
    if index < labels.length() {
      let label = labels[labels.length() - 1 - index]
      if names.local_declaration(3, func, label) is Some(name) {
        let shadowed = labels[labels.length() - index:]
          .iter()
          .any(l => names.local_declaration(3, func, l) == Some(name))
        if !shadowed {
          return names.reference(3, label, scope=func)
        }
        return index.to_string()
      }
      return "\{index} (;@\{labels.length() - index};)"
    }
    index.to_string()
  } else {
    "\{index} (;@\{labels.length() - index};)"
  }
}

///|
fn compatible_block_type(
  type_ : @types.BlockType,
  names : Names,
  values~ : ReadOnlyArray[String] = [],
) -> String {
  match type_ {
    TypeIndex(i) =>
      (if names.style == WasmTools {
        " (type \{names.reference(4, i)})"
      } else {
        ""
      }) +
      names.signatures
      .get(i)
      .map(sig => compatible_signature(sig, text=names.type_values.get(i)))
      .unwrap_or("")
    Value(type_) =>
      " (result " + values.get(0).unwrap_or(compatible_value_type(type_)) + ")"
    _ => block_type_to_wat(type_)
  }
}

///|
fn compatible_instruction(
  instr : @types.Instruction,
  names : Names,
  func : Int32,
  labels : Array[Int32],
  ordinal : Int32,
  values~ : ReadOnlyArray[String] = [],
) -> String {
  let reference = fn(kind, index) { names.reference(kind, index) }
  let branch = fn(index) { compatible_branch(index, names, func, labels) }
  match instr {
    Block(bt, _) | Loop(bt, _) | If(bt, _, _) => {
      let op = match instr {
        Block(_) => "block"
        Loop(_) => "loop"
        _ => "if"
      }
      let name = if names.style == WasmTools {
        names.local_declaration(3, func, ordinal)
      } else {
        None
      }
      let label = name.map(n => " " + n).unwrap_or("")
      let comment = if name is Some(_) {
        ""
      } else {
        (if names.style == Wabt { "  " } else { " " }) +
        ";; label = @\{labels.length() + 1}"
      }
      "\{op}\{label}\{compatible_block_type(bt, names, values~)}\{comment}"
    }
    Br(i) => "br \{branch(i)}"
    BrIf(i) => "br_if \{branch(i)}"
    BrTable(targets, default) =>
      "br_table " + (targets + [default]).map(i => branch(i)).join(" ")
    Call(i) => "call \{reference(1, i)}"
    ReturnCall(i) => "return_call \{reference(1, i)}"
    RefFunc(i) => "ref.func \{reference(1, i)}"
    CallRef(i) => "call_ref \{reference(4, i)}"
    ReturnCallRef(i) => "return_call_ref \{reference(4, i)}"
    CallIndirect(type_, table) | ReturnCallIndirect(type_, table) => {
      let op = if instr is CallIndirect(_) {
        "call_indirect"
      } else {
        "return_call_indirect"
      }
      let table = if table != 0 { " " + reference(5, table) } else { "" }
      "\{op}\{table} (type \{reference(4, type_)})"
    }
    RefNull(value) => "ref.null " + named_heap(value, names)
    RefTest(value) | RefTestNull(value) =>
      "ref.test " + named_heap_value(value, names)
    RefCast(value) | RefCastNull(value) =>
      "ref.cast " + named_heap_value(value, names)
    BrOnCast(label, from, to) | BrOnCastFail(label, from, to) => {
      let op = if instr is BrOnCast(_) {
        "br_on_cast"
      } else {
        "br_on_cast_fail"
      }
      op +
      " " +
      branch(label) +
      " " +
      named_heap_value(from, names) +
      " " +
      named_heap_value(to, names)
    }
    BrOnNull(label) => "br_on_null " + branch(label)
    BrOnNonNull(label) => "br_on_non_null " + branch(label)
    Throw(tag) => "throw " + reference(11, tag)
    StructNew(t)
    | StructNewDefault(t)
    | ArrayNew(t)
    | ArrayNewDefault(t)
    | ArrayGet(t)
    | ArrayGetS(t)
    | ArrayGetU(t)
    | ArraySet(t)
    | ArrayFill(t) => {
      let op = instr_to_wat(instr).split(" ").nth(0).unwrap().to_owned()
      op + " " + reference(4, t)
    }
    StructGet(t, f) | StructGetS(t, f) | StructGetU(t, f) | StructSet(t, f) => {
      let op = instr_to_wat(instr).split(" ").nth(0).unwrap().to_owned()
      op + " " + reference(4, t) + " " + names.reference(10, f, scope=t)
    }
    ArrayNewFixed(t, len) =>
      "array.new_fixed " +
      reference(4, t) +
      " " +
      len.reinterpret_as_uint().to_string()
    ArrayNewData(t, data) =>
      "array.new_data " + reference(4, t) + " " + reference(9, data)
    ArrayInitData(t, data) =>
      "array.init_data " + reference(4, t) + " " + reference(9, data)
    ArrayNewElem(t, elem) =>
      "array.new_elem " + reference(4, t) + " " + reference(8, elem)
    ArrayInitElem(t, elem) =>
      "array.init_elem " + reference(4, t) + " " + reference(8, elem)
    ArrayCopy(dst, src) =>
      "array.copy " + reference(4, dst) + " " + reference(4, src)
    LocalGet(i) => "local.get \{names.reference(2, i, scope=func)}"
    LocalSet(i) => "local.set \{names.reference(2, i, scope=func)}"
    LocalTee(i) => "local.tee \{names.reference(2, i, scope=func)}"
    GlobalGet(i) => "global.get \{reference(7, i)}"
    GlobalSet(i) => "global.set \{reference(7, i)}"
    TableGet(i) => "table.get \{reference(5, i)}"
    TableSet(i) => "table.set \{reference(5, i)}"
    TableSize(i) => "table.size \{reference(5, i)}"
    TableGrow(i) => "table.grow \{reference(5, i)}"
    TableFill(i) => "table.fill \{reference(5, i)}"
    TableCopy(dst, src) =>
      if dst == 0 && src == 0 {
        "table.copy"
      } else {
        "table.copy \{reference(5, dst)} \{reference(5, src)}"
      }
    TableInit(table, elem) => {
      let table = if table != 0 { reference(5, table) + " " } else { "" }
      "table.init \{table}\{reference(8, elem)}"
    }
    ElemDrop(i) => "elem.drop \{reference(8, i)}"
    MemorySize(i) | MemoryGrow(i) | MemoryFill(i) => {
      let op = match instr {
        MemorySize(_) => "memory.size"
        MemoryGrow(_) => "memory.grow"
        _ => "memory.fill"
      }
      let memory = if i != 0 { " " + reference(6, i) } else { "" }
      op + memory
    }
    MemoryCopy(dst, src) =>
      if dst == 0 && src == 0 {
        "memory.copy"
      } else {
        "memory.copy \{reference(6, dst)} \{reference(6, src)}"
      }
    MemoryInit(mem, data) => {
      let mem = if mem != 0 { reference(6, mem) + " " } else { "" }
      "memory.init \{mem}\{reference(9, data)}"
    }
    DataDrop(i) => "data.drop \{reference(9, i)}"
    SelectTyped(types) =>
      "select" + signature(types, "result", spellings=values)
    F32Const(f) =>
      "f32.const " +
      compatible_float(f.reinterpret_as_uint().to_uint64(), true, names.style)
    F64Const(f) =>
      "f64.const " +
      compatible_float(f.reinterpret_as_uint64(), false, names.style)
    V128Const(bytes) => {
      let lanes : Array[String] = []
      for i in 0..<4 {
        let mut value = 0U
        for j in 0..<4 {
          value = value | (bytes[i * 4 + j].to_uint() << (j * 8))
        }
        let hex = value.to_string(radix=16)
        lanes.push("0x" + "0".repeat(8 - hex.length()) + hex)
      }
      "v128.const i32x4 " + lanes.join(" ")
    }
    _ => compatible_memory_instruction(instr, names)
  }
}

///|
fn compatible_memory_instruction(
  instr : @types.Instruction,
  names : Names,
) -> String {
  let text = instr_to_wat(instr)
  // All in-profile loads/stores use the retained renderer's mem_instr helper.
  // Keep non-default alignment, and omit the natural alignment as both pins do.
  let words = text.split(" ").map(w => w.to_owned()).to_array()
  let op = words[0]
  if !op.contains(".load") && !op.contains(".store") {
    return text
  }
  let natural = if op.contains("8") {
    1
  } else if op.contains("16") {
    2
  } else if op.contains("32") &&
    !op.has_prefix("i32.") &&
    !op.has_prefix("f32.") {
    4
  } else if op.has_prefix("i64.") || op.has_prefix("f64.") {
    8
  } else if op.has_prefix("v128.") {
    16
  } else {
    4
  }
  let kept = words.filter(w => w != "align=\{natural}")
  let out : Array[String] = [op]
  let mut at = 1
  let index = if at < kept.length() && !kept[at].contains("=") {
    let value = @string.parse_int(kept[at]) catch { _ => 0 }
    at += 1
    value
  } else {
    0
  }
  if index != 0 {
    out.push(names.reference(6, index))
  }
  for i in at..<kept.length() {
    if kept[i].has_prefix("offset=-") {
      let offset = @string.parse_int64(kept[i][7:]) catch { _ => 0L }
      out.push("offset=" + offset.reinterpret_as_uint64().to_string())
    } else {
      out.push(kept[i])
    }
  }
  out.join(" ")
}

///|
priv enum CompatibleTask {
  Body(Array[@types.Instruction], Int32, Int32)
  Line(String)
  Leave
  Skip(Int32)
}

///|
fn compatible_body(
  body : Array[@types.Instruction],
  names : Names,
  func : Int32,
) -> String {
  let out = StringBuilder()
  let labels : Array[Int32] = []
  let tasks : Array[CompatibleTask] = [Body(body, 0, 2)]
  let mut ordinal = 0
  let mut opcode = 0
  let mut pending_annotation = false
  let hint = fn(depth, opcode) {
    if names.style == WasmTools {
      if names.hints.get((func, opcode)) is Some(taken) {
        out.write_string(
          "  ".repeat(depth) +
          "(@metadata.code.branch_hint \"\\0\{if taken { 1 } else { 0 }}\")\n",
        )
      }
    } else if names.annotations.get((func, opcode)) is Some((name, data)) {
      if !pending_annotation {
        out.write_string("  ".repeat(depth))
      }
      out.write_string("(@" + name + " \"" + escape_wat_bytes(data) + "\") ")
      pending_annotation = true
    }
  }
  while tasks.pop() is Some(task) {
    match task {
      Leave => ignore(labels.pop())
      Skip(depth) => {
        hint(depth, opcode)
        opcode += 1
      }
      Line(text) => {
        hint(
          (text.length() - text.trim_start(chars=" ").length()) / 2 + 1,
          opcode,
        )
        let text = if pending_annotation {
          text.trim_start(chars=" ").to_owned()
        } else {
          text
        }
        opcode += 1
        out.write_string(text)
        pending_annotation = false
      }
      Body(body, index, depth) => {
        if index >= body.length() {
          continue
        }
        let instr = body[index]
        let pad = "  ".repeat(depth)
        let value_types = names.instruction_values
          .get((func, opcode))
          .unwrap_or([])
        hint(depth, opcode)
        let render_pad = if pending_annotation { "" } else { pad }
        opcode += 1
        out.write_string(
          render_pad +
          compatible_instruction(
            instr,
            names,
            func,
            labels,
            ordinal,
            values=value_types,
          ) +
          "\n",
        )
        pending_annotation = false
        tasks.push(Body(body, index + 1, depth))
        match instr {
          Block(_, nested) | Loop(_, nested) => {
            labels.push(ordinal)
            ordinal += 1
            tasks.push(Leave)
            tasks.push(Line(pad + "end\n"))
            tasks.push(Body(nested, 0, depth + 1))
          }
          If(_, then_, else_) => {
            labels.push(ordinal)
            ordinal += 1
            tasks.push(Leave)
            tasks.push(Line(pad + "end\n"))
            if !else_.is_empty() ||
              (
                names.style == WasmTools &&
                names.elses.contains((func, ordinal - 1))
              ) {
              tasks.push(Body(else_, 0, depth + 1))
              tasks.push(Line(pad + "else\n"))
            } else if names.elses.contains((func, ordinal - 1)) {
              tasks.push(Skip(depth + 1))
            }
            tasks.push(Body(then_, 0, depth + 1))
          }
          _ => ()
        }
      }
    }
  }
  hint(2, opcode)
  out.to_string()
}

///|
priv enum ConstantTask {
  Node(Int32, Int32)
  Text(String)
}

///|
// WABT folds initializer expressions. Build an operand tree, then print with
// an explicit work stack; extended constants never recurse through the input.
fn compatible_constant(
  body : Array[@types.Instruction],
  names : Names,
) -> String {
  let nodes : Array[(@types.Instruction, Array[Int32])] = []
  let values : Array[Int32] = []
  for instr in body {
    let children = match instr {
      I32Add | I32Sub | I32Mul | I64Add | I64Sub | I64Mul => {
        let right = values.pop().unwrap_or(0)
        let left = values.pop().unwrap_or(0)
        [left, right]
      }
      _ => []
    }
    values.push(nodes.length())
    nodes.push((instr, children))
  }
  let out = StringBuilder()
  for value in values {
    let work : Array[ConstantTask] = [Node(value, 2)]
    while work.pop() is Some(task) {
      match task {
        Text(text) => out.write_string(text)
        Node(index, depth) => {
          let (instr, children) = nodes[index]
          out.write_string("(" + compatible_instruction(instr, names, 0, [], 0))
          work.push(Text(")"))
          for i = children.length() - 1; i >= 0; i = i - 1 {
            work.push(Node(children[i], depth + 1))
            work.push(Text("\n" + "  ".repeat(depth + 1)))
          }
        }
      }
    }
  }
  out.to_string()
}
