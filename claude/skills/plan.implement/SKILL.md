---
description: 実装計画に基づいて実装を開始する
allowed-tools: Skill
argument-hint: "<計画ディレクトリのパス> [開始タスクID]"
disable-model-invocation: true
---

## タスク

既に作成済みの実装計画（plan.md、requirements.md、design.md、tasks.md）に基づいて実装を開始してください。

Skill ツールで共通 skill `tasks-execute` を呼び出し、その手順に従って実装します。

- 引数: $ARGUMENTS
  - 1つ目: 計画ディレクトリのパス（必須。例: `.claude/plans/ABC-123/`。未指定の場合はユーザーに入力を求める）
  - 2つ目: 開始タスクID（任意。例: `TASK-003`）
- ディレクトリ内の最新の plan / requirements / design / tasks.md を読み込み、概要（計画・要件・設計のサマリー、タスク一覧と進捗状態）をユーザーに提示する
- ユーザーの確認を得てから実装を開始する

### 想定するワークフロー

```bash
# 1. 実装計画を作成
/plan.create     # または /spec.create

# 2. 作成された実装計画を確認・編集
# （ユーザーが手動で plan/requirements/design/tasks.md を確認・修正）

# 3. 実装計画に基づいて実装を開始
/plan.implement .claude/plans/ABC-123/

# 4. 実装完了後、コミット・プッシュ・PR作成
/git.commit.push.pr
```
