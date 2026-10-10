---
description: gitブランチを作成・切り替える
argument-hint: "[ブランチ名 or チケット番号]"
allowed-tools: Skill, Bash(git *)
disable-model-invocation: true
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- ローカルブランチ一覧: !`git branch`
- リモートブランチ一覧: !`git branch -r`
- 現在のステータス: !`git status -sb`

## タスク

Skillツールで共通skill `git` を呼び出し、その手順の「1. ブランチ操作（branch）」に従って、ブランチの作成・切り替え・一覧確認を行ってください。

- 引数: $ARGUMENTS
- 引数で指定されたブランチが存在する場合は切り替え、存在しない場合は作成して切り替えてください
- 引数がない場合は、ブランチ一覧を表示して、作成・切り替えるブランチをユーザーに確認してください
