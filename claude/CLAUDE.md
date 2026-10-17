# コーディングガイド

## common
@~/ai-coding-guide/guides/common.md

## git
@~/ai-coding-guide/guides/git.md

## github
@~/ai-coding-guide/guides/github.md

## mcp
@~/ai-coding-guide/guides/mcp.md

## jira
@~/ai-coding-guide/guides/jira.md

## frontend
@~/ai-coding-guide/guides/frontend.md

## react
@~/ai-coding-guide/guides/react.md

## storybook
@~/ai-coding-guide/guides/storybook.md

## test
@~/ai-coding-guide/guides/test.md

## pull-request
@~/ai-coding-guide/guides/pull-request.md

## docker
@~/ai-coding-guide/guides/docker.md

## speckit
@~/ai-coding-guide/guides/speckit.md

## plan-spec
@~/ai-coding-guide/guides/plan-spec.md

---

# sub-agent

## 共通
- sub-agentの実行結果は一時的ファイルとしてmdファイルを出力するようにしてください
- Writeツールを持たないsub-agent（組み込みの`Explore`など）を利用した場合は、メインセッションが結果をmdファイルに出力してください

## ファイル読み込み
- 大きなファイルを読み込む必要がある場合は、メインセッションのコンテクストを圧迫しないように、sub-agentを利用してください
