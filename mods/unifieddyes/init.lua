--[[

Unified Dyes

This mod provides an extension to the Minetest 0.4.x dye system

==============================================================================

Copyright (C) 2012-2013, Vanessa Ezekowitz
Email: vanessaezekowitz@gmail.com

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

==============================================================================

--]]

--=====================================================================

unifieddyes = {}

local creative_mode = minetest.setting_getbool("creative_mode")

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

-- helper functions for other mods that use this one

local HUES = {
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
	"redviolet"
}

local HUES2 = {
	"Red",
	"Orange",
	"Yellow",
	"Lime",
	"Green",
	"Aqua",
	"Cyan",
	"Sky-blue",
	"Blue",
	"Violet",
	"Magenta",
	"Red-violet"
}

local default_dyes = {
	"black",
	"blue",
	"brown",
	"cyan",
	"dark_green",
	"dark_grey",
	"green",
	"grey",
	"magenta",
	"orange",
	"pink",
	"red",
	"violet",
	"white",
	"yellow"
}

-- code borrowed from homedecor

function unifieddyes.select_node(pointed_thing)
	local pos = pointed_thing.under
	local node = minetest.get_node_or_nil(pos)
	local def = node and minetest.registered_nodes[node.name]

	if not def or not def.buildable_to then
		pos = pointed_thing.above
		node = minetest.get_node_or_nil(pos)
		def = node and minetest.registered_nodes[node.name]
	end
	return def and pos, def
end

function unifieddyes.is_buildable_to(placer_name, ...)
	for _, pos in ipairs({...}) do
		local node = minetest.get_node_or_nil(pos)
		local def = node and minetest.registered_nodes[node.name]
		if not (def and def.buildable_to) or minetest.is_protected(pos, placer_name) then
			return false
		end
	end
	return true
end

function unifieddyes.get_hsv(name) -- expects a node/item name
	local hue = ""
	local a,b
	for _, i in ipairs(HUES) do
		a,b = string.find(name, "_"..i)
		if a and not ( string.find(name, "_redviolet") and i == "red" ) then
			hue = i
			break
		end
	end

	if string.find(name, "_light_grey")     then hue = "light_grey"
	elseif string.find(name, "_lightgrey")  then hue = "light_grey"
	elseif string.find(name, "_dark_grey")  then hue = "dark_grey"
	elseif string.find(name, "_darkgrey")   then hue = "dark_grey"
	elseif string.find(name, "_grey")       then hue = "grey"
	elseif string.find(name, "_white")      then hue = "white"
	elseif string.find(name, "_black")      then hue = "black"
	end

	local sat = ""
	if string.find(name, "_s50")    then sat = "_s50" end

	local val = ""
	if string.find(name, "dark_")   then val = "dark_"   end
	if string.find(name, "medium_") then val = "medium_" end
	if string.find(name, "light_")  then val = "light_"  end

	return hue, sat, val
end

-- code borrowed from cheapie's plasticbox mod

