# Pandocker: Markdown → PDF 自動ビルド環境

## 概要

Pandocker は **Docker + Ubuntu(WSL2)** 上で動作する、Pandoc + LuaLaTeX + pandoc-crossref 環境です。Markdown から高品質な日本語 PDF を自動生成できます。

PowerShell スクリプトを実行するだけで、レポートの雛形作成から PDF のビルドまでをワンコマンドで完結させます。

---

## 主な特徴

- **完全自動化:** Docker 環境内で Markdown → PDF 変換が完結。
- **依存関係不要:** Windows 側に LaTeX や Pandoc をインストールする必要なし。
- **WSL2 統合:** Ubuntu(WSL2) と Docker Desktop の組み合わせで動作。
- **雛形生成:** `new.ps1` でレポートプロジェクトを自動作成。
- **高品質な組版:** LuaLaTeX による美しい日本語文書出力。
- **図表・数式の相互参照:** `pandoc-crossref` によって自動で番号・参照付け。

---

## 必要環境

- **Windows 10/11**
- [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/)
- **Ubuntu :** ディストリビューション用、Microsoft Storeからインストール
- **PowerShell 7 以降 :** Microsoft Storeからインストール

---

## ディレクトリ構成

~~~bash
.
│  Dockerfile              # PandocとTeX環境を構築するためのDocker設定ファイル  
│  docker-compose.yml      # コンテナ実行を自動化するCompose定義ファイル  
│  config.ps1              # 環境設定用:WSLディストリ名やパスを共通管理  
│  setup.ps1               # 初回セットアップスクリプト:WSL側のディレクトリ生成・権限設定などを実施  
│  new.ps1                 # 新しいレポートプロジェクトを自動生成（テンプレートから複製）  
│  pandocker.ps1           # メインのビルドスクリプト:Markdown → PDFをDocker経由で変換  
│  wsl-helpers.ps1         # WSL関連の補助関数（パス変換やWSL上でのコマンド実行など）  
│  README.md               # このドキュメント  
│  default.yml             # 各プロジェクトのdefaults.ymlのコピー元
│
├─csl/
│    ieee-with-url.csl     # IEEE形式（URL付き）の引用スタイル設定ファイル（CSL形式）  
│
├─log/
│    pandoc.log            # Pandocビルドのログ出力先。`-Log` オプション指定時に生成される  
│
├─preamble/
│    preamble-main.tex     # LaTeXのプリアンブル設定（パッケージやカスタム定義を含む）  
│    preamble-*.tex        # 分割管理用のサブプリアンブル（例: 図表・コード用など）  
│
├─projects/
│   └─ report-name/
│        │  defaults.yml         # Pandoc設定
│        ├─ src/report.md        # メインのMarkdownソースファイル（レポート本文） 
│        ├─ bib/references.bib   # BibTeX形式の参考文献データベース  
│        ├─ images/              # 図表や写真などの画像ファイル置き場  
│        └─ output/sample-report.pdf # ビルド済みPDFの出力先  
│
└─templates/
     pandoc.latex          # PandocのLaTeXテンプレート

~~~

---

## 使い方

### 0. Docker と WSL の統合設定
まずはDocker DesktopとUbuntu、Power Shellをインストールしてください。
Docker Desktop で PDF ビルド環境を正しく動作させるには、WSL 統合を有効にする必要があります。

1. Docker Desktop を開く

2. Settings → Resources → WSL Integration に移動

3. 以下を有効化

     - Enable integration with my default WSL distro
     - Enable integration with additional distros: で使用する Ubuntu のトグルをオン

これにより、Docker コンテナが WSL2 上の Ubuntu と連携して動作可能になります。

### 1. 初回セットアップ

初めて利用する場合、Docker イメージと WSL 作業環境を構築します。

~~~bash
./setup.ps1
~~~

> ※ WSL のディストリビューション設定は `config.ps1` 内で行います。

---

### 2. 新しいレポート環境を作成

