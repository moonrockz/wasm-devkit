///|
// One unit of printing work. Nested components and component/instance type
// bodies become tasks, so input-controlled nesting never recurses.
priv enum Task {
  Text(String)
  Component(Bytes, Int32, Int32?, String, Scope)
  ComponentDecls(Array[@component.ComponentDecl], Int32, Scope)
  InstanceDecls(Array[@component.InstanceDecl], Int32, Scope)
}

///|
// Index counters for one scope. Component sorts use their binary tags 1..5;
// core sorts use 0x100 plus their core sort byte.
priv struct Scope {
  counts : Map[Int32, Int32]
  compatibility : Bool
  names : @core_printer.Names
  parents : Array[Scope]
  original_bytes : Bytes
  source_offset : Int32
  core_signatures : Map[Int32, String]
}

///|
fn Scope::new(
  compatibility~ : Bool = false,
  bytes~ : Bytes = b"",
  parents~ : Array[Scope] = [],
  source_offset~ : Int32 = 0,
) -> Scope {
  {
    counts: Map([]),
    compatibility,
    names: @core_printer.component_names(bytes),
    parents,
    original_bytes: bytes,
    source_offset,
    core_signatures: Map([]),
  }
}

///|
fn Scope::child(
  self : Scope,
  bytes~ : Bytes = b"",
  source_offset~ : Int32 = 0,
) -> Scope {
  Scope::new(
    compatibility=self.compatibility,
    bytes~,
    parents=self.parents + [self],
    source_offset~,
  )
}

///|
fn Scope::reference(self : Scope, kind : Int32, index : Int32) -> String {
  if self.compatibility {
    self.names.reference(kind, index)
  } else {
    index.to_string()
  }
}

///|
fn Scope::declaration(self : Scope, kind : Int32, index : Int32) -> String {
  if self.compatibility {
    self.names.declaration(kind, index)
  } else {
    "(;\{index};)"
  }
}

///|
fn Scope::take(self : Scope, sort : Int32) -> Int32 {
  let index = self.counts.get(sort).unwrap_or(0)
  self.counts[sort] = index + 1
  index
}

///|
fn sort_key(sort : @component.Sort) -> Int32 {
  match sort {
    Core(core) => 0x100 + core
    Func => 1
    Value => 2
    Type => 3
    Component => 4
    Instance => 5
  }
}

///|
fn sort_name(key : Int32) -> String raise PrintFailure {
  match key {
    1 => "func"
    2 => "value"
    3 => "type"
    4 => "component"
    5 => "instance"
    0x100 => "core func"
    0x101 => "core table"
    0x102 => "core memory"
    0x103 => "core global"
    0x104 => "core tag"
    0x110 => "core type"
    0x111 => "core module"
    0x112 => "core instance"
    _ => unsupported("sort \{key} is outside the component print profile")
  }
}

///|
// Core sort names inside core instance expressions omit the `core` prefix.
fn core_sort_name(key : Int32) -> String raise PrintFailure {
  let name = sort_name(key)
  if name.has_prefix("core ") {
    name[5:].to_owned()
  } else {
    unsupported("core instance expressions use core sorts")
  }
}

///|
fn[T] unsupported(message : String) -> T raise PrintFailure {
  raise PrintFailure(None, "WIT-D003", message)
}

///|
fn indent(depth : Int32) -> String {
  "  ".repeat(depth)
}

///|
// Quote bytes as a WAT string. Printable ASCII other than quotes and
// backslashes stays readable; every other byte uses a `\hh` escape.
fn quote_bytes(bytes : BytesView) -> String {
  let hex = "0123456789abcdef"
  let out = StringBuilder()
  out.write_char('"')
  for byte in bytes {
    let code = byte.to_int()
    if code < 0x20 || code > 0x7e || code == 0x22 || code == 0x5c {
      out.write_char('\\')
      out.write_char(hex[(code >> 4) & 0xf].to_int().unsafe_to_char())
      out.write_char(hex[code & 0xf].to_int().unsafe_to_char())
    } else {
      out.write_char(code.unsafe_to_char())
    }
  }
  out.write_char('"')
  out.to_string()
}

///|
fn quote(text : String, scope~ : Scope = Scope::new()) -> String {
  if scope.compatibility {
    "\"" + @core_printer.compatibility_string(text, WasmTools) + "\""
  } else {
    quote_bytes(@utf8.encode(text))
  }
}

///|
fn attributes(
  attributes : Array[@component.NameAttribute],
  scope~ : Scope = Scope::new(),
) -> String {
  let out = StringBuilder()
  for attribute in attributes {
    match attribute {
      Implements(value) =>
        out.write_string(
          " (implements \{quote(@utf8.decode_lossy(value), scope~)})",
        )
      VersionSuffix(value) =>
        out.write_string(
          " (version-suffix \{quote(@utf8.decode_lossy(value), scope~)})",
        )
      ExternalId(value) =>
        out.write_string(
          " (external-id \{quote(@utf8.decode_lossy(value), scope~)})",
        )
    }
  }
  out.to_string()
}

///|
fn import_name(
  name : @component.ImportName,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  match name {
    Plain(bytes) => quote(@utf8.decode_lossy(bytes), scope~)
    WithVersion(_, _) =>
      unsupported("versioned import names are outside the print profile")
  }
}

