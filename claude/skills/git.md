---
description: gitを操作する（branch, commit, push, pull）
allowed-tools: Bash(git:*)
---

## 概要

gitリポジトリの操作を行います。ブランチ管理、コミット作成、プッシュ、プル等の操作を実行できます。

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- ローカルブランチ一覧: !`git branch`
- 現在のステータス: !`git status -sb`
- 最近のコミット: !`git log --oneline -5`

## 対応操作

### 1. ブランチ操作（branch）

新しいブランチの作成、切り替え、一覧表示を行います。

```bash
# 新規ブランチ作成・切り替え
git checkout -b <ブランチ名>
git switch -c <ブランチ名>

# ブランチ切り替え
git checkout <ブランチ名>
git switch <ブランチ名>

# ブランチ一覧
git branch
git branch -r  # リモート
git branch -a  # 全て
```

**命名規則:**
- `feature/` プレフィックスは付けない
- チケット番号をそのままブランチ名として使用
  - 良い例: `ABC-123`
  - 悪い例: `feature/ABC-123`

### 2. コミット操作（commit）

変更をステージングし、コミットを作成します。

```bash
# ステージング
git add <ファイル>
git add .

# コミット
git commit -m "コミットメッセージ"

# 差分確認
git diff
git diff --staged
```

**注意事項:**
- コミットメッセージは日本語で記述
- `.claude`、`.vscode`、`.serena` ディレクトリはコミットしない
- `--no-verify` オプションは使用しない

### 3. プッシュ操作（push）

ローカルの変更をリモートリポジトリに送信します。

```bash
# プッシュ
git push
git push -u origin <ブランチ名>  # 新規ブランチの場合
```

### 4. プル操作（pull）

リモートリポジトリから最新の変更を取得します。

```bash
# プル
git pull
git pull origin <ブランチ名>

# フェッチ
git fetch
git fetch --all
```

**コンフリクト発生時:**
- コンフリクトを確認
- 適切に解決
- 解決後にコミット

## タスク

ユーザーの指示に基づいて、上記のgit操作を実行してください。

操作前に現在の状態を確認し、必要に応じてユーザーに確認を取ってから実行してください。
