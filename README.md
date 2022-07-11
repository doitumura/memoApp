# memoApp

### 開発(および動作確認)環境
- 言語

    ruby(3.1.2)

- OS

    Monterey(12.4)

### 使用手順
1. 以下のリンクからPostgreSQLをインストール

    https://www.postgresql.org/download/

1. PostgreSQLサーバーを起動(macOS)

    ```brew services start postgresql ```

1. PostgreSQLサーバーに接続

    ```psql postgres ```

1. 本アプリ用のデータベースを作成

    ```CREATE DATABASE memo_db; ```

1. PostgreSQLサーバーとの接続を切断

    ```\q ```

1. リポジトリをclone

    ```git clone https://github.com/doitumura/memoApp.git```

1. cloneしたリポジトリに移動

    ```cd memoApp```

1. branchをmemo_dbに変更

    ```git checkout memo_db```

1. gemをインストール

    ```bundle install```

1. アプリを起動

    ```bundle exec ruby app.rb```
    
1. ブラウザのアドレスバーからlocalhost:4567にアクセス
