---
description: Codex CLIを実行し、結果をマークダウンファイルに記録する
allowed-tools: Bash(codex:*), Read, Write
---

# Codex実行スキル

## 概要

Codex CLIを使用してコード実装、レビュー、リファクタリング、デバッグを実行し、結果をマークダウンファイルに記録します。

## コンテキスト

- 現在のディレクトリ: !`pwd`
- Codexバージョン: !`codex --version 2>/dev/null || echo "Not installed"`
- タイムスタンプ（日本時間）: !`TZ=Asia/Tokyo date +"%Y_%m%d_%H%M_%S"`

## 入力パラメータ

このスキルは、ユーザーからの指示に基づいて以下のパラメータを受け取ります：

- **operation**: 操作種別（implement, review, refactor, debug）
- **prompt**: Codexに送信するプロンプト
- **model**: 使用するモデル（オプション、デフォルト: auto）
- **sandbox_mode**: サンドボックスモード（デフォルト: workspace-write）
  - `read-only`: 読み取り専用
  - `workspace-write`: ワークスペース書き込み可
  - `danger-full-access`: フルアクセス（明示的承認必要）
- **approval_policy**: 承認ポリシー（デフォルト: on-failure）
  - `untrusted`: 信頼されたコマンドのみ自動実行
  - `on-failure`: 失敗時のみ承認を求める
  - `on-request`: モデルが判断
  - `never`: 承認を求めない
- **working_dir**: 作業ディレクトリ（オプション）
- **enable_search**: Web検索を有効化（デフォルト: false）

## タスク

以下の手順でCodexを実行し、結果を記録します：

### 1. Codex CLIの利用可能性を確認

```bash
# Codexがインストールされているか確認
if ! command -v codex &> /dev/null; then
    echo "エラー: Codex CLIがインストールされていません"
    echo "インストール方法: https://codex.cli/install"
    exit 1
fi
```

### 2. タイムスタンプを生成（日本時間）

```bash
TIMESTAMP=$(TZ=Asia/Tokyo date +"%Y_%m%d_%H%M_%S")
```

### 3. 出力ディレクトリを作成

```bash
OUTPUT_DIR=".claude/plans/codex"
mkdir -p "$OUTPUT_DIR"
```

### 4. 除外ファイルパターンの確認

以下のファイルはCodexに送信しません：

```
.env
.env.*
*credentials*
*secret*
*password*
.claude/**
.vscode/**
.serena/**
node_modules/**
.git/**
```

**重要**: プロンプトに機密情報を含めないように注意してください。

### 5. Codexコマンドを構築

操作種別に応じてコマンドを構築します：

#### 実装・リファクタリング・デバッグ（exec）

```bash
codex exec \
  --model "${MODEL:-auto}" \
  --sandbox "${SANDBOX_MODE:-workspace-write}" \
  --ask-for-approval "${APPROVAL_POLICY:-on-failure}" \
  ${WORKING_DIR:+--cd "$WORKING_DIR"} \
  ${ENABLE_SEARCH:+--search} \
  "$PROMPT"
```

#### レビュー（review）

```bash
codex review \
  --sandbox read-only \
  --ask-for-approval on-failure \
  ${WORKING_DIR:+--cd "$WORKING_DIR"}
```

### 6. Codexを実行

実行開始時刻を記録し、Codexを実行します：

```bash
START_TIME=$(date +%s)

# 実行（標準出力・標準エラー出力を記録）
codex exec <options> "$PROMPT" > /tmp/codex_stdout.txt 2> /tmp/codex_stderr.txt
EXIT_CODE=$?

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
```

### 7. 実行結果をマークダウンに整形

以下の形式で結果ファイルを作成します：

```markdown
# Codex実行結果: <操作種別>

## 実行情報

- **実行日時**: YYYY年MM月DD日 HH:MM:SS（日本時間）
- **操作種別**: <operation>
- **実行時間**: <duration>秒
- **終了コード**: <exit_code>

## 実行コマンド

```bash
<実行したコマンド>
```

## プロンプト

```
<送信したプロンプト>
```

## 実行結果

### 標準出力

```
<stdout内容>
```

### 標準エラー出力

```
<stderr内容（あれば）>
```

## サマリー

<実行結果の要約>

## 次のアクション

<推奨される次のステップ>
```

