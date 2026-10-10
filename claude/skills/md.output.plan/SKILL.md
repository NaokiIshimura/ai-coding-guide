---
description: 実行計画（plan.md）を出力する
argument-hint: "[チケット番号] [計画のタイトル]"
disable-model-invocation: true
allowed-tools: Skill, Bash(git *), Bash(TZ=Asia/Tokyo date *)
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在の日時（日本時間）: !`TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S'`
- 引数: $ARGUMENTS

## タスク

現在までの作業状況や調査結果を整理して、実行計画（plan.md）として出力してください。

Skill ツールで共通 skill `plan-writer` を呼び出し、その手順に従って plan.md を作成します。

- **情報源**: 現在の会話の内容（作業状況・調査結果）と git 差分
- **識別子**: 引数にチケット番号があればそれを使用し、なければ `plan-writer` の手順（ブランチ名から推測 → `tmp`）に従う
- **タイトル**: 引数で与えられていればそれを使用し、なければ会話の内容から決める

### 使い分け

**`/md.output.plan` を使う場合**:
- 軽量な実行計画で十分（単一ファイル: plan.md）
- 個人作業やプロトタイピング、短期タスクやシンプルな実装
- 既に requirements/design.md があり、実行計画のみ欲しい

**`/md.output.spec` を使う場合**:
- 正式な実装計画が必要（3ファイル: requirements/design/tasks.md）
- チーム共有用の詳細な仕様書・設計書が必要
- 複雑な機能の実装で、要件・設計・タスクを分離したい
