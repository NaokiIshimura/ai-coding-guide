# Claude Code Skills

このディレクトリには、Claude Code の skill 定義（`claude/skills/<name>/SKILL.md`）が格納されています。

以前のスラッシュコマンド（commands）は、すべて skill に移行しました。呼び出し名（`/git.commit.push.pr` など）は変わらず、そのまま `/<name>` で実行できます。

## Skills と Agents の違い

| 項目 | 共通 skill | 呼び出し用 skill | Agents |
|------|-----------|-----------------|--------|
| 配置 | `claude/skills/<name>/SKILL.md` | `claude/skills/<name>/SKILL.md` | `claude/agents/<name>.md` |
| 名前の例 | `git`, `spec-writer` | `git.commit.push.pr`, `plan.create` | `jira-collector` |
| 呼び出し方 | Skill ツール（モデルが自動選択 / 他の skill から呼び出し）、`/<name>` | ユーザーが `/<name>` で実行 | Agent ツール（`subagent_type`） |
| 実行主体 | メインセッション | メインセッション | sub-agent |
| コンテキスト | 共有 | 共有 | 独立 |
| 役割 | 手順本体・テンプレートを保持 | 引数を受け取り、共通 skill を呼び出す薄いラッパー | 専門的タスクの自律実行 |

## 共通 skill

手順本体とテンプレート（`templates/`、`${CLAUDE_SKILL_DIR}` で参照）を持つ skill です。モデルが description に基づいて自動で呼び出すほか、呼び出し用 skill から Skill ツールで呼び出されます。

| skill | 説明 | 主な出力 |
|-------|------|---------|
| `git` | gitを操作する（branch, commit, push, pull, デフォルトブランチへの切り替え） | - |
| `pull-request` | プルリクエストを操作する（create, update, comment resolve, review, CI wait） | - |
| `plan-writer` | 実行計画（plan.md）を作成する | `<TS>_plan.md` |
| `spec-writer` | 仕様書（requirements/design/tasks.md）を統合的に作成する | `<TS>_requirements.md`, `<TS>_design.md`, `<TS>_tasks.md` |
| `tasks-execute` | tasks.mdに定義されたタスクを依存関係を考慮して順番に実装する | 実装コード、更新された tasks.md |
| `markdown` | markdownファイルを操作する（作業状況・調査結果の output、過去の作業の input） | `<TS>_<topic>.md` |
| `codex` | Codex CLIに実装・レビュー・リファクタリング・デバッグを依頼し、結果をマークダウンファイルに記録する | `<TS>_codex_<operation>.md` |
| `tmux-pane-info` | 現在のtmuxセッション・ウィンドウ・ペイン、および同一ウィンドウ内の別ペインの情報を取得する | - |

※ `<TS>` は日本時間のタイムスタンプ（`YYYY_MMDD_HHMM_SS`）です。

### 各共通 skill の補足

#### git

- 対応操作: branch / commit / push / pull / switch default
- `guides/git.md` のルール（ブランチ名はチケット番号のみ、日本語の署名付きコミット、`.claude` 等をコミットしない、`--no-verify` 禁止）に従います

#### pull-request

- 対応操作: create / update / comment resolve / review / CI wait
- PR description のテンプレートは `templates/description.md`（プロジェクトに `.github/pull_request_template.md` があればそちらを優先）
- PRレビューの投稿は `guides/github.md` のルール（インラインコメント付きの review を1回で投稿）に従います

#### plan-writer / spec-writer

- 出力先: `.claude/plans/<チケット番号>/`（チケット番号がない場合は `.claude/plans/tmp/`）
- テンプレート: `plan-writer/templates/plan.md`、`spec-writer/templates/{requirements,design,tasks}.md`
- 広範囲の調査が必要な場合は、組み込みの `Explore` エージェントに委譲します

#### tasks-execute

- 入力: tasks.md のパス、または計画ディレクトリのパス（例: `.claude/plans/ABC-123/`）、開始タスクID（任意）
- コンテキストを圧迫しそうなタスクは `code-implementer` エージェントに委譲します（依存関係がなく対象ファイルが重ならないタスクは並列実行可）

#### markdown