function unifieddyes.getpaletteidx(color, is_color_fdir)
	local origcolor = color
	local aliases = {
		["pink"] = "light_red",
		["brown"] = "dark_orange",
	}

	local grayscale = {
		["white"] = 1,
		["light_grey"] = 2,
		["grey"] = 3,
		["dark_grey"] = 4,
		["black"] = 5,
	}

	local grayscale_wallmounted = {
		["white"] = 0,
		["light_grey"] = 1,
		["grey"] = 2,
		["dark_grey"] = 3,
		["black"] = 4,
	}

	local hues = {
		["red"] = 1,
		["orange"] = 2,
		["yellow"] = 3,
		["lime"] = 4,
		["green"] = 5,
		["aqua"] = 6,
		["cyan"] = 7,
		["skyblue"] = 8,
		["blue"] = 9,
		["violet"] = 10,
		["magenta"] = 11,
		["redviolet"] = 12,
	}

	local hues_wallmounted = {
		["red"] = 0,
		["orange"] = 1,
		["yellow"] = 2,
		["green"] = 3,
		["cyan"] = 4,
		["blue"] = 5,
		["violet"] = 6,
		["magenta"] = 7
	}

	local shades = {
		[""] = 1,
		["s50"] = 2,
		["light"] = 3,
		["medium"] = 4,
		["mediums50"] = 5,
		["dark"] = 6,
		["darks50"] = 7,
	}

	local shades_wallmounted = {
		[""] = 1,
		["medium"] = 2,
		["dark"] = 3
	}

	if string.sub(color,1,4) == "dye:" then
		color = string.sub(color,5,-1)
	elseif string.sub(color,1,12) == "unifieddyes:" then
		color = string.sub(color,13,-1)
	else
		return
	end

	if is_color_fdir == "wallmounted" then
		if grayscale_wallmounted[color] then
			return (grayscale_wallmounted[color] * 8), 0
		end
	elseif is_color_fdir then
		if grayscale[color] then
			return (grayscale[color] * 32), 0
		end
	else
		if grayscale[color] then
			return grayscale[color], 0
		end
	end

	local shade = ""
	if string.sub(color,1,6) == "light_" then
		shade = "light"
		color = string.sub(color,7,-1)
	elseif string.sub(color,1,7) == "medium_" then
		shade = "medium"
		color = string.sub(color,8,-1)
	elseif string.sub(color,1,5) == "dark_" then
		shade = "dark"
		color = string.sub(color,6,-1)
	end
	if string.sub(color,-4,-1) == "_s50" then
		shade = shade.."s50"
		color = string.sub(color,1,-5)
	end

	if is_color_fdir == "wallmounted" then
		if color == "brown" then return 48,1
		elseif color == "pink" then return 56,7
		elseif color == "blue" and shade == "light" then return 40,5
		elseif hues_wallmounted[color] and shades_wallmounted[shade] then
			return (shades_wallmounted[shade] * 64 + hues_wallmounted[color] * 8), hues_wallmounted[color]
		end
	else
		if color == "brown" then
			color = "orange"
			shade = "dark"
		elseif color == "pink" then
			color = "red"
			shade = "light"
		end
		if hues[color] and shades[shade] then
			if is_color_fdir then
				return (shades[shade] * 32), hues[color]
			else
				return (hues[color] * 8 + shades[shade]), hues[color]
			end
		end
	end
end

function unifieddyes.after_dig_node(pos, oldnode, oldmetadata, digger)
	local prevdye

	if oldmetadata and oldmetadata.fields then
		prevdye = oldmetadata.fields.dye
	end

	local inv = digger:get_inventory()

	if prevdye and not (inv:contains_item("main", prevdye) and creative_mode) and minetest.registered_items[prevdye] then
		if inv:room_for_item("main", prevdye) then
			inv:add_item("main", prevdye)
		else
			minetest.add_item(pos, prevdye)
		end
	end
end

