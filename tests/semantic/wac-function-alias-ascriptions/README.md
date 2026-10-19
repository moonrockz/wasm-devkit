# Function alias ascriptions

These 39 original Apache-2.0 fixtures extend the direct-function ascription cases.
They compare WAC 0.12.0 `Package::from_bytes`, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`, with wasm-tools 1.262.0 validation
using all features, commit `e22db44da4eaf17a0e46ec55b911c7539589a3cc`.
`cases.tsv` separates reference and product acceptance; `SHA256SUMS` covers WAT,
compiled bytes and that table.

The tests retain complete async and value-type signatures for instance-exported
function aliases, including maps, fixed lists, future/stream values and nominal
resource handles. Separate instances introduce distinct resource identities.
Outer value/function/resource aliases preserve their defining namespace even
when local type indices collide. Subsequent exports retain the ascribed type.
Accepted binary and WAT package projections match the pinned oracle.

`nested-instance` is supported. The [hierarchical cases](../wac-hierarchical-ascriptions/README.md)
extend it with deeper scopes, resource captures, alias chains and transitive
value-type captures. Separate suites cover the other supported binary forms.
Async lift/lower and component start are in `wac-proposal-profiles/`. Concrete
GC and reference types, exception instructions, shared concrete globals and
limits above signed Int64 stay outside the profile.