- output: 作業状況・調査結果を `.claude/plans/<チケット番号 or tmp>/` に出力（形式: standard / investigation / plan / summary）
- input: 指定ディレクトリ（省略時 `.claude/plans/`）のmarkdownを読み込み、作業状況を把握。ファイル数が多い場合は `Explore` エージェントに抽出を任せます

#### codex

- operation: `implement` / `review` / `refactor` / `debug`
- sandbox_mode の既定値: review は `read-only`、それ以外は `workspace-write`
- implement は tasks.md を渡すと複数タスクモード（タスクを順に依頼し、一括実行サマリーを作成）になります
- `.env`、`*credentials*`、`*secret*` などの機密情報ファイルはCodexに渡しません
- 出力先: `.claude/plans/<チケット番号 or tmp>/`（プロンプト・stdout/stderrログ・結果ファイル）

#### tmux-pane-info

- tmuxセッション内でClaude Codeが起動されている場合のみ有効（`$TMUX` 環境変数で判定）
- `tmux display-message` / `tmux list-panes` / `tmux capture-pane` で情報を取得します

## 呼び出し用 skill

ドット区切りの名前を持つ、ユーザーが `/<name> [引数]` で実行するための skill です。`disable-model-invocation: true` を設定しているため、モデルが自動で呼び出すことはありません。

### Git操作

| skill | 説明 | 引数 |
|-------|------|------|
| `/git.branch` | gitブランチを作成・切り替える | `[ブランチ名 or チケット番号]` |
| `/git.commit` | gitコミットを作成する | `[コミットメッセージの補足]` |
| `/git.push` | gitプッシュを実行する | - |
| `/git.pull` | 最新の変更を取得する | - |
| `/git.switch.default` | デフォルトブランチに切り替えて最新を取得する | - |
| `/git.commit.push` | gitコミットとプッシュを実行する | `[コミットメッセージの補足]` |
| `/git.commit.push.pr` | gitコミット、プッシュ、プルリクエスト作成を実行する | `[コミットメッセージ・PRの補足]` |

### Pull Request操作

| skill | 説明 | 引数 |
|-------|------|------|
| `/pr.create` | プルリクエストを作成する | `[PRの補足（チケット番号・タグなど）]` |
| `/pr.update` | プルリクエストのtitle・descriptionを現在のブランチの変更内容に合わせて更新する | `[PR番号 or URL]` |
| `/pr.comment.resolve` | PRのコメントを確認して修正を実施する | `[PR番号 or URL]` |
| `/pr.ci.wait` | PRのCIが完了するまで待機して通知する | `[PR番号 or URL]` |

### JIRA連携

| skill | 説明 | 引数 |
|-------|------|------|
| `/jira.issue.develop` | JIRAチケットの情報を取得し、仕様書作成から実装までを実施する | `[JIRAのURL または チケット番号]` |
| `/jira.issue.feedback` | JIRAチケットへフィードバックを投稿する | `[JIRAチケットのURL or チケット番号]` |

### 計画・仕様書作成

| skill | 説明 | 引数 |
|-------|------|------|
| `/plan.create` | 実行計画（plan.md）を作成する | `[チケット番号] [計画の対象・要件]` |
| `/spec.create` | 仕様書（requirements/design/tasks.md）を作成する | `[チケット番号] [機能概要・要件]` |
| `/md.output.plan` | 現在までの作業状況から実行計画（plan.md）を出力する | `[チケット番号] [計画のタイトル]` |
| `/md.output.spec` | 現在までの作業状況から実装計画（requirements/design/tasks.md）を出力する | `[チケット番号]` |

### タスク実行

| skill | 説明 | 引数 |
|-------|------|------|
| `/tasks.execute` | tasks.mdに基づいてタスクを実行する | `<tasks.mdのパス> [開始タスクID]` |
| `/plan.implement` | 実装計画に基づいて実装を開始する | `<計画ディレクトリのパス> [開始タスクID]` |

### Markdown入出力

