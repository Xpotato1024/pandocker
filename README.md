# Pandocker-X: Markdown → PDF 日本語自動ビルド環境

[![GitHub release](https://img.shields.io/badge/release-v2.1.0--alpha-blue)](https://github.com/Xpotato1024/Pandocker-X/releases/tag/v2.1.0-alpha)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 概要

Pandocker-X は **Docker (Windows/Linux/Mac)** 上で動作する、Pandoc + LuaLaTeX + pandoc-crossref 環境です。Markdown から高品質な日本語 PDF を自動生成できます。

`install.ps1` (Windows) または `install.sh` (Linux/Mac) による初回セットアップ後は、`pdx` コマンドを実行するだけで、レポートの雛形作成から PDF のビルドまでをワンコマンドで完結させます。

## 主な特徴

* **クロスプラットフォーム対応:** Windows (WSL2)、Linux、macOS のすべてで `pdx` コマンドが動作。

* **ワンコマンド実行:** `pdx build "project"` だけで Docker 環境内で Markdown → PDF 変換が完結。

* **依存関係不要:** ホストOS側に LaTeX や Pandoc をインストールする必要なし。(※Linux/Macでは `jq` が必要)

* **雛形生成:** `pdx new "project"` でレポートプロジェクトを自動作成。

* **ビルド設定の外部化:** `config/pandoc-args.json` でPandocの共通引数を管理。

* **引用スタイル (CSL) の柔軟性:**
    * デフォルトのIEEEスタイルに加え、一般的なスタイル (APA, MLA, Chicagoなど) を同梱予定。
    * `report.md` のYAMLヘッダーを編集するだけでスタイルを切り替え可能。
    * プロジェクト内に独自のCSLファイルを追加して使用することも可能。

* **高品質な組版:** LuaLaTeX による美しい日本語文書出力。

* **図表・数式の相互参照:** `pandoc-crossref` によって自動で番号・参照付け。

## 必要環境

### 必要環境 (Windows)

* **Windows 10/11**
* [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/) (WSL2 Backend)
* **Ubuntu (または他ディストリビューション) :** Microsoft Storeからインストール
* **PowerShell 7 以降 :** Microsoft Storeからインストール (推奨)
    * ※ Windows標準のPowerShell 5.1でも動作しますが、`install.ps1` の文字コード互換性のためPS 7を推奨します。

### 必要環境 (Linux / macOS)

* **Linux または macOS**
* [Docker Desktop](https://docs.docker.com/desktop/setup/install/linux-install/) または Docker Engine
* **Bash** または **Zsh**
* **jq** (コマンドラインJSONパーサー)
    * `sudo apt install jq` (Debian/Ubuntu) や `brew install jq` (macOS) でインストールしてください。

## ディレクトリ構成

~~~
.
│  Dockerfile              # PandocとTeX環境を構築するDocker設定
│  docker-compose.yml      # コンテナ実行を自動化するCompose定義
│  install.ps1             # [Windows用] pdx関数をPowerShellに登録するインストーラ
│  install.sh              # [Linux/Mac用] pdx関数をBash/Zshに登録するインストーラ
│  README.md               # このドキュメント
│  default.yml             # 各プロジェクトのdefaults.ymlのコピー元
│
├─config/
│    config.ps1            # [Windows用] 環境設定 (WSLディストリ名など)
│    wsl-helpers.ps1        # [Windows用] WSL関連の補助関数
│    pandoc-args.json       # [共通] Pandocビルド引数の設定ファイル
│
├─scripts/
│    build.ps1              # [Windows用] pdx build の本体
│    new.ps1                # [Windows用] pdx new の本体
│    setup.ps1              # [Windows用] pdx setup の本体
│    wsl-init.ps1           # [Windows用] WSL初期化の共通ロジック
│    uninstall.ps1          # [Windows用] アンインストーラ
│
│    build.sh               # [Linux/Mac用] pdx build の本体
│    new.sh                 # [Linux/Mac用] pdx new の本体
│    setup.sh               # [Linux/Mac用] pdx setup の本体
│    uninstall.sh          # [Linux/Mac用] アンインストーラ
│
├─csl/
│    ieee-with-url.csl     # デフォルトの引用スタイル
│    apa.csl                # (例) 追加する一般的なCSLファイル
│    mla.csl                # (例)
│    ...
│
├─log/
│    (pandoc_*.log)        # -Log オプション指定時に生成
│
├─preamble/
│    preamble-main.tex     # LaTeXのプリアンブル設定
│    ...
│
├─projects/
│   └─ report-name/
│        (省略)
│
└─templates/
     pandoc.latex          # PandocのLaTeXテンプレート
~~~

## 使い方

### 0. Windows ユーザー向け: Docker と WSL の統合設定

(Linux/macOS ユーザーはこのステップをスキップしてください)

Docker Desktop で PDF ビルド環境を正しく動作させるには、WSL 統合を有効にする必要があります。

1. Docker Desktop を開く
2. Settings → Resources → WSL Integration に移動
3. 以下を有効化
        - Enable integration with my default WSL distro
        - Enable integration with additional distros: で使用する Ubuntu のトグルをオン

### 1. 初回インストール (pdx コマンドの登録)

お使いのOSに合わせて、インストーラーを**一度だけ**実行します。

#### Windows (PowerShell) の場合

PowerShell を開き、プロジェクトのルートディレクトリで `install.ps1` を**ドットソース**で実行します。

~~~
# 実行ポリシーがRestrictedの場合は先に変更が必要です
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# install.ps1 を実行して pdx 関数を登録 (先頭のドット(.)が重要です)
. .\install.ps1
~~~

`install.ps1` は `pdx` 関数をPowerShellプロファイルに登録し、現在のセッションに自動読み込みします。`pdx` コマンドが**そのまま使用可能**になります。

#### Linux / macOS (Bash/Zsh) の場合

ターミナルを開き、プロジェクトのルートディレクトリで `install.sh` を **source** コマンドで実行します。

~~~bash
# 実行権限を付与
chmod +x install.sh
chmod +x scripts/*.sh

# install.sh を実行 (source または . が重要です)
source ./install.sh
~~~

`install.sh` は `pdx` 関数を `.bashrc` または `.zshrc` に登録し、現在のセッションに自動読み込みします。`pdx` コマンドが**そのまま使用可能**になります。

### 2. 環境セットアップ

`pdx` コマンドが使えるようになったら、Docker イメージと TeX Live 環境を構築します。

~~~
pdx setup
~~~

> ※ Windows ユーザーの場合: WSL のディストリビューション設定は `config/config.ps1` 内で行います。

### 3. 新しいレポート環境を作成

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
       - 1つ指定すればその Markdown をビルド
       - 複数指定で指定した Markdown を順番にビルド
   

* `-All` スイッチで `src/` 内のすべての `.md` ファイルをビルド

* `-Log` スイッチでログ出力

#### 引数指定の挙動

| 種類 | 例 | 動作 |
|------|----|------|
| **無指定** | `pdx build "report-name"` | `projects/report-name/src` 内の `report.md` についてビルドを実行します。 |
| **単数指定** | `pdx build "report-name" "report1.md"` | 指定した Markdown のみをビルドします。 |
| **複数指定** | `pdx build "report-name" "report1.md" "report2.md"` | 指定した複数の Markdown を順にビルドします。 |
| **全指定（-All）** | `pdx build "report-name" -All` | `projects/report-name/src` 以下すべての Markdown を自動的にビルドします。 |

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

* **LaTeXパッケージの設定:**  
  `include-in-header` で読み込む `/app/preamble/` 内の `.tex` ファイルを編集します。不要なパッケージをコメントアウトすることでビルド時間を短縮できます。

~~~yaml
include-in-header:
  - "/app/preamble/preamble-main.tex" #基本パッケージ
  - "/app/preamble/preamble-chem.tex"  #化学パッケージ
  - "/app/preamble/preamble-mathphys.tex"  #数学物理パッケージ
  - "/app/preamble/preamble-tikz.tex"  #tikzパッケージ
  - "/app/preamble/preamble-table.tex"  #テーブルパッケージ
  - "/app/preamble/preamble-code.tex"  #コードパッケージ
  - "/app/preamble/preamble-links.tex"  #リンクパッケージ
~~~

例:TikZや化学式を使わない場合

~~~yaml
include-in-header:
  - "/app/preamble/preamble-main.tex" #基本パッケージ
  #- "/app/preamble/preamble-chem.tex"  #化学パッケージ
  - "/app/preamble/preamble-mathphys.tex"  #数学物理パッケージ
  #- "/app/preamble/preamble-tikz.tex"  #tikzパッケージ
  - "/app/preamble/preamble-table.tex"  #テーブルパッケージ
  - "/app/preamble/preamble-code.tex"  #コードパッケージ
  - "/app/preamble/preamble-links.tex"  #リンクパッケージ
~~~

### 引用スタイル (CSL) の変更

* **同梱スタイルへの切り替え:**
    `report.md` のYAMLヘッダーにある `csl:` の値を、使用したいスタイルの **コンテナ内絶対パス** に変更します。同梱されているスタイルは `/app/csl/` ディレクトリ内にあります (ファイル名は異なる場合があります)。

    ~~~yaml
    ---
    title: "Title"
    author: "Your Name"
    date: "..."
    bibliography: ../bib/references.bib
    csl: /app/csl/apa.csl # ここを /app/csl/mla.csl などに変更
    ---
    ~~~

    **同梱される引用スタイル:**
    * IEEE (デフォルト): `ieee-with-url.csl`
    * APA: `apa.csl`
    * MLA: `mla.csl`
    * Chicago (Author-Date): `chicago-author-date.csl`
    * Vancouver: `vancouver.csl`
    * (他のスタイルも `pdx setup`実行前に`csl/` フォルダに追加してください)

* **カスタムCSLファイルの使用:**
    1.  使用したい `.csl` ファイルを、ご自身のプロジェクトフォルダ内の分かりやすい場所 (例: `projects/report-name/custom-csl/my-style.csl`) に置きます。
    2.  `report.md` のYAMLヘッダーの `csl:` の値を、**`src` ディレクトリから見た相対パス**に変更します。

    ~~~yaml
    ---
    csl: ../custom-csl/my-style.csl # プロジェクト内のファイルへの相対パス
    ---
    ~~~

## ログとキャッシュ

* ビルドログ: `log/pandoc_*.log` ( `-Log` 指定時に生成)

* Docker キャッシュ: LaTeX フォントやパッケージを保持し、ビルドを高速化。

## トラブルシューティング

* **`pdx` コマンド未検出:** インストーラ (`. .\install.ps1` または `source ./install.sh`) を実行しましたか？ ターミナルを再起動すると認識される場合もあります。
* **WSL 未検出 (Windows):** `wsl --install -d Ubuntu` を実行。
* **Docker が起動していない:** Docker Desktop を起動して再試行。
* **フォントエラー:** `pdx setup` を再実行して TeX Live を再構築。
* **`jq` が見つからない (Linux/Mac):** `sudo apt install jq` または `brew install jq` で `jq` をインストールしてください。

## 作成者

**Xpotato1024** ([321miyuto@xpotato.net](mailto:321miyuto@xpotato.net))
