---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: gitコミットを作成する
---

## コンテキスト

- 現在のgitステータス: !`git status`
- 現在のgit差分（ステージング済み・未ステージングの変更）: !`git diff HEAD`
- 現在のブランチ: !`git branch --show-current`
- 最近のコミット: !`git log --oneline -10`

## タスク

上記の変更に基づいて、単一のgitコミットを作成してください。

コミット作成時は、@~/ai-coding-guide/guides/git.md の「commit」セクションの内容に従ってください。
