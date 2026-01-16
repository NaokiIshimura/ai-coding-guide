# Claude Commands

このディレクトリには、よく使用するワークフローを簡素化するためのカスタムスラッシュコマンドが格納されています。

## コマンド一覧

### Git操作

| コマンド | 説明 | 主な機能 |
|---------|------|----------|
| `/git.branch` | gitブランチを作成・切り替える | ブランチ作成・切り替え |
| `/git.commit` | gitコミットを作成 | 変更のステージング、コミットメッセージ作成、gitガイドライン準拠 |
| `/git.push` | gitプッシュを実行 | リモートへのプッシュ、アップストリームブランチ設定 |
| `/git.pull` | 最新の変更を取得 | リモートからの変更取得、マージ/リベース |
| `/git.pull.default` | デフォルトブランチから最新を取得 | main/masterブランチからのpull、自動マージ |
| `/git.commit.push` | コミット&プッシュを実行 | git.commit → git.push の連続実行 |
| `/git.commit.push.pr` | コミット&プッシュ&PR作成を実行 | git.commit → git.push → pr.create の連続実行 |

### Pull Request操作

| コマンド | 説明 | 主な機能 |
|---------|------|----------|
| `/pr.create` | プルリクエストを作成 | GitHub MCP使用、PRテンプレート適用、Assignee設定 |
| `/pr.comment.resolve` | PRコメントを確認して修正実施 | コメント取得、指摘分析、修正実施、コミット作成 |
| `/pr.update` | PRのdescriptionを更新 | 既存PR更新、テンプレート適用 |
| `/pr.comment.check` | PRコメント確認（非推奨） | 旧バージョン - 使用非推奨 |

### JIRA連携

| コマンド | 説明 | 主な機能 |
|---------|------|----------|
| `/jira.issue.develop` | JIRAチケット情報を取得・操作 | チケット情報取得、実装計画作成（requirements/design/tasks.md）、実装実行 |
| `/jira.issue.feedback` | JIRAチケットへフィードバック投稿 | コメント投稿、進捗更新、課題報告 |
| `/jira.issue.develop.old` | 旧バージョン（非推奨） | アーカイブ済み |
| `/jira.issue.develop.old2` | 旧バージョン（非推奨） | アーカイブ済み |

### Claude Comment管理

| コマンド | 説明 | 主な機能 |
|---------|------|----------|
| `/claude.comment` | @claudeコメントの検索・実行・削除 | 検索（finder）→ 実装（executor）→ クリーンアップ（cleaner） |

### Markdown入出力

| コマンド | 説明 | 主な機能 |
|---------|------|----------|
| `/md.output` | 作業状況・調査結果をmdファイル出力 | 構造化ドキュメント生成、タイムスタンプ付きファイル名、複数形式対応 |
| `/md.output.spec` | 実装計画作成（requirements/design/tasks.md）を出力 | 仕様書・設計書・タスクリスト生成、日本時間タイムスタンプ、バージョン管理対応 |
| `/md.output.plan` | 実行計画（plan.md）を出力 | 単一ファイル生成、日本時間タイムスタンプ、標準構造、バージョン管理対応 |
| `/md.input` | mdファイルから作業状況を把握 | ファイル検索・分析、時系列整理、未解決課題抽出、作業再開支援 |
| `/md.develop` | markdownファイルの情報を元に開発を実施 | mdファイル読み込み、実装計画作成（requirements/design/tasks.md）、実装実行 |

### 実装計画・タスク実行

| コマンド | 説明 | 主な機能 |
|---------|------|----------|
| `/plan.create` | 実装計画（requirements/design/tasks.md）を作成 | 仕様書・設計書・タスクリスト生成、日本時間タイムスタンプ、バージョン管理対応 |
| `/plan.implement` | 実装計画に基づいて実装を開始 | 実装計画読み込み、tasks-executorエージェント呼び出し、進捗管理 |
| `/tasks.execute` | tasks.mdに基づいてタスクを実行 | タスク読み込み、依存関係確認、順次実装、進捗更新 |

### ユーティリティ

| コマンド | 説明 | 主な機能 |
|---------|------|----------|
| `/task.init` | タスク準備を実行 | .claude/tasks配下にディレクトリ作成、マークダウンファイル確認・作成 |

## コマンドの使用方法

スラッシュコマンドは、以下のように実行します：

```bash
/<コマンド名> [引数]
```

例：
```bash
/git.commit
/pr.create
/jira.issue.develop
```

## ワークフロー例

### 新機能開発の基本フロー

```bash
# 1. JIRAチケットから実装計画を作成
/jira.issue.develop

# 2. 実装完了後、コミット・プッシュ・PR作成
/git.commit.push.pr

# 3. レビューコメントへの対応
/pr.comment.resolve

# 4. 作業状況を記録
/md.output
```

### 実装計画の作成・更新フロー

```bash
# 1. 現在の作業状況から実装計画を作成
/md.output.spec

# 2. 作成された requirements/design/tasks.md を確認
# 3. 必要に応じて実装計画を更新（新しいタイムスタンプで作成される）
/md.output.spec
```

### 軽量な実行計画の作成フロー

```bash
# 1. 現在の作業状況から実行計画を作成
/md.output.plan

# 2. 作成された plan.md を確認・編集
# （ユーザーが手動で確認・修正）

# 3. 計画に基づいて実装を実行
# （必要に応じて /plan.implement や /tasks.execute を使用）

# 4. 実装完了後、コミット・プッシュ・PR作成
/git.commit.push.pr
```

### /md.output.spec と /md.output.plan の使い分け

**`/md.output.spec` を使う場合**:
- 正式な実装計画が必要（3つのドキュメント: requirements/design/tasks.md）
- チーム共有用の詳細な仕様書・設計書が必要
- 複雑な機能の実装で、要件・設計・タスクを分離したい

**`/md.output.plan` を使う場合**:
- 軽量な実行計画で十分（単一ファイル: plan.md）
- 個人作業やプロトタイピング
- 短期タスクやシンプルな実装
- 既にrequirements/design.mdがあり、実行計画のみ欲しい

### 実装計画ベースの開発フロー

```bash
# 1. 実装計画を作成
/plan.create

# 2. 作成された requirements/design/tasks.md を確認・編集
# （ユーザーが手動で実装計画を確認・修正）

# 3. 実装計画に基づいて実装を開始
/plan.implement

# 4. 実装完了後、コミット・プッシュ・PR作成
/git.commit.push.pr
```

### 作業再開時のフロー

```bash
# 1. 過去の作業状況を確認
/md.input

# 2. デフォルトブランチの最新を取得
/git.pull.default

# 3. 作業継続...
```

## 注意事項

- コマンドは `.claude/commands/` ディレクトリ内のmarkdownファイルとして定義されています
- 各コマンドには `allowed-tools` が設定されており、使用できるツールが制限されています
- MCPツールを使用するコマンドは、適切なMCPサーバーが設定されている必要があります

## カスタムコマンドの追加

新しいコマンドを追加する場合は、以下の形式でmarkdownファイルを作成してください：

```markdown
---
allowed-tools: <使用するツールのリスト>
description: <コマンドの説明>
---

## コンテキスト
<コマンド実行時のコンテキスト情報>

## タスク
<実行するタスクの詳細>
```
