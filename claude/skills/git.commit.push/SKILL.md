---
description: gitコミットとプッシュを実行する
argument-hint: "[コミットメッセージの補足]"
allowed-tools: Skill, Bash(git *)
disable-model-invocation: true
---

## コンテキスト

- 現在のgitステータス: !`git status`
- 現在のブランチ: !`git branch --show-current`
- 最近のコミット: !`git log --oneline -10`

## タスク

Skillツールで共通skill `git` を呼び出し、その手順に従って以下を順に実行してください。

1. 「2. コミット操作（commit）」に従ってコミットを作成
2. 「3. プッシュ操作（push）」に従ってプッシュ

- 引数: $ARGUMENTS
- 引数がある場合は、コミットメッセージを作成する際の補足として扱ってください
- コミットに失敗した場合は、プッシュを行わずに状況を報告してください
