# Claude Agents

このディレクトリには、特定のタスクに特化したClaude Codeエージェント（sub-agent）の定義が格納されています。

## エージェント一覧

### 情報収集（Collector系）

| エージェント | 説明 | 主なツール |
|-------------|------|-----------|
| `confluence-collector` | Confluence情報収集スペシャリスト。スペース、ページ、ブログ、添付ファイルからの情報を収集・整理 | WebFetch, Bash, Read, Write, `mcp__atlassian-v2` |
| `jira-collector` | JIRA情報収集スペシャリスト。プロジェクト、課題、スプリント、エピックからの情報を収集・整理 | WebFetch, Bash, Read, Write, `mcp__atlassian-v2` |
| `pr-collector` | Pull Request情報収集スペシャリスト。PR、レビュー、コメント、変更内容からの情報を収集・整理 | WebFetch, Bash, Read, Write, `mcp__github`, Grep, Glob |
| `slack-collector` | Slack情報収集スペシャリスト。チャンネル、スレッド、メッセージからの情報を収集・整理 | WebFetch, Bash, Read, Write, `mcp__slack` |
| `web-collector` | Web情報収集スペシャリスト。外部Webサイト、API、オンラインドキュメントからの情報を収集・整理 | WebFetch, WebSearch, Write, Read |

### レビュー・分析（Analyzer系）

| エージェント | 説明 | 主なツール |
|-------------|------|-----------|
| `debugger` | エラー、テスト失敗、予期しない動作のデバッグスペシャリスト | Read, Edit, Bash, Grep, Glob |
| `data-scientist` | SQLクエリ、BigQuery操作、データインサイトのデータ分析専門家 | Bash, Read, Write |

### 実装（Implementer系）

| エージェント | 説明 | 主なツール |
|-------------|------|-----------|
| `code-implementer` | 新機能の実装、関数・コンポーネントの作成などのコーディング作業を担当（`tasks-execute` skill から委譲されることもある） | Read, Grep, Glob, Bash, Edit, Write, NotebookEdit |

### Claude Comment管理

`/claude.comment` skill から順番に呼び出されます。

| エージェント | 説明 | 主なツール |
|-------------|------|-----------|
| `claude-comment-finder` | コードベース内の@claudeコメントを検索し、要求内容を整理 | Glob, Grep, Read, WebFetch, WebSearch, ListMcpResourcesTool, ReadMcpResourceTool |
| `claude-comment-executor` | @claudeコメントの指示に従って実装・リファクタリングなどを実行 | 全ツール（`tools` 指定なし） |
| `claude-comment-cleaner` | @claudeコメントの対応が完了したことを確認し、解決済みコメントを削除 | Read, Grep, Glob, Edit, Write |

## エージェントの使用方法

エージェントは、メインセッションから Agent ツールで `subagent_type` を指定して呼び出します。

```
Agent ツールを使用して、適切な subagent_type（例: jira-collector）を指定
```

- エージェントは独立したコンテキストで動作し、完了後に結果を返します
- 大量のデータを扱う場合は、エージェントに任せてメインセッションのコンテキストを節約してください
- 広範囲のファイル探索・コード調査には、組み込みの `Explore` エージェントを利用してください

## 削除したエージェントと代替手段

| 削除したエージェント | 代替手段 |
|---------------------|---------|
| `code-collector`, `file-collector` | 組み込みの `Explore` エージェント |
| `code-reviewer` | 組み込みの `/code-review` |
| `git-operator` | `git` skill（`/git.commit` などから呼び出し） |
| `markdown-handler` | `markdown` skill（`/md.output`, `/md.input`） |
| `plan-writer`, `spec-writer` | 同名の skill（`/plan.create`, `/spec.create` などから呼び出し） |
| `tasks-executor` | `tasks-execute` skill（`/tasks.execute`, `/plan.implement`） |
| `codex-implementer`, `codex-reviewer` | `codex` skill（`/codex.implement`, `/codex.review`） |

既存環境に残っている削除済みエージェントは `make migrate` でバックアップ後に削除できます（詳細はルートの `README.md` を参照）。

## カラー設定

エージェントは役割に応じて色分けされています。新規エージェント作成時は、役割に適した色を設定してください。

| 役割 | 色 | 対象エージェント |
|------|-----|------------------|
| 情報収集（Collector系） | `blue` | confluence-collector, jira-collector, pr-collector, slack-collector, web-collector |
| レビュー・分析（Analyzer系） | `yellow` | debugger, data-scientist |
| 実装（Implementer系） | `red` | code-implementer |
| Claude Comment管理 | `cyan` | claude-comment-finder, claude-comment-executor, claude-comment-cleaner |

### 設定方法

エージェント定義ファイルのfrontmatterに`color`フィールドを追加します：

```yaml
---
name: example-agent
description: エージェントの説明
tools: Read, Write, Bash
color: blue
memory: user
---
```

`model` を指定すると、エージェントが利用するモデルを固定できます（例: `claude-comment-finder` / `claude-comment-cleaner` は `sonnet`、`code-implementer` / `claude-comment-executor` は `opus`）。

## メモリ設定

全エージェントに永続メモリ（`memory: user`）が設定されています。エージェントは会話を跨いでナレッジを蓄積・再利用できます。

### スコープ

| スコープ | 保存パス | 特徴 |
|---------|---------|------|
| `user` | `~/.claude/agent-memory/<agent-name>/` | 全プロジェクト共通（現在の設定） |
| `project` | `.claude/agent-memory/<agent-name>/` | プロジェクト固有、git管理可能 |
| `local` | `.claude/agent-memory-local/<agent-name>/` | プロジェクト固有、git管理外 |

### 挙動

- メモリディレクトリ内の `MEMORY.md` の先頭200行がシステムプロンプトに自動挿入される
- `Read`, `Write`, `Edit` ツールがメモリ操作用に自動有効化される
- エージェントは実行中に学んだパターン・知見・意思決定を記録し、次回以降の実行で活用する

## 注意事項

- エージェントは独立して動作し、完了後に結果を返します
- 複数のエージェントを並行実行することで効率を向上できます
- `claude/agents/` を更新した場合は、このファイル（`claude/AGENTS.md`）も更新してください
