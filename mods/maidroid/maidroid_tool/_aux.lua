------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid_tool._aux = {}

-- maidroid_tool.shared.generate_writer is a shared
-- function called for registering egg writer and core writer.
function maidroid_tool._aux.register_writer(nodename, options)
	local description                           = options.description
	local formspec                              = options.formspec
	local tiles                                 = options.tiles
	local node_box                              = options.node_box
	local selection_box                         = options.selection_box
	local duration                              = options.duration
	local on_activate                           = options.on_activate
	local on_deactivate                         = options.on_deactivate
	local empty_itemname                        = options.empty_itemname
	local dye_item_map                          = options.dye_item_map
	local on_metadata_inventory_put_to_main     = options.on_metadata_inventory_put_to_main
	local on_metadata_inventory_take_from_main  = options.on_metadata_inventory_take_from_main

	-- can_dig is a common callback.
	local function can_dig(pos)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		return (
			inventory:is_empty("main") and
			inventory:is_empty("fuel") and
			inventory:is_empty("dye")
		)
	end

	-- swap_node is a helper function that swap two nodes.
	local function swap_node(pos, name)
		local node = minetest.get_node(pos)
		node.name = name
		minetest.swap_node(pos, node)
	end

	-- on_timer is a common callback.
	local function on_timer(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		local main_list = inventory:get_list("main")
		local fuel_list = inventory:get_list("fuel")
		local dye_list = inventory:get_list("dye")

		local time = meta:get_float("time")
		local output = meta:get_string("output")

		-- if time is positive, this node is active.
		if time >= 0 then
			if time <= duration then
				meta:set_float("time", time + elapsed)
				meta:set_string("formspec", formspec.active(time))
			else
				meta:set_float("time", -1)
				meta:set_string("output", "")
				meta:set_string("formspec", formspec.inactive)
				inventory:set_stack("main", 1, ItemStack(output))

				swap_node(pos, nodename)

				if on_deactivate ~= nil then -- call on_deactivate callback.
					on_deactivate(pos, output)
				end
			end
		else
			local main_name = main_list[1]:get_name()

			if main_name == empty_itemname and (not fuel_list[1]:is_empty()) and (not dye_list[1]:is_empty()) then
				local output = dye_item_map[dye_list[1]:get_name()]

				meta:set_string("time", 0)
				meta:set_string("output", output)

				local fuel_stack = fuel_list[1]
				fuel_stack:take_item()
				inventory:set_stack("fuel", 1, fuel_stack)

				local dye_stack = dye_list[1]
				dye_stack:take_item()
				inventory:set_stack("dye", 1, dye_stack)

				swap_node(pos, nodename .. "_active")

				if on_activate ~= nil then -- call on_activate callback.
					on_activate(pos)
				end
			end
		end
		return true -- on_timer should return boolean value.
	end

	-- allow_metadata_inventory_put is a common callback.
	local function allow_metadata_inventory_put(_, listname, _, stack)
		local itemname = stack:get_name()

		if (listname == "fuel" and itemname == "default:coal_lump") then
			return stack:get_count()
		elseif listname == "dye" and dye_item_map[itemname] ~= nil then
			return stack:get_count()
		elseif listname == "main" and itemname == empty_itemname then
			return stack:get_count()
		end
		return 0
	end

	-- allow_metadata_inventory_move is a common callback for the node.
	local function allow_metadata_inventory_move(pos, from_list, from_index, _, to_index, _, player)
		local meta = minetest.get_meta(pos)
		local inventory = meta:get_inventory()
		local stack = inventory:get_stack(from_list, from_index)
		return allow_metadata_inventory_put(pos, listname, to_index, stack, player)
	end

	do -- register a definition of an inactive node.
		local function on_construct(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", formspec.inactive)
			meta:set_string("output", "")
			meta:set_string("time", -1)

			local inventory = meta:get_inventory()
			inventory:set_size("main", 1)
			inventory:set_size("fuel", 1)
			inventory:set_size("dye", 1)
		end

		local function on_metadata_inventory_put(pos, listname)
			local timer = minetest.get_node_timer(pos)
			timer:start(0.25)

			if listname == "main" then
				if on_metadata_inventory_put_to_main ~= nil then
					on_metadata_inventory_put_to_main(pos) -- call on_metadata_inventory_put_to_main callback.
				end
			end
		end

		local function on_metadata_inventory_move(pos, from_list, from_index, _, to_index, _, player)
			local meta = minetest.get_meta(pos)
			local inventory = meta:get_inventory()
			local stack = inventory:get_stack(from_list, from_index)

			-- listname is not set here, is it? ~Hybrid Dog
			on_metadata_inventory_put(pos, listname, to_index, stack, player)
		end

		local function on_metadata_inventory_take(pos, listname)
			if listname == "main" then
				if on_metadata_inventory_take_from_main ~= nil then
					on_metadata_inventory_take_from_main(pos) -- call on_metadata_inventory_take_from_main callback.
				end
			end
		end

		local function allow_metadata_inventory_take(_, _, _, stack)
			return stack:get_count() -- maybe add more.
		end

		minetest.register_node(nodename, {
			description                    = description,
			drawtype                       = "nodebox",
			paramtype                      = "light",
			paramtype2                     = "facedir",
			groups                         = {cracky = 2},
			is_ground_content              = false,
			sounds                         = default.node_sound_stone_defaults(),
			node_box                       = node_box,
			selection_box                  = selection_box,
			tiles                          = tiles.inactive,
			can_dig                        = can_dig,
			on_timer                       = on_timer,
			on_construct                   = on_construct,
			on_metadata_inventory_put      = on_metadata_inventory_put,
			on_metadata_inventory_move     = on_metadata_inventory_move,
			on_metadata_inventory_take     = on_metadata_inventory_take,
			allow_metadata_inventory_put   = allow_metadata_inventory_put,
			allow_metadata_inventory_move  = allow_metadata_inventory_move,
			allow_metadata_inventory_take  = allow_metadata_inventory_take,
		})

	end -- end register inactive node.

	do -- register a definition of an active node.
		local function allow_metadata_inventory_take(_, listname, _, stack)
			if listname == "main" then
				return 0
			end
			return stack:get_count()
		end

		minetest.register_node(nodename .. "_active", {
			drawtype                       = "nodebox",
			paramtype                      = "light",
			paramtype2                     = "facedir",
			groups                         = {cracky = 2},
			is_ground_content              = false,
			sounds                         = default.node_sound_stone_defaults(),
			node_box                       = node_box,
			selection_box                  = selection_box,
			tiles                          = tiles.active,
			can_dig                        = can_dig,
			on_timer                       = on_timer,
			allow_metadata_inventory_put   = allow_metadata_inventory_put,
			allow_metadata_inventory_move  = allow_metadata_inventory_move,
			allow_metadata_inventory_take  = allow_metadata_inventory_take,
		})
	end -- end register active node.
end
