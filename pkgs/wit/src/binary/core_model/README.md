# Retained core types

Internal compatibility sources from `Milky2018/wasm_core@0.16.0`, wasmoon
commit `397eb299e696d54cbc3bdcb095a5f535a74ad317`. `UPSTREAM.sha256` records
the original bytes; `LOCAL.patch` reconstructs the retained files. Apache-2.0
licensing and upstream notices are retained. These sources support the binary
profile extensions in `wasm-devkit-p5m.12.4` and `wasm-devkit-p5m.12.5`.

This internal model is distinct from the immutable public contracts in
`moonrockz/wit/core_types`. Callers must frame and bound original input before
using the compatibility parser and validate the original module before exposing
a verified package. It performs no execution.
