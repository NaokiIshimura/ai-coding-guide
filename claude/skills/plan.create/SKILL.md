---
description: 実行計画（plan.md）を作成する
argument-hint: "[チケット番号] [計画の対象・要件]"
disable-model-invocation: true
allowed-tools: Skill, Bash(git *), Bash(TZ=Asia/Tokyo date *)
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在の日時（日本時間）: !`TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S'`
- 引数: $ARGUMENTS

## タスク

Skill ツールで共通 skill `plan-writer` を呼び出し、その手順に従って実行計画（plan.md）を作成してください。

- **情報源**: 引数とユーザーの要求内容。コードベースを調査して計画を立てる
- **識別子**: 引数にチケット番号があればそれを使用し、なければ `plan-writer` の手順（ブランチ名から推測 → `tmp`）に従う
- 計画の対象が引数・会話から判断できない場合は、ユーザーに確認してから進める

### 使い分け

- 会話の中で進めた作業状況・調査結果を計画にまとめたい場合は `/md.output.plan` を使う
- 要件・設計・タスクを分けた正式な仕様書が必要な場合は `/spec.create` を使う
