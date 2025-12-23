# Claude Skills

このディレクトリには、Skill tool で呼び出し可能なスキル定義が格納されています。

## Skills、Commands、Agents の違い

| 項目 | Skills | Commands | Agents |
|------|--------|----------|--------|
| 呼び出し方 | Skill tool | `/xxx` | Task tool (subagent_type) |
| 実行主体 | メインプロセス | メインプロセス | サブプロセス |
| コンテキスト | 共有 | 共有 | 独立 |
| 用途 | 汎用的なスキル | プロジェクト固有のワークフロー | 専門的タスクの自律実行 |

## スキル一覧

| スキル | 説明 | 対応操作 |
|--------|------|----------|
| `git` | git操作 | branch, commit, push, pull |
| `pull-request` | プルリクエスト操作 | create, update, comment resolve |
| `markdown` | markdownファイル操作 | output, input |
| `example` | サンプルスキル（テンプレート） | - |

## スキルの使用方法

スキルは以下のように呼び出します：

```
/スキル名 [引数]
```

例：
```
/example
```

## スキルファイルの形式

```markdown
---
description: <スキルの説明>
allowed-tools: <許可ツール（カンマ区切り）>
---

## 概要
<スキルの概要説明>

## タスク
<実行するタスクの詳細>
```

## カスタムスキルの追加

新しいスキルを追加する場合は、上記の形式でmarkdownファイルを作成してください。

### 命名規則

- ファイル名: `機能名.md`（例: `git.md`, `pr.md`）
- 機能単位でまとめる（コマンド単位ではなく）
