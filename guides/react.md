# React

## AIへの指示
Reactに対する作業を指示した際には以下のルールを厳守してください。

### コンポーネント分割
- ロジックとUIはコンポーネントを分割してください
- 1つのファイルに全てのコードを記述せず、適切にファイル分割してください
  ```
  ShowUser
  ├─ hooks
  │  ├─ fetchUsers.ts
  │  ├─ handleClick.ts
  │  └─ index.ts
  ├─ components
  │  ├─ UserComponent
  │  │  ├─ index.tsx
  │  │  └─ UserComponent.stories.tsx
  │  └─ index.ts
  ├─ index.ts
  └─ ShowUser.stories.tsx
  ```
### Props
- propsをinterfaceで定義するときは、各パラメータにreadonlyを付けてください
- propsをtypeで定義する時は、Readonlyユーティリティタイプで型全体をラップしてください
