# Nested and concrete core limits

Original Apache-2.0 fixtures for `wasm-devkit-p5m.12.2`, under the repository's
[license](../../../LICENSE). Inputs and reference snapshots are retained with
SHA-256 hashes in `SHA256SUMS`.

The 90 probes use wasm-tools 1.262.0, commit
`e22db44da4eaf17a0e46ec55b911c7539589a3cc`, with all features, and WAC 0.12.0,
commit `5a7480c69ae7a4dc9eb161f485cbcb8c95e372c9`.
`cases.json` records text parsing, binary validation, pinned package loading and
product acceptance separately. Binary-form WAT retains deliberately malformed
encodings verbatim. Some of those fail the reference text parser itself, so
binary identity is checked only when reference text parsing succeeds.

Root, nested component/instance and concrete module contracts use full UInt64
limits. Address widths still constrain table32 limits to u32 and memory page
counts to the address space divided by page size. For memory64 with one-byte
pages the representable maximum is UInt64 maximum. Only page sizes of 1 and
65536 bytes are supported. Minimums cannot exceed maximums. Overflow, malformed
LEBs, invalid flags and invalid page sizes always fail without a model.

Cases cross the u32 and signed Int64 boundaries, exercise UInt64 maximum, absent
maximums, shared memory, imported and defined memories, lexical aliases, nested
concrete modules and unsigned minimum/maximum import matching. Global contracts
retain scalar type, mutability and shared flags. Concrete shared globals,
including imports, now accept under `wasm-devkit-p5m.12.3`; the
[shared-global suite](../wac-shared-globals/README.md) supplies the full regression
profile.

Accepted package snapshots retain every ordered reachable module signature,
world, interface, import, export and definition. The four-target product tests
in `core_limits_profile_test.mbt` compare complete normalized models against
those snapshots for retained binaries, WAT and re-decoded product bytes.
Normalization ignores arena IDs and transparent aliases, preserving declaration
order, limit values, widths, shared flags and optional page-size annotations.
An absent page annotation remains distinct from explicit `pagesize 65536`.
`concrete-import-mixed` also checks memory export indices when imports precede
definitions with different widths and page sizes.

`core_limits_bounds_test.mbt` checks randomized UInt64 contract round trips,
the unchanged 1,000,000-step work allowance,
binary component/control depth of 256, WAT control nesting of 64, invalid
instruction validation and overflowing decimal/hexadecimal literals. Newly
admitted concrete UInt64 modules also print unsigned limits and round-trip
through default and wasm-tools-compatible WAT output. Validation
uses explicit stacks, performs no hidden I/O and never executes input modules.

Run `mise run test` for wasm, wasm-gc, js and native. `mise run test:cli -- wasm`
and `-- native` exercise dependency providers. `mise run test:semantics --
.dev/reference-cli/bin/wasm-tools .dev/reference-cli/bin/wac` rechecks hashes,
reference acceptance, complete pinned models and both CLI providers. It also
retains the gate for all 128 pinned WAC resolution bundles. Build the test-only
references first with `mise run build:semantic-tools`.
