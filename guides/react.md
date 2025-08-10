# React

## AIへの指示
Reactに対する作業を指示した際には以下のルールを厳守してください。

### コンポーネント分割
- ロジックとUIはコンポーネントを分割してください
- 1つのファイルに全てのコードを記述せず、適切にファイル分割してください
  ```
  ├─ hooks
  │  └─ SampleHandler.ts
  ├─ components
  │  └─ SampleComponent
  │     ├─ index.tsx
  │     └─ SampleComponent.stories.tsx
  │
  └─ index.ts
  ```
### Props
- propsをinterfaceで定義するときは、各パラメータにreadonlyを付けてください
- propsをtypeで定義する時は、Readonlyユーティリティタイプで型全体をラップしてください
