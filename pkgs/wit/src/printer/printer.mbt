///|
pub(all) enum PrintError {
  InvalidTree
  InvalidRoot
  InvalidOptions
  RecoveryNode(Int32)
  Unrepresentable
} derive(Eq, Debug)

///|
priv enum Scope {
  File
  Inline
  Other
}

///|
priv enum Command {
  Text(String)
  Node(Int32, Scope)
}

///|
fn literal(text : String) -> Command {
  Text(text)
}

///|
fn child(index : Int32, scope~ : Scope = Other) -> Command {
  Node(index, scope)
}

///|
fn identifier(name : String) -> String {
  let scan = @scanner.scan(name)
  if scan.tokens[0].kind == Keyword {
    "%" + name
  } else {
    name
  }
}

///|
fn names(values : ReadOnlyArray[String], separator : String) -> String {
  let out = StringBuilder()
  for i, name in values {
    if i > 0 {
      out.write_string(separator)
    }
    out.write_string(identifier(name))
  }
  out.to_string()
}

///|
fn add_nodes(
  out : Array[Command],
  nodes : ReadOnlyArray[Int32],
  separator : String,
  scope~ : Scope = Other,
) -> Unit {
  for i, node in nodes {
    if i > 0 {
      out.push(literal(separator))
    }
    out.push(child(node, scope~))
  }
}

///|
fn attributes(out : Array[Command], nodes : ReadOnlyArray[Int32]) -> Unit {
  for node in nodes {
    out.push(child(node))
    out.push(literal(" "))
  }
}

///|
fn body(
  out : Array[Command],
  nodes : ReadOnlyArray[Int32],
  scope : Scope,
) -> Unit {
  out.push(literal(" { "))
  add_nodes(out, nodes, " ", scope~)
  out.push(literal(" } "))
}

///|
fn result(out : Array[Command], node : Int32?) -> Unit {
  if node is Some(node) {
    out.push(literal(" -> "))
    out.push(child(node))
  }
}

///|
fn generic(out : Array[Command], name : String, node : Int32) -> Unit {
  out.push(literal(name + "<"))
  out.push(child(node))
  out.push(literal(">"))
}

