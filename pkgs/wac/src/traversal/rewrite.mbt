///|
/// Replace uses rewritten child IDs from the candidate node. Subtree imports a
/// standalone tree; imported spans are anchored at the replaced source position.
///
/// Replace a leaf with a standalone immutable fragment.
///
/// Example imports: `moonrockz/wac/ast` as `@ast`, `moonrockz/wac/parser` as `@parser`, `moonrockz/wac/traversal` as `@traversal`.
///
/// ```mbt check
/// test "Edit: Replace a leaf with a standalone immutable fragment" {
///   let parsed = @parser.parse(
///     "package demo:app; interface api { type byte = u8; }",
///   )
///   let fragment : @ast.Tree = {
///     nodes: [
///       { data: PrimitiveType(name="bool"), span: { start: 0, end: 0, }, },
///       { data: OptionType(payload=0), span: { start: 0, end: 0, }, },
///     ],
///   }
///   let changed = @traversal.rewrite(parsed.ast, (_view, node) => {
///     if node.data == PrimitiveType(name="u8") {
///       Subtree(fragment)
///     } else {
///       Keep
///     }
///   }).unwrap()
///   assert_true(changed.tree.validate())
///   assert_eq(changed.tree.nodes.length(), parsed.ast.nodes.length() + 1)
///   assert_eq(fragment.nodes[1].span, { start: 0, end: 0, })
/// }
/// ```
pub(all) enum Edit {
  Keep
  Replace(@ast.Data)
  Subtree(@ast.Tree)
}

///|
/// Reject an invalid input arena, a replacement that breaks tree invariants, or an invalid text edit range.
/// Invalid syntax after a valid text edit is returned in the successful Parse value instead.
pub(all) enum RewriteError {
  InvalidTree
  InvalidReplacement(Int32)
  InvalidTextEdit(Int32)
} derive(Eq, Debug)

///|
/// A validated immutable output tree and event report. A stopped rewrite returns the original tree.
///
/// The replacement fragment adds a node before its parent is edited. The parent callback
/// uses the candidate's output child ID. Looking that ID up in the original arena would be
/// incorrect. Imported fragments are copied as supplied; the callback does not revisit their nodes.
///
/// Example imports: `moonrockz/wac/parser` as `@parser`, `moonrockz/wac/ast` as `@ast`, `moonrockz/wac/traversal` as `@traversal`.
///
/// ```mbt check
/// test "Rewritten: Compose rewrites using candidate child IDs" {
///   let original = @parser.parse(
///       "package demo:app; interface api { type wrapped = option<u8>; }",
///     ).ast
///   let fragment : @ast.Tree = {
///     nodes: [
///       { data: PrimitiveType(name="bool"), span: { start: 0, end: 0, }, },
///       { data: OptionType(payload=0), span: { start: 0, end: 0, }, },
///     ],
///   }
///   let changed = @traversal.rewrite(original, (_view, candidate) => {
///     match candidate.data {
///       PrimitiveType(name="u8") => Subtree(fragment)
///       OptionType(payload~) => Replace(ListType(element=payload))
///       _ => Keep
///     }
///   }).unwrap()
///   let expected = @parser.parse(
///       "package demo:app; interface api { type wrapped = list<option<bool>>; }",
///     ).ast
///   assert_true(changed.tree.equivalent(expected))
///   assert_true(original.nodes.any(node => node.data == PrimitiveType(name="u8")))
/// }
/// ```
pub(all) struct Rewritten {
  tree : @ast.Tree
  report : Report
}

///|
/// Copy an unvisited original subtree with an explicit postorder stack.
fn copy_original(
  tree : @ast.Tree,
  root : Int32,
  mapping : Array[Int32],
  output : Array[@ast.Node],
) -> Unit {
  let stack = [(root, false)]
  while stack.pop() is Some((index, leave)) {
    if mapping[index] >= 0 {
      continue
    }
    let node = tree.nodes[index]
    if leave {
      mapping[index] = output.length()
      output.push({
        ..node,
        data: node.data.map_children(child => mapping[child]),
      })
    } else {
      stack.push((index, true))
      for child in node.data.children().rev_iter() {
        stack.push((child, false))
      }
    }
  }
}

