--Unified Bricks by Vsevolod Borislav (wowiamdiamonds)
--
--License: WTFPL
--
--Depends: default, bucket, unifieddyes, vessels
--
--Obviously, offers the same colors in unifieddyes.
--Thanks go to VanessaE for making unifieddyes, gentextures.sh, etc.

unifiedbricks = {}
unifiedbricks.old_static_list = {}
unifiedbricks.old_static_list_formals = {}

minetest.register_alias("unifieddyes:white","unifieddyes:white_paint")
minetest.register_alias("unifieddyes:lightgrey","unifieddyes:lightgrey_paint")
minetest.register_alias("unifieddyes:grey","unifieddyes:grey_paint")
minetest.register_alias("unifieddyes:darkgrey","unifieddyes:darkgrey_paint")

HUES = {
	"red",
	"orange",
	"yellow",
	"lime",
	"green",
	"aqua",
	"cyan",
	"skyblue",
	"blue",
	"violet",
	"magenta",
	"redviolet",
	"black",
	"darkgrey",
	"grey",
	"lightgrey",
	"white"
}
TYPES = {
	"clayblock_",
	"clay_",
	"brick_",
	"brickblock_",
	"multicolor_"
}
SATURATION = {
	"_s50",
	""
}
DARKNESS = {
	"dark_",
	"medium_",
	"",
	"light_"
}
--formal versions
FORMALHUES = {
	"Red",
	"Orange",
	"Yellow",
	"Lime",
	"Green",
	"Aqua",
	"Cyan",
	"Sky blue",
	"Blue",
	"Violet",
	"Magenta",
	"Red violet",
	"Black",
	"Dark grey",
	"Grey",
	"Light grey",
	"White"
}
FORMALTYPES = {
	" clay",
	" clay lump",
	" brick",
	" bricks",
	" multicolor bricks"
}
FORMALSATURATION = {
	" (low saturation)",
	""
}
FORMALDARKNESS = {
	"Dark ",
	"Medium ",
	"Bright ",
	"Light "
}

-- param2-coloring-enabled nodes

minetest.register_node("unifiedbricks:brickblock", {
	description = "Brick Block",
	tiles = {
		"unifiedbricks_brickblock.png",
		{ name = "unifiedbricks_mortar.png", color = 0xffffffff },
	},
	drawtype = "mesh",
	mesh = "unifiedbricks_brick_block.obj",
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette.png",
	is_ground_content = true,
	groups = {cracky=3, not_in_creative_inventory=1, ud_param2_colorable = 1},
	sounds = default.node_sound_stone_defaults(),
	after_dig_node = unifieddyes.after_dig_node,
	drop = "default:brick"
})

minetest.override_item("default:brick", {
	ud_replacement_node = "unifiedbricks:brickblock",
	groups = {cracky = 3, ud_param2_colorable = 1}
})

minetest.register_node("unifiedbricks:clayblock", {
	description = "Clay Block",
	tiles = {
		"unifiedbricks_clayblock.png",
	},
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette.png",
	is_ground_content = true,
	groups = {crumbly=3, not_in_creative_inventory=1, ud_param2_colorable = 1},
		sounds = default.node_sound_dirt_defaults({
			footstep = "",
		}),
	after_dig_node = unifieddyes.after_dig_node,
	drop = "default:clay"
})

minetest.override_item("default:clay", {
	ud_replacement_node = "unifiedbricks:clayblock",
	groups = {crumbly = 3, ud_param2_colorable = 1}
})

minetest.register_node("unifiedbricks:brickblock_multicolor_dark", {
	description = "Brick block (dark multicolor)",
	tiles = {
		"unifiedbricks_brickblock_multicolor_dark.png",
		{ name = "unifiedbricks_mortar.png", color = 0xffffffff },
	},
	drawtype = "mesh",
	mesh = "unifiedbricks_brick_block.obj",
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette.png",
	is_ground_content = true,
	groups = {cracky=3, ud_param2_colorable = 1},
	sounds = default.node_sound_stone_defaults(),
	after_dig_node = unifieddyes.after_dig_node,
})

minetest.register_node("unifiedbricks:brickblock_multicolor_medium", {
	description = "Brick block (medium multicolor)",
	tiles = {
		"unifiedbricks_brickblock_multicolor_medium.png",
		{ name = "unifiedbricks_mortar.png", color = 0xffffffff },
	},
	drawtype = "mesh",
	mesh = "unifiedbricks_brick_block.obj",
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette.png",
	is_ground_content = true,
	groups = {cracky=3, ud_param2_colorable = 1},
	sounds = default.node_sound_stone_defaults(),
	after_dig_node = unifieddyes.after_dig_node,
})

minetest.register_node("unifiedbricks:brickblock_multicolor_light", {
	description = "Brick block (light multicolor)",
	tiles = {
		"unifiedbricks_brickblock_multicolor_light.png",
		{ name = "unifiedbricks_mortar.png", color = 0xffffffff },
	},
	drawtype = "mesh",
	mesh = "unifiedbricks_brick_block.obj",
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette.png",
	is_ground_content = true,
	groups = {cracky=3, ud_param2_colorable = 1},
	sounds = default.node_sound_stone_defaults(),
	after_dig_node = unifieddyes.after_dig_node,
})

