# Claude Code Skills

このディレクトリには、Claude Codeで自動的に使用されるスキルが含まれています。

## スキル一覧

| スキル名 | 説明 | 出力ファイル |
|----------|------|-------------|
| `plan-create` | 実装計画を作成（3つのドキュメントを統合作成） | requirements.md, design.md, tasks.md |
| `requirements-writer` | 仕様書を作成 | requirements.md |
| `design-writer` | 設計書を作成 | design.md |
| `tasks-writer` | タスクリストを作成 | tasks.md |
| `tasks-execute` | tasks.mdに基づいてタスクを実行 | 更新されたtasks.md, 実装コード |

## ディレクトリ構成

```
.claude/skills/
├── README.md                      # このファイル
├── plan-create/
│   └── SKILL.md                   # 実装計画作成スキル（統合）
├── requirements-writer/
│   └── SKILL.md                   # 仕様書作成スキル
├── design-writer/
│   └── SKILL.md                   # 設計書作成スキル
├── tasks-writer/
│   └── SKILL.md                   # タスクリスト作成スキル
└── tasks-execute/
    └── SKILL.md                   # タスク実行スキル
```

## スキルの呼び出し関係

```
plan-create
    ├─ requirements-writer → requirements.md
    ├─ design-writer → design.md（requirements参照）
    └─ tasks-writer → tasks.md（requirements/design参照）
```

## 各スキルの詳細

### plan-create

実装計画を統合的に作成するスキル。以下のトリガーで自動的に呼び出されます：

- 「実装計画作成」「plan作成」が必要な時
- JIRAチケットやissueから実装計画を立てる時
- 「planを作って」「計画を立てて」と言われた時

### requirements-writer

仕様書（requirements.md）を作成するスキル。以下のトリガーで自動的に呼び出されます：

- 「仕様書作成」「requirements作成」が必要な時
- 新機能の要件定義を行う時
- 「仕様をまとめて」「要件を整理して」と言われた時

### design-writer

設計書（design.md）を作成するスキル。以下のトリガーで自動的に呼び出されます：

- 「設計書作成」「design作成」が必要な時
- 技術設計をドキュメント化する時
- 「設計をまとめて」「アーキテクチャを整理して」と言われた時

### tasks-writer

タスクリスト（tasks.md）を作成するスキル。以下のトリガーで自動的に呼び出されます：

- 「タスクリスト作成」「tasks作成」が必要な時
- 実装計画を立てる時
- 「タスクを分解して」「作業を洗い出して」と言われた時

### tasks-execute

tasks.mdに基づいてタスクを実行するスキル。以下のトリガーで自動的に呼び出されます：

- tasks.mdに基づいて実装を進める時
- 計画されたタスクを順番に実装する時
- 「タスクを実行して」「実装を進めて」と言われた時
- 「次のタスクをやって」と言われた時

## 出力先

- チケット番号がある場合: `.claude/tasks/<チケット番号>/`
- チケット番号がない場合: `.claude/tasks/tmp/`

## ファイル名フォーマット

タイムスタンプ付きファイル名（日本時間）:

```
YYYY_MMDD_HHMM_<ドキュメント種別>.md
```

例: `2025_0102_0304_requirements.md`

## 関連ファイル

### Agent（Taskツール経由での呼び出し用）

- `claude/agents/plan-create.md`
- `claude/agents/requirements-writer.md`
- `claude/agents/design-writer.md`
- `claude/agents/tasks-writer.md`

### Command（コマンドでの呼び出し用）

- `claude/commands/plan.create.md` - `/plan.create`
- `claude/commands/tasks.execute.md` - `/tasks.execute`

## 参考

- [Claude Code Skills ドキュメント](https://code.claude.com/docs/ja/skills)
