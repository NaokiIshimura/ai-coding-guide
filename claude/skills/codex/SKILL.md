---
description: |
  Codex CLIに実装・レビュー・リファクタリング・デバッグを依頼し、結果をマークダウンファイルに記録する。Use when:
  - Codexに実装を依頼する時（ユーザー指示1件、またはtasks.mdのタスクを順に依頼する複数タスクモード）
  - Codexにコードレビューを依頼する時（単一ファイル、ディレクトリ・複数ファイルの一括レビュー、未コミットの変更）
  - Codexにリファクタリングやデバッグ（エラー原因の特定と修正）を依頼する時
  - 「Codexで〜して」「Codexにレビューさせて」と言われた時
allowed-tools: Bash(codex *), Bash(mkdir *), Bash(date *), Bash(TZ=Asia/Tokyo date *), Bash(git diff *), Bash(git status *), Bash(git branch *), Bash(find *), Read, Write, Glob, Grep
---

# Codex実行スキル

## 概要

Codex CLIを使用してコード実装、レビュー、リファクタリング、デバッグを実行し、結果をマークダウンファイルに記録します。
呼び出し用 skill（`/codex.implement`, `/codex.review`, `/codex.refactor`, `/codex.debug`）はこの skill の手順に従います。

## コンテキスト

- 現在のディレクトリ: !`pwd`
- Codexバージョン: !`codex --version 2>/dev/null || echo "Not installed"`
- タイムスタンプ（日本時間）: !`TZ=Asia/Tokyo date +"%Y_%m%d_%H%M_%S"`

## 入力パラメータ

呼び出し元（ユーザーの指示、または呼び出し用 skill の `$ARGUMENTS`）から以下を決めます。

| パラメータ | 説明 | デフォルト |
|---|---|---|
| operation | 操作種別（`implement` / `review` / `refactor` / `debug`） | 指示内容から判断 |
| target | 対象（ファイル、ディレクトリ、tasks.md、エラー情報） | 操作種別ごとに後述 |
| instruction | 対象以外の追加指示（重点観点、改善方針など） | なし |
| model | 使用するモデル | 指定なし（Codex の設定に従う） |
| sandbox_mode | サンドボックスモード（`read-only` / `workspace-write` / `danger-full-access`） | review: `read-only`、それ以外: `workspace-write` |
| working_dir | Codex の作業ディレクトリ | カレントディレクトリ |

- `danger-full-access` はユーザーが明示的に指定・承認した場合のみ使用します
- シェル変数は Bash ツールの呼び出し間で引き継がれません。以降の手順の `<TIMESTAMP>` などのプレースホルダーには、取得した値をそのまま埋め込んでコマンドを実行してください

## 共通手順

### 1. Codex CLIの利用可能性を確認

コンテキストの「Codexバージョン」が `Not installed` の場合は、以下を通知して終了します。

```
エラー: Codex CLIがインストールされていません。
インストール後に再実行してください（例: npm install -g @openai/codex または brew install codex）。
```

### 2. 出力先とタイムスタンプを決める

- タイムスタンプ: コンテキストの値を使う（取り直す場合は `TZ=Asia/Tokyo date +%Y_%m%d_%H%M_%S`）
- 出力先: `.claude/plans/<チケット番号 or tmp>/`
  - 引数・会話・ブランチ名（`git branch --show-current`）からチケット番号が分かればそれを使い、分からなければ `tmp`
  - `mkdir -p .claude/plans/<チケット番号 or tmp>` で作成
- 出力ファイル（`<op>` は操作種別）

| ファイル | 用途 |
|---|---|
| `<TIMESTAMP>_codex_<op>_prompt.md` | Codex に渡すプロンプト（複数件の場合は `<TIMESTAMP>_codex_<op>_<番号>_prompt.md`） |
| `<TIMESTAMP>_codex_<op>_stdout.log` / `_stderr.log` | Codex の標準出力・標準エラー出力（複数件の場合は `_<番号>_stdout.log` など） |
| `<TIMESTAMP>_codex_<op>.md` | 実行結果（複数件の場合も1ファイルにまとめる） |

