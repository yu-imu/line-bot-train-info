## 経路検索 Bot on Line
![line_photo1](https://user-images.githubusercontent.com/17560599/36638706-9d009976-1a3f-11e8-8f92-2099c5d13299.png)  
* **交通経路検索をlineのチャット上で行います**  
(注意) 現在はローカル環境でしか動きません。  

* **使用技術**  
[Messaging API](https://developers.line.me/ja/docs/messaging-api/reference)  
[探索関連API - 経路検索](https://dev.smt.docomo.ne.jp/?p=common_page&p_name=ekispert_search_course_extreme)  

|    tool      |   version    |
|:------------:|:------------:|
|    ruby      |    2.3.1     |
|ruby on rails |    5.0       |
|Redis server  |    4.0.6     |
|redis-cli     |    4.0.6     |
|mecab         |mecab-ipadic-neologd|  

* **セットアップ**  
 1. bundle exec rails server && ngrok http 3000
 2. redis-server && redis-cli  
[redis-serverが立ち上がらない時](https://askubuntu.com/questions/949119/error-when-starting-redis-server-address-already-in-use)  

* **仕様**  
 1. 駅名を入力する(１駅ずつ or ワンライナーでも可)
 2. 最短経路のリコメンドを表示
 3. 前のダイアor次のダイアをリコメンドする

* **開発の所感**  
交通経路の結果を出力する場合にbotというアプリケーションは向いてないことがわかった。
リアクティブな特徴が活かせてないのが勿体無い。

* **今後の展望**
本番環境にもリリースする予定です。
