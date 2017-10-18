ARKitを使ってスクラム看板作る
====
![AR看板](sample.gif)

## 背景
スクラムかんばんのタスクを付箋に書く時間が勿体無い。
最近出たARKitを使って、空間にPBLを出すというアプローチをした。

- かんばんのスペースを取らない
- キーボード入力で手軽に空間にPBLをきりだせる

という２点を今回は目指した。

## どういうものを作ったか
QRコードを読み取り、QRから読み取ったURL(PBL一覧を返す)のレスポンスからPBL群を取得。
それをAR機能を使って空間に配置する簡単な仕組み

## 完成品
gifの通りのものができた。できたことできなかったことを挙げて行く。
- できたこと
 - 空間にPBLを表示させることはできた。
 - Socket機能を使えば、自分が空間に投稿したPBLを他の人の画面にも表示できる。
 - QRコードの読み取り先をサーバサイドにして、かんばん要らずにできた。
- できなかったこと(多すぎるのでクリティカルなものだけ)
 - ARマーカー的なことはできなかった(機能的に.....絶望)
 - ARで配置するオブジェクト(PBL)の位置は主観的なものしか保存できないので、
 　他人の画面に、全く同じ位置にPBLを表示させることはできない(工夫が必要)。
今回は、QRにスマホを向けてもらうのを前提として、ある程度上の問題をごまかした(誤魔化せてない)

## 結論
- なんとか形になってよかった。
- オブジェクトをタッチして移動させるみたいなこともできるので、Socket機能でリアルタイムにPBL移動を同期できる(公式でそういう動画があっただけ)
- ARで配置するオブジェクトの位置を客観的に伝えらレルようになれば、本当にARかんばんできそう