### 8. 結果ファイルを出力

```bash
RESULT_FILE="$OUTPUT_DIR/${TIMESTAMP}_${OPERATION}_result.md"
```

### 9. ユーザーに通知

実行結果ファイルのパスをユーザーに通知します：

```
Codex実行が完了しました。
結果ファイル: <結果ファイルのパス>
終了コード: <exit_code>
```

## エラーハンドリング

### Codex CLIが利用できない場合

```
エラー: Codex CLIがインストールされていません。
以下のコマンドでインストールしてください:
npm install -g codex-cli
```

### 実行失敗時（終了コード != 0）

```
エラー: Codex実行が失敗しました（終了コード: <exit_code>）
エラー内容を確認してください:
<stderr内容>

結果ファイル: <結果ファイルのパス>
```

### タイムアウト時

デフォルトのタイムアウトは10分（600秒）です。タイムアウト発生時：

```
エラー: Codex実行がタイムアウトしました（10分経過）
処理が中断されました。より小さなタスクに分割して再試行してください。
```

### ファイル出力失敗時

```
エラー: 結果ファイルの出力に失敗しました。
ディレクトリの書き込み権限を確認してください: .claude/plans/codex/
```

## セキュリティ注意事項

### 機密情報の除外

以下のファイルパターンは**絶対に**Codexに送信しないでください：

- 環境変数ファイル: `.env`, `.env.*`
- 認証情報: `*credentials*`, `*secret*`, `*password*`, `*token*`
- 設定ディレクトリ: `.claude/**`, `.vscode/**`, `.serena/**`
- 依存関係: `node_modules/**`, `vendor/**`
- バージョン管理: `.git/**`

### サンドボックスモードの選択

- **read-only**: レビューやコード分析のみの場合
- **workspace-write**: 実装、リファクタリング、デバッグの場合（推奨）
- **danger-full-access**: システム全体への変更が必要な場合のみ（非推奨）

### 承認ポリシーの選択

- **on-failure**: 失敗時のみユーザーに確認（推奨）
- **untrusted**: 信頼されたコマンドのみ自動実行（安全）
- **on-request**: モデルが判断（バランス）
- **never**: 常に自動実行（注意が必要）

## 使用例

### 実装依頼

```
operation: implement
prompt: "ユーザー認証機能を実装してください。要件はrequirements.mdを参照。"
sandbox_mode: workspace-write
approval_policy: on-failure
```

### コードレビュー

```
operation: review
prompt: "src/auth/login.tsをレビューしてください。セキュリティとパフォーマンスに注目。"
sandbox_mode: read-only
approval_policy: on-failure
```

### リファクタリング

```
operation: refactor
prompt: "src/utils/helper.tsのコード品質を改善してください。"
sandbox_mode: workspace-write
approval_policy: on-failure
```

### デバッグ

```
operation: debug
prompt: "TypeError: Cannot read property 'name' of undefinedを解決してください。"
sandbox_mode: workspace-write
approval_policy: on-failure
```

## 出力ファイルの命名規則

```
.claude/plans/codex/YYYY_MMDD_HHMM_SS_<operation>_result.md
```

**例**:
```
.claude/plans/codex/2026_0124_1730_45_implement_result.md
.claude/plans/codex/2026_0124_1735_12_review_result.md
.claude/plans/codex/2026_0124_1740_28_refactor_result.md
.claude/plans/codex/2026_0124_1745_03_debug_result.md
```

## 注意事項

- ファイル末尾は必ず空行で終わるようにしてください
- 大きなプロンプトの場合は分割を検討してください
- 実行結果ファイルは`.gitignore`で除外されています
- Codexのバージョンによって動作が異なる可能性があります
- 長時間かかる処理は進捗を定期的に確認してください
