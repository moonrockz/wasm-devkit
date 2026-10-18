# WAC parser

`parse(text, features=Features::default())` returns immutable AST/CST arenas and structured
diagnostics. `Parse::is_valid()` means no error diagnostics. Parsing is pure, performs no
I/O and returns errors as data. Its grammar continuations use explicit heap tasks, including
type syntax, grouped expressions and nested instantiations. Recovery keeps exact source in
the CST and continues at declaration boundaries. Invalid input never becomes a successful stub.

The baseline is [bytecodealliance/wac at the pinned revision](fixtures/README.md). Tests embed
all 163 upstream `.wac` files unchanged and compare syntax acceptance with its public Rust
`Document::parse`. The manifest records hashes and classifications. No files are skipped.
The syntax layer accepts unresolved names, duplicate definitions and semantically invalid
compositions, as the reference syntax parser does.

Supported syntax includes the required initial package directive, optional targets, WAC
interface/world/type definitions, scoped use/include, imports, let bindings, instantiation
arguments, grouped expressions, access chains and exports. Async functions, future, stream
and error-context types are included. Atomic package paths may have multiple namespace and
path components. `borrow` takes a named resource. Tuples and record/flags/enum/variant bodies
require members. Empty resource/interface/world bodies are valid. Constructors have parameters
and no results. Interface functions may name a function type; resource methods use signatures.

WAC differs from WIT in its atomic package tokens, raw string names, supported type forms,
placement of declarations and semicolons after inline interface externs and include clauses.
It has no `own`, `map`, fixed-length list, attributes, accessor signatures or nested package
blocks. See the scanner README for identifier, Unicode and string rules.

`Features.named_results`, disabled by default, enables the named-results syntax described
in upstream `LANGUAGE.md` but rejected by its pinned parser. `Features::all()` enables it.
Disabled syntax remains represented with `WAC-P005`. The reference's empty `func() ->;`
result spelling is accepted and represented as an absent result. Result placeholders `_`
represent absent slots, including `result<_>` and `result<_,_>`.

| Code | Meaning |
|------|---------|
| `WAC-P001` | Expected grammar token/member/type/expression |
| `WAC-P002` | Invalid semantic version |
| `WAC-P003` | Invalid grammar scope, package path or empty aggregate |
| `WAC-P005` | Disabled named-results extension |
| `WAC-P006` | Skipped malformed declaration |

Diagnostic and node spans count UTF-16 code units. The root covers all input; concrete
node ranges include internal/following trivia. Acceptance tests, arbitrary-input and
malformed-fragment properties, node-kind coverage, recovery checks and 20,000-level stress
tests run on wasm, wasm-gc, js and native.
