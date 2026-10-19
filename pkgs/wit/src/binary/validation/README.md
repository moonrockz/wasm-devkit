# Component validator compatibility patch

This directory retains the validator from `Milky2018/wasm_component@0.16.0`,
upstream [wasmoon](https://github.com/Milky2018/wasmoon) commit
`397eb299e696d54cbc3bdcb095a5f535a74ad317`. Each original source file was
compared byte-for-byte with the published package before applying local changes.
`UPSTREAM.sha256` records those original hashes; `LOCAL.patch` records the
reviewable changes against that baseline. The Apache-2.0 license and
upstream third-party notices are retained here.

The parser, binary model and core validator remain pinned external dependencies.
This local validator adds modern component accessor-name validation needed by the
wasm-tools 1.262.0 WIT encoding profile. It also retains instance exported type
aliases and nominal resource IDs, checks original resource signatures, and enforces
preceding getter/property-type matching. Current-scope outer aliases preserve
type indices, nominal resource IDs and effective sizes. Constructor and accessor signatures reject
async forms where the reference forbids them. Its original encoded names and signatures
remain available to all semantic checks. The enclosing binary package guards
physical input nesting and separately checks pinned memory64 layout limits.

Tests in the enclosing binary and verifier packages compare original encoded
fixtures with the pinned wasm-tools validator and wit-parser resolver. This patch
is part of Beads task `wasm-devkit-p5m.8.1.5`; it does not establish complete
upstream component conformance by itself.

Functional changes are marked in `prelude.mbt`, `core_type.mbt` and
`component_type_sig.mbt` and `canon_abi.mbt`; other retained sources have local formatting changes. `moon.pkg` removes an unused hashset import. The retained
validator's core imports are pinned directly to `Milky2018/wasm_core@0.16.0`.
Original white-box tests are retained alongside the source. New fixtures compare
constructors, nominal method receivers, ordinary/static/async functions, free and
resource accessors, fallible accessors, transparent aliases and invalid pairs.
