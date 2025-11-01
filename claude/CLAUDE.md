# コーディングガイド

## common
@~/ai-coding-guide/guides/common.md

## git
@~/ai-coding-guide/guides/git.md

## mcp
@~/ai-coding-guide/guides/mcp.md

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

---

# sub-agent

## 共通
- sub-agentの実行結果は一時的ファイルとしてmdファイルを出力するようにしてください

## file-collector
- 大きなファイルを読み込む必要がある場合は、メインタスクのコンテクストを圧迫しないように、sub-agent`file-collector`を利用してください
