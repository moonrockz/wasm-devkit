///|
/// A numeric outer alias escaping a component fragment. Distance 1 identifies
/// its immediate containing component. Sorts use component binary tags, or
/// 0x100 plus a core sort tag. Entries are immutable and ordered by occurrence.
pub struct OuterReference {
  distance : Int32
  sort : Int32
  index : Int32
}

///|
/// A replacement name declared in the new containing component. Names include
/// the `$` prefix. Relocation leaves aliases within the fragment untouched.
pub(all) struct OuterBinding {
  distance : Int32
  sort : Int32
  index : Int32
  name : String
}

///|
priv enum FragmentTask {
  Visit(SExpr, Int32, String, Bool)
  Finish(Int32)
}

///|
fn fragment_sort(expr : SExpr, core : Bool) -> Int32? {
  guard expr is List(items) else { return None }
  let words = items
    .iter()
    .filter_map(e => if e is Atom(a) { Some(a) } else { None })
    .to_array()
  match words {
    ["type", ..] => Some(if core { 0x110 } else { 3 })
    ["component", ..] => Some(4)
    ["core", "type", ..] => Some(0x110)
    ["core", "module", ..] => Some(0x111)
    _ => None
  }
}

///|
fn fragment_aliases(
  source : String,
  bindings : ReadOnlyArray[OuterBinding]?,
) -> (Array[OuterReference], String) raise ComponentTextError {
  let reader = TextReader::TextReader(source)
  let root = parse_sexpr(reader)
  reader.skip_ws_and_comments()
  guard reader.is_eof() && expr_head_atom(root) == Some("component") else {
    raise ParseError("expected one component fragment")
  }
  let replacements : Map[(Int32, Int32, Int32), String] = Map([])
  if bindings is Some(values) {
    for value in values {
      guard value.name.has_prefix("$") else {
        raise ParseError("outer binding requires an identifier")
      }
      replacements[(value.distance, value.sort, value.index)] = value.name
    }
  }
  let references : Array[OuterReference] = []
  let work : Array[FragmentTask] = [Visit(root, -1, "", false)]
  let output : Array[SExpr] = []
  while work.pop() is Some(task) {
    match task {
      Finish(count) => {
        let start = output.length() - count
        let children = output[start:].to_owned()
        output.truncate(start)
        output.push(List(children))
      }
      Visit(expr, depth, parent, core) => {
        guard expr is List(items) else {
          output.push(expr)
          continue
        }
        let head = expr_head_atom(expr).unwrap_or("")
        // Core executable bodies contain no component outer aliases.
        if items.get(0) is Some(Atom("core")) &&
          items.get(1) is Some(Atom("module")) {
          output.push(expr)
          continue
        }
        let lexical = (
            head == "component" &&
            (parent == "" || parent == "component" || parent == "type")
          ) ||
          (head == "instance" && parent == "type") ||
          (head == "module" && parent == "core-type")
        let depth = depth + (if lexical { 1 } else { 0 })
        let core = core || (head == "module" && parent == "core-type")
        if items.length() == 5 &&
          items[0] is Atom("alias") &&
          items[1] is Atom("outer") &&
          items[2] is Atom(count) &&
          items[3] is Atom(index) &&
          parse_index_literal(count) is Some(count) &&
          parse_index_literal(index) is Some(index) &&
          fragment_sort(items[4], core) is Some(sort) &&
          count > depth {
          let distance = count - depth
          references.push({ distance, sort, index, })
          if bindings is Some(_) {
            guard replacements.get((distance, sort, index)) is Some(name) else {
              raise ParseError("missing outer binding")
            }
            output.push(
              List([
                Atom("alias"),
                Atom("outer"),
                Atom((depth + 1).to_string()),
                Atom(name),
                items[4],
              ]),
            )
            continue
          }
        }
        let label = if items.get(0) is Some(Atom("core")) &&
          items.get(1) is Some(Atom("type")) {
          "core-type"
        } else {
          head
        }
        work.push(Finish(items.length()))
        for i = items.length() - 1; i >= 0; i = i - 1 {
          work.push(Visit(items[i], depth, label, core))
        }
      }
    }
  }
  let rendered = if bindings is Some(_) {
    fragment_wat(output[0]) + "\n"
  } else {
    ""
  }
  (references, rendered)
}

///|
/// Find lexical references that must be supplied when a printed component
/// fragment is extracted. Parsing and traversal use explicit work stacks.
pub fn outer_references(
  source : String,
) -> ReadOnlyArray[OuterReference] raise ComponentTextError {
  ReadOnlyArray::from_array(fragment_aliases(source, None).0)
}

///|
/// Relocate external aliases to names declared in a new containing component.
/// This is a source transformation; the result still needs its containing
/// declarations before it can compile as a standalone component.
pub fn relocate_outer_references(
  source : String,
  bindings : ReadOnlyArray[OuterBinding],
) -> String raise ComponentTextError {
  fragment_aliases(source, Some(bindings)).1
}

///|
// Literal bytes must stay escaped when the reader decoded a string containing
// controls or a custom-section payload. This renderer never emits them raw.
fn fragment_wat(expr : SExpr) -> String {
  let out = StringBuilder()
  let work : Array[RenderSExpr] = [Expression(expr)]
  while work.pop() is Some(task) {
    match task {
      Text(text) => out.write_string(text)
      Expression(Atom(text)) => out.write_string(text)
      Expression(Str(text)) => out.write_string(wat_literal(@utf8.encode(text)))
      Expression(ByteStr(bytes)) => out.write_string(wat_literal(bytes))
      Expression(List(items)) => {
        out.write_char('(')
        work.push(Text(")"))
        for i = items.length() - 1; i >= 0; i = i - 1 {
          work.push(Expression(items[i]))
          if i > 0 {
            work.push(Text(" "))
          }
        }
      }
    }
  }
  out.to_string()
}
