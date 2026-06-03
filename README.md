# Pandocker-X

[![最新リリース](https://img.shields.io/github/v/release/Xpotato1024/Pandocker-X?include_prereleases)](https://github.com/Xpotato1024/Pandocker-X/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Pandocker-X は、Markdown から PDF を作るための Docker ベースの環境です。
Windows / Linux / macOS で、`pdx` コマンドからセットアップ・新規作成・PDF ビルドを行えます。

## 導入

### Windows

GitHub Release では zip 形式で配布し、展開後に `pdx-bootstrap.exe` を直接実行してください。

```powershell
.\pdx-bootstrap.exe install
```

`pdx-bootstrap.exe` は Rust 製の CLI installer で、`pdx.exe` を所定の場所へ配置して PowerShell 用の wrapper を登録します。
GUI から導入したい場合は、同梱の `pdx-installer-gui.exe` を起動してください。

- `tools/pdx-win/` に `pdx.exe`
- `tools/pdx-installer/` に `pdx-bootstrap.exe`
- `tools/pdx-installer/` に `pdx-installer-gui.exe`

`install.ps1` はソースツリー用の補助です。リリースでは必須ではありません。

詳細は [docs/windows-binary.md](docs/windows-binary.md) を参照してください。

release 用の zip を作るには、`release/package-windows-release.ps1` を使います。

### Linux / macOS

旧スクリプトは `legacy/` に退避しています。必要な場合は以下を使ってください。

```bash
source ./legacy/install.sh
```

## 使い方

### 初回セットアップ

```powershell
pdx setup
```

### 新規作成

```powershell
pdx new <プロジェクト名>
```

論文用の初期設定を使う場合は `-Paper` を付けます。

```powershell
pdx new <プロジェクト名> -Paper
```

### ビルド

基本形は次の通りです。

```powershell
pdx build <プロジェクト名>
```

何も指定しない場合は、`projects/<プロジェクト名>/src/report.md` をビルドします。

複数ファイルを分けてビルドする場合は、`プロジェクト名` の後ろに対象ファイル名を並べます。
ファイル名は `projects/<プロジェクト名>/src/` からの相対パスです。

```powershell
pdx build <プロジェクト名> chapter1.md chapter2.md appendix/appendix.md
```

プロジェクト配下の Markdown をすべて再帰的にビルドする場合は `-All` を使います。

```powershell
pdx build <プロジェクト名> -All
```

ビルドログを保存する場合は `-Log` を併用します。

```powershell
pdx build <プロジェクト名> -All -Log
```

### オプションの整理

- `pdx build` の第 1 引数はプロジェクト名です
- その後ろに並ぶ引数はビルド対象ファイルです
- `-All` は `src/` 配下の Markdown を再帰的に全部対象にします
- `-Log` は `log/` に pandoc のログを保存します
- 個別ファイル指定と `-All` は用途が異なるため、両方を混ぜないでください

## 構成

- `config/`: 実行時設定と Windows 向け補助ファイル
- `templates/`: `pdx new` で使うテンプレート
- `preamble/`: LaTeX の前処理
- `csl/`: 引用スタイル
- `tools/`: Windows 向け Rust バイナリ
- `legacy/`: 旧スクリプトの保管場所
- `projects/<名前>/src/`: 本文
- `projects/<名前>/output/`: 生成物

## 補足

- `defaults-paper.yml` は `pdx new -Paper` でコピーされる論文向け初期設定です
- `projects/sample-paper/` は挙動確認用のサンプルです
- ビルド時間や PDF サイズの記録は [docs/build-metrics.md](docs/build-metrics.md) に追記できます
- Windows release の zip 作成スクリプトは [release/package-windows-release.ps1](/C:/Users/miyut/Desktop/pandocker-dev/release/package-windows-release.ps1) です
