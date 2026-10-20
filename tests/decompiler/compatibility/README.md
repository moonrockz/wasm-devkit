# Pinned WAT printer comparisons

These fixtures implement the textual checks for `wasm-devkit-p5m.13.4`.
`pins.json` records the reference releases, invocations and downloaded archive
hashes. `SHA256SUMS` records every fixture input, expected output, reference
readback and retained license. `cases.tsv` records acceptance and measured
reference failures. The fixtures are Apache-2.0 project examples. The
`licenses/` directory also retains the printers' upstream licenses.

The exact printing invocations are:

```shell
wasm-tools print INPUT.wasm                      # wasm-tools 1.262.0
wasm2wat --enable-all INPUT.wasm                 # WABT 1.0.42
wasm-tools parse EXPECTED.wat -o REENCODED.wasm   # wasm-tools 1.262.0
```

No other printer flags are set. In particular, debug names and formatting use
each pin's defaults. The source `.input.wat` files are assembled with the pinned
`wasm-tools parse`. `random-floats.input.json` records the literal bits of 240
sampled globals encoded directly into the corresponding binary. It includes
only f32 NaNs whose payloads every supported target can retain.

Text comparison normalizes only CRLF/LF outside string literals and exactly one
terminal newline. It preserves indentation, wrapping, index comments, identifier
sanitization, number spelling, escapes, nesting and declaration order. Structural
checks supplement this comparison. They never replace it. Semantic diff remains
separate work in `wasm-devkit-xqn`.

The embedded MoonBit fixtures run with the ordinary tests on wasm, wasm-gc, JS
and native. Core tests compare the original and independently re-encoded module
structures, including instruction trees and float bits. WAC contract tests
compare single-document and compatibility readbacks with full splits, preserving
ordered types and resource sharing. Prefix, arbitrary-input and deep-input tests
check rejection without partial documents.

Run the external comparisons against a prebuilt native CLI:

```shell
moon build cmd/wasm-devkit --target native --release
mise run test:decompiler-reference -- /path/to/wasm-tools-1.262.0 /path/to/wasm2wat-1.0.42 _build/native/release/build/moonrockz/wasm-devkit/wasm-devkit.exe
```

The script checks versions and all hashes, compares both reference and CLI output
with the retained WAT, and validates successful reference readbacks. It does not
build or install reference tools. The exact outputs stay in ordinary unit tests;
this external check qualifies fixture or printer changes before landing.

## Measured boundaries

- WABT does not accept components. The compatibility API and CLI reject them.
- WABT 1.0.42 rejects explicit recursive groups, subtype encodings and several
  abstract reference types admitted by the existing core profile. Its reader
  also limits function locals to 50,000. WABT mode rejects these encodings and
  limits explicitly. Per-case stderr retains the measured reference failures.
- wasm-tools 1.262.0 rejects unknown `dylink.0` subsection kinds in both core
  modules and components. wasm-tools mode rejects these inputs explicitly.
- WABT preserves local debug names without escaping spaces. `unicode.wabt.wat`
  matches its output exactly, including `$a b`. The pinned wasm-tools parser
  rejects that WAT. Its failure is retained in `unicode.wabt.readback.stderr`.
  This case has exact text coverage and no successful structural readback claim.
- WABT emits raw branch-hint annotations that the pinned wasm-tools parser
  rejects for invalid hint data. `branch-hint-raw.wabt.readback.stderr` retains
  that failure; the emitted text still matches WABT exactly.
- WABT rejects some malformed known metadata that wasm-tools recovers from.
  Those failures are recorded per case. wasm-tools recovery comments and raw
  custom-section placement remain part of the exact expected output.
- `component-outer` passes the pinned reference parser but is rejected by the
  repository's existing component validation boundary in both default and
  compatibility modes. It is a profile rejection, not a skipped positive case.
- Local WAT readers have narrower readback support than the pinned references.
  In addition to their existing nesting limits, the retained core reader cannot
  consume the pinned wasm-tools import signatures, and WABT's forward memory-name
  references do not always resolve through that reader. The retained reference
  readbacks supply independent structural evidence for these cases.

The original normalization and profile boundaries have recorded user approval in
Beads. Newly measured reference and local-readback boundaries require review
before merge. No additional textual normalization is proposed.
