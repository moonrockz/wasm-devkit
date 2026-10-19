# Component text compatibility patch

This package retains `Milky2018/wasm_component@0.16.0`'s portable text compiler
from wasmoon commit `397eb299e696d54cbc3bdcb095a5f535a74ad317`.
The four original files match both that commit and the published package byte for
byte. `UPSTREAM.sha256` records their hashes, and `LOCAL.patch` reconstructs the
local changes. The upstream Apache-2.0 license and third-party notices are retained.

The patch encodes component value-type indices with signed LEB and supports map
types in declarations and inline value types. Decimal indices reject values above
the compiler's signed 32-bit index range instead of wrapping. The S-expression reader uses an
explicit stack and rejects nesting above 256 before compilation. Existing compiler
helpers operate on that bounded syntax. This is the WIT decoder's compatibility
frontend; it does not establish complete component text conformance.

Original white-box tests remain unchanged. Additional tests cover signed-LEB
boundaries, nested map syntax and deep-input rejection. WIT verifier and CLI tests
compare encoded maps and wasi-http against wasm-tools 1.262.0 and wit-parser
0.262.0. This patch is tracked by `wasm-devkit-p5m.8.1.5`.
