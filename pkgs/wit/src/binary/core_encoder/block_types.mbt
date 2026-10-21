///|
/// Materialize text-only block signatures without mutating the input module.
fn resolve_block_types(module_ : @types.Module) -> @types.Module {
  let types = module_.types.copy()
  let groups = module_.type_rec_groups.copy()
  while groups.length() < types.length() {
    groups.push(groups.length())
  }
  let mut next_group = 0
  for group in groups {
    if group >= next_group {
      next_group = group + 1
    }
  }
  fn resolve(block : @types.BlockType) -> @types.BlockType {
    let (params, results) = match block {
      MultiValue(results) => ([], results)
      InlineType(params, results) => (params, results)
      _ => return block
    }
    for index, subtype in types {
      if subtype.composite is Func(function) &&
        function.params == params &&
        function.results == results {
        return TypeIndex(index)
      }
    }
    let index = types.length()
    types.push(@types.SubType::from_func({ params, results, }))
    groups.push(next_group)
    next_group = next_group + 1
    TypeIndex(index)
  }
  fn instructions(
    body : Array[@types.Instruction],
  ) -> Array[@types.Instruction] {
    let output = []
    let pending : Array[
      (Array[@types.Instruction], Array[@types.Instruction], Int32),
    ] = [(body, output, 0)]
    while pending.pop() is Some((source, target, index)) {
      if index >= source.length() {
        continue
      }
      pending.push((source, target, index + 1))
      let rewritten = match source[index] {
        Block(bt, body) => {
          let child = []
          let bt = resolve(bt)
          pending.push((body, child, 0))
          @types.Instruction::Block(bt, child)
        }
        Loop(bt, body) => {
          let child = []
          let bt = resolve(bt)
          pending.push((body, child, 0))
          @types.Instruction::Loop(bt, child)
        }
        If(bt, yes, no) => {
          let first = []
          let second = []
          let bt = resolve(bt)
          pending.push((no, second, 0))
          pending.push((yes, first, 0))
          @types.Instruction::If(bt, first, second)
        }
        TryTable(bt, handlers, body) => {
          let child = []
          let bt = resolve(bt)
          pending.push((body, child, 0))
          @types.Instruction::TryTable(bt, handlers, child)
        }
        LegacyTry(bt, body, catches, delegate) => {
          let child = []
          let bt = resolve(bt)
          let arms : Array[@types.LegacyCatch] = catches.map(arm => {
            tag: arm.tag,
            body: [],
          })
          for i = arms.length() - 1; i >= 0; i = i - 1 {
            pending.push((catches[i].body, arms[i].body, 0))
          }
          pending.push((body, child, 0))
          @types.Instruction::LegacyTry(bt, child, arms, delegate)
        }
        other => other
      }
      target.push(rewritten)
    }
    output
  }
  let codes : Array[@types.FunctionCode] = module_.codes.map(fn(code) {
    { locals: code.locals, body: instructions(code.body), }
  })
  let globals = module_.globals.map(global => {
    ..global,
    init: instructions(global.init),
  })
  let tables = module_.tables.map(table => {
    ..table,
    init: table.init.map(instructions),
  })
  let elems = module_.elems.map(elem => {
    ..elem,
    mode: match elem.mode {
      Active(index, offset) => Active(index, instructions(offset))
      other => other
    },
    init: elem.init.map(instructions),
  })
  let datas = module_.datas.map(data => {
    ..data,
    offset: instructions(data.offset),
  })
  {
    ..module_,
    types,
    type_rec_groups: groups,
    codes,
    globals,
    tables,
    elems,
    datas,
  }
}
