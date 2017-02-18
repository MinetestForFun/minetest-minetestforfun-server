-- Boilerplate to support localized strings if intllib mod is installed.
local S = function(s) return s end
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
end

dofile(minetest.get_modpath(minetest.get_current_modname()).."/api.lua")

local ctrl_groups = {choppy=2, oddly_breakable_by_hand=2}
local has_worldedit = minetest.global_exists("worldedit")
local is_singleplayer = minetest.is_singleplayer()
local control_textures = {
	"default_steel_block.png",
	"default_diamond_block.png",
	"default_bronze_block.png",
	"default_obsidian_block.png",
	"default_gold_block.png",
}

if is_singleplayer then
	meshnode.config.max_radius = 16
	meshnode.config.show_in_creative = true
	meshnode.config.enable_crafting = true
	meshnode.config.autoconf = true
else
	meshnode.blacklist["default:chest_locked"] = true
	meshnode.blacklist["default:water_source"] = true
	meshnode.blacklist["default:river_water_source"] = true
	meshnode.blacklist["default:lava_source"] = true
end

for name, config in pairs(meshnode.config) do
	local setting = minetest.setting_get("meshnode_"..name)
	if type(config) == "number" then
		setting = tonumber(setting)
	elseif type(config) == "boolean" then
		setting = minetest.setting_getbool("meshnode_"..name)
	end
	if setting then
		meshnode.config[name] = setting
	end
end

if meshnode.config.autoconf == true then
	minetest.setting_set("max_objects_per_block", "4096")
end

if meshnode.config.show_in_creative == false then
	ctrl_groups.not_in_creative_inventory = 1
end

local function has_privilege(name)
	if is_singleplayer then
		return true
	end
	return minetest.check_player_privs(name, {meshnode=true})
end

local function show_meshnode_formspec(pos, player)
	local name = player:get_player_name()
	if not has_privilege(name) then
		return
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local id = minetest.pos_to_string(pos)
	local entity = meshnode.get_luaentity(id)
	local spos = pos.x..","..pos.y..","..pos.z
	local formspec = "size[8,8]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		default.get_hotbar_bg(0,4)..
		"list[current_player;main;0,4;8,1;]"..
		"list[current_player;main;0,5.25;8,3;8]"..
		"list[nodemeta:"..spos..";tool;0.5,1.5;1,1;]"
	local buttons = {}
	if entity and #entity.nodes > 0 then
		if inv:contains_item("tool", "meshnode:glue") then
			table.insert(buttons, {"activate", "Activate meshnode"})
		end
		table.insert(buttons, {"reset", "Reset connections"})
	end
	if meta:get_string("meshnode") ~= "" then
		table.insert(buttons, {"connect_meta", "Connect meta positions"})
	end
	if has_worldedit and worldedit.pos1[name] and worldedit.pos2[name] then
		table.insert(buttons, {"connect_we", "Connect worldedit markers"})
	end
	local y = 0.25
	for _, btn in pairs(buttons) do
		formspec = formspec.."button_exit[2.25,"..y..
			";5,0.5;"..btn[1]..";"..S(btn[2]).."]"
		y = y + 0.9
	end
	minetest.show_formspec(name, "meshnode_"..id, formspec)
end

local function register_scaffold(name, groups)
	groups.not_in_creative_inventory = 1
	groups.cracky = 1
	minetest.register_node(name, {
		paramtype = "light",
		drawtype = "glasslike",
		is_ground_content = false,
		sunlight_propagates = true,
		use_texture_alpha = true,
		tiles = {"meshnode_highlight.png"},
		groups = groups,
	})
end

register_scaffold("meshnode:scaffold", {})
register_scaffold("meshnode:scaffold_fence", {fence=1})
register_scaffold("meshnode:scaffold_wall", {wall=1})
register_scaffold("meshnode:scaffold_pane", {pane=1})

