---
allowed-tools: Bash(git push:*)
description: gitプッシュを実行する
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- リモートブランチとの差分: !`git status -sb`
- プッシュ対象のコミット: !`git log origin/HEAD..HEAD --oneline`

## タスク

現在のブランチの変更をリモートリポジトリにプッシュしてください。
