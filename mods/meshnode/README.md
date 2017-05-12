Meshnodes for Minetest [meshnode]
=================================

**Mod Version:** 0.3.0

**Minetest Version:** 0.4.14 or later

**Depends:** default

Description
-----------
Meshnodes is a mod that transforms ordinary minetest nodes into a connected
array of replica entities to which players can attach to and manoeuvre.

To use, simply build or place a model using nodes with a supported drawtype
then place a meshnode controller in an appropriate position. Now use the
special 'glue' that you will find in the controller node's inventory to 
connect your structure. Alternatively, if you are using worldedit, you can
use the position markers to define the extents of your model.

When everything is connected you should return the 'glue' to the controller
to enable activation. Once activated, players can then attach themselves
to the controller or restore the model back to nodes. Restored models can
be easily reconnected using the 'Connect from meta positions' option.

Please note that the 'glue' bottles are unique to a controller's position
and are only useable within a limited range.

**Supported Drawtypes**

I have done my best to include support for most of the common nodes that
are useful for building ships etc, like fences, xpanes and walls including
support for all default stairs and slabs in full 6d rotation. It may or
may not work with other decorative nodeboxes/meshnodes, the best way to
find out is to simply try it.

Exceptions include flowing liquids, wallmounted nodes, rails or any node
with non-generated wield or inventory images. Some drawtypes have only
partial support, like 'plantlike' for example.

**Construction Advice**

Place the controller node in the direction you wish to face when you attach
to it and always try to make your models hollow wherever possible.

Controls
--------      
```
[Up]	Forward
[Down]	Reverse
[Left]	Turn Left
[Right]	Turn Right
[Jump]	Up
[Sneak]	Down
[RMB]	Interact
```
Crafting
--------
By default crafting is enabled in singleplayer mode only.

**Meshnode Controller** [meshnode:controller]
<table>
 <tr>
  <td>[default:bronzeblock]</td>
  <td>[default:diamondblock]</td>
  <td>[default:bronzeblock]</td>
 </tr>
 <tr>
  <td>[default:obsidian_block]</td>
  <td>[default:steelblock]</td>
  <td>[default:goldblock]</td>
 </tr>
  <tr>
  <td>[default:bronzeblock]</td>
  <td>[default:steelblock]</td>
  <td>[default:bronzeblock]</td>
 </tr>
</table>

Multiplayer
-----------
Take care if you use this mod on a public server, while I have done my
best to support basic protection, I am sure this mod could still provide
serious potential for grief in the hands of the wrong people.

By default the controller node will only be available via `/give[me]` and
requires the 'meshnode' privilege to be effective, however, non-privileged
players will still be able to attach to and operate pre-activated models.

Note that you will probably need to increase `max_objects_per_block` to
something a little higher than the default 64 to avoid server warnings and
broken models. You can set `meshnode_autoconf = true` to automatically
increase that limit to 4096 which, in theory, equates to one solid map-block
full of meshnodes, though I would not advise testing that on live server.

Blacklist
---------
A global blacklist table is stored is in `meshnode.blacklist` keyed by item
name, in multiplayer mode the following nodes are blacklisted by default.
```
meshnode.blacklist["default:chest_locked"] = true
meshnode.blacklist["default:water_source"] = true
meshnode.blacklist["default:river_water_source"] = true
meshnode.blacklist["default:lava_source"] = true
```
Configuration
-------------
The global config table is stored `meshnode.config` and can overridden by
adding the config name prefixed with 'meshnode_' to your minetest.conf file.

**Example:** (multiplayer defaults)
```
meshnode_max_speed = 2
meshnode_max_lift = 1
meshnode_yaw_amount = 0.017
meshnode_max_radius = 8
meshnode_show_in_creative = false
meshnode_enable_crafting = false
meshnode_autoconf = false
```
Note that speed, lift, yaw and radius may still be altered by other mods after
the initial start-up via the global `meshnode.config` table.

API
---
I would like to think that this mod could be used as the base for other mods
like airships or sailing ships or perhaps even some fancy construction tool.

For this reason I have exposed everything that I thought might be potentially
useful under the `meshnode` namespace. I would hope that the source code is
reasonably self-explanatory.

Know Issues
-----------
Active objects sometimes disappear following a re-start/connect. This could
be for a number or reasons including /clearobjects or a minetest bug. For this
reason you are advised to always 'restore' your model to 'real' nodes before
logging out or moving any significant distance away from it.

The player controlling the entity may appear to be connected to the wrong
part of the model when viewed by a player that was not present during the
initial attachment. Currently the only solution is for the operator to
detach then re-attach to the model in the presence of said player.

