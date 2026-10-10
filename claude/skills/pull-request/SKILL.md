---
description: プルリクエストを操作する（create, update, comment resolve, review, CI wait）。PRの作成・title/descriptionの更新・レビューコメントへの対応と返信・PRレビューの投稿・CI完了の待機を行う時、他のskillからPR操作の手順として呼ばれた時に使用する
allowed-tools: Bash(gh pr *), Bash(gh api *), Bash(gh repo view *), Bash(git *), Bash(osascript *), mcp__github, Edit, Read, Glob
---

## 概要

GitHubプルリクエストの操作を行います。PR作成、更新、コメント対応、レビュー投稿、CI待機を実行できます。
PR操作の手順・ルールはこのskillに一本化しています（`/pr.create` などの呼び出し用skillはこのskillを使います）。

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在のブランチのPR: !`gh pr view --json number,title,url,state 2>/dev/null || echo "PRなし"`

## 共通ルール

git / pull-request ガイドのルールに従ってください。主なルールは以下のとおりです。

| 項目 | ルール |
|------|--------|
| 利用ツール | GitHub MCP（`mcp__github`）もしくは `gh` コマンドを利用する |
| title | `[チケット番号] チケット名`（タグがある場合は `[チケット番号][XXXXX] チケット名`） |
| description | PRテンプレートに従い、日本語で記述する。サマリと詳細を記載し、適度に表（テーブル）を利用する |
| Assignees | `NaokiIshimura` を設定する |
| コメント返信 | Claude Code による返信であることを明記する |
| レビュー投稿 | インラインコメント付きのPR reviewとして1回で投稿する（「5. レビュー投稿」参照） |

### デフォルトブランチ（PRのベース）の取得

`origin/master` などを決め打ちせず、以下で取得してください。

```bash
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

### PRテンプレート

以下の順に探し、見つかったテンプレートの構成に従ってdescriptionを作成してください。

- `.github/pull_request_template.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `docs/pull_request_template.md`
- `.github/PULL_REQUEST_TEMPLATE/` 配下

テンプレートがない場合は `${CLAUDE_SKILL_DIR}/templates/description.md` を Read ツールで読み込み、その構成を使用してください。

## 対応操作

### 1. PR作成（create）

現在のブランチからプルリクエストを作成します。

**実施手順:**

1. 既存PRを確認
   ```bash
   gh pr view --json number,url,state
   ```
   - オープンなPRが既にある場合は「2. PR更新」を実施する
2. ブランチがリモートにプッシュされていることを確認（未プッシュならgit skillのpush手順でプッシュ）
3. 変更内容を把握
   ```bash
   git log --oneline <デフォルトブランチ>..HEAD
   git diff --stat origin/<デフォルトブランチ>...HEAD
   ```
4. titleを作成
   - チケット番号はブランチ名から取得する（ブランチ名 = チケット番号）
   - チケット名はJIRAチケットから取得する（Atlassian MCP。取得できない場合はユーザーに確認）
5. PRテンプレートに従ってdescriptionを作成
6. PRを作成
   - GitHub MCP を利用する場合: PR作成後、Assigneesに `NaokiIshimura` を設定する
   - `gh` コマンドを利用する場合:
     ```bash
     gh pr create \
       --base <デフォルトブランチ> \
       --title "[ABC-123] チケット名" \
       --assignee NaokiIshimura \
       --body-file - <<'EOF'
     （description）
     EOF
     ```
7. 作成したPRのURLを報告

### 2. PR更新（update）

既存のプルリクエストのtitleやdescriptionを、現在のブランチの変更内容に合わせて更新します。

**実施手順:**

1. 対象PRと現在のtitle / descriptionを取得
   ```bash
   gh pr view --json number,title,body,baseRefName,url
   ```
2. 変更内容を把握（ベースはPRの `baseRefName` を使用）
   ```bash
   git log --oneline origin/<baseRefName>..HEAD
   git diff --stat origin/<baseRefName>...HEAD
   ```
3. 共通ルールとPRテンプレートに従ってtitle / descriptionを作成
   - 既存descriptionに人が追記した内容（スクリーンショット、補足など）は残す
4. 更新
   ```bash
   gh pr edit <PR番号> --title "[ABC-123] チケット名" --body-file - <<'EOF'
   （description）
   EOF
   ```
   - Assigneesが未設定の場合は `gh pr edit <PR番号> --add-assignee NaokiIshimura`

### 3. コメント対応（comment resolve）

PRのレビューコメントを確認し、指摘に基づいて修正を実施します。

**実施手順:**

1. **コメント取得**
   - GitHub MCP、または以下の `gh` コマンドを使用
   ```bash
   # PRへのコメントとレビュー本文
   gh pr view <PR番号> --comments

   # インラインのレビューコメント（id, path, line を含む）
   gh api repos/{owner}/{repo}/pulls/<PR番号>/comments --paginate \
     --jq '.[] | {id, path, line, user: .user.login, body, in_reply_to_id}'

   # 未解決のレビュースレッド
   gh api graphql -F owner='{owner}' -F name='{repo}' -F number=<PR番号> -f query='
     query($owner: String!, $name: String!, $number: Int!) {
       repository(owner: $owner, name: $name) {
         pullRequest(number: $number) {
           reviewThreads(first: 100) {
             nodes {
               isResolved
               path
               line
               comments(first: 20) { nodes { databaseId author { login } body } }
             }
           }
         }
       }
     }' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved | not)'
   ```

2. **指摘内容を分析**
   - 各コメントの内容を理解し、修正が必要な箇所を特定
   - 対応しない（できない）指摘は、理由を整理する

3. **修正を実施**
   - 指摘された内容に基づいてコードを修正
   - 必要に応じてテストも更新

