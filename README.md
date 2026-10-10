# AIコーディングガイド
AI アシスタント（ClaudeCode / GithubCopilot / Cline / RooCode）と効果的に協働するためのコーディングガイドです。

## ファイル構成
```
ai-coding-guide/
├── claude/
│   ├── CLAUDE.md                # Claude用の設定ファイル（guides/ を参照）
│   ├── settings.json            # Claude設定ファイル（インストール時に ~/.claude/settings.json へマージ）
│   ├── statusline-readable.sh   # Claude statusline スクリプト
│   ├── AGENTS.md                # エージェント一覧
│   ├── SKILLS.md                # skill 一覧・ワークフロー例
│   ├── agents/                  # Claudeエージェント定義（<name>.md）
│   └── skills/                  # Claude skill 定義（<name>/SKILL.md）
├── guides/
│   ├── common.md        # 共通ガイドライン
│   ├── git.md           # Git操作ガイド
│   ├── github.md        # GitHub（PRレビュー投稿）ガイド
│   ├── mcp.md           # MCPツール使用ガイド
│   ├── frontend.md      # フロントエンド開発ガイド
│   ├── react.md         # React開発ガイド
│   ├── storybook.md     # Storybook作成ガイド
│   ├── test.md          # テスト作成ガイド
│   ├── pull-request.md  # プルリクエスト作成ガイド
│   ├── docker.md        # Docker / colima ガイド
│   ├── speckit.md       # speckitガイド
│   └── plan-spec.md     # 実行計画・仕様書出力ガイド
├── config/
│   └── tmux.conf        # tmux設定
├── sounds/              # hooks で利用する通知音
├── vscode/              # VSCode設定
└── Makefile             # インストール用Makefile
```

`claude/CLAUDE.md` は `~/ai-coding-guide/guides/*.md` を参照しているため、リポジトリは `~/ai-coding-guide` にクローンしてください。

## インストール

Makefileを使用して、Claude用の設定ファイル、エージェント、skill を `~/.claude/` ディレクトリにインストールできます。また、`~/.claude/` の設定をプロジェクトにインポートすることも可能です。

### 使用可能なコマンド

```bash
# すべてインストール（CLAUDE.md、settings、statusline、agents、skills、tmux.conf）
make install

# 個別インストール
make install-config     # CLAUDE.mdのみインストール
make install-settings   # settings.jsonを ~/.claude/settings.json にマージ（バックアップを作成）
make install-statusline # statusline-readable.shのみインストール
make install-agents     # agentsのみインストール
make install-skills     # skillsのみインストール（skill ごとに rsync --delete で同期）
make install-tmux-conf  # tmux.confを ~/.tmux.conf にインストール

# 旧構成（commands）からの移行
make migrate            # 旧 commands・削除済み agent をバックアップして削除

# 設定のインポート
make import-settings    # ~/.claude/settings.json からリポジトリ管理のキーのみ取り込む

# アンインストール（このリポジトリが管理するファイル・キーのみ削除）
make clean              # すべて削除
make clean-config       # CLAUDE.mdのみ削除
make clean-settings     # settings.json から管理キーを削除（バックアップを作成）
make clean-agents       # agentsのみ削除
make clean-skills       # skillsのみ削除
make clean-tmux-conf    # tmux.confのみ削除

# ヘルプ表示
make help
```

### インストール例（新規環境）

```bash
# リポジトリをクローン
git clone https://github.com/NaokiIshimura/ai-coding-guide.git ~/ai-coding-guide
cd ~/ai-coding-guide

# すべてインストール
make install

# 確認
ls ~/.claude/ ~/.claude/agents/ ~/.claude/skills/
```

### 既存環境の移行手順

以前の構成（`make install-commands` でコマンドをインストールしていた環境）からは、以下の順で移行してください。

```bash
cd ~/ai-coding-guide
git pull

# 1. 旧 commands と削除済み agent をバックアップしてから削除
make migrate

# 2. 新しい構成をインストール
make install
```

| ステップ | 処理内容 | バックアップ先 |
|---------|---------|---------------|
| `make migrate` | `~/.claude/{agents,commands,skills}` をバックアップし、このリポジトリ由来の旧 commands と削除済み agent のみ削除（`commands/` が空になればディレクトリも削除） | `~/.claude/backups/ai-coding-guide_<タイムスタンプ>/` |
| `make install` | settings.json は上書きせずマージ（リポジトリ側の値を優先し、既存のみのキーは残す）。agents・skills・CLAUDE.md・statusline・tmux.conf はコピー | `~/.claude/settings.json.bak.<タイムスタンプ>` |

### 注意事項

- 同名の skill は `~/.claude/skills/` がプロジェクトの `.claude/skills/` より優先されます。旧コマンドが残っていると新しい skill と競合するため、既存環境では必ず `make migrate` → `make install` を実行してください
- `make install-settings` / `make import-settings` / `make clean-settings` には `jq` が必要です
- `make install` は `~/.tmux.conf` を上書きします。不要な場合は個別ターゲットでインストールしてください
- インストール先は `CLAUDE_DIR` で変更できます（例: `make install CLAUDE_DIR=/tmp/claude-test`）

