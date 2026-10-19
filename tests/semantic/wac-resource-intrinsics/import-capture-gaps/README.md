# Local-resource import capture regressions

Both pinned validators reject the original seven components because their
imports capture resources defined by the importing component. The product now
rejects them as WAC-B003 for both binary and WAT input. `results.json` preserves
the original false-positive outcome and the corrected result; these are no
longer open conformance gaps.

The 39 cases in `cases.tsv` compare both reference pins with binary and WAT
loading. They cover type equality, own/borrow functions, nested instance and
component contracts, and valid unused outer resources, unused nested captures,
fresh abstract binders, imported resource captures and shadowed names. Accepted
cases compare complete ordered public model projections. The parent README
identifies the reference revisions and license.

The import audit follows reachable members and value graphs using explicit
stacks and the shared metadata work allowance. Separate whitebox tests cover
6,000 nested contracts, shared value DAGs, complete function signatures,
cumulative budget exhaustion and unavailable metadata. Explicit WAT outer
aliases do not introduce an extra implicit alias or shift numeric type indices.
