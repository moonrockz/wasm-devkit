///|
/// Concrete grammar node. Token ranges are half-open indices into Tree::tokens,
/// including internal trivia. Child indices are postorder, matching the AST arena.
pub(all) struct Node {
  kind : @ast.Kind
  span : @span.Span
  first_token : Int32
  last_token : Int32
  children : ReadOnlyArray[Int32]
} derive(Eq, Debug)

///|
/// Tokens own every input code unit, including text skipped during recovery.
/// Root is the last node. No tree operation recurses through syntax nesting.
pub(all) struct Tree {
  tokens : ReadOnlyArray[@scanner.Token]
  nodes : ReadOnlyArray[Node]
} derive(Eq, Debug)

///|
///
/// Reconstruct a concrete subtree and the complete file.
///
/// Example imports: `moonrockz/wit/cst` as `@cst`, `moonrockz/wit/parser` as `@parser`.
///
/// ```mbt check
/// test "Tree::to_source: Reconstruct a concrete subtree and the complete file" {
///   let source = "// leading\ninterface api {} // trailing"
///   let parsed = @parser.parse(source)
///   let concrete : @cst.Tree = parsed.cst
///   let root = concrete.nodes.length() - 1
///   assert_eq(concrete.to_source(), source)
///   assert_eq(concrete.node_source(root), Some(source))
///   assert_eq(concrete.node_source(-1), None)
///   for id, node in concrete.nodes {
///     if node.kind == Interface {
///       assert_true(
///         concrete.node_source(id).unwrap().contains("interface api {}"),
///       )
///       assert_true(node.first_token < node.last_token)
///     }
///   }
/// }
/// ```
pub fn Tree::to_source(self : Tree) -> String {
  let out = StringBuilder()
  for token in self.tokens {
    out.write_string(token.text)
  }
  out.to_string()
}

///|
///
/// Reconstruct a concrete subtree and the complete file.
///
/// Example imports: `moonrockz/wit/cst` as `@cst`, `moonrockz/wit/parser` as `@parser`.
///
/// ```mbt check
/// test "Tree::node_source: Reconstruct a concrete subtree and the complete file" {
///   let source = "// leading\ninterface api {} // trailing"
///   let parsed = @parser.parse(source)
///   let concrete : @cst.Tree = parsed.cst
///   let root = concrete.nodes.length() - 1
///   assert_eq(concrete.to_source(), source)
///   assert_eq(concrete.node_source(root), Some(source))
///   assert_eq(concrete.node_source(-1), None)
///   for id, node in concrete.nodes {
///     if node.kind == Interface {
///       assert_true(
///         concrete.node_source(id).unwrap().contains("interface api {}"),
///       )
///       assert_true(node.first_token < node.last_token)
///     }
///   }
/// }
/// ```
pub fn Tree::node_source(self : Tree, index : Int32) -> String? {
  guard self.nodes.get(index) is Some(node) &&
    node.first_token >= 0 &&
    node.last_token >= node.first_token &&
    node.last_token <= self.tokens.length() else {
    return None
  }
  let out = StringBuilder()
  for i in node.first_token..<node.last_token {
    out.write_string(self.tokens[i].text)
  }
  Some(out.to_string())
}

///|
///
/// Validate concrete data before navigating it.
///
/// Example imports: `moonrockz/wit/cst` as `@cst`.
///
/// ```mbt check
/// test "Tree::validate: Validate concrete data before navigating it" {
///   let empty : @cst.Tree = { tokens: [], nodes: [], }
///   assert_false(empty.validate())
///   assert_eq(empty.node_source(0), None)
///   assert_eq(empty.to_source(), "")
/// }
/// ```
pub fn Tree::validate(self : Tree) -> Bool {
  guard !self.nodes.is_empty() && !self.tokens.is_empty() else { return false }
  let parents = Array::make(self.nodes.length(), 0)
  let mut offset = 0
  for i, token in self.tokens {
    guard token.span.start == offset &&
      token.span.length() == token.text.length() else {
      return false
    }
    if token.kind == Eof {
      guard i == self.tokens.length() - 1 && token.text == "" else {
        return false
      }
    } else {
      guard token.span.length() > 0 else { return false }
    }
    offset = token.span.end
  }
  guard self.tokens[self.tokens.length() - 1].kind == Eof else { return false }
  for i, node in self.nodes {
    guard node.first_token >= 0 &&
      node.last_token >= node.first_token &&
      node.last_token <= self.tokens.length() &&
      node.span.start >= 0 &&
      node.span.start <= node.span.end &&
      node.span.end <= offset else {
      return false
    }
    let expected_start = if node.first_token < self.tokens.length() {
      self.tokens[node.first_token].span.start
    } else {
      offset
    }
    let expected_end = if node.last_token < self.tokens.length() {
      self.tokens[node.last_token].span.start
    } else {
      offset
    }
    guard node.span.start == expected_start && node.span.end == expected_end else {
      return false
    }
    let mut previous = node.first_token
    for child in node.children {
      guard child >= 0 && child < i else { return false }
      let c = self.nodes[child]
      guard node.span.contains(c.span) &&
        c.first_token >= node.first_token &&
        c.last_token <= node.last_token else {
        return false
      }
      guard c.first_token >= previous else { return false }
      previous = c.last_token
      parents[child] += 1
      guard parents[child] == 1 else { return false }
    }
  }
  for i in 0..<(parents.length() - 1) {
    guard parents[i] == 1 else { return false }
  }
  let root = self.nodes[self.nodes.length() - 1]
  root.span == { start: 0, end: offset, } &&
  root.first_token == 0 &&
  root.last_token == self.tokens.length() &&
  parents[parents.length() - 1] == 0
}

///|
pub extend Node with Eq::{equal, not_equal}

///|
pub extend Tree with Eq::{equal, not_equal}

///|
pub extend Node with @debug.Debug::{to_repr}

///|
pub extend Tree with @debug.Debug::{to_repr}