minetest.register_craft( {
   type = "shapeless",
   output = "unifiedbricks:brickblock_multicolor_dark",
   recipe = {
		"default:brick",
		"unifieddyes:grey",
		"unifieddyes:dark_grey",
		"unifieddyes:dark_grey"
	},
})

minetest.register_craft( {
   type = "shapeless",
   output = "unifiedbricks:brickblock_multicolor_medium",
   recipe = {
		"default:brick",
		"unifieddyes:white",
		"unifieddyes:grey",
		"unifieddyes:dark_grey"
	},
})

minetest.register_craft( {
   type = "shapeless",
   output = "unifiedbricks:brickblock_multicolor_light",
   recipe = {
		"default:brick",
		"unifieddyes:white",
		"unifieddyes:white",
		"unifieddyes:grey"
	},
})

-- static nodes

unifiedbricks.register_old_static_block = function(name, formalname, blocktype)
	table.insert(unifiedbricks.old_static_list, "unifiedbricks:"..blocktype.."_"..name)
	table.insert(unifiedbricks.old_static_list_formals, formalname)
end

for _, color in ipairs(HUES) do
	table.insert(unifiedbricks.old_static_list, "unifiedbricks:multicolor_dark_"..color)
	table.insert(unifiedbricks.old_static_list, "unifiedbricks:multicolor_medium_"..color)
	table.insert(unifiedbricks.old_static_list, "unifiedbricks:multicolor_light_"..color)
end

table.insert(unifiedbricks.old_static_list, "unifiedbricks:multicolor_darkgrey")
table.insert(unifiedbricks.old_static_list, "unifiedbricks:multicolor_grey")
table.insert(unifiedbricks.old_static_list, "unifiedbricks:multicolor_lightgrey")

--REGISTERS ALL STATIC NODES EXCEPT MULTICOLOR BRICK BLOCKS
for i = 1,17 do
	for j = 1,4 do
		if i > 12 then
			formalname = FORMALHUES[i]
			name = HUES[i]
			if j == 1 then
				unifiedbricks.register_old_static_block(name, formalname, "clayblock")
			elseif j == 4 then
				unifiedbricks.register_old_static_block(name, formalname, "brickblock")
			end
		else
			for k = 1,4 do
				if k == 4 then
					formalname = FORMALDARKNESS[k] .. FORMALHUES[i]
					name = DARKNESS[k] .. HUES[i]
					if j == 1 then
						unifiedbricks.register_old_static_block(name, formalname, "clayblock")
					elseif j == 4 then
						unifiedbricks.register_old_static_block(name, formalname, "brickblock")
					end
				else
					for l = 1,2 do
						formalname = FORMALDARKNESS[k] .. FORMALHUES[i] .. FORMALSATURATION[l]
						name = DARKNESS[k] .. HUES[i] .. SATURATION[l]
						if j == 1 then
							unifiedbricks.register_old_static_block(name, formalname, "clayblock")
						elseif j == 4 then
							unifiedbricks.register_old_static_block(name, formalname, "brickblock")
						end
					end
				end
			end
		end
	end
end

-- convert in-map static nodes to use param2 coloring

minetest.register_lbm({
	name = "unifiedbricks:convert_brickblocks",
	label = "Convert clay blocks and single-color brick blocks to use param2 color",
	run_at_every_load = true,
	nodenames = unifiedbricks.old_static_list,
	action = function(pos, node)

		local name = node.name
		local t = string.find(name, "_")
		local type = string.sub(name, 1, t - 1)
		local color1 = string.sub(name, t + 1)

		local color2 = string.gsub(color1, "grey", "_grey")
		if color2 == "_grey" then color2 = "grey" end

		local paletteidx, hue = unifieddyes.getpaletteidx("unifieddyes:"..color2)

		if string.find(type, "multicolor") then

			local newpalette = (hue*8)+1
			local shade

			if string.find(name, "dark") then
				shade = "dark"
			elseif string.find(name, "medium")
					or name == "unifiedbricks:multicolor_grey" then
				shade = "medium"
			else
				shade = "light"
			end
			if string.find(name, "grey") then
				newpalette = 2
			end

			minetest.set_node(pos, { name = "unifiedbricks:brickblock_multicolor_"..shade, param2 = newpalette })
			local meta = minetest.get_meta(pos)
			meta:set_string("dye", "unifieddyes:"..color1)
		elseif string.find(type, "brickblock") then
			minetest.set_node(pos, { name = "unifiedbricks:brickblock", param2 = paletteidx })
			local meta = minetest.get_meta(pos)
			meta:set_string("dye", "unifieddyes:"..color1)
		elseif string.find(type, "clayblock") then
			minetest.set_node(pos, { name = "unifiedbricks:clayblock", param2 = paletteidx })
			local meta = minetest.get_meta(pos)
			meta:set_string("dye", "unifieddyes:"..color1)
		end
	end
})

print("[UnifiedBricks] Loaded!")
