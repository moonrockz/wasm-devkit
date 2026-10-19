# Core instances and synchronous canonical functions

Original Apache-2.0 fixtures compare WAC 0.12.0 at
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` and wasm-tools 1.262.0 at
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all features enabled.
`packages.json` records 71 package probes. Accepted binary and WAT inputs compare
complete ordered public models, including nominal resources and module contracts.

The cases cover ordered core instances and aliases, complete import contracts,
synchronous lift/lower signatures, memory32/memory64, realloc/post-return options,
named aggregates, indirect parameters/results and imported function metadata.
Both references reject flags with more than 32 members in this profile.
Future module, instance, alias and function references reject.

`composition/results.json` records twelve source compositions. Both the pinned
Document API and CLI accept ten and reject two invalid ABIs. All ten emitted
binaries pass independent wasm-tools validation. The tests compare binary/WAT
provider models and complete resulting public composition models.

Two explicit upstream false positives remain outside acceptance equivalence.
WAC's package loader accepts `contract-table64-flag` and
`contract-global-shared-flag`; wasm-tools and the product reject both mismatched
flags. `contract-global-ref-narrow` has the opposite difference: wasm-tools
accepts it, while the product retains WAC's invariant global reference rule.
These differences remain tracked on `wasm-devkit-p5m.8.2.2`.

Verification never executes a module or component. Original concrete module
bodies still pass the flat-instruction preflight and core validator. Nested
runtime components, component starts/values, structured core instructions,
async canonical functions and canonical intrinsics remain outside this slice.
The canonical type walk uses an explicit stack, caches shared type graphs and
charges a shared work budget. Flattened signature prefixes stop after 17 slots,
while validation still visits every reachable child. Core instantiations and
aliases share a separate 1,000,000-unit contract work budget.

`SHA256SUMS` covers every retained fixture and reference result. Unit tests also
exercise 6,000-level type graphs, shared graphs, large fixed lists and budget
exhaustion without recursive input traversal.
