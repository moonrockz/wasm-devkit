// Retained from Milky2018/wasm_component@0.16.0; local formatting changes.
// Modified by wasm-devkit: validate accessor and async-constructor contracts.

///|
fn parse_core_type_module_exports(
  r : CoreTypeReader,
  max_outer_depth : Int32,
  current_core_type_bound : Int32,
  outer_core_type_bounds : Array[Int32],
) -> Map[String, Int32] raise ComponentValidationError {
  let ndecls = r.read_leb_u32()
  let exports : Map[String, Int32] = Map([])
  let seen_imports : Map[(String, String), Int32] = Map([])
  let mut func_type_bound = 0
  for _i in 0..<ndecls {
    let tag = r.read_u8()
    match tag {
      0x00 => {
        let mod_name = r.read_name_ascii()
        let name = r.read_name_ascii()
        let mod_s = match mod_name {
          Some(s) => s
          None => ""
        }
        let name_s = match name {
          Some(s) => s
          None => ""
        }
        let key = (mod_s, name_s)
        if seen_imports.get(key) is Some(_) {
          raise SectionParseError(3, "duplicate import name")
        }
        seen_imports.set(key, 1)
        let kind = r.read_u8()
        r.validate_extern_type(kind, func_type_bound)
      }
      0x01 => func_type_bound += r.skip_heap_group()
      0x02 => {
        // Alias declarations inside module types, e.g.:
        //   (alias outer $C $t (type $u))
        // We only skip the encoding here since export-kind validation doesn't
        // depend on it.
        let sort = r.read_u8()
        // Module-type extern kinds (func/tag) reference the module type's own
        // function-type index space. Both inline function type declarations and
        // aliases of core types introduce new indices.
        if sort == 0x10 {
          func_type_bound += 1
        }
        let target_tag = r.read_u8()
        match target_tag {
          0x01 => {
            let depth = r.read_leb_u32()
            let idx = r.read_leb_u32()
            if max_outer_depth >= 0 {
              if depth > max_outer_depth {
                raise SectionParseError(3, "outer alias depth out of bounds")
              }
              if sort == 0x10 {
                let bound = if depth == 0 {
                  func_type_bound - 1
                } else if depth == 1 {
                  current_core_type_bound
                } else if depth - 2 < outer_core_type_bounds.length() {
                  outer_core_type_bounds[depth - 2]
                } else {
                  raise SectionParseError(3, "outer alias depth out of bounds")
                }
                if idx < 0 || idx >= bound {
                  raise SectionParseError(3, "type index out of bounds")
                }
              }
            }
          }
          _ =>
            raise SectionParseError(
              3,
              "unknown module alias target: \{target_tag}",
            )
        }
      }
      0x03 => {
        let name = r.read_name_ascii()
        let kind = r.read_u8()
        r.validate_extern_type(kind, func_type_bound)
        match name {
          Some(s) =>
            if exports.get(s) is Some(_) {
              raise SectionParseError(3, "duplicate export name")
            } else {
              exports.set(s, kind)
            }
          None => ()
        }
      }
      _ => raise SectionParseError(3, "unknown module type decl tag: \{tag}")
    }
  }
  exports
}

///|
fn parse_core_type_section(
  payload : Bytes,
  max_outer_depth : Int32,
  base_core_type_bound : Int32,
  outer_core_type_bounds : Array[Int32],
) -> Array[Map[String, Int32]?] raise ComponentValidationError {
  let r = CoreTypeReader::CoreTypeReader(payload)
  let n = r.read_leb_u32()
  let out : Array[Map[String, Int32]?] = []
  for _ in 0..<n {
    let op = r.read_u8()
    if op == 0x50 {
      out.push(
        Some(
          parse_core_type_module_exports(
            r,
            max_outer_depth,
            base_core_type_bound + out.length(),
            outer_core_type_bounds,
          ),
        ),
      )
    } else {
      r.pos -= 1
      let count = r.skip_core_declaration()
      for _ in 0..<count {
        out.push(None)
      }
    }
  }
  if !r.is_eof() {
    raise SectionParseError(3, "trailing bytes in core type section")
  }
  out
}

///|
fn parse_core_type_section_module_sigs(
  payload : Bytes,
  max_outer_depth : Int32,
  base_core_type_bound : Int32,
  outer_core_type_bounds : Array[Int32],
) -> (Array[Array[CoreModuleTypeImport]?], Array[Map[String, CoreExternType]?]) raise ComponentValidationError {
  let r = CoreTypeReader::CoreTypeReader(payload)
  let n = r.read_leb_u32()
  let imports : Array[Array[CoreModuleTypeImport]?] = []
  let export_types : Array[Map[String, CoreExternType]?] = []
  for _ in 0..<n {
    let op = r.read_u8()
    if op == 0x50 {
      let (imps, exps) = parse_core_type_module_sig(
        r,
        max_outer_depth,
        base_core_type_bound + imports.length(),
        outer_core_type_bounds,
      )
      imports.push(Some(imps))
      export_types.push(Some(exps))
    } else {
      r.pos -= 1
      let count = r.skip_core_declaration()
      for _ in 0..<count {
        imports.push(None)
        export_types.push(None)
      }
    }
  }
  if !r.is_eof() {
    raise SectionParseError(3, "trailing bytes in core type section")
  }
  (imports, export_types)
}

///|
fn validate_single_core_type(
  payload : Bytes,
  current_core_type_bound : Int32,
  outer_core_type_bounds : Array[Int32],
) -> Array[Map[String, Int32]?] raise ComponentValidationError {
  let r = CoreTypeReader::CoreTypeReader(payload)
  let op = r.read_u8()
  // For module-type aliases, `depth` counts outward from the module:
  // depth 0/1 target the current component core-type index space; depth >= 2
  // targets outer component environments.
  let max_outer_depth = outer_core_type_bounds.length() + 1
  let exports : Array[Map[String, Int32]?] = []
  if op == 0x50 {
    exports.push(
      Some(
        parse_core_type_module_exports(
          r, max_outer_depth, current_core_type_bound, outer_core_type_bounds,
        ),
      ),
    )
  } else {
    r.pos -= 1
    let count = r.skip_core_declaration()
    for _ in 0..<count {
      exports.push(None)
    }
  }
  if !r.is_eof() {
    raise SectionParseError(3, "trailing bytes in core type payload")
  }
  exports
}

///|
fn validate_import_name(
  name : @component.ImportName,
  cfg : ComponentValidationConfig,
) -> Unit raise ComponentValidationError {
  if !cfg.wit_names {
    return
  }
  match name {
    Plain(bytes) => validate_import_name_bytes(bytes)
    WithVersion(bytes, _vs) => validate_import_name_bytes(bytes)
  }
}

