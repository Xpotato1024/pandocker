# Phase / Round / Issue Design Rules

## Intent

This document defines the relationship between project phases, Codex rounds, and individual issues for `Pandocker-X`.

## Definitions

- Phase: a major multi-step initiative.
- Round: one Codex pass that moves a phase forward.
- Issue: one reviewable unit of work that should become one PR.

## Design rules

- Do not collapse a phase into a single round.
- Do not split a single issue across multiple unrelated PRs.
- Prefer one branch, one issue, one PR.
- Keep implementation, validation, and documentation aligned with the same issue scope.

## PR rules

- Base branch: `master`
- Branch name: `codex/<issue-number>-<short-description>`
- PR body should include:
  - `Closes #<issue-number>`
  - validation results
  - scope exclusions
  - runtime or Docker status
  - branch and diff gate notes

## Validation rules

Use the validation that matches the change type:

```bash
git diff --check
git status --short --branch
git diff --name-only origin/master...HEAD
```

Repository-specific checks may include:

```bash
bash -n pdx
cargo check --locked --manifest-path tools/pdx-win/Cargo.toml
cargo check --locked --manifest-path tools/pdx-installer/Cargo.toml
./pdx setup
./pdx new smoke-report
./pdx build smoke-report -Log
test -f projects/smoke-report/output/report.pdf
```

## Runtime rules

- Build in Docker when the repository expects Docker-based output.
- Do not treat host TeX Live as the source of truth when the Docker runtime is the supported path.
- Keep template target support consistent with the runtime that actually ships.

## Unified template target rule

- Keep the user-facing entrypoints stable.
- Do not introduce extra top-level commands that fragment the workflow.
- Prefer a single `pdx new` and `pdx build` route, with target selection handled through supported options.

## Forbidden actions

- Do not commit directly to `master`.
- Do not merge a PR without review authorization.
- Do not upload release assets unless the task explicitly requires release work.
- Do not make destructive cleanup changes to Docker or project data.
- Do not use host TeX Live as an assumed replacement for the supported build path.

## Review rule

- A round is not complete until the change is safe for review.
- If the work touches behavior, require the appropriate review and validation before declaring it done.

## Stop conditions

Stop and report if any of the following are true:

- repository mismatch
- wrong base branch
- issue scope exceeded
- unrelated working tree changes
- validation failure outside the scope of the issue
- Docker or TeX runtime gap
- release publishing is implied but not authorized
- required review is unavailable

## Related reference

- `docs/agent/codex-round-batch-execution-guardrails.md`

