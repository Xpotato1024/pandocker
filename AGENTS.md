# AGENTS.md

## このリポジトリの基本方針

- このリポジトリは `Pandocker-X` の source of truth 。
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

- 変更後の基本確認は、対象環境で `pdx setup`、`pdx new "<name>"`、`pdx build "<name>"` のいずれか適切なものを使う。
- 変更がビルド系なら、少なくとも対象プロジェクトで `pdx build` を通す。
- Rust の変更が入ったら `cargo check` と `cargo build --release` を確認する。
- 文字コードやスクリプト変更が入る場合は、PowerShell / Bash の実行互換性も確認する。
- Markdown docs-only 変更では `git diff --check` を必ず通す。
- 必要に応じて `git diff --name-only origin/master...HEAD` と `git status --short --branch` で差分境界を確認する。
- shell 変更では `bash -n pdx` を通す。
- Rust 変更では `cargo check --locked --manifest-path tools/pdx-win/Cargo.toml` を通す。
- Rust 変更では `cargo check --locked --manifest-path tools/pdx-installer/Cargo.toml` を通す。
- Docker / Pandoc / LaTeX 変更では `pdx setup`、`pdx new smoke-report`、`pdx build smoke-report -Log` を通す。
- `projects/smoke-report/output/report.pdf` の有無を確認する。
- docs-only では `README.md` の docs/agent リンク以外を増やさない。
- 詳細な検証条件は `docs/agent/` に逃がす。

## Pandocker-X 固有の作業知識

- build 挙動の変更は、まず `tools/`、`config/`、`defaults.yml` を見る。
- Windows の導入導線は `install.ps1` と `tools/pdx-installer/` を優先する。
- 旧来のシェル / PowerShell スクリプトは `legacy/` に退避した前提で、原則として新規修正しない。
- 新しい雛形やテンプレートの変更は `templates/` と `projects/<project>/content/` の関係を崩さない。
- LaTeX 周りの調整は `preamble/` を優先し、テンプレート全体を大きく書き換えない。
- 引用スタイルの追加や切り替えは `csl/` と report 系 YAML header の整合を保つ。
- `projects/<name>/content/` は本文。
- `projects/<name>/output/` は生成物。
- `log/` はビルドログ。
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
- forbidden files を差分に混ぜない。
- 文字化けが出たら保存形式を疑う。
- 詳細な理由は `docs/agent/` に逃がす。

## 固定事項

- README.md の変更は docs/agent のリンク追加に限定する。
- `legacy/` は原則として新規修正しない。
- Docker runtime を正とする。
- host TeX Live を通常依存にしない。
- current issue order は `#10`, `#11`, `#12`, `#9`, `#14`, `#13`。
- command list は 1 回だけ書く。
- 差分境界は `git diff --name-only origin/master...HEAD` で確認する。
- 理由と例外は `docs/agent/` に書く。
- README.md の docs/agent link だけを維持する。
- `docs/agent` の詳細は削らない。
- `pdx` と `.github/workflows/ci.yml` を差分に含めない。

## 迷ったときの参照順

1. `README.md`
2. `defaults.yml` と `config/`
3. `tools/`
4. `templates/`
5. `projects/<name>/`
