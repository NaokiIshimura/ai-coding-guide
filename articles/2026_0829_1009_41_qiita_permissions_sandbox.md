---
title: Claude Codeの権限とサンドボックスはどう変わったか — auto mode・--restricted・認証情報マスキング
tags:
  - claudecode
  - claude
  - anthropic
  - セキュリティ
  - AI
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---

## 🎯 はじめに

`--dangerously-skip-permissions`（通称 YOLO モード）を常用していませんか。

Claude Code の権限まわりは、v2.1.55（2026-02-25）から v2.1.251（2026-08-28）の半年で大きく作り替えられました。ポイントは「**プロンプトの数を減らしつつ、危険な操作は確実に止める**」という方向です。

```bash
# v2.1.248 で追加された最も厳しいモード
claude --restricted

# または
CLAUDE_CODE_RESTRICTED=1 claude
```

本記事では **auto mode の進化 / 新しい `--restricted` / パーミッションルールの書き方 / サンドボックスの認証情報保護** の4本立てで整理します。

## 📌 3行まとめ

- **auto mode** は分類器（classifier）ベースの権限判断。`git reset --hard` や `terraform destroy` など**破壊的操作を文脈から判断してブロック**する（v2.1.183）
- **`--restricted`**（v2.1.248）はコード実行系ツールを丸ごと外し、**ユーザー・プロジェクト・ローカル設定をすべて無視**する最も硬いモード
- サンドボックスは**認証情報のマスキング**（v2.1.221 / v2.1.224）まで到達。JWT のクレーム単位マスクや AWS SigV4 の再署名まで対応

## 🏷 まず用語：「default」は「Manual」になった

v2.1.200 で名称が変わりました。

> Changed the "default" permission mode to "Manual" across the CLI, `--help`, VS Code, and JetBrains; `--permission-mode manual` and `"defaultMode": "manual"` are accepted alongside `default`

`default` という指定も引き続き通りますが、UI 上の表示は **Manual** です。さらに v2.1.203 で、Manual モードのときフッターに**グレーの ⏸ バッジ**が出るようになりました。「今どのモードで動いているか」が常に見えるようになっています。

現在のモードは以下の4つです。

| モード | 挙動 |
|---|---|
| `manual`（旧 `default`） | すべての操作で確認 |
| `plan` | 計画のみ立て、実行しない |
| `acceptEdits` | ファイル編集を自動承認 |
| `auto` | **分類器が個別に判断** |
| `bypassPermissions` | すべてスキップ（危険） |

## 🤖 auto mode — 分類器が判断する

auto mode は、コマンドを静的なルールではなく**分類器（LLM）が文脈込みで評価**するモードです。この半年で最も手が入った領域です。

### 何をブロックするようになったか

**v2.1.183 — 破壊的 git コマンドと IaC の destroy**

これが一番実感しやすい変更です。

- `git reset --hard` / `git checkout -- .` / `git clean -fd` / `git stash drop` を、**あなたがローカルの変更を捨てるよう頼んでいない場合はブロック**
- `git commit --amend` を、**そのコミットがこのセッションでエージェントが作ったものでない場合はブロック**
- `terraform destroy` / `pulumi destroy` / `cdk destroy` を、**特定のスタックを指定して頼んでいない限りブロック**

「コマンドが危険か」ではなく「**あなたがそれを頼んだか**」で判断しているのがポイントです。

**v2.1.205 — トランスクリプトの改竄と、解決できない変数の `rm -rf`**

- セッションのトランスクリプトファイルへの改竄をブロックするルールを追加
- 文脈から中身を解決できない変数に対する `rm -rf`（`rm -rf $DIR` の `$DIR` が不明など）は**確認してから実行**

**v2.1.154 — データ持ち出しの検知**

リポジトリ内容の一括転送など、データ持ち出しの検知が強化されました。

**v2.1.178 / v2.1.222 — 抜け道を塞ぐ**

- v2.1.178：**サブエージェントの起動そのもの**を分類器が起動前に評価。サブエージェント経由でブロック対象の操作を要求する穴を塞いだ
- v2.1.222：**`SendMessage` による他セッションへのメッセージ送信**も、送信前に分類器で評価されるように

「別のエージェント／別のセッションに頼めば通る」という迂回路が順番に潰されています。

### 設定

**`autoMode.classifyAllShell`（v2.1.193）**

```json
{
  "autoMode": {
    "classifyAllShell": true
  }
}
```

