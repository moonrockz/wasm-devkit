# Concrete core modules

Original Apache-2.0 fixtures compare WAC 0.12.0 at
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` and wasm-tools 1.262.0 at
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all features enabled.
`packages.tsv` records 45 binary probes. Accepted models compare complete,
ordered core contracts from the pinned API and preserve binary/WAT equivalence.
The model retains original bytes. No module executes during verification.

`composition.tsv` records eight concrete-provider argument checks against both
Document::resolve and the WAC CLI. All five accepted composed binaries validate
with wasm-tools. These cover function signatures, memory limits, imports, tags
and globals. Three incompatible arguments reject.

The pinned WAC package loader deliberately skips function-body validation. It
accepts `invalid-body`, `invalid-local`, `invalid-call`, `invalid-stack` and
`invalid-load`; wasm-tools and the product reject their original bodies. These
are explicit reference false positives, tracked under `wasm-devkit-p5m.8.2.2`.
They are not ordinary acceptance-equivalence cases. The `padded-heap` binary
uses a padded negative abstract heap code. Both references reject that encoding;
its WAT file describes the canonical form before the deliberate byte mutation.

`shared-global` now accepts and preserves its complete contract.
`concrete-heap-index` and `nested-component` now accept with complete scoped
contracts. The [extension suite](../wac-binary-extensions/README.md) additionally
checks concrete/shared heap references, recursive GC types and supertypes.

Original function instructions and non-code metadata reach the retained core
validator. Structured block, loop and if instructions are now supported through
explicit parser/validator stacks. The `structured` fixture accepts. Physical
control nesting is bounded at 256 in binary and 64 for combined flat keywords
and folded expressions in WAT. Contract
tests exercise 20,000 sequential instructions, 10,000 nested block rejection,
signed-LEB overflow, truncation, local expansion and a shared validation-work
limit. The estimate charges signature arity, pairwise type comparisons and
control-local snapshots rather than multiplying all bytes by body count.
See `../wac-core-control` and `pkgs/wit/src/core_types/README.md` for the formula,
new exact witnesses and the unchanged hello/greeter production components.

`SHA256SUMS` covers every retained fixture and reference projection. The
validator and compiler changes retain their original hashes and reconstructable
patches in their respective package directories. Remaining runtime, canonical,
value and ascription scope stays open on `.8.2.2` and `.8.2.4`.

The `canonical-lift` case is now supported by the synchronous canonical-function
profile, with full model coverage in `../wac-canonical-functions`.
