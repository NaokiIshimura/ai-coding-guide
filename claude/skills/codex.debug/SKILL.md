---
description: Codexにデバッグを依頼する
argument-hint: "<エラーメッセージ・スタックトレース・再現手順など>"
disable-model-invocation: true
allowed-tools: Skill, Bash(codex *), Bash(mkdir *), Bash(date *), Bash(TZ=Asia/Tokyo date *), Bash(git branch *), Read, Write, Glob, Grep
---

## タスク

Skill ツールで共通 skill `codex` を呼び出し、その手順の「debug（デバッグ）」に従って、Codexにエラーの原因特定と修正を依頼してください。

## 引数

- 引数: $ARGUMENTS
- 引数全体をエラー情報（target）として扱い、エラーメッセージ・スタックトレース・再現手順・期待する動作・実際の動作に振り分けてプロンプトに含める
- 引数がない場合や情報が不足している場合は、不足している情報をユーザーに確認する

**使用例**:
```bash
# 基本的な使用方法
/codex.debug TypeError: Cannot read property 'name' of undefined

# 詳細なエラー情報を提供
/codex.debug
エラー: TypeError: Cannot read property 'name' of undefined
ファイル: src/auth/login.ts:42
スタックトレース:
  at login (src/auth/login.ts:42:10)
  at handleSubmit (src/components/LoginForm.tsx:28:5)
再現手順:
1. ログインフォームを開く
2. ユーザー名とパスワードを入力
3. ログインボタンをクリック
期待する動作: ログインが成功する
実際の動作: エラーが発生する
```