///|
fn export_name(
  name : @component.ExportName,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  match name {
    Plain(bytes) => quote(@utf8.decode_lossy(bytes), scope~)
    WithVersion(_, _) =>
      unsupported("versioned export names are outside the print profile")
  }
}

///|
// The retained component text compiler has no `error-context` value type, so
// printed text containing one could not compile.
fn primitive(type_ : @component.PrimValType) -> String raise PrintFailure {
  match type_ {
    Bool => "bool"
    S8 => "s8"
    U8 => "u8"
    S16 => "s16"
    U16 => "u16"
    S32 => "s32"
    U32 => "u32"
    S64 => "s64"
    U64 => "u64"
    F32 => "f32"
    F64 => "f64"
    Char => "char"
    String => "string"
    ErrorContext =>
      unsupported(
        "error-context values are outside the component print profile",
      )
  }
}

///|
fn value_type(
  type_ : @component.ValType,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  match type_ {
    TypeIdx(index) => scope.reference(3, index)
    Prim(prim) => primitive(prim)
  }
}

///|
// Print a non-nesting type definition. Component and instance types are
// handled by `type_tasks`.
fn simple_type(
  definition : @component.TypeDef,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  match definition {
    DefValType(prim) => primitive(prim)
    FuncType(func) => {
      let out = StringBuilder()
      out.write_string("(func")
      if func.is_async {
        out.write_string(" async")
      }
      for param in func.params {
        out.write_string(
          " (param \{quote(param.label, scope~)} \{value_type(param.ty, scope~)})",
        )
      }
      if func.result is Some(result) {
        out.write_string(" (result \{value_type(result, scope~)})")
      }
      out.write_string(")")
      out.to_string()
    }
    List(element) => "(list \{value_type(element, scope~)})"
    FixedList(element, length) =>
      "(list \{value_type(element, scope~)} \{length})"
    MapType(key, value) =>
      "(map \{value_type(key, scope~)} \{value_type(value, scope~)})"
    Record(fields) => {
      let out = StringBuilder()
      out.write_string("(record")
      for field in fields {
        out.write_string(
          " (field \{quote(field.label, scope~)} \{value_type(field.ty, scope~)})",
        )
      }
      out.write_string(")")
      out.to_string()
    }
    Variant(cases) => {
      let out = StringBuilder()
      out.write_string("(variant")
      for case_ in cases {
        out.write_string(" (case \{quote(case_.label, scope~)}")
        if case_.ty is Some(payload) {
          out.write_string(" \{value_type(payload, scope~)}")
        }
        if case_.refines is Some(index) {
          out.write_string(" (refines \{index})")
        }
        out.write_string(")")
      }
      out.write_string(")")
      out.to_string()
    }
    Tuple(types) => {
      let out = StringBuilder()
      out.write_string("(tuple")
      for type_ in types {
        out.write_string(" \{value_type(type_, scope~)}")
      }
      out.write_string(")")
      out.to_string()
    }
    Flags(names) | Enum(names) => {
      let out = StringBuilder()
      out.write_string(if definition is Flags(_) { "(flags" } else { "(enum" })
      for name in names {
        out.write_string(" \{quote(name, scope~)}")
      }
      out.write_string(")")
      out.to_string()
    }
    Option(type_) => "(option \{value_type(type_, scope~)})"
    Result(ok, error) => {
      let out = StringBuilder()
      out.write_string("(result")
      if ok is Some(type_) {
        out.write_string(" \{value_type(type_, scope~)}")
      }
      if error is Some(type_) {
        out.write_string(" (error \{value_type(type_, scope~)})")
      }
      out.write_string(")")
      out.to_string()
    }
    Own(index) => "(own \{scope.reference(3, index)})"
    Borrow(index) => "(borrow \{scope.reference(3, index)})"
    Stream(Some(type_)) => "(stream \{value_type(type_, scope~)})"
    Stream(None) => "(stream)"
    Future(Some(type_)) => "(future \{value_type(type_, scope~)})"
    Future(None) => "(future)"
    ResourceType(_, rep, destructor, _) => {
      let rep = match rep {
        0x7f => "i32"
        0x7e => "i64"
        _ =>
          unsupported(
            "resource representations other than i32 and i64 are outside the print profile",
          )
      }
      match destructor {
        Some(index) =>
          if scope.compatibility {
            "(resource (rep \{rep}) (dtor \{scope.reference(0x100, index)}))"
          } else {
            "(resource (rep \{rep}) (dtor (func \{index})))"
          }
        None => "(resource (rep \{rep}))"
      }
    }
    InstanceTypeEmpty => "(instance)"
    ComponentType(_) | InstanceType(_) =>
      unsupported("nested type bodies print as tasks")
  }
}