if meshnode.config.enable_crafting == true then
	minetest.register_craft({
		output = "meshnode:controller",
		recipe = {
			{"default:bronzeblock", "default:diamondblock", "default:bronzeblock"},
			{"default:obsidian_block", "default:steelblock", "default:goldblock"},
			{"default:bronzeblock", "default:steelblock", "default:bronzeblock"},
		}
	})
end

minetest.register_privilege("meshnode", "Player can use meshnode controller.")

minetest.register_entity("meshnode:mesh", {
	physical = true,
	visual = "wielditem",
	visual_size = {x=0.666, y=0.666},
	on_activate = function(self, staticdata)
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	get_staticdata = function(self)
		return "expired"
	end,
})

minetest.register_entity("meshnode:ctrl", {
	physical = true,
	visual = "mesh",
	mesh = "meshnode_plant.obj",
	visual_size = {x=1, y=1},
	textures = {"meshnode_trans.png"},
	facedir = 0,
	speed = 0,
	lift = 0,
	nodes = {},
	activated = false,
	animation = "stand",
	on_activate = function(self, staticdata)
		local pos = self.object:getpos()
		local objects = minetest.get_objects_inside_radius(pos, 0.5) or {}
		for _, object in pairs(objects) do
			if object ~= self.object then
				local entity = object:get_luaentity()
				if entity and entity.name == "meshnode:ctrl" then
					minetest.log("warning", "meshnode: duplicate object removed")
					self.object:remove()
					return
				end
			end
		end
		self.object:set_armor_groups({immortal=1})
		if staticdata then
			local data = minetest.deserialize(staticdata) or {}
			self.mesh_id = data[1]
			self.activated = data[2]
			self.nodes = data[3] or {}
		end
		if self.activated then
			self.mesh_id = meshnode.new_id()
		else
			local node = minetest.get_node(pos)
			if node.name ~= "meshnode:controller" then
				minetest.log("warning", "meshnode: stray object removed")
				self.object:remove()
				return
			end
		end
		for _, ref in pairs(self.nodes) do
			ref.id = meshnode.new_id()
			meshnode.add_entity(ref, self)
		end
		self:set_activated(self.activated)
	end,
	on_punch = function(self, puncher)
		--self.object:remove()
	end,
	on_rightclick = function(self, clicker)
		if not self.mesh_id then
			return
		end
		if self.activated then
			local name = clicker:get_player_name()
			local buttons = {}
			local formspec = "size[4,3.5]"	
			if self.player then
				table.insert(buttons, {"detach", "Detach"})
				local btn = {"animation_sit", "Sit"}
				if self.animation == "sit" then
					btn = {"animation_stand", "Stand"}
				end
				table.insert(buttons, btn)				
			else
				table.insert(buttons, {"attach", "Attach"})
				table.insert(buttons, {"restore", "Restore"})
			end
			table.insert(buttons, {"align", "Align"})
			local y = 0.5
			for _, btn in pairs(buttons) do
				formspec = formspec.."button_exit[0.5,"..y..
					";3,0.75;"..btn[1]..";"..S(btn[2]).."]"
				y = y + 1
			end
			local formname = "meshnode_"..self.mesh_id
			minetest.show_formspec(name, formname, formspec)
		end
	end,
	on_step = function(self, dtime)
		if self.player then
			local velocity = self.object:getvelocity()
			local yaw = self.object:getyaw()
			local speed = self.speed
			local lift = self.lift
			local ctrl = self.player:get_player_control()
			if ctrl.up then
				speed = speed + 0.1
			elseif ctrl.down then
				speed = speed - 0.1
			else
				speed = speed * 0.99
			end
			if speed > meshnode.config.max_speed then
				speed = meshnode.config.max_speed
			elseif speed < 0 - meshnode.config.max_speed then
				speed = 0 - meshnode.config.max_speed
			end
			if ctrl.jump then
				lift = lift + 0.1
			elseif ctrl.sneak then
				lift = lift - 0.1
			else
				lift = lift * 0.99
			end
			if lift > meshnode.config.max_lift then
				lift = meshnode.config.max_lift
			elseif lift < 0 - meshnode.config.max_lift then
				lift = 0 - meshnode.config.max_lift
			end
			if ctrl.left then
				yaw = yaw + meshnode.config.yaw_amount
			elseif ctrl.right then
				yaw = yaw - meshnode.config.yaw_amount
			end
			velocity.x = -math.sin(yaw) * speed
			velocity.y = lift
			velocity.z = math.cos(yaw) * speed
			self.object:setyaw(yaw)
			self.object:setvelocity(velocity)
			self.speed = speed
			self.lift = lift
		else
			self.object:setvelocity({x=0, y=0, z=0})
			self.speed = 0
			self.lift = 0
		end
	end,
	get_staticdata = function(self)
		local data = {self.mesh_id, self.activated, self.nodes}
		return minetest.serialize(data)
	end,
	set_alignment = function(self)
		local pos = self.object:getpos()
		local yaw = self.object:getyaw()
		local deg = math.deg(yaw) + 45
		deg = math.floor(deg / 90) * 90
		self.object:setvelocity({x=0, y=0, z=0})
		self.object:setyaw(math.rad(deg))
		self.object:setpos(vector.round(pos))
		self.speed = 0
		self.lift = 0
	end,
	set_activated = function(self, active)
		local mesh = "meshnode_plant.obj"
		local anim = {x=0, y=0}
		local textures = {"meshnode_trans.png"}
		local collisionbox = {0,0,0, 0,0,0}
		if active then
			mesh = "meshnode_ctrl.b3d"
			anim = {x=20, y=100}
			textures = control_textures
			collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5}
		end
		self.object:set_properties({
			mesh = mesh,
			textures = textures,
			collisionbox = collisionbox,
		})
		self.object:set_animation(anim, 15)
		self.activated = active
	end,
})

