# Retained core printer

Sources are retained from `Milky2018/wasm_core@0.16.0` package `wat`, wasmoon
commit `397eb299e696d54cbc3bdcb095a5f535a74ad317`. Only the renderer and its
tests are retained. `UPSTREAM.sha256` records the original bytes of each
retained file in the published package; `LOCAL.patch` reconstructs each file
from that baseline. Apache-2.0 licensing and upstream third-party notices are
retained.

The local patch makes three changes:

- Instruction-shape checks and instruction rendering use explicit work stacks.
  Nested block, loop, if and try-table bodies never deepen the call stack, and
  output order is unchanged.
- Index comments for defined tables, memories, globals and tags count imported
  items first, so they name absolute indices like function comments do.
- Retained tests qualify package names and parse with the pinned `wat` package.
  The floating-point bits test compares f32 values with the bits that the target
  can hold, because JavaScript quiets f32 signaling NaNs.

This is an internal compatibility package for the
[core-module WAT printer](../../decompiler/README.mbt.md). It does not establish
conformance for every upstream proposal or compatibility with other printers.
Beads tracking: `wasm-devkit-p5m.13.1`.
