# テスト

## AIへの指示
テストに関する指示した際には以下のルールを厳守してください。

### 作業範囲
- テストの追加・修正のみを実施してください。
- テストの対象としているコードの修正は行わないでください。

### テスト対象
- privateメソッドのテストは追加しないでください
- カバレッジが100%となるようにしてください

### テスト実行
- テストを追加・修正を行ったあとには、テストを実行してください
- テストを実行する際には、追加・修正したテストのみ実行の対象となるように、テスト対象を指定してください
  - テスト対象を指定せず、全てのテストが実行することは避けてください
- テストを実行した際に、失敗したテストがあったら、テストが通るようになるまで修正してください
- テストを通るようにするために、テストの対象としているコードの修正は行わないでください

#### コマンド
js
```
npm test -- <ファイルパス>
```

rspec
```
$ bundle exec rspec <ファイルパス>
```
