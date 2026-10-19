# WAC implicit import cases

These original Apache-2.0 fixtures compare WAC 0.12.0 at revision
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`. `cases.tsv` records exit statuses
for `Document::resolve`, `TypeAggregator` and validating `wac compose`, followed
by the verifier's expected acceptance. A dash means an earlier stage rejected the
input. Dependency keys are caller lookup identities. `SHA256SUMS` covers every
input and the table. WAT binaries were encoded with wasm-tools 1.262.0 at revision
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`.

`implicit_imports_test.mbt` embeds these inputs and checks binary/WAT equivalence,
ordered import/type projections and composition edges. The API oracle's
`--aggregate-imports` output supplies the expected type projections. These cases
cover final-position Fill, exact explicit conflicts, interface/component merging,
compatible version tracks and build ordering, named resource owners and nominal
captures. They do not establish complete WAC conformance.

Reference differences are explicit:

- `resource-capture`, `used-resource`, `used-resource-repeat`,
  `used-resource-explicit`, `pair-resource` and `split-captures` resolve and aggregate, but the
  pinned encoder panics at `crates/wac-graph/src/encoding.rs:702`. The verifier
  accepts their bound graphs; dedicated assertions check the imported declaration
  and handle share both static and runtime resource identities.
- `resource-crossed` reaches the same encoder panic. The verifier rejects the
  shared function's two distinct captures with `WAC-C005`.
- `nested-up`, `nested-down` and `used-interface-explicit` resolve and aggregate,
  but validating compose rejects them. The verifier rechecks each consumer after
  aggregation and rejects them too. The nested interface merge retains a narrower
  nested interface; the renamed explicit resource owner differs from the implicit
  owner synthesized by aggregation.

Tracking remains on Beads `wasm-devkit-p5m.8.2.5` and the full conformance task.

`split-captures` checks two functions sharing an original package signature but
capturing resources from distinct explicit interfaces. Each aggregate import
clones only the type paths affected by its own resource substitution. Static
handle targets and runtime bindings stay distinct and refer to the corresponding
imported declarations.

`split-captures-witness.wat` encodes the two independent imports and component
instantiations directly. Its binary passes pinned wasm-tools validation, providing
an independent component-model witness for the captured-resource composition
that the WAC encoder cannot emit. The witness is not a declarative package input.
