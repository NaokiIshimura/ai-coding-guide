---
title: Claude Codeのセッション同士が会話しはじめた — SendMessage / ListAgents 完全ガイド
tags:
  - claudecode
  - claude
  - anthropic
  - AI
  - CLI
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---

## 🎯 はじめに

Claude Code v2.1.224（2026-08-07）で、**Claude Code のセッション同士がメッセージをやり取りできるようになりました**。

これまで「複数のターミナルで Claude Code を並列に走らせる」ことはできても、それぞれは完全に孤立していました。API サーバーを直しているセッションと、フロントを直しているセッションは、互いの存在すら知らなかったわけです。

v2.1.224 以降はこうなります。

```
> フロント側のセッションに、APIのレスポンス形式を変えたと伝えて

⏺ ListAgents
  ⎿ backend-refactor   (this session)  /work/api
     frontend-fix                       /work/web
     flaky-test-hunt                    /work/api

⏺ SendMessage(to: "frontend-fix")
  ⎿ Message delivered to frontend-fix
```

本記事では、この**クロスセッションメッセージング**を軸に、`claude agents`（agent view）から始まった一連の「マルチセッション統治」機能を、CHANGELOG を追いながら整理します。

## 📌 3行まとめ

- **v2.1.224** で `SendMessage` / `ListAgents` が追加され、Claude Code のセッション同士が直接メッセージを送れるようになった（macOS / Linux、WSL2 内の Linux を含む）
- 送られるのは**プレーンテキストのメッセージだけ**。会話履歴もプロジェクトファイルも渡らず、受信側はツール呼び出しの合間にそれを読む
- `crossSessionInbound` と `dialogExpiry` により、**メッセージは同意にならない**設計。`bypassPermissions` で動いているセッション宛のメッセージは自動配信されず、承認待ちで保留される

## 🗺 ここまでの流れ：単体セッションから「群れ」へ

クロスセッションメッセージングは突然生えた機能ではなく、半年かけて積み上がった土台の上に乗っています。

| バージョン | 日付 | 何が入ったか |
|---|---|---|
| v2.1.139 | 2026-05-11 | **agent view**（Research Preview）— 全セッションを1画面に一覧 |
| v2.1.141 | 2026-05 | `claude agents --cwd <path>` でディレクトリ単位に絞り込み |
| v2.1.142 | 2026-05 | `claude agents` に `--model` `--effort` `--permission-mode` 等のフラグ追加 |
| v2.1.144 | 2026-05 | `/resume` がバックグラウンドセッションにも対応（`bg` マーク付き） |
| v2.1.145 | 2026-05 | `claude agents --json` — セッション一覧を JSON で取得、スクリプト可能に |
| v2.1.198 | 2026-06 | `Notification` フックが `agent_needs_input` / `agent_completed` で発火 |
| **v2.1.224** | **2026-08-07** | **`SendMessage` / `ListAgents`（クロスセッション）** |
| v2.1.225 | 2026-08-08 | 他マシンの Remote Control セッションに**こちらから**話しかけられるように |
| v2.1.236 | 2026-08 | `notify_when_idle` — 相手がアイドルになったら1回だけ通知 |
| v2.1.248 | 2026-08-27 | Bedrock / Vertex / Foundry、テレメトリ無効時でも同一マシン間で利用可能に |

つまり「**一覧できる（agent view）→ 個別に操作できる → 相互に会話できる**」という順で進化してきました。

## 🚀 使い方

### 1. まずセッションを増やす

バックグラウンドセッションを立てます。

```bash
# バックグラウンドで起動
claude --bg "investigate the flaky SettingsChangeDetector test"

# 名前を付けておくと SendMessage の宛先にしやすい
claude --bg --name "flaky-test-fix" "investigate the flaky test"

# subagent を指定して起動
claude --agent code-reviewer --bg "address review comments on PR 1234"
```

セッション中からバックグラウンドに送ることもできます。

```
/bg run the test suite and fix any failures
```

### 2. agent view で見渡す

```bash
claude agents
```

セッション中に空のプロンプトで `←` を押しても開きます。