///|
// Tasks for one `(type ...)` definition at `depth`.
fn type_tasks(
  tasks : Array[Task],
  depth : Int32,
  index : Int32,
  definition : @component.TypeDef,
  scope~ : Scope = Scope::new(),
) -> Unit raise PrintFailure {
  let pad = indent(depth)
  let label = scope.declaration(3, index)
  match definition {
    ComponentType(decls) => {
      if scope.compatibility && decls.is_empty() {
        tasks.push(Text("\{pad}(type \{label}\n\{pad}  (component)\n\{pad})\n"))
        return
      }
      tasks.push(Text("\{pad}(type \{label}\n\{pad}  (component\n"))
      tasks.push(ComponentDecls(decls, depth + 2, scope.child()))
      tasks.push(Text("\{pad}  )\n\{pad})\n"))
    }
    InstanceType(decls) => {
      if scope.compatibility && decls.is_empty() {
        tasks.push(Text("\{pad}(type \{label}\n\{pad}  (instance)\n\{pad})\n"))
        return
      }
      tasks.push(Text("\{pad}(type \{label}\n\{pad}  (instance\n"))
      tasks.push(InstanceDecls(decls, depth + 2, scope.child()))
      tasks.push(Text("\{pad}  )\n\{pad})\n"))
    }
    InstanceTypeEmpty if scope.compatibility =>
      tasks.push(Text("\{pad}(type \{label}\n\{pad}  (instance)\n\{pad})\n"))
    _ =>
      tasks.push(
        Text("\{pad}(type \{label} \{simple_type(definition, scope~)})\n"),
      )
  }
}

///|
fn extern_sort(desc : @component.ExternDesc) -> Int32 {
  match desc {
    CoreModuleType(_) => 0x111
    FuncType(_) => 1
    Value(_) => 2
    Type(_) => 3
    ComponentType(_) => 4
    InstanceType(_) => 5
  }
}

///|
// An extern descriptor whose defined item has `index`, or no comment when
// `index` is `None` (export ascriptions define nothing).
fn extern_desc(
  desc : @component.ExternDesc,
  index : Int32?,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  let comment = match index {
    Some(index) => " " + scope.declaration(extern_sort(desc), index)
    None => ""
  }
  match desc {
    CoreModuleType(type_) =>
      "(core module\{comment} (type \{scope.reference(0x110, type_)}))"
    FuncType(type_) => "(func\{comment} (type \{scope.reference(3, type_)}))"
    Value(Type(type_)) =>
      match type_ {
        TypeIdx(index) if scope.compatibility =>
          "(value\{comment} (type \{scope.reference(3, index)}))"
        _ => "(value\{comment} \{value_type(type_, scope~)})"
      }
    Value(Eq(value)) => "(value\{comment} (eq \{scope.reference(2, value)}))"
    Type(Eq(type_)) => "(type\{comment} (eq \{scope.reference(3, type_)}))"
    Type(SubResource) => "(type\{comment} (sub resource))"
    ComponentType(type_) =>
      "(component\{comment} (type \{scope.reference(3, type_)}))"
    InstanceType(type_) =>
      "(instance\{comment} (type \{scope.reference(3, type_)}))"
  }
}

///|
fn outer_alias(
  pad : String,
  kind : Int32,
  count : Int32,
  target : Int32,
  scope : Scope,
) -> String raise PrintFailure {
  // Declaration aliases encode core sorts as 0x100 plus the core sort byte,
  // matching `sort_key`.
  let index = scope.take(kind)
  let target_scope = if count == 0 {
    scope
  } else if count <= scope.parents.length() {
    scope.parents[scope.parents.length() - count]
  } else {
    scope
  }
  let count = if scope.compatibility {
    target_scope.names.root_name().unwrap_or(count.to_string())
  } else {
    count.to_string()
  }
  "\{pad}(alias outer \{count} \{target_scope.reference(kind, target)} (\{sort_name(kind)} \{scope.declaration(kind, index)}))\n"
}

///|
// `core` selects a core instance export; otherwise the alias reads a
// component instance export, whose sort can still be a core module.
fn export_alias(
  pad : String,
  core : Bool,
  kind : Int32,
  instance : Int32,
  name : String,
  scope : Scope,
) -> String raise PrintFailure {
  let index = scope.take(kind)
  let target = if core { "core export" } else { "export" }
  "\{pad}(alias \{target} \{scope.reference(if core { 0x112 } else { 5 }, instance)} \{quote(name, scope~)} (\{sort_name(kind)} \{scope.declaration(kind, index)}))\n"
}

///|
fn component_decl_tasks(
  decls : Array[@component.ComponentDecl],
  depth : Int32,
  scope~ : Scope = Scope::new(),
) -> Array[Task] raise PrintFailure {
  let tasks : Array[Task] = []
  let pad = indent(depth)
  for decl in decls {
    match decl {
      CoreType(bytes) =>
        tasks.push(
          Text(core_type_text(bytes, depth, scope.take(0x110), scope~)),
        )
      Type(definition) =>
        type_tasks(tasks, depth, scope.take(3), definition, scope~)
      AliasOuter(kind, count, target) =>
        tasks.push(Text(outer_alias(pad, kind, count, target, scope)))
      AliasInstanceExport(kind, instance, name) =>
        tasks.push(Text(export_alias(pad, false, kind, instance, name, scope)))
      Import(name, attrs, desc) => {
        let index = scope.take(extern_sort(desc))
        tasks.push(
          Text(
            "\{pad}(import \{quote(name, scope~)}\{attributes(attrs, scope~)} \{extern_desc(desc, Some(index), scope~)})\n",
          ),
        )
      }
      Export(name, attrs, desc) => {
        let index = scope.take(extern_sort(desc))
        tasks.push(
          Text(
            if scope.compatibility {
              "\{pad}(export \{scope.declaration(extern_sort(desc), index)} \{quote(name, scope~)}\{attributes(attrs, scope~)} \{extern_desc(desc, None, scope~)})\n"
            } else {
              "\{pad}(export \{quote(name, scope~)}\{attributes(attrs, scope~)} \{extern_desc(desc, Some(index), scope~)})\n"
            },
          ),
        )
      }
    }
  }
  tasks
}

