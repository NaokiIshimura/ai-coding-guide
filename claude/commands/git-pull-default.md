---
allowed-tools: Bash(git checkout:*), Bash(git pull:*), Bash(git merge:*), Bash(git status:*), Bash(git branch:*)
description: デフォルトブランチから最新の変更を取得してマージする
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- デフォルトブランチ: !`git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`
- リモートとの差分: !`git status -sb`

## タスク

デフォルトブランチ（master/main）から最新の変更を取得して、現在のブランチにマージしてください。

1. 現在の作業状態を確認
2. デフォルトブランチに切り替えて最新を取得
3. 元のブランチに戻ってマージ
4. コンフリクトが発生した場合は適切に解決

注意: 作業中の変更がある場合は、コミットまたはstashで保存してから実行してください。