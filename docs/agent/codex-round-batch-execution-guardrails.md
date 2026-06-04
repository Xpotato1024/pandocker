# Codex Round Batch Execution Guardrails

## 目的

この文書は、Pandocker-X で Codex に 1 round を実行させるときの正式な運用ガードレールです。
repository guard を最優先にし、Round 単位で安全に進め、Phase 丸ごとを Codex に任せないための基準を定義します。

## 基本原則

- Repository guard を最優先にします。
- Codex に任せるのは Round までです。Phase 丸ごとは任せません。
- 通常運用では Codex は merge しません。
- 1 issue = 1 PR を守ります。
- 変更は issue scope に閉じます。
- 実装、validation、PR 本文、レビュー判断は同じ事実に基づいて整合させます。

## Repository guard

- Project: `Pandocker-X`
- Repository: `Xpotato1024/Pandocker-X`
- default branch の source of truth: `gh repo view --json nameWithOwner,defaultBranchRef`
- 現時点の `defaultBranchRef.name`: `master`
- PR base: `master`
- `Xpotato1024/Pandocker-X` 以外では作業しません。
- `Xpotato1024/Selfrionette` では絶対に作業しません。

作業前には次を必ず確認します。

```powershell
git remote -v
git branch --show-current
git status --short --branch
gh repo view --json nameWithOwner,defaultBranchRef
```

次があれば作業を止めます。

- repository mismatch
- wrong base branch
- unrelated working tree changes
- validation failure
- Docker / TeX runtime gap

## Output formatting guard

- prompt や PR 本文で nested triple-backtick code fence を作りません。
- 複数の prompt を出すときは、独立した code block に分けます。
- command example は prompt block 内では plain text として書きます。
- 文書は GitHub でそのまま読める日本語にします。

## 一括実行してよい条件

- repository guard が一致している。
- 対象 issue が 1 つに定まっている。
- issue scope が小さく、Round で完了可能である。
- 変更対象が docs-only か、あるいは既知の build / validation 範囲に収まる。
- 使う validation が事前に特定できる。
- PR 本文に必要事項を書き切れる。

## 一括実行してはいけない条件

- repository mismatch がある。
- wrong base branch である。
- unrelated working tree changes がある。
- issue scope が広すぎる。
- Phase 丸ごとを 1 round に押し込もうとしている。
- release publishing が暗黙に必要だが許可されていない。
- Docker / TeX runtime が足りない。
- gpt-5.5 review が必要なのに回避しようとしている。

## goal usage

- 1 round ごとに 1 goal を使います。
- goal は 1 issue の完了判定を追跡するために使います。
- goal complete は、必須 validation が終わり、差分が scope 内で、PR 本文も整っているときだけ使います。
- goal blocked は、同じ阻害要因が繰り返し出て、これ以上意味のある進展がないときだけ使います。
- 途中で別 issue に広げません。

## goal complete の定義

次をすべて満たしたときにのみ goal complete とします。

- diff が issue scope に収まっている
- forbidden files が入っていない
- validation が通っている
- PR 本文が実差分と一致している
- 必須の review 前提を満たしている

## goal blocked の定義

次の条件が同じ形で繰り返され、前に進めない場合のみ goal blocked とします。

- repository guard の不一致
- base branch の不一致
- 必要な validation の未達
- 必須レビューが取得不能
- runtime / environment の欠落

単に難しい、遅い、まだ終わっていない、では blocked にしません。

## モデル分割ルール

- Phase は人間側の管理単位です。
- Round は Codex に分ける実行単位です。
- Issue は 1 PR に収める変更単位です。
- Codex に Phase 全体を投げないでください。
- Round が終わらないなら、Phase を分割してください。

## gpt-5.5 review 必須タイミング

次のいずれかに当てはまるときは、gpt-5.5 review を前提にします。

- behavior を変える
- review なしで safe for merge を言いたくなる
- Round complete / goal complete の最終判断が曖昧
- stacked PR で相互依存がある
- release や runtime に影響する

