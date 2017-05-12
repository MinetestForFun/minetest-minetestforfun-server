
bonemeal = {}


-- default crops
local crops = {
	{"farming:cotton_", 8, "farming:seed_cotton"},
	{"farming:wheat_", 8, "farming:seed_wheat"},
}


-- special pine check for nearby snow
local function pine_grow(pos)

	if minetest.find_node_near(pos, 1,
		{"default:snow", "default:snowblock", "default:dirt_with_snow"}) then

		default.grow_new_snowy_pine_tree(pos)
	else
		default.grow_new_pine_tree(pos)
	end
end


-- default saplings
local saplings = {
	{"default:sapling", default.grow_new_apple_tree, "soil"},
	{"default:junglesapling", default.grow_new_jungle_tree, "soil"},
	{"default:acacia_sapling", default.grow_new_acacia_tree, "soil"},
	{"default:aspen_sapling", default.grow_new_aspen_tree, "soil"},
	{"default:pine_sapling", pine_grow, "soil"},
}

-- helper tables ( "" denotes a blank item )
local green_grass = {
	"default:grass_2", "default:grass_3", "default:grass_4",
	"default:grass_5", "", ""
}

local dry_grass = {
	"default:dry_grass_2", "default:dry_grass_3", "default:dry_grass_4",
	"default:dry_grass_5", "", ""
}

local flowers = {
	"flowers:dandelion_white", "flowers:dandelion_yellow", "flowers:geranium",
	"flowers:rose", "flowers:tulip", "flowers:viola", ""
}

-- add additional bakedclay flowers if enabled
if minetest.get_modpath("bakedclay") then
	flowers[7] = "bakedclay:delphinium"
	flowers[8] = "bakedclay:thistle"
	flowers[9] = "bakedclay:lazarus"
	flowers[10] = "bakedclay:mannagrass"
	flowers[11] = ""
end

-- default biomes deco
local deco = {
	{"default:dirt_with_dry_grass", dry_grass, flowers},
	{"default:sand", {}, {"default:dry_shrub", "", "", ""} },
	{"default:desert_sand", {}, {"default:dry_shrub", "", "", ""} },
	{"default:silver_sand", {}, {"default:dry_shrub", "", "", ""} },
}


----- local functions


-- particles
local function particle_effect(pos)

	minetest.add_particlespawner({
		amount = 4,
		time = 0.15,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -1, y = 2, z = -1},
		maxvel = {x = 1, y = 4, z = 1},
		minacc = {x = -1, y = -1, z = -1},
		maxacc = {x = 1, y = 1, z = 1},
		minexptime = 1,
		maxexptime = 1,
		minsize = 1,
		maxsize = 3,
		texture = "bonemeal_particle.png",
	})
end


-- tree type check
local function grow_tree(pos, object)

	if type(object) == "table" and object.axiom then
		-- grow L-system tree
		minetest.remove_node(pos)
		minetest.spawn_tree(pos, object)

	elseif type(object) == "string" and minetest.registered_nodes[object] then
		-- place node
		minetest.set_node(pos, {name = object})

	elseif type(object) == "function" then
		-- function
		object(pos)
	end
end


-- sapling check
local function check_sapling(pos, nodename)

	-- what is sapling placed on?
	local under =  minetest.get_node({
		x = pos.x,
		y = pos.y - 1,
		z = pos.z
	})

	local can_grow, grow_on

	-- check list for sapling and function
	for n = 1, #saplings do

		if saplings[n][1] == nodename then

			grow_on = saplings[n][3]

			-- sapling grows on top of specific node
			if grow_on
			and grow_on ~= "soil"
			and grow_on ~= "sand"
			and grow_on == under.name then
				can_grow = true
			end

			-- sapling grows on top of soil (default)
			if can_grow == nil
			and (grow_on == nil or grow_on == "soil")
			and minetest.get_item_group(under.name, "soil") > 0 then
				can_grow = true
			end

			-- sapling grows on top of sand
			if can_grow == nil
			and grow_on == "sand"
			and minetest.get_item_group(under.name, "sand") > 0 then
				can_grow = true
			end

			-- check if we can grow sapling
			if can_grow then
				particle_effect(pos)
				grow_tree(pos, saplings[n][2])
				return
			end
		end
	end
end


-- crops check
local function check_crops(pos, nodename, strength)

	local stage = ""

	-- grow registered crops
	for n = 1, #crops do

		if string.find(nodename, crops[n][1])
		or nodename == crops[n][3] then

			-- get stage number or set to 0 for seed
			stage = tonumber( nodename:split("_")[2] ) or 0
			stage = math.min(stage + strength, crops[n][2])

			minetest.set_node(pos, {name = crops[n][1] .. stage})

			particle_effect(pos)

			return

		end

	end

end


