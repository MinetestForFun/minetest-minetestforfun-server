# playeranim
Makes the head, and the right arm when you’re mining, face the way you’re facing, similar to Minecraft. Compatible with 3d_armor. Forked from the animplus mod, which was an ugly hack.

The head only turns up and down relative to the body, except it turns slightly to the right/left when you strafe right/left. When you turn the body turns with the head.

Works in multiplayer, I tested it on a local server.

Configuration
-------------

This mod supports 2 versions of the player model:
- The old version: v1 (before nov. 2016)
- The new version: v2 (after nov. 2016)
(see also init.lua)

As there is no automatic way to determine which version is used, this must be manually configured in `init.lua`.

Symptoms of having configured the incorrect player model:
- In rest, arms are raised up, and are either detached from the body, or are too close to the body
- Cape (if visible) points upward


Created by Rui914, this document was written by sloantothebone.