function unifieddyes.on_use(itemstack, player, pointed_thing)

	if not pointed_thing or pointed_thing.type == "nothing" then return end  -- if "using" the dye on air

	local pos = minetest.get_pointed_thing_position(pointed_thing)
	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	local playername = player:get_player_name()

	-- if the node has an on_punch defined, bail out and call that instead, unless "sneak" is pressed.
	if not player:get_player_control().sneak then
		local onpunch = nodedef.on_punch(pos, node, player, pointed_thing)
		if onpunch then
			return onpunch
		end
	end

	-- if the target is unknown, has no groups defined, or isn't UD-colorable, just bail out
	if not (nodedef and nodedef.groups and nodedef.groups.ud_param2_colorable) then
		minetest.chat_send_player(playername, "That node can't be colored.")
		return
	end

	local newnode = nodedef.ud_replacement_node
	local is_color_fdir

	if nodedef.paramtype2 == "color" then
		is_color_fdir = false
	elseif nodedef.paramtype2 == "colorfacedir"
		then is_color_fdir = true
	elseif nodedef.paramtype2 == "colorwallmounted"
		then is_color_fdir = "wallmounted"
	end

	if minetest.is_protected(pos, playername) and not minetest.check_player_privs(playername, {protection_bypass=true}) then
		minetest.record_protection_violation(pos, playername)
		return
	end

	local stackname = itemstack:get_name()
	local pos2 = unifieddyes.select_node(pointed_thing)
	local paletteidx, hue = unifieddyes.getpaletteidx(stackname, is_color_fdir)

	if paletteidx then

		local meta = minetest.get_meta(pos)
		local prevdye = meta:get_string("dye")
		local inv = player:get_inventory()

		if not (inv:contains_item("main", prevdye) and creative_mode) and minetest.registered_items[prevdye] then
			if inv:room_for_item("main", prevdye) then
				inv:add_item("main", prevdye)
			else
				minetest.add_item(pos, prevdye)
			end
		end

		meta:set_string("dye", stackname)

		if prevdye == stackname then
			local a,b = string.find(stackname, ":")
			minetest.chat_send_player(playername, "That node is already "..string.sub(stackname, a + 1).."." )
			return
		elseif not creative_mode then
			itemstack:take_item()
		end

		node.param2 = paletteidx

		local oldpaletteidx, oldhuenum = unifieddyes.getpaletteidx(prevdye, is_color_fdir)
		local oldnode = minetest.get_node(pos)

		local oldhue = nil
		for _, i in ipairs(HUES) do
			if string.find(oldnode.name, "_"..i) and not
				( string.find(oldnode.name, "_redviolet") and i == "red" ) then
				oldhue = i
				break
			end
		end

		if newnode then -- this path is used when the calling mod want to supply a replacement node
			if is_color_fdir == "wallmounted" then
				node.param2 = paletteidx + (minetest.get_node(pos).param2 % 8)
			elseif is_color_fdir then  -- we probably need to change the hue of the node too
				if oldhue ~=0 then -- it's colored, not grey
					if oldhue ~= nil then -- it's been painted before
						if hue ~= 0 then -- the player's wielding a colored dye
							newnode = string.gsub(newnode, "_"..oldhue, "_"..HUES[hue])
						else -- it's a greyscale dye
							newnode = string.gsub(newnode, "_"..oldhue, "_grey")
						end
					else -- it's never had a color at all
						if hue ~= 0 then -- and if the wield is greyscale, don't change the node name
							newnode = string.gsub(newnode, "_grey", "_"..HUES[hue])
						end
					end
				else
					if hue ~= 0 then  -- greyscale dye on greyscale node = no hue change
						newnode = string.gsub(newnode, "_grey", "_"..HUES[hue])
					end
				end
				node.param2 = paletteidx + (minetest.get_node(pos).param2 % 32)
			else
				node.param2 = paletteidx
			end
			node.name = newnode
			minetest.swap_node(pos, node)
			if not creative_mode then
				return itemstack
			end
		else -- this path is used when you're just painting an existing node, rather than replacing one.
			newnode = oldnode  -- note that here, newnode/oldnode are a full node, not just the name.
			if is_color_fdir == "wallmounted" then
				newnode.param2 = paletteidx + (minetest.get_node(pos).param2 % 8)
			elseif is_color_fdir then
				if oldhue then
					if hue ~= 0 then
						newnode.name = string.gsub(newnode.name, "_"..oldhue, "_"..HUES[hue])
					else
						newnode.name = string.gsub(newnode.name, "_"..oldhue, "_grey")
					end
				elseif string.find(minetest.get_node(pos).name, "_grey") and hue ~= 0 then
					newnode.name = string.gsub(newnode.name, "_grey", "_"..HUES[hue])
				end
				newnode.param2 = paletteidx + (minetest.get_node(pos).param2 % 32)
			else
				newnode.param2 = paletteidx
			end
			minetest.swap_node(pos, newnode)
			if not creative_mode then
				return itemstack
			end
		end
	else
		local a,b = string.find(stackname, ":")
		if a then
			minetest.chat_send_player(playername, "That node can't be colored "..string.sub(stackname, a + 1).."." )
		end
	end
end

-- re-define default dyes slightly, to add on_use

for _, color in ipairs(default_dyes) do
	minetest.override_item("dye:"..color, {
		on_use = unifieddyes.on_use
	})
end

-- Items/recipes needed to generate the few base colors that are not
-- provided by the standard dyes mod.

-- Lime

minetest.register_craftitem(":dye:lime", {
	description = S("Lime Dye"),
	inventory_image = "unifieddyes_lime.png",
	groups = { dye=1, excolor_lime=1, unicolor_lime=1, not_in_creative_inventory=1 },
	on_use = unifieddyes.on_use
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:lime 2",
       recipe = {
               "dye:yellow",
               "dye:green",
		},
})

