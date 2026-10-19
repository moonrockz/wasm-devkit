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
`wasm-devkit-p5m.8.2.2`; remaining runtime sections stay explicitly bounded by the public
profile. The patch does not claim complete component-model conformance.

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
`validate.mbt`. The enclosing framing boundary rejects component values while their legacy
encoding remains incomplete. Instance and component annotations use the complete
comparisons described below.

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

Root function export ascriptions now compare complete signatures using the original
`ascription.mbt` helper, which is additional wasm-devkit code rather than a retained
upstream file. `ascription_wbtest.mbt` exercises 6,000-level value graphs with an
explicit stack. Changes in `prelude.mbt` and `section_export.mbt` preserve typed
unsupported errors and the ascribed function signature for later re-exports.
The additional `function_signature.mbt` retains complete private signature graphs
for instance-exported aliases. Queue-based extraction keeps local and outer type
indices separate and records nominal resource IDs. Substitution updates the
resource table without changing the graph. Ascription checks compare complete
graphs; the reduced legacy signature equality used by other retained checks is
unchanged. The additional `instance_metadata.mbt` retains hierarchical imported
instance scopes and value aliases. Scope construction, signature normalization
and legacy signature projection use explicit work stacks. A shared one-million
step metadata budget covers imports and ascriptions. Instance aliases and
re-exports preserve graph identities; nested resource declarations receive fresh
IDs from the existing allocator. Private graph definitions never shift binary
type indices. Additional whitebox tests exercise 6,000-level scope/value graphs.
The enclosing declarative framing profile admits function, type-equality and
core-module and supported instance ascriptions. Type annotations use the same explicit-stack value comparator and
nominal resource IDs, including imported instance aliases. Fresh resource
subtype annotations reject as incompatible, matching both pinned validators. The
WIT type-only profile still rejects them all.

Core module contracts use tuple import keys rather than concatenating names with
`:`, decode names as UTF-8, and validate u32/u64 limits with address width and
custom page size. Depth-zero aliases use preceding module-local function slots.
The enclosing declarative codec retains complete unsigned/shared signatures.
Legacy runtime metadata omits extern signatures it cannot represent, including
limits above signed Int64 and shared globals/tables. Flat concrete core modules now validate their original instructions after bounded
preflight. Other runtime sections remain excluded.

Concrete module import keys also use `(module, name)` tuples, so colons cannot
conflate distinct imports. Invalid function bodies reject despite the pinned WAC
package loader skipping their instruction validation.

Core-module export annotations are checked by the enclosing ordered core-scope
pass using complete immutable module contracts. Imported-instance aliases and
re-exports preserve the annotation's contract; later declarations cannot supply
an earlier type index. The retained legacy module tables do not determine this
comparison.

The optional `core_contracts` argument to `validate_component_with_config` carries
immutable core scope metadata from the ordered binary boundary. It is retained
in the current validation scope for full-width module-member checks. Direct
callers may omit it; supplying metadata does not itself prove validity, and
a supplied graph must contain a root scope. Runtime component admission remains
controlled by the binary framing profile.

Instance export annotations compare complete instance metadata with an explicit
work stack in `contract_ascription.mbt`. Function/value shapes and nominal
resource identities are invariant; expected members must exist, while extra
actual members may be hidden. Nested instances share the same cumulative
comparison budget. Complete module contracts come from immutable core-scope
metadata and use the shared module subtype operation. Component members use the
same complete contract comparison. The annotation's metadata replaces the exported alias contract so
later aliases and re-exports cannot recover hidden members or narrower limits.

Imported component annotations use `contract_metadata.mbt` and
`contract_ascription.mbt`, with complete flat scoped metadata and explicit work
stacks. Component imports reverse the comparison direction. Required fresh
resource binders receive directed substitutions, while captures stay fixed;
function and value comparisons retain those substitutions. Expected metadata
replaces the exported component alias contract for subsequent annotation checks.
Runtime component instantiation remains excluded; the older reduced tables are
not proof of these complete contracts. Component and instance aliases preserve
scoped graph nodes. Imported instance metadata seeds concrete resource identities;
nested component binders remain abstract. The shared comparator replaces the
earlier instance-only comparator. Whitebox tests cover 6,000-scope stack safety,
deepest mismatch, cumulative work exhaustion and seeded resource preservation.

Synchronous canonical lift/lower uses an iterative, cached value-shape walk.
It checks complete core signatures and memory/realloc/post-return contracts,
including memory64 pointer widths. Core instance imports and aliases use full
immutable contracts from the ordered scope pass. Core contract work and
canonical shape work each share a 1,000,000-unit allowance across the component.
The current flags profile permits at most 32 members, matching both pins.
Async canonical operations and other intrinsics remain unsupported. Concrete module
bodies still undergo original-byte validation; no substituted body is accepted
as proof of validity.


Canonical resource new/drop/rep checks nominal resource identity before emitting
its core signature. Local i32/i64 representations determine new/rep and destructor
signatures; imported resources permit drop only. Complete core metadata validates
destructors, including i64 representations and result arity. These checks retain
original module bytes and perform no resource operations.

Imported instance and component contracts reject reachable captures of resources
defined by the importing component. The audit follows complete function and
value graphs with explicit stacks and the shared metadata budget; unused outer
definitions and fresh abstract binders remain valid. Missing contract metadata
fails closed when local resources need auditing.