主なキーバインド：

| キー | 動作 |
|---|---|
| `↑` / `↓` | 行の移動 |
| `Enter` | アタッチ（入力欄にテキストがあれば dispatch） |
| `Space` | peek パネルの開閉 |
| `→` | アタッチ |
| `Ctrl+S` | 状態別 / ディレクトリ別のグルーピング切替 |
| `Ctrl+T` | ピン留め |
| `Ctrl+R` | リネーム |
| `Ctrl+X` | 停止（もう一度で削除） |
| `?` | ショートカット一覧 |

:::note info
v2.1.248 で agent view の dispatch 入力欄の挙動が変わりました。`Shift+Enter` が改行、`Ctrl+Enter` が「dispatch してそのままアタッチ」です。
:::

### 3. セッションから他セッションへ話しかける

あとは Claude に頼むだけです。

```
> ListAgentsで今動いてるセッションを確認して、
  frontend-fix に「/api/users のレスポンスに total_count を足した」と伝えて
```

Claude は `ListAgents` で到達可能なセッションを列挙し、`SendMessage` で名前を指定して届けます。

CLI 側からもセッションを操作できます。

```bash
claude agents --json          # セッション一覧を JSON で
claude attach <id>            # アタッチ
claude logs <id>              # 直近の出力
claude stop <id>              # 停止
claude rm <id>                # 一覧から削除
claude daemon status          # スーパーバイザの状態
```

### 4. 「終わったら教えて」— notify_when_idle

v2.1.236 で追加された `notify_when_idle` は、ポーリングせずに相手の完了を待つための仕組みです。

- **opt-in**：明示的に指定したときだけ動く
- **one-shot**：通知は1回だけ
- **no polling**：定期的な確認は発生しない

「ビルドを回しているセッションが手を離したら教えて」という待ち方が、無駄なトークンを使わずにできます。

## 🔐 ここが本題：メッセージは「同意」にならない

この機能で一番よく設計されているのは、**セキュリティ境界**です。

他のセッションからメッセージが届いたからといって、それが「あなたの承認」として扱われることは絶対にありません。

### crossSessionInbound

受信側の挙動を3値で制御します。

```json
{
  "crossSessionInbound": "hold",
  "dialogExpiry": 300
}
```

| 値 | 挙動 |
|---|---|
| `accept` | 受信して自動的に会話へ流す |
| `hold` | 承認ダイアログを出して保留（`dialogExpiry` 秒でタイムアウト） |
| `refuse` | 受信を拒否 |

**`bypassPermissions` で動いているセッション宛のメッセージは、既定で保留（hold）されます。** 権限チェックを飛ばしているセッションを、外から自由に動かせてしまってはまずいからです。

v2.1.232 では `/config` に「Dialog expiry」と「Messages from your other sessions」の行が追加され、GUI からも設定できるようになりました。

:::note warn
v2.1.248 で、`crossSessionInbound` に不正な値が入っていたときの挙動が変わりました。以前は黙って無視されていましたが、現在は**警告を出したうえで保留（ユーザー設定の場合）または拒否（マネージド設定の場合）** されます。設定ミスが「素通り」に倒れないよう、fail-closed になっています。
:::

### auto mode の分類器も通る

v2.1.222 で、**`SendMessage` による送信自体が auto mode のパーミッション分類器で評価される**ようになりました。「他セッションにメッセージを送る」という行為が権限チェックの抜け道にならないようにする措置です。

### 渡らないもの

改めて重要な点として、`SendMessage` で相手に渡るのは**そのメッセージのテキストだけ**です。

- ❌ 会話履歴は渡らない
- ❌ プロジェクトファイルは渡らない
- ❌ 権限は渡らない

受信側の Claude は、ツール呼び出しの合間にそのテキストを読むだけです。

## 🖥 表示の作り込み

地味ですが、実運用で効く改善が続いています。

- **v2.1.228**：送信者と本文がインラインで表示されるように。他マシンの Remote Control セッション宛の場合、送信者名として Remote Control のセッション名が表示される
- **v2.1.247**：既定で `Message from @<sender>: <first line>` の1行プレビューに折りたたまれるように変更。`Ctrl+O` で全文展開

