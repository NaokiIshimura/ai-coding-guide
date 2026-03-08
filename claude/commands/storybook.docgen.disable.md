---
allowed-tools: Read, Edit, Glob
description: StorybookのdocgenをFalseに設定する（一時的な無効化）
---

## コンテキスト

- Storybookのメイン設定ファイルを検索: !`find . -path "./.storybook/main.*" -not -path "*/node_modules/*" 2>/dev/null | head -5`

## タスク

StorybookのdocgenをFalseに一時的に設定してください。

### 手順

1. `.storybook/main.ts` または `.storybook/main.js` を特定する
2. 設定ファイルを読み込み、現在の `typescript.reactDocgen` の値を確認する
3. `typescript.reactDocgen` を `false` に設定する
   - すでに `typescript` の設定ブロックがある場合は `reactDocgen: false` を追加・更新する
   - `typescript` の設定ブロックがない場合は新たに追加する

### 設定例

```typescript
// .storybook/main.ts
const config: StorybookConfig = {
  // ...既存の設定...
  typescript: {
    reactDocgen: false,
  },
};
```

4. 変更後のファイルを確認し、変更内容をユーザーに報告する
5. 元の値をユーザーに伝え、元に戻す方法を案内する

### 注意事項

- docgenを無効化するとStorybookの起動が速くなりますが、ArgsTableでのプロパティ自動生成が無効になります
- 元の設定に戻す際は、`typescript.reactDocgen` を元の値（例: `'react-docgen-typescript'`）に変更してください
