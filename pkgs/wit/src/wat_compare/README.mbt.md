# Compare core WAT

`moonrockz/wit/wat_compare` compares exact source text or validated core-module
structure. It performs no execution and makes no claim of arbitrary behavioral
equivalence. Components are outside this operation's scope.

```moon.pkg
import {
  "moonrockz/wit/wat_compare",
} for "test"
```

```mbt check
///|
test "compare typed literals" {
  let decimal = "(module (func (result i32) i32.const 16))"
  let hexadecimal = "(module (func (result i32) i32.const 0x10))"
  assert_true(
    @wat_compare.compare(decimal, hexadecimal, mode=Semantic)
    .unwrap()
    .is_equal(),
  )
  assert_false(
    @wat_compare.compare(decimal, hexadecimal, mode=Text).unwrap().is_equal(),
  )
  let changed = "(module (func (result i32) i32.const 17))"
  let diff = @wat_compare.compare(decimal, changed).unwrap().differences
  assert_eq(diff[0].path, "module.code[0]")
  assert_true(diff[0].left_span is Some(_))
}
```

## Equivalence contract

`Semantic`, the library default, compiles one explicit `(module ...)` using the
maintained portable WAT frontend, checks its original encoded declarations and
validates its decoded instructions. Both inputs must pass before equality or a
diff is returned. Identical invalid inputs still return `Err`. Each diagnostic
identifies the input side and distinguishes malformed, invalid and unsupported
input. `Text` compares every UTF-16 code unit, including line endings and terminal
newlines, without parsing or validating either source.

Semantic comparison ignores whitespace, comments, module names and symbolic
binding names after reference resolution. It also ignores folded versus flat
instruction spelling, inline versus separate import/export declarations,
redundant inline function signatures that agree with their type use, equivalent
string escapes, integer radix/sign/separators and vector lane spelling. Declaration
interleavings that compile to identical ordered index spaces compare equal.
Explicit default limits and shorthand reference types use the frontend's decoded
forms. Canonical encoding determines implicit function/block types and single-type
recursive-group spelling. This does not reorder or deduplicate explicit type slots.

Integers compare as the bit pattern of their declared width. Negative signed
literals and positive unsigned spellings of the same bits compare equal. Literals
outside the signed-negative or unsigned-positive range reject before decoding.
Floating point literals compare by IEEE bits after rounding to their declared
width. Positive and negative zero differ. NaN signs, quiet/signaling bits and
payloads differ; `nan` denotes the positive canonical quiet NaN. NaNs never pass
through host floating point storage, including on JavaScript. Vectors compare their
128 bits regardless of lane shape. Scalar constants retain their instruction type.

Instruction order, opcodes, numeric indices and their identities, types, recursive
group membership, imports and export names, declaration order within index spaces,
limits, mutability/shared flags, start functions, element/data modes, initializer
expressions and raw data bytes remain significant. No constant folding, dead-code
removal, type-index renumbering or optimizer reasoning occurs.

Custom sections, producers/name annotations and other `@` annotations are
unsupported rather than silently discarded. Binary module
abbreviations, WAST scripts and components also return unsupported diagnostics.
Quoted identifiers, ordinary quoted import/export names and raw data strings are supported. The
portable frontend and core validator define the supported instruction/type profile;
an unsupported construct never produces a successful equality result. No external
executable or network service is needed.

## Structured differences and locations

A result owns an immutable `ReadOnlyArray[Difference]`. Paths are stable,
lexicographically ordered keys. `module.types`, `module.imports`, `module.globals`
and the other section names identify changed canonical section payloads.
`module.code[N]` identifies one defined function's locals and instruction body,
excluding imported functions. A missing section/body has `None` on that side.
Payloads omit section lengths and code body length prefixes, so a longer earlier
body does not cause false changes to every later function.

Scalar floats have separate paths such as
`module.func[0].constant[1].bits`. The constant index counts scalar and vector
constant instructions in source/execution order within that declaration. Their
values are exact little-endian IEEE bytes. Canonical section/body payloads use
zero placeholders for scalar floats; the separate bit records are part of the
comparison, not optional metadata. Vectors carry their full bits directly in the
body payload. This separation preserves every scalar NaN bit on every target.

`left` and `right` contain immutable bytes. Ordinary section/body differences are
canonical binary payloads, not textual edits or a minimal instruction edit script.
The initial API reports whole changed sections and bodies. It does not claim
field-level edit alignment after insertions. Float differences locate the literal;
code differences locate the containing defined function. Other section differences
locate the range of corresponding source declarations when available. Some
synthesized declarations have no source span. Offsets are zero-based, half-open
UTF-16 code-unit ranges in the original input, including comments and surrogate
pairs. A section range can include intervening declarations and trivia.

## Limits and laws

Framing, comment scans, diffing and source-location discovery use explicit loops
or work stacks. The existing portable compiler bounds expression parentheses at
256 and combined flat/folded control nesting at 64 before its bounded recursive
helpers run. Deeper inputs return unsupported diagnostics; 30,000-level flat and
folded controls are regression-tested. Nested comments use an explicit counter and
are tested at 30,000 levels. Finite float literals are limited to 4,096 UTF-16 code
units and exponent magnitude 10,000 before precise conversion. Quoted identifier
validation has a 1,000,000-code-unit budget. Core type validation
has its existing 1,000,000-work budget. Redundant inline signature checks
have a separate 1,000,000-code-unit compilation budget. Limits never turn failure into equality.

Tests run on wasm, wasm-gc, JavaScript and native. They cover reflexivity, symmetry
and transitivity over alternate integer spellings; changed instruction/type/index
and data contracts; integer boundaries; float subnormal/maximum/rounding boundaries;
signed zero and quiet/signaling NaN payloads; vector lane equivalence; invalid and
unsupported input; source spans and deep controls/comments.

```mbt check
///|
test "invalid input is separate from different input" {
  let invalid = "(module (func i32.add))"
  guard @wat_compare.compare(invalid, invalid) is Err(errors) else {
    abort("invalid modules must not compare equal")
  }
  assert_eq(errors.length(), 2)
  assert_eq(errors[0].side, Left)
  assert_eq(errors[0].kind, Invalid)
}
```
