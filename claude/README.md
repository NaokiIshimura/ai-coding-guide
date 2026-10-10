# ClaudeCode

このディレクトリの内容は、リポジトリルートの `Makefile` で `~/.claude/` にインストールします。手順の詳細はルートの [README.md](../README.md) を参照してください。

```bash
# 新規環境
make install

# 旧構成（commands）からの移行
make migrate
make install
```

## ディレクトリ構成

| パス | 説明 | 呼び出し方 | インストール先 |
|------|------|-----------|---------------|
| `CLAUDE.md` | ユーザー共通の指示（`guides/` を参照） | 自動で読み込み | `~/.claude/CLAUDE.md` |
| `settings.json` | ユーザー設定（permissions、hooks、statusLine など） | 自動で読み込み | `~/.claude/settings.json` にマージ |
| `statusline-readable.sh` | statusline スクリプト | settings.json の `statusLine` から実行 | `~/.claude/statusline-readable.sh` |
| `agents/` | sub-agent 定義（一覧: [AGENTS.md](AGENTS.md)） | Agent ツール（`subagent_type`） | `~/.claude/agents/` |
| `skills/` | skill 定義（一覧: [SKILLS.md](SKILLS.md)） | `/<name>`、Skill ツール | `~/.claude/skills/` |

## CLAUDE.md
```bash
$ make install-config
```

## settings
```bash
$ make install-settings
```

- 既存の `~/.claude/settings.json` がある場合は、`~/.claude/settings.json.bak.<タイムスタンプ>` にバックアップしてからマージします（リポジトリ側の値を優先し、既存のみのキーは残す）
- `~/.claude/settings.json` で変更した管理キーは `make import-settings` でリポジトリに取り込めます（`autoMode` などリポジトリで管理していないキーは取り込みません）
- `jq` が必要です

設定の優先順位（上ほど優先）:
```
1. Project settings (local)  Saved in .claude/settings.local.json
2. Project settings          Checked in at .claude/settings.json
3. User settings             Saved in ~/.claude/settings.json
```

## agents
```bash
$ make install-agents
$ ls -l ~/.claude/agents/
```

## skills
```bash
$ make install-skills
$ ls -l ~/.claude/skills/
```

- skill ごとに `rsync -a --delete claude/skills/<name>/ ~/.claude/skills/<name>/` で同期します（リポジトリで管理していない skill には触れません）
- 同名の skill は `~/.claude/skills/` がプロジェクトの `.claude/skills/` より優先されます

## hooks
[フックリファレンス - Anthropic](https://docs.anthropic.com/ja/docs/claude-code/hooks)

hooks は `settings.json` の `hooks` で管理しており、`make install-settings` でインストールされます。手動で設定する場合は `/hooks` を利用してください。

### Notification
Claude Codeが通知を送信するときに実行されます。通知は以下の場合に送信されます：

- Claudeがツールを使用する許可が必要な場合。例：「ClaudeがBashを使用する許可が必要です」
- プロンプト入力が少なくとも60秒間アイドル状態の場合。「Claudeがあなたの入力を待っています」

```
1. /hooks
2. Notification
3. afplay ~/ai-coding-guide/sounds/Glass.aiff
```

### Stop
メインのClaude Codeエージェントが応答を完了したときに実行されます。
ユーザーの中断による停止の場合は実行されません。

```
1. /hooks
2. Stop
3. afplay ~/ai-coding-guide/sounds/Funk.aiff
```

#### mplayer

```
# Mac
$ brew install mplayer

# Linux
$ sudo apt-get install mplayer

# play
$ mplayer ~/ai-coding-guide/sounds/Glass.aiff >& /dev/null
$ mplayer ~/ai-coding-guide/sounds/Funk.aiff >& /dev/null
```
