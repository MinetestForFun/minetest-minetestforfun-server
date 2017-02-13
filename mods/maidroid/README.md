# Maidroid

<img src=http://i.imgur.com/oWjrLtK.png>

This mod is inspired littleMaidMob mod (for Minecraft), and provides maid robots called 'maidroid', cores that command them to do farming, following their owner and so on, involved tools.

## How to Use

### Create Maidroid Eggs

1. Create an empty egg and Maidroid-Egg Writer by following the recipe below.
2. Place Maidroid-Egg Writer and open formspec by right-clicking it.
3. Put an empty egg into the slot labeled `Egg`, a coal into `Fuel`, and a dye into `Dye`.
4. Then, Maidroid-Egg Writer activates.
5. A short time later, a new maidroid egg will be created.

### Create Cores

1. Create an empty core and Core Writer by following the recipe below.
2. Place Core Writer and open formspec by right-clicking it.
3. Put an empty core into the slot labeled `Core`, a coal into `Fuel`, and a dye into `Dye`.
4. Then, Core Writer activates.
5. A short time later, a new core will be created.

### Activate Maidroid

1. Throw the egg created, then a new maidroid will be spawned.
2. Open formspec by right-clicking the maidroid, and put the core created into `Core` slot.
3. Then, the maidroid will be activated.

### Recipes / Dye and Egg / Dye and Core

```
b = dye:black            c = default:cobble        d = default:diamond
f = farming:cotton       o = default:obsidian      p = default:paper
s = default:steel_ingot  w = bucket:bucket_water   z = default:bronze_ingot  

Core Writer      Egg Writer       Nametag          Empty Core       Empty Egg

| s | d | s |    | d | w | d |    |   | f |   |    | s | s | s |    | z | z | z |
| c | s | c |    | c | s | c |    | p | p | p |    | s | o | s |    | z | s | z |
| c | c | c |    | s | c | s |    | s | b | s |    | s | s | s |    | z | z | z |
```

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

<table>
<tr>
<td>Red</td><td>Basic Core</td><td>Maidroids embeded this core will follow a player.</td>
</tr>
<tr>
<td>Yellow</td><td>Farming Core</td><td>Maidroids embeded this core will do farming. Embed this core and put seed into them, then they will plant the seeds. And the plant will be grown, they mow it. The farmlang should be surrounded by fences, because maidroids embeded this core cannot jump over fences.</td>
</tr>
<tr>
<td>White</td><td>OCR Core</td><td>Maidroids embeded this core will read a book written a program in their inventory, and execute the program. Program example:
<pre><code>start: sleep 1
beep
jump 0.9
jmp start
</code></pre>
</tr>
<tr>
<td>Orange</td><td>Torcher Core</td><td>Maidroids embeded this core will follow a player, and put torch if it is dark.</td>
</tr>
</table>

## Dependencies

- bucket
- default
- dye
- [pdisc](https://github.com/HybridDog/pdisc)?

## Requirements

- Minetest v0.4.14 or later

## Forum Topic

The forum topic for this mod on the Minetest Forums is located at:

- https://forum.minetest.net/viewtopic.php?f=9&t=14808

## License

- The source code of Maidroid is available under the [LGPLv2.1](https://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt) or later license.
- The resouces included in Maidroid are available under the [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) or later license.
