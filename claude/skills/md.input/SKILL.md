---
description: 指定したディレクトリ内のmarkdownファイルを読み込んで作業状況を把握する
argument-hint: "[読み込み対象ディレクトリ（省略時: .claude/plans/）]"
disable-model-invocation: true
allowed-tools: Skill
---

## タスク

Skill ツールで共通 skill `markdown` を呼び出し、その「2. 入力（input）」の手順に従って、markdownファイルを読み込み過去の作業状況を把握してください。

## 引数

- 引数: $ARGUMENTS
- 引数がある場合は、そのパスを読み込み対象とする
- 引数がない場合は、`.claude/plans/` を読み込み対象とする

**使用例**:
```bash
# デフォルト（.claude/plans/ 配下のすべてのファイルを読み込み）
/md.input

# 特定のチケットのディレクトリから読み込み
/md.input .claude/plans/ABC-123/

# カスタムパスから読み込み
/md.input path/to/directory/
```
