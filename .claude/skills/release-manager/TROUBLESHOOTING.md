# Release troubleshooting

## Version mismatch

Run `mise run validate:versions`. Use `moonx scripts/versions.mbtx set X.Y.Z` on the release branch,
then check the diff. Do not change third-party pins.

## Missing notes or unfinished highlights

The workflow refuses a missing version section or unfinished highlights.
Fix CHANGELOG.md in a reviewed PR, merge it and dispatch again.

## Registry authentication failure

Ensure MOONCAKES_USER_TOKEN is available to this repository. `release:credentials` writes credentials
using MOON_HOME when set. Do not print tokens or commit credentials.

## Partial publication

Run `gh run rerun <run-id> --failed` after a transient error. Already-published versions count as done.
For a permanent code problem, release a new version; registry versions cannot be overwritten.

## Publication succeeded but GitHub release failed

Rerun failed jobs on the same workflow run to retain its validated commit and version.
GitHub release creation is idempotent and refuses to reuse a tag for another commit.