///|
/// Remove nodes dropped by edits, checking references before indexing them.
fn compact(nodes : Array[@ast.Node], root : Int32) -> @ast.Tree? {
  guard root >= 0 && root < nodes.length() else { return None }
  let reachable = Array::make(nodes.length(), false)
  let pending = [root]
  while pending.pop() is Some(index) {
    if reachable[index] {
      continue
    }
    reachable[index] = true
    for child in nodes[index].data.children() {
      guard child >= 0 && child < index else { return None }
      pending.push(child)
    }
  }
  let mapping = Array::make(nodes.length(), -1)
  let kept = []
  for index, node in nodes {
    if !reachable[index] {
      continue
    }
    mapping[index] = kept.length()
    kept.push({ ..node, data: node.data.map_children(child => mapping[child]), })
  }
  let tree : @ast.Tree = { nodes: ReadOnlyArray::from_array(kept), }
  if tree.validate() {
    Some(tree)
  } else {
    None
  }
}

///|
/// Bottom-up immutable rewrite. The callback receives source metadata and a node
/// whose direct child IDs already refer to rewritten output. Pruned descendants
/// are copied unchanged, and the pruned root is still editable. Stop cancels the
/// transaction and returns the original tree. Invalid edits return an error.
///
/// Change a type without mutating the parsed tree.
///
/// Example imports: `moonrockz/wac/parser` as `@parser`, `moonrockz/wac/traversal` as `@traversal`.
///
/// ```mbt check
/// test "rewrite: Change a type without mutating the parsed tree" {
///   let parsed = @parser.parse(
///     "package demo:app; interface api { type byte = u8; }",
///   )
///   let changed = @traversal.rewrite(parsed.ast, (_view, node) => {
///     match node.data {
///       PrimitiveType(name="u8") => Replace(PrimitiveType(name="u64"))
///       _ => Keep
///     }
///   }).unwrap()
///   assert_true(changed.tree.validate())
///   assert_true(
///     parsed.ast.nodes.any(node => node.data == PrimitiveType(name="u8")),
///   )
///   assert_false(
///     changed.tree.nodes.any(node => node.data == PrimitiveType(name="u8")),
///   )
///   assert_true(
///     changed.tree.nodes.any(node => node.data == PrimitiveType(name="u64")),
///   )
/// }
/// ```
pub fn rewrite(
  tree : @ast.Tree,
  edit : (View, @ast.Node) -> Edit,
  decide~ : (Event) -> Control = default_decision,
) -> Result[Rewritten, RewriteError] {
  guard Reader::new(Ast(tree), decide~) is Some(reader) else {
    return Err(InvalidTree)
  }
  let mapping = Array::make(tree.nodes.length(), -1)
  let pruned = Array::make(tree.nodes.length(), false)
  let output = []
  while reader.next() is Some(event) {
    if reader.stopped {
      return Ok({ tree, report: reader.report(), })
    }
    let index = event.view.index
    if event.phase == Enter {
      pruned[index] = reader.last_control == Prune
      continue
    }
    let original = tree.nodes[index]
    if pruned[index] {
      for child in original.data.children() {
        copy_original(tree, child, mapping, output)
      }
    }
    let candidate : @ast.Node = {
      ..original,
      data: original.data.map_children(child => mapping[child]),
    }
    let next = match edit(event.view, candidate) {
      Keep => candidate
      Replace(data) => { ..candidate, data, }
      Subtree(replacement) => {
        if !replacement.validate() {
          return Err(InvalidReplacement(index))
        }
        let offset = output.length()
        for i, node in replacement.nodes {
          let span : @span.Span = if i == replacement.nodes.length() - 1 {
            original.span
          } else {
            { start: original.span.start, end: original.span.start, }
          }
          output.push({
            data: node.data.map_children(child => child + offset),
            span,
          })
        }
        mapping[index] = output.length() - 1
        continue
      }
    }
    output.push(next)
    mapping[index] = output.length() - 1
  }
  match compact(output, mapping[tree.nodes.length() - 1]) {
    None => Err(InvalidReplacement(tree.nodes.length() - 1))
    Some(next) => Ok({ tree: next, report: reader.report(), })
  }
}

