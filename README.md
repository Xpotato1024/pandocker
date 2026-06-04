# Pandocker-X

Pandocker-X は、Markdown を Pandoc と LaTeX で PDF に変換するための Docker ベースのワークフローです。

このリポジトリは、次の内容に対する source of truth です。

- プロジェクト雛形
- Docker イメージとビルド設定
- Windows 向け配布バイナリ
- Linux / macOS 向け source release の起点

## 利用方法

### Windows

Windows では、Rust 製の配布バイナリをインストールして WSL 経由で使います。

- release asset: `pandocker-x-windows-<version>.zip`
- checksum asset: `pandocker-x-checksums-<version>.sha256`
- ローカル checkout 用の導入スクリプト: `install.ps1`
- 実行環境: WSL 2、Docker Desktop または WSL Docker

インストール後の典型的な実行例:

```powershell
.\pdx-bootstrap.exe install
```

### Linux / macOS

Linux と macOS では、source release かローカル checkout を使い、ルート直下の Unix `pdx` を実行します。

- release asset: `pandocker-x-source-<version>.zip`
- checksum asset: `pandocker-x-checksums-<version>.sha256`
- エントリポイント: `./pdx`
- 実行環境: Docker、Docker Compose、`jq`

初回実行の例:

```bash
./pdx setup
./pdx new sample-report
./pdx build sample-report
```

## クイックスタート

### Windows の source checkout

```powershell
.\install.ps1
pdx setup
pdx new sample-report
pdx build sample-report
```

### Linux / macOS の source checkout または source release

```bash
./pdx setup
./pdx new sample-report
./pdx build sample-report
```

## ディレクトリ構成

- `config/` - 実行設定と WSL ヘルパー
- `templates/` - `pdx new` が使うテンプレート
- `preamble/` - LaTeX の preamble 断片
- `csl/` - 引用スタイル
- `tools/` - Windows 導入と setup 用の Rust バイナリ
- `projects/<name>/content/` - Markdown 本文
- `projects/<name>/output/` - 生成済み PDF
- `docs/` - release、support、roadmap の文書

## Release の流れ

公開 release は次の流れで進めます。

1. Issue を作成または更新する。
2. `codex/` プレフィックスの branch を切る。
3. 変更を commit する。
4. branch を push する。
5. PR を作る。
6. レビュー後に merge する。
7. `v1.2.3` のような release tag を push する。

詳しい運用は [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## OSS 向けの案内

- License は [MIT License](LICENSE) です。
- 変更提案は [CONTRIBUTING.md](CONTRIBUTING.md) に従ってください。
- Security report は [SECURITY.md](SECURITY.md) を参照してください。
- Release asset には Windows zip、source archive、checksum file が含まれます。検証手順は [docs/release.md](docs/release.md) を参照してください。

## 文書

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [SECURITY.md](SECURITY.md)
- [docs/release.md](docs/release.md)
- [docs/windows-binary.md](docs/windows-binary.md)
- [docs/roadmap.md](docs/roadmap.md)
- [docs/build-metrics.md](docs/build-metrics.md)
- [docs/agent/codex-round-batch-execution-guardrails.md](docs/agent/codex-round-batch-execution-guardrails.md)
- [docs/agent/phase-round-issue-design-rules.md](docs/agent/phase-round-issue-design-rules.md)

## 補足

- `legacy/` には旧来の shell / PowerShell スクリプトがあります。参照・互換用であり、主要な導線ではありません。
- GitHub release asset には Windows binaries、Unix 向け source archive、checksum file が含まれます。
