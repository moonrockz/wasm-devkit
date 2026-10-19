# Runtime named type origins

Original Apache-2.0 fixtures compare WAC 0.12.0 commit
`5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` Package loading with wasm-tools
1.262.0 commit `e22db44da4eaf17a0e46ec55b911c7539589a3cc` validation.
`cases.json` records each exit status and diagnostic. Binary and WAT product
tests compare acceptance and full ordered public models for successful Package
loads.

Ordinary type arguments preserve their declaration origins through component
instantiation. Anonymous arguments can remain private or unused; exported
functions and instances must expose named types. Equal record shapes do not
make an anonymous declaration named. Imported instance names, nested captures,
function aliases and explicit export ascriptions exercise visibility. Two
instances of one component share its ordinary type origins; separate component
templates do not. Resource identities remain generative.

`second-instance-visible-function` validates with wasm-tools but the pinned
Package loader panics while projecting repeated aliased type exports. Its exact
panic is retained as an oracle exclusion under `wasm-devkit-p5m.8.2.2`; product
acceptance is checked without inventing a Package model or treating the panic
as a semantic rejection.

Seven source compositions compare the pinned Document API with complete public
models. Five accepted compositions also encode and independently validate. One
invalid dependency rejects. `named-export-nested` resolves but the pinned encoder
rejects its own output with an unnamed-instance export error; `compose.errors`
retains this separate encoder exclusion under `wasm-devkit-p5m.8.2.4`.

Runtime values remain outside this checkpoint. No fixture executes a component.
`SHA256SUMS` covers fixtures, oracle output, cases and license.
