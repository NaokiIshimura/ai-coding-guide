# AIコーディングガイド
AI アシスタント（ClaudeCode / GithubCopilot / Cline / RooCode）効果的に協働するためのコーディングガイドです。

## ファイル構成
```
ai-coding-guide/
├── claude/
│   ├── CLAUDE.md                # Claude用の設定ファイル
│   ├── settings.json            # Claude設定ファイル
│   ├── statusline-readable.sh   # Claude statusline スクリプト
│   ├── agents/                  # Claudeエージェント定義
│   ├── commands/                # Claudeコマンド定義
│   └── skills/                  # Claudeスキル定義
├── guides/
│   ├── common.md      # 共通ガイドライン
│   ├── git.md         # Git操作ガイド
│   ├── mcp.md         # MCPツール使用ガイド
│   ├── react.md       # React開発ガイド
│   ├── storybook.md   # Storybook作成ガイド
│   └── test.md        # テスト作成ガイド
└── Makefile           # インストール用Makefile
```

## インストール

Makefileを使用して、Claude用の設定ファイル、エージェント、コマンド、スキルを`~/.claude/`ディレクトリにインストールできます。また、`~/.claude/`の設定をプロジェクトにインポートすることも可能です。

### 使用可能なコマンド

```bash
# すべてインストール（CLAUDE.md、settings、agents、commands、skills）
make install

# 個別インストール
make install-config     # CLAUDE.mdのみインストール
make install-settings   # settings.jsonのみインストール
make install-statusline # statusline-readable.shのみインストール
make install-agents     # agentsディレクトリのみインストール
make install-commands   # commandsディレクトリのみインストール
make install-skills     # skillsディレクトリのみインストール

# 設定のインポート
make import-settings   # ~/.claude/ の設定をプロジェクトにコピー

# アンインストール
make clean            # すべて削除
make clean-config     # CLAUDE.mdのみ削除
make clean-settings   # settingsのみ削除
make clean-agents     # agentsのみ削除
make clean-commands   # commandsのみ削除
make clean-skills     # skillsのみ削除

# ヘルプ表示
make help
```

### インストール例

```bash
# リポジトリをクローン
git clone https://github.com/NaokiIshimura/ai-coding-guide.git
cd ai-coding-guide

# すべてインストール
make install

# 確認
ls ~/.claude/
```

## Skills（スキル）

Claudeが自動的に使用するスキルです。

| スキル名 | 説明 | 出力ファイル |
|----------|------|-------------|
| `plan-create` | 実装計画を作成（統合SKILL） | requirements.md, design.md, tasks.md |
| `requirements-writer` | 仕様書を作成 | requirements.md |
| `design-writer` | 設計書を作成 | design.md |
| `tasks-writer` | タスクリストを作成 | tasks.md |

## Agents（エージェント）

Taskツール経由で呼び出すエージェントです。詳細は [claude/AGENTS.md](claude/AGENTS.md) を参照してください。

### 実装計画作成

| エージェント | 説明 |
|-------------|------|
| `plan-create` | 実装計画作成（requirements/design/tasks統合作成） |
| `requirements-writer` | 仕様書作成 |
| `design-writer` | 設計書作成 |
| `tasks-writer` | タスクリスト作成 |

### コード関連

| エージェント | 説明 |
|-------------|------|
| `code-collector` | ソースコード情報収集 |
| `code-implementer` | コード実装 |
| `code-reviewer` | コードレビュー |
| `debugger` | デバッグ |

### 情報収集

| エージェント | 説明 |
|-------------|------|
| `file-collector` | ファイル情報収集 |
| `web-collector` | Web情報収集 |
| `confluence-collector` | Confluence情報収集 |
| `jira-collector` | JIRA情報収集 |
| `pr-collector` | Pull Request情報収集 |
| `slack-collector` | Slack情報収集 |

### データ分析

| エージェント | 説明 |
|-------------|------|
| `data-scientist` | SQLクエリ、データ分析 |

### Claude Comment管理

| エージェント | 説明 |
|-------------|------|
| `claude-comment-finder` | @claudeコメント検出 |
| `claude-comment-executor` | @claudeコメント実行 |
| `claude-comment-cleaner` | @claudeコメントクリーンアップ |

## Commands（コマンド）

`/`で呼び出すコマンドです。詳細は [claude/COMMANDS.md](claude/COMMANDS.md) を参照してください。

### 実装計画

| コマンド | 説明 |
|----------|------|
| `/plan.create` | 実装計画（requirements/design/tasks）を作成 |
| `/md.output.spec` | 作業状況から実装計画を出力 |

### 開発

| コマンド | 説明 |
|----------|------|
| `/jira.issue.develop` | JIRAチケットから開発を実施 |
| `/md.develop` | markdownファイルから開発を実施 |

### Git操作

| コマンド | 説明 |
|----------|------|
| `/git.branch` | ブランチ作成・切り替え |
| `/git.commit` | コミット作成 |
| `/git.push` | プッシュ |
| `/git.commit.push` | コミット＆プッシュ |
| `/git.commit.push.pr` | コミット＆プッシュ＆PR作成 |
| `/git.pull` | プル |
| `/git.pull.default` | デフォルトブランチからプル＆マージ |

### PR操作

| コマンド | 説明 |
|----------|------|
| `/pr.create` | PR作成 |
| `/pr.update` | PR説明更新 |
| `/pr.comment.check` | PRコメント確認 |
| `/pr.comment.resolve` | PRコメント対応 |

### その他

| コマンド | 説明 |
|----------|------|
| `/claude.comment` | @claudeコメント管理 |
| `/md.input` | markdownファイル読み込み |
| `/md.output` | 作業状況をmarkdown出力 |
| `/task.init` | タスクディレクトリ初期化 |
| `/jira.issue.feedback` | JIRAチケットへフィードバック |
