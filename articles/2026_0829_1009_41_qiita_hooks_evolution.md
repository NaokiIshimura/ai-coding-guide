---
title: Claude Codeのフックがこの半年で別物になった — 追加された13イベントと新しい書き方
tags:
  - claudecode
  - claude
  - anthropic
  - AI
  - hooks
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---

## 🎯 はじめに

Claude Code の**フック（hooks）** は、`PreToolUse` と `PostToolUse` くらいしか使っていない人が多いのではないでしょうか。

しかし v2.1.55（2026-02-25）から v2.1.251（2026-08-28）までの半年で、**13個のフックイベントが新設**され、実行機構そのものも大きく変わりました。現在のイベント数は31個です。

たとえば「Bash で git コマンドを実行するときだけ、シェルを介さずにスクリプトを直接起動する」はこう書けます。

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git *)",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/guard.sh",
            "args": []
          }
        ]
      }
    ]
  }
}
```

`if` も `args` も、この半年で追加されたものです。本記事では**何が増えて、どう書き方が変わったか**をまとめます。

## 📌 3行まとめ

- `InstructionsLoaded` / `CwdChanged` / `FileChanged` / `StopFailure` / `MessageDisplay` / `PermissionDenied` など、**13個のフックイベントが新設**された
- `type: "http"`（HTTP フック）、`type: "mcp_tool"`、`args` による exec 形式、`if` による条件実行など、**実行機構が大幅に拡張**された
- `defer` 権限判断や `continueOnBlock` により、**「ブロックして終わり」ではない制御**ができるようになった

## 🆕 新設されたフックイベント（v2.1.55 以降）

| イベント | バージョン | 何が起きたとき発火するか |
|---|---|---|
| `InstructionsLoaded` | v2.1.69 | `CLAUDE.md` や `.claude/rules/*.md` がコンテキストに読み込まれたとき |
| `PostCompact` | v2.1.76 | コンパクション完了後 |
| `Elicitation` | v2.1.76 | MCP サーバーが構造化入力を要求したとき |
| `ElicitationResult` | v2.1.76 | その応答が返される直前（横取り・上書き可能） |
| `StopFailure` | v2.1.78 | API エラー（レート制限、認証失敗など）でターンが終わったとき |
| `CwdChanged` | v2.1.83 | 作業ディレクトリが変わったとき |
| `FileChanged` | v2.1.83 | ファイルが変更されたとき |
| `TaskCreated` | v2.1.84 | `TaskCreate` でタスクが作られたとき |
| `PermissionDenied` | v2.1.89 | auto mode の分類器が拒否したあと |
| `MessageDisplay` | v2.1.152 | アシスタントのメッセージが表示されるとき |
| `DirectoryAdded` | v2.1.219 | `/add-dir` などで作業ディレクトリが追加されたとき |
| `PreModelSwitch` | v2.1.251 | モデル切替の直前（ブロック・確認・注釈が可能） |
| `PostModelSwitch` | v2.1.251 | モデル切替の直後 |

### 実用度が高い3つ

**`CwdChanged` / `FileChanged`（v2.1.83）— リアクティブな環境管理**

CHANGELOG が例として挙げているのがまさに **direnv** です。ディレクトリが変わったら環境変数を読み直す、といった「環境をコードに追従させる」用途に使えます。

**`StopFailure`（v2.1.78）— 失敗の検知**

これまで `Stop` フックは正常終了時にしか発火せず、「レート制限で落ちた」を検知する手段がありませんでした。`StopFailure` はまさにそこで発火します。CI や長時間バッチで通知を飛ばすのに向いています。

**`InstructionsLoaded`（v2.1.69）— CLAUDE.md の可視化**

どの `CLAUDE.md` / `.claude/rules/*.md` が実際に読み込まれたかを検出できます。モノレポでルールファイルが散らばっているとき、「意図したルールが効いているか」を確認する用途に使えます。

## ⚙️ 実行機構の進化

イベントが増えただけではなく、**フックの書き方自体**が変わりました。

### 1. HTTP フック（v2.1.63）

シェルスクリプトを置かずに、**JSON を POST して JSON を受け取る**形式が使えます。

```json
{
  "type": "http",
  "url": "http://localhost:8080/hooks/pre-tool-use",
  "headers": {
    "Authorization": "Bearer $MY_TOKEN"
  },
  "allowedEnvVars": ["MY_TOKEN"],
  "timeout": 600
}
```

`allowedEnvVars` で明示したものだけが展開されるので、環境変数が無差別に漏れることはありません。ポリシーサーバーを1つ立てて、チーム全員のフックをそこに集約する、といった運用ができます。

### 2. `if` による条件実行（v2.1.85）

パーミッションルール構文でフックの発火条件を絞れます。

```json
{
  "type": "command",
  "if": "Bash(git *)",
  "command": "./check-git.sh"
}
```

これがない時代は、フック側で「自分に関係あるツール呼び出しか」を判定していたため、**すべてのツール呼び出しでプロセスが起動**していました。`if` はそのオーバーヘッドを丸ごと削ります。

:::note warn
v2.1.214 で `if:` 条件のパス解釈が変わりました。単一セグメントの `dir/**` は **`<cwd>/dir` にのみマッチ**するようになっています。任意の深さにマッチさせたい場合は `**/dir/**` と書いてください。なお `deny` / `ask` のパーミッションルール側は従来どおり任意深さでマッチします。
:::

### 3. `args` による exec 形式（v2.1.139）

`args` を指定すると、**シェルを経由せず実行ファイルを直接起動**します。

```json
{
  "type": "command",
  "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/guard.sh",
  "args": []
}
```

シェルを挟まないので、パスにスペースが含まれていてもクォートで悩む必要がありません。`args` を省略すると従来どおり `sh -c`（Windows では PowerShell）経由のシェル形式になります。

### 4. `type: "mcp_tool"` — MCP ツールをフックとして呼ぶ

```json
{
  "type": "mcp_tool",
  "server": "my_server",
  "tool": "security_scan",
  "input": {
    "file_path": "${tool_input.file_path}"
  }
}
```

既存の MCP サーバーが持つツールを、そのままフックの処理系として使えます。

### 5. `terminalSequence`（v2.1.141）

フックの JSON 出力に `terminalSequence` を含めると、**制御端末を持たないフックからでも**デスクトップ通知・ウィンドウタイトル・ベルを出せます。

```json
{
  "terminalSequence": "\u001b]0;Build finished\u0007"
}
```

バックグラウンドセッションから通知を出したいときに効きます。

## 🚦 「ブロックして終わり」からの脱却

フックの判断結果まわりも進化しました。

### `defer`（v2.1.89）

`PreToolUse` に `"defer"` という第3の選択肢が入りました。`allow` でも `deny` でもなく、**「通常のフローに判断を委ねる」** です。

さらにヘッドレスセッションでは、`defer` でツール呼び出しの直前まで進んで一時停止し、`-p --resume` で再開したときにフックが再評価される、という使い方ができます。CI で「人間の承認を挟む」ゲートを作れます。

### `continueOnBlock`（v2.1.139）

`PostToolUse` 向けの設定です。`true` にすると、**フックの拒否理由が Claude にフィードバックされ、ターンが継続**します。

従来は「フックがブロック → ターン終了」でしたが、これで「フックが指摘 → Claude が直す → 続行」というループが組めます。lint やフォーマッタの結果を返すフックと相性が良いです。

### `PermissionDenied` + `retry`（v2.1.89）

auto mode の分類器が拒否したあとに発火します。`{"retry": true}` を返すと、Claude に「リトライしてよい」と伝えられます。

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionDenied",
    "retry": true
  }
}
```

### `PreCompact` でコンパクションを止める（v2.1.105）

`PreCompact` フックが終了コード 2 または `{"decision":"block"}` を返すと、**コンパクション自体をブロック**できます。「この作業中は圧縮させたくない」を表現できます。

## 🔧 運用まわりの改善

派手さはありませんが、実際に効く変更です。

| バージョン | 内容 |
|---|---|
| v2.1.75 | パーミッションプロンプトに**フックの出所**（settings / plugin / skill）を表示 |
| v2.1.89 | 50K 文字を超えるフック出力は、コンテキストに直接注入せず**ファイルに保存してパス＋プレビュー**を渡す |
| v2.1.94 | `UserPromptSubmit` フックの `hookSpecificOutput.sessionTitle` でセッションタイトルを設定可能に |
| v2.1.98 | トランスクリプト上のフックエラーに **stderr の1行目**を含めるように（`--debug` なしで原因が分かる） |
| v2.1.101 | `settings.json` に未知のフックイベント名があっても、**ファイル全体が無視されなくなった** |
| v2.1.142 | `SessionStart` / `Setup` / `SubagentStart` に prompt 型・agent 型フックを設定した場合、「command 型を使え」という明確なエラーが出るように |
| v2.1.169 | `--safe-mode`（`CLAUDE_CODE_SAFE_MODE`）で **CLAUDE.md・プラグイン・スキル・フック・MCP をすべて無効化**して起動できる（トラブルシュート用） |
| v2.1.229 | セルフホストランナーのセッションでも、サーバー供給のフックがサポートされるように |
| v2.1.251 | `SessionStart` の resume フックが、**セッションの古さと再キャッシュ推定コスト**を受け取るように |

特に **v2.1.101 の変更は重要**です。以前はイベント名を1つタイポしただけで `settings.json` 全体が無視され、原因が分からず数時間溶かす、ということが起き得ました。

## 📄 実践例：危険なコマンドをブロックする

公式ドキュメントの例をベースにした最小構成です。

`.claude/hooks/block-rm.sh`:

```bash
#!/bin/bash
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive command blocked by hook"
    }
  }'
else
  exit 0
fi
```

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.sh",
            "args": []
          }
        ]
      }
    ]
  }
}
```

`if: "Bash(rm *)"` があるので、**`rm` を含む Bash 呼び出しのときだけ**スクリプトが起動します。`args: []` により exec 形式になり、パスのクォートを気にする必要がありません。

### 終了コードの意味

| コード | 挙動 |
|---|---|
| `0` | 成功。JSON 出力が読まれる |
| `2` | ブロッキングエラー。アクションが阻止される（対応イベントのみ） |
| その他（1, 3〜255） | 非ブロッキングエラー。アクションは続行 |
| タイムアウト | フックがキャンセルされ、アクションは続行 |

「`1` を返せば止まる」ではない点に注意してください。**止めたいなら `2`** です。

## ✅ まとめ

- フックイベントは31個に増え、**ライフサイクルのほぼ全域にフックできる**ようになった
- `if` と `args` は、既存のフック設定を今すぐ書き換える価値がある（オーバーヘッド削減とクォート地獄の解消）
- `defer` / `continueOnBlock` / `retry` により、フックは「門番」から「対話的なガードレール」に変わった
- 設定を書き換えるなら、まず `--safe-mode` で「フック無しの挙動」を確認できることを覚えておくと安全

CLAUDE.md にルールを書き連ねるより、フックで機械的に強制したほうが確実なケースは多いです。この半年の追加分は、ちょうどその「機械的に強制する」ための道具が揃った期間でした。

## 🔗 参考リンク

- [Hooks reference — Claude Code Docs](https://code.claude.com/docs/en/hooks)
- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
