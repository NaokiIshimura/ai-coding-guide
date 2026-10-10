---
description: 仕様書（requirements/design/tasks.md）を作成する
argument-hint: "[チケット番号] [機能概要・要件]"
disable-model-invocation: true
allowed-tools: Skill, Bash(git *), Bash(TZ=Asia/Tokyo date *)
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在の日時（日本時間）: !`TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S'`
- 引数: $ARGUMENTS

## タスク

Skill ツールで共通 skill `spec-writer` を呼び出し、その手順に従って仕様書（requirements.md → design.md → tasks.md）を作成してください。

- **情報源**: 引数とユーザーの要求内容。コードベースを調査して仕様をまとめる
- **識別子**: 引数にチケット番号があればそれを使用し、なければ `spec-writer` の手順（ブランチ名から推測 → `tmp`）に従う
- 仕様の対象が引数・会話から判断できない場合は、ユーザーに確認してから進める

会話の中で進めた作業状況・調査結果を仕様書にまとめたい場合は `/md.output.spec` を使ってください。
