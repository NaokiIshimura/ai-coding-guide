---
allowed-tools: Bash(git:*), Bash(gh pr:*), mcp_github
description: プルリクエストを作成する
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- デフォルトブランチ: !`git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
- ベースブランチとの差分: !`git diff origin/$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')...HEAD --stat`
- 変更されたファイル: !`git diff origin/$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')...HEAD --name-only`
- コミット履歴: !`git log origin/$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')..HEAD --oneline`

## タスク

現在のブランチからプルリクエストを作成してください。

プルリクエストの作成にはGitHub MCPを利用してください。

既にプルリクエストが存在する場合は、descriptionを更新してください（`gh pr edit`を使用）。

プルリクエスト作成時は、@~/ai-coding-guide/guides/git.md の「pull request」セクションの内容に従ってください。

### 注意事項

- masterブランチが存在しない場合は、デフォルトブランチを自動的に参照します
