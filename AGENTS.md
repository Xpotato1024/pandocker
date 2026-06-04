# AGENTS.md

## Codex / Agent Guardrails

- This repository is `Pandocker-X`.
- Repository identity: `Xpotato1024/Pandocker-X`.
- Treat `gh repo view --json nameWithOwner,defaultBranchRef` as the source of truth for the default branch.
- At present, `defaultBranchRef.name` is `master`, and PR base should be `master`.
- Before starting work, always run:
  - `git remote -v`
  - `git branch --show-current`
  - `git status --short --branch`
  - `gh repo view --json nameWithOwner,defaultBranchRef`
- Detailed rules live in:
  - `docs/agent/codex-round-batch-execution-guardrails.md`
  - `docs/agent/phase-round-issue-design-rules.md`
- Do not use any base branch other than the default branch reported by `gh repo view`.
- Stop and report on repository mismatch, wrong base branch, unrelated working tree changes, validation failure, or a Docker / TeX runtime gap.
- Do not create nested triple-backtick fences inside Markdown prompt examples.
- Keep to 1 issue = 1 PR.

## Reference Order

1. `README.md`
2. `defaults.yml` and `config/`
3. `tools/`
4. `templates/`
5. `projects/<name>/`
