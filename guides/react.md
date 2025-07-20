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
  │  └─ SampleComponent.tsx
  └─ index.ts
  ```
