# AGENTS.md

## このリポジトリの基本方針

- このリポジトリは `Pandocker-X` の source of truth です。
- 仕様はまず `README.md`、`defaults.yml`、`config/`、`tools/`、`templates/`、`preamble/`、`csl/` を確認してください。
- 実装と説明が食い違う場合は、実装と設定ファイルを優先して確認し、必要なら `README.md` も合わせて更新してください。
- 文章は UTF-8 で保存してください。
- 既存の日本語表記、コマンド名、ファイル構成は勝手に置き換えないでください。

## Repository guard

- repository identity は `Xpotato1024/Pandocker-X` です。
- default branch の source of truth は `gh repo view --json nameWithOwner,defaultBranchRef` の `defaultBranchRef.name` です。
- 現時点の `defaultBranchRef.name` は `master` です。
- PR base は `master` です。
- repository が `Xpotato1024/Pandocker-X` でなければ停止してください。
- 特に `Xpotato1024/Selfrionette` では絶対に作業しないでください。

## 作業前 preflight

作業前に必ず次を実行してください。

```powershell
git remote -v
git branch --show-current
git status --short --branch
gh repo view --json nameWithOwner,defaultBranchRef
```

次のいずれかがあれば、作業を止めて報告してください。

- repository mismatch
- wrong base branch
- unrelated working tree changes
- validation failure
- Docker / TeX runtime gap

## 出力形式 guard

- Markdown の prompt や説明文では、nested triple-backtick code fence を作らないでください。
- 複数の prompt を示すときは、独立した code block として分けてください。
- command example は prompt block 内では plain text として書いてください。
- 生成物や PR 本文で、読みにくい表示崩れを作らないでください。

## Phase / Round / Issue の扱い

- Phase は大きな謎解きのまとまりです。
- Round は Codex に 1 回実行させる単位です。
- Issue は 1 PR に収める実装単位です。
- Codex に任せるのは Round までであり、Phase 丸ごとは任せないでください。
- 1 issue = 1 PR を守ってください。
- Phase を 1 round で終わらせようとしないでください。
- Issue の範囲を超える変更は次の round に分離してください。

## PR ルール

- branch 名は `codex/<issue-number>-<short-description>` にしてください。
- 通常運用では Codex は merge しないでください。
- safe for merge は implementation worker が宣言しないでください。
- gpt-5.5 review なしに safe for merge, Round complete, goal complete を宣言しないでください。
- PR 本文には少なくとも Summary, Changed Files, What Changed, Validation Run, Scope Check, Scope Exclusions, Runtime / Docker / TeX Status, Branch / Diff Gate, Remaining Risks, Handoff を含めてください。
- Related issue も必要に応じて明記してください。

## Validation ルール

- 変更後の基本確認は、対象環境で `pdx setup`、`pdx new "<name>"`、`pdx build "<name>"` のいずれか適切なものを使ってください。
- 変更がビルド系なら、少なくとも対象プロジェクトで `pdx build` を通してください。
- Rust の変更が入ったら `cargo check` と `cargo build --release` を確認してください。
- 文字コードやスクリプト変更が入る場合は、PowerShell / Bash の実行互換性も確認してください。
- Markdown docs-only 変更では `git diff --check` を必ず通してください。
- 必要に応じて `git diff --name-only origin/master...HEAD` と `git status --short --branch` で差分境界を確認してください。

## Pandocker-X 固有の作業知識

- build 挙動の変更は、まず `tools/`、`config/`、`defaults.yml` を見ます。
- Windows の導入導線は `install.ps1` と `tools/pdx-installer/` を優先して扱ってください。
- 旧来のシェル / PowerShell スクリプトは `legacy/` に退避した前提で、原則として新規修正はしません。
- 新しい雛形やテンプレートの変更は `templates/` と `projects/<project>/content/` の関係を崩さないようにしてください。
- LaTeX 周りの調整は `preamble/` を優先し、テンプレート全体を大きく書き換えないでください。
- 引用スタイルの追加や切り替えは `csl/` と report 系 YAML header の整合を保ってください。
- `projects/<name>/content/` が編集対象の本文です。
- `projects/<name>/output/` はビルド成果物です。必要なとき以外は手を入れないでください。
- `log/` はビルドログです。調査以外では変更しないでください。
- 現行の issue 順は `#10`, `#11`, `#12`, `#9`, `#14`, `#13` です。

## Docker / TeX runtime ルール

- Pandocker-X は Docker runtime を正としてください。
- host TeX Live を通常依存として扱わないでください。
- template target が `lualatex`, `platex`, `uplatex`, `pbibtex`, `dvipdfmx`, `latexmk` を必要とするなら、それらは Docker image / runtime 側に必要です。
- target descriptor の要求と Docker image の実体を混同しないでください。

## Unified template target ルール

- `paper-build` や `template-build` のような別 top-level command を作らないでください。
- user-facing route は `pdx new <name>`、`pdx new <name> --target <target-id>`、`pdx build <name>` に統一してください。
- default report workflow は `default-report` target として扱ってください。
- 複数の入口を増やして利用者の導線を分岐させないでください。

## 禁止事項

- main への直接 commit はしないでください。
- PR merge はしないでください。
- GitHub Release の作成はしないでください。
- release asset upload はしないでください。
- secrets / credentials の編集はしないでください。
- deployment keys の変更はしないでください。
- destructive Docker cleanup はしないでください。
- Xpotato1024/Selfrionette で作業しないでください。
- host TeX Live を source of truth として扱わないでください。
- nested triple-backtick を prompt 内に作らないでください。

## stop condition

次の条件が出たら作業を止めて報告してください。

- repository mismatch
- wrong base branch
- issue scope exceeded
- unrelated working tree changes
- validation failure outside the scope
- Docker / TeX runtime gap
- release publishing が必要だが許可されていない
- required gpt-5.5 review を満たせない

## 詳細 docs への参照

- Round 一括実行の詳細: `docs/agent/codex-round-batch-execution-guardrails.md`
- Phase / Round / Issue 設計の詳細: `docs/agent/phase-round-issue-design-rules.md`

## 迷ったときの参照順

1. `README.md`
2. `defaults.yml` と `config/`
3. `tools/`
4. `templates/`
5. `projects/<name>/`
