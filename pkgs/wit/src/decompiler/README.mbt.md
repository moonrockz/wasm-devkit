# Core-module WAT printing

`moonrockz/wit/decompiler` prints a flat core-module `.wasm` binary as one WAT
document. It is the first slice of Wasm-to-WAT decompilation. It performs no
filesystem, network or subprocess I/O and does not execute the binary.

`print_core_module(bytes, source_id~)` returns `WatDocuments` or diagnostics.
`WatDocuments.documents` is an immutable ordered collection of named documents.
Core-module printing returns exactly one document, named `root`, and
`WatDocuments::root()` returns it. Later modes can return more documents
through the same type. Document text is complete and ends with a newline.

```moon.pkg
import {
  "moonrockz/wit/decompiler",
} for "test"
```

## Recipes

### Print a core module

```mbt check
///|
test "decompiler: print a core module as one WAT document" {
  // (module (func (export "run")))
  let bytes = b"\x00asm\x01\x00\x00\x00\x01\x04\x01\x60\x00\x00\x03\x02\x01\x00\x07\x07\x01\x03run\x00\x00\x0a\x04\x01\x02\x00\x0b"
  guard @decompiler.print_core_module(bytes) is Ok(printed) else {
    fail("module rejected")
  }
  assert_eq(printed.documents.length(), 1)
  assert_eq(printed.root().name, "root")
  assert_eq(
    printed.root().text,
    "(module\n  (type (;0;) (func))\n  (export \"run\" (func 0))\n  (func (;0;) (type 0)\n  )\n)\n",
  )
}
```

### Report a binary outside the profile

```mbt check
///|
test "decompiler: components fail without a partial document" {
  guard @decompiler.print_core_module(
      b"\x00asm\x0d\x00\x01\x00",
      source_id="app.wasm",
    )
    is Err(errors) else {
    fail("component printed")
  }
  assert_eq(errors[0].source, "app.wasm")
  assert_eq(errors[0].offset, Some(4))
  assert_eq(errors[0].code, "WIT-D003")
}
```

## Profile

The input profile is the core-module profile that component verification uses.
`@core_types.inspect_module` checks framing, section order, limits, control
nesting up to 256 and validation work. The retained core parser and validator
then check the module. The profile includes MVP instructions, multi-value,
reference types, bulk memory, tail calls, memory64, multiple memories and
`v128.const`. It rejects GC types, threads, exceptions, other SIMD instructions
and shared globals.

`f32.const` immediates that are signaling NaNs are also rejected. The JavaScript
target cannot represent their payloads as `Float` values, so no target prints them.
This keeps results identical on wasm, wasm-gc, js and native.

Custom sections carry no module structure. The document omits them and starts with
one `;; custom section omitted: "NAME"` line per custom section, in binary order.
Control characters, quotes and backslashes in those names use `\hh` escapes.

Text comes from the [retained core printer](../binary/core_printer/README.md).
Index comments name absolute indices. No identifiers are printed, and the name
section is not read. Output is deterministic, but it is not wasm-tools `print`
or WABT `wasm2wat` output. Compatibility with those tools, components, nested
modules, split documents, module selection and API-shape inventories are later
slices of epic `wasm-devkit-p5m.13`.

## Diagnostics

Every failure returns one diagnostic and no document. Offsets count bytes from
the start of the binary. An absent offset means the retained parser or validator
supplied no position.

| Code | Meaning |
|------|---------|
| `WIT-D001` | Malformed binary framing, header or encoding |
| `WIT-D002` | Invalid module, such as a type mismatch in a function body |
| `WIT-D003` | Valid input outside the print profile, including components |
| `WIT-D004` | The retained printer rejected the module shape |

## Validation

Tests compare exact text, print every prefix of a rich fixture and print arbitrary
bytes with and without a core header. Printed documents are parsed with the pinned
`Milky2018/wasm_core@0.16.0` WAT parser and encoded again. The re-encoded module
has the same structure as the original, and printing it again gives the same text.
The pinned parser recurses, so that oracle uses 64 nested blocks. A directly
encoded 256-level body checks the printer at the profile limit. All tests run on
wasm, wasm-gc, js and native. Beads tracking: `wasm-devkit-p5m.13.1`.
