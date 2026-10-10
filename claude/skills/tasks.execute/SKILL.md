---
description: tasks.mdに基づいてタスクを実行する
allowed-tools: Skill
argument-hint: "<tasks.mdのパス> [開始タスクID]"
disable-model-invocation: true
---

## タスク

Skill ツールで共通 skill `tasks-execute` を呼び出し、その手順に従って tasks.md に定義されたタスクを順番に実装してください。

- 引数: $ARGUMENTS
  - 1つ目: tasks.md のパス（必須。未指定の場合はユーザーに入力を求める）
  - 2つ目: 開始タスクID（任意。例: `TASK-003`）
- タスク識別子は tasks.md の親ディレクトリ名を使用する（例: `.claude/plans/ABC-123/xxx_tasks.md` → `ABC-123`）
- 実行するタスクをユーザーに提示し、確認を得てから実装を開始する
