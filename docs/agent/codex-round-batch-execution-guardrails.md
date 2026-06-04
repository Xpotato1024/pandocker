# Codex Round Batch Execution Guardrails

## Repository identity

- Project: `Pandocker-X`
- Repository: `Xpotato1024/Pandocker-X`
- Default branch: `master`

If the repository identity does not match, stop and report before making changes.

## Mandatory preflight

Before starting a round, confirm the current repository state with:

```powershell
git remote -v
git branch --show-current
git status --short --branch
gh repo view --json nameWithOwner,defaultBranchRef
```

Treat any mismatch in repository identity, default branch, or unexpected working tree changes as a stop condition.

## Output formatting guard

- Keep prompt and instruction text readable in Markdown.
- Do not nest triple-backtick fences inside another fenced block.
- If a command list needs to appear inside a prompt example, use plain text or separate fenced blocks.

## Work hierarchy

- Phase: a larger strategic effort. Do not try to complete a phase in one Codex round.
- Round: one Codex implementation pass.
- Issue: one PR-sized unit of work.
- Keep one issue per PR.

## Scope discipline

- Stay inside the issue scope assigned for the round.
- If the work expands into a different problem, stop and ask for direction.
- Do not mix unrelated repository cleanup into the same PR.

## Validation rule

- Run the smallest validation set that proves the change.
- For docs-only changes, check Markdown and diff hygiene.
- For behavior changes, add the repository-specific build and smoke checks required by the issue.

## Documentation references

- `docs/agent/phase-round-issue-design-rules.md`
- `README.md`

