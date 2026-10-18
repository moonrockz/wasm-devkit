# Semantic reference fixtures

These are original Apache-2.0 fixture sources for the initial verifier API path.
They are a seed suite, not the complete upstream conformance gate required by issue #5.
No upstream fixture sources are copied here yet.

`manifest.tsv` records acceptance and SHA-256 over the exact source bytes. Each file
is passed unchanged to the reference semantic resolver and the wasm-devkit CLI.
There are no dependency files, registry lookups or optional semantic features in this suite.

| Language | Reference | Revision | Semantic operation |
| --- | --- | --- | --- |
| WIT | wasm-tools 1.262.0 | `e22db44da4eaf17a0e46ec55b911c7539589a3cc` | `wasm-tools component wit FILE` calls WIT package resolution |
| WAC | wac-cli 0.12.0 | `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9` | `wac resolve --deps-dir tests/semantic/deps FILE` calls `Document::resolve` |

Use the official release executables or build those exact revisions with their default
release feature sets. The runner checks executable version output. No feature switches
are passed. In-profile acceptance differences fail the runner.

```shell
mise run test:semantics -- /path/to/wasm-tools /path/to/wac
```

The WIT grammar fixture pin predates this semantic reference; these seed cases use
syntax shared by both revisions. The WAC grammar and semantic revisions are identical.
The complete source/dependency corpus, normalized model comparison, binary fixtures,
feature profiles and justified exclusions remain tracked in Beads
`wasm-devkit-p5m.8.1.7` and `wasm-devkit-p5m.8.2.7`.
