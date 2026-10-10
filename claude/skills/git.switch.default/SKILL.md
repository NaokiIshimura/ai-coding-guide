---
description: デフォルトブランチに切り替えて最新を取得する
allowed-tools: Skill, Bash(git *), Bash(gh repo view *)
disable-model-invocation: true
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在のステータス: !`git status -sb`

## タスク

Skillツールで共通skill `git` を呼び出し、その手順の「5. デフォルトブランチへの切り替え（switch default）」に従って、デフォルトブランチ（master / main など）に切り替えて最新の変更を取得してください。
