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
    out.write_string(name)
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
/// Canonical source for a complete WAC file AST. All syntax descent is scheduled
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
        let is_inline = match scope {
          Inline => true
          File | Other => false
        }
        let out = []
        match tree.nodes[index].data {
          File(directive~, statements~) => {
            if directive is Some(header) {
              out.push(child(header))
            }
            add_nodes(out, statements, " ", scope=File)
          }
          Package(path~, targets~) => {
            out.push(literal("package "))
            out.push(child(path))
            if targets is Some(target) {
              out.push(literal(" targets "))
              out.push(child(target))
            }
            out.push(literal("; "))
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
          Interface(name~, items~) => {
            out.push(
              literal(
                if is_inline {
                  "interface"
                } else {
                  "interface " + identifier(name)
                },
              ),
            )
            body(out, items, Other)
          }
          World(name~, items~) => {
            out.push(literal("world " + identifier(name)))
            body(out, items, Other)
          }
          Resource(name~, methods~, has_body~) => {
            out.push(literal("resource " + identifier(name)))
            if has_body {
              body(out, methods, Other)
            } else {
              out.push(literal("; "))
            }
          }
          Alias(name~, ty~) => {
            out.push(literal("type " + identifier(name) + " = "))
            out.push(child(ty))
            out.push(literal("; "))
          }
          Record(name~, fields~) => {
            out.push(literal("record " + identifier(name) + " { "))
            add_nodes(out, fields, ", ")
            out.push(literal(" } "))
          }
          Flags(name~, cases~) | Enum(name~, cases~) | Variant(name~, cases~) => {
            let word = match tree.nodes[index].data.kind() {
              Flags => "flags"
              Enum => "enum"
              _ => "variant"
            }
            out.push(literal(word + " " + identifier(name) + " { "))
            add_nodes(out, cases, ", ")
            out.push(literal(" } "))
          }
          Function(name~, signature~, is_static~) => {
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
          Constructor(params~) => {
            out.push(literal("constructor("))
            add_nodes(out, params, ", ")
            out.push(literal("); "))
          }
          Signature(asynchronous~, params~, result=returns) => {
            out.push(
              literal((if asynchronous { "async " } else { "" }) + "func("),
            )
            add_nodes(out, params, ", ")
            out.push(literal(")"))
            result(out, returns)
          }
          NamedResults(params~) => {
            out.push(literal("("))
            add_nodes(out, params, ", ")
            out.push(literal(")"))
          }
          Import(binding~, renamed~, ty~) => {
            out.push(literal("import " + identifier(binding)))
            if renamed is Some(name) {
              out.push(literal(" as "))
              out.push(child(name))
            }
            out.push(literal(": "))
            out.push(
              child(
                ty,
                scope=if tree.nodes[ty].data.kind() == Interface {
                  Inline
                } else {
                  Other
                },
              ),
            )
            out.push(literal("; "))
          }
          WorldImport(name~, target~) | WorldExport(name~, target~) => {
            out.push(
              literal(
                if tree.nodes[index].data.kind() == WorldImport {
                  "import "
                } else {
                  "export "
                },
              ),
            )
            if name is Some(name) {
              out.push(literal(identifier(name) + ": "))
            }
            out.push(
              child(
                target,
                scope=if tree.nodes[target].data.kind() == Interface {
                  Inline
                } else {
                  Other
                },
              ),
            )
            out.push(literal("; "))
          }
          Use(path~, names=selected) => {
            out.push(literal("use "))
            out.push(child(path))
            out.push(literal(".{"))
            add_nodes(out, selected, ", ")
            out.push(literal("}; "))
          }
          Include(path~, renames~) => {
            out.push(literal("include "))
            out.push(child(path))
            if !renames.is_empty() {
              out.push(literal(" with { "))
              add_nodes(out, renames, ", ")
              out.push(literal(" }"))
            }
            out.push(literal("; "))
          }
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
          Field(name~, ty~) | Parameter(name~, ty~) => {
            out.push(literal(identifier(name) + ": "))
            out.push(child(ty))
          }
          Case(name~, payload~) => {
            out.push(literal(identifier(name)))
            if payload is Some(ty) {
              out.push(literal("("))
              out.push(child(ty))
              out.push(literal(")"))
            }
          }
          PrimitiveType(name~) => out.push(literal(name))
          NamedType(name~) => out.push(literal(identifier(name)))
          ListType(element~) => generic(out, "list", element)
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
          BorrowType(resource~) => generic(out, "borrow", resource)
          FutureType(payload~) | StreamType(payload~) => {
            let word = if tree.nodes[index].data.kind() == FutureType {
              "future"
            } else {
              "stream"
            }
            if payload is Some(ty) {
              generic(out, word, ty)
            } else {
              out.push(literal(word))
            }
          }
          Let(name~, expression~) => {
            out.push(literal("let " + identifier(name) + " = "))
            out.push(child(expression))
            out.push(literal("; "))
          }
          Export(expression~, renamed~, spread~) => {
            out.push(literal("export "))
            out.push(child(expression))
            if spread {
              out.push(literal("..."))
            }
            if renamed is Some(name) {
              out.push(literal(" as "))
              out.push(child(name))
            }
            out.push(literal("; "))
          }
          Name(value~, quoted~) =>
            out.push(
              literal(
                if quoted {
                  "\"" + value + "\""
                } else {
                  identifier(value)
                },
              ),
            )
          Expression(primary~, postfix~) => {
            out.push(child(primary))
            add_nodes(out, postfix, "")
          }
          Reference(name~) | InferredArgument(name~) =>
            out.push(literal(identifier(name)))
          Group(expression~) => {
            out.push(literal("("))
            out.push(child(expression))
            out.push(literal(")"))
          }
          New(component~, arguments~) => {
            out.push(literal("new "))
            out.push(child(component))
            out.push(literal(" { "))
            add_nodes(out, arguments, ", ")
            out.push(literal(" }"))
          }
          SpreadArgument(name~) => out.push(literal("..." + identifier(name)))
          NamedArgument(name~, value~) => {
            out.push(child(name))
            out.push(literal(": "))
            out.push(child(value))
          }
          FillArgument => out.push(literal("..."))
          Access(name~, quoted~) =>
            out.push(
              literal(
                if quoted {
                  "[\"" + name + "\"]"
                } else {
                  "." + identifier(name)
                },
              ),
            )
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
