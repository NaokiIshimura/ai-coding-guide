---
allowed-tools: Write, Read, Bash(git:*), Bash(TZ='Asia/Tokyo' date '+%Y_%m%d_%H%M'), Bash(mkdir:*), Glob, Grep, Task
description: 実装計画（requirements/design/tasks.md）を作成する
---

## コンテキスト

- 現在のブランチ: !`git branch --show-current`
- 現在のディレクトリ: !`pwd`
- 現在の日時（日本時間）: !`TZ='Asia/Tokyo' date '+%Y-%m-%d %H:%M:%S'`

## タスク

収集した情報を基に、実装計画（requirements/design/tasks.md）を作成してください。

### 実施手順

1. **チケット番号/識別子の確認**
   - ユーザーからチケット番号が提供されている場合は、それを使用
   - 提供されていない場合は、現在のgitブランチ名から推測
   - 推測できない場合は、ユーザーに確認

2. **出力先ディレクトリの作成**
   - チケット番号がある場合: `.claude/tasks/<チケット番号>/`
   - チケット番号がない場合: `.claude/tasks/tmp/`
   ```bash
   mkdir -p .claude/tasks/<識別子>/
   ```

3. **タイムスタンプの生成**
   ```bash
   TZ='Asia/Tokyo' date '+%Y_%m%d_%H%M'
   ```

4. **実装計画ドキュメントの作成**
   以下の3つのドキュメントを順番に作成：

   **a) 仕様書（requirements.md）**
   - Taskツールで `requirements-writer` エージェントを呼び出し
   - または直接作成
   - 出力: `<タイムスタンプ>_requirements.md`

   **b) 設計書（design.md）**
   - Taskツールで `design-writer` エージェントを呼び出し
   - 仕様書を参照して作成
   - 出力: `<タイムスタンプ>_design.md`

   **c) タスクリスト（tasks.md）**
   - Taskツールで `tasks-writer` エージェントを呼び出し
   - 仕様書・設計書を参照して作成
   - 出力: `<タイムスタンプ>_tasks.md`

5. **出力完了の報告**
   - 出力した各ファイルのパス
   - 各ドキュメントの概要
   - 次のステップの提案

### 出力ファイル

```
.claude/tasks/<識別子>/
├── YYYY_MMDD_HHMM_requirements.md  # 仕様書
├── YYYY_MMDD_HHMM_design.md        # 設計書
└── YYYY_MMDD_HHMM_tasks.md         # タスクリスト
```

### ドキュメント間の参照関係

```
requirements.md
    ↓ 参照
design.md
    ↓ 参照
tasks.md
```

### 注意事項

- **タイムスタンプ**: 必ず日本時間のタイムスタンプを使用
- **バージョン管理**: 新しいタイムスタンプのファイルとして保存し、既存ファイルは上書きしない
- **整合性**: 3つのドキュメント間で整合性を保つ
- **順序**: requirements → design → tasks の順で作成（依存関係のため）
- **ファイル末尾**: 全てのファイルの末尾に空行を追加
- **日本語**: すべてのドキュメントは日本語で記述

### 期待される成果

1. 要件が明確に定義された仕様書
2. 技術的に実現可能な設計書
3. 実行可能なタスクリスト
4. ドキュメント間の一貫性と整合性
