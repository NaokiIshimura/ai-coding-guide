# React

## AIへの指示
gitの利用について以下のルールを厳守してください。

### 注意事項
- MCPを利用してください
- ghコマンドは利用しないでください

### ブランチ命名
- ブランチ名には「feature/」プレフィックスを付けないでください
- チケット番号をそのままブランチ名として使用してください
  - 良い例: `ABC-123`
  - 悪い例: `feature/ABC-123`

### commit
- **重要**: ユーザーが明示的に指示するまでgit commitを実行しないでください
- **重要**: プロジェクト配下の「.claude」「.vscode」「.serena」ディレクトリはコミットしないでください
- コミットメッセージは日本語で記述してください
- コミット時にフォーマッターやpre-commitフックによる指摘があった場合は、その内容を修正してから再度コミットしてください
- **重要**: フォーマッターやpre-commitフックを無効化（--no-verifyオプション等）することは絶対に行わないでください。必ず指摘事項を修正してからコミットを実行してください

### pull request
#### title
- PR名はJIRAチケット名にチケット番号を付与して
  - [チケット番号] チケット名
  - [チケット番号][XXXXX] チケット名 
  - [チケット番号][XXXXX][XXXXX] チケット名 
#### description
- descriptionはtemplateを参考にして  
  - templateの配置バスの例
   - .github/pull_request_template.md
- descriptionは日本語で記述して
- Assigneesに`NaokiIshimura`を設定して
- copilot reviewを有効にして
- copilot reviewのコメントを確認して、指摘事項があったら修正して
