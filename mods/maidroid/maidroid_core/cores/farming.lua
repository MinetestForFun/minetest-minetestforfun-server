------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local state = {
	WALK_RANDOMLY = 0,
	WALK_TO_PLANT = 1,
	WALK_TO_MOW   = 2,
	PLANT         = 3,
	MOW           = 4,
}

local target_plants = {
	"farming:cotton_8",
	"farming:wheat_8",
}

local _aux = maidroid_core._aux

local FIND_PATH_TIME_INTERVAL = 20
local CHANGE_DIRECTION_TIME_INTERVAL = 30
local MAX_WALK_TIME = 120

-- is_plantable_place reports whether maidroid can plant any seed.
local function is_plantable_place(pos)
	local node = minetest.get_node(pos)
	local lpos = vector.add(pos, {x = 0, y = -1, z = 0})
	local lnode = minetest.get_node(lpos)
	return node.name == "air"
		and minetest.get_item_group(lnode.name, "soil") > 1
end

-- is_mowable_place reports whether maidroid can mow.
local function is_mowable_place(pos)
	local node = minetest.get_node(pos)
	for _, plant in ipairs(target_plants) do
		if plant == node.name then
			return true
		end
	end
	return false
end


local walk_randomly, walk_to_plant_and_mow_common, plant, mow
local to_walk_randomly, to_walk_to_plant, to_walk_to_mow, to_plant, to_mow

local function on_start(self)
	self.object:setacceleration{x = 0, y = -10, z = 0}
	self.object:setvelocity{x = 0, y = 0, z = 0}
	self.state = state.WALK_RANDOMLY
	self.time_counters = {}
	self.path = nil
	to_walk_randomly(self)
end

local function on_stop(self)
	self.object:setvelocity{x = 0, y = 0, z = 0}
	self.state = nil
	self.time_counters = nil
	self.path = nil
	self:set_animation(maidroid.animation_frames.STAND)
end

local function is_near(self, pos, distance)
	local p = self.object:getpos()
	-- p.y = p.y + 0.5
	return vector.distance(p, pos) < distance
end

local searching_range = {x = 5, y = 2, z = 5}

walk_randomly = function(self, dtime)
	if self.time_counters[1] >= FIND_PATH_TIME_INTERVAL then
		self.time_counters[1] = 0
		self.time_counters[2] = self.time_counters[2] + 1

		local wield_stack = self:get_wield_item_stack()
		if minetest.get_item_group(wield_stack:get_name(), "seed") > 0
		or self:has_item_in_main(function(itemname)	return (minetest.get_item_group(itemname, "seed") > 0) end) then
			local destination = _aux.search_surrounding(self.object:getpos(), is_plantable_place, searching_range)
			if destination ~= nil then
				local path = minetest.find_path(self.object:getpos(), destination, 10, 1, 1, "A*")

				if path ~= nil then -- to walk to plant state.
					to_walk_to_plant(self, path, destination)
					return
				end
			end
		end
		-- if couldn't find path to plant, try to mow.
		local destination = _aux.search_surrounding(self.object:getpos(), is_mowable_place, searching_range)
		if destination ~= nil then
			local path = minetest.find_path(self.object:getpos(), destination, 10, 1, 1, "A*")
			if path ~= nil then -- to walk to mow state.
				to_walk_to_mow(self, path, destination)
				return
			end
		end
		-- else do nothing.
		return

	elseif self.time_counters[2] >= CHANGE_DIRECTION_TIME_INTERVAL then
		self.time_counters[1] = self.time_counters[1] + 1
		self.time_counters[2] = 0
		self:change_direction_randomly()
		return
	else
		self.time_counters[1] = self.time_counters[1] + 1
		self.time_counters[2] = self.time_counters[2] + 1

		local velocity = self.object:getvelocity()
		if velocity.y == 0 then
			local front_node = self:get_front_node()

			if minetest.get_item_group(front_node.name, "fence") > 0 then
				self:change_direction_randomly()
			elseif front_node.name ~= "air" and minetest.registered_nodes[front_node.name] ~= nil
			and minetest.registered_nodes[front_node.name].walkable then
				self.object:setvelocity{x = velocity.x, y = 6, z = velocity.z}
			end
		end
		return
	end
end

to_walk_randomly = function(self)
	self.state = state.WALK_RANDOMLY
	self.time_counters[1] = 0
	self.time_counters[2] = 0
	self:change_direction_randomly()
	self:set_animation(maidroid.animation_frames.WALK)
end

to_walk_to_plant = function(self, path, destination)
	self.state = state.WALK_TO_PLANT
	self.path = path
	self.destination = destination
	self.time_counters[1] = 0 -- find path interval
	self.time_counters[2] = 0
	self:change_direction(self.path[1])
	self:set_animation(maidroid.animation_frames.WALK)
end

