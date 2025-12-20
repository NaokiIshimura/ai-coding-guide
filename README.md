# AIコーディングガイド
AI アシスタント（ClaudeCode / GithubCopilot / Cline / RooCode）効果的に協働するためのコーディングガイドです。

## ファイル構成
```
ai-coding-guide/
├── claude/
│   ├── CLAUDE.md                # Claude用の設定ファイル
│   ├── settings.json            # Claude設定ファイル
│   ├── statusline-readable.sh   # Claude statusline スクリプト
│   ├── agents/                  # Claudeエージェント定義
│   └── commands/                # Claudeコマンド定義
├── guides/
│   ├── common.md      # 共通ガイドライン
│   ├── git.md         # Git操作ガイド
│   ├── mcp.md         # MCPツール使用ガイド
│   ├── react.md       # React開発ガイド
│   ├── storybook.md   # Storybook作成ガイド
│   └── test.md        # テスト作成ガイド
└── Makefile           # インストール用Makefile
```

## インストール

Makefileを使用して、Claude用の設定ファイル、エージェント、コマンドを`~/.claude/`ディレクトリにインストールできます。また、`~/.claude/`の設定をプロジェクトにインポートすることも可能です。

### 使用可能なコマンド

```bash
# すべてインストール（CLAUDE.md、settings、agents、commands）
make install

# 個別インストール
make install-config     # CLAUDE.mdのみインストール
make install-settings   # settings.jsonのみインストール
make install-statusline # statusline-readable.shのみインストール
make install-agents     # agentsディレクトリのみインストール
make install-commands   # commandsディレクトリのみインストール

# 設定のインポート
make import-settings   # ~/.claude/ の設定をプロジェクトにコピー

# アンインストール
make clean            # すべて削除
make clean-config     # CLAUDE.mdのみ削除
make clean-settings   # settingsのみ削除
make clean-agents     # agentsのみ削除
make clean-commands   # commandsのみ削除

# ヘルプ表示
make help
```

### インストール例

```bash
# リポジトリをクローン
git clone https://github.com/NaokiIshimura/ai-coding-guide.git
cd ai-coding-guide

# すべてインストール
make install

# 確認
ls ~/.claude/
```
