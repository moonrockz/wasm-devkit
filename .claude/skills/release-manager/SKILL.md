---
name: release-manager
description: Prepare, validate, publish and troubleshoot wasm-devkit library and CLI releases.
---

# Release manager

Read AGENTS.md and README.md. This repository publishes WIT/WAC libraries, the moonx CLI and native CLI release archives.
Version 0.0.0 is an unpublished scaffold and must never be released.

1. Check clean main, current CI and `mise run release:status`. Check which capabilities are ready.
2. Track the release in Beads under wasm-devkit-p5m. Claim the task.
3. Inspect `mise run release:version`, then run `mise run release:prepare -- X.Y.Z`
   with the intended version. This only makes local changes.
4. Replace the CHANGELOG.md highlights placeholder with concrete user-facing changes.
   Run `mise run check` and `mise run test:scripts`.
5. Commit `chore(release): vX.Y.Z`, push and open a release PR within the user's authorization.
   Check CI and review comments before merging.
6. After merge, dispatch `gh workflow run release.yml --ref main -f version=X.Y.Z -f dry_run=true`.
   Wait for validation to pass.
7. When publishing is authorized, dispatch again with `dry_run=false`. The workflow validates main,
   publishes WIT, WAC and the CLI to mooncakes.io, verifies moonx, creates the GitHub release
   with native archives and verifies mise installation.
8. Run `mise run release:status`, verify all three registry entries, moonx/mise installation and the GitHub tag/release,
   close the task and run `bd sync`.

Publishing needs MOONCAKES_USER_TOKEN and is permanent. Do not publish scaffold modules,
delete releases or move tags. Rerun failed jobs after transient network failures.
See TROUBLESHOOTING.md for partial-publication recovery.
