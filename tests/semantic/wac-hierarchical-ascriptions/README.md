# Hierarchical imported-instance ascriptions

These 29 original Apache-2.0 fixtures compare WAC 0.12.0
`Package::from_bytes`, commit `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`,
and wasm-tools 1.262.0 with all features, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`.
The product agrees on acceptance and compares ordered package/type/resource
projections for every accepted binary and WAT input. `SHA256SUMS` covers the
sources, compiled bytes and acceptance table.

Cases cover four nested instance levels, parent and child re-exports, captured
outer types/resources, independent sibling resource binders, exported value-type
aliases and transitive captures through another imported interface. Crossed
resources and changed value signatures reject. Private graphs preserve binary
type indices; internal value definitions never enter the public binary index
space. Separate contract tests traverse 6,000 scopes and 6,000 value definitions
with explicit stacks and verify the metadata work limit.

These fixtures cover hierarchical function ascriptions. Separate suites cover
concrete runtime components, values and non-function export annotations. Together
they test the documented profile, not universal component-model conformance.