大量にメッセージが飛び交うと会話が埋まるため、「既定は1行、必要なら展開」に落ち着いた形です。

## ⚠️ ハマりどころ

CHANGELOG の Fixed を追うと、実際に踏まれた地雷が見えます。

| バージョン | 内容 |
|---|---|
| v2.1.162 | `CLAUDE_CODE_TMPDIR` や `$TMPDIR` が深い階層を指しているとクロスセッションメッセージングが黙って壊れる問題を修正（UNIX ソケットのパス長制限） |
| v2.1.228 | インストール／アップグレード直後の最初のセッションで inbox が生成されないことがある問題を修正 |
| v2.1.239 | **タイトルが `/` で始まるセッションが `SendMessage` の宛先にできず**、`ListAgents` で "(untitled)" と表示される問題を修正 |
| v2.1.243 | 2.1.232 のソケットディレクトリ強化以降、ユーザー名前空間や rootless コンテナ内でクロスセッションメッセージングが無効化されてしまう問題を修正 |
| v2.1.248 | 既定のディレクトリが使えない場合に、ユーザー専用の `/tmp` 配下へフォールバックするように改善。通知と `/status` が「直すべきディレクトリ」を明示 |

うまく動かないときは、まず **`/status` でクロスセッションメッセージングの状態と使用中のディレクトリを確認**するのが早道です。`$TMPDIR` 周りとコンテナ内の実行が二大要因でした。

### プラットフォーム

- ✅ macOS
- ✅ Linux（WSL2 内の Linux を含む）
- ❌ ネイティブ Windows

### subagent から送る場合の注意

v2.1.248 で挙動が明示されました。**subagent から他セッションへ `SendMessage` した場合、返信は subagent ではなく親セッションの会話に届きます。** subagent は返事を受け取れないので、「送りっぱなし」で完結する使い方に留めるのが安全です。

## 🧭 どういうときに使うか

現実的に効くパターンを挙げます。

1. **モノレポの前後段分離**：API を直すセッションとフロントを直すセッションを分け、インターフェース変更のタイミングだけ通知する
2. **長時間ジョブの待ち合わせ**：ビルド／E2E を回すセッションに `notify_when_idle` を仕込み、完了したら次の工程を始める
3. **レビュー分業**：`claude --agent code-reviewer --bg` でレビュー役を常駐させ、実装セッションから「この差分見て」と投げる
4. **調査の切り出し**：フレーキーテストの原因調査を別セッションに分離し、本流の実装を止めない

いずれも「1つのセッションのコンテキストを膨らませない」ことが主目的です。コンテキストを分けたうえで、必要な情報だけを細い線でやり取りする——これがこの機能の本質だと思います。

## ✅ まとめ

- `SendMessage` / `ListAgents` により、Claude Code のセッションは**互いに独立したまま連携**できるようになった
- 渡るのはメッセージ本文のみ。**コンテキストは分離したまま**なので、大規模作業でトークンを浪費しない
- `crossSessionInbound` / `dialogExpiry` / auto mode 分類器という三重の防御で、**メッセージが権限昇格の経路にならない**よう設計されている
- まずは `claude agents` で全セッションを可視化するところから始めるのがおすすめ

並列開発の運用設計そのものが変わる機能です。まだ日本語の情報が少ない領域なので、ぜひ手元で試してみてください。

## 🔗 参考リンク

- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [Agent view — Claude Code Docs](https://code.claude.com/docs/en/agent-view)
- [Claude Code 2.1.224: Sessions Can Now Message Each Other](https://www.digitalapplied.com/blog/claude-code-self-hosted-runners-cross-session-agent-messaging)
- [Claude Code Cross-Session Messaging: ListAgents, SendMessage, and Safe Parallel Development](https://kylon.io/blog/claude-code-cross-session-messaging-2026)
- [Claude Code Cross-Session Messaging: Permission Boundaries and Organization Controls](https://smartscope.blog/en/blog/claude-code-cross-session-messaging-2026/)