///|
///
/// Distinguish bad edit ranges from invalid edited syntax.
///
/// Example imports: `moonrockz/wac/parser` as `@parser`, `moonrockz/wac/traversal` as `@traversal`.
///
/// ```mbt check
/// test "TextEdit: Distinguish bad edit ranges from invalid edited syntax" {
///   let parsed = @parser.parse(
///     "package demo:app; interface api { type byte = u8; }",
///   )
///   let bad_range = @traversal.rewrite_cst(parsed.cst, [
///     { span: { start: -1, end: 0, }, text: "", },
///   ])
///   assert_true(bad_range is Err(InvalidTextEdit(0)))
///   let damaged = @traversal.rewrite_cst(parsed.cst, [
///     { span: { start: 0, end: 0, }, text: "?", },
///   ]).unwrap()
///   // Applying a valid edit succeeds even when the new document is invalid.
///   assert_false(damaged.is_valid())
///   assert_true(damaged.cst.to_source().has_prefix("?"))
/// }
/// ```
pub(all) struct TextEdit {
  span : @span.Span
  text : String
}

///|
/// Apply ordered, nonoverlapping UTF-16 source edits and reparse the concrete
/// tree. Invalid syntax is returned with diagnostics, while malformed edit ranges
/// return Err. The original CST remains unchanged. Equal-position insertions use
/// their collection order. Callers choose the same syntax profile as parsing.
///
/// Apply an editor change while preserving surrounding comments.
///
/// Example imports: `moonrockz/wac/parser` as `@parser`, `moonrockz/wac/traversal` as `@traversal`.
///
/// ```mbt check
/// test "rewrite_cst: Apply an editor change while preserving surrounding comments" {
///   let source = "// keep\npackage demo:app; interface api { type byte = u8; }"
///   let parsed = @parser.parse(source)
///   let byte_type = parsed.ast.nodes
///     .iter()
///     .find_first(node => node.data == PrimitiveType(name="u8"))
///     .unwrap()
///   let changed = @traversal.rewrite_cst(parsed.cst, [
///     { span: byte_type.span, text: "u64", },
///   ]).unwrap()
///   assert_true(changed.is_valid())
///   assert_true(changed.cst.to_source().contains("type byte = u64;"))
///   assert_true(changed.cst.to_source().has_prefix("// keep\n"))
///   assert_eq(parsed.cst.to_source(), source)
/// }
/// ```
pub fn rewrite_cst(
  tree : @cst.Tree,
  edits : ReadOnlyArray[TextEdit],
  features~ : @parser.Features = @parser.Features::default(),
) -> Result[@parser.Parse, RewriteError] {
  if !tree.validate() {
    return Err(InvalidTree)
  }
  let source = tree.to_source()
  let out = StringBuilder()
  let mut at = 0
  for i, change in edits {
    let span = change.span
    if span.start < at || span.end < span.start || span.end > source.length() {
      return Err(InvalidTextEdit(i))
    }
    out.write_string(source.unsafe_substring(start=at, end=span.start))
    out.write_string(change.text)
    at = span.end
  }
  out.write_string(source.unsafe_substring(start=at, end=source.length()))
  Ok(@parser.parse(out.to_string(), features~))
}

///|
pub extend RewriteError with Eq::{equal, not_equal}

///|
pub extend RewriteError with @debug.Debug::{to_repr}