| skill | 説明 | 引数 |
|-------|------|------|
| `/md.output` | 現在までの作業状況・調査結果をmarkdownファイルに出力する | `[トピック名] [出力形式: standard\|investigation\|plan\|summary]` |
| `/md.input` | 指定したディレクトリ内のmarkdownファイルを読み込んで作業状況を把握する | `[読み込み対象ディレクトリ（省略時: .claude/plans/）]` |
| `/md.develop` | markdownファイルの情報を元に仕様書作成から開発までを実施する | `<markdownファイルのパス>` |

### Codex連携

| skill | 説明 | 引数 |
|-------|------|------|
| `/codex.implement` | Codexに実装を依頼する | `[実装内容 \| tasks.mdのパス] [開始タスク（例: Task-3以降）]` |
| `/codex.review` | Codexにコードレビューを依頼する | `[ファイル \| ディレクトリ（省略時: 未コミットの変更）] [重点観点]` |
| `/codex.refactor` | Codexにリファクタリングを依頼する | `<対象ファイル> [改善方針]` |
| `/codex.debug` | Codexにデバッグを依頼する | `<エラーメッセージ・スタックトレース・再現手順など>` |

### Claude Comment管理

| skill | 説明 | 引数 |
|-------|------|------|
| `/claude.comment` | @claudeコメントの検索・実行・削除を管理する | `[検索のみ\|実行のみ\|クリーンアップのみ\|フル実行] [対象パス]` |

### ユーティリティ

| skill | 説明 | 引数 |
|-------|------|------|
| `/task.init` | `.claude/plans` 配下にタスク用ディレクトリを準備する | `<ディレクトリ名（チケット番号 or tmp など）>` |
| `/storybook.docgen.disable` | StorybookのdocgenをFalseに設定する（一時的な無効化） | - |

## 呼び出し関係

呼び出し用 skill は、Skill ツールで共通 skill を呼び出す（または Agent ツールでエージェントを起動する）だけの薄いラッパーです。

| 呼び出し用 skill | 利用する共通 skill / エージェント |
|-----------------|--------------------------------|
| `/git.branch`, `/git.commit`, `/git.push`, `/git.pull`, `/git.switch.default`, `/git.commit.push` | `git` |
| `/git.commit.push.pr` | `git` → `pull-request` |
| `/pr.create`, `/pr.update`, `/pr.comment.resolve`, `/pr.ci.wait` | `pull-request` |
| `/jira.issue.develop` | `spec-writer` → `git`（branch） → `tasks-execute` |
| `/md.develop` | `spec-writer` → `git`（branch） → `tasks-execute` |
| `/plan.create`, `/md.output.plan` | `plan-writer` |
| `/spec.create`, `/md.output.spec` | `spec-writer` |
| `/tasks.execute`, `/plan.implement` | `tasks-execute` |
| `/md.output`, `/md.input` | `markdown` |
| `/codex.implement`, `/codex.review`, `/codex.refactor`, `/codex.debug` | `codex` |
| `/claude.comment` | エージェント `claude-comment-finder` → `claude-comment-executor` → `claude-comment-cleaner` |
| `/jira.issue.feedback`, `/task.init`, `/storybook.docgen.disable` | なし（skill 単体で完結） |

```
spec-writer
    ├─ requirements作成 → requirements.md
    ├─ design作成 → design.md（requirements参照）
    └─ tasks作成 → tasks.md（requirements/design参照）
                     └─ tasks-execute で順番に実装
```

## ワークフロー例

### JIRAチケットからの開発フロー

```bash
# 1. JIRAチケットから仕様書を作成し、ブランチ作成・実装まで実施
/jira.issue.develop ABC-123

# 2. 実装完了後、コミット・プッシュ・PR作成
/git.commit.push.pr

# 3. レビューコメントへの対応
/pr.comment.resolve

# 4. JIRAチケットへフィードバック
/jira.issue.feedback
```

### 仕様書ベースの開発フロー

```bash
# 1. 仕様書を作成
/spec.create ABC-123

# 2. 作成された requirements/design/tasks.md を確認・編集

# 3. 仕様書に基づいて実装を開始
/plan.implement .claude/plans/ABC-123/

# 4. 実装完了後、コミット・プッシュ・PR作成
/git.commit.push.pr
```

### 実行計画ベースの開発フロー

