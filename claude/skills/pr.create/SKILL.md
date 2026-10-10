---
description: プルリクエストを作成する
argument-hint: "[PRの補足（チケット番号・タグなど）]"
allowed-tools: Skill, Bash(git *), Bash(gh pr *), Bash(gh repo view *), mcp__github
disable-model-invocation: true
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在のステータス: !`git status -sb`

## タスク

Skillツールで共通skill `pull-request` を呼び出し、その手順の「1. PR作成（create）」に従って、現在のブランチからプルリクエストを作成してください。

- 引数: $ARGUMENTS
- 引数がある場合は、title・descriptionを作成する際の補足として扱ってください
- 既にプルリクエストが存在する場合は、同じskillの「2. PR更新（update）」に従ってtitle・descriptionを更新してください
