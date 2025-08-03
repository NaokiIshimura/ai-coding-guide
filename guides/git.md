# React

## AIへの指示
gitの利用について以下のルールを厳守してください。

### commit
- コミットメッセージは日本語で記述してください
- コミット時にフォーマッターやpre-commitフックによる指摘があった場合は、その内容を修正してから再度コミットしてください
- **重要**: フォーマッターやpre-commitフックを無効化（--no-verifyオプション等）することは絶対に行わないでください。必ず指摘事項を修正してからコミットを実行してください

### pull request
#### title
- PR名はJIRAチケット名にチケット番号を付与して
  - [チケット番号]チケット名
    - [XXXXX] XXXXX 
    - [XXXXX][XXXXX] XXXXX 
    - [XXXXX][XXXXX][XXXXX] XXXXX 
#### description
- descriptionはtemplateを参考にして  
  - templateの配置バスの例
   - .github/pull_request_template.md
- descriptionは日本語で記述して
- Assigneesに`NaokiIshimura`を設定して
- copilot reviewを有効にして
- copilot reviewのコメントを確認して、指摘事項があったら修正して
