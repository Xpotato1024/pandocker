# Contributing

This repository is intended to be used through a small, predictable release flow.

## Branching and PR flow

1. Create or update an issue for the work.
2. Create a branch with the `codex/` prefix.
3. Make the smallest change that solves the issue.
4. Run the relevant checks locally.
5. Push the branch.
6. Open a pull request.
7. Merge after review and verification.

Example branch names:

- `codex/ci-foundation`
- `codex/release-flow`
- `codex/unix-entrypoint`

## Commit guidance

- Keep commits focused on a single outcome.
- Use an imperative subject line.
- Mention the issue number if one exists.

## Release flow

1. Merge the feature or fix branch.
2. Confirm the release assets are ready.
3. Push a version tag such as `v1.2.3`.
4. Let the release workflow publish the Windows zip and source archive.

## Local checks

Run the checks that match the files you changed:

```powershell
cargo check --locked --manifest-path tools/pdx-win/Cargo.toml
cargo check --locked --manifest-path tools/pdx-installer/Cargo.toml
```

```bash
bash -n pdx legacy/install.sh legacy/scripts/*.sh
```

If you touch release packaging or PowerShell scripts, also validate the relevant `.ps1` files in a PowerShell session.

## Documentation rules

- Update the docs when behavior changes.
- Keep `README.md`, `docs/windows-binary.md`, and `docs/roadmap.md` aligned with the actual implementation.
- Prefer explicit platform notes over assumptions about "multi-platform" support.

