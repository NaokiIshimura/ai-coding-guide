---
allowed-tools: Bash(git switch:*), Bash(git checkout:*), Bash(git pull:*), Bash(git status:*), Bash(git branch:*), Bash(git symbolic-ref:*)
description: デフォルトブランチに切り替えて最新を取得する
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- デフォルトブランチ: !`git symbolic-ref --short refs/remotes/origin/HEAD`
- 現在のステータス: !`git status -sb`

## タスク

デフォルトブランチ（master/main）に切り替えて、リモートから最新の変更を取得してください。

1. 未コミットの変更がある場合は警告して確認
2. デフォルトブランチに切り替え
3. リモートから最新をpull

### 注意事項

- 作業中の変更がある場合は、コミットまたはstashで保存してから実行してください
