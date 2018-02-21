# README

交通経路検索をlineのチャット上で行います。

注意) これは、ローカル環境でしか動きません。

* 使用技術
line messenger api https://developers.line.me/ja/docs/messaging-api/reference/
ruby 2.3.1 ruby on rails 5.0
Redis server v4.0.6 redis-cli 4.0.6

* セットアップ
bundle exec rails server && ngrok http 3000
redis-server && redis-cli

* 開発の所感
交通経路の結果を出力する場合にbotというアプリケーションは向いてないことがわかった。リアクティブな特徴が活かせてないのが勿体無い。

created at 2018.2.22
