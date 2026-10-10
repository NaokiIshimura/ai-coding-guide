---
description: PRのCIが完了するまで待機して通知する
argument-hint: "[PR番号 or URL]"
allowed-tools: Skill, Bash(gh pr *), Bash(gh run *), Bash(osascript *)
disable-model-invocation: true
---

## タスク

Skillツールで共通skill `pull-request` を呼び出し、その手順の「6. CI待機（ci wait）」に従って、PRのCIの完了を待機し、結果を通知してください。

- 引数: $ARGUMENTS
- 引数でPR番号またはURLが指定されている場合はそのPRを、指定がない場合は現在のブランチのPRを対象としてください
