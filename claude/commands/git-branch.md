---
allowed-tools: Bash(git branch:*), Bash(git checkout:*), Bash(git status:*)
description: gitブランチを作成・切り替える
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- ローカルブランチ一覧: !`git branch`
- リモートブランチ一覧: !`git branch -r`
- 現在のステータス: !`git status -sb`

## タスク

以下のいずれかのタスクを実行してください：

1. 新しいブランチを作成して切り替える
2. 既存のブランチに切り替える
3. ブランチの一覧を確認する

### 注意事項

- ブランチ切り替え前に、未コミットの変更がある場合は確認してください
- ブランチ名は明確で分かりやすい名前を使用してください