///|
/// Canonical source for a complete WIT file AST. All syntax descent is scheduled
/// on a heap command stack. Recovery nodes and nonrepresentable hand-built ASTs
/// return errors; the operation never returns partial output.
pub fn print(
  tree : @ast.Tree,
  indent_width~ : Int32 = 2,
) -> Result[String, PrintError] {
  if indent_width < 0 || indent_width > 8 {
    return Err(InvalidOptions)
  }
  if !tree.validate() {
    return Err(InvalidTree)
  }
  let root = tree.nodes.length() - 1
  if tree.nodes[root].data.kind() != File {
    return Err(InvalidRoot)
  }
  let pending = [child(root, scope=File)]
  let raw = StringBuilder()
  while pending.pop() is Some(command) {
    match command {
      Text(text) => raw.write_string(text)
      Node(index, scope) => {
        let out = []
        match tree.nodes[index].data {
          File(items~) => add_nodes(out, items, " ", scope=File)
          Package(attributes=attrs, path~, items~, nested~) => {
            attributes(out, attrs)
            out.push(literal("package "))
            out.push(child(path))
            if nested {
              body(out, items, File)
            } else {
              out.push(literal("; "))
              add_nodes(out, items, " ", scope=File)
            }
          }
          Interface(name~, attributes=attrs, items~) => {
            attributes(out, attrs)
            out.push(
              literal(
                if scope is Inline {
                  "interface"
                } else {
                  "interface " + identifier(name)
                },
              ),
            )
            body(out, items, Other)
          }
          World(name~, attributes=attrs, items~) => {
            attributes(out, attrs)
            out.push(literal("world " + identifier(name)))
            body(out, items, Other)
          }
          Resource(name~, attributes=attrs, methods~, has_body~) => {
            attributes(out, attrs)
            out.push(literal("resource " + identifier(name)))
            if has_body {
              body(out, methods, Other)
            } else {
              out.push(literal("; "))
            }
          }
          Alias(name~, attributes=attrs, ty~) => {
            attributes(out, attrs)
            out.push(literal("type " + identifier(name) + " = "))
            out.push(child(ty))
            out.push(literal("; "))
          }
          Record(name~, attributes=attrs, fields~) => {
            attributes(out, attrs)
            out.push(literal("record " + identifier(name) + " { "))
            add_nodes(out, fields, ", ")
            out.push(literal(" } "))
          }
          Flags(name~, attributes=attrs, cases~)
          | Enum(name~, attributes=attrs, cases~)
          | Variant(name~, attributes=attrs, cases~) => {
            let word = match tree.nodes[index].data.kind() {
              Flags => "flags"
              Enum => "enum"
              _ => "variant"
            }
            attributes(out, attrs)
            out.push(literal(word + " " + identifier(name) + " { "))
            add_nodes(out, cases, ", ")
            out.push(literal(" } "))
          }
          Function(name~, attributes=attrs, signature~, is_static~) => {
            attributes(out, attrs)
            out.push(
              literal(
                identifier(name) +
                ": " +
                (if is_static { "static " } else { "" }),
              ),
            )
            out.push(child(signature))
            out.push(literal("; "))
          }
          Constructor(attributes=attrs, params~, result=returns) => {
            attributes(out, attrs)
            out.push(literal("constructor("))
            add_nodes(out, params, ", ")
            out.push(literal(")"))
            result(out, returns)
            out.push(literal("; "))
          }
          Signature(flavor~, asynchronous~, params~, result=returns) => {
            let name = match flavor {
              Func => "func"
              Get => "get"
              Set => "set"
            }
            out.push(
              literal((if asynchronous { "async " } else { "" }) + name + "("),
            )
            add_nodes(out, params, ", ")
            out.push(literal(")"))
            result(out, returns)
          }
          Import(name~, attributes=attrs, target~)
          | Export(name~, attributes=attrs, target~) => {
            attributes(out, attrs)
            out.push(
              literal(
                if tree.nodes[index].data.kind() == Import {
                  "import "
                } else {
                  "export "
                },
              ),
            )
            if name is Some(name) {
              out.push(literal(identifier(name) + ": "))
            }
            let inline = tree.nodes[target].data.kind() == Interface
            out.push(child(target, scope=if inline { Inline } else { Other }))
            if !inline {
              out.push(literal("; "))
            }
          }
          Use(attributes=attrs, path~, names=selected, renamed~) => {
            attributes(out, attrs)
            out.push(literal("use "))
            out.push(child(path))
            if renamed is Some(name) {
              out.push(literal(" as " + identifier(name)))
            }
            if (match scope {
                File => !selected.is_empty()
                Inline | Other => true
              }) {
              out.push(literal(".{"))
              add_nodes(out, selected, ", ")
              out.push(literal("}"))
            }
            out.push(literal("; "))
          }
          Include(attributes=attrs, path~, renames~) => {
            attributes(out, attrs)
            out.push(literal("include "))
            out.push(child(path))
            if renames.is_empty() {
              out.push(literal("; "))
            } else {
              out.push(literal(" with { "))
              add_nodes(out, renames, ", ")
              out.push(literal(" } "))
            }
          }
          Attribute(name~, field~, value~) => {
            let value = if name == "unstable" {
              identifier(value)
            } else {
              value
            }
            out.push(
              literal(
                "@" +
                identifier(name) +
                "(" +
                (if field == "" { "" } else { identifier(field) + " = " }) +
                value +
                ") ",
              ),
            )
          }
          Path(namespaces~, segments~, version~) =>
            out.push(
              literal(
                names(namespaces, ":") +
                (if namespaces.is_empty() { "" } else { ":" }) +
                names(segments, "/") +
                (match version {
                  Some(v) => "@" + v
                  None => ""
                }),
              ),
            )
          Rename(name~, renamed~) =>
            out.push(
              literal(
                identifier(name) +
                (match renamed {
                  Some(n) => " as " + identifier(n)
                  None => ""
                }),
              ),
            )
          Field(name~, attributes=attrs, ty~) => {
            attributes(out, attrs)
            out.push(literal(identifier(name) + ": "))
            out.push(child(ty))
          }
          Case(name~, attributes=attrs, payload~) => {
            attributes(out, attrs)
            out.push(literal(identifier(name)))
            if payload is Some(ty) {
              out.push(literal("("))
              out.push(child(ty))
              out.push(literal(")"))
            }
          }
          Parameter(name~, ty~) => {
            out.push(literal(identifier(name) + ": "))
            out.push(child(ty))
          }
          PrimitiveType(name~) => out.push(literal(name))
          NamedType(name~) => out.push(literal(identifier(name)))
          ListType(element~, length~) => {
            out.push(literal("list<"))
            out.push(child(element))
            if length is Some(length) {
              out.push(literal(", " + length))
            }
            out.push(literal(">"))
          }
          TupleType(elements~) => {
            out.push(literal("tuple<"))
            add_nodes(out, elements, ", ")
            out.push(literal(">"))
          }
          OptionType(payload~) => generic(out, "option", payload)
          ResultType(ok~, error~) => {
            out.push(literal("result"))
            if ok is Some(ty) {
              out.push(literal("<"))
              out.push(child(ty))
              if error is Some(err) {
                out.push(literal(", "))
                out.push(child(err))
              }
              out.push(literal(">"))
            } else if error is Some(err) {
              out.push(literal("<_, "))
              out.push(child(err))
              out.push(literal(">"))
            }
          }
          OwnType(resource~) => generic(out, "own", resource)
          BorrowType(resource~) => generic(out, "borrow", resource)
          FutureType(payload~) =>
            if payload is Some(ty) {
              generic(out, "future", ty)
            } else {
              out.push(literal("future"))
            }
          StreamType(payload~) =>
            if payload is Some(ty) {
              generic(out, "stream", ty)
            } else {
              out.push(literal("stream"))
            }
          MapType(key~, value~) => {
            out.push(literal("map<"))
            out.push(child(key))
            out.push(literal(", "))
            out.push(child(value))
            out.push(literal(">"))
          }
          Error(..) => return Err(RecoveryNode(index))
        }
        for next in out.rev_iter() {
          pending.push(next)
        }
      }
    }
  }
  let parsed = @parser.parse(raw.to_string(), features=@parser.Features::all())
  if !parsed.is_valid() || !tree.equivalent(parsed.ast) {
    return Err(Unrepresentable)
  }
  guard @layout.render(parsed.cst, indent_width) is Some(text) else {
    return Err(Unrepresentable)
  }
  let reparsed = @parser.parse(text, features=@parser.Features::all())
  if !reparsed.is_valid() || !tree.equivalent(reparsed.ast) {
    return Err(Unrepresentable)
  }
  Ok(text)
}

///|
pub extend PrintError with Eq::{equal, not_equal}

///|
pub extend PrintError with @debug.Debug::{to_repr}
