---
description: 現在までの作業状況・調査結果をmarkdownファイルに出力する
argument-hint: "[トピック名] [出力形式: standard|investigation|plan|summary]"
disable-model-invocation: true
allowed-tools: Skill
---

## タスク

Skill ツールで共通 skill `markdown` を呼び出し、その「1. 出力（output）」の手順に従って、現在までの作業状況や調査結果をmarkdownファイルに出力してください。

## 引数

- 引数: $ARGUMENTS
- トピック名・出力形式・詳細度・出力先が指定されていれば、それに従う
- 引数がない場合は、会話の内容からトピック名を決め、出力形式は `standard` とする
