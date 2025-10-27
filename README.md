# Pandocker: Markdown → PDF 自動ビルド環境

[![GitHub release](https://img.shields.io/badge/release-v1.0.0-blue)](https://github.com/Xpotato1024/pandocker/releases/tag/v1.0.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 概要

Pandocker は **Docker + Ubuntu(WSL2)** 上で動作する、Pandoc + LuaLaTeX + pandoc-crossref 環境です。Markdown から高品質な日本語 PDF を自動生成できます。

`install.ps1`による初回セットアップ後は、`pdx`コマンドを実行するだけで、レポートの雛形作成から PDF のビルドまでをワンコマンドで完結させます。

## 主な特徴

* **ワンコマンド実行:** `pdx build "project"` だけで Docker 環境内で Markdown → PDF 変換が完結。

* **依存関係不要:** Windows 側に LaTeX や Pandoc をインストールする必要なし。

* **WSL2 統合:** Ubuntu(WSL2) と Docker Desktop の組み合わせで動作。

* **雛形生成:** `pdx new "project"` でレポートプロジェクトを自動作成。

* **高品質な組版:** LuaLaTeX による美しい日本語文書出力。

* **図表・数式の相互参照:** `pandoc-crossref` によって自動で番号・参照付け。

## 必要環境

* **Windows 10/11**

* [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/)

* **Ubuntu :** ディストリビューション用、Microsoft Storeからインストール

* **PowerShell 7 以降 :** Microsoft Storeからインストール (推奨)

  * ※ Windows標準のPowerShell 5.1でも動作しますが、`install.ps1` の文字コード互換性のためPS 7を推奨します。

## ディレクトリ構成

~~~
.
│  Dockerfile              # PandocとTeX環境を構築するDocker設定
│  docker-compose.yml      # コンテナ実行を自動化するCompose定義
│  install.ps1             # [★変更] pdx関数をPowerShellに登録するインストーラ
│  README.md               # このドキュメント
│  default.yml             # 各プロジェクトのdefaults.ymlのコピー元
│
├─config/
│    config.ps1            # [★追加] 環境設定用:WSLディストリ名やパスを共通管理
│
├─scripts/
│    build.ps1              # [★追加] メインのビルドスクリプト (pdx build が実行)
│    new.ps1                # [★追加] 新規プロジェクト作成スクリプト (pdx new が実行)
│    setup.ps1              # [★追加] 初回セットアップスクリプト (pdx setup が実行)
│    wsl-helpers.ps1        # [★追加] WSL関連の補助関数
│    wsl-init.ps1           # [★追加] WSL初期化の共通ロジック
|    uninstall.ps1          # [★追加] install.ps1の影響をクリーンアップするアンインストーラ
│
├─csl/
│    ieee-with-url.csl     # IEEE形式（URL付き）の引用スタイル設定ファイル
│
├─log/
│    (pandoc.log)          # Pandocビルドのログ出力先。-Log オプション指定時に生成
│
├─preamble/
│    preamble-main.tex     # LaTeXのプリアンブル設定（パッケージやカスタム定義）
│    ...
│
├─projects/
│   └─ report-name/
│        │  defaults.yml         # Pandoc設定
│        ├─ src/report.md        # メインのMarkdownソースファイル
│ _      ├─ bib/references.bib   # BibTeX形式の参考文献データベース
│        ├─ images/              # 画像ファイル置き場
│        └─ output/sample-report.pdf # ビルド済みPDFの出力先
│
└─templates/
     pandoc.latex          # PandocのLaTeXテンプレート

~~~

## 使い方

### 0. Docker と WSL の統合設定

まずはDocker DesktopとUbuntu、Power Shellをインストールしてください。
Docker Desktop で PDF ビルド環境を正しく動作させるには、WSL 統合を有効にする必要があります。

1. Docker Desktop を開く

2. Settings → Resources → WSL Integration に移動

3. 以下を有効化
        - Enable integration with my default WSL distro
        - Enable integration with additional distros: で使用する Ubuntu のトグルをオン

### 1. 初回インストール (pdx コマンドの登録)

\[★変更]

PowerShell を開き、プロジェクトのルートディレクトリで `install.ps1` を実行します。

~~~
# 実行ポリシーがRestrictedの場合は先に変更が必要です
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# install.ps1 を実行して pdx 関数を登録
. .\install.ps1

~~~

`install.ps1` は `pdx` 関数をPowerShellのプロファイルに登録します。
PowerShellを**再起動**（または `. $PROFILE` を実行）すると、`pdx` コマンドが使えるようになります。

### 2. 環境セットアップ

\[★変更]

`pdx` コマンドが使えるようになったら、Docker イメージと WSL 作業環境を構築します。

~~~
pdx setup

~~~

> ※ WSL のディストリビューション設定は `config/config.ps1` 内で行います。

### 3. 新しいレポート環境を作成

\[★変更]

`pdx new` コマンドで `projects/` 配下に雛形を作成します。

~~~
pdx new "report-name"

~~~

* 引数1:作成するフォルダ名を指定

実行すると、`projects/report-name/` に Markdown や bib ファイルなどが自動生成されます。

### 4. 執筆

* 本文: `projects/report-name/src/report.md`

* 画像: `projects/report-name/images/`

* 参考文献: `projects/report-name/bib/references.bib`

### 5. PDF 生成

`pdx build` コマンドで PDF を生成します。

~~~
pdx build "report-name"

~~~

* 引数1:作成したフォルダ名を指定

* 引数2 (任意): PDFにビルドするファイル名を指定
       - 無指定なら `report.md` をビルド
       - 1つ指定すればその Markdown (`.md` 必須) をビルド
       - 複数指定で指定した Markdown を順番にビルド
   

* `-All` スイッチで `src/` 内のすべての `.md` ファイルをビルド

* `-Log` スイッチでログ出力

#### 引数指定の挙動

| **種類** | **例** | **動作** |
| **無指定** | `pdx build "report-name"` | `projects/report-name/src` 内の`report.md`についてビルドを実行します。 |
| **単数指定** | `pdx build "report-name" "report1.md"` | 指定したMarkdownのみをビルドします。 |
| **複数指定** | `pdx build "report-name" "report1.md" "report2.md"` | 指定した複数のMarkdownを順にビルドします。 |
| **全指定（-All）** | `pdx build "report-name" -All` | `projects/report-name/src` 以下すべてのMarkdownを自動的にビルドします。 |

生成結果は `projects/report-name/output/` に保存されます。

ログ出力付きビルドも可能です。

~~~
pdx build "report-name" -All -Log

~~~

#### ファイル上書き防止

PDF 出力時は、入力ファイル名をもとにしたファイル名で保存されるため、同一ディレクトリで複数ビルドしても上書きされません。

## カスタマイズ

### defaults.yml の編集

* フォント・余白・文書クラスなどの基本設定を変更できます。

> 基本的には作成したフォルダ内にあるdefaults.ymlを編集すること。

* パッケージの設定  
  パッケージは分野別にpreambleにして設定されています。必要に応じて削除・コメントアウトしてください。

~~~
include-in-header:
  - "../../../preamble/preamble-main.tex" #基本パッケージ
  - "../../../preamble/preamble-chem.tex"  #化学パッケージ
  - "../../../preamble/preamble-mathphys.tex"  #数学物理パッケージ
  - "../../../preamble/preamble-tikz.tex"  #tikzパッケージ
  - "../../../preamble/preamble-table.tex"  #テーブルパッケージ
  - "../../../preamble/preamble-code.tex"  #コードパッケージ
  - "../../../preamble/preamble-links.tex"  #リンクパッケージ

~~~

例:TikZや化学式を使わない場合

~~~
# - "../../../preamble/preamble-chem.tex"
# - "../../../preamble/preamble-tikz.tex"

~~~

これによりビルド時の読み込み時間を短縮できます。

### report.md のyamlヘッダー編集

* 引用スタイルを変更

例:

~~~
---
title: "Title"
author: "Your Name"
date: "2025-10-22"
bibliography: ../bib/references.bib
csl: ../../../csl/ieee-with-url.csl #ここを変更して引用スタイルを変更
---

~~~

## ログとキャッシュ

* ビルドログ: `log/pandoc_*.log` ( `-Log` 指定時に生成)

* Docker キャッシュ: LaTeX フォントやパッケージを保持し、ビルドを高速化。

## トラブルシューティング

* **`pdx` コマンド未検出:** `install.ps1` を実行後、PowerShellを再起動しましたか？

* **WSL 未検出:** `wsl --install -d Ubuntu` を実行。

* **Docker が起動していない:** Docker Desktop を起動して再試行。

* **フォントエラー:** `pdx setup` を再実行して TeX Live を再構築。

## 作成者

**Xpotato1024** ([321miyuto@xpotato.net](mailto:321miyuto@xpotato.net))
