---
name: tmux-pane-info
description: 現在のtmuxセッション・ウィンドウ・ペインの情報、および同一ウィンドウ内の別ペインの情報を取得する
allowed-tools: Bash(tmux:*)
---

## 概要

現在Claude Codeが起動されているtmuxの「セッション・ウィンドウ・ペイン」の情報を取得します。
また、同じセッション・ウィンドウ内で起動されている別ペインの情報（実行コマンド、カレントディレクトリ、表示内容など）も取得できます。

## コンテキスト

- TMUX環境変数（tmux内で実行されているか）: !`echo "${TMUX:-未検出}"`
- 現在のペイン情報: !`tmux display-message -p '#{session_name}:#{window_index}.#{pane_index} (window=#{window_name} pane_id=#{pane_id} command=#{pane_current_command})' 2>/dev/null || echo "tmux外で実行中"`

## 前提条件

このスキルはtmuxセッション内でClaude Codeが起動されている場合のみ有効です。
`$TMUX` が未設定、または `tmux display-message` がエラーになる場合は、tmux外で実行されていることをユーザーに伝えてください。

## 対応操作

### 1. 現在のセッション・ウィンドウ・ペイン情報取得

```bash
# セッション名:ウィンドウ番号.ペイン番号
tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}'

# セッションID / ウィンドウID / ペインID
tmux display-message -p '#{session_id} #{window_id} #{pane_id}'

# カレントディレクトリ / 実行中コマンド / プロセスID
tmux display-message -p '#{pane_current_path}'
tmux display-message -p '#{pane_current_command}'
tmux display-message -p '#{pane_pid}'
```

取得できる主な情報:

- セッション名: `#{session_name}`
- ウィンドウ番号・ウィンドウ名: `#{window_index}` / `#{window_name}`
- ペイン番号・ペインID: `#{pane_index}` / `#{pane_id}`
- カレントディレクトリ: `#{pane_current_path}`
- 実行中コマンド: `#{pane_current_command}`

### 2. 同一ウィンドウ内の別ペイン一覧取得

自分自身のペインIDを取得したうえで、同じセッション・ウィンドウに属する全ペインを一覧化し、自分自身を除外することで「別ペイン」を特定します。

```bash
# 自分自身のペインID
MY_PANE=$(tmux display-message -p '#{pane_id}')

# 同一ウィンドウ内の全ペイン一覧（自分自身含む）
tmux list-panes -t "$(tmux display-message -p '#{session_name}:#{window_index}')" \
  -F '#{pane_id} active=#{pane_active} command=#{pane_current_command} path=#{pane_current_path} title="#{pane_title}"'

# 自分自身を除いた別ペインのみ
tmux list-panes -t "$(tmux display-message -p '#{session_name}:#{window_index}')" \
  -F '#{pane_id} active=#{pane_active} command=#{pane_current_command} path=#{pane_current_path} title="#{pane_title}"' \
  | grep -v "^${MY_PANE} "
```

### 3. 別ペインの表示内容取得

一覧で特定した `pane_id` を指定して、そのペインに表示されている内容（スクロールバック含む）を取得します。

```bash
# 現在表示されている内容のみ
tmux capture-pane -t <pane_id> -p

# スクロールバック全体を含めて取得
tmux capture-pane -t <pane_id> -p -S -

# 直近N行のみ取得
tmux capture-pane -t <pane_id> -p -S -<N>
```

## タスク

1. `$TMUX` が設定されているかを確認し、tmux内での実行かどうかを判定する
2. `tmux display-message` で現在のセッション名・ウィンドウ・ペインの情報を取得する
3. `tmux list-panes` で同一セッション・ウィンドウ内の全ペインを一覧化し、自分自身のペインIDと突き合わせて「別ペイン」を特定する
4. ユーザーの要求に応じて、`tmux capture-pane` で別ペインの表示内容を取得する
5. 取得した情報（セッション名、ウィンドウ、ペイン番号、実行コマンド、カレントディレクトリなど）を分かりやすく整理してユーザーに報告する
