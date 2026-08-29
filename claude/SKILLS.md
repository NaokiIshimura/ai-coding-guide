# Claude Code Skills

このディレクトリには、Skill tool で呼び出し可能なスキル定義が格納されています。

## Skills、Commands、Agents の違い

| 項目 | Skills | Commands | Agents |
|------|--------|----------|--------|
| 呼び出し方 | Skill tool | `/xxx` | Task tool (subagent_type) |
| 実行主体 | メインプロセス | メインプロセス | サブプロセス |
| コンテキスト | 共有 | 共有 | 独立 |
| 用途 | 汎用的なスキル | プロジェクト固有のワークフロー | 専門的タスクの自律実行 |

## スキル一覧

| スキル名 | 説明 | 出力ファイル |
|----------|------|-------------|
| `plan-writer` | 実行計画を作成 | plan.md |
| `spec-writer` | 仕様書を統合的に作成 | requirements.md, design.md, tasks.md |
| `tasks-execute` | tasks.mdに基づいてタスクを実行 | 更新されたtasks.md, 実装コード |
| `git` | gitを操作する（branch, commit, push, pull） | - |
| `markdown` | markdownファイルを操作する（output, input） | markdownファイル |
| `pull-request` | プルリクエストを操作する（create, update, comment resolve） | - |
| `codex` | Codex CLIを実行し、結果をマークダウンファイルに記録 | YYYY_MMDD_HHMM_SS_<operation>_result.md |
| `tmux-pane-info` | 現在のtmuxセッション・ウィンドウ・ペイン、および同一ウィンドウ内の別ペインの情報を取得 | - |

## ディレクトリ構成

```
claude/skills/
├── codex/
│   └── SKILL.md                   # Codex実行スキル
├── git/
│   └── SKILL.md                   # git操作スキル
├── markdown/
│   └── SKILL.md                   # markdown入出力スキル
├── plan-writer/
│   └── SKILL.md                   # 実行計画作成スキル
├── pull-request/
│   └── SKILL.md                   # プルリクエスト操作スキル
├── spec-writer/
│   └── SKILL.md                   # 仕様書統合作成スキル
├── tasks-execute/
│   └── SKILL.md                   # タスク実行スキル
└── tmux-pane-info/
    └── SKILL.md                   # tmuxペイン情報取得スキル
```

## スキルの使用方法

スキルは以下のように呼び出します：

```
/スキル名 [引数]
```

例：
```
/spec-writer
/plan-writer
/tasks-execute
```

## スキルの呼び出し関係

```
spec-writer
    ├─ requirements作成 → requirements.md
    ├─ design作成 → design.md（requirements参照）
    └─ tasks作成 → tasks.md（requirements/design参照）
```

## 各スキルの詳細

### plan-writer

実行計画（plan.md）を作成するスキル。以下のトリガーで自動的に呼び出されます：

- 「実行計画作成」「plan作成」が必要な時
- 複数ステップの実装タスクを開始する前
- 要件分析が完了し、実装方針を決定した時
- 「planを作って」「計画を立てて」と言われた時

### spec-writer

仕様書（requirements/design/tasks.md）を統合的に作成するスキル。以下のトリガーで自動的に呼び出されます：

- 「仕様書作成」「spec作成」が必要な時
- 実装前にドキュメントを揃える時
- JIRAチケットやissueから仕様書を作成する時
- 「specを作って」「仕様をまとめて」と言われた時

### tasks-execute

tasks.mdに基づいてタスクを実行するスキル。以下のトリガーで自動的に呼び出されます：

- tasks.mdに基づいて実装を進める時
- 計画されたタスクを順番に実装する時
- 「タスクを実行して」「実装を進めて」と言われた時
- 「次のタスクをやって」と言われた時

### git

gitリポジトリの操作を行うスキル。以下のトリガーで自動的に呼び出されます：

- ブランチの作成・切り替えが必要な時
- コミットを作成する時
- プッシュ・プルを行う時
- 「ブランチを作って」「コミットして」「プッシュして」と言われた時

