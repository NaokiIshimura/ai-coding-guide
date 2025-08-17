# PR Description Update

現在のブランチの変更内容を基にPRのdescriptionを更新するコマンドです。

## 実行内容

1. 現在のブランチの変更内容を分析
2. git log と git diff を使用してコミット履歴と変更内容を取得
3. 既存のPRのdescriptionを更新

## 対応フォーマット

- JIRAチケット形式のタイトル: `[チケット番号] チケット名`
- 日本語でのdescription記述
- PRテンプレートに基づく構成

## 実行方法

```bash
# 現在のブランチの変更内容を分析してPR descriptionを更新
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