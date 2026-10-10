---
description: gitコミット、プッシュ、プルリクエスト作成を実行する
argument-hint: "[コミットメッセージ・PRの補足]"
allowed-tools: Skill, Bash(git *), Bash(gh pr *), Bash(gh api *), Bash(gh repo view *), mcp__github
disable-model-invocation: true
---

## コンテキスト

- 現在のgitステータス: !`git status`
- 現在のブランチ: !`git branch --show-current`
- 最近のコミット: !`git log --oneline -10`

## タスク

以下を順に実行してください。

1. Skillツールで共通skill `git` を呼び出し、「2. コミット操作（commit）」に従ってコミットを作成
2. 共通skill `git` の「3. プッシュ操作（push）」に従ってプッシュ
3. Skillツールで共通skill `pull-request` を呼び出し、「1. PR作成（create）」に従ってプルリクエストを作成（既にPRがある場合は「2. PR更新（update）」）

- 引数: $ARGUMENTS
- 引数がある場合は、コミットメッセージ・PRのdescriptionを作成する際の補足として扱ってください
- いずれかの手順に失敗した場合は、後続の手順を行わずに状況を報告してください
