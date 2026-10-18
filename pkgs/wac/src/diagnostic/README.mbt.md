# WAC diagnostic

`Diagnostic` contains a stable string code, severity, message, primary label,
immutable related labels and the recovery action taken by the frontend.
Labels refer to UTF-16 source spans. Messages can change; use codes for programmatic handling.

`Diagnostic::error(code, message, span, recovery=Continue)` constructs an error with no
related labels. Callers can construct diagnostics with `ReadOnlyArray[Label]` for related locations.
Copy mutable arrays with `ReadOnlyArray::from_array` before storing them.

Recovery is `Continue`, `SkipToken` or `EndOfInput`. Scanner diagnostics are data;
lexical errors do not raise from `scan`.
