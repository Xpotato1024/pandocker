# AGENTS.md

## このリポジトリの基本方針

- このリポジトリは `Pandocker-X` の source of truth です。
- 仕様はまず `README.md`、`defaults.yml`、`config/`、`tools/`、`templates/`、`preamble/`、`csl/` を確認してください。
- 実装と説明が食い違う場合は、実装と設定ファイルを優先して確認し、必要なら README も合わせて更新してください。

## 変更対象の考え方

- ビルド挙動の変更は、まず `tools/`、`config/`、`defaults.yml` を見ます。
- Windows の導入導線は `install.ps1` と `tools/pdx-installer/` を優先して扱ってください。
- 旧来のシェル / PowerShell スクリプトは `legacy/` に退避した前提で、原則として新規修正はしません。
- 新しい雛形やテンプレートの変更は `templates/` と `projects/<project>/src/` の関係を崩さないようにしてください。
- LaTeX 周りの調整は `preamble/` を優先し、テンプレート全体を大きく書き換えないでください。
- 引用スタイルの追加や切り替えは `csl/` と `report.md` の YAML ヘッダーの整合を保ってください。

## 生成物と作業領域

- `projects/<name>/src/` が編集対象の本文です。
- `projects/<name>/output/` はビルド成果物です。必要なとき以外は手を入れないでください。
- `log/` はビルドログです。調査以外では変更しないでください。
- `legacy/` は旧スクリプトの保管場所です。配布向けの本体は `tools/` の Rust バイナリです。
- 既存のプロジェクト配下では、`bib/`、`images/`、`src/` の役割を崩さないでください。

## 実行と検証

- Windows の導入は `install.ps1` を起点にし、内部では Rust 製 installer / binary を使う前提です。
- 変更後の基本確認は、対象環境で `pdx setup`、`pdx new "<name>"`、`pdx build "<name>"` のいずれか適切なものを使ってください。
- 変更がビルド系なら、少なくとも対象プロジェクトで `pdx build` を通してください。
- Rust の変更が入ったら `cargo check` と `cargo build --release` を確認してください。
- 文字コードやスクリプト変更が入る場合は、PowerShell / Bash の実行互換性も確認してください。
- GitHub release を切る場合は、`pdx.exe`、`pdx-bootstrap.exe`、`install.ps1` の配布物整合を確認してください。

## 編集ルール

- 文章は UTF-8 で保存してください。
- 既存の日本語表記、コマンド名、ファイル構成は勝手に置き換えないでください。
- 変更はできるだけ小さく、影響範囲の近いファイルに閉じてください。
- 実装を変えたら、関連する README やサンプルも必要に応じて追従させてください。

## 迷ったときの優先順位

1. `README.md` の説明
2. `defaults.yml` と `config/`
3. `tools/`
4. `templates/`
5. `projects/<name>/`

