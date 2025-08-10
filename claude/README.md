# ClaudeCode

## CLAUDE.md
```
$ cp claude/CLAUDE.md ~/.claude/CLAUDE.md
```

## settings
```
1. Project settings (local)  Saved in .claude/settings.local.json
2. Project settings          Checked in at .claude/settings.json
3. User settings             Saved in at ~/.claude/settings.json
```

## commands
```
$ mkdir ~/.claude/commands/
$ rsync -av --delete claude/commands/ ~/.claude/commands/
$ ls -l ~/.claude/commands/
```

## agents
```
$ mkdir ~/.claude/agents/
$ rsync -av --delete claude/agents/ ~/.claude/agents/
$ ls -l ~/.claude/agents/
```

## hooks
[フックリファレンス - Anthropic](https://docs.anthropic.com/ja/docs/claude-code/hooks)

### Notification
Claude Codeが通知を送信するときに実行されます。通知は以下の場合に送信されます：

Claudeがツールを使用する許可が必要な場合。例：「ClaudeがBashを使用する許可が必要です」
プロンプト入力が少なくとも60秒間アイドル状態の場合。「Claudeがあなたの入力を待っています」
​
```
1. /hooks
2. Notification
3. afplay /System/Library/Sounds/Glass.aiff
```

### Stop
メインのClaude Codeエージェントが応答を完了したときに実行されます。
ユーザーの中断による停止の場合は実行されません。

```
1. /hooks
2. Stop
3. afplay /System/Library/Sounds/Funk.aiff
```
