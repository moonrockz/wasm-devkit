# WAC WIT providers

Original Apache-2.0 probes against WAC 0.12.0 revision
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, using its exact
`wit-parser` and `wit-component` 0.258.0 dependencies. `cases.tsv` records
WIT encoding, `Document::resolve`, and CLI resolution exit statuses. A dash
means the earlier encoding step rejected the input.

`wit_package_test.mbt` checks these immutable source closures against ordered
reference package and composition projections. The projections compare item
sorts, canonical names, implicit uses, and nominal resource equivalence without
comparing implementation arena IDs. The source files retain rejected cases.
`bundle-file-deps` tests filesystem discovery only: a single WIT file does not
load its sibling `deps` directory. An explicit CLI dependency mapping must be a
file, while automatic directory lookup discovers WIT dependencies. Directory
cases are tested through automatic lookup and through caller-supplied closures.

Coverage includes type-wrapper instantiation/access, interface and world imports,
resource capture and fresh binders, forward declarations, named/inline instances,
transitive closures, nested packages, lookup versions, scalar and aggregate uses,
async functions, fixed lists, maps, external IDs and source feature rejection.
This fixture set does not establish complete WAC conformance.

`wac-semantic-reference --encode-wit INPUT OUTPUT` reproduces the intermediate
package encoding. `--package lookup:types OUTPUT` emits its package graph; the
normal oracle invocation with `--dependency lookup:types OUTPUT` emits the WAC
graph. Versioned lookup uses `lookup:types@1.2.3` for `bundle-versioned`.
The WIT 0.262.0 CLI verifier has a separate profile; WAC rejects source accessors.
`SHA256SUMS` covers the inputs and result table. Tracking: Beads
`wasm-devkit-p5m.8.2.3` and full WAC conformance.
