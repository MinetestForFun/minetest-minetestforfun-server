------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

-- maidroid.animation_frames represents the animation frame data
-- of "models/maidroid.b3d".
maidroid.animation_frames = {
	STAND     = {x =   1, y =  78},
	SIT       = {x =  81, y = 160},
	LAY       = {x = 162, y = 165},
	WALK      = {x = 168, y = 187},
	MINE      = {x = 189, y = 198},
	WALK_MINE = {x = 200, y = 219},
}

-- maidroid.registered_maidroids represents a table that contains
-- definitions of maidroid registered by maidroid.register_maidroid.
maidroid.registered_maidroids = {}

-- maidroid.registered_cores represents a table that contains
-- definitions of core registered by maidroid.register_core.
maidroid.registered_cores = {}

-- maidroid.registered_eggs represents a table that contains
-- definition of egg registered by maidroid.register_egg.
maidroid.registered_eggs = {}

-- maidroid.is_core reports whether a item is a core item by the name.
function maidroid.is_core(item_name)
	if maidroid.registered_cores[item_name] then
		return true
	end
	return false
end

-- maidroid.is_maidroid reports whether a name is maidroid's name.
function maidroid.is_maidroid(name)
	if maidroid.registered_maidroids[name] then
		return true
	end
	return false
end

---------------------------------------------------------------------

-- maidroid.maidroid represents a table that contains common methods
-- for maidroid object.
-- this table must be contains by a metatable.__index of maidroid self tables.
-- minetest.register_entity set initial properties as a metatable.__index, so
-- this table's methods must be put there.
maidroid.maidroid = {}

-- maidroid.maidroid.get_inventory returns a inventory of a maidroid.
function maidroid.maidroid.get_inventory(self)
	return minetest.get_inventory {
		type = "detached",
		name = self.inventory_name,
	}
end

-- maidroid.maidroid.get_core_name returns a name of a maidroid's current core.
function maidroid.maidroid.get_core_name(self)
	local inv = self:get_inventory()
	return inv:get_stack("core", 1):get_name()
end

-- maidroid.maidroid.get_core returns a maidroid's current core definition.
function maidroid.maidroid.get_core(self)
	local name = self:get_core_name()
	if name ~= "" then
		return maidroid.registered_cores[name]
	end
	return nil
end

-- maidroid.maidroid.get_nearest_player returns a player object who
-- is the nearest to the maidroid.
function maidroid.maidroid.get_nearest_player(self, range_distance)
	local player, min_distance = nil, range_distance
	local position = self.object:getpos()

	local all_objects = minetest.get_objects_inside_radius(position, range_distance)
	for _, object in pairs(all_objects) do
		if object:is_player() then
			local player_position = object:getpos()
			local distance = vector.distance(position, player_position)

			if distance < min_distance then
				min_distance = distance
				player = object
			end
		end
	end
	return player
end

-- maidroid.maidroid.get_front returns a position in front of the maidroid.
function maidroid.maidroid.get_front(self)
	local direction = self:get_look_direction()
	if math.abs(direction.x) >= 0.5 then
		if direction.x > 0 then	direction.x = 1	else direction.x = -1 end
	else
		direction.x = 0
	end

	if math.abs(direction.z) >= 0.5 then
		if direction.z > 0 then	direction.z = 1	else direction.z = -1 end
	else
		direction.z = 0
	end

	return vector.add(vector.round(self.object:getpos()), direction)
end

-- maidroid.maidroid.get_front_node returns a node that exists in front of the maidroid.
function maidroid.maidroid.get_front_node(self)
	local front = self:get_front()
	return minetest.get_node(front)
end

-- maidroid.maidroid.get_look_direction returns a normalized vector that is
-- the maidroid's looking direction.
function maidroid.maidroid.get_look_direction(self)
	local yaw = self.object:getyaw()
	return vector.normalize{x = -math.sin(yaw), y = 0.0, z = math.cos(yaw)}
end