///|
fn instance_decl_tasks(
  decls : Array[@component.InstanceDecl],
  depth : Int32,
  scope~ : Scope = Scope::new(),
) -> Array[Task] raise PrintFailure {
  let tasks : Array[Task] = []
  let pad = indent(depth)
  for decl in decls {
    match decl {
      CoreType(bytes) =>
        tasks.push(
          Text(core_type_text(bytes, depth, scope.take(0x110), scope~)),
        )
      Type(definition) =>
        type_tasks(tasks, depth, scope.take(3), definition, scope~)
      AliasOuter(kind, count, target) =>
        tasks.push(Text(outer_alias(pad, kind, count, target, scope)))
      AliasInstanceExport(kind, instance, name) =>
        tasks.push(Text(export_alias(pad, false, kind, instance, name, scope)))
      Export(name, attrs, desc) => {
        let index = scope.take(extern_sort(desc))
        tasks.push(
          Text(
            if scope.compatibility {
              "\{pad}(export \{scope.declaration(extern_sort(desc), index)} \{quote(name, scope~)}\{attributes(attrs, scope~)} \{extern_desc(desc, None, scope~)})\n"
            } else {
              "\{pad}(export \{quote(name, scope~)}\{attributes(attrs, scope~)} \{extern_desc(desc, Some(index), scope~)})\n"
            },
          ),
        )
      }
    }
  }
  tasks
}

///|
fn sort_ref(
  sort_index : @component.SortIdx,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  "(\{sort_name(sort_key(sort_index.sort))} \{scope.reference(sort_key(sort_index.sort), sort_index.idx)})"
}

///|
fn core_sort_ref(
  sort_index : @component.SortIdx,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  "(\{core_sort_name(sort_key(sort_index.sort))} \{scope.reference(sort_key(sort_index.sort), sort_index.idx)})"
}

///|
fn canon_options(
  options : Array[@component.CanonOpt],
  scope~ : Scope = Scope::new(),
) -> String {
  let out = StringBuilder()
  for option in options {
    out.write_string(
      match option {
        StringEncoding(Utf8) => " string-encoding=utf8"
        StringEncoding(Utf16) => " string-encoding=utf16"
        StringEncoding(Latin1Utf16) => " string-encoding=latin1+utf16"
        Memory(index) => " (memory \{scope.reference(258, index)})"
        Realloc(index) => " (realloc \{scope.reference(256, index)})"
        PostReturn(index) => " (post-return \{scope.reference(256, index)})"
        CoreType(index) => " (core-type \{scope.reference(272, index)})"
        Gc => " gc"
        Async => " async"
        Callback(index) => " (callback \{scope.reference(256, index)})"
      },
    )
  }
  out.to_string()
}

///|
fn core_value_type(type_ : @types.ValueType) -> String raise PrintFailure {
  match type_ {
    I32 => "i32"
    I64 => "i64"
    _ =>
      unsupported(
        "context values other than i32 and i64 are outside the print profile",
      )
  }
}

///|
fn flag(set : Bool, name : String) -> String {
  if set {
    " " + name
  } else {
    ""
  }
}

