---
description: PRのコメントを確認して修正を実施する
argument-hint: "[PR番号 or URL]"
allowed-tools: Skill, Bash(git *), Bash(gh pr *), Bash(gh api *), mcp__github, Edit, Read
disable-model-invocation: true
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`

## タスク

Skillツールで共通skill `pull-request` を呼び出し、その手順の「3. コメント対応（comment resolve）」に従って、プルリクエストのコメントを確認し、指摘された内容に基づいて修正・コミット・返信を実施してください。

- 引数: $ARGUMENTS
- 引数でPR番号またはURLが指定されている場合はそのPRを、指定がない場合は現在のブランチのPRを対象としてください
- 全てのコメントに対応（または対応しない理由を返信）してください
