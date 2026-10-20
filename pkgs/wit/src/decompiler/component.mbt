///|
// One unit of printing work. Nested components and component/instance type
// bodies become tasks, so input-controlled nesting never recurses.
priv enum Task {
  Text(String)
  Component(Bytes, Int32, Int32?, String)
  ComponentDecls(Array[@component.ComponentDecl], Int32)
  InstanceDecls(Array[@component.InstanceDecl], Int32)
}

///|
// Index counters for one scope. Component sorts use their binary tags 1..5;
// core sorts use 0x100 plus their core sort byte.
priv struct Scope {
  counts : Map[Int32, Int32]
}

///|
fn Scope::new() -> Scope {
  { counts: Map([]), }
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
fn quote(text : String) -> String {
  quote_bytes(@utf8.encode(text))
}

///|
fn attributes(attributes : Array[@component.NameAttribute]) -> String {
  let out = StringBuilder()
  for attribute in attributes {
    match attribute {
      Implements(value) =>
        out.write_string(" (implements \{quote_bytes(value)})")
      VersionSuffix(value) =>
        out.write_string(" (version-suffix \{quote_bytes(value)})")
      ExternalId(value) =>
        out.write_string(" (external-id \{quote_bytes(value)})")
    }
  }
  out.to_string()
}

///|
fn import_name(name : @component.ImportName) -> String raise PrintFailure {
  match name {
    Plain(bytes) => quote_bytes(bytes)
    WithVersion(_, _) =>
      unsupported("versioned import names are outside the print profile")
  }
}

///|
fn export_name(name : @component.ExportName) -> String raise PrintFailure {
  match name {
    Plain(bytes) => quote_bytes(bytes)
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
fn value_type(type_ : @component.ValType) -> String raise PrintFailure {
  match type_ {
    TypeIdx(index) => index.to_string()
    Prim(prim) => primitive(prim)
  }
}

///|
// Print a non-nesting type definition. Component and instance types are
// handled by `type_tasks`.
fn simple_type(definition : @component.TypeDef) -> String raise PrintFailure {
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
          " (param \{quote(param.label)} \{value_type(param.ty)})",
        )
      }
      if func.result is Some(result) {
        out.write_string(" (result \{value_type(result)})")
      }
      out.write_string(")")
      out.to_string()
    }
    List(element) => "(list \{value_type(element)})"
    FixedList(element, length) => "(list \{value_type(element)} \{length})"
    MapType(key, value) => "(map \{value_type(key)} \{value_type(value)})"
    Record(fields) => {
      let out = StringBuilder()
      out.write_string("(record")
      for field in fields {
        out.write_string(
          " (field \{quote(field.label)} \{value_type(field.ty)})",
        )
      }
      out.write_string(")")
      out.to_string()
    }
    Variant(cases) => {
      let out = StringBuilder()
      out.write_string("(variant")
      for case_ in cases {
        out.write_string(" (case \{quote(case_.label)}")
        if case_.ty is Some(payload) {
          out.write_string(" \{value_type(payload)}")
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
        out.write_string(" \{value_type(type_)}")
      }
      out.write_string(")")
      out.to_string()
    }
    Flags(names) | Enum(names) => {
      let out = StringBuilder()
      out.write_string(if definition is Flags(_) { "(flags" } else { "(enum" })
      for name in names {
        out.write_string(" \{quote(name)}")
      }
      out.write_string(")")
      out.to_string()
    }
    Option(type_) => "(option \{value_type(type_)})"
    Result(ok, error) => {
      let out = StringBuilder()
      out.write_string("(result")
      if ok is Some(type_) {
        out.write_string(" \{value_type(type_)}")
      }
      if error is Some(type_) {
        out.write_string(" (error \{value_type(type_)})")
      }
      out.write_string(")")
      out.to_string()
    }
    Own(index) => "(own \{index})"
    Borrow(index) => "(borrow \{index})"
    Stream(Some(type_)) => "(stream \{value_type(type_)})"
    Stream(None) => "(stream)"
    Future(Some(type_)) => "(future \{value_type(type_)})"
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
        Some(index) => "(resource (rep \{rep}) (dtor (func \{index})))"
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
) -> Unit raise PrintFailure {
  let pad = indent(depth)
  match definition {
    ComponentType(decls) => {
      tasks.push(Text("\{pad}(type (;\{index};)\n\{pad}  (component\n"))
      tasks.push(ComponentDecls(decls, depth + 2))
      tasks.push(Text("\{pad}  )\n\{pad})\n"))
    }
    InstanceType(decls) => {
      tasks.push(Text("\{pad}(type (;\{index};)\n\{pad}  (instance\n"))
      tasks.push(InstanceDecls(decls, depth + 2))
      tasks.push(Text("\{pad}  )\n\{pad})\n"))
    }
    _ =>
      tasks.push(Text("\{pad}(type (;\{index};) \{simple_type(definition)})\n"))
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
) -> String raise PrintFailure {
  let comment = match index {
    Some(index) => " (;\{index};)"
    None => ""
  }
  match desc {
    CoreModuleType(type_) => "(core module\{comment} (type \{type_}))"
    FuncType(type_) => "(func\{comment} (type \{type_}))"
    Value(Type(type_)) => "(value\{comment} \{value_type(type_)})"
    Value(Eq(value)) => "(value\{comment} (eq \{value}))"
    Type(Eq(type_)) => "(type\{comment} (eq \{type_}))"
    Type(SubResource) => "(type\{comment} (sub resource))"
    ComponentType(type_) => "(component\{comment} (type \{type_}))"
    InstanceType(type_) => "(instance\{comment} (type \{type_}))"
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
  "\{pad}(alias outer \{count} \{target} (\{sort_name(kind)} (;\{index};)))\n"
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
  "\{pad}(alias \{target} \{instance} \{quote(name)} (\{sort_name(kind)} (;\{index};)))\n"
}

///|
fn component_decl_tasks(
  decls : Array[@component.ComponentDecl],
  depth : Int32,
) -> Array[Task] raise PrintFailure {
  let tasks : Array[Task] = []
  let scope = Scope::new()
  let pad = indent(depth)
  for decl in decls {
    match decl {
      CoreType(bytes) =>
        tasks.push(Text(core_type_text(bytes, depth, scope.take(0x110))))
      Type(definition) => type_tasks(tasks, depth, scope.take(3), definition)
      AliasOuter(kind, count, target) =>
        tasks.push(Text(outer_alias(pad, kind, count, target, scope)))
      AliasInstanceExport(kind, instance, name) =>
        tasks.push(Text(export_alias(pad, false, kind, instance, name, scope)))
      Import(name, attrs, desc) => {
        let index = scope.take(extern_sort(desc))
        tasks.push(
          Text(
            "\{pad}(import \{quote(name)}\{attributes(attrs)} \{extern_desc(desc, Some(index))})\n",
          ),
        )
      }
      Export(name, attrs, desc) => {
        let index = scope.take(extern_sort(desc))
        tasks.push(
          Text(
            "\{pad}(export \{quote(name)}\{attributes(attrs)} \{extern_desc(desc, Some(index))})\n",
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
) -> Array[Task] raise PrintFailure {
  let tasks : Array[Task] = []
  let scope = Scope::new()
  let pad = indent(depth)
  for decl in decls {
    match decl {
      CoreType(bytes) =>
        tasks.push(Text(core_type_text(bytes, depth, scope.take(0x110))))
      Type(definition) => type_tasks(tasks, depth, scope.take(3), definition)
      AliasOuter(kind, count, target) =>
        tasks.push(Text(outer_alias(pad, kind, count, target, scope)))
      AliasInstanceExport(kind, instance, name) =>
        tasks.push(Text(export_alias(pad, false, kind, instance, name, scope)))
      Export(name, attrs, desc) => {
        let index = scope.take(extern_sort(desc))
        tasks.push(
          Text(
            "\{pad}(export \{quote(name)}\{attributes(attrs)} \{extern_desc(desc, Some(index))})\n",
          ),
        )
      }
    }
  }
  tasks
}

///|
fn sort_ref(sort_index : @component.SortIdx) -> String raise PrintFailure {
  "(\{sort_name(sort_key(sort_index.sort))} \{sort_index.idx})"
}

///|
fn core_sort_ref(sort_index : @component.SortIdx) -> String raise PrintFailure {
  "(\{core_sort_name(sort_key(sort_index.sort))} \{sort_index.idx})"
}

///|
fn canon_options(options : Array[@component.CanonOpt]) -> String {
  let out = StringBuilder()
  for option in options {
    out.write_string(
      match option {
        StringEncoding(Utf8) => " string-encoding=utf8"
        StringEncoding(Utf16) => " string-encoding=utf16"
        StringEncoding(Latin1Utf16) => " string-encoding=latin1+utf16"
        Memory(index) => " (memory \{index})"
        Realloc(index) => " (realloc \{index})"
        PostReturn(index) => " (post-return \{index})"
        CoreType(index) => " (core-type \{index})"
        Gc => " gc"
        Async => " async"
        Callback(index) => " (callback \{index})"
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
fn canon_body(canon : @component.Canon) -> String raise PrintFailure {
  match canon {
    Lift(_, _, _) => unsupported("lift produces a component function")
    Lower(func, options) => "lower (func \{func})\{canon_options(options)}"
    BackpressureInc => "backpressure.inc"
    BackpressureDec => "backpressure.dec"
    ContextGet(type_, index) => "context.get \{core_value_type(type_)} \{index}"
    ContextSet(type_, index) => "context.set \{core_value_type(type_)} \{index}"
    TaskReturn(result, options) => {
      let result = match result {
        Some(type_) => " (result \{value_type(type_)})"
        None => ""
      }
      "task.return\{result}\{canon_options(options)}"
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
      "waitable-set.wait\{flag(cancellable, "cancellable")} (memory \{memory})"
    WaitableSetPoll(cancellable, memory) =>
      "waitable-set.poll\{flag(cancellable, "cancellable")} (memory \{memory})"
    WaitableSetDrop => "waitable-set.drop"
    WaitableJoin => "waitable.join"
    SubtaskCancel(is_async) => "subtask.cancel" + flag(is_async, "async")
    SubtaskDrop => "subtask.drop"
    StreamNew(type_) => "stream.new \{type_}"
    StreamRead(type_, options) =>
      "stream.read \{type_}\{canon_options(options)}"
    StreamWrite(type_, options) =>
      "stream.write \{type_}\{canon_options(options)}"
    StreamCancelRead(type_, is_async) =>
      "stream.cancel-read \{type_}" + flag(is_async, "async")
    StreamCancelWrite(type_, is_async) =>
      "stream.cancel-write \{type_}" + flag(is_async, "async")
    StreamDropReadable(type_) => "stream.drop-readable \{type_}"
    StreamDropWritable(type_) => "stream.drop-writable \{type_}"
    FutureNew(type_) => "future.new \{type_}"
    FutureRead(type_, options) =>
      "future.read \{type_}\{canon_options(options)}"
    FutureWrite(type_, options) =>
      "future.write \{type_}\{canon_options(options)}"
    FutureCancelRead(type_, is_async) =>
      "future.cancel-read \{type_}" + flag(is_async, "async")
    FutureCancelWrite(type_, is_async) =>
      "future.cancel-write \{type_}" + flag(is_async, "async")
    FutureDropReadable(type_) => "future.drop-readable \{type_}"
    FutureDropWritable(type_) => "future.drop-writable \{type_}"
    ErrorContextNew(options) => "error-context.new\{canon_options(options)}"
    ErrorContextDebugMessage(options) =>
      "error-context.debug-message\{canon_options(options)}"
    ErrorContextDrop => "error-context.drop"
    ResourceNew(type_) => "resource.new \{type_}"
    ResourceDrop(type_) => "resource.drop \{type_}"
    ResourceRep(type_) => "resource.rep \{type_}"
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
) -> Array[Task] raise PrintFailure {
  let binary = parsed(base, () => @component.parse_component_binary(bytes))
  let offsets = payload_offsets(bytes)
  let tasks : Array[Task] = []
  let scope = Scope::new()
  let pad = indent(depth)
  for i, section in binary.sections {
    let payload = section.payload
    let offset = if base is Some(base) && i < offsets.length() {
      Some(base + offsets[i])
    } else {
      None
    }
    match section.id {
      0 => tasks.push(Text(custom_text(pad, payload)))
      1 => {
        let index = scope.take(0x111)
        let text = render_core_module(payload, offset)
        let lines = text.split("\n").to_array()
        let out = StringBuilder()
        for line in lines {
          if line.is_empty() {
            continue
          }
          if line == "(module" {
            out.write_string("\{pad}(core module (;\{index};)\n")
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
          let head = "\{pad}(core instance (;\{index};)"
          match instance.expr {
            Instantiate(module_, args) =>
              tasks.push(
                Text(
                  instance_text(
                    head,
                    pad,
                    "(instantiate \{module_}",
                    args.map(arg => {
                      "(with \{quote(arg.name)} \{core_sort_ref(arg.sortidx)})"
                    }),
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
                      "(export \{quote(item.name)} \{core_sort_ref(item.sortidx)})"
                    }),
                  ),
                ),
              )
          }
        }
      3 =>
        for entry in core_type_entries(payload, offset) {
          tasks.push(Text(core_type_text(entry, depth, scope.take(0x110))))
        }
      4 => {
        let index = scope.take(4)
        tasks.push(
          Component(payload, depth, offset, "\{pad}(component (;\{index};)\n"),
        )
      }
      5 =>
        for
          instance in parsed(offset, () => {
            @component.parse_instance_section(payload)
          }) {
          let index = scope.take(5)
          let head = "\{pad}(instance (;\{index};)"
          match instance.expr {
            Instantiate(component, args) =>
              tasks.push(
                Text(
                  instance_text(
                    head,
                    pad,
                    "(instantiate \{component}",
                    args.map(arg => {
                      "(with \{quote(arg.name)} \{sort_ref(arg.sortidx)})"
                    }),
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
                      "(export \{quote(item.name)}\{attributes(item.attributes)} \{sort_ref(item.sortidx)})"
                    }),
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
          type_tasks(tasks, depth, scope.take(3), definition)
        }
      8 =>
        for
          canon in parsed(offset, () => @component.parse_canon_section(payload)) {
          match canon {
            Lift(core_func, options, type_) => {
              let index = scope.take(1)
              tasks.push(
                Text(
                  "\{pad}(func (;\{index};) (type \{type_}) (canon lift (core func \{core_func})\{canon_options(options)}))\n",
                ),
              )
            }
            _ => {
              let index = scope.take(0x100)
              tasks.push(
                Text(
                  "\{pad}(core func (;\{index};) (canon \{canon_body(canon)}))\n",
                ),
              )
            }
          }
        }
      9 => {
        let start = parsed(offset, () => @component.parse_start_section(payload))
        let out = StringBuilder()
        out.write_string("\{pad}(start \{start.func_idx}")
        for arg in start.args {
          out.write_string(" (value \{arg})")
        }
        out.write_string(" (result \{start.results}))\n")
        for _ in 0..<start.results {
          ignore(scope.take(2))
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
              "\{pad}(import \{import_name(import_.name)}\{attributes(import_.attributes)} \{extern_desc(import_.desc, Some(index))})\n",
            ),
          )
        }
      11 =>
        for
          item in parsed(offset, () => @component.parse_export_section(payload)) {
          let index = scope.take(sort_key(item.sortidx.sort))
          let ascription = match item.desc {
            Some(desc) => " " + extern_desc(desc, None)
            None => ""
          }
          tasks.push(
            Text(
              "\{pad}(export (;\{index};) \{export_name(item.name)}\{attributes(item.attributes)} \{sort_ref(item.sortidx)}\{ascription})\n",
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
  out.write_string("\{head}\n\{pad}  \{opening}\n")
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
) -> Result[WatDocuments, ReadOnlyArray[Diagnostic]] {
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
  let work : Array[Task] = [Component(parser_bytes, 0, base, "(component\n")]
  while work.pop() is Some(task) {
    let tasks = match task {
      Text(line) => {
        text.write_string(line)
        continue
      }
      Component(bytes, depth, base, header) => {
        let tasks = [Text(header)]
        tasks.append(
          component_tasks(bytes, depth + 1, base) catch {
            PrintFailure(offset, code, message) =>
              return problem(source_id, offset, code, message)
          },
        )
        tasks.push(Text("\{indent(depth)})\n"))
        tasks
      }
      ComponentDecls(decls, depth) =>
        component_decl_tasks(decls, depth) catch {
          PrintFailure(offset, code, message) =>
            return problem(source_id, offset, code, message)
        }
      InstanceDecls(decls, depth) =>
        instance_decl_tasks(decls, depth) catch {
          PrintFailure(offset, code, message) =>
            return problem(source_id, offset, code, message)
        }
    }
    for i = tasks.length() - 1; i >= 0; i = i - 1 {
      work.push(tasks[i])
    }
  }
  Ok({ documents: [{ name: "root", text: text.to_string(), }], })
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
  let work : Array[Task] = [Component(bytes, 0, None, "(component\n")]
  while work.pop() is Some(task) {
    let next = match task {
      Text(line) => {
        text.write_string(line)
        continue
      }
      Component(bytes, depth, base, header) => {
        let next = [Text(header)]
        next.append(component_tasks(bytes, depth + 1, base))
        next.push(Text("\{indent(depth)})\n"))
        next
      }
      ComponentDecls(decls, depth) => component_decl_tasks(decls, depth)
      InstanceDecls(decls, depth) => instance_decl_tasks(decls, depth)
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
