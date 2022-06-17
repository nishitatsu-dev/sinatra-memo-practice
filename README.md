# sinatra-memo-practice

## 概要

sinatra課題のメモアプリです。
データベース（DB）利用バージョンです。

## セットアップ

1. PostgreSQLを起動してください。
2. PostgreSQLで下記２点を準備して下さい。
   - アプリを使う「OSユーザ」と同名の「DBユーザ」があることを確認して下さい。
   - メモアプリ用のDB`memo_app_nishitatsu`を作成して下さい。
     ✅ DB作成権限のあるOSユーザで、下記コマンドを入力

     ``` shell
     createdb memo_app_nishitatsu
     ```

3. メモアプリのコードをダウンロードして下さい。
4. memo_app.rbのあるディレクトリに移動し、下記5,6のコマンドを実行して下さい。
5. 必要なgemのインストール

   ``` shell
   bundle
   ```

6. メモアプリの起動

   ``` shell
   bundle exec ruby memo_app.rb -p 4567
   ```

7. ブラウザのアドレスバーに下記を入力すると、index画面が表示されます。

   ``` shell
   http://localhost:4567/memo/index
   ```