## review 観点

- scope が issue に収まっているか
- forbidden files が含まれていないか
- validation が十分か
- PR 本文が実差分と一致しているか
- release / secrets / runtime の禁止境界を破っていないか
- replace すべき PR を stale のまま放置していないか

## 実行単位

- 1 round は 1 issue を対象にします。
- 1 round は 1 PR に対応させます。
- 1 round の中で別 issue を混ぜません。

## Issue 選定ルール

- 現行の推奨順を優先します。
- 依存関係のある issue は順番を守ります。
- docs-only、validation-only、behavior change を同じ PR に混ぜません。
- issue が大きすぎる場合は round を分割します。

## PR / commit title ルール

- branch 名は `codex/<issue-number>-<short-description>` にします。
- commit title は簡潔な命名にします。
- PR title は `[docs] ...` のように、変更の性質が分かるものにします。
- `Closes #<issue-number>` のような自動クローズ keyword は、意図した issue 以外には使いません。

## PR 本文の必須項目

PR 本文には少なくとも次を含めます。

- Summary
- Changed Files
- What Changed
- Validation Run
- Scope Check
- Scope Exclusions
- Runtime / Docker / TeX Status
- Release Impact
- Branch / Diff Gate
- Remaining Risks
- Handoff
- Related issue

## validation ルール

docs-only 変更では最低限次を確認します。

```bash
git diff --check
git status --short --branch
git diff --name-only origin/master...HEAD
```

behavior 変更では、変更内容に応じて次を追加します。

- `bash -n pdx`
- `cargo check --locked --manifest-path tools/pdx-win/Cargo.toml`
- `cargo check --locked --manifest-path tools/pdx-installer/Cargo.toml`
- `./pdx setup`
- `./pdx new smoke-report`
- `./pdx build smoke-report -Log`
- `test -f projects/smoke-report/output/report.pdf`

必要に応じて、PowerShell / Bash の実行互換性も確認します。

## Pandocker-X 固有の禁止境界

次は明示的な許可がない限り禁止です。

- release publishing
- release asset upload
- Docker image publish
- secrets 編集
- deployment keys の変更
- destructive Docker cleanup
- host TeX Live を source of truth とみなすこと

## Docker / TeX runtime 原則

- Pandocker-X の標準 runtime は Docker です。
- host TeX Live は通常依存ではありません。
- target descriptor の要求と Docker image の実体を混同しません。
- `lualatex`, `platex`, `uplatex`, `pbibtex`, `dvipdfmx`, `latexmk` は、target が必要とするなら container 内に必要です。

## stacked PR ルール

- stacked PR が必要なら、親子関係を明示します。
- 子 PR は親 PR に依存することを本文で説明します。
- 依存が解けるまで stale 化を放置しません。

## replacement PR ルール

- 既存 PR を置き換える場合は replacement であることを明示します。
- 置き換え前の PR は stale になったことを明確にします。
- 同じ issue の並走 PR を増やしません。

## Round completion 判定

Round complete にする前に次を確認します。

- diff が issue scope に収まっている
- forbidden files が含まれていない
- validation が通っている
- PR 本文が実差分と一致している
- 必須 review 条件を満たしている
- 手戻りが発生しそうな残存リスクを本文に書けている

## final report フォーマット

最終報告は次の順番で書きます。

1. 変更の要点
2. validation 結果
3. changed files
4. forbidden files が含まれていない確認
5. 必要なら次の手順

## 人間 merge 運用

- 通常運用では Codex は merge しません。
- merge は人間の責務です。
- review 後に safe for merge を言う場合でも、最終的な merge は人間側で行います。

## 最終方針

- repository guard を最優先にします。
- 迷ったら Round を止めます。
- PR 本文と実差分を一致させます。
- 文字化けや表示崩れを残しません。
- Xpotato1024/Pandocker-X 以外では作業しません。
