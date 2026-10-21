# Retained core wat

Internal compatibility sources from `Milky2018/wasm_core@0.16.0`, wasmoon
commit `397eb299e696d54cbc3bdcb095a5f535a74ad317`. `UPSTREAM.sha256` records
the original bytes; `LOCAL.patch` reconstructs the retained files. Apache-2.0
licensing and upstream notices are retained. These sources support the binary
profile extensions in `wasm-devkit-p5m.12.4` and `wasm-devkit-p5m.12.5`.

This internal model is distinct from the immutable public contracts in
`moonrockz/wit/core_types`. Callers must frame and bound original input before
using the compatibility parser and validate the original module before exposing
a verified package. It performs no execution.

The retained subset includes the lexer, parser and parser tests. Upstream
`render*`, `element_test.mbt` and `trait_extensions.mbt` belong to the separate
`core_printer` renderer and are not copied here. The local `render.mbt` adapter
uses that renderer's explicit work stack. Shared composites and abstract heaps,
recursive placeholders, and non-nullable exception/bottom heaps preserve their
exact types through parsing. New graph tests are local additions.

The local additions retain shared global/table forms, modern handler labels
and legacy flat/folded try/catch/rethrow/delegate. Table initializer expressions
accept the same flat constant sequences as globals. Public component WAT
framing applies the existing depth limit before invoking this parser.
