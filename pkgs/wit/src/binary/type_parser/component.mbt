// Retained from Milky2018/wasm_component@0.16.0.
// Modified by wasm-devkit: parse nested type scopes with an explicit work stack.

///|
pub fn parse_component(bytes : Bytes) -> @component.Component raise {
  let roots : Array[@component.Component] = []
  let work = [(bytes, roots)]
  while work.pop() is Some((bytes, out)) {
    let binary = @component.parse_component_binary(bytes)
    let nested : Array[Bytes] = []
    let core_modules : Array[Bytes] = []
    let core_instances : Array[Bytes] = []
    let core_types : Array[Bytes] = []
    let types : Array[@component.TypeDef] = []
    let imports : Array[@component.Import] = []
    let exports : Array[@component.Export] = []
    let instances : Array[@component.Instance] = []
    let aliases : Array[@component.Alias] = []
    let canons : Array[@component.Canon] = []
    let mut start : @component.Start? = None
    let components : Array[@component.Component] = []
    for s in binary.sections {
      if s.id == 1 {
        core_modules.push(s.payload)
      } else if s.id == 2 {
        core_instances.push(s.payload)
      } else if s.id == 3 {
        core_types.push(s.payload)
      } else if s.id == 7 {
        for t in parse_type_section(s.payload) {
          types.push(t)
        }
      } else if s.id == 10 {
        for i in @component.parse_import_section(s.payload) {
          imports.push(i)
        }
      } else if s.id == 11 {
        for e in @component.parse_export_section(s.payload) {
          exports.push(e)
        }
      } else if s.id == 5 {
        for inst in @component.parse_instance_section(s.payload) {
          instances.push(inst)
        }
      } else if s.id == 6 {
        for a in @component.parse_alias_section(s.payload) {
          aliases.push(a)
        }
      } else if s.id == 8 {
        for c in @component.parse_canon_section(s.payload) {
          canons.push(c)
        }
      } else if s.id == 9 {
        start = Some(@component.parse_start_section(s.payload))
      } else if s.id == 4 {
        nested.push(s.payload)
      } else {
        ()
      }
    }
    out.push({
      binary,
      core_modules,
      core_instances,
      core_types,
      types,
      imports,
      exports,
      instances,
      aliases,
      canons,
      start,
      components,
    })
    for i = nested.length() - 1; i >= 0; i = i - 1 {
      work.push((nested[i], components))
    }
  }
  roots[0]
}
