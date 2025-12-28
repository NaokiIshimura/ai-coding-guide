---
name: plan-create
description: |
  実装計画（plan）を作成する。requirements.md、design.md、tasks.md の
  3つのドキュメントを順番に作成して実装計画を完成させる。Use when:
  - 「実装計画作成」「plan作成」が必要な時
  - JIRAチケットやissueから実装計画を立てる時
  - 新機能の実装前にドキュメントを揃える時
  - 「planを作って」「計画を立てて」と言われた時
  - 開発を始める前の準備が必要な時
allowed-tools: Read, Write, Glob, Grep, Bash
---

# 実装計画作成スキル

あなたは実装計画の作成を統合的に行うスキルです。
requirements-writer、design-writer、tasks-writerの3つのスキルを順番に活用して、
包括的な実装計画を作成します。

## 概要

収集した情報を基に、3つの実装計画ドキュメントを順番に作成します：
1. requirements.md（仕様書）
2. design.md（設計書）
3. tasks.md（タスクリスト）

## 入力情報

- チケット番号またはタスク識別子
- 情報源（JIRAチケット / markdownファイル / 会話履歴）

## 出力先

- チケット番号がある場合: `.claude/tasks/<チケット番号>/`
- チケット番号がない場合: `.claude/tasks/tmp/`

## 実行手順

### Step 1: 準備

1. **出力先ディレクトリを確認・作成**
   ```bash
   mkdir -p .claude/tasks/<識別子>/
   ```

2. **タイムスタンプを生成（日本時間）**
   ```bash
   TZ='Asia/Tokyo' date '+%Y_%m%d_%H%M_%S'
   ```
   - フォーマット: `YYYY_MMDD_HHMM_SS`
   - 例: 2025年01月02日03時04分05秒の場合 → `2025_0102_0304_05`

### Step 2: 仕様書作成

- `requirements-writer` スキルの機能を使用
- 収集した情報を基に仕様書を作成
- 出力: `<タイムスタンプ>_requirements.md`

**仕様書の主要セクション**:
- プロジェクト概要
- 機能要件
- 非機能要件
- ユースケース
- データ要件

### Step 3: 設計書作成

- `design-writer` スキルの機能を使用
- Step 2で作成したrequirements.mdを参照
- 出力: `<タイムスタンプ>_design.md`

**設計書の主要セクション**:
- システム概要
- アーキテクチャ設計
- 詳細設計（データ設計、API設計、クラス設計）
- セキュリティ設計
- テスト設計

### Step 4: タスクリスト作成

- `tasks-writer` スキルの機能を使用
- Step 2のrequirements.md、Step 3のdesign.mdを参照
- 出力: `<タイムスタンプ>_tasks.md`

**タスクリストの主要セクション**:
- プロジェクト情報
- タスク分類（環境構築、設計、実装、テスト、リリース）
- 各タスクの詳細（優先度、見積もり、依存関係、完了条件）
- 進捗管理

### Step 5: 完了報告

作成したファイルの情報を報告：
- 各ファイルのパス
- 各ドキュメントの概要
- 次のステップの提案

## 出力ファイル

```
.claude/tasks/<識別子>/
├── YYYY_MMDD_HHMM_SS_requirements.md  # 仕様書
├── YYYY_MMDD_HHMM_SS_design.md        # 設計書
└── YYYY_MMDD_HHMM_SS_tasks.md         # タスクリスト
```

## 注意事項

- **タイムスタンプ**: 日本時間を使用
- **既存ファイル**: 上書きせず、新しいタイムスタンプで作成
- **ファイル末尾**: 空行を追加
- **言語**: 日本語で記述
- **整合性**: 3つのドキュメント間で整合性を保つ
- **順序**: requirements → design → tasks の順で作成（依存関係のため）

## ドキュメント間の参照関係

```
requirements.md
    ↓ 参照
design.md
    ↓ 参照
tasks.md
```

- design.md は requirements.md の機能要件を参照して設計
- tasks.md は requirements.md と design.md の両方を参照してタスク分解

## 品質基準

- **仕様書**: 曖昧さのない要件定義、テスト可能な受入基準
- **設計書**: 実装に十分な詳細度、拡張性を考慮
- **タスクリスト**: 1-3日で完了可能な粒度、明確な完了条件

## 使用例

### JIRAチケットからの実装計画作成

```
入力: チケット番号 ABC-123、JIRAから取得した情報
出力:
  .claude/tasks/ABC-123/2025_0102_0304_requirements.md
  .claude/tasks/ABC-123/2025_0102_0304_design.md
  .claude/tasks/ABC-123/2025_0102_0304_tasks.md
```

### 会話履歴からの実装計画作成

```
入力: 会話で収集した要件情報
出力:
  .claude/tasks/tmp/2025_0102_0304_requirements.md
  .claude/tasks/tmp/2025_0102_0304_design.md
  .claude/tasks/tmp/2025_0102_0304_tasks.md
```
