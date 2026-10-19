# Target resource subtype witnesses

These original Apache-2.0 WAT sources retain component-model checks for the
WAC target tests. They are independent of `Document::resolve` and the target
checker, which currently compare resources by name in these cases.

Compile each with pinned wasm-tools 1.262.0 `parse FILE.wat -o FILE.wasm`, then
run `validate FILE.wasm`:

- `resource-alias-subtyping` succeeds. A component with independent resource
  imports accepts an environment that supplies equal resources for both.
- `resource-export-control` succeeds. The exported function uses the resource
  imported from the expected owning instance.
- `resource-export-subtyping` fails with `resource types are not the same` at
  offset `0x12b`. Its function uses the separate `b` instance's resource.

Each source instantiates a consumer requiring the target component type with
an actual component. This makes the validator check the subtype relationship.
A plain `wac compose` result does not encode its source target constraint and
therefore cannot establish this relationship by itself.

The last witness corresponds to `pinned targets resource-crossed-export` in
`pkgs/wac/src/verifier/targets_test.mbt`. The product rejects that case with
`WAC-T003`; the other two relationships remain accepted. The source tests retain
the actual WAC input and reference model. Tracking: `wasm-devkit-p5m.8.2.6`.