**対応操作:** branch, commit, push, pull

### markdown

markdownファイルの入出力を行うスキル。以下のトリガーで自動的に呼び出されます：

- 作業状況をファイルに出力する時
- 過去の作業履歴を読み込む時
- 「作業状況を出力して」「履歴を読み込んで」と言われた時

**対応操作:** output, input

### pull-request

GitHubプルリクエストの操作を行うスキル。以下のトリガーで自動的に呼び出されます：

- PRを作成する時
- PRのdescriptionを更新する時
- レビューコメントに対応する時
- 「PRを作って」「PRを更新して」「コメントに対応して」と言われた時

**対応操作:** create, update, comment resolve

### codex

Codex CLIを使用してコード実装・レビュー・リファクタリング・デバッグを実行し、結果をマークダウンファイルに記録するスキル。

**トリガー:**
- Codexに実装を依頼する時
- Codexにコードレビューを依頼する時
- Codexにリファクタリングを依頼する時
- Codexにデバッグを依頼する時

**対応操作:** implement, review, refactor, debug

**入力パラメータ:**
- `operation`: 操作種別（implement, review, refactor, debug）
- `prompt`: Codexに送信するプロンプト
- `model`: 使用するモデル（オプション、デフォルト: auto）
- `sandbox_mode`: サンドボックスモード（デフォルト: workspace-write）
- `approval_policy`: 承認ポリシー（デフォルト: on-failure）

**除外ファイルパターン:** `.env`, `*credentials*`, `*secret*`, `*password*`, `.claude/**`, `.vscode/**`, `.serena/**`

**出力先:** `.claude/plans/codex/YYYY_MMDD_HHMM_SS_<operation>_result.md`

**セキュリティ:**
- 機密情報ファイルは自動的に除外されます
- サンドボックスモードで安全に実行されます
- 実行結果は`.gitignore`で除外されています

### tmux-pane-info

現在Claude Codeが起動されているtmuxの「セッション・ウィンドウ・ペイン」の情報、および同一セッション・ウィンドウ内で起動されている別ペインの情報を取得するスキル。以下のトリガーで自動的に呼び出されます：

- 現在のtmuxセッション・ウィンドウ・ペインの情報を知りたい時
- 同じウィンドウ内の別ペインの情報を取得したい時
- 「tmuxの情報を教えて」「隣のペインで何が動いてる？」と言われた時

**対応操作:**
- 現在のセッション・ウィンドウ・ペイン情報取得（`tmux display-message`）
- 同一ウィンドウ内の別ペイン一覧取得（`tmux list-panes`）
- 別ペインの表示内容取得（`tmux capture-pane`）

**前提条件:** tmuxセッション内でClaude Codeが起動されている場合のみ有効（`$TMUX` 環境変数で判定）

## 出力先

- チケット番号がある場合: `.claude/plans/<チケット番号>/`
- チケット番号がない場合: `.claude/plans/tmp/`

## ファイル名フォーマット

タイムスタンプ付きファイル名（日本時間）:

```
YYYY_MMDD_HHMM_SS_<ドキュメント種別>.md
```

例: `2025_0102_0304_05_requirements.md`

## スキルファイルの形式

```markdown
---
description: <スキルの説明>
allowed-tools: <許可ツール（カンマ区切り）>
---

## 概要
<スキルの概要説明>

## タスク
<実行するタスクの詳細>
```

## カスタムスキルの追加

新しいスキルを追加する場合は、上記の形式でmarkdownファイルを作成してください。

### 命名規則

- ディレクトリ名: `機能名/`（例: `git/`, `pull-request/`）
- ファイル名: `SKILL.md`
- 機能単位でまとめる（コマンド単位ではなく）

## 関連ファイル

### Agent（Taskツール経由での呼び出し用）

- `claude/agents/spec-writer.md`
- `claude/agents/plan-writer.md`

### Command（コマンドでの呼び出し用）

- `claude/commands/plan.create.md` - `/plan.create`
- `claude/commands/tasks.execute.md` - `/tasks.execute`
