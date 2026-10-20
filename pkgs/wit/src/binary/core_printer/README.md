# Retained core printer

Sources are retained from `Milky2018/wasm_core@0.16.0` package `wat`, wasmoon
commit `397eb299e696d54cbc3bdcb095a5f535a74ad317`. Only the renderer and its
tests are retained. `UPSTREAM.sha256` records the original bytes of each
retained file in the published package; `LOCAL.patch` reconstructs each file
from that baseline. Apache-2.0 licensing and upstream third-party notices are
retained.

The local patch makes these changes:

- Instruction-shape checks and instruction rendering use explicit work stacks.
  Nested block, loop, if and try-table bodies never deepen the call stack, and
  output order is unchanged.
- Index comments for defined tables, memories, globals and tags count imported
  items first, so they name absolute indices like function comments do.
- Global initializers print as flat instruction sequences, so extended constant
  expressions compile through both retained text paths.
- Retained tests qualify package names and parse with the pinned `wat` package.
  The floating-point bits test compares f32 values with the bits that the target
  can hold, because JavaScript quiets f32 signaling NaNs.

This is an internal compatibility package for the
[core-module WAT printer](../../decompiler/README.mbt.md). It does not establish
conformance for every upstream proposal.
Beads tracking: `wasm-devkit-p5m.13.1` and `wasm-devkit-p5m.13.4`.

The opt-in compatibility renderer matches the pinned default layouts of
`wasm-tools 1.262.0 print` and `WABT 1.0.42 wasm2wat --enable-all`. Separate
emitters preserve their section order, naming, float spelling, custom metadata,
folding and comments. The default renderer uses raw reference-type metadata to
preserve nullability without changing its layout. All instruction and initializer
walks use explicit work stacks.

The compatibility implementation follows the reference sources named in
`THIRD_PARTY_NOTICES.md`. Exact binaries, expected text, pins, licenses, hashes,
re-encoded structure and measured boundaries live in
`tests/decompiler/compatibility/` at the repository root. These pins do not imply
compatibility with other versions or proposals outside the existing profile.
