# WIT printer

`print(tree, indent_width=2)` returns canonical WIT source for a complete file AST.
It returns `Result[String, PrintError]` and never returns partial output.
All syntax descent uses an explicit command stack. The printer supports every
implemented WIT node and proposal form, including named imports, nested package paths,
fixed-length lists and accessors.

Printing emits valid source and checks that parsing it preserves the typed AST,
ignoring source locations and arena numbering. `Tree::equivalent(other)` implements
that comparison with an explicit pair stack. Named field roles, optional/list shapes,
function flags, names and scalar metadata still participate in equality.

## Canonical layout

Output uses LF line endings, a final newline for nonempty files, one declaration per
line and block indentation. Empty blocks stay inline. Records, flags, enums and variants
put members on separate lines. Use selectors, include renames, parameters and generic
types remain inline. There is no width-based wrapping. `indent_width` accepts zero through
eight spaces. Printing the same AST with the same options is deterministic.

Reserved identifiers receive `%` escapes. Namespace/package colons stay tight, while
field and named-import colons receive a following space. Attributes precede their
items on separate lines. Optional trailing commas and empty include rename syntax
are normalized from the AST's field values. External-ID string spellings and numeric
spellings are retained because those are scalar AST metadata.

The AST omits trivia, so use the formatter to retain comments from concrete source.
ASTs also omit proposal activation state. Printed source is checked with all implemented
features enabled; callers can apply a narrower parser profile when needed.

## Invalid input

| Error | Meaning |
|-------|---------|
| `InvalidTree` | Arena references, ownership, spans or child order are invalid |
| `InvalidRoot` | The root is not a complete file |
| `InvalidOptions` | Indentation is outside zero through eight |
| `RecoveryNode(index)` | A retained error node cannot be printed as valid WIT |
| `Unrepresentable` | The typed fields cannot round-trip through supported WIT syntax |

A recovered AST without error nodes can still be representable, for example after a
missing delimiter. Callers requiring valid original source must inspect `Parse::is_valid()`
before printing. Semantic resolution remains separate from syntax printing.

## Validation

Every printable node kind is covered, with explicit rejection of recovery nodes.
Tests run the 321 pinned wasm-tools files and 68 Component Model examples from the parser's
licensed fixture snapshots. Any successful print must reparse to equivalent structure and
print identically again. Tests also include 400 seeded nested-type cases, reserved names,
invalid hand-built trees, proposal forms, 18,000 nested types and 1,200 nested package
blocks on wasm, wasm-gc, js and native.
