---
allowed-tools: Read, Bash(codex:*)
description: Codexに実装を依頼する
---

## タスク

Codexに実装を依頼します。requirements.md、design.md、tasks.mdがある場合はそれらを読み込んで、実装プロンプトに含めます。

### 1. 仕様ファイルの確認

以下のファイルを確認します：

```bash
# 最新の仕様ファイルを探す
REQUIREMENTS=$(find .claude/plans -name "*requirements.md" -type f | sort -r | head -1)
DESIGN=$(find .claude/plans -name "*design.md" -type f | sort -r | head -1)
TASKS=$(find .claude/plans -name "*tasks.md" -type f | sort -r | head -1)
```

### 2. 実装プロンプトの生成

仕様ファイルの内容を読み込み、プロンプトを生成します：

```markdown
# 実装タスク

## 要件
<requirements.mdの内容（存在する場合）>

## 設計
<design.mdの内容（存在する場合）>

## 実装するタスク
<tasks.mdの内容またはユーザー指示>

## 注意事項
- プロジェクトのコーディング規約に従ってください
- @~/ai-coding-guide/guides/common.md のルールを遵守してください
- テスト可能なコードを記述してください
- エラーハンドリングを適切に実装してください
- ファイル末尾は空行で終わるようにしてください
- 周辺のコードを参考にして、コメントの言語（日本語・英語）を判断してください

## 出力形式
実装したファイルのパスと主な変更内容を報告してください。
```

### 3. Codex実行

`codex` スキルを使用して実装を依頼します。

**実行コマンド**:

```bash
# タイムスタンプ生成
TIMESTAMP=$(TZ=Asia/Tokyo date +"%Y_%m%d_%H%M_%S")

# 出力ディレクトリ
OUTPUT_DIR=".claude/plans/codex"
mkdir -p "$OUTPUT_DIR"

# Codex実行
codex exec \
  --model auto \
  --sandbox workspace-write \
  --ask-for-approval on-failure \
  "$PROMPT"

# 結果を記録
EXIT_CODE=$?
RESULT_FILE="$OUTPUT_DIR/${TIMESTAMP}_implement_result.md"
```

### 4. 実行結果の整形と保存

実行結果をマークダウン形式で保存します：

```markdown
# Codex実行結果: 実装

## 実行情報

- **実行日時**: $(TZ=Asia/Tokyo date +"%Y年%m月%d日 %H:%M:%S")
- **操作種別**: implement
- **終了コード**: $EXIT_CODE

## 実行コマンド

```bash
codex exec --model auto --sandbox workspace-write --ask-for-approval on-failure
```

## プロンプト

<生成したプロンプト>

## 実行結果

<Codexの出力>

## 次のアクション

- 実装されたコードを確認
- 必要に応じてテストを実行
- コードレビューを実施（/codex.reviewを使用）
```

### 5. ユーザーへの通知

実行完了後、結果ファイルのパスを通知します：

```
Codexによる実装が完了しました。

結果ファイル: .claude/plans/codex/<timestamp>_implement_result.md

次のステップ:
- 実装されたコードを確認してください
- テストを実行してください: npm test
- レビューを依頼してください: /codex.review
```

## エラーハンドリング

### 仕様ファイルが見つからない場合

仕様ファイルが存在しない場合は、ユーザーの指示のみを使用します：

```
注意: requirements.md、design.md、tasks.mdが見つかりませんでした。
ユーザーの指示のみで実装を進めます。

詳細な仕様がある場合は、事前に /spec.create を実行することを推奨します。
```

### Codex実行失敗時

```
エラー: Codex実行が失敗しました（終了コード: <code>）

考えられる原因:
- プロンプトが不明瞭または矛盾している
- 必要なファイルが存在しない
- 依存関係が不足している

対処方法:
1. エラー内容を確認: .claude/plans/codex/<timestamp>_implement_result.md
2. プロンプトを修正して再実行
3. 必要に応じて仕様ファイルを更新
```

## 使用例

### 基本的な使用方法

```
/codex.implement ユーザー認証機能を実装してください
```

### 詳細な指示を含む場合

```
/codex.implement
以下の機能を実装してください:
- ログイン画面の作成
- JWT認証の実装
- ログアウト機能
- セッション管理
```

### 既存コードの拡張

```
/codex.implement
src/auth/login.tsに以下の機能を追加してください:
- パスワードリセット機能
- 2要素認証のサポート
```

## 注意事項

- **重要**: 実装後は必ず動作確認とテストを実施してください
- 機密情報（.env等）がコミットされないよう注意してください
- 大規模な実装の場合は、タスクを分割して順次実行することを推奨します
- Codexによる変更は、ユーザーの明示的な指示があるまでコミットしないでください
