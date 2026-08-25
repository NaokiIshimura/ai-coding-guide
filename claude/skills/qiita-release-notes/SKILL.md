---
name: qiita-release-notes
description: Claude Codeのバージョンを指定してQiitaのリリースノート記事を作成する
allowed-tools: Write, Read, Bash, Glob, Grep, WebFetch, WebSearch
---

# Claude Code リリースノート Qiita記事作成スキル

Claude Code の指定バージョン範囲の CHANGELOG を取得し、Qiita 投稿用のリリースノート記事を作成します。

## コンテキスト

- 現在の日時（日本時間）: !`TZ='Asia/Tokyo' date +"%Y-%m-%d %H:%M:%S"`
- タイムスタンプ（ファイル名用）: !`TZ='Asia/Tokyo' date +"%Y_%m%d_%H%M_%S"`

## 入力パラメータ

ユーザーから以下を受け取ります：

- **開始バージョン**: 例 `v2.1.80`（`v` プレフィックスは省略可）
- **終了バージョン**: 例 `v2.1.84`（`v` プレフィックスは省略可）

バージョン範囲が指定されていない場合は、ユーザーに確認してください。

## 実行手順

### 1. CHANGELOG の取得

`gh` コマンドで GitHub から CHANGELOG.md を取得します：

```bash
gh api repos/anthropics/claude-code/contents/CHANGELOG.md --jq '.content' | base64 -d
```

取得後、指定バージョン範囲の行番号を特定して該当セクションを抽出します：

```bash
# バージョンの行番号を確認
gh api repos/anthropics/claude-code/contents/CHANGELOG.md --jq '.content' | base64 -d | grep -n "^## <バージョン番号>"

# 該当範囲を抽出（開始行〜終了行）
gh api repos/anthropics/claude-code/contents/CHANGELOG.md --jq '.content' | base64 -d | sed -n '<開始行>,<終了行>p'
```

### 2. 参考記事の確認（初回のみ）

過去記事のフォーマットを参考にする場合は以下を確認：

```
https://qiita.com/NaokiIshimura/items/a976cce2fc48de14da63
```

### 3. 記事の構成

以下の構成で記事を作成します：

```
---
title: Claude Code v<開始> - v<終了> リリースノート
tags:
  - claudecode
  - claude
  - anthropic
  - AI
  - リリースノート
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---

<冒頭サマリー（今回のリリースのハイライトを1〜2文で）>

---

## ✨ 新機能まとめ

### <絵文字> <カテゴリ名>

**<機能名>（v<バージョン>）**

- <説明>

---

## 🛠 主な修正

### <絵文字> <カテゴリ名>

- **v<バージョン>**: <修正内容>

---

## 📋 バージョン別サマリー

| バージョン | 主なトピック |
|-----------|------------|
| **v<バージョン>** | <概要> |

---

## 参考

- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
```

### 4. 見出し・スタイルのルール

- **見出し形式**: `**<機能名>（v<バージョン>）**`（バージョンは末尾に括弧書き）
- **カテゴリ絵文字の例**:
  - ⚡ CLI / 起動オプション
  - 🔌 MCP（Model Context Protocol）
  - 🪝 Hooks
  - 🔧 プラグイン
  - 🖥️ Windows / PowerShell
  - 📊 ステータスライン / Rate Limit
  - 🔍 検索・UI
  - 🖼️ 画像・ファイル操作
  - 🤖 エージェント
  - 🔒 セキュリティ・マネージド設定
  - ⚙️ 環境変数・設定
  - 🎹 キーバインディング
  - 🚀 パフォーマンス・UX
  - 💻 VSCode 拡張
- **修正セクション**: カテゴリ別に `-` の箇条書きでバージョンを **太字** で記載
- **バージョン別サマリー**: 記事末尾にテーブル形式で各バージョンの要点を列挙
- **コードは適宜挿入**: コマンドや JSON は ` ```bash ` ` ```json ` などで記述

### 5. カテゴリの並び順

カテゴリは以下の順序で並べます（該当するカテゴリのみ記載）：

#### ✨ 新機能まとめ

1. ⚡ CLI / 起動オプション
2. 🔌 MCP（Model Context Protocol）
3. 🪝 Hooks
4. 🔧 プラグイン
5. 🖥️ Windows / PowerShell
6. 📊 ステータスライン / Rate Limit
7. 🔍 トランスクリプト検索
8. 🖼️ 画像・ファイル操作
9. 🤖 エージェント
10. 🔒 セキュリティ・マネージド設定
11. ⚙️ 環境変数・設定
12. 🎹 キーバインディング
13. 🚀 パフォーマンス・UX

#### 🛠 主な修正

1. ⚡ CLI / セッション
2. 🔌 MCP
3. 🎤 音声入力
4. 🔒 パーミッション / セキュリティ
5. 💻 ターミナル / UI
6. 🖥️ Windows / PowerShell
7. 🔧 VSCode

### 7. CHANGELOG の分類方針

CHANGELOG の各エントリを以下のルールで分類します：

- `Added` → **✨ 新機能まとめ** に追加
- `Fixed` → **🛠 主な修正** に追加
- `Improved` → 改善内容に応じて新機能または修正に振り分け
- `Changed` / `Deprecated` → 新機能まとめに記載（ただし破壊的変更は修正セクションで言及）

エントリは意味のあるカテゴリにグループ化し、バージョン間で同じカテゴリのものをまとめます。

### 8. ファイル出力

```
.claude/plans/qiita/<タイムスタンプ>_release_notes.md
```

- ディレクトリが存在しない場合は作成する
- ファイル末尾は必ず空行で終わる

### 9. 完了通知

出力ファイルのパスをユーザーに通知してください。

## 注意事項

- バージョン番号の前に `v` をつける（例: `v2.1.80`）
- 記事は **日本語** で記述（技術用語・コマンド名は英語のまま）
- `v2.1.82` のようにスキップされているバージョンが存在する場合があるため、CHANGELOG に該当バージョンが存在するかを必ず確認する
- 特定のバージョンに大量のエントリがある場合は重要度の高いものを優先して記載する

## タスク

ユーザーから指定されたバージョン範囲（例: `v2.1.80 - v2.1.84`）の Claude Code リリースノートを Qiita 記事として作成してください。