-- Aqua

minetest.register_craftitem(":dye:aqua", {
	description = S("Aqua Dye"),
	inventory_image = "unifieddyes_aqua.png",
	groups = { dye=1, excolor_aqua=1, unicolor_aqua=1, not_in_creative_inventory=1 },
	on_use = unifieddyes.on_use
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:aqua 2",
       recipe = {
               "dye:cyan",
               "dye:green",
		},
})

-- Sky blue

minetest.register_craftitem(":dye:skyblue", {
	description = S("Sky-blue Dye"),
	inventory_image = "unifieddyes_skyblue.png",
	groups = { dye=1, excolor_sky_blue=1, unicolor_sky_blue=1, not_in_creative_inventory=1 },
	on_use = unifieddyes.on_use
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:skyblue 2",
       recipe = {
               "dye:cyan",
               "dye:blue",
		},
})

-- Red-violet

minetest.register_craftitem(":dye:redviolet", {
	description = S("Red-violet Dye"),
	inventory_image = "unifieddyes_redviolet.png",
	groups = { dye=1, excolor_red_violet=1, unicolor_red_violet=1, not_in_creative_inventory=1 },
	on_use = unifieddyes.on_use
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:redviolet 2",
       recipe = {
               "dye:red",
               "dye:magenta",
		},
})


-- Light grey

minetest.register_craftitem(":dye:light_grey", {
	description = S("Light Grey Dye"),
	inventory_image = "unifieddyes_lightgrey.png",
	groups = { dye=1, excolor_lightgrey=1, unicolor_light_grey=1, not_in_creative_inventory=1 },
	on_use = unifieddyes.on_use
})

minetest.register_craft( {
       type = "shapeless",
       output = "dye:light_grey 2",
       recipe = {
               "dye:grey",
               "dye:white",
		},
})

-- Extra craft for black dye

minetest.register_craft( {
       type = "shapeless",
       output = "dye:black 4",
       recipe = {
               "default:coal_lump",
		},
})

-- Extra craft for dark grey dye

minetest.register_craft( {
       type = "shapeless",
       output = "dye:dark_grey 3",
       recipe = {
               "dye:black",
               "dye:black",
               "dye:white",
		},
})

-- Extra craft for light grey dye

minetest.register_craft( {
       type = "shapeless",
       output = "dye:light_grey 3",
       recipe = {
               "dye:black",
               "dye:white",
               "dye:white",
		},
})

-- Extra craft for green dye

minetest.register_craft( {
       type = "shapeless",
       output = "dye:green 4",
       recipe = {
               "default:cactus",
		},
})

-- =================================================================

-- Generate all of additional variants of hue, saturation, and
-- brightness.

-- "s50" in a file/item name means "saturation: 50%".
-- Brightness levels in the textures are 33% ("dark"), 66% ("medium"),
-- 100% ("full", but not so-named), and 150% ("light").


