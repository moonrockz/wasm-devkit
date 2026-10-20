# Core module signatures

This pure codec reads core function and module type definitions into immutable
models. Module imports retain ordered `(module_name, name)` pairs; exports retain
ordered names. Function and tag signatures retain all parameters/results.
Tables and memories retain unsigned 64-bit limits, address-width and shared flags.
Memory page sizes preserve the distinction between an absent annotation and an
explicit `pagesize 65536`. Globals retain value type, mutability and shared status.

`External::Table` fields are element, minimum, maximum, table64 and shared.
`External::Memory` fields are minimum, maximum, memory64, shared and optional
page-size logarithm. `External::Global` fields are value, mutable and shared.
`Value::Reference` fields are nullable and abstract heap name.

`decode_type` reads one definition; `decode_section` reads a vector and returns
only newly declared definitions. Caller-supplied `current` and `outers` retain
lexical index spaces. Outer scopes are ordered nearest first. Module-local
function aliases use depth zero, the enclosing component uses depth one.
Aliases resolve only against preceding definitions. No operation performs I/O.

`scan_type` returns the end offset of one definition within an enclosing range.
It checks byte framing and values before the retained component parser runs.
Root and nested component/instance core declarations share full u64 limits and
custom memory pages of 1 or 65536 bytes. The obsolete `legacy_nested` argument
is retained for source compatibility and no longer restricts nested limits.
The retained type parser uses this scanner to retain the complete payload.
The enclosing component validator checks external type indices separately.

Concrete GC references, recursive/subtype groups and shared heap references
return `Unsupported`. The pinned WAC loader panics on concrete reference types;
this codec returns a diagnostic. Abstract references, including non-null forms,
are retained. Tables with shared limits and unshared element references reject.
Counts are bounded by remaining input bytes; lexical traversal and graph copying
have a shared work budget in the enclosing binary and WAC decoders.


`inspect_module` reads concrete module metadata and returns immutable
`ModuleMetadata` containing the contract and a validation-work estimate.
`decode_module` returns only the contract. Neither operation certifies instruction
semantics. The enclosing binary boundary must validate the original bytes.
The estimate is `bytes * A + types² * A + sum((locals + params) * (controls + 1))`,
where `A` is at least one and otherwise the largest function parameter/result
count. It bounds instruction stack effects, pairwise type canonicalization and
local initialization snapshots. The limit remains 1,000,000 per module and is
summed across the enclosing component. Arithmetic is checked before products can
exceed that limit. Local expansion has its own 1,000,000 ceiling.
Function/initializer framing uses explicit control frames; block, loop and if
nesting is limited to 256. The retained binary parser and validator use explicit
stacks. Concrete references, GC types, supertypes and unimplemented proposals
reject before parsing. Function-only groups are supported when no concrete
references occur. Concrete memory64 and table64 limits retain all UInt64 bits;
semantic checks compare them unsigned. Memory limits also obey address width
and page size. Scalar and vector globals retain mutability and shared flags.
Shared globals require shared value types; unshared reference types reject.


`signaling_f32_constants` applies the same framing checks as `inspect_module`
and returns the byte offset of each `f32.const` opcode whose immediate is a
signaling NaN, in input order. The JavaScript target quiets these payloads when
it creates `Float` values, so consumers that need exact bits can reject them.


`check_external_subtype` and `check_module_subtype` compare already validated
contracts without I/O. Module imports are contravariant and exports covariant;
function/tag signatures and value/width/shared flags are invariant. Minimum and
maximum limits use unsigned comparisons, and optional page sizes remain distinct.
Import keys are `(module_name, name)` pairs; duplicate contract keys reject.
These operations do not certify caller-built types or executable instructions.

Both operations accept an optional work allowance and return its unused balance
on success. Signature widths and all map/traversal steps consume that allowance.
`CompatibilityError::Mismatch` carries the incompatible contract context;
`WorkLimit` distinguishes exhausted work from a type mismatch. WAC compatibility
and binary/runtime consumers use this same contract comparison.

`ContractGraph` and `ContractScope` retain immutable core metadata from an ordered
component scope pass. Module bindings retain complete contracts; scope bindings
refer to a flat table. Definition, indexed-binding and named-export lookups do
not follow scope links. Callers remain responsible for declaration ordering,
index validity and component semantics: constructing this metadata is not a
validation proof. Constructors take readonly snapshots, and internal lookup maps
are private.