///|
fn validate_export_name(
  name : @component.ExportName,
  cfg : ComponentValidationConfig,
) -> Unit raise ComponentValidationError {
  if !cfg.wit_names {
    return
  }
  match name {
    Plain(bytes) => validate_name_bytes(bytes)
    WithVersion(bytes, _vs) => validate_name_bytes(bytes)
  }
}

///|
fn importname_to_string(name : @component.ImportName) -> String? {
  match name {
    Plain(bytes) => ascii_bytes_to_string(bytes)
    WithVersion(bytes, _vs) => ascii_bytes_to_string(bytes)
  }
}

///|
fn exportname_to_string(name : @component.ExportName) -> String? {
  match name {
    Plain(bytes) => ascii_bytes_to_string(bytes)
    WithVersion(bytes, _vs) => ascii_bytes_to_string(bytes)
  }
}

///|
fn importname_to_bytes(name : @component.ImportName) -> Bytes {
  match name {
    Plain(bytes) | WithVersion(bytes, _) => bytes
  }
}

///|
fn exportname_to_bytes(name : @component.ExportName) -> Bytes {
  match name {
    Plain(bytes) | WithVersion(bytes, _) => bytes
  }
}

///|
fn utf8_bytes_of_string(s : String) -> Bytes {
  let bytes : Array[Byte] = []
  for c in s {
    let cp = c.to_int()
    if cp < 0x80 {
      bytes.push(cp.to_byte())
    } else if cp < 0x800 {
      bytes.push((0xC0 | (cp >> 6)).to_byte())
      bytes.push((0x80 | (cp & 0x3F)).to_byte())
    } else if cp < 0x10000 {
      bytes.push((0xE0 | (cp >> 12)).to_byte())
      bytes.push((0x80 | ((cp >> 6) & 0x3F)).to_byte())
      bytes.push((0x80 | (cp & 0x3F)).to_byte())
    } else {
      bytes.push((0xF0 | (cp >> 18)).to_byte())
      bytes.push((0x80 | ((cp >> 12) & 0x3F)).to_byte())
      bytes.push((0x80 | ((cp >> 6) & 0x3F)).to_byte())
      bytes.push((0x80 | (cp & 0x3F)).to_byte())
    }
  }
  Bytes::from_array(bytes)
}

///|
fn validate_name_attributes(
  section : Int32,
  name : Bytes,
  attributes : Array[@component.NameAttribute],
  sort : @component.Sort,
  cfg : ComponentValidationConfig,
) -> Unit raise ComponentValidationError {
  let mut has_implements = false
  let mut suffix : Bytes? = None
  let mut interface_name = name
  let mut has_external_id = false
  for attribute in attributes {
    let bytes = match attribute {
      Implements(bytes) | VersionSuffix(bytes) | ExternalId(bytes) => bytes
    }
    (@utf8.decode(bytes, ignore_bom=false) |> ignore) catch {
      _ => raise SectionParseError(section, "name attribute is not UTF-8")
    }
    match attribute {
      Implements(implemented) => {
        if !cfg.component_implements {
          raise SectionParseError(
            section, "the `cm-implements` feature is not active",
          )
        }
        if has_implements {
          raise SectionParseError(section, "duplicate `implements` attribute")
        }
        has_implements = true
        if !(sort is Instance) {
          raise SectionParseError(
            section, "only instances can have an `implements`",
          )
        }
        if !is_kebab_case(name) {
          raise SectionParseError(
            section, "name is not valid with `implements`",
          )
        }
        interface_name = implemented
        if interface_name.length() == 0 {
          raise SectionParseError(section, "not a valid name")
        }
        if !is_package_name(interface_name) {
          raise SectionParseError(
            section, "`implements` value must be an interface",
          )
        }
      }
      VersionSuffix(version) => {
        if suffix is Some(_) {
          raise SectionParseError(
            section, "duplicate `version-suffix` attribute",
          )
        }
        if !(sort is Instance) {
          raise SectionParseError(
            section, "only instances can have a `version-suffix`",
          )
        }
        suffix = Some(version)
      }
      ExternalId(_) => {
        if has_external_id {
          raise SectionParseError(section, "duplicate `external-id` attribute")
        }
        has_external_id = true
      }
    }
  }
  if !cfg.canonical_version_suffix && has_implements {
    return
  }
  let is_interface = is_package_name(interface_name)
  if cfg.canonical_version_suffix && suffix is Some(_) && !is_interface {
    raise SectionParseError(section, "invalid version suffix")
  }
  if !is_interface {
    return
  }
  let mut at = -1
  for i in 0..<interface_name.length() {
    if interface_name[i] == 0x40 {
      at = i
      break
    }
  }
  if at < 0 {
    if cfg.canonical_version_suffix && suffix is Some(_) {
      raise SectionParseError(section, "invalid version suffix")
    }
    return
  }
  let merged : Array[Byte] = []
  for i in (at + 1)..<interface_name.length() {
    merged.push(interface_name[i])
  }
  let prefix_length = merged.length()
  if suffix is Some(bytes) {
    for byte in bytes {
      merged.push(byte)
    }
  }
  let full = Bytes::from_array(merged)
  if !is_semver_range(full, 0, full.length()) {
    raise SectionParseError(section, "invalid interface version")
  }
  if cfg.canonical_version_suffix && suffix is Some(bytes) {
    if bytes.length() == 0 {
      raise SectionParseError(section, "invalid version suffix")
    }
    let mut first_dot = -1
    let mut second_dot = -1
    let mut build = full.length()
    let mut prerelease = false
    for i in 0..<full.length() {
      if full[i] == 0x2b {
        build = i
        break
      }
      if full[i] == 0x2d {
        prerelease = true
      }
      if full[i] == 0x2e && first_dot < 0 {
        first_dot = i
      } else if full[i] == 0x2e && second_dot < 0 {
        second_dot = i
      }
    }
    let canonical = if !prerelease && !(first_dot == 1 && full[0] == 0x30) {
      first_dot
    } else if !prerelease &&
      !(second_dot - first_dot == 2 && full[first_dot + 1] == 0x30) {
      second_dot
    } else {
      build
    }
    if prefix_length != canonical {
      raise SectionParseError(section, "invalid version suffix")
    }
  }
}

///|
fn validate_name_attributes_string(
  section : Int32,
  name : String,
  attributes : Array[@component.NameAttribute],
  sort : @component.Sort,
  cfg : ComponentValidationConfig,
) -> Unit raise ComponentValidationError {
  validate_name_attributes(
    section,
    utf8_bytes_of_string(name),
    attributes,
    sort,
    cfg,
  )
}