-- maidroid.maidroid.set_animation sets the maidroid's animation.
-- this method is wrapper for self.object:set_animation.
function maidroid.maidroid.set_animation(self, frame)
	self.object:set_animation(frame, 15, 0)
end

-- maidroid.maidroid.set_yaw_by_direction sets the maidroid's yaw
-- by a direction vector.
function maidroid.maidroid.set_yaw_by_direction(self, direction)
	self.object:setyaw(math.atan2(direction.z, direction.x) - math.pi / 2)
end

-- maidroid.maidroid.get_wield_item_stack returns the maidroid's wield item's stack.
function maidroid.maidroid.get_wield_item_stack(self)
	local inv = self:get_inventory()
	return inv:get_stack("wield_item", 1)
end

-- maidroid.maidroid.set_wield_item_stack sets maidroid's wield item stack.
function maidroid.maidroid.set_wield_item_stack(self, stack)
	local inv = self:get_inventory()
	inv:set_stack("wield_item", 1, stack)
end

-- maidroid.maidroid.add_item_to_main add item to main slot.
-- and returns leftover.
function maidroid.maidroid.add_item_to_main(self, stack)
	local inv = self:get_inventory()
	return inv:add_item("main", stack)
end

-- maidroid.maidroid.move_main_to_wield moves itemstack from main to wield.
-- if this function fails then returns false, else returns true.
function maidroid.maidroid.move_main_to_wield(self, pred)
	local inv = self:get_inventory()
	local main_size = inv:get_size("main")

	for i = 1, main_size do
		local stack = inv:get_stack("main", i)
		if pred(stack:get_name()) then
			local wield_stack = inv:get_stack("wield_item", 1)
			inv:set_stack("wield_item", 1, stack)
			inv:set_stack("main", i, wield_stack)
			return true
		end
	end
	return false
end

-- maidroid.maidroid.is_named reports the maidroid is still named.
function maidroid.maidroid.is_named(self)
	return self.nametag ~= ""
end

-- maidroid.maidroid.has_item_in_main reports whether the maidroid has item.
function maidroid.maidroid.has_item_in_main(self, pred)
	local inv = self:get_inventory()
	local stacks = inv:get_list("main")

	for _, stack in ipairs(stacks) do
		local itemname = stack:get_name()
		if pred(itemname) then
			return true
		end
	end
end

-- maidroid.maidroid.change_direction change direction to destination and velocity vector.
function maidroid.maidroid.change_direction(self, destination)
  local position = self.object:getpos()
  local direction = vector.subtract(destination, position)
	direction.y = 0
  local velocity = vector.multiply(vector.normalize(direction), 1.5)

  self.object:setvelocity(velocity)
	self:set_yaw_by_direction(direction)
end

-- maidroid.maidroid.change_direction_randomly change direction randonly.
function maidroid.maidroid.change_direction_randomly(self)
	local direction = {
		x = math.random(0, 5) * 2 - 5,
		y = 0,
		z = math.random(0, 5) * 2 - 5,
	}
	local velocity = vector.multiply(vector.normalize(direction), 1.5)
	self.object:setvelocity(velocity)
	self:set_yaw_by_direction(direction)
end

-- maidroid.maidroid.update_infotext updates the infotext of the maidroid.
function maidroid.maidroid.update_infotext(self)
	local infotext = ""
	local core_name = self:get_core_name()

	if core_name ~= "" then
		if self.pause then
			infotext = infotext .. "this maidroid is paused\n"
		else
			infotext = infotext .. "this maidroid is active\n"
		end
		infotext = infotext .. "[Core] : " .. core_name .. "\n"
	else
		infotext = infotext .. "this maidroid is inactive\n[Core] : None\n"
	end
	infotext = infotext .. "[Owner] : " .. self.owner_name
	self.object:set_properties{infotext = infotext}
end

---------------------------------------------------------------------

