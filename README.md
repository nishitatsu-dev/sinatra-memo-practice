# sinatra-memo-practice

## 概要

sinatra課題のメモアプリです。
データベース（DB）利用バージョンです。

## セットアップ

1. PostgreSQLを起動し、下記を準備して下さい。
   1. メモアプリ用のDBを作成
      ✅ DB作成権限のあるOSユーザで、下記コマンドを入力

      ``` shell
      createdb DB名
      ```

   1. DBユーザを作成
      🚨 既存DBユーザを利用する場合は、作成不要。
      下記コマンド入力後、パスワード設定を要求されるので入力してください。

      ``` shell
      createuser -PE DBユーザ名
      ```

   1. DBユーザに権限付与
      🚨 スーパーユーザ権限を持つ場合は、不要。
      1. 上記で作ったDBに接続

         ``` txt
         psql -d DB名
         ```

      1. テーブル作成権限をDBユーザに付与

         ``` txt
         grant create on schema public to DBユーザ名;
         ```

      1. 各種テーブル操作権限をDBユーザに付与

         ``` txt
         grant select, insert, delete, update on all tables in schema public to DBユーザ名;
         ```

1. ローカルのシェルで下記の環境変数を設定して下さい。
   - DB
     ✅ 上記で作ったDBを設定。

     ``` shell
     export MEMO_APP_DB='DB名'
     ```

   - DBユーザと、その認証パスワード
     🚨 Peer認証、またはIdent認証の場合は、設定不要。

     ``` shell
     export MEMO_APP_USER='DBユーザ名'
     ```

     ``` shell
     export MEMO_APP_PW='パスワード'
     ```

   - ホスト
     🚨 ローカルホストの場合は、設定不要。

     ``` shell
     export MEMO_APP_HOST='ホスト名'
     ```

1. メモアプリのコードをダウンロードして下さい。
1. memo_app.rbのあるディレクトリに移動し、下記のコマンドを実行して下さい。
   1. 必要なgemのインストール

      ``` shell
      bundle
      ```

   1. メモアプリの起動

      ``` shell
      bundle exec ruby memo_app.rb -p 4567
      ```

1. ブラウザのアドレスバーに下記を入力すると、index画面が表示されます。

   ``` shell
   http://localhost:4567/memo/index
   ```