~~~bash
./new.ps1 "report-name"
~~~

- 引数1:作成するフォルダ名を指定

実行すると、`projects/report-name/` に Markdown や bib ファイルなどが自動生成されます。

---

### 3. 執筆

- 本文: `projects/report-name/src/report.md`
- 画像: `projects/report-name/images/`
- 参考文献: `projects/report-name/bib/references.bib`

---

### 4. PDF 生成

~~~bash
./pandocker.ps1 "report-name"
~~~

- 引数1:作成したフォルダ名を指定
- 引数2:PDFにビルドするファイル名を指定  
     - 無指定ならreport.mdをビルド
     - 1つ指定すればそのmarkdownをビルド
     - 複数指定で指定したmarkdownを順番にビルド
     - -Allスイッチでsrc/内のすべてのmarkdownをビルド
     - -Logスイッチでログ出力

#### 引数指定の挙動

| 種類 | 例 | 動作 |
|------|----|------|
| **無指定** | `./pandocker.ps1 "report-name"` | `projects/report-name/src` 内の`report.md`についてビルドを実行します。 |
| **単数指定** | `./pandocker.ps1 "report-name" "report1"` | 指定したMarkdownのみをビルドします。 |
| **複数指定** | `./pandocker.ps1 "report-name" "report1","report2"` | 指定した複数のMarkdownを順にビルドします。 |
| **全指定（-All）** | `./pandocker.ps1 "report-name" -All` | `projects/report-name/src` 以下すべてのMarkdownを自動的にビルドします。 |

生成結果は `projects/report-name/output/` に保存されます。

ログ出力付きビルドも可能です。

~~~bash
./pandocker.ps1 report-name -All -Log
~~~
#### ファイル上書き防止

PDF 出力時は、入力ファイル名をもとにしたファイル名で保存されるため、同一ディレクトリで複数ビルドしても上書きされません。

---

## カスタマイズ
### defaults.yml の編集

- フォント・余白・文書クラスなどの基本設定を変更できます。

>基本的には作成したフォルダ内にあるdefaults.ymlを編集すること。

- パッケージの設定  
パッケージは分野別にpreambleにして設定されています。必要に応じて削除・コメントアウトしてください。

~~~yaml
include-in-header:
  - "../../../preamble/preamble-main.tex" #基本パッケージ
  - "../../../preamble/preamble-chem.tex"  #化学パッケージ
  - "../../../preamble/preamble-mathphys.tex"  #数学物理パッケージ
  - "../../../preamble/preamble-tikz.tex"  #tikzパッケージ
  - "../../../preamble/preamble-table.tex"  #テーブルパッケージ
  - "../../../preamble/preamble-code.tex"  #コードパッケージ
  - "../../../preamble/preamble-links.tex"  #リンクパッケージ
~~~

例:TikZや化学式を使わない場合

~~~yaml
# - "../../../preamble/preamble-chem.tex"
# - "../../../preamble/preamble-tikz.tex"
~~~

これによりビルド時の読み込み時間を短縮できます。

### report.md のyamlヘッダー編集

- 引用スタイルを変更

例:

~~~yaml
---
title: "Title"
author: "Your Name"
date: "2025-10-22"
bibliography: ../bib/references.bib
csl: ../../../csl/ieee-with-url.csl #ここを変更して引用スタイルを変更
---
~~~

---

## ログとキャッシュ

- ビルドログ: `log/pandoc.log`
- Docker キャッシュ: LaTeX フォントやパッケージを保持し、ビルドを高速化。

---

## トラブルシューティング

- **WSL 未検出:** `wsl --install -d Ubuntu` を実行。
- **Docker が起動していない:** Docker Desktop を起動して再試行。
- **フォントエラー:** `./setup.ps1` を再実行して TeX Live を再構築。

---

## ライセンス

- MIT License

## 作成者

**Xpotato1024** ([321miyuto@xpotato.net](mailto:321miyuto@xpotato.net))

