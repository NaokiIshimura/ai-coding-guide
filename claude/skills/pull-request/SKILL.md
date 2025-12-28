---
description: プルリクエストを操作する（create, update, comment resolve）
allowed-tools: Bash(gh pr:*), Bash(git:*), mcp_github, Edit, MultiEdit, Read, Glob
---

## 概要

GitHubプルリクエストの操作を行います。PR作成、更新、コメント対応等の操作を実行できます。

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- リモートとの差分: !`git log origin/master..HEAD --oneline 2>/dev/null || git log origin/main..HEAD --oneline 2>/dev/null || echo "リモートブランチなし"`

## 対応操作

### 1. PR作成（create）

現在のブランチからプルリクエストを作成します。

**実施手順:**
1. PRテンプレート（`.github/pull_request_template.md`）を確認
2. テンプレートに従ってdescriptionを作成
3. GitHub MCP または `gh` コマンドでPR作成

**PRタイトルの形式:**
```
[チケット番号] チケット名
[チケット番号][XXXXX] チケット名
```

**設定:**
- Assigneesに `NaokiIshimura` を設定
- Copilot review を有効化

```bash
# gh コマンドでPR作成
gh pr create --title "タイトル" --body "説明"
```

### 2. PR更新（update）

既存のプルリクエストのタイトルやdescriptionを更新します。

```bash
# タイトル更新
gh pr edit --title "新しいタイトル"

# description更新
gh pr edit --body "新しい説明"

# 両方更新
gh pr edit --title "タイトル" --body "説明"
```

### 3. コメント対応（comment resolve）

PRのレビューコメントを確認し、指摘に基づいて修正を実施します。

**実施手順:**

1. **コメント取得**
   ```bash
   gh pr view --comments
   gh pr review --comments
   ```

2. **指摘内容を分析**
   - 各コメントの内容を理解
   - 修正が必要な箇所を特定

3. **修正を実施**
   - 指摘された内容に基づいてコードを修正
   - 必要に応じてテストも更新

4. **修正内容をコミット**
   - 修正内容を明確に記載したコミットメッセージ
   - レビューコメントへの対応であることを明記

### 4. PRステータス確認

```bash
# PR一覧表示
gh pr list

# PR詳細表示
gh pr view

# PRコメント表示
gh pr view --comments
```

## 注意事項

- GitHub MCP が利用可能な場合は優先的に使用
- descriptionは日本語で記述
- PRテンプレートがある場合はそれに従う
- 全てのレビューコメントに対応する

## タスク

ユーザーの指示に基づいて、上記のPR操作を実行してください。

操作前に現在の状態を確認し、適切な操作を選択してください。