既定では「任意コード実行パターン」に該当する Bash / PowerShell コマンドだけが分類器を通ります。`true` にすると**すべてのシェルコマンド**が分類器を通ります。安全側に倒したい場合に。

**`autoMode.hard_deny`（v2.1.136）**

```json
{
  "autoMode": {
    "hard_deny": ["..."]
  }
}
```

**ユーザーの意図や allow 例外に関係なく無条件でブロック**するルールを書けます。通常の分類器ルールは「あなたが頼んだかどうか」を見ますが、`hard_deny` は文脈を一切見ません。組織ポリシーとして「絶対にやらせない」ものを書く場所です。

:::note warn
**v2.1.207 の破壊的変更**：auto mode は `.claude/settings.local.json`（リポジトリ内に置かれるファイル）から `autoMode` 設定を**読まなくなりました**。`~/.claude/settings.json` に書いてください。リポジトリに commit された設定でセキュリティ境界を緩められないようにする措置です。
:::

### 使い勝手の改善

| バージョン | 内容 |
|---|---|
| v2.1.118 | auto mode の opt-in プロンプトに「Don't ask again」を追加 |
| v2.1.160 | 定型操作での推論を減らし**分類器のレイテンシを改善**。"could not evaluate this action" によるブロックが減少 |
| v2.1.193 | 拒否理由をトランスクリプト・拒否トースト・`/permissions` の recent denials に表示 |
| v2.1.210 | 外部セッションでは分類器が既定で **Sonnet 5** を使用。セッション最初のリクエストで検証してセッション中は固定 |
| v2.1.218 | dangerous-rm / background-`&` / 疑わしい Windows パスのチェックが**ダイアログを開かず分類器が裁定**するように |
| v2.1.218 | plan モード + auto で、静的解析が read-only と証明できない Bash コマンドについて**プロンプトを出さず分類器が判断** |
| v2.1.221 | 並列ツール呼び出しの権限チェックがキャッシュ効率化。チェック中のモード切替でも古い結果が適用されなくなった |
| v2.1.236 | Bedrock / Vertex AI / Foundry、テレメトリ無効時でも **Claude API と同じ既定**（severity スコア付き分類）を使用 |
| v2.1.236 | git status チェックが、リポジトリの `status.showUntrackedFiles=no` 設定に**騙されなくなった** |
| v2.1.246 | **`/permissions` に Auto mode タブ**を追加。分類器ルールの閲覧・編集が可能に |
| v2.1.247 | Bash の権限プロンプトに auto mode への案内を追加。**「Yes, and switch to auto mode」がワンキー**で選べる |

v2.1.246 の `/permissions` Auto mode タブは、これまでブラックボックスだった分類器のルールを可視化するもので、auto mode を導入する際の心理的ハードルを下げます。

## 🔒 `--restricted` — 最も硬いモード（v2.1.248）

2026-08-27 に追加された、まだ新しいフラグです。

```bash
claude --restricted
CLAUDE_CODE_RESTRICTED=1 claude
```

やっていることは4つです。

1. **コマンドやコードを実行する組み込みツールと `WebFetch` を削除**（`--tools` で明示的に指定した場合を除く）
2. **ファイル系ツールを作業ディレクトリ内に限定**
3. **`bypassPermissions` を拒否**
4. **ユーザー・プロジェクト・ローカルの設定ファイルをすべて無視**

4番目が効いています。「設定ファイルで権限を緩める」経路そのものを断つので、**設定を書き換えられていても安全側に倒れます**。信頼できないリポジトリを読ませるとき、あるいは CI で読み取り専用の解析だけさせたいときに向きます。

## 📝 パーミッションルールの書き方

### `Tool(param:value)` 構文（v2.1.178）

ツールの**入力パラメータ**にマッチさせられるようになりました。

```json
{
  "permissions": {
    "deny": ["Agent(model:opus)"]
  }
}
```

上の例は「Opus を使うサブエージェントの起動を禁止」です。`*` ワイルドカードも使えます。

### deny ルールでのグロブ（v2.1.166）

```json
{
  "permissions": {
    "deny": ["*"]
  }
}
```

ツール名の位置でグロブが使えるようになり、`"*"` で全ツール拒否ができます。allow ルール側では非 MCP のグロブは拒否されます（誤って全許可してしまう事故を防ぐため）。

### ⚠️ 書き間違えやすいルール

**Write / NotebookEdit / Glob にパスを付けるのは無効（v2.1.210）**

```json
{
  "permissions": {
    "allow": ["Write(src/**)"]
  }
}
```

