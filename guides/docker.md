# Docker

## AIへの指示
- MCPを利用するためにdockerが必要なケースがあるので、MCPを利用する前にdockerデーモンが起動しているか確認してください
- dockerデーモンが起動していない場合は、dockerデーモンを起動してください
- colimaがインストールされている場合は、dockerデーモンの代わりにcolimaを起動してください

## docker
- dockerデーモンステータス確認
  ```
  $ ps aux | grep docker
  ```

## colima
- インストールされているか確認する
  ```
  $ colima --version
  ```
- colimaを起動する
  ```
  $ colima start
  ```
