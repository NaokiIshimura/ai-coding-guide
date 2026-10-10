---
description: プルリクエストのtitle・descriptionを現在のブランチの変更内容に合わせて更新する
argument-hint: "[PR番号 or URL]"
allowed-tools: Skill, Bash(git *), Bash(gh pr *), Bash(gh repo view *), mcp__github
disable-model-invocation: true
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`

## タスク

Skillツールで共通skill `pull-request` を呼び出し、その手順の「2. PR更新（update）」に従って、プルリクエストのtitle・descriptionを更新してください。

- 引数: $ARGUMENTS
- 引数でPR番号またはURLが指定されている場合はそのPRを、指定がない場合は現在のブランチのPRを対象としてください