///|
// The body of a canonical definition that produces a core function.
fn canon_body(
  canon : @component.Canon,
  scope~ : Scope = Scope::new(),
) -> String raise PrintFailure {
  match canon {
    Lift(_, _, _) => unsupported("lift produces a component function")
    Lower(func, options) =>
      "lower (func \{scope.reference(1, func)})\{canon_options(options, scope~)}"
    BackpressureInc => "backpressure.inc"
    BackpressureDec => "backpressure.dec"
    ContextGet(type_, index) => "context.get \{core_value_type(type_)} \{index}"
    ContextSet(type_, index) => "context.set \{core_value_type(type_)} \{index}"
    TaskReturn(result, options) => {
      let result = match result {
        Some(type_) => " (result \{value_type(type_, scope~)})"
        None => ""
      }
      "task.return\{result}\{canon_options(options, scope~)}"
    }
    TaskCancel => "task.cancel"
    ThreadIndex => "thread.index"
    ThreadYield(cancellable) =>
      "thread.yield" + flag(cancellable, "cancellable")
    ThreadSuspendThenResume(cancellable) =>
      "thread.suspend-then-resume" + flag(cancellable, "cancellable")
    ThreadYieldThenResume(cancellable) =>
      "thread.yield-then-resume" + flag(cancellable, "cancellable")
    ThreadSuspendThenPromote(cancellable) =>
      "thread.suspend-then-promote" + flag(cancellable, "cancellable")
    ThreadYieldThenPromote(cancellable) =>
      "thread.yield-then-promote" + flag(cancellable, "cancellable")
    ThreadResumeLater => "thread.resume-later"
    ThreadSuspend(cancellable) =>
      "thread.suspend" + flag(cancellable, "cancellable")
    ThreadNewIndirect(type_, table) => "thread.new-indirect \{type_} \{table}"
    WaitableSetNew => "waitable-set.new"
    WaitableSetWait(cancellable, memory) =>
      "waitable-set.wait\{flag(cancellable, "cancellable")} (memory \{scope.reference(0x102, memory)})"
    WaitableSetPoll(cancellable, memory) =>
      "waitable-set.poll\{flag(cancellable, "cancellable")} (memory \{scope.reference(0x102, memory)})"
    WaitableSetDrop => "waitable-set.drop"
    WaitableJoin => "waitable.join"
    SubtaskCancel(is_async) => "subtask.cancel" + flag(is_async, "async")
    SubtaskDrop => "subtask.drop"
    StreamNew(type_) => "stream.new \{scope.reference(3, type_)}"
    StreamRead(type_, options) =>
      "stream.read \{scope.reference(3, type_)}\{canon_options(options, scope~)}"
    StreamWrite(type_, options) =>
      "stream.write \{scope.reference(3, type_)}\{canon_options(options, scope~)}"
    StreamCancelRead(type_, is_async) =>
      "stream.cancel-read \{scope.reference(3, type_)}" +
      flag(is_async, "async")
    StreamCancelWrite(type_, is_async) =>
      "stream.cancel-write \{scope.reference(3, type_)}" +
      flag(is_async, "async")
    StreamDropReadable(type_) =>
      "stream.drop-readable \{scope.reference(3, type_)}"
    StreamDropWritable(type_) =>
      "stream.drop-writable \{scope.reference(3, type_)}"
    FutureNew(type_) => "future.new \{scope.reference(3, type_)}"
    FutureRead(type_, options) =>
      "future.read \{scope.reference(3, type_)}\{canon_options(options, scope~)}"
    FutureWrite(type_, options) =>
      "future.write \{scope.reference(3, type_)}\{canon_options(options, scope~)}"
    FutureCancelRead(type_, is_async) =>
      "future.cancel-read \{scope.reference(3, type_)}" +
      flag(is_async, "async")
    FutureCancelWrite(type_, is_async) =>
      "future.cancel-write \{scope.reference(3, type_)}" +
      flag(is_async, "async")
    FutureDropReadable(type_) =>
      "future.drop-readable \{scope.reference(3, type_)}"
    FutureDropWritable(type_) =>
      "future.drop-writable \{scope.reference(3, type_)}"
    ErrorContextNew(options) =>
      "error-context.new\{canon_options(options, scope~)}"
    ErrorContextDebugMessage(options) =>
      "error-context.debug-message\{canon_options(options, scope~)}"
    ErrorContextDrop => "error-context.drop"
    ResourceNew(type_) => "resource.new \{scope.reference(3, type_)}"
    ResourceDrop(type_) => "resource.drop \{scope.reference(3, type_)}"
    ResourceRep(type_) => "resource.rep \{scope.reference(3, type_)}"
  }
}

///|
// Payload offsets of each section, in binary order. The profile check has
// already validated this framing.
fn payload_offsets(bytes : Bytes) -> Array[Int32] {
  let offsets : Array[Int32] = []
  let mut position = 8
  while position < bytes.length() {
    position += 1
    let mut size = 0
    let mut shift = 0
    while position < bytes.length() {
      let byte = bytes[position].to_int()
      position += 1
      size = size | ((byte & 0x7f) << shift)
      shift += 7
      if (byte & 0x80) == 0 {
        break
      }
    }
    offsets.push(position)
    position += size
  }
  offsets
}

///|
fn[T] parsed(
  base : Int32?,
  parse : () -> T raise @component.ComponentParseError,
) -> T raise PrintFailure {
  parse() catch {
    error => raise PrintFailure(base, "WIT-D001", error.to_string())
  }
}

