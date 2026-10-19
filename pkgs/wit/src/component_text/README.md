# Component text compatibility patch

This package retains `Milky2018/wasm_component@0.16.0`'s portable text compiler
from wasmoon commit `397eb299e696d54cbc3bdcb095a5f535a74ad317`.
The four original files match both that commit and the published package byte for
byte. `UPSTREAM.sha256` records their hashes, and `LOCAL.patch` reconstructs the
local changes. The upstream Apache-2.0 license and third-party notices are retained.

The patch encodes component value-type indices with signed LEB and supports map
types in declarations and inline value types. Indices accept decimal and hexadecimal
unsigned literals, an optional leading plus and single underscores between digits.
Values above the compiler's signed 32-bit index range are rejected instead of wrapping. The S-expression reader uses an
explicit stack and rejects nesting above 256 before compilation. Existing compiler
helpers operate on that bounded syntax. This is the WIT decoder's compatibility
frontend; it does not establish complete component text conformance.

The retained attribute test now uses the standard `version-suffix` spelling.
The compiler enforces quoted attribute values and their grammar order. Additional tests cover signed-LEB
boundaries, nested map syntax and deep-input rejection. WIT verifier and CLI tests
compare encoded maps and wasi-http against wasm-tools 1.262.0 and wit-parser
0.262.0. This patch is tracked by `wasm-devkit-p5m.8.1.5`.

`normalized.mbt` is this project's strict normalization layer, shared by the WIT
and WAC declarative package decoders. It validates source framing and Unicode,
normalizes quoted names, and preserves custom/producers bytes. Its public
`parse_normalized_component_wat` operation returns compiled bytes; callers must
validate those bytes under their own binary profile before reconstructing types.
Neither byte-compilation entry point eagerly parses an embedded binary component.
The retained compiler rejects the nonstandard `component definition binary` form.

`LOCAL.patch` also records the UTF-8 import used by normalization. The new layer is
original project code rather than a copied upstream file, so it has no upstream
hash. Existing WIT conformance fixtures exercise it alongside the WAC package corpus.

Explicit named outer type aliases resolve against the saved parent bindings.
Automatic aliases in an inline instance/component type cannot overwrite those
parent indices. WAC Fill fixtures compare the resulting imported resource graph
with the binary encoded by the pinned wasm-tools.

The core-module contract patch retains named tag references and their required
zero attribute byte, abstract/non-null references, memory64/table64 limits,
shared globals and custom memory page annotations. Unsigned limits use bounded
u32/u64 parsing with hexadecimal and separator support. Local core type names
and aliases restore their parent bindings after inline type compilation.
`core_limits.mbt` is original project code. Binary/WAT equivalence and negative
cases are retained in `tests/semantic/wac-core-modules` under `.8.2.2`.

Explicit core declarations preserve distinct numeric slots even when signatures
are equal. Duplicate core type identifiers reject within their lexical scope;
shadowing outer names remains valid. Name scans have a shared compilation budget.

`core_module.mbt` bounds combined flat control keywords and folded expressions at
64 before the pinned core WAT parser/encoder runs. Block, loop and if bodies
compile and then validate as their original encoded instructions. S-expression
rendering uses an explicit stack. Raw data strings preserve bytes, and Unicode
data is encoded as UTF-8 byte escapes. Module names remain UTF-8 strings.
Imported function type uses with redundant inline signatures are checked against
the referenced declaration before the redundant spelling is removed for the
pinned parser. Mismatched signatures reject. Exact bytes, full models and printed
production WAT controls are retained in `tests/semantic/wac-core-control`.

Core module export annotations encode explicit type uses and inline module
contracts using the same core type index space as module imports.

Implicit reference collection excludes explicit outer alias targets and local
type bindings. Those declarations retain their source numeric slots even when
names shadow outer resource types. Import-resource controls compare the resulting
binary and WAT public models against both pinned validators.

Value imports, instance aliases, export projections and annotations use modern
direct value descriptors. Their dedicated index space remains separate from
functions and types. `LOCAL.patch` retains these compiler changes; the binary
boundary adapts only validated descriptor positions for the older parser.

Concrete child component compilation uses suspended frames and an explicit
driver stack. Parent name bindings become visible only after a child completes.
The existing 256-parenthesis source limit also bounds concrete scopes; binary
validation separately permits 256 nested component envelopes.