to_walk_to_mow = function(self, path, destination)
	self.state = state.WALK_TO_MOW
	self.path = path
	self.destination = destination
	self.time_counters[1] = 0 -- find path interval
	self.time_counters[2] = 0
	self:change_direction(self.path[1])
	self:set_animation(maidroid.animation_frames.WALK)
end

to_plant = function(self)
	local wield_stack = self:get_wield_item_stack()
	if minetest.get_item_group(wield_stack:get_name(), "seed") > 0
	or self:move_main_to_wield(function(itemname)	return (minetest.get_item_group(itemname, "seed") > 0) end) then
		self.state = state.PLANT
		self.time_counters[1] = 0
		self.object:setvelocity{x = 0, y = 0, z = 0}
		self:set_animation(maidroid.animation_frames.MINE)
		self:set_yaw_by_direction(vector.subtract(self.destination, self.object:getpos()))
		return
	else
		to_walk_randomly(self)
		return
	end
end

to_mow = function(self)
	self.state = state.MOW
	self.time_counters[1] = 0
	self.object:setvelocity{x = 0, y = 0, z = 0}
	self:set_animation(maidroid.animation_frames.MINE)
	self:set_yaw_by_direction(vector.subtract(self.destination, self.object:getpos()))
end

walk_to_plant_and_mow_common = function(self, dtime)
	if is_near(self, self.destination, 1.5) then
		if self.state == state.WALK_TO_PLANT then
			to_plant(self)
			return
		elseif self.state == state.WALK_TO_MOW then
			to_mow(self)
			return
		end
	end

	if self.time_counters[2] >= MAX_WALK_TIME then -- time over.
		to_walk_randomly(self)
		return
	end

	self.time_counters[1] = self.time_counters[1] + 1
	self.time_counters[2] = self.time_counters[2] + 1

	if self.time_counters[1] >= FIND_PATH_TIME_INTERVAL then
		self.time_counters[1] = 0
		local path = minetest.find_path(self.object:getpos(), self.destination, 10, 1, 1, "A*")
		if path == nil then
			to_walk_randomly(self)
			return
		end
		self.path = path
	end

	-- follow path
	if is_near(self, self.path[1], 0.5) then
		table.remove(self.path, 1)

		if #self.path == 0 then -- end of path
			if self.state == state.WALK_TO_PLANT then
				to_plant(self)
				return
			elseif self.state == state.WALK_TO_MOW then
				to_mow(self)
				return
			end
		else -- else next step, follow next path.
			self:change_direction(self.path[1])
		end

	else
		-- if maidroid is stopped by obstacles, the maidroid must jump.
		local velocity = self.object:getvelocity()
		if velocity.y == 0 then
			local front_node = self:get_front_node()
			if front_node.name ~= "air" and minetest.registered_nodes[front_node.name] ~= nil
			and minetest.registered_nodes[front_node.name].walkable
			and not (minetest.get_item_group(front_node.name, "fence") > 0) then
				self.object:setvelocity{x = velocity.x, y = 6, z = velocity.z}
			end
		end
	end
end

plant = function(self, dtime)
	if self.time_counters[1] >= 15 then
		if is_plantable_place(self.destination) then
			local stack = self:get_wield_item_stack()
			local itemname = stack:get_name()

			local pointed_thing = {
				type = "node",
				under = vector.add(self.destination, {x = 0, y = -1, z = 0}),
				above = self.destination,
			}
			farming.place_seed(stack, minetest.get_player_by_name(self.owner_name), pointed_thing, stack:get_name())

			stack:take_item(1)
			self:set_wield_item_stack(stack)
		end
		to_walk_randomly(self)
		return
	else
		self.time_counters[1] = self.time_counters[1] + 1
	end
end

mow = function(self, dtime)
	if self.time_counters[1] >= 15 then
		if is_mowable_place(self.destination) then
			local destnode = minetest.get_node(self.destination)
			minetest.remove_node(self.destination)
			local stacks = minetest.get_node_drops(destnode.name)

			for _, stack in ipairs(stacks) do
				local leftover = self:add_item_to_main(stack)
				minetest.add_item(self.destination, leftover)
			end
		end
		to_walk_randomly(self)
		return
	else
		self.time_counters[1] = self.time_counters[1] + 1
	end
end

local function on_step(self, dtime)
	if self.state == state.WALK_RANDOMLY then
		walk_randomly(self, dtime)
	elseif self.state == state.WALK_TO_PLANT or self.state == state.WALK_TO_MOW then
		walk_to_plant_and_mow_common(self, dtime)
	elseif self.state == state.PLANT then
		plant(self, dtime)
	elseif self.state == state.MOW then
		mow(self, dtime)
	end
end

maidroid.register_core("maidroid_core:farming", {
	description      = "maidroid core : farming",
	inventory_image  = "maidroid_core_farming.png",
	on_start         = on_start,
	on_stop          = on_stop,
	on_resume        = on_start,
	on_pause         = on_stop,
	on_step          = on_step,
})
