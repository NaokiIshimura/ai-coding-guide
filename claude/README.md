# ClaudeCode

## CLAUDE.md
```
$ cp claude/CLAUDE.md ~/.claude/CLAUDE.md
```

## commands
```
$ mkdir ~/.claude/commands/
$ rsync -av --delete claude/commands/ ~/.claude/commands/
$ ls -l ~/.claude/commands/
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