## ワークフロー

各 skill の詳細とその他のワークフロー例は [claude/SKILLS.md](claude/SKILLS.md) を参照してください。

### JIRAチケットからの開発フロー

```
/jira.issue.develop   # JIRAチケットから仕様書作成＆開発
     ↓
/git.commit.push.pr   # コミット・プッシュ・PR作成
     ↓
/jira.issue.feedback  # JIRAチケットへフィードバック
```

### 仕様書ベースの開発フロー

```
/spec.create          # 仕様書を作成（requirements/design/tasks.md）
     ↓
/tasks.execute        # tasks.mdに基づいて順次実装
     ↓
/git.commit.push.pr   # コミット・プッシュ・PR作成
     ↓
/pr.comment.resolve   # レビューコメントへの対応
```

### 計画ベースの開発フロー

```
/plan.create                      # 実行計画を作成（plan.md）
     ↓
/plan.implement <計画ディレクトリ>  # 計画に基づいて実装
     ↓
/git.commit                       # コミット
     ↓
/tasks.execute <tasks.md>         # 残りのタスクを実装
     ↓
/git.commit.push.pr               # 最終コミット＆PR作成
```

### 作業再開時のフロー

```
/md.input             # 過去の作業状況を確認
     ↓
/git.switch.default   # デフォルトブランチに切り替えて最新を取得（作業ブランチで続ける場合は /git.pull）
     ↓
/tasks.execute        # 残りのタスクを実装
```

## 移行ガイド

commands は skill に移行しました。呼び出し名が変わらないものは、`make migrate` → `make install` 後もそのまま `/<name>` で実行できます。

### 旧 command

| 旧 command | 新しい skill / 代替手段 | 備考 |
|-----------|------------------------|------|
| `/git.branch`, `/git.commit`, `/git.push`, `/git.pull`, `/git.commit.push`, `/git.commit.push.pr` | 同名の skill | 呼び出し名は変わりません |
| `/git.switch.default` | 同名の skill | 呼び出し名は変わりません |
| `/git.pull.default` | `/git.switch.default` | 旧ドキュメントにのみ記載されていた存在しないコマンド。デフォルトブランチへの切り替えと最新の取得は `/git.switch.default` を使用 |
| `/pr.create`, `/pr.update`, `/pr.comment.resolve`, `/pr.ci.wait` | 同名の skill | 呼び出し名は変わりません |
| `/pr.comment.check` | `/pr.comment.resolve` | 削除（非推奨だった旧バージョン） |
| `/jira.issue.develop`, `/jira.issue.feedback` | 同名の skill | 呼び出し名は変わりません |
| `/jira.issue.develop.old`, `/jira.issue.develop.old2` | `/jira.issue.develop` | 削除（非推奨だった旧バージョン） |
| `/plan.create`, `/plan.implement`, `/spec.create`, `/tasks.execute` | 同名の skill | 呼び出し名は変わりません |
| `/md.output`, `/md.output.plan`, `/md.output.spec`, `/md.input`, `/md.develop` | 同名の skill | 呼び出し名は変わりません |
| `/codex.implement`, `/codex.review`, `/codex.refactor`, `/codex.debug` | 同名の skill | 呼び出し名は変わりません |
| `/claude.comment`, `/task.init`, `/storybook.docgen.disable` | 同名の skill | 呼び出し名は変わりません |
| `/memory.read`, `/memory.write` | 組み込みの auto memory（`/memory`） | 削除 |

### 旧 agent

| 旧 agent | 新しい skill / 代替手段 |
|---------|------------------------|
| `code-collector`, `file-collector` | 組み込みの `Explore` エージェント |
| `code-reviewer` | 組み込みの `/code-review` |
| `git-operator` | `git` skill |
| `markdown-handler` | `markdown` skill |
| `plan-writer`, `spec-writer` | 同名の skill（`plan-writer` / `spec-writer`） |
| `tasks-executor` | `tasks-execute` skill |
| `codex-implementer`, `codex-reviewer` | `codex` skill（`/codex.implement`, `/codex.review`） |

### Makefile

| 旧ターゲット / 旧手順 | 新しいターゲット / 手順 |
|---------------------|----------------------|
| `make install-commands`, `make clean-commands` | 削除（commands は skills に統合） |
| `rsync` で `claude/commands/` を `~/.claude/commands/` へ同期 | `make migrate` で削除し、`make install-skills` で skill をインストール |
| `make install-settings`（上書きコピー） | `make install-settings`（既存設定にマージし、バックアップを作成） |
| `make import-settings`（ファイルごとコピー） | `make import-settings`（リポジトリ管理のキーのみ取り込み） |