-- maidroid.manufacturing_data represents a table that contains manufacturing data.
-- this table's keys are product names, and values are manufacturing numbers
-- that has been already manufactured.
maidroid.manufacturing_data = (function()
	local file_name = minetest.get_worldpath() .. "/manufacturing_data"

	minetest.register_on_shutdown(function()
		local file = io.open(file_name, "w")
		file:write(minetest.serialize(maidroid.manufacturing_data))
		file:close()
	end)

	local file = io.open(file_name, "r")
	if file ~= nil then
		local data = file:read("*a")
		file:close()
		return minetest.deserialize(data)
	end
	return {}
end) ()

--------------------------------------------------------------------

-- register empty item entity definition.
-- this entity may be hold by maidroid's hands.
do
	minetest.register_craftitem("maidroid:dummy_empty_craftitem", {
		wield_image = "maidroid_dummy_empty_craftitem.png",
	})

	local function on_activate(self, staticdata)
		self.object:set_properties{textures={"maidroid:dummy_empty_craftitem"}}
	end

	local function on_step(self, dtime)
		if self.maidroid_object then
			local luaentity = self.maidroid_object:get_luaentity()
			if luaentity then
				local stack = luaentity:get_wield_item_stack()

				if stack:get_name() ~= self.itemname then
					if stack:is_empty() then
						self.itemname = ""
						self.object:set_properties{textures={"maidroid:dummy_empty_craftitem"}}
					else
						self.itemname = stack:get_name()
						self.object:set_properties{textures={self.itemname}}
					end
				end
				return
			end
		end

		-- if cannot find maidroid, delete empty item.
		self.object:remove()
		return
	end

	minetest.register_entity("maidroid:dummy_item", {
		hp_max		     = 1,
		visual		     = "wielditem",
		visual_size	   = {x = 0.025, y = 0.025},
		collisionbox	 = {0, 0, 0, 0, 0, 0},
		physical	     = false,
		textures	     = {"air"},
		on_activate	   = on_activate,
		on_step        = on_step,
		itemname       = "",
		maidroid_object  = nil
	})
end

---------------------------------------------------------------------

-- maidroid.register_core registers a definition of a new core.
function maidroid.register_core(core_name, def)
	maidroid.registered_cores[core_name] = def

	minetest.register_tool(core_name, {
		stack_max       = 1,
		description     = def.description,
		inventory_image = def.inventory_image,
	})
end

-- maidroid.register_egg registers a definition of a new egg.
function maidroid.register_egg(egg_name, def)
	maidroid.registered_eggs[egg_name] = def

	minetest.register_tool(egg_name, {
		description     = def.description,
		inventory_image = def.inventory_image,
		stack_max       = 1,

		on_use = function(itemstack, user, pointed_thing)
			if pointed_thing.above ~= nil and def.product_name ~= nil then
				-- set maidroid's direction.
				local new_maidroid = minetest.add_entity(pointed_thing.above, def.product_name)
				new_maidroid:get_luaentity():set_yaw_by_direction(
					vector.subtract(user:getpos(), new_maidroid:getpos())
				)
				new_maidroid:get_luaentity().owner_name = user:get_player_name()
				new_maidroid:get_luaentity():update_infotext()

				itemstack:take_item()
				return itemstack
			end
			return nil
		end,
	})
end

