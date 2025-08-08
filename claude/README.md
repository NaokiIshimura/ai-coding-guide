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
```
1. /hooks
2. Stop
3. afplay /System/Library/Sounds/Funk.aiff
```

Claude Codeがツールの実行前に確認を求める際にサウンドを鳴らすには、tool-use-allow-hookを使用します。
```
# 設定コマンド
claude hooks set tool-use-allow-hook "afplay /System/Library/Sounds/Ping.aiff"

# または他のサウンド例
claude hooks set tool-use-allow-hook "afplay /System/Library/Sounds/Glass.aiff"
claude hooks set tool-use-allow-hook "afplay /System/Library/Sounds/Hero.aiff"

このhookは、Claude Codeがツール（コマンドの実行やファイル編集など）の使用許可を求める直前に実行されます。

確認：
claude hooks list

無効化したい場合：
claude hooks disable tool-use-allow-hook
```
