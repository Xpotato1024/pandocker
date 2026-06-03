# Build Metrics

この文書は、Docker backend 切り替えやテンプレート変更の影響を確認するための記録用メモです。

## 記録項目

- 実行日時
- OS / backend
- WSL dockerd か Docker Desktop か
- `docker compose build --no-cache` の所要時間
- `pdx setup` の所要時間
- 1 回目の `pdx build` の所要時間
- 2 回目の `pdx build` の所要時間
- 生成 PDF のサイズ
- エラー有無

## 推奨コマンド

### Windows / PowerShell

```powershell
git status --short
docker version
docker compose version
pdx setup
pdx new "sample-check"
pdx build "sample-paper"
pdx build "sample-paper" -Log
```

### Linux / WSL

```bash
docker version
docker compose version
docker info
systemctl is-active docker || pgrep dockerd
time docker compose build --no-cache
```

## 記録例

| 日時 | OS | Backend | `pdx setup` | `pdx build` | PDF size | 備考 |
| --- | --- | --- | --- | --- | --- | --- |
| 2026-06-02 16:00 | Windows 11 | WSL dockerd | - | - | - | 例 |

## メモ

- まず `sample-paper` で確認する。
- 変更前後で同じ条件をできるだけ揃える。
- `-Log` を付けたビルドは、失敗時の差分確認に使う。