### 3. 機密情報の除外

以下のファイルの内容はプロンプトに含めず、Codex に読ませる対象にも指定しません。

```
.env
.env.*
*credentials*
*secret*
*password*
*token*
.claude/**   （ただし仕様ファイル requirements/design/tasks.md の内容はプロンプトに含めてよい）
.vscode/**
.serena/**
node_modules/**
vendor/**
.git/**
```

### 4. プロンプトを作成

- 操作種別ごとのテンプレートを Read で読み込み、プレースホルダーを埋めてプロンプトファイルに Write で書き出します

| 操作種別 | テンプレート |
|---|---|
| implement | `${CLAUDE_SKILL_DIR}/templates/prompt-implement.md` |
| review | `${CLAUDE_SKILL_DIR}/templates/prompt-review.md` |
| refactor | `${CLAUDE_SKILL_DIR}/templates/prompt-refactor.md` |
| debug | `${CLAUDE_SKILL_DIR}/templates/prompt-debug.md` |

- プロジェクト規約は、テンプレートの「プロジェクト規約」に記載した要点（ファイル末尾の空行、コメントの言語・量を周辺コードに合わせる等）をプロンプト本文に含めて渡します。ガイドファイルへの `@` 付きのパス参照は Codex 側では解決されないため書きません
- 対象ファイルのコードはプロンプトに貼り付けず、ファイルパスを渡して Codex にワークスペースから読ませます
- 該当しないセクション（要件・設計がない等）は削除します

### 5. Codexを実行

Bash ツールの `timeout` は `600000`（10分）を指定します。プロンプトはファイルから読み込んで渡します。

#### exec（implement / refactor / debug、および対象指定ありの review）

```bash
codex exec \
  --sandbox <sandbox_mode> \
  [--model <model>] \
  [--cd <working_dir>] \
  "$(cat <出力先>/<TIMESTAMP>_codex_<op>_prompt.md)" \
  > <出力先>/<TIMESTAMP>_codex_<op>_stdout.log \
  2> <出力先>/<TIMESTAMP>_codex_<op>_stderr.log; echo "exit_code=$?"
```

- `[...]` はパラメータが指定された場合のみ付けます
- 実行前後に `date +%s` で時刻を取得し、実行時間を算出します

#### review（対象指定なし: 未コミットの変更をレビュー）

```bash
codex review \
  [--cd <working_dir>] \
  > <出力先>/<TIMESTAMP>_codex_review_stdout.log \
  2> <出力先>/<TIMESTAMP>_codex_review_stderr.log; echo "exit_code=$?"
```

#### CLIオプションについて

上記のオプション（`exec` の `--sandbox` / `--model` / `--cd`、`review` サブコマンド）は、Codex CLI のバージョンによって存在しない・名前が異なる可能性があります。初回実行前に `codex exec --help` / `codex review --help` で確認し、存在しないオプションは外して実行してください。`codex review` が存在しない場合は、`git diff` の対象ファイルを target にして exec でレビューします。

### 6. 実行結果を記録

`${CLAUDE_SKILL_DIR}/templates/result.md` を Read で読み込み、stdout / stderr のログ内容を埋めて `<出力先>/<TIMESTAMP>_codex_<op>.md` に Write で出力します。

- 単一実行の場合は「一括実行サマリー」以降を削除します
- 「サマリー」「次のアクション」は Codex の出力を読んで Claude が記述します
- ファイル末尾は必ず空行（改行）で終わるようにします

### 7. ユーザーに通知

```
Codex実行が完了しました（<操作種別>）。
結果ファイル: <結果ファイルのパス>
終了コード: <exit_code>

<サマリー（review の場合は High / Medium / Low の件数）>

次のステップ:
- <操作種別ごとの次のステップ>
```

操作種別ごとの次のステップの例:

