------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

do -- register egg writer

	local dye_item_map = {
		["dye:white"]       = "maidroid:maidroid_mk1_egg",
		["dye:grey"]        = "maidroid:maidroid_mk2_egg",
		["dye:dark_grey"]   = "maidroid:maidroid_mk3_egg",
		["dye:black"]       = "maidroid:maidroid_mk4_egg",
		["dye:blue"]        = "maidroid:maidroid_mk5_egg",
		["dye:cyan"]        = "maidroid:maidroid_mk6_egg",
		["dye:green"]       = "maidroid:maidroid_mk7_egg",
		["dye:dark_green"]  = "maidroid:maidroid_mk8_egg",
		["dye:yellow"]      = "maidroid:maidroid_mk9_egg",
		["dye:orange"]      = "maidroid:maidroid_mk10_egg",
		["dye:brown"]       = "maidroid:maidroid_mk11_egg",
		["dye:red"]         = "maidroid:maidroid_mk12_egg",
		["dye:pink"]        = "maidroid:maidroid_mk13_egg",
		["dye:magenta"]     = "maidroid:maidroid_mk14_egg",
		["dye:violet"]      = "maidroid:maidroid_mk15_egg",
	}

	local formspec = { -- want to change.
		["inactive"] = "size[8,9]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. default.gui_slots
			.. "label[3.75,0;Egg]"
			.. "list[current_name;main;3.5,0.5;1,1;]"
			.. "label[2.75,2;Coal]"
			.. "list[current_name;fuel;2.5,2.5;1,1;]"
			.. "label[4.75,2;Dye]"
			.. "list[current_name;dye;4.5,2.5;1,1;]"
			.. "image[3.5,1.5;1,2;maidroid_tool_gui_arrow.png]"
			.. "image[3.1,3.5;2,1;maidroid_tool_gui_meter.png^[transformR270]"
			.. "list[current_player;main;0,5;8,1;]"
			.. "list[current_player;main;0,6.2;8,3;8]",

		["active"] = function(time)
			local arrow_percent = (100 / 40) * time
			local merter_percent = 0
			if time % 16 >= 8 then
				meter_percent = (8 - (time % 8)) * (100 / 8)
			else
				meter_percent = (time % 8) * (100 / 8)
			end
			return "size[8,9]"
				.. default.gui_bg
				.. default.gui_bg_img
				.. default.gui_slots
				.. "label[3.75,0;Egg]"
				.. "list[current_name;main;3.5,0.5;1,1;]"
				.. "label[2.75,2;Coal]"
				.. "list[current_name;fuel;2.5,2.5;1,1;]"
				.. "label[4.75,2;Dye]"
				.. "list[current_name;dye;4.5,2.5;1,1;]"
				.. "image[3.5,1.5;1,2;maidroid_tool_gui_arrow.png^[lowpart:"
				.. arrow_percent
				.. ":maidroid_tool_gui_arrow_filled.png]"
				.. "image[3.1,3.5;2,1;maidroid_tool_gui_meter.png^[lowpart:"
				.. meter_percent
				.. ":maidroid_tool_gui_meter_filled.png^[transformR270]"
				.. "list[current_player;main;0,5;8,1;]"
				.. "list[current_player;main;0,6.2;8,3;8]"
		end,
	}

	local tiles = {
		["active"] = {
			"maidroid_tool_egg_writer_top.png",
			"maidroid_tool_egg_writer_bottom.png",
			"maidroid_tool_egg_writer_right.png",
			"maidroid_tool_egg_writer_right.png^[transformFX",
			{
				backface_culling = false,
				image = "maidroid_tool_egg_writer_front_active.png^[transformFX",

				animation = {
					type      = "vertical_frames",
					aspect_w  = 16,
					aspect_h  = 16,
					length    = 1.5,
				},
			},
			{
				backface_culling = false,
				image = "maidroid_tool_egg_writer_front_active.png",

				animation = {
					type      = "vertical_frames",
					aspect_w  = 16,
					aspect_h  = 16,
					length    = 1.5,
				},
			},
		},

		["inactive"] = {
			"maidroid_tool_egg_writer_top.png",
			"maidroid_tool_egg_writer_bottom.png",
			"maidroid_tool_egg_writer_right.png",
			"maidroid_tool_egg_writer_right.png^[transformFX",
			"maidroid_tool_egg_writer_front.png^[transformFX",
			"maidroid_tool_egg_writer_front.png",
		},
	}

	local node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.3125, -0.4375, -0.375,  0.4375, 0.4375},
			{-0.4375, -0.3125, -0.4375, 0.4375,  0.4375, -0.375},
			{  0.375, -0.3125, -0.4375, 0.4375,  0.4375, 0.4375},
			{-0.4375, -0.3125,   0.375, 0.4375,  0.4375, 0.4375},
			{-0.4375,   -0.25,  -0.375, 0.4375,    0.25,  0.375},
			{   -0.5,       0,    -0.5,    0.5,   0.125,    0.5},
			{  -0.25,    -0.5, -0.3125,   0.25, -0.3125, 0.3125},
			{-0.3125,    -0.5,   -0.25, 0.3125, -0.3125,   0.25},
		},
	}

	local selection_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, 0.4375, 0.4375},
		},
	}

	local function get_nearest_egg_entity(pos)
		pos.y = pos.y + 0.25 -- egg entity is above.
		local all_objects = minetest.get_objects_inside_radius(pos, 0.35)
		for _, object in ipairs(all_objects) do
			if object:get_luaentity() ~= nil and object:get_luaentity().name == "maidroid_tool:egg_entity" then
				return object:get_luaentity()
			end
		end
		return nil
	end

	local function on_deactivate(pos, output)
		local egg_entity = get_nearest_egg_entity(pos)
		egg_entity:stop_move(output)
	end

	local function on_activate(pos)
		local egg_entity = get_nearest_egg_entity(pos)
		egg_entity.object:set_properties{textures={"maidroid:empty_egg"}}
		egg_entity:start_move(output)
	end

	local function on_metadata_inventory_put_to_main(pos)
		local center_position = {
			x = pos.x, y = pos.y + 0.25, z = pos.z
		}
		local egg_entity = minetest.add_entity(center_position, "maidroid_tool:egg_entity")
		local lua_entity = egg_entity:get_luaentity()
		lua_entity:initialize(center_position)
	end

	local function on_metadata_inventory_take_from_main(pos)
		local egg_entity = get_nearest_egg_entity(pos)
		egg_entity.object:remove()
	end

	maidroid_tool._aux.register_writer("maidroid_tool:egg_writer", {
		description                           = "maidroid tool : egg writer",
		formspec                              = formspec,
		tiles                                 = tiles,
		node_box                              = node_box,
		selection_box                         = selection_box,
		duration                              = 40,
		on_activate                           = on_activate,
		on_deactivate                         = on_deactivate,
		empty_itemname                        = "maidroid:empty_egg",
		dye_item_map                          = dye_item_map,
		on_metadata_inventory_put_to_main     = on_metadata_inventory_put_to_main,
		on_metadata_inventory_take_from_main  = on_metadata_inventory_take_from_main,
	})

