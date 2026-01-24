---
allowed-tools: Read, Bash(codex review:*)
description: Codexにコードレビューを依頼する
---

## タスク

Codexにコードレビューを依頼します。指定されたファイルまたはディレクトリ全体をレビューします。

### 1. レビュー対象の確認

ユーザーが指定したファイルまたはディレクトリを確認します：

```bash
# レビュー対象が指定されている場合
if [ -n "$TARGET" ]; then
    if [ -f "$TARGET" ]; then
        echo "ファイルをレビューします: $TARGET"
    elif [ -d "$TARGET" ]; then
        echo "ディレクトリをレビューします: $TARGET"
    else
        echo "エラー: レビュー対象が見つかりません: $TARGET"
        exit 1
    fi
else
    # 指定がない場合は最近変更されたファイルをレビュー
    echo "最近変更されたファイルをレビューします"
    TARGET=$(git diff --name-only HEAD | head -5)
fi
```

### 2. レビュープロンプトの生成

レビュー観点を含むプロンプトを生成します：

```markdown
# コードレビュー依頼

## レビュー対象
<ファイルパスまたはディレクトリ>

## レビュー観点

### 1. コード品質
- 命名規則が適切か
- コードの可読性
- DRY原則の遵守
- SOLID原則の遵守
- 適切な関数/メソッドの分割

### 2. セキュリティ
- XSS、SQL Injection等の脆弱性
- 機密情報の露出
- 認証・認可の適切性
- 入力値のバリデーション

### 3. パフォーマンス
- 不要な計算の有無
- メモリリークの可能性
- データベースクエリの最適化
- キャッシング戦略

### 4. 可読性・保守性
- コメントの適切性
- 複雑度（Cyclomatic Complexity）
- コードの構造化
- テスタビリティ

### 5. プロジェクト規約
- @~/ai-coding-guide/guides/common.md の遵守
- ファイル末尾の空行
- コメントの言語（日本語/英語）の統一
- インデントとフォーマット

## 指摘形式

各指摘は以下の形式で記述してください:

**[重要度: High/Medium/Low] ファイル名:行番号**
- **問題**: <指摘内容>
- **影響**: <この問題がもたらす影響>
- **改善案**: <具体的な改善方法>

## 出力形式

1. レビューサマリー（全体的な評価）
2. 重要度別の指摘事項
3. 推奨される次のアクション
```

### 3. Codex Review実行

`codex review` コマンドを実行します：

```bash
# タイムスタンプ生成
TIMESTAMP=$(TZ=Asia/Tokyo date +"%Y_%m%d_%H%M_%S")

# 出力ディレクトリ
OUTPUT_DIR=".claude/plans/codex"
mkdir -p "$OUTPUT_DIR"

# Codex Review実行
codex review \
  --sandbox read-only \
  --ask-for-approval on-failure \
  ${TARGET:+--cd "$TARGET"}

# 結果を記録
EXIT_CODE=$?
RESULT_FILE="$OUTPUT_DIR/${TIMESTAMP}_review_result.md"
```

### 4. レビュー結果の整形と保存

レビュー結果をマークダウン形式で保存します：

```markdown
# Codex実行結果: レビュー

## 実行情報

- **実行日時**: $(TZ=Asia/Tokyo date +"%Y年%m月%d日 %H:%M:%S")
- **操作種別**: review
- **レビュー対象**: <対象ファイル/ディレクトリ>
- **終了コード**: $EXIT_CODE

## 実行コマンド

```bash
codex review --sandbox read-only --ask-for-approval on-failure
```

## レビュー結果

<Codexのレビュー結果>

## 指摘事項サマリー

### 重要度: High
- <High指摘の数>件

### 重要度: Medium
- <Medium指摘の数>件

### 重要度: Low
- <Low指摘の数>件

## 次のアクション

指摘事項に基づいて以下の対応を推奨します:
1. High優先度の問題を修正
2. セキュリティ関連の問題を優先的に対処
3. 必要に応じてリファクタリング（/codex.refactorを使用）
```

### 5. ユーザーへの通知

レビュー完了後、結果ファイルのパスと指摘事項の概要を通知します：

```
Codexによるコードレビューが完了しました。

結果ファイル: .claude/plans/codex/<timestamp>_review_result.md

指摘事項:
- High: X件
- Medium: Y件
- Low: Z件

次のステップ:
- 指摘事項を確認してください
- High優先度の問題から修正してください
- 必要に応じて /codex.refactor を実行してください
```

## レビュー観点の詳細

### コード品質
- 変数名、関数名が自己文書化されているか
- マジックナンバーの使用を避けているか
- 早期リターンを活用しているか
- 適切な抽象化レベルか

### セキュリティ
- ユーザー入力のサニタイゼーション
- SQLインジェクション対策
- XSS対策
- CSRF対策
- 機密情報のハードコーディング

### パフォーマンス
- O(n²)以上のアルゴリズムの確認
- 不必要なループの確認
- メモリリークの可能性
- 非同期処理の適切な使用

### 保守性
- 関数の長さ（推奨: 50行以内）
- 引数の数（推奨: 3つ以内）
- ネストの深さ（推奨: 3レベル以内）
- コメントの適切性

## エラーハンドリング

### レビュー対象が見つからない場合

```
エラー: レビュー対象が見つかりません

確認事項:
- ファイルパスが正しいか
- ファイルが存在するか
- 作業ディレクトリが正しいか

使用例:
/codex.review src/auth/login.ts
/codex.review src/auth/
```

### Codex Review実行失敗時

```
エラー: Codex Review実行が失敗しました（終了コード: <code>）

考えられる原因:
- レビュー対象のファイルが大きすぎる
- 対象ディレクトリにアクセスできない
- Codex CLIのバージョンが古い

対処方法:
1. エラー内容を確認: .claude/plans/codex/<timestamp>_review_result.md
2. ファイルを分割してレビュー
3. Codex CLIを最新版に更新: npm update -g codex-cli
```

## 使用例

### 単一ファイルのレビュー

```
/codex.review src/auth/login.ts
```

### ディレクトリ全体のレビュー

```
/codex.review src/auth/
```

### 特定の観点でレビュー

```
/codex.review src/auth/login.ts
セキュリティとパフォーマンスに重点を置いてレビューしてください
```

### 最近の変更のレビュー

```
/codex.review
（レビュー対象を指定しない場合、最近変更されたファイルをレビュー）
```

## 注意事項

- **重要**: レビュー結果は参考情報です。最終的な判断は人間が行ってください
- 大規模なディレクトリのレビューには時間がかかる場合があります
- セキュリティ指摘は特に慎重に確認してください
- false positive（誤検知）の可能性もあるため、各指摘を検証してください
- レビュー結果を元に修正する場合は、テストを必ず実施してください