///|
// Turn one component into ordered tasks. Nested components become tasks with
// their own scopes; this function never descends into them.
fn component_tasks(
  bytes : Bytes,
  depth : Int32,
  base : Int32?,
  scope~ : Scope = Scope::new(),
) -> Array[Task] raise PrintFailure {
  let binary = parsed(base, () => @component.parse_component_binary(bytes))
  let offsets = payload_offsets(bytes)
  let original = if scope.compatibility && !scope.original_bytes.is_empty() {
    Some(
      parsed(base, () => @component.parse_component_binary(scope.original_bytes)),
    )
  } else {
    None
  }
  let original_offsets = if original is Some(_) {
    payload_offsets(scope.original_bytes)
  } else {
    []
  }
  let tasks : Array[Task] = []
  let pad = indent(depth)
  for i, section in binary.sections {
    let payload = section.payload
    let offset = if base is Some(base) && i < offsets.length() {
      Some(base + offsets[i])
    } else {
      None
    }
    let original_payload = if original is Some(binary) {
      binary.sections[i].payload
    } else {
      payload
    }
    let original_offset = if i < original_offsets.length() {
      scope.source_offset + original_offsets[i]
    } else {
      offset.unwrap_or(0)
    }
    match section.id {
      0 =>
        if scope.compatibility {
          let custom = @core_printer.component_custom_section(
            payload,
            binary_offset=original_offset,
          ) catch {
            @core_printer.ReferenceUnsupported(message) =>
              raise PrintFailure(Some(original_offset), "WIT-D003", message)
            error =>
              raise PrintFailure(
                Some(original_offset),
                "WIT-D004",
                error.to_string(),
              )
          }
          if custom is Some(text) {
            tasks.push(
              Text(
                text
                .split("\n")
                .map(line => pad + line.to_owned() + "\n")
                .to_array()
                .join(""),
              ),
            )
          }
        } else {
          tasks.push(Text(custom_text(pad, payload)))
        }
      1 => {
        let index = scope.take(0x111)
        let text = render_core_module(
          payload,
          if scope.compatibility {
            Some(original_offset)
          } else {
            offset
          },
          compatibility=if scope.compatibility { Some(WasmTools) } else { None },
        )
        let lines = text.split("\n").to_array()
        let out = StringBuilder()
        for line in lines {
          if line.is_empty() {
            continue
          }
          if line.has_prefix("(module") {
            if scope.compatibility {
              let empty = line.has_suffix(")")
              let label = scope.declaration(0x111, index)
              out.write_string(
                "\{pad}(core module \{label}\{if empty { ")" } else { "" }}\n",
              )
            } else {
              out.write_string("\{pad}(core module (;\{index};)\n")
            }
          } else {
            out.write_string("\{pad}\{line}\n")
          }
        }
        tasks.push(Text(out.to_string()))
      }
      2 =>
        for
          instance in parsed(offset, () => {
            @component.parse_core_instance_section(payload)
          }) {
          let index = scope.take(0x112)
          let head = "\{pad}(core instance \{scope.declaration(0x112, index)}"
          match instance.expr {
            Instantiate(module_, args) =>
              tasks.push(
                Text(
                  instance_text(
                    head,
                    pad,
                    "(instantiate \{scope.reference(0x111, module_)}",
                    args.map(arg => {
                      "(with \{quote(arg.name, scope~)} \{core_sort_ref(arg.sortidx, scope~)})"
                    }),
                    compatibility=scope.compatibility,
                  ),
                ),
              )
            InlineExports(exports) =>
              tasks.push(
                Text(
                  instance_text(
                    head,
                    pad,
                    "",
                    exports.map(item => {
                      "(export \{quote(item.name, scope~)} \{core_sort_ref(item.sortidx, scope~)})"
                    }),
                    compatibility=scope.compatibility,
                  ),
                ),
              )
          }
        }
      3 =>
        for entry in core_type_entries(payload, offset) {
          tasks.push(
            Text(core_type_text(entry, depth, scope.take(0x110), scope~)),
          )
        }
      4 => {
        let index = scope.take(4)
        tasks.push(
          Component(
            payload,
            depth,
            offset,
            "\{pad}(component \{scope.declaration(4, index)}\n",
            scope.child(bytes=original_payload, source_offset=original_offset),
          ),
        )
      }
      5 =>
        for
          instance in parsed(offset, () => {
            @component.parse_instance_section(payload)
          }) {
          let index = scope.take(5)
          let head = "\{pad}(instance \{scope.declaration(5, index)}"
          match instance.expr {
            Instantiate(component, args) =>
              tasks.push(
                Text(
                  instance_text(
                    head,
                    pad,
                    "(instantiate \{scope.reference(4, component)}",
                    args.map(arg => {
                      "(with \{quote(arg.name, scope~)} \{sort_ref(arg.sortidx, scope~)})"
                    }),
                    compatibility=scope.compatibility,
                  ),
                ),
              )
            InlineExports(exports) =>
              tasks.push(
                Text(
                  instance_text(
                    head,
                    pad,
                    "",
                    exports.map(item => {
                      "(export \{quote(item.name, scope~)}\{attributes(item.attributes, scope~)} \{sort_ref(item.sortidx, scope~)})"
                    }),
                    compatibility=scope.compatibility,
                  ),
                ),
              )
          }
        }
      6 =>
        for
          entry in parsed(offset, () => @component.parse_alias_section(payload)) {
          let kind = sort_key(entry.sort)
          match entry.target {
            Export(instance, name) =>
              tasks.push(
                Text(export_alias(pad, false, kind, instance, name, scope)),
              )
            CoreExport(instance, name) =>
              tasks.push(
                Text(export_alias(pad, true, kind, instance, name, scope)),
              )
            Outer(count, target) =>
              tasks.push(Text(outer_alias(pad, kind, count, target, scope)))
          }
        }
      7 =>
        for
          definition in parsed(offset, () => {
            @component.parse_type_section(payload)
          }) {
          type_tasks(tasks, depth, scope.take(3), definition, scope~)
        }
      8 =>
        for
          canon in parsed(offset, () => @component.parse_canon_section(payload)) {
          match canon {
            Lift(core_func, options, type_) => {
              let index = scope.take(1)
              tasks.push(
                Text(
                  "\{pad}(func \{scope.declaration(1, index)} (type \{scope.reference(3, type_)}) (canon lift (core func \{scope.reference(0x100, core_func)})\{canon_options(options, scope~)}))\n",
                ),
              )
            }
            _ => {
              let index = scope.take(0x100)
              tasks.push(
                Text(
                  "\{pad}(core func \{scope.declaration(0x100, index)} (canon \{canon_body(canon, scope~)}))\n",
                ),
              )
            }
          }
        }
      9 => {
        let start = parsed(offset, () => @component.parse_start_section(payload))
        let out = StringBuilder()
        out.write_string("\{pad}(start \{scope.reference(1, start.func_idx)}")
        for arg in start.args {
          out.write_string(" (value \{scope.reference(2, arg)})")
        }
        if scope.compatibility {
          for _ in 0..<start.results {
            out.write_string(
              " (result (value \{scope.declaration(2, scope.take(2))}))",
            )
          }
          out.write_string(")\n")
        } else {
          out.write_string(" (result \{start.results}))\n")
          for _ in 0..<start.results {
            ignore(scope.take(2))
          }
        }
        tasks.push(Text(out.to_string()))
      }
      10 =>
        for
          import_ in parsed(offset, () => {
            @component.parse_import_section(payload)
          }) {
          let index = scope.take(extern_sort(import_.desc))
          tasks.push(
            Text(
              "\{pad}(import \{import_name(import_.name, scope~)}\{attributes(import_.attributes, scope~)} \{extern_desc(import_.desc, Some(index), scope~)})\n",
            ),
          )
        }
      11 =>
        for
          item in parsed(offset, () => @component.parse_export_section(payload)) {
          let index = scope.take(sort_key(item.sortidx.sort))
          let ascription = match item.desc {
            Some(desc) => " " + extern_desc(desc, None, scope~)
            None => ""
          }
          tasks.push(
            Text(
              "\{pad}(export \{scope.declaration(sort_key(item.sortidx.sort), index)} \{export_name(item.name, scope~)}\{attributes(item.attributes, scope~)} \{sort_ref(item.sortidx, scope~)}\{ascription})\n",
            ),
          )
        }
      id =>
        raise PrintFailure(
          offset,
          "WIT-D003",
          "component section \{id} is outside the component print profile",
        )
    }
  }
  tasks
}

