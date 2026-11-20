# GitHub

## AIへの指示
GitHubの利用について以下のルールを厳守してください。

### PRコメント内の参照の書き方
- **重要**: PRコメント（review body・インラインコメント・issue comment・PR本文を含む）でコミット番号・チケット番号・issue/PRに言及する際は、クリックでリンクとして動作する形式で記載してください
- コミット: フルSHA、またはMarkdownリンクで記載してください（短縮SHAのみだとリンクにならない場合があるため）
  - 例: `[abc1234](https://github.com/<owner>/<repo>/commit/<フルSHA>)`
- issue / PR: 同一リポジトリなら `#123`、別リポジトリなら `<owner>/<repo>#123` または完全なURLで記載してください
- JIRAチケット: Markdownリンクで記載してください（GitHubのautolink未設定だと `ABC-123` だけではリンクにならないため）
  - 例: `[ABC-123](https://<site>.atlassian.net/browse/ABC-123)`
- コードブロック・インラインコード（バッククォート）内ではリンクにならないため、参照はその外に記載してください

### PRレビューの投稿
- **重要**: レビューは返信スレッドが立つインラインコメント付きのPR reviewとして1回で投稿してください
  - `gh pr review --body` のみの、本文だけのreviewは不可（返信スレッドが立たないため）
  - 通常のPRコメント（issue comment）も不可
- 総評・観点ごとの結果は、修正の主要な変更行へのインラインコメントにしてください
- 個別の指摘（must / should / nit）は該当行へのインラインコメントにしてください
- review body には「Claude Code によるレビュー」である旨と総合評価のみ記載してください
- event は `COMMENT` にしてください（`APPROVE` / `REQUEST_CHANGES` は使わない）
- インラインコメントの path / line は `gh pr diff` で実際の差分を確認して指定してください（推測しない）

#### コマンド
```
$ gh api repos/<owner>/<repo>/pulls/<PR番号>/reviews -X POST --input payload.json
```

payload.json
```
{
  "commit_id": "<headのコミットSHA>",
  "event": "COMMENT",
  "body": "このレビューは Claude Code によるものです。総合評価: LGTM",
  "comments": [
    { "path": "<ファイルパス>", "line": <行番号>, "side": "RIGHT", "body": "<総評・観点ごとの結果>" },
    { "path": "<ファイルパス>", "line": <行番号>, "side": "RIGHT", "body": "<指摘>" }
  ]
}
```

#### 誤って本文のみのreviewを投稿した場合
- 投稿済みのreviewは削除できないため、インラインコメント付きのreviewを投稿し直したうえで、旧reviewの本文を差し替え先の案内に更新してください
  ```
  $ gh api repos/<owner>/<repo>/pulls/<PR番号>/reviews/<review_id> -X PUT -f body="<差し替え先の案内>"
  ```
