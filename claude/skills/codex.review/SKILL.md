---
description: Codexにコードレビューを依頼する
argument-hint: "[ファイル | ディレクトリ（省略時: 未コミットの変更）] [重点観点]"
disable-model-invocation: true
allowed-tools: Skill, Bash(codex *), Bash(mkdir *), Bash(date *), Bash(TZ=Asia/Tokyo date *), Bash(git diff *), Bash(git status *), Bash(git branch *), Read, Write, Glob, Grep
---

## タスク

Skill ツールで共通 skill `codex` を呼び出し、その手順の「review（レビュー）」に従って、Codexにコードレビューを依頼してください。

## 引数

- 引数: $ARGUMENTS
- 引数のうち、存在するファイル・ディレクトリのパスをレビュー対象（target）とする
  - ディレクトリや複数ファイルの場合は、複数ファイルモード（1ファイルずつ順にレビューしてサマリーを作成）で実行する
- パス以外の部分は重点観点（instruction）としてプロンプトに含める
- 引数がない場合は、未コミットの変更をレビューする

**使用例**:
```bash
# 単一ファイルのレビュー
/codex.review src/auth/login.ts

# ディレクトリ全体のレビュー
/codex.review src/auth/

# 特定の観点でレビュー
/codex.review src/auth/login.ts セキュリティとパフォーマンスに重点を置いてレビューしてください

# 未コミットの変更のレビュー
/codex.review
```
