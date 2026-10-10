---
description: 最新の変更を取得する
allowed-tools: Skill, Bash(git *)
disable-model-invocation: true
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- リモートとの差分: !`git status -sb`
- リモートブランチ: !`git branch -r`

## タスク

Skillツールで共通skill `git` を呼び出し、その手順の「4. プル操作（pull）」に従って、リモートリポジトリから最新の変更を取得してください。

- 引数: $ARGUMENTS
- 引数でブランチが指定されている場合は、そのブランチを取得してください