-- check soil for specific decoration placement
local function check_soil(pos, nodename, strength)

	-- set radius according to strength
	local side = strength - 1
	local tall = math.max(strength - 2, 0)

	-- get area of land with free space above
	local dirt = minetest.find_nodes_in_area_under_air(
		{x = pos.x - side, y = pos.y - tall, z = pos.z - side},
		{x = pos.x + side, y = pos.y + tall, z = pos.z + side},
		{"group:soil", "group:sand"})

	-- set default grass and decoration
	local grass = green_grass
	local decor = flowers

	-- choose grass and decoration to use on dirt patch
	for n = 1, #deco do

		-- do we have a grass match?
		if nodename == deco[n][1] then
			grass = deco[n][2] or {}
			decor = deco[n][3] or {}
		end
	end

	local pos2, nod

	-- loop through soil
	for _,n in pairs(dirt) do

		pos2 = n

		pos2.y = pos2.y + 1

		-- place random decoration (rare)
		if math.random(1, 5) == 5 then
			nod = decor[math.random(1, #decor)] or ""
			if nod ~= "" then
				minetest.set_node(pos2, {name = nod})
			end
		else
			-- place random grass (common)
			nod = grass[math.random(1, #grass)] or ""
			if nod ~= "" then
				minetest.set_node(pos2, {name = nod})
			end
		end

		particle_effect(pos2)
	end
end


-- global functions


-- add to sapling list
-- {sapling node, schematic or function name, "soil"|"sand"|specific_node}
--e.g. {"default:sapling", default.grow_new_apple_tree, "soil"}

function bonemeal:add_sapling(list)

	for n = 1, #list do
		table.insert(saplings, list[n])
	end
end


-- add to crop list to force grow
-- {crop name start_, growth steps, seed node (if required)}
-- e.g. {"farming:wheat_", 8, "farming:seed_wheat"}
function bonemeal:add_crop(list)

	for n = 1, #list do
		table.insert(crops, list[n])
	end
end


-- add grass and flower/plant decoration for specific dirt types
--  {dirt_node, {grass_nodes}, {flower_nodes}
-- e.g. {"default:dirt_with_dry_grass", dry_grass, flowers}
function bonemeal:add_deco(list)

	for n = 1, #list do
		table.insert(deco, list[n])
	end
end


-- global on_use function for bonemeal
function bonemeal:on_use(pos, strength)

	-- get node pointed at
	local node = minetest.get_node(pos)

	-- return if nothing there
	if node.name == "ignore" then
		return
	end

	-- make sure strength is between 1 and 4
	strength = strength or 2
	strength = math.max(strength, 1)
	strength = math.min(strength, 4)

	-- grow grass and flowers
	if minetest.get_item_group(node.name, "soil") > 0
	or minetest.get_item_group(node.name, "sand") > 0 then
		check_soil(pos, node.name, strength)
		return
	end

	-- light check depending on strength (strength of 4 = no light needed)
	if (minetest.get_node_light(pos) or 0) < (12 - (strength * 3)) then
		return
	end

	-- check for tree growth if pointing at sapling
	if minetest.get_item_group(node.name, "sapling") > 0
	and math.random(1, (5 - strength)) == 1 then
		check_sapling(pos, node.name)
		return
	end

	-- check for crop growth
	check_crops(pos, node.name, strength)
end


----- items


-- mulch (strength 1)
minetest.register_craftitem("bonemeal:mulch", {
	description = "Mulch",
	inventory_image = "bonemeal_mulch.png",

	on_use = function(itemstack, user, pointed_thing)

		-- did we point at a node?
		if pointed_thing.type ~= "node" then
			return
		end

		-- is area protected?
		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			return
		end

		-- take item if not in creative
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end

		-- call global on_use function with strength of 1
		bonemeal:on_use(pointed_thing.under, 1)

		return itemstack
	end,
})

-- bonemeal (strength 2)
minetest.register_craftitem("bonemeal:bonemeal", {
	description = "Bone Meal",
	inventory_image = "bonemeal_item.png",

	on_use = function(itemstack, user, pointed_thing)

		-- did we point at a node?
		if pointed_thing.type ~= "node" then
			return
		end

		-- is area protected?
		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			return
		end

		-- take item if not in creative
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end

		-- call global on_use function with strength of 2
		bonemeal:on_use(pointed_thing.under, 2)

		return itemstack
	end,
})


-- fertiliser (strength 3)
minetest.register_craftitem("bonemeal:fertiliser", {
	description = "Fertiliser",
	inventory_image = "bonemeal_fertiliser.png",

	on_use = function(itemstack, user, pointed_thing)

		-- did we point at a node?
		if pointed_thing.type ~= "node" then
			return
		end

		-- is area protected?
		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			return
		end

		-- take item if not in creative
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end

		-- call global on_use function with strength of 3
		bonemeal:on_use(pointed_thing.under, 3)

		return itemstack
	end,
})


-- bone
minetest.register_craftitem("bonemeal:bone", {
	description = "Bone",
	inventory_image = "bonemeal_bone.png",
})


--- crafting recipes


-- bonemeal (from bone)
minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:bonemeal 2",
	recipe = {"bonemeal:bone"},
})

-- bonemeal (from player bones)
minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:bonemeal 4",
	recipe = {"bones:bones"},
})

-- mulch
minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:mulch 4",
	recipe = {
		"group:tree", "group:leaves", "group:leaves",
		"group:leaves", "group:leaves", "group:leaves",
		"group:leaves", "group:leaves", "group:leaves"
	},
})

-- fertiliser
minetest.register_craft({
	type = "shapeless",
	output = "bonemeal:fertiliser 2",
	recipe = {"bonemeal:bonemeal", "bonemeal:mulch"},
})


-- add bones to dirt
minetest.override_item("default:dirt", {
	drop = {
		max_items = 1,
		items = {
			{
				items = {"bonemeal:bone", "default:dirt"},
				rarity = 30,
			},
			{
				items = {"default:dirt"},
			}
		}
	},
})


-- add support for other mods
dofile(minetest.get_modpath("bonemeal") .. "/mods.lua")

print ("[MOD] Bonemeal loaded")