| 操作種別 | 次のステップ |
|---|---|
| implement | 実装されたコードを確認する、テストを実行する、`/codex.review` でレビューする |
| review | High 優先度の指摘から修正する、必要に応じて `/codex.refactor` を実行する |
| refactor | `git diff` で差分を確認する、テストを実行して振る舞いが変わっていないことを確認する |
| debug | 修正内容を確認する、テストを実行して問題が解決したか確認する |

## 操作種別ごとの手順

### implement（実装）

#### 対象の決定

- target が tasks.md のパス、tasks.md を含むディレクトリ、または「tasks.md のタスクを実行」等の指示の場合は **複数タスクモード**
- それ以外は instruction（ユーザーの指示）を実装内容とする **単一実行**

#### 単一実行

1. 最新の仕様ファイルを探す（存在する場合のみ使用）
   - `find .claude/plans -name "*requirements.md" -type f | sort -r | head -1`（design.md / tasks.md も同様）
2. 仕様ファイルが見つかれば Read で読み込み、プロンプトの「要件」「設計」に含める
3. 見つからない場合は以下を通知してユーザーの指示のみで進める

```
注意: requirements.md、design.md、tasks.mdが見つかりませんでした。
ユーザーの指示のみで実装を進めます。
詳細な仕様がある場合は、事前に /spec.create を実行することを推奨します。
```

#### 複数タスクモード（tasks.md のタスクを順に依頼）

1. tasks.md を特定する（パス指定 → 指定ディレクトリ内 → `.claude/plans` 配下の最新の順）。見つからない場合は以下を通知して終了

```
エラー: tasks.mdが見つかりません
以下のいずれかを実行してから、再度実行してください:
- /spec.create: 仕様書（requirements/design/tasks）を作成
- /plan.create: 実行計画（plan.md）を作成
```

2. 未完了のタスク（`- [ ]` 形式のチェックボックス、または未完了のタスク見出し）を抽出し、タスク数を数える
   - 「Task-3以降」のように開始位置が指定されていればそこから開始する
   - 実行前に対象タスクの一覧をユーザーに提示する
3. 同じディレクトリの requirements.md / design.md があれば読み込む
4. 各タスクを **順番に1件ずつ** 実行する（並列実行はしない）
   - タスクごとにプロンプトファイル（`_<番号>_prompt.md`）を作成し、exec を実行
   - 進捗を `[番号/タスク数] <タスク内容>` の形式で通知
   - 失敗した場合（終了コード != 0）は stderr を確認し、次のタスクに進むか中断するかをユーザーに確認する
5. 全タスク完了後、結果ファイルの「一括実行サマリー」に各タスクの結果をまとめる

各タスクは独立した Codex 実行になるため、前のタスクの結果を次のタスクが参照する必要がある場合は、プロンプトの「実装内容」に前提となる変更内容を記載します。

### review（レビュー）

#### 対象の決定

| target | 動作 |
|---|---|
| ファイル1件 | そのファイルを exec（`read-only`）でレビュー |
| ディレクトリ・複数ファイル | **複数ファイルモード** |
| 指定なし | `codex review` で未コミットの変更をレビュー（使えない場合は `git diff --name-only HEAD` のファイルを複数ファイルモードでレビュー） |

target が存在しない場合は以下を通知して終了します。

```
エラー: レビュー対象が見つかりません: <target>
- ファイルパスが正しいか、作業ディレクトリが正しいか確認してください
使用例: /codex.review src/auth/login.ts, /codex.review src/auth/
```

#### 複数ファイルモード

1. ディレクトリの場合はソースファイルを抽出する（Glob を使用。バイナリ・除外パターンは対象外）
2. 対象が20件を超える場合は、ユーザーに対象の絞り込み（重要なファイルの優先、ディレクトリの分割）を提案する
3. ファイルごとに **順番に1件ずつ** exec（`read-only`）でレビューする
   - 進捗を `[番号/ファイル数] <ファイルパス>` の形式で通知
   - 失敗したファイルは記録して次のファイルに進む
4. 結果ファイルの「一括実行サマリー」に、ファイルごとの評価、指摘件数の集計、High の指摘、全体的な所見をまとめる

