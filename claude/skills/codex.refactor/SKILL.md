---
description: Codexにリファクタリングを依頼する
argument-hint: "<対象ファイル> [改善方針]"
disable-model-invocation: true
allowed-tools: Skill, Bash(codex *), Bash(mkdir *), Bash(date *), Bash(TZ=Asia/Tokyo date *), Bash(git diff *), Bash(git branch *), Read, Write, Glob, Grep
---

## タスク

Skill ツールで共通 skill `codex` を呼び出し、その手順の「refactor（リファクタリング）」に従って、Codexにリファクタリングを依頼してください。

## 引数

- 引数: $ARGUMENTS
- 最初のファイルパスをリファクタリング対象（target）とする（必須）
- 残りの部分は改善方針（instruction）としてプロンプトに含める
- 対象ファイルの指定がない場合は、対象をユーザーに確認する

**使用例**:
```bash
# 基本的な使用方法
/codex.refactor src/utils/helper.ts

# 改善方針を指定
/codex.refactor src/utils/helper.ts 可読性向上に重点を置いてリファクタリングしてください

# パフォーマンス重視
/codex.refactor src/services/data-processor.ts パフォーマンス最適化を優先してください
```