end -- register egg writer

do -- register a definition of an egg entity
	local function on_activate(self, staticdata)
		self.object:set_properties{textures={"maidroid:empty_egg"}}
		self.object:set_properties{automatic_rotate = 1}

		if staticdata ~= "" then
			local data = minetest.deserialize(staticdata)

			self.is_moving       = data["is_moving"]
			self.center_position = data["center_position"]
			self.current_egg     = data["current_egg"]

			self.object:set_properties{textures={self.current_egg}}
			self:initialize(self.center_position)

			if self.is_moving then
				self:start_move()
			end
		else
			self.object:set_properties{textures={"maidroid:empty_egg"}}
		end
	end

	local function start_move(self, output)
		self.is_moving = true
	end

	local function stop_move(self, output)
		self.object:set_properties{textures={output}}
		self.is_moving = false
		self.current_egg = output
	end

	local function get_staticdata(self)
		local data = {
			["is_moving"]        = self.is_moving,
			["center_position"]  = self.center_position,
			["current_egg"]      = self.current_egg,
		}
		return minetest.serialize(data)
	end

	local function on_step(self, dtime)
		if self.angle >= 360 then
			self.angle = 0
		else
			self.angle = self.angle + 2
		end

		if self.is_moving then
			local length = 0.15
			local new_position = vector.add(self.center_position, {
				x = length * math.cos(self.angle * math.pi / 180.0),
				y = math.sin(self.angle * math.pi / 180.0) * 0.025,
				z = length * math.sin(self.angle * math.pi / 180.0),
			})
			self.object:setpos(new_position)
		else
			local cur_position = self.object:getpos()
			local new_position = {
				x = cur_position.x,
				y = self.center_position.y + math.sin(self.angle * math.pi / 180.0) * 0.025,
				z = cur_position.z,
			}
			self.object:setpos(new_position)
		end
	end

	local function initialize(self, pos)
		self.angle = 0
		self.center_position = pos
		local init_pos = vector.add(pos, {x = 0.15, y = 0, z = 0})
		self.object:setpos(init_pos)
	end

	minetest.register_entity("maidroid_tool:egg_entity", {
		hp_max           = 1,
		visual           = "wielditem",
		visual_size      = {x = 0.2, y = 0.2},
		collisionbox     = {0, 0, 0, 0, 0, 0},
		physical         = false,
		on_activate      = on_activate,
		start_move       = start_move,
		stop_move        = stop_move,
		get_staticdata   = get_staticdata,
		on_step          = on_step,
		initialize       = initialize,
		current_egg      = "maidroid:empty_egg",
		center_position  = nil,
		is_moving        = false,
		angle            = 0,
	})
end -- register egg entity
