# Phase / Round / Issue Design Rules

## 目的

この文書は、Pandocker-X の Phase / Round / Issue の設計ルールを定義します。
build safety、runtime root 分離、unified template target architecture、LaTeX ownership cleanup を、どの順で、どの単位で進めるかを明確にします。

## 基本構造

- Phase: 大きな技術テーマです。
- Round: Codex に 1 回やらせる実行単位です。
- Issue: 1 PR に収める変更単位です。

Phase を複数の Round に分け、Round を 1 Issue に対応させます。
1 issue = 1 PR を維持します。

## Phase の定義

Phase は、複数 issue を横断する大きな整理単位です。
Phase の例は、build safety の整備、runtime root の分離、template target の統一、LaTeX ownership の整理です。

## Round の定義

Round は、Codex が 1 回で完了できる変更単位です。
Round は 1 issue に対応させ、1 PR に着地させます。

## Issue の定義

Issue は、レビュー可能で、validation 可能で、PR に収まる変更です。
Issue が大きすぎるなら、Round を分けます。

## Pandocker-X の現在の Phase / Round 推奨構造

現在の推奨構造は次の通りです。

### Phase A: Build safety and validation foundation

- 目的: build 失敗の意味付けと入力境界を整える。
- 対象: #10, #11, #12
- 方針: build safety を先に固め、後続の runtime / template 作業の土台にします。

### Round A1: #10, #11, #12

- #10 Align Unix and Windows build failure semantics
- #11 Validate project names and prevent path traversal
- #12 Add PDF smoke tests for CI and release artifacts

この round 群は、build / input boundary / CI validation を先に安定化させます。

### Phase B: Runtime root and workspace root separation

- 目的: installed Windows usage の runtime root と workspace root を分離する。
- 対象: #9
- 方針: インストール済み利用の path handling を整理します。

### Phase C: Unified template target architecture

- 目的: paper-build と template-build のような分岐を避け、統一された target architecture を作る。
- 対象: #14
- 方針: user-facing route を統一し、target descriptor だけを差し替え可能にします。

### Phase D: LaTeX ownership cleanup

- 目的: defaults / template / preamble の LaTeX 責務を整理する。
- 対象: #13
- 方針: LaTeX の責務を再配分し、template 全体の不用意な書き換えを避けます。

## Phase 設計ルール

- Phase は大きく、Round は小さくします。
- Phase を 1 Round に詰め込みません。
- Phase の途中で別 Phase の issue を混ぜません。
- build safety を先に固め、その後に runtime、template、LaTeX を進めます。
- 依存関係があるものは順番を守ります。

## Issue 作成テンプレート

Issue は次の要素を含めて設計します。

- issue title
- problem statement
- expected behavior
- scope
- out of scope
- validation plan
- PR completion condition
- related issue ordering

Issue は 1 PR に閉じる前提で書きます。

## Round 作成テンプレート

Round を始めるときは次を明確にします。

- current repository identity
- default branch
- issue number
- branch name
- expected changed files
- validation commands
- PR body sections

Round の開始条件が曖昧なら、始めずに止めます。

## Round 切り分けの判断基準

次の場合は Round を分けます。

- validation が別種類になる
- runtime / Docker / TeX の前提が変わる
- 変更ファイル群が別責務になる
- PR 本文が別の story を必要とする
- release 関連と docs 関連が混ざる
- build safety と template architecture が同じ PR に収まりきらない

## Pandocker-X の current issue ordering

現行の issue 順は次です。

1. `#10` Align Unix and Windows build failure semantics
2. `#11` Validate project names and prevent path traversal
3. `#12` Add PDF smoke tests for CI and release artifacts
4. `#9` Separate runtime root and workspace root for installed Windows usage
5. `#14` Introduce unified template target architecture
6. `#13` Consolidate LaTeX defaults/template/preamble ownership

この順は、build safety → runtime separation → template architecture → LaTeX ownership の流れを表します。

## Completion Audit ルール

Round を完了とみなす前に、次を確認します。

- diff が issue scope に収まっている
- expected files 以外が入っていない
- forbidden files が入っていない
- validation が通っている
- PR 本文が実差分と一致している
- 必須 review 条件を満たしている
- human merge に回せる状態になっている

## 最終方針

- 1 issue = 1 PR を守ります。
- Round は小さく、Phase は大きく扱います。
- まず build safety、次に runtime separation、その後に template architecture、最後に LaTeX ownership を扱います。
- current issue ordering は必ず尊重します。
- 不明点があれば Round を止めます。
