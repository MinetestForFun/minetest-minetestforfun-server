# Maidroid

<img src=http://i.imgur.com/oWjrLtK.png>

この MOD は Maidroid というメイドのロボットと, その Maidroid に農業やプレイヤーの追跡など, 様々なことをさせるコア, それらに関連する種々のツールを提供します.
Minecraft の著名な MOD, littleMaidMob にインスパイアされて開発を始めました.

## 使い方

### Maidroid の卵の作成

1. 空の卵と Maidroid-Egg Writer を後に示すレシピに従ってクラフトテーブルで作成します.
2. Maidroid-Egg Writer を設置し, 右クリックして formspec を開きます.
3. `Egg` と書かれたスロットに先に作成しておいた空の卵, `Fuel` と書かれたスロットに石炭, `Dye` と書かれたスロットに染料を配置します.
4. すると, Maidroid-Egg Writer が起動し, 浮いた卵が回転を始めます.
5. しばらく待つと, 命の吹き込まれた Maidroid の卵が完成しますので, 再度 Maidroid-Egg Writer を右クリックし取り出してください.

### コアの作成

1. 空のコアと Core Writer を後に示すレシピに従ってクラフトテーブルで作成します.
2. Core Writer を設置し, 右クリックして formspec を開きます.
3. `Core` と書かれたスロットに先に作成しておいた空のコア, `Fuel` と書かれたスロットに石炭, `Dye` と書かれたスロットに染料を配置します.
4. すると, Core Writer が起動し, 上のコアが回転を始めます.
5. しばらく待つと, 情報が書き込まれたコアが完成しますので, 再度 Core Writer を右クリックし取り出してください.

### Maidroid の起動

1. 先に作成しておいた, 命の吹き込まれた Maidroid の卵を床に投げつけ, Maidroid を生成します.
2. 生成された Maidroid を右クリックし, `Core` と書かれたスロットに先ほど作成したコアを配置します.
3. すると, Maidroid はそのコアの情報に従って行動を始めます.

### レシピ / 染料と卵 / 染料とコア

クラフトテーブルで作成するノードやアイテムのレシピを以下に示します.

```
b = dye:black            c = default:cobble        d = default:diamond
f = farming:cotton       o = default:obsidian      p = default:paper
s = default:steel_ingot  w = bucket:bucket_water   z = default:bronze_ingot  

Core Writer      Egg Writer       Nametag          Empty Core       Empty Egg

| s | d | s |    | d | w | d |    |   | f |   |    | s | s | s |    | z | z | z |
| c | s | c |    | c | s | c |    | p | p | p |    | s | o | s |    | z | s | z |
| c | c | c |    | s | c | s |    | s | b | s |    | s | s | s |    | z | z | z |
```

次に, 染料と対応する卵から生まれる Maidroid について以下に示します.

<table>
<tr>
<td>White</td><td><img src=http://i.imgur.com/lsdq79e.png> Mk1</td>
<td></td>
<td>Grey</td><td><img src=http://i.imgur.com/9ffUTjB.png> Mk2</td>
<td></td>
<td>Dark Grey</td><td><img src=http://i.imgur.com/HWtLvqb.png> Mk3</td>
</tr>

<tr>
<td>Black</td><td><img src=http://i.imgur.com/GoHRTRC.png> Mk4</td>
<td></td>
<td>Blue</td><td><img src=http://i.imgur.com/JTZTCS9.png> Mk5</td>
<td></td>
<td>Cyan</td><td><img src=http://i.imgur.com/hHw6mbD.png> Mk6</td>
</tr>

<tr>
<td>Green</td><td><img src=http://i.imgur.com/YdzOgvM.png> Mk7</td>
<td></td>
<td>Dark Green</td><td><img src=http://i.imgur.com/UXB52Ce.png> Mk8</td>
<td></td>
<td>Yellow</td><td><img src=http://i.imgur.com/hcd9vk4.png> Mk9</td>
</tr>

<tr>
<td>Orange</td><td><img src=http://i.imgur.com/6UjS63j.png> Mk10</td>
<td></td>
<td>Brown</td><td><img src=http://i.imgur.com/ayz4uP3.png> Mk11</td>
<td></td>
<td>Red</td><td><img src=http://i.imgur.com/rqknHh7.png> Mk12</td>
</tr>

<tr>
<td>Pink</td><td><img src=http://i.imgur.com/UNALjMo.png> MK13</td>
<td></td>
<td>Magenta</td><td><img src=http://i.imgur.com/iorRtmf.png> Mk14</td>
<td></td>
<td>Violet</td><td><img src=http://i.imgur.com/UX3w1Cx.png> Mk15</td>
</tr>

</table>

最後に, 染料とコアとの対応と, 各コアの簡易的な説明を以下に示します.

<table>
<tr>
<td>Red</td><td><img src=http://i.imgur.com/DlMzSGK.png> Basic Core</td><td>プレイヤーを追跡する. 荷物持ちに使える.</td>
</tr>
<tr>
<td>Yellow</td><td><img src=http://i.imgur.com/ALor72m.png> Farming Core</td><td>農業を行う.</td>
</tr>
<tr>
<td>White</td><td><img src=http://i.imgur.com/ypI2Fs6.png> OCR Core</td><td>プログラムが書かれた本を読み実行. 要 pdisc MOD.</td>
</tr>
<tr>
<td>Orange</td><td>Torcher Core</td><td>プレイヤーを追跡し, 暗い所を松明で照らす.</td>
</tr>
</table>

## 各コアの詳細

### Basic Core

このコアが埋め込まれた Maidroid はプレイヤーを追跡します.
Maidroid 自体の場所移動に使えますし, あるいは荷物持ちくらいにはなると思われます.

### Farming Core

このコアが埋め込まれた Maidroid は農業をします.
Farming Core を埋め込んだ状態で種を持たせれば, 土壌に種を植え始めます.
また, 収穫の時期になったら自動で回収して回ります.
このコアが埋め込まれた状態では柵を飛び越えないので, 農地の周りを柵で囲むことをお勧めします.

### OCR Core

pdisc MOD と連携するコアです.
このコアが埋め込まれた Maidroid は, 自身のインベントリ内のプログラムが書かれた本を読み, そのプログラムを実行します. 例えば, 以下のようなプログラムが書かれた本を OCR Core が埋め込まれた Maidroid に読ませると, 一秒ごとにビープ音とジャンプをします. 本のタイトルは `main` としなければなりません.

```
start: sleep 1
beep
jump 0.9
jmp start
```

### Torcher Core

このコアが埋め込まれた Maidroid はプレイヤーを追跡し, 自分の周りが暗いと判断したら松明を設置し, 周りを照らしてくれます.
採掘の際には結構役に立つと思われます.

## 依存 MOD

- bucket
- default
- dye
- [pdisc?](https://github.com/HybridDog/pdisc)

## 必要条件

- Minetest v0.4.14 以降

## ライセンス

- Source Code : [LGPLv2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt) or later
- Resources : [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) or later
