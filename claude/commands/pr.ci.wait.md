---
allowed-tools: Bash(gh pr:*), Bash(gh run:*), Bash(osascript:*)
description: PRのCIが完了するまで待機して通知する
---

## タスク

### PRのCI完了を待機して通知する

以下の手順で、現在のブランチのPRに関連するCIの完了を待機し、結果を通知してください。

#### 1. 現在のブランチのPRを特定

- 現在のブランチに関連するPRを検索
  ```bash
  gh pr view --json number,title,url,headRefName
  ```
- PRが見つからない場合はその旨を通知して終了

#### 2. CI状態の確認

- 現在のchecks状態を確認
  ```bash
  gh pr checks
  ```
- 全てのchecksが既に完了している場合は、結果を報告して手順4へ進む

#### 3. CI完了まで待機

- `--watch` オプションでchecksの完了を待機
  ```bash
  gh pr checks --watch --fail-fast
  ```
- 待機中はユーザーに「CI完了を待機中...」と伝える

#### 4. 結果の通知

CI完了後、以下の方法で結果を通知する。

**成功時:**
```bash
osascript -e 'display notification "全てのCIチェックが成功しました" with title "CI完了 ✅" sound name "Glass"'
```

**失敗時:**
```bash
osascript -e 'display notification "CIチェックが失敗しました" with title "CI失敗 ❌" sound name "Basso"'
```

- ターミナルにもchecksの結果一覧を表示する
- 失敗したchecksがある場合は、失敗したcheck名とURLを表示する
