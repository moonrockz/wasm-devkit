# Inventory and component splitting

`moonrockz/wac/decompiler` inspects supported core-module and component binaries
without executing them. `inventory` returns an immutable preorder inventory and
flat signature graph. `split` returns immutable named WAC and WAT documents.
Neither operation performs filesystem, network or subprocess I/O.

```moon.pkg
import {
  "moonrockz/wac/decompiler",
} for "test"
```

## Inspect before printing

```mbt check
///|
test "inventory: inspect an empty component without producing WAT" {
  let bytes = b"\x00asm\x0d\x00\x01\x00"
  let inventory = @decompiler.inventory(bytes).unwrap()
  assert_eq(inventory.entries.length(), 1)
  assert_eq(inventory.entries[0].id, "root")
  assert_eq(inventory.entries[0].kind, @decompiler.Component)
  assert_true(inventory.entries[0].world is Some(_))
  assert_true(inventory.to_json().stringify().contains("\"schema-version\":1"))
}
```

Every physical nested component and core module has an entry, including modules
inside a component that stays together during splitting. Component contracts
refer to `types` by arena index. A world describes ordered imports and exports;
its child types retain names, function parameters/results, resources and uses.
Core-module entries carry complete import/export contracts directly.
Memory `page-size-log2` is the binary exponent; null means the default 16. Inventory
uses the verifier's profile and does not need the narrower WAT print profile.

`to_json()` emits schema version 1. Its flat `types` table keeps input-controlled
nesting out of JSON serialization. Core UInt64 limits are decimal strings.
`to_text()` lists the entries and the same complete signature table.

## Split components

```mbt check
///|
test "split: an empty composition becomes a WAC root" {
  let bytes = b"\x00asm\x0d\x00\x01\x00"
  let split = @decompiler.split(bytes).unwrap()
  assert_eq(split.documents.length(), 1)
  assert_eq(split.documents[0].path, "root.wac")
  assert_eq(split.documents[0].text, "package split:root;\n")
}
```

A pure composition becomes WAC. Its nested components become dependencies,
recursively split by the same rule. Any core module, core instance, core type,
core alias, runtime resource definition, canonical definition or start section
makes a component a WAT leaf. A leaf keeps its core modules and nested components
inline. A core-module input also stays one WAT document. Core modules never become
separate split targets. Type-only packages use a WAT metadata carrier to retain
encoded name attributes exactly.

WAC package dependencies can be WAC source as well as WAT/binary components. The
CLI resolves that dependency DAG with the verifier, without running a composer.
The full generated set must verify before `split` returns any documents. Each
WAT dependency compiles independently through the retained component compiler.

Ordinary WAC describes the wiring. Additional WAT dependencies carry signatures,
forward inline instances, invoke component values or retain export ascriptions.
When a concrete component is used as a runtime value, a factory dependency
exports its original body. These factories retain component identity and do not
replace the component's independently generated WAC document.

Extraction closes lexical aliases. Pure type metadata is declared in the new
containing component; captured module/component values and nominal types become
explicit `capture-*` imports. The parent WAC supplies those arguments. A selected
leaf with captures therefore compiles independently, while its caller must supply
its captured values. The original body retains its local indices inside a wrapper.

## Names and selection

Entries use path-qualified IDs. Each path segment uses the first component/module
export name, then the optional binary name, otherwise its binary index. Sort and
index suffixes disambiguate names. Package keys include a readable label and the
SHA-256 of the complete ID; filesystem names stay bounded even for deep inputs.
Document paths are relative, portable paths below `deps/split/`, with `root.wac`
or `root.wat` for the root.

```mbt check
///|
test "split: omitted, empty and invalid selections are different" {
  let bytes = b"\x00asm\x0d\x00\x01\x00"
  assert_eq(@decompiler.split(bytes).unwrap().documents.length(), 1)
  assert_eq(
    @decompiler.split(bytes, select=Some([])).unwrap().documents.length(),
    0,
  )
  assert_true(@decompiler.split(bytes, select=Some(["missing"])) is Err(_))
}
```

`None` selects all. `Some([])` selects none. Other selectors are exact component
IDs from the inventory. Unknown IDs and core-module selectors fail explicitly.
A selected subset includes only those component documents and their applicable
adapters. An adapter containing an unselected component body is omitted. Selected
WAC documents may consequently refer to omitted dependencies, which callers must
supply separately to verify or compose the subset. A WAT leaf continues to keep
its inline contents together.

All errors return diagnostics with source provenance and no partial document
collection. `WAC-D001` reports invalid inventory input, `WAC-D003` reports selection
or closure constraints, and `WAC-D004` reports a print, compilation or generated
composition failure. Unsupported proposals follow the existing verifier and text
compiler profiles. This operation does not claim wasm-tools/WABT print compatibility.

Splitting uses the retained WAT compiler's existing limits, including 64 levels
of core control/expression nesting. Inputs beyond those text limits return a
diagnostic and no documents, even when inventory and single-document printing
accept the binary.

Tests cover immutable contracts, arbitrary bytes and prefixes, nominal resource
relationships, imported and concrete component values, outer aliases, ascriptions,
selected subsets and deep compositions on wasm, wasm-gc, JavaScript and native.
Beads: `wasm-devkit-p5m.13.3`.