for i = 1, 12 do

	local hue = HUES[i]
	local hue2 = HUES2[i]

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:dark_" .. hue .. "_s50 2",
        recipe = {
                "dye:" .. hue,
                "dye:dark_grey",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:dark_" .. hue .. "_s50 4",
        recipe = {
                "dye:" .. hue,
                "dye:black",
                "dye:black",
		"dye:white"
	        },
	})

	if hue == "green" then

		minetest.register_craft( {
		type = "shapeless",
		output = "dye:dark_green 3",
		recipe = {
		        "dye:" .. hue,
		        "dye:black",
		        "dye:black",
			},
		})
	else
		minetest.register_craft( {
		type = "shapeless",
		output = "unifieddyes:dark_" .. hue .. " 3",
		recipe = {
		        "dye:" .. hue,
		        "dye:black",
		        "dye:black",
			},
		})
	end

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. "_s50 2",
        recipe = {
                "dye:" .. hue,
                "dye:grey",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. "_s50 3",
        recipe = {
                "dye:" .. hue,
		"dye:black",
                "dye:white",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:medium_" .. hue .. " 2",
        recipe = {
                "dye:" .. hue,
                "dye:black",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:" .. hue .. "_s50 2",
        recipe = {
                "dye:" .. hue,
                "dye:grey",
                "dye:white",
	        },
	})

	minetest.register_craft( {
        type = "shapeless",
        output = "unifieddyes:" .. hue .. "_s50 4",
        recipe = {
                "dye:" .. hue,
                "dye:white",
                "dye:white",
                "dye:black",
	        },
	})

	if hue ~= "red" then
		minetest.register_craft( {
		type = "shapeless",
		output = "unifieddyes:light_" .. hue .. " 2",
		recipe = {
			"dye:" .. hue,
			"dye:white",
			},
		})
	end

	minetest.register_craftitem("unifieddyes:dark_" .. hue .. "_s50", {
		description = S("Dark " .. hue2 .. " Dye (low saturation)"),
		inventory_image = "unifieddyes_dark_" .. hue .. "_s50.png",
		groups = { dye=1, ["unicolor_dark_"..hue.."_s50"]=1, not_in_creative_inventory=1 },
		on_use = unifieddyes.on_use
	})

	if hue ~= "green" then
		minetest.register_craftitem("unifieddyes:dark_" .. hue, {
			description = S("Dark " .. hue2 .. " Dye"),
			inventory_image = "unifieddyes_dark_" .. hue .. ".png",
			groups = { dye=1, ["unicolor_dark_"..hue]=1, not_in_creative_inventory=1 },
			on_use = unifieddyes.on_use
		})
	end

	minetest.register_craftitem("unifieddyes:medium_" .. hue .. "_s50", {
		description = S("Medium " .. hue2 .. " Dye (low saturation)"),
		inventory_image = "unifieddyes_medium_" .. hue .. "_s50.png",
		groups = { dye=1, ["unicolor_medium_"..hue.."_s50"]=1, not_in_creative_inventory=1 },
		on_use = unifieddyes.on_use
	})

	minetest.register_craftitem("unifieddyes:medium_" .. hue, {
		description = S("Medium " .. hue2 .. " Dye"),
		inventory_image = "unifieddyes_medium_" .. hue .. ".png",
		groups = { dye=1, ["unicolor_medium_"..hue]=1, not_in_creative_inventory=1 },
		on_use = unifieddyes.on_use
	})

	minetest.register_craftitem("unifieddyes:" .. hue .. "_s50", {
		description = S(hue2 .. " Dye (low saturation)"),
		inventory_image = "unifieddyes_" .. hue .. "_s50.png",
		groups = { dye=1, ["unicolor_"..hue.."_s50"]=1, not_in_creative_inventory=1 },
		on_use = unifieddyes.on_use
	})

	if hue ~= "red" then
		minetest.register_craftitem("unifieddyes:light_" .. hue, {
			description = S("Light " .. hue2 .. " Dye"),
			inventory_image = "unifieddyes_light_" .. hue .. ".png",
			groups = { dye=1, ["unicolor_light_"..hue]=1, not_in_creative_inventory=1 },
			on_use = unifieddyes.on_use
		})
	end
	minetest.register_alias("unifieddyes:"..hue, "dye:"..hue)
	minetest.register_alias("unifieddyes:pigment_"..hue, "dye:"..hue)
end

minetest.register_alias("unifieddyes:light_red",  "dye:pink")
minetest.register_alias("unifieddyes:dark_green", "dye:dark_green")
minetest.register_alias("unifieddyes:black",      "dye:black")
minetest.register_alias("unifieddyes:darkgrey",   "dye:dark_grey")
minetest.register_alias("unifieddyes:dark_grey",   "dye:dark_grey")
minetest.register_alias("unifieddyes:grey",       "dye:grey")
minetest.register_alias("unifieddyes:lightgrey",  "dye:light_grey")
minetest.register_alias("unifieddyes:light_grey",  "dye:light_grey")
minetest.register_alias("unifieddyes:white",      "dye:white")

minetest.register_alias("unifieddyes:white_paint", "dye:white")
minetest.register_alias("unifieddyes:titanium_dioxide", "dye:white")
minetest.register_alias("unifieddyes:lightgrey_paint", "dye:light_grey")
minetest.register_alias("unifieddyes:grey_paint", "dye:grey")
minetest.register_alias("unifieddyes:darkgrey_paint", "dye:dark_grey")
minetest.register_alias("unifieddyes:carbon_black", "dye:black")

print(S("[UnifiedDyes] Loaded!"))

