# Pandoc + LuaLaTeX + Pandoc-crossref PDF生成環境

## 概要
このプロジェクトは、Pandocを利用してMarkdownファイルから高品質な日本語PDFを生成するためのDocker環境です。PowerShellスクリプトを実行するだけで、レポートの雛形作成からPDFのビルドまでを簡単に行うことができます。

## 主な特徴

- 簡単な実行環境: Dockerを利用するため、ローカル環境にLaTeXなどをインストールする必要がありません。
- 効率的なプロジェクト管理: レポートごとにフォルダが分離され、ファイルが整理されます。
- 雛形の自動生成: new.ps1スクリプトで、必要なディレクトリ構造と設定ファイルを一瞬で作成できます。
- 高品質な日本語組版: PDF生成エンジンにLuaLaTeXを採用し、美しい日本語文書を作成します。
- 図表・数式の相互参照: pandoc-crossrefにより、図や表、数式に自動で番号を振り、本文中から参照できます。

## ファイル構成
プロジェクトのルートディレクトリにスクリプトを配置し、各レポートは専用のサブディレクトリで管理します。

~~~bash
.
│  Dockerfile               # Pandoc環境を定義するファイル
│  docker-compose.yml       # Dockerイメージのビルドを簡単にするファイル
│  ieee-with-url.csl        # 引用スタイルファイル
│  new.ps1                  # 新規レポートファイル作成スクリプト
│  pandocker.ps1            # PDF変換用スクリプト
│  README.md                # このファイル
│
└─ report1/                 # 生成された"report1"という名前のレポートファイル
    │  defaults.yml          # レポート固有のPandoc設定
    │
    ├─ bib/
    │    └─ references.bib   # 参考文献ファイル
    ├─ images/              # 画像ファイル
    ├─ output/              # 生成されたPDFが保存される場所
    └─ src/
         └─ report.md        # 執筆用Markdownファイル
~~~

## 使い方

### 必要なもの

- [Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/)
- PowerShell

### ステップ1: Dockerイメージのビルド (初回のみ)
この環境を初めて使うとき、またはDockerfileを更新したときに一度だけ実行します。PowerShellでこのフォルダに移動し、以下のコマンドを実行してください。

~~~bash
docker build -t pandoc-ja . 
~~~

### ステップ2: 新しいレポート環境の作成
新しいレポートを書き始めるときに実行します。

```bash
# ./new.ps1 "作成したいレポート名"
./new.ps1 "report-weekly-progress"
```

これを実行すると、report-weekly-progressという名前のフォルダと、その中に執筆に必要なファイル一式が自動で作成されます。

### ステップ3: 執筆
自動生成されたreport-weekly-progress/src/report.mdを開き、内容を編集します。

- 画像: imagesフォルダに入れます。
- 参考文献: bib/references.bibに記述します。

### ステップ4: PDFを生成する
執筆が完了したら、pandocker.ps1スクリプトでPDFをビルドします。引数にはレポート名を指定するだけです。

~~~bash
# ./pandocker.ps1 "レポート名"
./pandocker.ps1 "report-weekly-progress"
~~~

コマンドが正常に完了すると、outputフォルダ内にPDFファイルが生成されます。

## カスタマイズ
### レポートごとの共通設定
フォントや用紙の余白などを変更したい場合は、各レポートフォルダ内のdefaults.ymlを編集します。

### 引用スタイル (CSL) の変更
使いたい.cslファイルをプロジェクトのルートディレクトリ（new.ps1などがある場所）に置きます。src/report.mdのヘッダー部分を、使いたいファイル名に書き換えます。

~~~yaml
---
title: "Title"
author: "name"
date: "2025-10-12"
bibliography: ../bib/references.bib
csl: ../../new-style.csl  # ← ここを書き換える
---
~~~