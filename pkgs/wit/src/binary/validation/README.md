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

The declarative package profile also removes obsolete restrictions on root
component imports/exports and re-exported imported functions. Both pinned
wasm-tools 1.262.0 validation and WAC 0.12.0 `Package::from_bytes` accept those
operations. `section_import.mbt` and `section_export.mbt` contain those changes.
`core_type.mbt` checks interface value naming with an explicit work stack,
including fixed lists and map keys/values. These additions are tracked under
`wasm-devkit-p5m.8.2.2`; runtime sections remain outside the public declarative
boundary. The patch does not claim complete component-model conformance.

`restricted_map_keys` defaults to the wasmparser 0.262 rule. The declarative
WAC entry point disables that restriction to match its pinned wasmparser 0.258;
value-type validation still applies to both key and value. Own and borrow types
may be imported or exported when their resource is named, matching both pins.
The original probes in `version_profile_test.mbt` cover these differences and
preserve rejection of missing type indices and unnamed resources.

Imported instances and their aliases now preserve separate import/export naming
visibility. An alias of an imported resource can appear in a later function
import; exporting a local resource does not make it importable. Current-scope
outer aliases and instance re-exports retain that visibility. These changes are
in `section_alias.mbt`, `section_import.mbt`, `section_export.mbt` and
`validate.mbt`. The enclosing framing boundary rejects component values and root
export ascriptions while their legacy parsing/compatibility rules remain
incomplete, including a reference-rejected resource ascription this validator
previously accepted.

Component-type function imports retain resource visibility through imported type
equality aliases, current-scope outer aliases and aliases from imported instances.
Aliases created by exports remain unavailable to imports. Resource visibility
checks use an explicit work stack, including map and fixed-length-list children.

`canonical_version_suffix` defaults to wasmparser 0.262 validation: instance-only
suffixes must be nonempty and split the full SemVer at its canonical track.
Version components use strict u64 SemVer rules. WAC's 0.258 profile accepts any
concatenation yielding a valid version, ignores suffixes on unversioned names,
and leaves `implements` versions unchecked. Both profiles reject malformed UTF-8
attributes, duplicates and suffixes on other sorts. The exact differing cases are
recorded in `../fixtures/version-suffix/`; this is intentional pinned behavior.
