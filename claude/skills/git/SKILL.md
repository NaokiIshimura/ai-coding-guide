---
description: gitを操作する（branch, commit, push, pull, デフォルトブランチへの切り替え）。ブランチ作成・コミット・プッシュ・プルなどのgit操作を行う時、他のskillからgit操作の手順として呼ばれた時に使用する
allowed-tools: Bash(git *), Bash(gh repo view *)
---

## 概要

gitリポジトリの操作を行います。ブランチ管理、コミット作成、プッシュ、プル、デフォルトブランチへの切り替えを実行できます。
git操作の手順・ルールはこのskillに一本化しています（`/git.commit` などの呼び出し用skillはこのskillを使います）。

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- ローカルブランチ一覧: !`git branch`
- 現在のステータス: !`git status -sb`
- 最近のコミット: !`git log --oneline -5`

## 共通ルール

gitガイドのルールに従ってください。主なルールは以下のとおりです。

| 項目 | ルール |
|------|--------|
| ブランチ名 | チケット番号をそのまま使用し、`feature/` などのプレフィックスは付けない |
| コミット | 署名付きコミット（`git commit -S`）を行う |
| コミットメッセージ | 日本語で記述する |
| コミット対象外 | `.claude`、`.vscode`、`.serena` ディレクトリはコミットしない |
| pre-commit | `--no-verify` などでフォーマッターやpre-commitフックを無効化しない。指摘を修正してから再度コミットする |
| GitHub操作 | GitHub MCP もしくは `gh` コマンドを利用する |

## 対応操作

### 1. ブランチ操作（branch）

新しいブランチの作成、切り替え、一覧表示を行います。

```bash
# 新規ブランチ作成・切り替え
git switch -c <ブランチ名>

# ブランチ切り替え
git switch <ブランチ名>

# ブランチ一覧
git branch
git branch -r  # リモート
git branch -a  # 全て
```

**命名規則:**
- チケット番号をそのままブランチ名として使用
  - 良い例: `ABC-123`
  - 悪い例: `feature/ABC-123`

**注意事項:**
- ブランチ切り替え前に未コミットの変更がある場合は、ユーザーに確認してください

### 2. コミット操作（commit）

変更を確認し、署名付きコミットを作成します。

**実施手順:**

1. 変更内容を確認
   ```bash
   git status
   git diff
   git diff --staged
   ```
2. コミット対象のファイルを個別に指定してステージング
   - `git add .` や `git add -A` で一括ステージングしない
   - `.claude`、`.vscode`、`.serena` 配下のファイルはステージングしない
   ```bash
   git add <ファイル> <ファイル>
   ```
3. 署名付きでコミット（メッセージは日本語）
   ```bash
   git commit -S -m "$(cat <<'EOF'
   コミットメッセージ（日本語）

   詳細（必要な場合）
   EOF
   )"
   ```
4. コミット結果を確認
   ```bash
   git status
   git log --oneline -1
   ```

**pre-commitフックで失敗した場合:**
- `--no-verify` は使用しない
- 指摘内容を修正し、修正したファイルを再度ステージングしてからコミットし直す

### 3. プッシュ操作（push）

ローカルの変更をリモートリポジトリに送信します。

```bash
# プッシュ対象のコミットを確認
git status -sb

# 上流ブランチが設定済みの場合
git push

# 新規ブランチ（上流ブランチ未設定）の場合
git push -u origin HEAD
```

**注意事項:**
- `--force` は使用しない。必要な場合はユーザーに確認し、`--force-with-lease` を使用する

### 4. プル操作（pull）

リモートリポジトリから最新の変更を取得します。

```bash
# プル
git pull

# フェッチ
git fetch
git fetch --all --prune
```

**コンフリクト発生時:**
- コンフリクトしているファイルを確認（`git status`）
- 適切に解決し、解決内容をユーザーに報告
- 解決後に共通ルールに従ってコミット

### 5. デフォルトブランチへの切り替え（switch default）

デフォルトブランチ（master / main など）に切り替えて最新の変更を取得します。

1. 未コミットの変更がある場合は警告し、コミットまたはstashするかユーザーに確認
2. デフォルトブランチ名を取得
   ```bash
   gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
   # gh が利用できない場合
   git remote set-head origin --auto
   git symbolic-ref --short refs/remotes/origin/HEAD  # origin/<ブランチ名> の形式で返る
   ```
3. デフォルトブランチに切り替えて最新を取得
   ```bash
   git switch <デフォルトブランチ名>
   git pull
   ```

## タスク

ユーザーの指示（または呼び出し元skillの指示）に基づいて、上記のgit操作を実行してください。

操作前に現在の状態を確認してから実行してください。
