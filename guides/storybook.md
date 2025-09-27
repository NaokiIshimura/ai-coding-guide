# Storybook

## AIへの指示
Storybookに関する指示した際には以下のルールを厳守してください。

---

### 作業範囲
- Storyの追加・修正のみを実施してください。
- Storyの対象としているコードの修正は行わないでください。

---

### モック
- Storyの対象とするコンポーネントがAPIリクエストを行っていたら、MSWでモックしてください

---

### 確認
- Storyの追加・修正を行った際には、ブラウザ もしくは Playwright MCP でStoryにアクセスして、エラーが発生してないことを確認してください
- Storybookを起動する際には`--ci`オプションを付与して、空いているポートを利用してください。
  ```
  $ npm run storybook -- --ci
  ```
- Storyへアクセスして、エラーが発生していたら、エラーが発生しなくようになるまで修正してください

---

### インタラクションテスト
- `step`でテスト項目を明示してください

#### サンプルコード
```
import { expect, within } from 'storybook/test';

play: async ({ canvasElement, step }) => {
    const canvas = within(canvasElement);

    await step('ラジオボタンが有効であることを確認', async () => {
      const radioButton = canvas.getByRole('radio');
      expect(radioButton).not.toBeDisabled();
    });

    await step('メッセージが表示されていないことを確認', async () => {
      const messageElements = canvas.queryAllByText(
        /xxxxxxxxxx/
      );
      expect(messageElements.length).toBeGreaterThan(0);
    });
  },
```
