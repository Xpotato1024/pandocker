# AGENTS.md

## このリポジトリの基本方針

- このリポジトリは `Pandocker-X` の source of truth。
- 仕様はまず `README.md`、`defaults.yml`、`config/`、`tools/`、`templates/`、`preamble/`、`csl/` を確認する。
- 実装と説明が食い違う場合は、実装と設定ファイルを優先して確認し、必要なら `README.md` も更新する。
- 文章は UTF-8 で保存する。
- 既存の日本語表記、コマンド名、ファイル構成は勝手に置き換えない。

## Repository guard

- repository identity は `Xpotato1024/Pandocker-X`。
- default branch の source of truth は `gh repo view --json nameWithOwner,defaultBranchRef` の `defaultBranchRef.name`。
- 現時点の `defaultBranchRef.name` は `master`。
- PR base は `master`。
- `Xpotato1024/Pandocker-X` 以外では作業しない。
- `Xpotato1024/Selfrionette` では絶対に作業しない。

## 作業前 preflight

- 作業前に次を実行する。
- `git remote -v`
- `git branch --show-current`
- `git status --short --branch`
- `gh repo view --json nameWithOwner,defaultBranchRef`
- 次のいずれかがあれば停止する。
- repository mismatch
- wrong base branch
- unrelated working tree changes
- validation failure
- Docker / TeX runtime gap

## 出力形式 guard

- Markdown の prompt や説明文で nested triple-backtick code fence を作らない。
- 複数の prompt は独立した code block に分ける。
- command example は prompt block 内では plain text として書く。
- 生成物や PR 本文で、読みにくい表示崩れを作らない。

## Phase / Round / Issue の扱い

- Phase = 大きな技術的到達点。
- Round = Codex に 1 回やらせる実行単位。
- Issue = 1 PR に収める変更単位。
- Codex に任せるのは Round まで。
- 1 issue = 1 PR。
- Phase を 1 round で終わらせない。
- Issue の範囲を超える変更は次の round に分離する。

## PR ルール

- branch 名は `codex/<issue-number>-<short-description>` にする。
- Codex は明示許可なしに merge しない。
- implementation worker は safe for merge を宣言しない。
- gpt-5.5 review なしに safe for merge, Round complete, goal complete を宣言しない。
- PR 本文には `Summary`, `Changed Files`, `What Changed`, `Validation Run`, `Scope Check`, `Scope Exclusions`, `Runtime / Docker / TeX Status`, `Branch / Diff Gate`, `Remaining Risks`, `Handoff` を含める。
- `Related issue` も必要に応じて明記する。

## Validation ルール

- 全PR: `git diff --check` / `git status --short --branch` / `git diff --name-only origin/master...HEAD`
- shell 変更: `bash -n pdx`
- Rust 変更: `cargo check --locked --manifest-path tools/pdx-win/Cargo.toml`
- Rust 変更: `cargo check --locked --manifest-path tools/pdx-installer/Cargo.toml`
- Docker / Pandoc / LaTeX 変更: `pdx setup` / `pdx new smoke-report` / `pdx build smoke-report -Log` / `test -f projects/smoke-report/output/report.pdf`
- docs-only 変更: diff gate / `git diff --check` / mojibake grep

## Pandocker-X 固有の作業知識

- build 挙動の変更は、まず `tools/`、`config/`、`defaults.yml` を見る。
- Windows の導入導線は `install.ps1` と `tools/pdx-installer/` を優先する。
- source checkout は `install.ps1`、installed mode は `tools/pdx-installer/` を使う。
- 旧来のシェル / PowerShell スクリプトは `legacy/` に退避した前提で、原則として新規修正しない。
- 新しい雛形やテンプレートの変更は `templates/` と `projects/<project>/content/` の関係を崩さない。
- LaTeX 周りの調整は `preamble/` を優先し、テンプレート全体を大きく書き換えない。
- 引用スタイルの追加や切り替えは `csl/` と report 系 YAML header の整合を保つ。
- `projects/<name>/content/` は本文。
- `projects/<name>/output/` は生成物。
- `log/` はビルドログ。
- `source checkout` と `installed mode` の境界を崩さない。
- 現行の issue 順は `#10`, `#11`, `#12`, `#9`, `#14`, `#13`。

## Docker / TeX runtime ルール

- Pandocker-X は Docker runtime を正とする。
- host TeX Live を通常依存として扱わない。
- target が `lualatex`, `platex`, `uplatex`, `pbibtex`, `dvipdfmx`, `latexmk` を要求するなら、container 内に必要。
- target descriptor の要求と Docker image の実体を混同しない。

## Unified template target ルール

- `paper-build` や `template-build` のような別 top-level command を作らない。
- user-facing route は `pdx new <name>`、`pdx new <name> --target <target-id>`、`pdx build <name>` に統一する。
- default report workflow は `default-report` target として扱う。
- 複数の入口を増やして利用者の導線を分岐させない。

## 禁止事項

- default branch への直接 commit はしない。
- PR merge はしない。
- GitHub Release の作成はしない。
- release asset upload はしない。
- secrets / credentials の編集はしない。
- deployment keys の変更はしない。
- destructive Docker cleanup はしない。
- host TeX Live を source of truth として扱わない。
- nested triple-backtick を prompt 内に作らない。

## stop condition

- 次の条件が出たら作業を止めて報告する。
- repository mismatch
- wrong base branch
- issue scope exceeded
- unrelated working tree changes
- validation failure outside the scope
- Docker / TeX runtime gap
- release publishing ambiguity
- required gpt-5.5 review unavailable

## 詳細 docs への参照

- Round 一括実行の詳細: `docs/agent/codex-round-batch-execution-guardrails.md`
- Phase / Round / Issue 設計の詳細: `docs/agent/phase-round-issue-design-rules.md`

## 運用メモ

- 迷いがあれば Round を止める。
- scope 外の修正は別 issue に分離する。
- PR 本文は実差分と一致させる。
- 文字化けが出たら保存形式を疑う。
- 詳細な理由は `docs/agent/` に逃がす。

## 迷ったときの参照順

1. `README.md`
2. `defaults.yml` と `config/`
3. `tools/`
4. `templates/`
5. `projects/<name>/`
