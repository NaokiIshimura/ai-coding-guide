---
allowed-tools: Bash(gh pr:*)
description: プルリクエストを作成する
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- ベースブランチとの差分: !`git diff origin/master...HEAD --stat`
- 変更されたファイル: !`git diff origin/master...HEAD --name-only`
- コミット履歴: !`git log origin/master..HEAD --oneline`

## タスク

現在のブランチからプルリクエストを作成してください。

プルリクエストの作成にはGitHub MCPを利用してください。

既にプルリクエストが存在する場合は、descriptionを更新してください（`gh pr edit`を使用）。

プルリクエスト作成時は、@~/ai-coding-guide/guides/git.md の「pull request」セクションの内容に従ってください。
