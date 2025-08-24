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

---

# 一時ファイルの作成ルール
- プロジェクトのルートディレクトリ直下に一時ファイルを作成しないでください
- 一時ファイルを作成する際には、プロジェクト配下の`claude`ディレクトリ配下に作成してください

## チケット番号が与えられている場合
```
.claude
  └ tasks
    └ <チケット番号>
      └ xxx.md
```
## チケット番号が与えられてない場合
```
.claude
└ tmp
  └ xxx.md
```
