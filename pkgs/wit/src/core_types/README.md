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
`legacy_nested=true` rejects limits above u32 and custom memory page sizes in
nested component/instance type declarations, whose pinned dependency parser
cannot consume those encodings. Root core-type sections support full u64 limits.
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
The estimate is `bytes * max(function-type-count, body-count, 1) + expanded-locals`,
limited to 1,000,000 per module and summed across the enclosing component.
Flat function/initializer framing uses loops. Structured instructions, concrete
references, GC types, supertypes and unimplemented proposals reject before the
retained recursive parser runs. Function-only groups are supported when no
concrete references occur. Shared globals and limits above signed Int64 remain
outside the concrete-module profile because of the retained parser/validator.


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
