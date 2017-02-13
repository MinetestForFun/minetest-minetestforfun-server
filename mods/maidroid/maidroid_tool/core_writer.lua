------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

do -- register core writer

	local dye_item_map = {
		["dye:red"]    = "maidroid_core:basic",
		["dye:yellow"] = "maidroid_core:farming",
		["dye:white"]  = "maidroid_core:ocr",
		["dye:orange"] = "maidroid_core:torcher"
	}

	local node_box = {
		type = "fixed",
		fixed = {
			{-0.4375,   -0.25, -0.4375,  0.4375,  0.1875,  0.4375},
			{ 0.1875,  0.3125,  0.0625,  0.4375,   0.375,   0.125},
			{ -0.375,  0.1875,  -0.375,   0.375,    0.25,   0.375},
			{-0.0625,    -0.5, -0.0625,  0.0625,   0.375,  0.0625},
			{  0.375,  0.1875,  0.0625,  0.4375,   0.375,   0.125},
			{ -0.375,    -0.5,  -0.375,   0.375,   -0.25,   0.375},
		},
	}

	local selection_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.4375, 0.4375, 0.25, 0.4375},
		},
	}

	local formspec = {
		["inactive"] = "size[8,9]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. default.gui_slots
			.. "label[3.75,0;Core]"
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
				.. "label[3.75,0;Core]"
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
		["inactive"] = {
			"maidroid_tool_core_writer_top.png",
			"maidroid_tool_core_writer_bottom.png",
			"maidroid_tool_core_writer_right.png",
			"maidroid_tool_core_writer_right.png^[transformFX",
			"maidroid_tool_core_writer_front.png^[transformFX",
			"maidroid_tool_core_writer_front.png",
		},

		["active"] = {
			"maidroid_tool_core_writer_top.png",
			"maidroid_tool_core_writer_bottom.png",
			"maidroid_tool_core_writer_right.png",
			"maidroid_tool_core_writer_right.png^[transformFX",
			{
				backface_culling = false,
				image = "maidroid_tool_core_writer_front_active.png^[transformFX",

				animation = {
					type      = "vertical_frames",
					aspect_w  = 16,
					aspect_h  = 16,
					length    = 1.5,
				},
			},
			{
				backface_culling = false,
				image = "maidroid_tool_core_writer_front_active.png",

				animation = {
					type      = "vertical_frames",
					aspect_w  = 16,
					aspect_h  = 16,
					length    = 1.5,
				},
			},
		},
	}

	-- get_nearest_core_entity returns the nearest core entity.
	local function get_nearest_core_entity(pos)
		pos.y = pos.y + 0.65
		local all_objects = minetest.get_objects_inside_radius(pos, 0.1)
		for _, object in ipairs(all_objects) do
			if object:get_luaentity().name == "maidroid_tool:core_entity" then
				return object:get_luaentity()
			end
		end
		return nil
	end

	local function on_deactivate(pos)
		local core_entity = get_nearest_core_entity(pos)
		core_entity:stop_rotate()
	end

	local function on_activate(pos)
		local core_entity = get_nearest_core_entity(pos)
		core_entity:start_rotate()
	end

	local function on_metadata_inventory_put_to_main(pos)
		local entity_position = {
			x = pos.x, y = pos.y + 0.65, z = pos.z,
		}
		minetest.add_entity(entity_position, "maidroid_tool:core_entity")
	end

	local function on_metadata_inventory_take_from_main(pos)
		local core_entity = get_nearest_core_entity(pos)
		core_entity.object:remove()
	end

	maidroid_tool._aux.register_writer("maidroid_tool:core_writer", {
		description                           = "maidroid tool : core writer",
		formspec                              = formspec,
		tiles                                 = tiles,
		node_box                              = node_box,
		selection_box                         = selection_box,
		duration                              = 40,
		on_activate                           = on_activate,
		on_deactivate                         = on_deactivate,
		empty_itemname                        = "maidroid_core:empty",
		dye_item_map                          = dye_item_map,
		on_metadata_inventory_put_to_main     = on_metadata_inventory_put_to_main,
		on_metadata_inventory_take_from_main  = on_metadata_inventory_take_from_main,
	})

end

-- register a definition of a core entity.
do
	local node_box = {
		type = "fixed",
		fixed = {
			{   -0.5,    -0.5,  -0.125,     0.5, -0.4375,   0.125},
			{ -0.125,    -0.5,    -0.5,   0.125, -0.4375,     0.5},
			{  -0.25,    -0.5, -0.4375,    0.25, -0.4375,  0.4375},
			{ -0.375,    -0.5,  -0.375,   0.375, -0.4375,   0.375},
			{-0.4375,    -0.5,   -0.25,  0.4375, -0.4375,    0.25},
		},
	}

	local tiles = {
		"maidroid_tool_core_top.png",
		"maidroid_tool_core_top.png",
		"maidroid_tool_core_right.png",
		"maidroid_tool_core_right.png",
		"maidroid_tool_core_right.png",
		"maidroid_tool_core_right.png",
	}

	minetest.register_node("maidroid_tool:core_node", {
		drawtype    = "nodebox",
		tiles       = tiles,
		node_box    = node_box,
		paramtype   = "light",
		paramtype2  = "facedir",
	})

	local function on_activate(self, staticdata)
		self.object:set_properties{textures = {"maidroid_tool:core_node"}}

		if staticdata ~= "" then
			local data = minetest.deserialize(staticdata)
			self.is_rotating = data["is_rotating"]

			if self.is_rotating then
				self:start_rotate()
			end
		end
	end

	local function start_rotate(self)
		self.object:set_properties{automatic_rotate = 1}
		self.is_rotating = true
	end

	local function stop_rotate(self)
		self.object:set_properties{automatic_rotate = 0}
		self.is_rotating = false
	end

	local function get_staticdata(self)
		local data = {
			["is_rotating"] = self.is_rotating,
		}
		return minetest.serialize(data)
	end

	minetest.register_entity("maidroid_tool:core_entity", {
		physical        = false,
		visual          = "wielditem",
		visual_size     = {x = 0.5, y = 0.5},
		collisionbox    = {0, 0, 0, 0, 0, 0},
		on_activate     = on_activate,
		start_rotate    = start_rotate,
		stop_rotate     = stop_rotate,
		get_staticdata  = get_staticdata,
		is_rotating     = false,
	})
end
