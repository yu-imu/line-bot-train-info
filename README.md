## README
**交通経路検索をlineのチャット上で行います。**
![画像](https://user-images.githubusercontent.com/17560599/36638594-60b9cecc-1a3c-11e8-9423-6b1caa588603.PNG)
created at 2018.2.22  

注意) これは、ローカル環境でしか動きません。  

* **使用技術**  
[line messenger api] (https://developers.line.me/ja/docs/messaging-api/reference)  

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
[redis-serverが立ち上がらない時] (https://askubuntu.com/questions/949119/error-when-starting-redis-server-address-already-in-use)  

* **仕様**  
1. 駅名を入力する(１駅ずつ or ワンライナーでも可)
2. 最短経路のリコメンドを表示
3. 前のダイアor次のダイアをリコメンドする

* **開発の所感**  
交通経路の結果を出力する場合にbotというアプリケーションは向いてないことがわかった。
リアクティブな特徴が活かせてないのが勿体無い。  
