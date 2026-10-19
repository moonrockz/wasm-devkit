# Runtime component values

Original Apache-2.0 fixtures compare WAC 0.12.0 commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` Package loading with wasm-tools
1.262.0 commit `e22db44da4eaf17a0e46ec55b911c7539589a3cc` validation.
`cases.json` retains each exit status and diagnostic. Binary and WAT tests compare
complete ordered package models with the WAC loader.

The 28 cases cover imported values consumed by instantiation and inline instance
exports, runtime-produced values, nested instance aliases, single-use checks,
unused aliases, resource substitution, independently fresh resources, named and
anonymous results, explicit ascriptions and immutable contract copying.
`borrow-substitution` preserves the documented WAC 0.258 borrowed-value profile:
WAC accepts it while wasm-tools 0.262 rejects the exported borrow.

Eleven source compositions compare complete ordered models, using the public
composition resource contexts for runtime nominal identities. Static arena roots
alone describe reusable templates and cannot identify an instantiated output.
One emitted composition independently validates; three invalid dependencies
reject. Seven accepted Document inputs panic in the pinned encoder when it tries
to encode value-bearing component contracts. Exact `compose.errors` files retain
these encoder exclusions under `wasm-devkit-p5m.8.2.4`; they are not reported as
successful emissions or semantic rejections.

All operations remain non-executing. Values are consumed exactly once, while
separate aliases of an instance value are independently consumable as specified
by both references. Escaping values require visible named types after resource
and ordinary-type substitution. Private anonymous outputs may remain private.
`SHA256SUMS` covers every fixture, reference result, case manifest and license.
