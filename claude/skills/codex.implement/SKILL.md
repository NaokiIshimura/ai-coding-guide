---
description: Codexに実装を依頼する
argument-hint: "[実装内容 | tasks.mdのパス] [開始タスク（例: Task-3以降）]"
disable-model-invocation: true
allowed-tools: Skill, Bash(codex *), Bash(mkdir *), Bash(date *), Bash(TZ=Asia/Tokyo date *), Bash(git branch *), Bash(find *), Read, Write, Glob, Grep
---

## タスク

Skill ツールで共通 skill `codex` を呼び出し、その手順の「implement（実装）」に従って、Codexに実装を依頼してください。

## 引数

- 引数: $ARGUMENTS
- 引数が tasks.md のパス、またはそれを含むディレクトリの場合は、複数タスクモード（tasks.md の未完了タスクを順に依頼）で実行する
  - 「Task-3以降」のような開始位置の指定があれば、そのタスクから開始する
- それ以外の場合は、引数を実装内容（instruction）として単一実行する
- 引数がない場合は、実装内容をユーザーに確認する

**使用例**:
```bash
# 実装内容を指定
/codex.implement ユーザー認証機能を実装してください

# tasks.md のタスクを順に実装
/codex.implement .claude/plans/ABC-123/2026_0124_1730_45_tasks.md

# 特定のタスクから開始
/codex.implement .claude/plans/ABC-123/ Task-3以降
```