これは意図どおりに動きません。**`Edit(path)` または `Read(path)` を使ってください。** v2.1.210 以降は起動時に警告が出ます。

**Bash ルールのサブコマンド前ワイルドカード（v2.1.246）**

```json
{
  "permissions": {
    "allow": ["Bash(git * main)"]
  }
}
```

これも危険です。`*` がサブコマンドの**前に**あるため、サブコマンドの前に挿入されたオプションにもマッチしてしまいます。v2.1.246 以降は起動時に警告が出ます。

**「always allow」の保存先（v2.1.211）**

権限プロンプトで「always allow」を選んだときの保存先が、**リポジトリのルート**に変わりました。git worktree 内で承認した内容が、セッションや worktree を跨いで維持されます。

### プロンプトを減らす

**v2.1.71 / v2.1.72 — auto-approval allowlist の拡充**

読み取り専用コマンドが追加されました。

- v2.1.71：`fmt` / `comm` / `cmp` / `numfmt` / `expr` / `test` / `printf` / `getconf` / `seq` / `tsort` / `pr`
- v2.1.72：`lsof` / `pgrep` / `tput` / `ss` / `fd` / `fdfind`

**v2.1.111 — `/less-permission-prompts` スキル**

トランスクリプトを走査して、頻出する読み取り専用の Bash / MCP ツール呼び出しを検出し、**優先度付きの allowlist を `.claude/settings.json` 向けに提案**してくれます。まずこれを実行するのが手っ取り早いです。

### 逆に厳しくなったもの

| バージョン | 内容 |
|---|---|
| v2.1.214 | `file` コマンドの `-m`/`--magic-file`、`-f`/`--files-from` が read-only 扱いされなくなり、**権限が必要**に |
| v2.1.214 | `docker`（Podman の `docker` シム含む）の**デーモンリダイレクト系フラグ**（`--url` / `--connection` / `--identity`、Podman のリモートモード）に権限プロンプトを追加 |
| v2.1.235 | 権限ダイアログの表示テキストと「don't ask again」が、**実際に付与される範囲と常に一致**するように。内容を完全に表示できない場合は「don't ask again」が出なくなった |
| v2.1.251 | Bash の権限チェックが、**整数シェル変数への算術式代入**（`OPTIND=1/0`、`RANDOM=2+2` など）を自動承認していた問題を修正 |

## 🛡 サンドボックス — 認証情報を守る

サンドボックスは「ファイルシステム分離」と「ネットワーク egress 制御」の2軸です。この半年での目玉は**認証情報の保護**でした。

### `sandbox.credentials`（v2.1.187）

サンドボックス内のコマンドが、認証情報ファイルや秘密の環境変数を読むのをブロックします。

### `mode: "mask"`（v2.1.221）— Linux / WSL

ここが面白い機能です。ブロックするのではなく、**偽物を読ませます**。

- サンドボックス内のコマンドは**センチネル（ダミー）のコピー**を読む
- ファイル全体、または `extract` 正規表現でキャプチャしたスパンだけをダミー化できる
- **egress の際にサンドボックスプロキシが本物の値に差し替える**

つまり、`~/.aws/credentials` を読んで API を叩くツールは**正常に動くのに、認証情報そのものはプロセスから見えない**という状態を作れます。

:::note warn
macOS ではファイルのマスキングはサポートされず、`deny` にフォールバックします。
:::

### 高度なマスキングオプション（v2.1.224）

```json
{
  "sandbox": {
    "network": { "tlsTerminate": true },
    "credentials": {
      "...": {
        "decode": "jwt",
        "maskClaims": ["sub", "email"]
      }
    }
  }
}
```

- `extract` / `onExtractNoMatch`：構造化された環境変数値から特定部分だけを抽出してマスク
- `decode: "jwt"` + `maskClaims`：**JWT をデコードしてクレーム単位でマスク**
- `awsPairs` / `sigv4`：**AWS SigV4 の再署名**

いずれも `network.tlsTerminate` が必要で、**ユーザー設定・マネージド設定・`--settings` からのみ**有効です（プロジェクト設定からは指定できません）。

### ネットワーク制御

