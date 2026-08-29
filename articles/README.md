# Qiita 投稿用記事

Claude Code の CHANGELOG（v2.1.55 〜 v2.1.251 / 2026-02-25 〜 2026-08-28）を調査して作成した Qiita 投稿用記事です。

## 記事一覧

| ファイル | テーマ | 主な対象バージョン |
|---|---|---|
| [2026_0829_1009_41_qiita_cross_session_messaging.md](2026_0829_1009_41_qiita_cross_session_messaging.md) | クロスセッションメッセージング（`SendMessage` / `ListAgents`）と agent view | v2.1.139, v2.1.224〜v2.1.248 |
| [2026_0829_1009_41_qiita_hooks_evolution.md](2026_0829_1009_41_qiita_hooks_evolution.md) | フックの拡張（新設13イベント、HTTP フック、`if` / `args`、`defer`） | v2.1.63〜v2.1.251 |
| [2026_0829_1009_41_qiita_autonomous_loop_workflow.md](2026_0829_1009_41_qiita_autonomous_loop_workflow.md) | 自走・自動化（`/goal` / `/loop` / Cron / Workflow / Monitor） | v2.1.71, v2.1.139, v2.1.202〜v2.1.248 |
| [2026_0829_1009_41_qiita_permissions_sandbox.md](2026_0829_1009_41_qiita_permissions_sandbox.md) | 権限とサンドボックス（auto mode、`--restricted`、認証情報マスキング） | v2.1.69〜v2.1.251 |

## フォーマット

各記事は Qiita CLI 互換の frontmatter を持ちます。投稿前に `private` と `tags` を確認してください。

```yaml
---
title: ...
tags:
  - claudecode
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
```

## 参考

- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- `claude/skills/qiita/SKILL.md` — 記事の構成ルール
- `claude/skills/qiita-claude-code-release-notes/SKILL.md` — リリースノート記事の構成ルール