4. **修正内容をコミット・プッシュ**
   - git skillのcommit / push手順に従う
   - コミットメッセージにはレビューコメントへの対応であることを明記

5. **コメントに返信**
   - 返信の冒頭に Claude Code による返信であることを明記する
   - 対応内容（または対応しない理由）と、対応したコミットを記載する
   ```bash
   # インラインコメントへの返信
   gh api repos/{owner}/{repo}/pulls/<PR番号>/comments/<コメントid>/replies -X POST \
     -f body="このコメントは Claude Code による返信です。
   <対応内容>（<コミットSHA>）"

   # PRへのコメント（issue comment）への返信
   gh pr comment <PR番号> --body "このコメントは Claude Code による返信です。
   <対応内容>"
   ```

### 4. PRステータス確認

```bash
# PR一覧表示
gh pr list

# PR詳細表示
gh pr view <PR番号>

# PRの差分
gh pr diff <PR番号>

# CIの状態
gh pr checks <PR番号>
```

### 5. レビュー投稿（review）

PRにレビューを投稿する場合は、以下のルールを厳守してください。

- レビューは返信スレッドが立つインラインコメント付きのPR reviewとして1回で投稿する
  - `gh pr review --body` のみの、本文だけのreviewは不可（返信スレッドが立たないため）
  - 通常のPRコメント（issue comment）も不可
- 総評・観点ごとの結果は、修正の主要な変更行へのインラインコメントにする
- 個別の指摘（must / should / nit）は該当行へのインラインコメントにする
- review body には「Claude Code によるレビュー」である旨と総合評価のみ記載する
- event は `COMMENT` にする（`APPROVE` / `REQUEST_CHANGES` は使わない）
- インラインコメントの path / line は `gh pr diff` で実際の差分を確認して指定する（推測しない）

```bash
# headのコミットSHAを取得
gh pr view <PR番号> --json headRefOid --jq .headRefOid

# レビューを投稿
gh api repos/{owner}/{repo}/pulls/<PR番号>/reviews -X POST --input payload.json
```

payload.json
```json
{
  "commit_id": "<headのコミットSHA>",
  "event": "COMMENT",
  "body": "このレビューは Claude Code によるものです。総合評価: LGTM",
  "comments": [
    { "path": "<ファイルパス>", "line": 10, "side": "RIGHT", "body": "<総評・観点ごとの結果>" },
    { "path": "<ファイルパス>", "line": 20, "side": "RIGHT", "body": "<指摘>" }
  ]
}
```

- payload.json はプロジェクトのルート直下に置かず、一時ディレクトリに作成する
- 誤って本文のみのreviewを投稿した場合は、削除できないため、インラインコメント付きのreviewを投稿し直したうえで、旧reviewの本文を差し替え先の案内に更新する
  ```bash
  gh api repos/{owner}/{repo}/pulls/<PR番号>/reviews/<review_id> -X PUT -f body="<差し替え先の案内>"
  ```

### 6. CI待機（ci wait）

現在のブランチのPRに関連するCIの完了を待機し、結果を通知します。

**実施手順:**

1. PRを特定
   ```bash
   gh pr view --json number,title,url
   ```
   - PRが見つからない場合はその旨を報告して終了
2. 現在のchecks状態を確認
   ```bash
   gh pr checks <PR番号>
   ```
   - 全てのchecksが完了済みの場合は手順4へ進む
3. CI完了まで待機（ユーザーには「CI完了を待機中...」と伝える）
   - **Monitorツールが利用できる場合**: Monitorツールで以下のスクリプトをバックグラウンド監視し、完了したcheckごとに通知を受ける（`timeout_ms` は最大値を指定し、期限切れになったら再設定する）。待機中は他の作業を続けてよい
     ```bash
     prev=""
     empty=0
     while true; do
       s=$(gh pr checks <PR番号> --json name,bucket,link 2>/dev/null || echo '[]')
       cur=$(jq -r '.[] | select(.bucket!="pending") | "\(.name): \(.bucket) \(.link)"' <<<"$s" | sort)
       comm -13 <(echo "$prev") <(echo "$cur")
       prev=$cur
       jq -e 'length > 0 and all(.bucket!="pending")' <<<"$s" >/dev/null && echo "CI_DONE" && break
       # checksが登録されないまま約5分経過したらCIなしとして終了
       if jq -e 'length == 0' <<<"$s" >/dev/null; then
         empty=$((empty + 1))
         [ "$empty" -ge 10 ] && echo "NO_CHECKS" && break
       fi
       sleep 30
     done
     ```
   - `NO_CHECKS` で終了した場合は、CIが設定されていない旨を報告して終了する
   - **Monitorツールが利用できない場合**: `--watch` オプションで完了まで待機する
     ```bash
     gh pr checks <PR番号> --watch --fail-fast
     ```
4. 結果を通知
   - ターミナルにchecksの結果一覧を表示し、失敗したchecksがある場合はcheck名とURLを表示する
     ```bash
     gh pr checks <PR番号> --json name,bucket,link --jq '.[] | select(.bucket=="fail" or .bucket=="cancel")'
     ```
   - macOSの通知を送る

     **成功時:**
     ```bash
     osascript -e 'display notification "全てのCIチェックが成功しました" with title "CI完了 ✅" sound name "Glass"'
     ```

     **失敗時:**
     ```bash
     osascript -e 'display notification "CIチェックが失敗しました" with title "CI失敗 ❌" sound name "Basso"'
     ```

## タスク

ユーザーの指示（または呼び出し元skillの指示）に基づいて、上記のPR操作を実行してください。

操作前に現在の状態を確認し、適切な操作を選択してください。