///|
// An instance definition. `opening` is `(instantiate N` or empty for inline
// exports; `items` are its arguments or exports, one per line.
fn instance_text(
  head : String,
  pad : String,
  opening : String,
  items : Array[String],
  compatibility~ : Bool = false,
) -> String {
  if opening.is_empty() {
    if items.is_empty() {
      return head + ")\n"
    }
    let out = StringBuilder()
    out.write_string(head + "\n")
    for item in items {
      out.write_string("\{pad}  \{item}\n")
    }
    out.write_string("\{pad})\n")
    return out.to_string()
  }
  if items.is_empty() {
    return "\{head} \{opening}))\n"
  }
  let out = StringBuilder()
  out.write_string(
    if compatibility {
      "\{head} \{opening}\n"
    } else {
      "\{head}\n\{pad}  \{opening}\n"
    },
  )
  for item in items {
    out.write_string("\{pad}    \{item}\n")
  }
  out.write_string("\{pad}  )\n\{pad})\n")
  out.to_string()
}

///|
fn custom_text(pad : String, payload : Bytes) -> String {
  let mut size = 0
  let mut shift = 0
  let mut position = 0
  while position < payload.length() {
    let byte = payload[position].to_int()
    position += 1
    size = size | ((byte & 0x7f) << shift)
    shift += 7
    if (byte & 0x80) == 0 {
      break
    }
  }
  let name = payload[position:position + size]
  let data = payload[position + size:]
  "\{pad}(@custom \{quote_bytes(name)} \{quote_bytes(data)})\n"
}

///|
/// Print a component binary as one deterministic WAT document.
///
/// The binary must satisfy the declarative component profile of
/// `@binary.validate_declarative_component`, the profile that component
/// verification uses. Core modules print inline through the core-module
/// profile of `print_core_module`. Nested components print inline in binary
/// order. Every failure returns one diagnostic and no document.
/// No operation performs I/O or executes the binary.
pub fn print_component(
  bytes : Bytes,
  source_id~ : String = "<wasm>",
  compatibility~ : Compatibility? = None,
) -> Result[WatDocuments, ReadOnlyArray[Diagnostic]] {
  if compatibility == Some(Wabt) {
    return problem(
      source_id,
      Some(4),
      "WIT-D003",
      "WABT 1.0.42 does not print components",
    )
  }
  if !is_component_header(bytes) {
    if bytes.length() >= 8 && bytes[0:4] == b"\x00asm".exact_view() {
      if bytes[4:8] == b"\x01\x00\x00\x00".exact_view() {
        return problem(
          source_id,
          Some(4),
          "WIT-D003",
          "core-module binaries are outside the component print profile",
        )
      }
    }
    return problem(
      source_id,
      Some(0),
      "WIT-D001",
      "expected a component binary header",
    )
  }
  let validated = match
    @binary.validate_declarative_component(bytes, source_id~) {
    Ok(validated) => validated
    Err(errors) => {
      let error = errors[0]
      let code = match error.code {
        "WIT-B001" => "WIT-D001"
        "WIT-B002" => "WIT-D003"
        _ => "WIT-D002"
      }
      return problem(source_id, error.offset, code, error.message)
    }
  }
  let parser_bytes = validated.parser_bytes()
  // Adapted value descriptors move later sections, so nested offsets are
  // reported only when the retained parser reads the original bytes.
  let base = if parser_bytes == bytes { Some(0) } else { None }
  let text = StringBuilder()
  let root_scope = Scope::new(
    compatibility=compatibility == Some(WasmTools),
    bytes~,
  )
  let root_name = if root_scope.compatibility {
    root_scope.names.root_name().map(n => " " + n).unwrap_or("")
  } else {
    ""
  }
  let work : Array[Task] = [
    Component(
      parser_bytes,
      0,
      base,
      "(component" + root_name + "\n",
      root_scope,
    ),
  ]
  while work.pop() is Some(task) {
    let tasks = match task {
      Text(line) => {
        text.write_string(line)
        continue
      }
      Component(bytes, depth, base, header, scope) => {
        let children = component_tasks(bytes, depth + 1, base, scope~) catch {
          PrintFailure(offset, code, message) =>
            return problem(source_id, offset, code, message)
        }
        if scope.compatibility && children.is_empty() {
          [Text(header.trim_end(chars="\n").to_owned() + ")\n")]
        } else {
          let tasks = [Text(header)]
          tasks.append(children)
          tasks.push(Text("\{indent(depth)})\n"))
          tasks
        }
      }
      ComponentDecls(decls, depth, scope) =>
        component_decl_tasks(decls, depth, scope~) catch {
          PrintFailure(offset, code, message) =>
            return problem(source_id, offset, code, message)
        }
      InstanceDecls(decls, depth, scope) =>
        instance_decl_tasks(decls, depth, scope~) catch {
          PrintFailure(offset, code, message) =>
            return problem(source_id, offset, code, message)
        }
    }
    for i = tasks.length() - 1; i >= 0; i = i - 1 {
      work.push(tasks[i])
    }
  }
  Ok({
    documents: [
      {
        name: "root",
        text: if compatibility == Some(WasmTools) {
          @core_printer.limit_indentation(text.to_string())
        } else {
          text.to_string()
        },
      },
    ],
  })
}

