# Roadmap

This document tracks the near-term public-repo work that still needs to be finished or expanded.

## Current priorities

1. Keep the CI workflow green on Windows and Unix.
2. Keep the release workflow publishing both Windows binaries and source archives.
3. Expand the Unix source-release experience so it is clearly documented and easy to bootstrap.
4. Add regression tests for Rust code where practical.
5. Reduce reliance on historical scripts under `legacy/`.

## Follow-up ideas

- Add a machine-readable release checklist.
- Add a docs check that validates key links and file references.
- Add example project snippets that show the expected file layout for new reports.
- Replace remaining ad hoc script logic with shared helpers where it improves maintainability.

## Non-goals for now

- A complete rewrite of the historical shell scripts.
- Introducing package-manager based distribution outside GitHub Releases.
- Reworking the project template layout without a user-facing need.