| 設定 | バージョン | 内容 |
|---|---|---|
| `sandbox.network.deniedDomains` | v2.1.113 | 広い `allowedDomains` ワイルドカードがあっても、特定ドメインを個別にブロック |
| `sandbox.network.strictAllowlist` | v2.1.219 | 許可リストに無いホストを**プロンプトを出さずに拒否** |
| `sandbox.filesystem.disabled` | v2.1.216 | **ファイルシステム分離だけスキップ**し、ネットワーク egress 制御は維持 |
| `sandbox.failIfUnavailable` | v2.1.83 | サンドボックスが有効なのに起動できない場合、**サンドボックス無しで実行せずエラー終了** |
| `allowRead` | v2.1.77 | `denyRead` 領域の中で読み取りを再許可 |

`sandbox.failIfUnavailable` は地味に重要です。既定では「サンドボックスが使えなければサンドボックス無しで実行」という挙動なので、**セキュリティを前提にしているなら明示的に `true` にすべき**です。

その他の関連改善：

- **v2.1.191**：ネットワーク権限ダイアログで "Yes" したホストが**セッション中記憶される**ように（接続のたびに聞かれなくなった）
- **v2.1.229**：ネットワークドメインリスト内の IPv6 リテラルを角括弧付き（`[::1]:443`）に。曖昧な記法は **fail-closed** で強制され、`/doctor` がフラグを立てる
- **v2.1.243**：サンドボックス化された Bash のプロンプトが**許可済みホストを列挙しなくなった**。Claude がリクエストを試み、新しいホストをあなたが承認する流れに変更
- **v2.1.251**：サンドボックス内 Bash のコマンド出力ファイルの作成・読み戻し方法を変更し、**サンドボックス内コマンドがそれをリダイレクト・置換できない**ように

### 認証情報の漏洩を防ぐその他の仕組み

- **`CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`（v2.1.83）**：Bash ツール・フック・MCP stdio サーバーのサブプロセス環境から、Anthropic とクラウドプロバイダの認証情報を除去
- **PID 名前空間分離（v2.1.98）**：Linux で `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` が設定されている場合、サブプロセスサンドボックスに PID 名前空間分離が入る。`CLAUDE_CODE_SCRIPT_CAPS` でセッションあたりのスクリプト実行回数を制限可能
- **GitLab トークンの秘匿（v2.1.232）**：`glrt-` / `gloas-` / `glptt-` など GitLab のトークンファミリを redaction 対象に追加。`glpat-` / `gldt-` は完全 redaction。`glab` CLI の設定ストアも `gh` と同等のサンドボックス保護・認証情報パス保護の対象に

## 🏢 マネージド設定側の締め付け

v2.1.251 で、組織が配布するサーバーマネージド設定にも承認が要求されるようになりました。

> Changed server-managed settings that terminate sandbox TLS, route sandbox traffic through your own proxy, inject credentials, or weaken sandbox isolation to require approval before they apply

サンドボックスの TLS を終端する、トラフィックを独自プロキシに通す、認証情報を注入する、サンドボックス分離を弱める——これらは**適用前にユーザーの承認が必要**になりました。

あわせて、`ANTHROPIC_CUSTOM_HEADERS` がマネージド／プロジェクト設定から `Authorization` や `Host` などの認証・ルーティング系ヘッダを設定する場合も承認が必要です。また、プロジェクトレベルの `.claude/settings.json` の `env` は `CLAUDE_CONFIG_DIR` / `CLAUDE_CODE_TMPDIR` / `TMPDIR` / `TMP` / `TEMP` を設定できなくなりました。

**「リポジトリに入っている設定ファイルは、セキュリティ境界を緩める権限を持たない」** という原則が、この半年で一貫して徹底されています。

## ✅ まとめ

- auto mode は「コマンドが危険か」ではなく「**あなたがそれを頼んだか**」で判断する。`git reset --hard` や `terraform destroy` が文脈でブロックされる
- `autoMode` 設定は **`~/.claude/settings.json` に書く**（v2.1.207 以降、`.claude/settings.local.json` からは読まれない）
- 権限プロンプトを減らしたいなら、まず **`/less-permission-prompts`** を実行する
- `Write(path)` / `Glob(path)` のルールは無効。**`Edit(path)` / `Read(path)`** を使う
- 信頼できないコードを扱うなら **`--restricted`**。サンドボックスを前提にするなら **`sandbox.failIfUnavailable: true`** を忘れずに

`--dangerously-skip-permissions` を常用している人ほど、まず `auto` モードを試す価値があります。プロンプトの数は大きく減りつつ、破壊的な操作はきちんと止まります。

## 🔗 参考リンク

- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [Claude Code settings — Claude Code Docs](https://code.claude.com/docs/en/settings)
- [Claude Code security — Claude Code Docs](https://code.claude.com/docs/en/security)