///|
/// Text of a nested component in its original lexical context. Outer aliases
/// are retained, so a fragment must be closed before compiling it standalone.
pub struct ComponentFragment {
  text : String
}

///|
fn render_fragment(bytes : Bytes) -> String raise PrintFailure {
  let text = StringBuilder()
  let work : Array[Task] = [
    Component(bytes, 0, None, "(component\n", Scope::new()),
  ]
  while work.pop() is Some(task) {
    let next = match task {
      Text(line) => {
        text.write_string(line)
        continue
      }
      Component(bytes, depth, base, header, scope) => {
        let next = [Text(header)]
        next.append(component_tasks(bytes, depth + 1, base, scope~))
        next.push(Text("\{indent(depth)})\n"))
        next
      }
      ComponentDecls(decls, depth, scope) =>
        component_decl_tasks(decls, depth, scope~)
      InstanceDecls(decls, depth, scope) =>
        instance_decl_tasks(decls, depth, scope~)
    }
    for i = next.length() - 1; i >= 0; i = i - 1 {
      work.push(next[i])
    }
  }
  text.to_string()
}

///|
/// Print a nested definition after validating the entire containing binary.
/// Each path entry is a component index in its containing component's index
/// space. This returns a contextual fragment, rather than a standalone WAT
/// document. No unvalidated binary is rendered and no operation performs I/O.
pub fn component_fragment(
  bytes : Bytes,
  path : ReadOnlyArray[Int32],
  source_id~ : String = "<wasm>",
) -> Result[ComponentFragment, ReadOnlyArray[Diagnostic]] {
  let validated = match
    @binary.validate_declarative_component(bytes, source_id~) {
    Ok(value) => value
    Err(errors) =>
      return Err(
        errors.map(e => {
          source: e.source,
          offset: e.offset,
          code: match e.code {
            "WIT-B001" => "WIT-D001"
            "WIT-B002" => "WIT-D003"
            _ => "WIT-D002"
          },
          message: e.message,
        }),
      )
  }
  component_fragment_validated(validated, path, source_id~)
}

///|
/// Print a contextual fragment from an immutable validation snapshot. Reusing
/// the snapshot avoids validating a containing binary for every nested entry.
pub fn component_fragment_validated(
  validated : @binary.ValidatedDeclarativeComponent,
  path : ReadOnlyArray[Int32],
  source_id~ : String = "<wasm>",
) -> Result[ComponentFragment, ReadOnlyArray[Diagnostic]] {
  try {
    let mut selected = validated.parser_bytes()
    for wanted in path {
      let binary = parsed(None, () => {
        @component.parse_component_binary(selected)
      })
      let scope = Scope::new()
      let mut child : Bytes? = None
      for section in binary.sections {
        match section.id {
          4 =>
            if scope.take(4) == wanted {
              child = Some(section.payload)
              break
            }
          6 =>
            for
              entry in parsed(None, () => {
                @component.parse_alias_section(section.payload)
              }) {
              ignore(scope.take(sort_key(entry.sort)))
            }
          10 =>
            for
              entry in parsed(None, () => {
                @component.parse_import_section(section.payload)
              }) {
              ignore(scope.take(extern_sort(entry.desc)))
            }
          11 =>
            for
              entry in parsed(None, () => {
                @component.parse_export_section(section.payload)
              }) {
              ignore(scope.take(sort_key(entry.sortidx.sort)))
            }
          _ => ()
        }
      }
      guard child is Some(value) else {
        unsupported(
          "component fragment path does not identify a physical definition",
        )
      }
      selected = value
    }
    Ok({ text: render_fragment(selected), })
  } catch {
    PrintFailure(offset, code, message) =>
      Err([{ source: source_id, offset, code, message, }])
  }
}