レビュー結果は参考情報です。誤検知の可能性があるため、通知時に「最終的な判断は人間が行う」旨を添えます。

### refactor（リファクタリング）

- target（ファイル）は必須です。指定がない、または存在しない場合は以下を通知して終了します

```
エラー: リファクタリング対象のファイルを指定してください
使用例: /codex.refactor src/utils/helper.ts
```

- instruction があればプロンプトの「重点方針」に記載します
- 実行後は `git diff <target>` で差分を確認し、結果ファイルの「サマリー」に変更内容と改善効果を記載します
- 問題があれば `git checkout <target>` で元に戻せることを通知に含めます

### debug（デバッグ）

- target（エラーメッセージ、スタックトレース、再現手順、期待する動作・実際の動作）をプロンプトの「エラー情報」に記載します
- スタックトレースからファイルパスと行番号を抽出し、存在するファイルを「関連ファイル」に記載します
- エラー情報が不足している場合は、実行前に以下を依頼します

```
警告: エラー情報が不足しています
より正確なデバッグのため、以下の情報を提供してください:
- エラーメッセージの全文
- スタックトレース
- エラーが発生する手順
- 期待する動作と実際の動作
```

## エラーハンドリング

### 実行失敗時（終了コード != 0）

```
エラー: Codex実行が失敗しました（終了コード: <exit_code>）
エラー内容:
<stderr の内容>

結果ファイル: <結果ファイルのパス>
```

考えられる原因と対処:

| 原因 | 対処 |
|---|---|
| 存在しないCLIオプション | `codex exec --help` で確認してオプションを外す |
| プロンプトが不明瞭・矛盾している | プロンプトを修正して再実行 |
| 対象が大きすぎる・複雑すぎる | 対象を小さな単位に分割して再実行 |
| 認証エラー | `codex login` の実行をユーザーに依頼する |

### タイムアウト時

```
エラー: Codex実行がタイムアウトしました（10分経過）
処理が中断されました。より小さなタスクに分割して再試行してください。
```

### ファイル出力失敗時

```
エラー: 結果ファイルの出力に失敗しました。
ディレクトリの書き込み権限を確認してください: <出力先>
```

## セキュリティ注意事項

### サンドボックスモードの選択

- **read-only**: レビューやコード分析のみの場合
- **workspace-write**: 実装、リファクタリング、デバッグの場合（推奨）
- **danger-full-access**: システム全体への変更が必要な場合のみ（非推奨。ユーザーの明示的な承認が必要）

### 機密情報

- 「3. 機密情報の除外」のファイルは Codex に渡しません
- プロンプトに認証情報・トークンなどを含めないでください

## 使用例

```
# 実装（単一）
operation: implement
instruction: "ユーザー認証機能を実装してください"

# 実装（複数タスクモード）
operation: implement
target: .claude/plans/ABC-123/2026_0124_1730_45_tasks.md

# レビュー（ディレクトリ）
operation: review
target: src/auth/
instruction: "セキュリティとパフォーマンスに注目"

# リファクタリング
operation: refactor
target: src/utils/helper.ts
instruction: "可読性向上に重点"

# デバッグ
operation: debug
target: "TypeError: Cannot read property 'name' of undefined (src/auth/login.ts:42)"
```

出力ファイルの例:

```
.claude/plans/ABC-123/2026_0124_1730_45_codex_implement_prompt.md
.claude/plans/ABC-123/2026_0124_1730_45_codex_implement_stdout.log
.claude/plans/ABC-123/2026_0124_1730_45_codex_implement.md
.claude/plans/tmp/2026_0124_1735_12_codex_review.md
```

## 注意事項

- ファイル末尾は必ず空行で終わるようにしてください
- 大きなプロンプト・大きな対象は分割を検討してください
- Codexによる変更後は、必ずテストを実行して動作を確認してください
- 機密情報（.env等）がコミットされないよう注意してください
- Codexのバージョンによって動作が異なる可能性があります
