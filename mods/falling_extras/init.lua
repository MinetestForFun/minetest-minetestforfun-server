local load_time_start = os.clock()

local core = minetest

local sound_count = 0
local function play_node_sound(pos, name, alt, gain_multiplier)
	if sound_count > 50 then
		return	-- fixes error message spam
	end
	local sound = core.registered_nodes[name]
	if not sound then
		return
	end
	sound = sound.sounds
	if not sound then
		return
	end
	sound = sound.drop or sound[alt]
	if not sound then
		return
	end
	core.sound_play(sound.name, {pos=pos, gain=sound.gain*math.abs(gain_multiplier)})
	sound_count = sound_count+1
	if sound_count > 10 then
		core.after(0.1, function()
			sound_count = 0
		end)
	end
end

if not core.get_gravity then
	local gravity,grav_updating = 10
	function core.get_gravity()
		if not grav_updating then
			gravity = tonumber(core.setting_get("movement_gravity")) or gravity
			grav_updating = true
			core.after(50, function()
				grav_updating = false
			end)
		end
		return gravity
	end
	local set_setting = core.setting_set
	function core.setting_set(name, v, ...)
		if name == "gravity" then
			name = "movement_gravity"
			gravity = tonumber(v) or gravity
		end
		return set_setting(name, v, ...)
	end
	local get_setting = core.setting_get
	function core.setting_get(name, ...)
		if name == "gravity" then
			name = "movement_gravity"
		end
		return get_setting(name, ...)
	end
end

local damage_near_players
local enable_damage = core.setting_getbool("enable_damage")
if enable_damage
or enable_damage == nil then
	function damage_near_players(np, fdmg)
		local dmg = math.floor(math.abs(fdmg)+0.5)
		if dmg < 1 then
			return
		end
		for _,obj in pairs(core.get_objects_inside_radius(np, 2)) do
			if obj:is_player() then
				local pos = obj:getpos()
				if math.abs(np.x-pos.x) < 0.45
				and math.abs(np.z-pos.z) < 0.45
				and pos.y < np.y+0.5
				and pos.y > np.y-1.4 then
					obj:set_hp(math.max(0, obj:get_hp()-dmg))
				end
			end
		end
	end
else
	function damage_near_players()
	end
end

local falling_entity = core.registered_entities["__builtin:falling_node"]
falling_entity.makes_footstep_sound = true
falling_entity.sound_volume = 1
falling_entity.on_step = function(self, dtime)
	-- Set gravity
	local gravity = core.get_gravity()
	self.object:setacceleration({x=0, y=-gravity, z=0})
	-- Turn to actual sand when collides to ground or just move
	local bcp = self.object:getpos()
	bcp.y = bcp.y-0.7*math.sign(gravity) -- Position of bottom center point
	local bcnn = core.get_node(bcp).name
	local bcd = core.registered_nodes[bcnn]
	-- Note: walkable is in the node definition, not in item groups
	if not bcd
	or bcd.walkable
	or (core.get_item_group(self.node.name, "float") ~= 0
		and bcd.liquidtype ~= "none"
	) then
		if bcd and bcd.leveled and
				bcnn == self.node.name then
			local addlevel = self.node.level
			if addlevel == nil or addlevel <= 0 then
				addlevel = bcd.leveled
			end
			if core.add_node_level(bcp, addlevel) == 0 then
				self.object:remove()
				return
			end
		elseif bcd and bcd.buildable_to and
				(core.get_item_group(self.node.name, "float") == 0 or
				bcd.liquidtype == "none") then
			play_node_sound(bcp, bcnn, "dug", self.sound_volume)
			core.remove_node(bcp)
			return
		end
		local np = {x=bcp.x, y=bcp.y+math.sign(gravity), z=bcp.z}
		-- Check what's here
		local n2 = core.get_node(np)
		-- If it's not air or liquid, remove node and replace it with
		-- it's drops
		if n2.name ~= "air" and (not core.registered_nodes[n2.name] or
				core.registered_nodes[n2.name].liquidtype == "none") then
			play_node_sound(np, n2.name, "dug", self.sound_volume)
			core.remove_node(np)
			if core.registered_nodes[n2.name].buildable_to == false then
				if core.get_node(np).name == "air" then
					-- Add dropped items
					local drops = core.get_node_drops(n2.name, "")
					for _, dropped_item in pairs(drops) do
						core.add_item(np, dropped_item)
					end
				else
					-- Sometimes there are not walkable chests or similar
					local drops = core.get_node_drops(self.node.name, "")
					for _, dropped_item in pairs(drops) do
						core.add_item(np, dropped_item)
					end
					self.object:remove()
					return
				end
			end
			-- Run script hook
			local _, callback
			for _, callback in ipairs(core.registered_on_dignodes) do
				callback(np, n2, nil)
			end
		end
		-- Play sound, set node, remove entity and damage player(s)
		play_node_sound(np, self.node.name, "dug", self.sound_volume)	-- The place sound sounds weird
		core.add_node(np, self.node)
		self.object:remove()
		nodeupdate(np)
		damage_near_players(np, self.sound_volume)
		return
	end
	local vely = self.object:getvelocity().y
	if vely == 0 then
		self.object:setpos(vector.round(self.object:getpos()))
	else
		self.sound_volume = vely/10
	end
end

core.register_entity(":__builtin:falling_node", falling_entity)


-- mostly copied
function nodeupdate_single(p, delay)
	local n = core.get_node(p)
	if core.get_item_group(n.name, "falling_node") ~= 0 then
		local p_bottom = {x=p.x, y=p.y-math.sign(core.get_gravity()), z=p.z}
		local n_bottom = core.get_node(p_bottom)
		-- Note: walkable is in the node definition, not in item groups
		if core.registered_nodes[n_bottom.name] and
				(core.get_item_group(n.name, "float") == 0 or
					core.registered_nodes[n_bottom.name].liquidtype == "none") and
				(n.name ~= n_bottom.name or (core.registered_nodes[n_bottom.name].leveled and
					core.get_node_level(p_bottom) < core.get_node_max_level(p_bottom))) and
				(not core.registered_nodes[n_bottom.name].walkable or
					core.registered_nodes[n_bottom.name].buildable_to) then
			if delay then
				core.after(0.1, nodeupdate_single, {x=p.x, y=p.y, z=p.z}, false)
			else
				n.level = core.get_node_level(p)
				core.remove_node(p)
				spawn_falling_node(p, n)
				nodeupdate(p)
			end
		end
	end

	if core.get_item_group(n.name, "attached_node") ~= 0 then
		if not check_attached_node(p, n) then
			drop_attached_node(p)
			nodeupdate(p)
		end
	end
end

local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[falling_extras] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	core.log("info", msg)
end
