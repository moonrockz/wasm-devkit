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

`nested-instance` remains a reference-accepted `WAC-B002` exclusion. The retained
validator does not yet carry complete metadata through aliases of nested imported
instances. The missing signature is never replaced by an empty one. This case is
tracked on `wasm-devkit-p5m.8.2.2` for the next hierarchical metadata slice.
