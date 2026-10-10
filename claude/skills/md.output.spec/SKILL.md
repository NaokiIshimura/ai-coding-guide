---
description: 実装計画作成（requirements/design/tasks.md）を出力する
argument-hint: "[チケット番号]"
disable-model-invocation: true
allowed-tools: Skill, Bash(git *), Bash(TZ=Asia/Tokyo date *)
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在の日時（日本時間）: !`TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S'`
- 引数: $ARGUMENTS

## タスク

現在までの作業状況や調査結果を整理して、実装計画（requirements/design/tasks.md）として出力してください。

Skill ツールで共通 skill `spec-writer` を呼び出し、その手順に従って3つのドキュメントを作成します。

- **情報源**: 現在の会話の内容（作業状況・調査結果）と git 差分
- **識別子**: 引数にチケット番号があればそれを使用し、なければ `spec-writer` の手順（ブランチ名から推測 → `tmp`）に従う
- 出力完了の報告では、各ファイルのパス・主要なセクション・内容の要約を示す

軽量な実行計画（plan.md のみ）で十分な場合は `/md.output.plan` を使ってください。
