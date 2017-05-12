------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local state = {IDLE = 0, ACCOMPANY = 1}

local PLACE_TIME = 4

local function on_start(self)
	self.state = state.IDLE
	self.object:setacceleration{x = 0, y = -10, z = 0}
	self.object:setvelocity{x = 0, y = 0, z = 0}
	self.time_counter = -1
	self.is_placing = false
end

local function on_stop(self)
	self.state = nil
	self.object:setvelocity{x = 0, y = 0, z = 0}
	self:set_animation(maidroid.animation_frames.STAND)
	self.time_counter = nil
	self.is_placing = nil
end

local function is_dark(pos)
	local light_level = minetest.get_node_light(pos)
	return light_level <= 5
end

local function on_step(self, dtime)
	if self.is_placing then
		if self.time_counter >= PLACE_TIME then
			self.time_counter = -1
			if self.state == state.IDLE then
				self:set_animation(maidroid.animation_frames.STAND)
			elseif self.state == state.ACCOMPANY then
				self:set_animation(maidroid.animation_frames.WALK)
			end

			local owner = minetest.get_player_by_name(self.owner_name)
			local wield_stack = self:get_wield_item_stack()
			local front = self:get_front()

			local pointed_thing = {
				type = "node",
				under = vector.add(front, {x = 0, y = -1, z = 0}),
				above = front,
			}

			if wield_stack:get_name() == "default:torch" then
				local res_stack, success = minetest.item_place_node(wield_stack, owner, pointed_thing)
				if success then
					res_stack:take_item(1)
					self:set_wield_item_stack(res_stack)
				end
			end
			self.is_placing = false
		else
			self.time_counter = self.time_counter + 1
		end
	end

	local player = self:get_nearest_player(10)
	if player == nil then
		self:set_animation(maidroid.animation_frames.STAND)
		return
	end

	local position = self.object:getpos()
	local player_position = player:getpos()
	local direction = vector.subtract(player_position, position)
	local velocity = self.object:getvelocity()

	if vector.length(direction) < 3 then
		if self.state == state.ACCOMPANY then
			self:set_animation(maidroid.animation_frames.STAND)
			self.state = state.IDLE
			self.object:setvelocity{x = 0, y = velocity.y, z = 0}
		end

		if not self.is_placing then
			local front = self:get_front() -- if it is dark, set touch.
			local wield_stack = self:get_wield_item_stack()

			if is_dark(front)
			and (wield_stack:get_name() == "default:torch"
			or self:move_main_to_wield(function (itemname) return itemname == "default:torch" end)) then
				self.time_counter = 0
				self.is_placing = true
				self:set_animation(maidroid.animation_frames.MINE)
			end
		end

	else
		if self.state == state.IDLE then
			self:set_animation(maidroid.animation_frames.WALK)
			self.state = state.ACCOMPANY
		end
		self.object:setvelocity{x = direction.x, y = velocity.y, z = direction.z} -- TODO

		if not self.is_placing then
			local front = self:get_front() -- if it is dark, set touch.
			local wield_stack = self:get_wield_item_stack()

			if is_dark(front)
			and (wield_stack:get_name() == "default:torch"
			or self:move_main_to_wield(function (itemname) return itemname == "default:torch" end)) then
				self.time_counter = 0
				self.is_placing = true
				self:set_animation(maidroid.animation_frames.WALK_MINE)
			end
		end
	end
	self:set_yaw_by_direction(direction)

	-- if maidroid is stoped by obstacle, the maidroid must jump.
	if velocity.y == 0 and self.state == state.ACCOMPANY then
		local front_node = self:get_front_node()
		if front_node.name ~= "air" and minetest.registered_nodes[front_node.name] ~= nil
		and minetest.registered_nodes[front_node.name].walkable then
			self.object:setvelocity{x = direction.x, y = 5, z = direction.z}
		end
	end
end

-- register a definition of a new core.
maidroid.register_core("maidroid_core:torcher", {
	description      = "maidroid core : torcher",
	inventory_image  = "maidroid_core_torcher.png",
	on_start         = on_start,
	on_stop          = on_stop,
	on_resume        = on_start,
	on_pause         = on_stop,
	on_step          = on_step,
})
