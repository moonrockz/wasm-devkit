# Agent instructions

This is a MoonBit monorepo for WIT and WAC language tooling. Read README.md for the actual
implementation status. Do not claim scaffold packages implement their documented contracts.

## Toolchain and checks

- mise pins every tool in `.config/mise/config.toml`. Run `mise trust` and `mise install` once.
- Keep the MoonBit version and all platform URLs in sync.
- `moon.work` lists all members. Libraries go under `pkgs/`, executables under `apps/`.
- Write automation in cross-platform MoonBit `scripts/*.mbtx`, with mise tasks invoking `moonx`.
- Pin third-party imports. Use `moonbitlang/async` for processes, files and stdio,
  `moonbitlang/core/env` for arguments/environment and `moonbitlang/x/sys` for nonzero exits.
- `@env.args()[0]` is the script binary. Arguments begin at index 1.
- Prefer compiler, formatter, linter and focused tests for mechanical issues.
- Run `mise run format` before committing MoonBit code.
- `mise run lint`, `mise run validate` and `mise run test` must pass before pushing.
- `mise run check` adds all-target builds. Run `mise run test:scripts` after task changes.
- Install lefthook hooks with `mise run hooks:install`.
- Use Conventional Commits in plain English without AI attribution or Co-Authored-By lines.

## Language modules

`pkgs/wit` and `pkgs/wac` are independently consumable modules. Both reserve `span`, `diagnostic`,
`scanner`, `ast`, `cst`, `parser`, `traversal`, `printer` and `formatter` packages.
Their READMEs define intended boundaries. Implement capabilities with acceptance examples and laws.
Never add a successful stub parser or no-op formatter.

- Pin upstream grammar/corpus revisions, retain licenses and record skips on the relevant Beads task.
- Scanner and CST reconstruction reproduce exact input, including malformed tokens and trivia.
- Parsing reports diagnostics, recovers and never panics or raises out of the public operation.
- Public ASTs, CSTs and child collections are immutable. Do not expose mutable backing arrays.
- Traversals and immutable rewrites use explicit work stacks. No walk, fold, reduce, event reader,
  cursor, tree printer or formatter recurses through input-controlled nesting.
- Maintain one documented node-kind/field table per language and test coverage against it.
- Identical prune/stop decisions yield identical enter/leave order across traversal styles.
- Child spans lie inside parent spans. Document offset units and Unicode handling.
- Printer round trips preserve AST structure ignoring locations. Formatters retain comments,
  preserve meaning and are idempotent. Test invalid-input behavior.
- Use property tests and deep-input stress cases on wasm, wasm-gc, js and native.
- Avoid a shared syntax abstraction until implementations demonstrate a stable common contract.

## Working documents

`.dev/` is ignored local space for working specs, plans, scripts and output. Never stage it.
Use standalone HTML with inline CSS and SVG for working design documents.
Do not put working plans under `docs/`. Keep `docs/superpowers/` in `.git/info/exclude`;
do not add it to the tracked .gitignore. Commit reader-facing documentation intentionally.

## Releases

- Root `moon.mod` is the version source. `validate:versions` checks all members and version functions.
- `0.0.0` is an unpublished scaffold. Do not publish it.
- Read `.claude/skills/release-manager/SKILL.md` for release and troubleshooting instructions.
- `mise run release:prepare -- X.Y.Z` requires clean main and creates a local release branch.
  It runs the shared version setter and prepends a git-cliff changelog section.
- Replace the highlights placeholder, run all gates and commit `chore(release): vX.Y.Z`.
  Push and open a PR when authorized.
- After merging, manually dispatch `release.yml` with that version and `dry_run=true`.
  A separate dispatch with `dry_run=false` publishes immutable mooncakes.io versions.
- The workflow checks out main and verifies the requested version and notes before publication.
- `scripts/publish.mbtx` publishes only WIT and WAC with transient retries and duplicate handling.
  Keep its module list in sync with moon.work and the README.
- Validation precedes publication. GitHub release creation follows successful publication.
- Rerun failed jobs on transient failures. Never replace tags or published versions.
- Zig cross builds use the separately versioned `moonrockz/zig-cross` launcher; this repo does not publish it.

## Tracking

Use Beads for all work. Database `wasm_devkit` syncs only with
`git+https://github.com/moonrockz/wasm-devkit.git` and is independent of Smithy.

- Fresh clone: `bd bootstrap`. With no remote data: `bd init -p wasm-devkit --shared-server`.
- `bd prime` prints the workflow; `bd ready` lists unblocked work.
- Claim before starting with `bd update <id> --claim`; close when complete; `bd sync` at session end.
- Root epic: `wasm-devkit-p5m`. Keep separate child epics for WIT and WAC.
