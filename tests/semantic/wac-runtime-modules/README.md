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

`shared-global`, `structured`, `concrete-heap-index` and
`nested-component` are
reference-accepted boundaries that still return `WAC-B002`. Concrete and shared
heap references, GC types and supertypes also remain outside this slice.
Function-only recursive groups without recursive references are supported.

Original function instructions and non-code metadata reach the retained core
validator. A flat byte preflight rejects structured/proposal instructions before
the recursive dependency parser. The text frontend rejects structured control
keywords before its core WAT parser, including keyword nesting without nested
parentheses. Contract tests exercise 20,000 flat instructions, 10,000 nested
block keywords, signed-LEB overflow, truncation, local expansion and a shared
component validation-work limit. The conservative module estimate is
`bytes * max(function-type-count, body-count, 1) + expanded-locals`; their sum
must not exceed 1,000,000 before retained validation starts.

`SHA256SUMS` covers every retained fixture and reference projection. The
validator and compiler changes retain their original hashes and reconstructable
patches in their respective package directories. Remaining runtime, canonical,
value and ascription scope stays open on `.8.2.2` and `.8.2.4`.

The `canonical-lift` case is now supported by the synchronous canonical-function
profile, with full model coverage in `../wac-canonical-functions`.
