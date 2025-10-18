---
allowed-tools: Bash(mkdir:*), Bash(ls:*), Bash(git:*)
description: .claude/tasks配下に指定した名前のディレクトリを作成する
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在のディレクトリ: !`pwd`
- 既存のtasksディレクトリ: !`ls -la .claude/tasks/ 2>/dev/null || echo "tasks directory not found"`

## タスク

`.claude/tasks`配下に指定された名前のディレクトリを作成してください。

### 実施手順

1. **ディレクトリ名の確認**
   - ユーザーに作成するディレクトリ名を確認
   - ディレクトリ名が未指定の場合は質問する
   - チケット番号（例: ABC-123）またはtmpなどの任意の名前を受け付ける

2. **ディレクトリの確認と作成**
   - `.claude/tasks`ディレクトリが存在しない場合は作成
   - 指定されたディレクトリが既に存在する場合は通知
   - 存在しない場合は新規作成

3. **作成結果の報告**
   - 作成したディレクトリの絶対パス
   - ディレクトリの一覧表示（`ls -la .claude/tasks/`）

### 使用例

```bash
# チケット番号でディレクトリを作成
/task-dir-create ABC-123

# 一時作業用ディレクトリを作成
/task-dir-create tmp

# 任意の名前でディレクトリを作成
/task-dir-create feature-investigation
```

### 注意事項

- ディレクトリ名には有効なファイルシステム文字のみを使用してください
- 既存のディレクトリを上書きしません
- 作成したディレクトリは`.claude/.gitignore`の設定に従ってgit管理対象外となります
- このディレクトリは一時ファイルの整理に使用されます
