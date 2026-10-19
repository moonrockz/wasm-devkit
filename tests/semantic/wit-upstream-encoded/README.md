# Encoded upstream WIT corpus

These 78 binaries are the output of the pinned wasm-tools encoder for every
accepted source group in [the complete UI corpus](../wit-upstream-ui/README.md).
The pin is wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`. Each row in `cases.json` records its
original input, encoding and resolution commands, feature selection and SHA-256.
The upstream input licenses are retained here.

All 67 accepted encoded WIT packages compare their full public models with the
pinned Resolve API. The tests compare package and interface identities, world
keys, type and function contracts, stability and external-ID metadata, and
nominal resource equivalence using the same projection as the source corpus.
They also check repeated resolution, input ordering and preservation of earlier
results on all four targets. Source corpus tests additionally check formatting
preserves the full semantic model and is idempotent.

The remaining 11 source groups have empty root packages. Encoding them produces
an ordinary component with no WIT package exports. Both Resolve::push_path and
wasm-devkit reject those bytes as encoded WIT packages. The pure decoder tests
assert that rejection. They are excluded from the shared CLI acceptance manifest
because `wasm-tools component wit` can extract an interface from an ordinary
component, a separate operation from loading an encoded WIT package. Their exact
classification is retained in `cases.json`, under Beads
`wasm-devkit-p5m.8.1.5` and `wasm-devkit-p5m.8.1.7`.

The 67 accepted binaries are in the parent CLI manifest. Ordinary library tests
need no host tools. To recreate a binary with the pinned encoder:

```sh
wasm-tools component wit SOURCE --features active --wasm -o BINARY
```