-- maidroid.register_maidroid registers a definition of a new maidroid.
function maidroid.register_maidroid(product_name, def)
	maidroid.registered_maidroids[product_name] = def

	-- initialize manufacturing number of a new maidroid.
	if maidroid.manufacturing_data[product_name] == nil then
		maidroid.manufacturing_data[product_name] = 0
	end

	-- create_inventory creates a new inventory, and returns it.
	local function create_inventory(self)
		self.inventory_name = product_name .. "_" .. tostring(self.manufacturing_number)
		local inventory = minetest.create_detached_inventory(self.inventory_name, {
			on_put = function(inv, listname, index, stack, player)
				if listname == "core" then
					local core_name = stack:get_name()
					local core = maidroid.registered_cores[core_name]
					core.on_start(self)

					self:update_infotext()
				end
			end,

			allow_put = function(inv, listname, index, stack, player)
				-- only cores can put to a core inventory.
				if listname == "main" then
					return stack:get_count()
				elseif listname == "core" and maidroid.is_core(stack:get_name()) then
					return stack:get_count()
				elseif listname == "wield_item" then
					return 0
				end
				return 0
			end,

			on_take = function(inv, listname, index, stack, player)
				if listname == "core" then
					local core_name = stack:get_name()
					local core = maidroid.registered_cores[core_name]
					core.on_stop(self)

					self:update_infotext()
				end
			end,

			allow_take = function(inv, listname, index, stack, player)
				if listname == "wield_item" then
					return 0
				end
				return stack:get_count()
			end,

			on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
				if to_list == "core" or from_list == "core" then
					local core_name = inv:get_stack(to_list, to_index):get_name()
					local core = maidroid.registered_cores[core_name]

					if to_list == "core" then
						core.on_start(self)
					elseif from_list == "core" then
						core.on_stop(self)
					end

					self:update_infotext()
				end
			end,

			allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
				if to_list == "wield_item" then
					return 0
				end

				if to_list == "main" then
					return count
				elseif to_list == "core" and maidroid.is_core(inv:get_stack(from_list, from_index):get_name()) then
					return count
				end

				return 0
			end,
		})

		inventory:set_size("main", 16)
		inventory:set_size("core",  1)
		inventory:set_size("wield_item", 1)

		return inventory
	end

	-- create_formspec_string returns a string that represents a formspec definition.
	local function create_formspec_string(self)
		return "size[8,9]"
			.. default.gui_bg
			.. default.gui_bg_img
 			.. default.gui_slots
			.. "list[detached:"..self.inventory_name..";main;0,0;4,4;]"
			.. "label[4.5,1;core]"
			.. "list[detached:"..self.inventory_name..";core;4.5,1.5;1,1;]"
			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.2;8,3;8]"
			.. "label[5.5,1;wield]"
			.. "list[detached:"..self.inventory_name..";wield_item;5.5,1.5;1,1;]"
	end

	-- on_activate is a callback function that is called when the object is created or recreated.
	local function on_activate(self, staticdata)
		-- parse the staticdata, and compose a inventory.
		if staticdata == "" then
			self.manufacturing_number = maidroid.manufacturing_data[product_name]
			maidroid.manufacturing_data[product_name] = maidroid.manufacturing_data[product_name] + 1
			create_inventory(self)

		else
			-- if static data is not empty string, this object has beed already created.
			local data = minetest.deserialize(staticdata)

			self.manufacturing_number = data["manufacturing_number"]
			self.nametag = data["nametag"]
			self.owner_name = data["owner_name"]

			local inventory = create_inventory(self)
			for list_name, list in pairs(data["inventory"]) do
				inventory:set_list(list_name, list)
			end
		end

		self:update_infotext()

		self.object:set_nametag_attributes{
			text = self.nametag
		}

		-- attach dummy item to new maidroid.
		local dummy_item = minetest.add_entity(self.object:getpos(), "maidroid:dummy_item")
		dummy_item:set_attach(self.object, "Arm_R", {x = 0.065, y = 0.50, z = -0.15}, {x = -45, y = 0, z = 0})
		dummy_item:get_luaentity().maidroid_object = self.object

		local core = self:get_core()
		if core ~= nil then
			core.on_start(self)
		else
			self.object:setvelocity{x = 0, y = 0, z = 0}
			self.object:setacceleration{x = 0, y = -10, z = 0}
		end
	end

	-- get_staticdata is a callback function that is called when the object is destroyed.
	local function get_staticdata(self)
		local inventory = self:get_inventory()
		local data = {
			["manufacturing_number"] = self.manufacturing_number,
			["nametag"] = self.nametag,
			["owner_name"] = self.owner_name,
			["inventory"] = {},
		}

		-- set lists.
		for list_name, list in pairs(inventory:get_lists()) do
			data["inventory"][list_name] = {}

			for i, item in ipairs(list) do
				data["inventory"][list_name][i] = item:to_string()
			end
		end

		return minetest.serialize(data)
	end

	-- maidroid.maidroid.pickup_item pickup items placed and put it to main slot.
	local function pickup_item(self)
		local pos = self.object:getpos()
		local radius = 1.0
		local all_objects = minetest.get_objects_inside_radius(pos, radius)

		for _, obj in ipairs(all_objects) do
			if not obj:is_player() and obj:get_luaentity() then
				local itemstring = obj:get_luaentity().itemstring

				if minetest.registered_items[itemstring] ~= nil then
					local inv = self:get_inventory()
					local stack = ItemStack(itemstring)
					local leftover = inv:add_item("main", stack)

					minetest.add_item(obj:getpos(), leftover)
					obj:get_luaentity().itemstring = ""
					obj:remove()
				end
			end
		end
	end

	-- on_step is a callback function that is called every delta times.
	local function on_step(self, dtime)
		-- if owner didn't login, the maidroid does nothing.
		if not minetest.get_player_by_name(self.owner_name) then
			return
		end

		-- pickup surrounding item.
		pickup_item(self)

		-- do core method.
		local core = self:get_core()
		if (not self.pause) and core then
			core.on_step(self, dtime)
		end
	end

	-- on_rightclick is a callback function that is called when a player right-click them.
	local function on_rightclick(self, clicker)
		minetest.show_formspec(
			clicker:get_player_name(),
			"maidroid:gui",
			create_formspec_string(self)
		)
	end

	-- on_punch is a callback function that is called when a player punch then.
	local function on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local core = self:get_core()
		if self.pause == true then
			self.pause = false
			if core then
				core.on_resume(self)
			end
		else
			self.pause = true
			if core then
				core.on_pause(self)
			end
		end

		self:update_infotext()
	end

	-- register a definition of a new maidroid.
	minetest.register_entity(product_name, {
		-- basic initial properties
		hp_max                       = def.hp_max,
		weight                       = def.weight,
		mesh                         = def.mesh,
		textures                     = def.textures,

		physical                     = true,
		visual                       = "mesh",
		visual_size                  = {x = 7.5, y = 7.5},
		collisionbox                 = {-0.25, -0.375, -0.25, 0.25, 0.75, 0.25},
		is_visible                   = true,
		makes_footstep_sound         = true,
		infotext                     = "",
		nametag                      = "",

		-- extra initial properties
		pause                        = false,
		manufacturing_number         = -1,
		owner_name                   = "",

		-- callback methods.
		on_activate                  = on_activate,
		on_step                      = on_step,
		on_rightclick                = on_rightclick,
		on_punch                     = on_punch,
		get_staticdata               = get_staticdata,

		-- extra methods.
		get_inventory                = maidroid.maidroid.get_inventory,
		get_core                     = maidroid.maidroid.get_core,
		get_core_name                = maidroid.maidroid.get_core_name,
		get_nearest_player           = maidroid.maidroid.get_nearest_player,
		get_front                    = maidroid.maidroid.get_front,
		get_front_node               = maidroid.maidroid.get_front_node,
		get_look_direction           = maidroid.maidroid.get_look_direction,
		set_animation                = maidroid.maidroid.set_animation,
		set_yaw_by_direction         = maidroid.maidroid.set_yaw_by_direction,
		get_wield_item_stack         = maidroid.maidroid.get_wield_item_stack,
		set_wield_item_stack         = maidroid.maidroid.set_wield_item_stack,
		add_item_to_main             = maidroid.maidroid.add_item_to_main,
		move_main_to_wield           = maidroid.maidroid.move_main_to_wield,
		is_named                     = maidroid.maidroid.is_named,
		has_item_in_main             = maidroid.maidroid.has_item_in_main,
		change_direction             = maidroid.maidroid.change_direction,
		change_direction_randomly    = maidroid.maidroid.change_direction_randomly,
		update_infotext              = maidroid.maidroid.update_infotext,
	})

	-- register maidroid egg.
	maidroid.register_egg(product_name .. "_egg", {
		description     = product_name .. " egg",
		inventory_image = def.egg_image,
		product_name    = product_name,
	})
end
