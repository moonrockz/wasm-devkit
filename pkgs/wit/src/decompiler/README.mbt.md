# Wasm-to-WAT printing

`moonrockz/wit/decompiler` prints a core-module or component `.wasm` binary as
one WAT document. It performs no filesystem, network or subprocess I/O and does
not execute the binary.

| Operation | Input |
|-----------|-------|
| `print_core_module(bytes, source_id~)` | A flat core module |
| `print_component(bytes, source_id~)` | A component, with core modules and nested components inline |
| `print_binary(bytes, source_id~)` | Either; the binary preamble selects the operation |

Each operation returns `WatDocuments` or diagnostics. `WatDocuments.documents`
is an immutable ordered collection of named documents. Every successful result
contains exactly one document, named `root`, and `WatDocuments::root()` returns
it. Later modes can return more documents through the same type. Document text
is complete and ends with a newline.

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

### Print a component

```mbt check
///|
test "decompiler: print a component with its core module inline" {
  // A component that lifts the core function `run` of one core module.
  let bytes = b"\x00\x61\x73\x6d\x0d\x00\x01\x00\x01\x23\x00\x61\x73\x6d\x01\x00\x00\x00\x01\x06\x01\x4e\x01\x60\x00\x00\x03\x02\x01\x00\x07\x07\x01\x03\x72\x75\x6e\x00\x00\x0a\x04\x01\x02\x00\x0b\x02\x04\x01\x00\x00\x00\x07\x05\x01\x40\x00\x01\x00\x06\x09\x01\x00\x00\x01\x00\x03\x72\x75\x6e\x08\x06\x01\x00\x00\x00\x00\x00\x0b\x09\x01\x00\x03\x72\x75\x6e\x01\x00\x00"
  guard @decompiler.print_binary(bytes) is Ok(printed) else {
    fail("component rejected")
  }
  assert_eq(printed.root().name, "root")
  inspect(
    printed.root().text,
    content=(
      #|(component
      #|  (core module (;0;)
      #|    (type (;0;) (func))
      #|    (export "run" (func 0))
      #|    (func (;0;) (type 0)
      #|    )
      #|  )
      #|  (core instance (;0;) (instantiate 0))
      #|  (type (;0;) (func))
      #|  (alias core export 0 "run" (core func (;0;)))
      #|  (func (;0;) (type 0) (canon lift (core func 0)))
      #|  (export (;1;) "run" (func 0))
      #|)
      #|
    ),
  )
}
```

### Report a binary outside the profile

```mbt check
///|
test "decompiler: a malformed component fails without a partial document" {
  // The type section declares one entry but holds none.
  guard @decompiler.print_component(
      b"\x00asm\x0d\x00\x01\x00\x07\x01\x01",
      source_id="app.wasm",
    )
    is Err(errors) else {
    fail("malformed component printed")
  }
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].source, "app.wasm")
  assert_eq(errors[0].offset, Some(11))
  assert_eq(errors[0].code, "WIT-D001")
}
```

## Core-module profile

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
section is not read.

## Component profile

`print_component` accepts the declarative component profile of
`@binary.validate_declarative_component`, which component verification uses. It
covers type-only encoded WIT packages and runtime components: custom sections,
core modules, core instances, core types, nested components, component
instances, aliases, types, canonical definitions (lift, lower and the supported
intrinsics), start, import and export sections. The validator limits combined
component and type nesting to 256 levels.

Sections print in binary order. Each core module prints inline as
`(core module (;N;) ...)` through the core-module profile above, so an
out-of-profile nested module fails the whole component. Nested components print
inline as `(component (;N;) ...)`. Component and instance types print their
declarations in order. Index comments name each defined item's index in its own
scope; references use numeric indices and no identifiers.

Component custom sections print as `(@custom "NAME" "BYTES")`, so their bytes
survive. Strings keep printable ASCII other than quotes and backslashes and use
`\hh` byte escapes for every other byte.

Printed text uses only forms that the retained
[component text compiler](../component_text/README.md) accepts. Values of type
`error-context`, resource representations other than `i32` and `i64`, and
concrete or GC core references have no such form, and fail with `WIT-D003`. Two compiler limits remain: it rejects core control
nesting deeper than 64, and it rejects the flat extended constant initializers
that the core printer emits (`wasm-devkit-p5m.13.5`). Such components print,
but their text does not compile again.

Output is deterministic, but it is not wasm-tools `print` or WABT `wasm2wat`
output. Compatibility with those tools, split documents, module selection and
API-shape inventories are later slices of epic `wasm-devkit-p5m.13`.

## Diagnostics

Every failure returns one diagnostic and no document. Offsets count bytes from
the start of the binary. An absent offset means the retained parser or validator
supplied no position, or the component needed value-descriptor adaptation, which
moves later sections.

| Code | Meaning |
|------|---------|
| `WIT-D001` | Malformed binary framing, header or encoding |
| `WIT-D002` | Invalid module or component, such as a type mismatch |
| `WIT-D003` | Valid input outside the print profile, such as a component passed to `print_core_module` |
| `WIT-D004` | The retained core printer rejected the module shape |

Component validation maps `WIT-B001` to `WIT-D001`, `WIT-B002` to `WIT-D003`
and `WIT-B003` to `WIT-D002`, and keeps the offset and message.

## Validation

Core-module tests compare exact text, print every prefix of a rich fixture and
print arbitrary bytes with and without a core header. Printed documents are
parsed with the pinned `Milky2018/wasm_core@0.16.0` WAT parser and encoded again.
The re-encoded module has the same structure as the original, and printing it
again gives the same text. The pinned parser recurses, so that oracle uses 64
nested blocks. A directly encoded 256-level body checks the printer at the
profile limit.

Component tests compare exact text for a type-only package, a flat runtime
component, nested components with component instances, resources with their
intrinsics, and core types with custom sections. Each printed document compiles
through `@component_text.parse_normalized_component_wat`, validates under the
same profile, and prints again to the same text, except for the omitted
custom-section comments of core modules. Every prefix of a runtime component and
arbitrary bytes after a component header either fail with one diagnostic or
print. 256 nested components print, and 257 fail. Nested component types are
tested at 64 levels, because the retained validator recurses through type
declarations (`wasm-devkit-p5m.14`).

The [WIT verifier](../verifier/README.mbt.md) decodes four pinned upstream
encoded packages, including wasi-http, from binary and from printed WAT, and the
two models are equal. The [WAC verifier](../../../wac/src/verifier/README.mbt.md)
does the same for the pinned WAC hello and greeter components and both pinned
WASI HTTP production components. Their package models and their composition
models are equal. All tests run on wasm, wasm-gc, js and native. Beads tracking:
`wasm-devkit-p5m.13.1` and `wasm-devkit-p5m.13.2`.
