------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local formspec = "size[4,1.25]"
			.. default.gui_bg
			.. default.gui_bg_img
 			.. default.gui_slots
			.. "button_exit[3,0.25;1,0.875;apply_name;Apply]"
			.. "field[0.5,0.5;2.75,1;name;name;%s]"

local maidroid_buf = {} -- for buffer of target maidroids.

minetest.register_craftitem("maidroid_tool:nametag", {
	description      = "maidroid tool : nametag",
	inventory_image  = "maidroid_tool_nametag.png",
	stack_max        = 1,

	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "object" then
			return nil
		end

		local obj = pointed_thing.ref
		local luaentity = obj:get_luaentity()

		if not obj:is_player() and luaentity then
			local name = luaentity.name

			if maidroid.is_maidroid(name) then
				local player_name = user:get_player_name()
				local nametag = luaentity.nametag or ""

				minetest.show_formspec(player_name, "maidroid_tool:nametag", formspec:format(nametag))
				maidroid_buf[player_name] = {
					object = obj,
					itemstack = itemstack
				}
			end
		end
		return nil
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "maidroid_tool:nametag" then
		return
	end

	local player_name = player:get_player_name()
	if fields.name then
		local luaentity = maidroid_buf[player_name].object:get_luaentity()
		if luaentity then
			luaentity.nametag = fields.name

			luaentity.object:set_properties{
				nametag = fields.name,
			}

			local itemstack = maidroid_buf[player_name].itemstack
			itemstack:take_item()
			player:set_wielded_item(itemstack)
		end
	end

	maidroid_buf[player_name] = nil
end)
