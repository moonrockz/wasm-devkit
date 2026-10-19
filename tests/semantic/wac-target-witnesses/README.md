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

The `nested/` table adds 49 original Apache-2.0 cases. Package bytes and WAT,
WAC input, independent subtype witness WAT and SHA-256 hashes are retained for
each case. `cases.tsv` records source-resolution, witness-validation and product
acceptance separately. Compile and validate each `*-witness.wat` with the command
above; package `.wat` files compile to the corresponding retained `.wasm` bytes.

The polarity matrix crosses root import/export checks with zero through three
nested component-import scopes and both independent/aliased resource parameter
relationships. The two capture matrices check imported and exported functions
that use matching or crossed resource parameters at the same depths. All 48
source cases resolve with WAC 0.12.0, commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`; the product follows the independent
wasm-tools 1.262.0 subtype witness, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. The source resolver does not enforce
these nominal relationships. Rejected witnesses are explicit source-resolution
exclusions, not ordinary acceptance-manifest cases.

The remaining `owner/import-0-canonical` case compares a source world with a
`use`-implied named resource owner against its binary form. Pinned source
resolution rejects this equivalence. The independent binary witness validates,
and the product expands the nested world's implicit owner before comparison.
A separately named instance of the same source interface must not replace the
canonical owner's captured resource. These exclusions remain tracked on
`wasm-devkit-p5m.8.2.6` and its full WAC conformance task.
