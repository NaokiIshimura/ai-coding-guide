# PR Description Update

現在のブランチの変更内容を基にPRのtitle, descriptionを更新するコマンドです。

## 実行内容

1. 現在のブランチの変更内容を分析
2. git log と git diff を使用してコミット履歴と変更内容を取得
3. 既存のPRのtitle, descriptionを更新

## title
- バージョン番号形式
  - [バージョン番号] 機能名
- JIRAチケット形式
  - [チケット番号] チケット名
- 日本語でのdescription記述

## description
- PRテンプレートに基づく構成

## 実行方法

```bash
# 現在のブランチの変更内容を分析してPR title, descriptionを更新
git log --oneline -10
git diff origin/master...HEAD
gh pr edit --body-file <(cat <<'EOF'
## 概要
[変更内容の概要]

## 変更詳細
[具体的な変更内容]

## テスト
[テスト内容]

## その他
[その他の注意事項]
EOF
)
```