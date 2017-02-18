unifiedbricks

Code license: WTFPL
Texture license: WTFPL

depends: unifieddyes, default

Adds configurable clay blocks, clay lumps, bricks, and brick blocks. Includes
all of the colors that unifieddyes offers (which amounts to 89 clayblocks, clay
lumps, bricks, brick blocks, leaving 356 total).

Now returns glass bottles and empty buckets when appropriate.

Settings at the top of init.lua:
	SETTING_allow_default_coloring = 1
		When set to 1, default clay + unifieddyes dye = unifiedbricks clay lump
	SETTING_allow_hues = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
		Each number represents a hue (red, orange, yellow ...). When a value is
		set to 0, that hue is disabled.
	SETTING_allow_types = {1,1,1,1}
		Same, except these represent clay blocks, clay lumps, etc.
	SETTING_allow_saturation = {1,1}
		Represents low saturation and full saturation, respectively.
	SETTING_allow_darkness = {1,1,1,1}
		Represents dark, medium, bright, and light colors, respectively.

	Furthermore, a list of names is included below that, from which you can
	change, for example, "red" to "mahogany".

WARNING: if you remove something important, such as clay lumps, you'll have to
cheat to get some items.
	
If you don't like what I did, tell me or use one of github's fancy features or 
do it yourself or whatever. Hint: I would absolutely love to have some better
looking textures, especially the brick and clay textures.

Used VanessaE's gentextures.sh to change the texture colors.