```bash
# 1. 実行計画を作成
/plan.create ABC-123

# 2. 作成された plan.md を確認・編集

# 3. 計画に基づいて実装を実行
/plan.implement .claude/plans/ABC-123/

# 4. 途中でコミットし、残りのタスクを実装
/git.commit
/tasks.execute .claude/plans/ABC-123/<TS>_tasks.md TASK-004

# 5. 実装完了後、コミット・プッシュ・PR作成
/git.commit.push.pr
```

### 作業状況からの計画作成フロー

```bash
# 正式な実装計画（requirements/design/tasks.md）を作成・更新（新しいタイムスタンプで作成される）
/md.output.spec

# 軽量な実行計画（plan.md）を作成
/md.output.plan
```

#### `/md.output.spec` と `/md.output.plan` の使い分け

| 観点 | `/md.output.spec` | `/md.output.plan` |
|------|-------------------|-------------------|
| 出力 | requirements/design/tasks.md の3ファイル | plan.md の1ファイル |
| 向いている作業 | チーム共有用の詳細な仕様書が必要な作業、要件・設計・タスクを分離したい複雑な機能 | 個人作業、プロトタイピング、短期タスク、シンプルな実装 |
| その他 | - | 既に requirements/design.md があり、実行計画のみ欲しい場合 |

### Codex連携の開発フロー

```bash
# 1. 仕様書を作成
/spec.create

# 2. Codexに実装を依頼（tasks.md を渡すとタスクを順に依頼）
/codex.implement .claude/plans/ABC-123/<TS>_tasks.md

# 3. Codexにレビューを依頼（省略時は未コミットの変更が対象）
/codex.review

# 4. 指摘事項に応じてCodexでリファクタリング
/codex.refactor <ファイルパス>

# 5. コミット・プッシュ・PR作成
/git.commit.push.pr
```

### Codexによるデバッグフロー

```bash
# 1. エラーが発生した場合、Codexにデバッグを依頼
/codex.debug <エラーメッセージ>

# 2. 修正案を確認して適用し、テストを実行して動作確認

# 3. 問題が解決したらコミット
/git.commit
```

### 作業再開時のフロー

```bash
# 1. 過去の作業状況を確認
/md.input .claude/plans/ABC-123/

# 2. デフォルトブランチに切り替えて最新を取得（作業ブランチで続ける場合は /git.pull）
/git.switch.default

# 3. 残りのタスクを実装
/tasks.execute .claude/plans/ABC-123/<TS>_tasks.md
```

## 出力先

- チケット番号がある場合: `.claude/plans/<チケット番号>/`
- チケット番号がない場合: `.claude/plans/tmp/`

ファイル名は日本時間のタイムスタンプ付きです（例: `2025_0102_0304_05_requirements.md`）。

## skill の追加

### ディレクトリ構成

```
claude/skills/
├── <共通 skill>/
│   ├── SKILL.md
│   └── templates/        # 任意。SKILL.md から ${CLAUDE_SKILL_DIR}/templates/... で参照
└── <呼び出し用 skill>/
    └── SKILL.md
```

### 共通 skill の形式

```markdown
---
name: <skill名>
description: <何をする skill か。Use when: 自動で呼び出されるべき場面>
allowed-tools: <許可ツール（カンマ区切り）>
---

# <タイトル>

<手順本体>
```

### 呼び出し用 skill の形式

```markdown
---
description: <skill の説明>
argument-hint: "<引数の説明>"
disable-model-invocation: true
allowed-tools: Skill, <共通 skill の実行に必要なツール>
---

## コンテキスト
- 引数: $ARGUMENTS

## タスク
Skill ツールで共通 skill `<skill名>` を呼び出し、その手順に従って実行してください。
```

### 命名規則・注意事項

- 共通 skill: 機能単位のハイフン区切り（例: `pull-request`, `tasks-execute`）
- 呼び出し用 skill: ドット区切り（例: `git.commit.push.pr`）。手順は共通 skill に置き、ラッパーは薄く保つ
- 同名の skill は `~/.claude/skills/` がプロジェクトの `.claude/skills/` より優先されます
- `claude/skills/` を更新した場合は、このファイル（`claude/SKILLS.md`）も更新してください
