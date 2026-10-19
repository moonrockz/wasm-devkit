///|
/// Text coordinates count UTF-16 code units; binary coordinates count bytes.
/// A binary offset can be unavailable without inventing a textual position.
pub(all) enum Position {
  SourceSpan(@span.Span)
  BinaryOffset(Int32?)
} derive(Eq, Debug)

///|
pub(all) struct Location {
  source : String
  position : Position
} derive(Eq, Debug)

///|
pub fn Location::text(source : String, span : @span.Span) -> Location {
  { source, position: SourceSpan(span), }
}

///|
pub fn Location::binary(source : String, offset~ : Int32? = None) -> Location {
  { source, position: BinaryOffset(offset), }
}

///|
pub fn Location::span(self : Location) -> @span.Span? {
  match self.position {
    SourceSpan(span) => Some(span)
    BinaryOffset(_) => None
  }
}

///|
pub fn Location::render(self : Location) -> String {
  match self.position {
    SourceSpan(span) => "\{self.source}:[\{span.start},\{span.end})"
    BinaryOffset(Some(offset)) => "\{self.source}:[byte \{offset}]"
    BinaryOffset(None) => "\{self.source}:[binary]"
  }
}

///|
pub(all) struct Label {
  location : Location
  message : String
} derive(Eq, Debug)

///|
/// Semantic errors use stable WAC-S codes. Related locations may refer to
/// another file. All collections are immutable and ordered deterministically.
pub(all) struct Diagnostic {
  code : String
  message : String
  primary : Label
  related : ReadOnlyArray[Label]
} derive(Eq, Debug)

///|
/// A resolved declaration identity within its source and lexical scope.
pub(all) struct Binding {
  name : String
  scope : Int32
  node : Int32
  target : Int32
} derive(Eq, Debug)

///|
/// Construction is private. A value exists only after the entire supported
/// model passes verification. Retained syntax and binding tables are immutable.
pub struct Verified {
  priv source_id : String
  priv source_text : String
  priv composition_nodes : ReadOnlyArray[CompositionNode]
  priv composition_outputs : ReadOnlyArray[CompositionExport]
  priv tree : @ast.Tree
  priv bindings : ReadOnlyArray[Binding]
  priv resolved_types : ReadOnlyArray[ResolvedType]
  priv resolved_declarations : ReadOnlyArray[ResolvedDeclaration]
  priv resolved_imports : ReadOnlyArray[Extern]
  priv resolved_exports : ReadOnlyArray[Extern]
}

///|
pub fn Verified::source(self : Verified) -> String {
  self.source_id
}

///|
pub fn Verified::text(self : Verified) -> String {
  self.source_text
}

///|
pub fn Verified::ast(self : Verified) -> @ast.Tree {
  self.tree
}

///|
pub fn Verified::declarations(self : Verified) -> ReadOnlyArray[Binding] {
  self.bindings
}

///|
fn error(
  source : String,
  span : @span.Span,
  code : String,
  message : String,
) -> Diagnostic {
  {
    code,
    message,
    primary: { location: Location::text(source, span), message, },
    related: [],
  }
}

///|
/// Verify an existing parse. Parse::is_valid retains its syntax-only meaning.
/// No filesystem, network, subprocess or mutable global state is accessed.
pub fn verify(
  parsed : @parser.Parse,
  source_id~ : String = "<input>",
  source~ : String,
  dependencies~ : ReadOnlyArray[PackageSource] = [],
  wit_dependencies~ : ReadOnlyArray[WitPackageSource] = [],
) -> Result[Verified, ReadOnlyArray[Diagnostic]] {
  if !parsed.is_valid() {
    let errors : Array[Diagnostic] = []
    for d in parsed.diagnostics {
      if d.severity == Error {
        errors.push(error(source_id, d.primary.span, d.code, d.message))
      }
    }
    return Err(ReadOnlyArray::from_array(errors))
  }
  verify_ast(parsed.ast, source_id~, source~, dependencies~, wit_dependencies~)
}

///|
/// Render text as UTF-16 ranges and binary metadata as byte offsets. Unknown
/// binary offsets remain distinct from source positions.
pub fn Diagnostic::render(self : Diagnostic) -> String {
  let out = StringBuilder()
  let p = self.primary.location
  out.write_string("\{p.render()}: error \{self.code}: \{self.message}\n")
  for label in self.related {
    let p = label.location
    out.write_string("\{p.render()}: \{label.message}\n")
  }
  out.to_string()
}

///|
pub extend Location with Eq::{equal, not_equal}

///|
pub extend Location with @debug.Debug::{to_repr}

///|
pub extend Label with Eq::{equal, not_equal}

///|
pub extend Label with @debug.Debug::{to_repr}

///|
pub extend Diagnostic with Eq::{equal, not_equal}

///|
pub extend Diagnostic with @debug.Debug::{to_repr}

///|
pub extend Binding with Eq::{equal, not_equal}

///|
pub extend Binding with @debug.Debug::{to_repr}

///|
/// AST names are decoded identifiers. They must satisfy the identifier contract
/// even when the caller did not obtain the tree from the parser.
fn identifier(name : String) -> Bool {
  if name.is_empty() {
    return false
  }
  let mut segment_start = true
  let mut casing = 0
  for i in 0..<name.length() {
    let c = name.code_unit_at(i).to_int()
    if c == 45 {
      if segment_start {
        return false
      }
      segment_start = true
      casing = 0
    } else {
      let lower = c >= 97 && c <= 122
      let upper = c >= 65 && c <= 90
      let digit = c >= 48 && c <= 57
      if (!lower && !upper && !digit) || (i == 0 && digit) {
        return false
      }
      if lower {
        if casing == 2 {
          return false
        }
        casing = 1
      }
      if upper {
        if casing == 1 {
          return false
        }
        casing = 2
      }
      segment_start = false
    }
  }
  !segment_start
}

///|
pub extend Position with Eq::{equal, not_equal}

///|
pub extend Position with @debug.Debug::{to_repr}
