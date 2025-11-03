---
allowed-tools: Bash(git pull:*), Bash(git fetch:*), Bash(git status:*)
description: 最新の変更を取得する
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- リモートとの差分: !`git status -sb`
- リモートブランチ: !`git branch -r`

## タスク

リモートリポジトリから最新の変更を取得してください。

コンフリクトが発生した場合は、適切に解決してください。
