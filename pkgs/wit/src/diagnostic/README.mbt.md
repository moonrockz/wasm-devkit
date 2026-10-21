# WIT diagnostic

[Module scenario guide](../../README.mbt.md#scenario-recipes) · [API contracts](#api-contracts)

## Recipes

These executable examples use the following `moon.pkg` test imports. Add the module
with `moon add moonrockz/wit@0.3.0`, then copy a recipe into `example_test.mbt`
and run `moon test`. Application code uses the same imports without `for "test"`.

If your package already has a test import group, merge these entries into it.

```moon.pkg
import {
  "moonrockz/wit/diagnostic",
  "moonrockz/wit/span",
} for "test"
```

### Attach an application diagnostic to source

```mbt check
///|
test "README: Attach an application diagnostic to source" {
  let span : @span.Span = { start: 0, end: 4, }
  let diagnostic = @diagnostic.Diagnostic::error(
    "APP-001",
    "unknown import",
    span,
    recovery=SkipToken,
  )
  assert_eq(diagnostic.code, "APP-001")
  assert_eq(diagnostic.severity, Error)
  assert_eq(diagnostic.primary.span, span)
  assert_eq(diagnostic.recovery, SkipToken)
}
```

### Connect a duplicate declaration to its original

```mbt check
///|
test "README: Connect a duplicate declaration to its original" {
  let primary : @span.Span = { start: 10, end: 14, }
  let base = @diagnostic.Diagnostic::error(
    "APP-DUPLICATE", "duplicate name", primary,
  )
  let diagnostic : @diagnostic.Diagnostic = {
    ..base,
    severity: Warning,
    related: [{ span: { start: 0, end: 4, }, message: "first declared here", }],
  }
  assert_eq(diagnostic.related.length(), 1)
  assert_eq(diagnostic.related[0].message, "first declared here")
  assert_true(base.related.is_empty())
}
```

## API contracts

`Diagnostic` contains a stable string code, severity, message, primary label,
immutable related labels and the recovery action taken by the frontend.
Labels refer to UTF-16 source spans. Messages can change; use codes for programmatic handling.

`Diagnostic::error(code, message, span, recovery=Continue)` constructs an error with no
related labels. Callers can construct diagnostics with `ReadOnlyArray[Label]` for related locations.
Copy mutable arrays with `ReadOnlyArray::from_array` before storing them.

Recovery is `Continue`, `SkipToken` or `EndOfInput`. Scanner diagnostics are data;
lexical errors do not raise from `scan`.