///|
fn ascii_lower_key(s : String) -> String {
  let buf = StringBuilder::StringBuilder()
  for c in s {
    let n = c.to_int()
    if n >= 0x41 && n <= 0x5A {
      // ASCII A-Z -> a-z
      buf.write_char((n + 0x20).unsafe_to_char())
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
fn wit_name_conflict_base(name : String) -> String {
  fn parse_resource_prefix(name : String, prefix_len : Int32) -> String {
    let buf = StringBuilder::StringBuilder()
    let mut i = 0
    let mut saw_dot = false
    let mut after_dot = false
    for c in name {
      if i < prefix_len {
        i += 1
        continue
      }
      if c == '.' {
        saw_dot = true
        after_dot = true
        continue
      }
      if after_dot {
        buf.write_char(c)
      }
    }
    if saw_dot {
      buf.to_string()
    } else {
      name
    }
  }

  if name.has_prefix("[method]") {
    parse_resource_prefix(name, 8)
  } else if name.has_prefix("[static]") {
    parse_resource_prefix(name, 8)
  } else {
    name
  }
}

///|
fn wit_conflict_key(name : String) -> String {
  let base = wit_name_conflict_base(name)
  // Names with embedded opaque payloads (base64/url) are case-sensitive.
  if base.has_prefix("integrity=<") ||
    base.has_prefix("locked-dep=") ||
    base.has_prefix("unlocked-dep=") ||
    base.has_prefix("url=") {
    base
  } else {
    ascii_lower_key(base)
  }
}

///|
fn validate_extern_name_string(
  name : String,
  cfg : ComponentValidationConfig,
) -> Unit raise ComponentValidationError {
  if !cfg.wit_names {
    return
  }
  // Component type section names are decoded as UTF-8 strings by the parser.
  // For now we only validate ASCII-compatible names to match the wasm-tools
  // component-spec suite.
  let bytes : Array[Byte] = []
  for c in name {
    let cp = c.to_int()
    if cp < 0 || cp > 0x7f {
      raise InvalidKebabName(name)
    }
    bytes.push(cp.to_byte())
  }
  validate_name_bytes(Bytes::from_array(bytes))
}

///|
priv enum BracketResourceKind {
  Constructor
  Method
  Static
}

///|
priv struct BracketResourceName {
  kind : BracketResourceKind
  resource : String
}

///|
fn parse_bracket_resource_name(name : String) -> BracketResourceName? {
  if !name.has_prefix("[") {
    return None
  }
  let prefix = StringBuilder::StringBuilder()
  let suffix = StringBuilder::StringBuilder()
  let mut in_prefix = true
  let mut saw_close = false
  let mut i = 0
  for c in name {
    if i == 0 {
      i += 1
      continue
    }
    if in_prefix {
      if c == ']' {
        in_prefix = false
        saw_close = true
      } else {
        prefix.write_char(c)
      }
    } else {
      suffix.write_char(c)
    }
    i += 1
  }
  if !saw_close {
    return None
  }
  let p = prefix.to_string()
  let raw_suffix = suffix.to_string()
  let s = if (p == "method" || p == "static") &&
    (raw_suffix.has_prefix("[get]") || raw_suffix.has_prefix("[set]")) {
    raw_suffix[5:].to_owned()
  } else {
    raw_suffix
  }
  if p == "constructor" {
    return Some({ kind: Constructor, resource: s, })
  }
  if p == "method" || p == "static" {
    let res = StringBuilder::StringBuilder()
    let mut after_dot = false
    for c in s {
      if c == '.' && !after_dot {
        after_dot = true
        continue
      }
      if !after_dot {
        res.write_char(c)
      }
    }
    let kind = if p == "method" { Method } else { Static }
    return Some({ kind, resource: res.to_string(), })
  }
  None
}

///|
fn own_target_of_valtype(
  ty : @component.ValType,
  type_table : Array[@component.TypeDef?],
) -> Int32? {
  match ty {
    TypeIdx(idx) =>
      if idx >= 0 && idx < type_table.length() {
        match type_table[idx] {
          Some(Own(t)) => Some(t)
          _ => None
        }
      } else {
        None
      }
    _ => None
  }
}

///|
fn borrow_target_of_valtype(
  ty : @component.ValType,
  type_table : Array[@component.TypeDef?],
) -> Int32? {
  match ty {
    TypeIdx(idx) =>
      if idx >= 0 && idx < type_table.length() {
        match type_table[idx] {
          Some(Borrow(t)) => Some(t)
          _ => None
        }
      } else {
        None
      }
    _ => None
  }
}

///|
fn validate_bracketed_func_name(
  section : Int32,
  name : String,
  ft : @component.FuncType,
  type_table : Array[@component.TypeDef?],
  resource_ids : Array[Int32?],
  known_resources : Map[String, Int32],
) -> Unit raise ComponentValidationError {
  validate_accessor_function(section, name, ft, type_table)
  let br = parse_bracket_resource_name(name)
  if br is Some(info) && info.kind is Constructor && ft.is_async {
    raise SectionParseError(section, "constructor cannot be async")
  }
  match br {
    None => ()
    Some(info) =>
      match known_resources.get(info.resource) {
        None =>
          raise SectionParseError(
            section, "resource used in function does not have a name in this context",
          )
        Some(expected_tyidx) =>
          match info.kind {
            Constructor =>
              match ft.result {
                None =>
                  raise SectionParseError(
                    section, "constructor must return a value",
                  )
                Some(r) => {
                  // Accept `(own $T)` or `(result (own $T) ...)`.
                  let ok = match own_target_of_valtype(r, type_table) {
                    Some(t) =>
                      type_sig_of_typeidx(t, type_table, resource_ids) ==
                      type_sig_of_typeidx(
                        expected_tyidx, type_table, resource_ids,
                      )
                    None =>
                      match r {
                        TypeIdx(idx) =>
                          if idx >= 0 && idx < type_table.length() {
                            match type_table[idx] {
                              Some(Result(ok, _err)) =>
                                match ok {
                                  Some(v) =>
                                    match own_target_of_valtype(v, type_table) {
                                      Some(t) =>
                                        type_sig_of_typeidx(
                                          t, type_table, resource_ids,
                                        ) ==
                                        type_sig_of_typeidx(
                                          expected_tyidx, type_table, resource_ids,
                                        )
                                      None => false
                                    }
                                  None => false
                                }
                              _ => false
                            }
                          } else {
                            false
                          }
                        _ => false
                      }
                  }
                  if !ok {
                    raise SectionParseError(
                      section, "constructor does not match resource",
                    )
                  }
                }
              }
            Method => {
              if ft.params.length() == 0 {
                raise SectionParseError(section, "method must take `self`")
              }
              let first = ft.params[0]
              if first.label != "self" {
                raise SectionParseError(section, "method must take `self`")
              }
              match borrow_target_of_valtype(first.ty, type_table) {
                Some(t) =>
                  if type_sig_of_typeidx(t, type_table, resource_ids) !=
                    type_sig_of_typeidx(
                      expected_tyidx, type_table, resource_ids,
                    ) {
                    raise SectionParseError(
                      section, "method does not match resource",
                    )
                  }
                None =>
                  raise SectionParseError(section, "method must take `borrow`")
              }
            }
            Static => ()
          }
      }
  }
}

///|
fn valtype_uses_disallowed_resources(
  ty : @component.ValType,
  type_table : Array[@component.TypeDef?],
  allowed_resource_type_idxs : Map[Int32, Int32],
  visiting : Map[Int32, Int32],
) -> Bool {
  let work : Array[@component.ValType] = [ty]
  while work.pop() is Some(value) {
    guard value is TypeIdx(idx) else { continue }
    if idx < 0 || idx >= type_table.length() || visiting.contains(idx) {
      continue
    }
    visiting[idx] = 1
    match type_table[idx] {
      Some(Own(target)) | Some(Borrow(target)) =>
        if !allowed_resource_type_idxs.contains(target) {
          return true
        }
      Some(Tuple(values)) => work.append(values)
      Some(Record(fields)) =>
        for field in fields {
          work.push(field.ty)
        }
      Some(Variant(cases)) =>
        for item in cases {
          if item.ty is Some(value) {
            work.push(value)
          }
        }
      Some(Option(value)) | Some(List(value)) | Some(FixedList(value, _)) =>
        work.push(value)
      Some(MapType(key, value)) => {
        work.push(key)
        work.push(value)
      }
      Some(Result(ok, error)) => {
        if ok is Some(value) {
          work.push(value)
        }
        if error is Some(value) {
          work.push(value)
        }
      }
      Some(Stream(value)) | Some(Future(value)) =>
        if value is Some(value) {
          work.push(value)
        }
      _ => ()
    }
  }
  false
}

///|
fn functype_uses_disallowed_resources(
  ft : @component.FuncType,
  type_table : Array[@component.TypeDef?],
  allowed_resource_type_idxs : Map[Int32, Int32],
) -> Bool {
  let visiting : Map[Int32, Int32] = Map([])
  for p in ft.params {
    if valtype_uses_disallowed_resources(
        p.ty,
        type_table,
        allowed_resource_type_idxs,
        visiting,
      ) {
      return true
    }
  }
  match ft.result {
    None => false
    Some(r) =>
      valtype_uses_disallowed_resources(
        r, type_table, allowed_resource_type_idxs, visiting,
      )
  }
}

///|
fn funcsig_of_functype(
  ft : @component.FuncType,
  type_table : Array[@component.TypeDef?],
  resource_ids : Array[Int32?],
) -> FuncSigShape {
  let visiting : Map[Int32, Int32] = Map([])
  let params : Array[ParamShape] = []
  for p in ft.params {
    params.push({
      name: p.label,
      ty: type_sig_of_valtype(p.ty, type_table, resource_ids, visiting),
    })
  }
  let result : TypeSig? = match ft.result {
    Some(v) => Some(type_sig_of_valtype(v, type_table, resource_ids, visiting))
    None => None
  }
  {
    params,
    result,
    complete: complete_function_signature(ft, [], [], type_table, resource_ids),
  }
}

///|
fn type_sig_of_typedef_lg(
  td : @component.TypeDef,
  local_types : Array[@component.TypeDef],
  local_resource_ids : Array[Int32?],
  global_types : Array[@component.TypeDef?],
  global_resource_ids : Array[Int32?],
  visiting : Map[Int32, Int32],
) -> TypeSig {
  match td {
    DefValType(p) => Prim(p)
    Tuple(tys) => {
      let out : Array[TypeSig] = []
      for t in tys {
        out.push(
          type_sig_of_valtype_lg(
            t, local_types, local_resource_ids, global_types, global_resource_ids,
            visiting,
          ),
        )
      }
      Tuple(out)
    }
    Record(fields) => {
      let out : Array[TypeFieldSig] = []
      for f in fields {
        out.push({
          name: f.label,
          ty: type_sig_of_valtype_lg(
            f.ty,
            local_types,
            local_resource_ids,
            global_types,
            global_resource_ids,
            visiting,
          ),
        })
      }
      Record(out)
    }
    Variant(cases) => {
      let out : Array[TypeCaseSig] = []
      for c in cases {
        let payload = match c.ty {
          None => None
          Some(t) =>
            Some(
              type_sig_of_valtype_lg(
                t, local_types, local_resource_ids, global_types, global_resource_ids,
                visiting,
              ),
            )
        }
        out.push({ name: c.label, ty: payload, })
      }
      Variant(out)
    }
    Option(v) =>
      Option(
        type_sig_of_valtype_lg(
          v, local_types, local_resource_ids, global_types, global_resource_ids,
          visiting,
        ),
      )
    Result(ok, err) => {
      let ok_sig = ok.map(fn(v) {
        type_sig_of_valtype_lg(
          v, local_types, local_resource_ids, global_types, global_resource_ids,
          visiting,
        )
      })
      let err_sig = err.map(fn(v) {
        type_sig_of_valtype_lg(
          v, local_types, local_resource_ids, global_types, global_resource_ids,
          visiting,
        )
      })
      Result(ok_sig, err_sig)
    }
    List(v) =>
      List(
        type_sig_of_valtype_lg(
          v, local_types, local_resource_ids, global_types, global_resource_ids,
          visiting,
        ),
      )
    Flags(labels) => Flags(labels)
    Enum(labels) => Enum(labels)
    Own(idx) => {
      let resource = type_sig_of_valtype_lg(
        TypeIdx(idx),
        local_types,
        local_resource_ids,
        global_types,
        global_resource_ids,
        visiting,
      )
      match resource {
        Resource(rid) => Own(rid)
        _ => Other
      }
    }
    Borrow(idx) => {
      let resource = type_sig_of_valtype_lg(
        TypeIdx(idx),
        local_types,
        local_resource_ids,
        global_types,
        global_resource_ids,
        visiting,
      )
      match resource {
        Resource(rid) => Borrow(rid)
        _ => Other
      }
    }
    _ => Other
  }
}

///|
fn type_sig_of_valtype_lg(
  ty : @component.ValType,
  local_types : Array[@component.TypeDef],
  local_resource_ids : Array[Int32?],
  global_types : Array[@component.TypeDef?],
  global_resource_ids : Array[Int32?],
  visiting : Map[Int32, Int32],
) -> TypeSig {
  match ty {
    Prim(p) => Prim(p)
    TypeIdx(idx) =>
      if idx < 0 {
        Other
      } else if visiting.get(idx) is Some(_) {
        Other
      } else {
        visiting.set(idx, 1)
        let td = if idx < local_types.length() {
          Some(local_types[idx])
        } else if idx < global_types.length() {
          global_types[idx]
        } else {
          None
        }
        let rid = if idx < local_resource_ids.length() {
          local_resource_ids[idx]
        } else if idx < global_resource_ids.length() {
          global_resource_ids[idx]
        } else {
          None
        }
        let sig = match td {
          Some(ResourceType(_, _, _, _)) =>
            match rid {
              Some(v) => TypeSig::Resource(v)
              None => Resource(-1)
            }
          Some(def) =>
            type_sig_of_typedef_lg(
              def, local_types, local_resource_ids, global_types, global_resource_ids,
              visiting,
            )
          None => Other
        }
        visiting.remove(idx) |> ignore
        sig
      }
  }
}

///|
fn funcsig_of_functype_lg(
  ft : @component.FuncType,
  local_types : Array[@component.TypeDef],
  local_resource_ids : Array[Int32?],
  global_types : Array[@component.TypeDef?],
  global_resource_ids : Array[Int32?],
  local_origins~ : Map[Int32, Int32] = Map([]),
  global_function~ : Bool = false,
) -> FuncSigShape {
  let visiting : Map[Int32, Int32] = Map([])
  let params : Array[ParamShape] = []
  for p in ft.params {
    params.push({
      name: p.label,
      ty: type_sig_of_valtype_lg(
        p.ty,
        local_types,
        local_resource_ids,
        global_types,
        global_resource_ids,
        visiting,
      ),
    })
  }
  let result : TypeSig? = match ft.result {
    Some(v) =>
      Some(
        type_sig_of_valtype_lg(
          v, local_types, local_resource_ids, global_types, global_resource_ids,
          visiting,
        ),
      )
    None => None
  }
  {
    params,
    result,
    complete: complete_function_signature(
      ft,
      local_types,
      local_resource_ids,
      global_types,
      global_resource_ids,
      local_origins~,
      global_function~,
    ),
  }
}

///|
fn type_sig_of_typedef(
  td : @component.TypeDef,
  type_table : Array[@component.TypeDef?],
  resource_ids : Array[Int32?],
  visiting : Map[Int32, Int32],
) -> TypeSig {
  match td {
    DefValType(p) => Prim(p)
    Tuple(tys) => {
      let out : Array[TypeSig] = []
      for t in tys {
        out.push(type_sig_of_valtype(t, type_table, resource_ids, visiting))
      }
      Tuple(out)
    }
    Record(fields) => {
      let out : Array[TypeFieldSig] = []
      for f in fields {
        out.push({
          name: f.label,
          ty: type_sig_of_valtype(f.ty, type_table, resource_ids, visiting),
        })
      }
      Record(out)
    }
    Variant(cases) => {
      let out : Array[TypeCaseSig] = []
      for c in cases {
        let payload = match c.ty {
          None => None
          Some(t) =>
            Some(type_sig_of_valtype(t, type_table, resource_ids, visiting))
        }
        out.push({ name: c.label, ty: payload, })
      }
      Variant(out)
    }
    Option(v) =>
      Option(type_sig_of_valtype(v, type_table, resource_ids, visiting))
    Result(ok, err) => {
      let ok_sig = ok.map(fn(v) {
        type_sig_of_valtype(v, type_table, resource_ids, visiting)
      })
      let err_sig = err.map(fn(v) {
        type_sig_of_valtype(v, type_table, resource_ids, visiting)
      })
      Result(ok_sig, err_sig)
    }
    List(v) => List(type_sig_of_valtype(v, type_table, resource_ids, visiting))
    Flags(labels) => Flags(labels)
    Enum(labels) => Enum(labels)
    Own(idx) => {
      let resource = type_sig_of_valtype(
        TypeIdx(idx),
        type_table,
        resource_ids,
        visiting,
      )
      match resource {
        Resource(rid) => Own(rid)
        _ => Other
      }
    }
    Borrow(idx) => {
      let resource = type_sig_of_valtype(
        TypeIdx(idx),
        type_table,
        resource_ids,
        visiting,
      )
      match resource {
        Resource(rid) => Borrow(rid)
        _ => Other
      }
    }
    _ => Other
  }
}

///|
fn type_sig_of_valtype(
  ty : @component.ValType,
  type_table : Array[@component.TypeDef?],
  resource_ids : Array[Int32?],
  visiting : Map[Int32, Int32],
) -> TypeSig {
  match ty {
    Prim(p) => Prim(p)
    TypeIdx(idx) =>
      if idx < 0 || idx >= type_table.length() {
        Other
      } else if visiting.get(idx) is Some(_) {
        Other
      } else {
        visiting.set(idx, 1)
        let sig = match type_table[idx] {
          Some(ResourceType(_, _, _, _)) =>
            match resource_ids.get(idx) {
              Some(Some(rid)) => TypeSig::Resource(rid)
              _ => Resource(-1)
            }
          Some(td) =>
            type_sig_of_typedef(td, type_table, resource_ids, visiting)
          None => Other
        }
        visiting.remove(idx) |> ignore
        sig
      }
  }
}

///|
fn type_sig_of_typeidx(
  idx : Int32,
  type_table : Array[@component.TypeDef?],
  resource_ids : Array[Int32?],
) -> TypeSig {
  type_sig_of_valtype(TypeIdx(idx), type_table, resource_ids, Map([]))
}

///|
fn type_sig_subst_resources(
  sig : TypeSig,
  subst : Map[Int32, Int32],
) -> TypeSig {
  match sig {
    Prim(p) => Prim(p)
    Tuple(xs) => Tuple(xs.map(fn(x) { type_sig_subst_resources(x, subst) }))
    Record(fs) =>
      Record(
        fs.map(fn(f) {
          { name: f.name, ty: type_sig_subst_resources(f.ty, subst), }
        }),
      )
    Variant(cs) =>
      Variant(
        cs.map(fn(c) {
          let ty = match c.ty {
            None => None
            Some(t) => Some(type_sig_subst_resources(t, subst))
          }
          { name: c.name, ty, }
        }),
      )
    Option(v) => Option(type_sig_subst_resources(v, subst))
    Result(ok, err) => {
      let ok2 = ok.map(fn(v) { type_sig_subst_resources(v, subst) })
      let err2 = err.map(fn(v) { type_sig_subst_resources(v, subst) })
      Result(ok2, err2)
    }
    List(v) => List(type_sig_subst_resources(v, subst))
    Flags(labels) => Flags(labels)
    Enum(labels) => Enum(labels)
    Resource(rid) =>
      match subst.get(rid) {
        Some(v) => Resource(v)
        None => Resource(rid)
      }
    Own(rid) =>
      match subst.get(rid) {
        Some(v) => Own(v)
        None => Own(rid)
      }
    Borrow(rid) =>
      match subst.get(rid) {
        Some(v) => Borrow(v)
        None => Borrow(rid)
      }
    Other => Other
  }
}

///|
fn type_sig_has_resource_mismatch(expected : TypeSig, actual : TypeSig) -> Bool {
  match (expected, actual) {
    (Resource(a), Resource(b)) => a != b
    (Own(a), Own(b)) | (Borrow(a), Borrow(b)) => a != b
    (Own(_), Borrow(_)) | (Borrow(_), Own(_)) => true
    (Tuple(xs), Tuple(ys)) =>
      xs.length() == ys.length() &&
      ({
        let mut mismatch = false
        for i in 0..<xs.length() {
          if xs[i] != ys[i] && type_sig_has_resource_mismatch(xs[i], ys[i]) {
            mismatch = true
            break
          }
        }
        mismatch
      })
    (Record(xs), Record(ys)) =>
      xs.length() == ys.length() &&
      ({
        let mut mismatch = false
        for i in 0..<xs.length() {
          if xs[i].ty != ys[i].ty &&
            type_sig_has_resource_mismatch(xs[i].ty, ys[i].ty) {
            mismatch = true
            break
          }
        }
        mismatch
      })
    (Variant(xs), Variant(ys)) =>
      xs.length() == ys.length() &&
      ({
        let mut mismatch = false
        for i in 0..<xs.length() {
          let a = xs[i].ty
          let b = ys[i].ty
          if a != b {
            match (a, b) {
              (Some(a2), Some(b2)) =>
                if type_sig_has_resource_mismatch(a2, b2) {
                  mismatch = true
                  break
                }
              _ => ()
            }
          }
        }
        mismatch
      })
    (Option(a), Option(b)) => a != b && type_sig_has_resource_mismatch(a, b)
    (List(a), List(b)) => a != b && type_sig_has_resource_mismatch(a, b)
    (Result(a1, a2), Result(b1, b2)) => {
      if a1 != b1 {
        match (a1, b1) {
          (Some(x), Some(y)) =>
            if type_sig_has_resource_mismatch(x, y) {
              return true
            }
          _ => ()
        }
      }
      if a2 != b2 {
        match (a2, b2) {
          (Some(x), Some(y)) =>
            if type_sig_has_resource_mismatch(x, y) {
              return true
            }
          _ => ()
        }
      }
      false
    }
    _ => false
  }
}

///|
fn funcsig_subst_resources(
  sig : FuncSigShape,
  subst : Map[Int32, Int32],
) -> FuncSigShape {
  let params : Array[ParamShape] = []
  for p in sig.params {
    params.push({ name: p.name, ty: type_sig_subst_resources(p.ty, subst), })
  }
  let result = match sig.result {
    None => None
    Some(r) => Some(type_sig_subst_resources(r, subst))
  }
  {
    params,
    result,
    complete: complete_signature_substitute(sig.complete, subst),
  }
}

///|
fn funcsig_has_resource_mismatch(
  expected : FuncSigShape,
  actual : FuncSigShape,
) -> Bool {
  if expected.params.length() != actual.params.length() {
    return false
  }
  for i in 0..<expected.params.length() {
    let a = expected.params[i].ty
    let b = actual.params[i].ty
    if a != b && type_sig_has_resource_mismatch(a, b) {
      return true
    }
  }
  match (expected.result, actual.result) {
    (None, None) => false
    (Some(a), Some(b)) => a != b && type_sig_has_resource_mismatch(a, b)
    _ => false
  }
}

///|
fn typedef_requires_name_for_interface(td : @component.TypeDef) -> Bool {
  match td {
    Record(_) | Variant(_) | Flags(_) | Enum(_) | ResourceType(_, _, _, _) =>
      true
    _ => false
  }
}

///|
fn valtype_valid_in_interface(
  ty : @component.ValType,
  type_table : Array[@component.TypeDef?],
  _resource_ids : Array[Int32?],
  named_types : Map[Int32, Int32],
  _visiting : Map[Int32, Int32],
) -> Bool {
  interface_value_work(ty, type_table, named_types, false)
}

///|
fn valtype_valid_for_type_import_export(
  ty : @component.ValType,
  type_table : Array[@component.TypeDef?],
  _resource_ids : Array[Int32?],
  named_types : Map[Int32, Int32],
  _visiting : Map[Int32, Int32],
) -> Bool {
  interface_value_work(ty, type_table, named_types, true)
}

///|
// Type index chains are input-controlled even when physical scopes are shallow.
// Keep this check iterative, including fixed lists and maps from WAC packages.
fn interface_value_work(
  ty : @component.ValType,
  type_table : Array[@component.TypeDef?],
  named_types : Map[Int32, Int32],
  type_external : Bool,
) -> Bool {
  let work : Array[(@component.ValType, Bool)] = [(ty, type_external)]
  let seen : Map[(Int32, Bool), Bool] = Map([])
  while work.pop() is Some((value, top_external)) {
    guard value is TypeIdx(index) else { continue }
    if index < 0 || index >= type_table.length() {
      continue
    }
    if seen.get((index, top_external)) is Some(_) {
      continue
    }
    seen[(index, top_external)] = true
    guard type_table[index] is Some(definition) else { continue }
    if typedef_requires_name_for_interface(definition) &&
      named_types.get(index) is None {
      return false
    }
    match definition {
      Tuple(values) =>
        for value in values {
          work.push((value, false))
        }
      Record(fields) =>
        for field in fields {
          work.push((field.ty, false))
        }
      Variant(cases) =>
        for case in cases {
          if case.ty is Some(value) {
            work.push((value, false))
          }
        }
      Option(value) | List(value) | FixedList(value, _) =>
        work.push((value, false))
      MapType(key, value) => {
        work.push((key, false))
        work.push((value, false))
      }
      Result(ok, error) => {
        if ok is Some(value) {
          work.push((value, false))
        }
        if error is Some(value) {
          work.push((value, false))
        }
      }
      Own(index) | Borrow(index) => work.push((TypeIdx(index), false))
      Future(value) | Stream(value) =>
        if value is Some(value) {
          work.push((value, false))
        }
      FuncType(function) =>
        if top_external {
          for param in function.params {
            work.push((param.ty, false))
          }
          if function.result is Some(result) {
            work.push((result, false))
          }
        }
      _ => ()
    }
  }
  true
}

///|
fn functype_valid_in_interface(
  ft : @component.FuncType,
  type_table : Array[@component.TypeDef?],
  resource_ids : Array[Int32?],
  named_types : Map[Int32, Int32],
) -> Bool {
  let visiting : Map[Int32, Int32] = Map([])
  for p in ft.params {
    if !valtype_valid_in_interface(
        p.ty,
        type_table,
        resource_ids,
        named_types,
        visiting,
      ) {
      return false
    }
  }
  match ft.result {
    None => true
    Some(r) =>
      valtype_valid_in_interface(
        r, type_table, resource_ids, named_types, visiting,
      )
  }
}

///|
fn instancetype_sig_of_typedef(
  td : @component.TypeDef,
  type_table : Array[@component.TypeDef?],
  visiting_global : Map[Int32, Int32],
) -> InstanceSig {
  match td {
    InstanceTypeEmpty => InstanceSig::empty()
    InstanceType(decls) =>
      instancetype_sig_of_decls(decls, type_table, visiting_global)
    _ => InstanceSig::empty()
  }
}

///|
fn instancetype_sig_of_global_idx(
  tyidx : Int32,
  type_table : Array[@component.TypeDef?],
  visiting_global : Map[Int32, Int32],
) -> InstanceSig {
  if tyidx < 0 || tyidx >= type_table.length() {
    return InstanceSig::empty()
  }
  // Avoid infinite recursion on recursive instance types; wasm-tools accepts
  // such encodings, so we conservatively stop descending.
  if visiting_global.get(tyidx) is Some(_) {
    return InstanceSig::empty()
  }
  visiting_global.set(tyidx, 1)
  match type_table[tyidx] {
    Some(td) => instancetype_sig_of_typedef(td, type_table, visiting_global)
    None => InstanceSig::empty()
  }
}

///|
fn instancetype_sig_of_local_idx(
  tyidx : Int32,
  local_types : Array[@component.TypeDef],
  type_table : Array[@component.TypeDef?],
  visiting_local : Map[Int32, Int32],
  visiting_global : Map[Int32, Int32],
) -> InstanceSig {
  if tyidx < 0 {
    return InstanceSig::empty()
  }
  if tyidx < local_types.length() {
    if visiting_local.get(tyidx) is Some(_) {
      return InstanceSig::empty()
    }
    visiting_local.set(tyidx, 1)
    return instancetype_sig_of_typedef(
      local_types[tyidx],
      type_table,
      visiting_global,
    )
  }
  // Fallback to the component's type index space if the index does not refer to
  // a locally declared type. This keeps the validator tolerant of different
  // toolchain encodings.
  instancetype_sig_of_global_idx(tyidx, type_table, visiting_global)
}

///|
fn instancetype_sig_of_decls(
  decls : Array[@component.InstanceDecl],
  type_table : Array[@component.TypeDef?],
  visiting_global : Map[Int32, Int32],
) -> InstanceSig {
  let exports : Map[String, @component.Sort] = Map([])
  let nested : Map[String, InstanceSig] = Map([])
  // Instance types define their own internal type index space introduced by
  // `Type(...)` declarations in-order.
  let local_types : Array[@component.TypeDef] = []
  let visiting_local : Map[Int32, Int32] = Map([])
  for d in decls {
    match d {
      Type(t) => local_types.push(t)
      Export(name, _attributes, desc) => {
        let sort = sort_of_externdesc(desc)
        exports.set(name, sort)
        match desc {
          InstanceType(child_tyidx) => {
            let child = instancetype_sig_of_local_idx(
              child_tyidx, local_types, type_table, visiting_local, visiting_global,
            )
            nested.set(name, child)
          }
          _ => ()
        }
      }
      _ => ()
    }
  }
  { exports, nested, }
}

///|
fn instancetype_valid_for_use_as_interface(
  tyidx : Int32,
  type_table : Array[@component.TypeDef?],
  type_outers : Array[Array[@component.TypeDef?]],
  named_types : Map[Int32, Int32],
) -> Bool {
  let work = [(tyidx, type_table, [type_table] + type_outers, [named_types])]
  let mut remaining = 1000000
  while work.pop() is Some((tyidx, type_table, type_outers, named_outers)) {
    remaining -= 1
    if remaining < 0 {
      return false
    }
    if tyidx < 0 || tyidx >= type_table.length() {
      return false
    }
    match type_table[tyidx] {
      Some(InstanceTypeEmpty) => ()
      Some(InstanceType(decls)) => {
        let local_type_table : Array[@component.TypeDef?] = []
        let local_resource_ids : Array[Int32?] = []
        let local_named_types : Map[Int32, Int32] = Map([])
        let mut next_rid = 0
        fn push_local(td : @component.TypeDef?) -> Unit {
          local_type_table.push(td)
          match td {
            Some(ResourceType(_, _, _, _)) => {
              local_resource_ids.push(Some(next_rid))
              next_rid += 1
            }
            _ => local_resource_ids.push(None)
          }
        }

        for d in decls {
          remaining -= 1
          if remaining < 0 {
            return false
          }
          match d {
            Type(t) => push_local(Some(t))
            AliasOuter(kind, count, idx) =>
              if kind == 0x03 {
                let td = if count == 0 {
                  local_type_table.get(idx).unwrap_or(None)
                } else {
                  outer_type_of_alias(type_outers, count, idx) catch {
                    _ => None
                  }
                }
                let rid = if count == 0 {
                  local_resource_ids.get(idx).unwrap_or(None)
                } else {
                  None
                }
                push_local(td)
                if count == 0 {
                  local_resource_ids[local_resource_ids.length() - 1] = rid
                  if local_named_types.contains(idx) {
                    local_named_types[local_type_table.length() - 1] = 1
                  }
                } else if named_outers.get(count - 1) is Some(names) &&
                  names.contains(idx) {
                  local_named_types[local_type_table.length() - 1] = 1
                }
              }
            AliasInstanceExport(kind, _inst, _name) =>
              if kind == 0x03 {
                push_local(None)
              }
            Export(_name, _attributes, desc) =>
              match desc {
                Type(bound) => {
                  let new_idx = local_type_table.length()
                  match bound {
                    Eq(src) =>
                      if src >= 0 && src < local_type_table.length() {
                        push_local(local_type_table[src])
                      } else {
                        push_local(None)
                      }
                    SubResource =>
                      push_local(
                        Some(ResourceType(-1, 0x7f, None, HostDefined)),
                      )
                  }
                  local_named_types.set(new_idx, 1)
                  if !valtype_valid_for_type_import_export(
                      TypeIdx(new_idx),
                      local_type_table,
                      local_resource_ids,
                      local_named_types,
                      Map([]),
                    ) {
                    return false
                  }
                }
                InstanceType(child) => {
                  remaining -= local_type_table.length() +
                    type_outers.length() +
                    local_named_types.length()
                  if remaining < 0 {
                    return false
                  }
                  let snapshot = local_type_table.copy()
                  work.push(
                    (
                      child,
                      snapshot,
                      [snapshot] + type_outers,
                      [local_named_types.copy()] + named_outers,
                    ),
                  )
                }
                Value(Type(value)) =>
                  if !valtype_valid_in_interface(
                      value,
                      local_type_table,
                      local_resource_ids,
                      local_named_types,
                      Map([]),
                    ) {
                    return false
                  }
                FuncType(ft_idx) =>
                  if ft_idx >= 0 && ft_idx < local_type_table.length() {
                    match local_type_table[ft_idx] {
                      Some(FuncType(ft)) =>
                        if !functype_valid_in_interface(
                            ft, local_type_table, local_resource_ids, local_named_types,
                          ) {
                          return false
                        }
                      _ => ()
                    }
                  }
                _ => ()
              }
            _ => ()
          }
        }
      }
      _ => ()
    }
  }
  true
}

///|
fn componenttype_signature_of_decls(
  decls : Array[@component.ComponentDecl],
  type_table : Array[@component.TypeDef?],
) -> (
  Map[String, @component.Sort],
  Map[String, InstanceSig],
  Map[String, @component.Sort],
  Map[String, InstanceSig],
) {
  let import_sorts : Map[String, @component.Sort] = Map([])
  let import_instance_sigs : Map[String, InstanceSig] = Map([])
  let export_sorts : Map[String, @component.Sort] = Map([])
  let export_instance_sigs : Map[String, InstanceSig] = Map([])
  // Component type declarations define their own local type space introduced by
  // `Type(...)` plus type-valued alias/import/export declarations.
  let local_types : Array[@component.TypeDef] = []
  let visiting_local : Map[Int32, Int32] = Map([])
  let visiting_global : Map[Int32, Int32] = Map([])
  fn record_type_slot() -> Unit {
    // Placeholder for a type index introduced by an alias/import/export decl.
    local_types.push(InstanceTypeEmpty)
  }

  for d in decls {
    match d {
      Type(t) => local_types.push(t)
      AliasOuter(kind, _count, _idx) => if kind == 0x03 { record_type_slot() }
      AliasInstanceExport(kind, _inst, _name) =>
        if kind == 0x03 {
          record_type_slot()
        }
      Import(name, _attributes, desc) => {
        import_sorts.set(name, sort_of_externdesc(desc))
        match desc {
          InstanceType(tyidx) => {
            let sig = instancetype_sig_of_local_idx(
              tyidx, local_types, type_table, visiting_local, visiting_global,
            )
            import_instance_sigs.set(name, sig)
          }
          _ => ()
        }
        if desc is Type(_) {
          record_type_slot()
        }
      }
      Export(name, _attributes, desc) => {
        export_sorts.set(name, sort_of_externdesc(desc))
        match desc {
          InstanceType(tyidx) => {
            let sig = instancetype_sig_of_local_idx(
              tyidx, local_types, type_table, visiting_local, visiting_global,
            )
            export_instance_sigs.set(name, sig)
          }
          _ => ()
        }
        if desc is Type(_) {
          record_type_slot()
        }
      }
      CoreType(_) => ()
    }
  }
  (import_sorts, import_instance_sigs, export_sorts, export_instance_sigs)
}

///|
fn check_instance_subtype(
  actual : InstanceSig?,
  expected : InstanceSig,
) -> Unit raise ComponentValidationError {
  if actual is Some(sig) {
    for kv in expected.exports.iter() {
      let (name, expected_sort) = kv
      match sig.exports.get(name) {
        Some(actual_sort) =>
          if actual_sort != expected_sort {
            raise ComponentImportTypeMismatch("export \{name}")
          } else {
            match expected.nested.get(name) {
              Some(expected_child) =>
                match sig.nested.get(name) {
                  Some(actual_child) =>
                    check_instance_subtype(Some(actual_child), expected_child)
                  None => ()
                }
              None => ()
            }
          }
        None => raise MissingExpectedExport(name)
      }
    }
  }
}

///|
fn check_core_module_subtype(
  actual : Map[String, Int32]?,
  expected : Map[String, Int32],
) -> Unit raise ComponentValidationError {
  if actual is Some(map) {
    for kv in expected.iter() {
      let (name, expected_kind) = kv
      match map.get(name) {
        Some(actual_kind) =>
          if actual_kind != expected_kind {
            raise ComponentImportTypeMismatch("export \{name}")
          }
        None => raise MissingExpectedExport(name)
      }
    }
  }
}

///|
fn validate_accessor_function(
  section : Int32,
  name : String,
  ft : @component.FuncType,
  type_table : Array[@component.TypeDef?],
) -> Unit raise ComponentValidationError {
  let is_method = name.has_prefix("[method]")
  let rest = if is_method || name.has_prefix("[static]") {
    name[8:].to_owned()
  } else {
    name
  }
  let getter = rest.has_prefix("[get]")
  let setter = rest.has_prefix("[set]")
  if !getter && !setter {
    return
  }
  if ft.is_async {
    raise SectionParseError(section, "accessor cannot be async")
  }
  let parameters = ft.params.length() - (if is_method { 1 } else { 0 })
  if (getter && parameters != 0) || (setter && parameters != 1) {
    raise SectionParseError(section, "invalid accessor parameter count")
  }
  let result_without_success = match ft.result {
    Some(TypeIdx(index)) if index >= 0 && index < type_table.length() =>
      type_table[index] is Some(Result(None, _))
    _ => false
  }
  if getter && (ft.result is None || result_without_success) {
    raise SectionParseError(section, "getter must return a value")
  }
  if setter && ft.result is Some(_) && !result_without_success {
    raise SectionParseError(
      section, "setter may return only a result without success",
    )
  }
}

///|
fn validate_accessor_pair(
  section : Int32,
  name : String,
  ft : @component.FuncType,
  type_table : Array[@component.TypeDef?],
  resource_ids : Array[Int32?],
  preceding : Map[String, @component.FuncType],
) -> Unit raise ComponentValidationError {
  let rest = if name.has_prefix("[method]") || name.has_prefix("[static]") {
    name[8:].to_owned()
  } else {
    name
  }
  if !rest.has_prefix("[set]") {
    return
  }
  let getter_name = name.replace(old="[set]", new="[get]")
  guard preceding.get(getter_name) is Some(getter) else {
    raise SectionParseError(section, "setter requires a preceding getter")
  }
  guard getter.result is Some(property) && !ft.params.is_empty() else {
    raise SectionParseError(section, "accessor pair has an invalid signature")
  }
  let property = match property {
    TypeIdx(index) if index >= 0 && index < type_table.length() =>
      match type_table[index] {
        Some(Result(Some(success), _)) => success
        _ => property
      }
    _ => property
  }
  if type_sig_of_valtype(
      ft.params[ft.params.length() - 1].ty,
      type_table,
      resource_ids,
      Map([]),
    ) !=
    type_sig_of_valtype(property, type_table, resource_ids, Map([])) {
    raise SectionParseError(
      section, "setter parameter does not match getter property type",
    )
  }
}