minetest.register_node("meshnode:controller", {
	description = S("Meshnode Controller"),
	drawtype = "mesh",
	mesh = "meshnode_ctrl.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = control_textures,
	groups = ctrl_groups,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = {
			name = "meshnode:glue",
			metadata = minetest.pos_to_string(pos),
		}
		inv:set_size("tool", 1)
		inv:add_item("tool", stack)
		meta:set_string("infotext", S("Meshnode Controller"))
	end,
	on_destruct = function(pos)
		local id = minetest.pos_to_string(pos)
		local entity = meshnode.get_luaentity(id)
		if entity then
			meshnode.restore_all(entity)
			entity.object:remove()
		end
	end,
	after_place_node = function(pos, placer)
		local node = minetest.get_node(pos)
		local id = minetest.pos_to_string(pos)
		local object = minetest.add_entity(pos, "meshnode:ctrl")
		if object then
			local entity = object:get_luaentity()
			if entity then
				local facedir = node.param2 or 0
				local yaw = meshnode.facedir_to_yaw(facedir)
				object:setyaw(yaw)
				entity.mesh_id = id
			end
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		show_meshnode_formspec(pos, clicker)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = stack:get_metadata()
		if meta then
			if vector.equals(minetest.string_to_pos(meta), pos) then
				return 1
			end
		end
		return 0
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		show_meshnode_formspec(pos, player)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		show_meshnode_formspec(pos, player)
	end
})

