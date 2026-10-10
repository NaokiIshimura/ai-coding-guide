---
description: gitコミットを作成する
argument-hint: "[コミットメッセージの補足]"
allowed-tools: Skill, Bash(git *)
disable-model-invocation: true
---

## コンテキスト

- 現在のgitステータス: !`git status`
- 現在のgit差分（ステージング済み・未ステージングの変更）: !`git diff HEAD --stat`
- 現在のブランチ: !`git branch --show-current`
- 最近のコミット: !`git log --oneline -10`

## タスク

Skillツールで共通skill `git` を呼び出し、その手順の「2. コミット操作（commit）」に従って、上記の変更に基づく単一のgitコミットを作成してください。

- 引数: $ARGUMENTS
- 引数がある場合は、コミットメッセージを作成する際の補足として扱ってください
