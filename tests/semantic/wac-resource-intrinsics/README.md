# Canonical resource operations

Original Apache-2.0 fixtures compare WAC 0.12.0 at
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` and wasm-tools 1.262.0 at
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all features enabled.
All 42 resource-operation package cases agree across both references. Accepted binary and WAT
inputs compare complete ordered public models.

`resource.new` and `resource.rep` require local resource identity, including
export aliases. `resource.drop` also accepts imported resources and resources
aliased from imported instances. Nonresource types and future indices reject.
Core consumer modules check each intrinsic's complete signature. Both i32 and
i64 resource representations are retained, with i32 handles in either case.
Destructor parameters match the representation and destructors return nothing.
Original concrete destructor bodies still undergo core validation.

Five source compositions compare Document resolution and the pinned CLI. Four
accept and their emitted binaries validate independently; the wrong i64-resource
destructor rejects. Native and wasm CLI smoke tests load these binary/WAT inputs.
The verifier never executes a resource operation or destructor.

`SHA256SUMS` covers all retained files. Canonical intrinsics other than
resource new/drop/rep are tracked in `wasm-devkit-p5m.12.1`. Async lift/lower and
component start are covered by `wac-proposal-profiles/`.

`import-capture-gaps` retains 39 additional import-resource cases, including
seven former product false positives now rejected. Binary/WAT acceptance agrees
with both pins, and accepted cases compare complete ordered public models.