minetest.register_tool("meshnode:glue", {
	description = S("Meshnode Glue"),
	inventory_image = "meshnode_glue.png",
	liquids_pointable = true,
	groups = {not_in_creative_inventory=1},
	on_use = function(itemstack, user, pointed_thing)
		local meta = itemstack:get_metadata()
		local parent = meshnode.get_luaentity(meta)
		if not parent then
			return
		end
		local name = user:get_player_name()
		if not has_privilege(name) then
			return ""
		end
		if pointed_thing and pointed_thing.type == "node" then
			local pos = minetest.get_pointed_thing_position(pointed_thing)
			if pos then
				if minetest.is_protected(pos, name) then
					minetest.chat_send_player(name, S("Protected node").."!")
					return
				end
				local node = minetest.get_node_or_nil(pos)
				if node then
					if string.find(node.name, "meshnode:scaffold") then
						for i, ref in pairs(parent.nodes) do 
							local map_pos = meshnode.get_map_pos(ref, parent)
							if vector.equals(map_pos, pos) then
								meshnode.restore(ref, parent)
								parent.nodes[i] = nil
							end
						end
					else
						local dist = vector.distance(parent.object:getpos(), pos)
						if dist > meshnode.config.max_radius then
							minetest.chat_send_player(name, S("Out of range").."!")
						else
							meshnode.create(pos, parent)
						end
					end
				end
			end
		end
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname then
		local id = formname:gsub("meshnode_", "")
		if id == formname then
			return
		end
		local name = player:get_player_name()
		local entity = meshnode.get_luaentity(id)
		if not entity then
			return
		end
		local pos = vector.round(entity.object:getpos())
		if fields.activate then
			local id = meshnode.new_id()
			entity.mesh_id = meshnode.new_id()
			entity:set_activated(true)
			for _, ref in pairs(entity.nodes) do
				local map_pos = meshnode.get_map_pos(ref, entity)
				minetest.remove_node(map_pos)
				ref.parent = id
			end
			minetest.remove_node(pos)
		elseif fields.connect_meta then
			local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos)
			local spos = meta:get_string("meshnode")
			local positions = minetest.deserialize(spos) or {}
			for _, p in pairs(positions) do
				meshnode.create(p, entity)
			end
		elseif fields.connect_we then
			if has_worldedit then
				local p1 = worldedit.pos1[name]
				local p2 = worldedit.pos2[name]
				if p1 and p2 then
					local minp = {
						x = math.min(p1.x, p2.x),
						y = math.min(p1.y, p2.y),
						z = math.min(p1.z, p2.z),
					}
					local maxp = {
						x = math.max(p1.x, p2.x),
						y = math.max(p1.y, p2.y),
						z = math.max(p1.z, p2.z),
					}
					local area = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
					for i in area:iterp(minp, maxp) do
						local p = area:position(i)
						meshnode.create(p, entity)
					end
				end
			end
		elseif fields.reset then
			meshnode.restore_all(entity)
			entity.nodes = {}
		elseif fields.attach and entity.player == nil then
			player:set_attach(entity.object, "", {x=0, y=15, z=0}, {x=0, y=0, z=0})
			entity.player = player
			entity.object:set_animation({x=0, y=0}, 15)
			default.player_attached[name] = true
		elseif fields.detach and entity.player == player then
			player:set_detach()
			entity.player = nil
			entity.animation = "stand"
			entity.object:set_animation({x=20, y=100}, 15)
			default.player_attached[name] = false
			local p = player:getpos()
			minetest.after(0.1, function()
				player:setpos({x=p.x, y=p.y + 1, z=p.z})
			end)
		elseif fields.animation_sit then
			default.player_set_animation(player, "sit", 30)
			entity.animation = "sit"
		elseif fields.animation_stand then
			default.player_set_animation(player, "stand", 30)
			entity.animation = "stand"
		elseif fields.align then
			entity:set_alignment()
		elseif fields.restore then
			if not has_privilege(name) then
				local msg = S("Requires the meshnode privilege")
				minetest.chat_send_player(name, msg)
				return
			end
			entity:set_alignment()
			local positions = meshnode.restore_all(entity, name)
			if positions then
				local yaw = entity.object:getyaw()
				local node = {
					name = "meshnode:controller",
					param2 = meshnode.yaw_to_facedir(yaw),
				}
				minetest.add_node(pos, node)
				if #positions > 0 then
					local meta = minetest.get_meta(pos)
					local spos = minetest.serialize(positions)
					meta:set_string("meshnode", spos)
				end
				entity.nodes = {}
				entity.mesh_id = minetest.pos_to_string(pos)
				entity:set_activated(false)
			else
				local msg = S("Protected or unloaded area")
				minetest.chat_send_player(name, msg.."!")
			end
		end
	end
end)

