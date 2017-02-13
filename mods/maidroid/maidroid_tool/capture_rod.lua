local rod_uses = 100

minetest.register_tool("maidroid_tool:capture_rod", {
	description = "maidroid tool : capture rod",
	inventory_image = "maidroid_tool_capture_rod.png",
	on_use = function(itemstack, user, pointed_thing)
		if (pointed_thing.type ~= "object") then
			return
		end

		local obj = pointed_thing.ref
		local luaentity = obj:get_luaentity()
		if not maidroid.is_maidroid(luaentity.name) then
			if luaentity.name == "__builtin:item" then
				luaentity:on_punch(user)
			end
			return
		end

		local drop_pos = vector.add(obj:getpos(), {x = 0, y = 1, z = 0})
		local maidroid_name = string.split(luaentity.name, ":")[2]
		local stack = ItemStack("maidroid_tool:captured_" .. maidroid_name .. "_egg")
		stack:set_metadata(luaentity:get_staticdata())

		obj:remove()
		minetest.add_item(drop_pos, stack)
		itemstack:add_wear(65535 / (rod_uses - 1))

		minetest.sound_play("maidroid_tool_capture_rod_use", {pos = drop_pos})
		minetest.add_particlespawner({
			amount = 20,
			time = 0.2,
			minpos = drop_pos,
			maxpos = drop_pos,
			minvel = {x = -1.5, y = 2, z = -1.5},
			maxvel = {x = 1.5,  y = 4, z = 1.5},
			minacc = {x = 0, y = -8, z = 0},
			maxacc = {x = 0, y = -4, z = 0},
			minexptime = 1,
			maxexptime = 1.5,
			minsize = 1,
			maxsize = 2.5,
			collisiondetection = true,
			vertical = false,
			texture = "maidroid_tool_capture_rod_star.png",
			player = user
		})

		return itemstack
	end
})


for name, _ in pairs(maidroid.registered_maidroids) do
	local maidroid_name = string.split(name, ":")[2]
	local egg_def = maidroid.registered_eggs[name .. "_egg"]
	local inv_img = "maidroid_tool_capture_rod_plate.png^" .. egg_def.inventory_image

	minetest.register_tool("maidroid_tool:captured_" .. maidroid_name .. "_egg", {
		description = "maidroid tool : captured " .. egg_def.description,
		inventory_image = inv_img,
		groups = {not_in_creative_inventory = 1},
		on_use = function(itemstack, user, pointed_thing)
			if pointed_thing.type ~= "node" then
				if pointed_thing.type == "object" then
					local luaentity = pointed_thing.ref:get_luaentity()
					if luaentity.name == "__builtin:item" then
						luaentity:on_punch(user)
					end
				end
				return
			end

			local meta = itemstack:get_metadata()
			local obj = minetest.add_entity(pointed_thing.above, name)
			local luaentity = obj:get_luaentity()
			luaentity:set_yaw_by_direction(vector.subtract(user:getpos(), obj:getpos()))
			luaentity:on_activate(meta)

			-- FIXME: this is workaround
			maidroid.manufacturing_data[name] = maidroid.manufacturing_data[name] - 1

			local pos = vector.add(obj:getpos(), {x = 0, y = -0.2, z = 0})
			minetest.sound_play("maidroid_tool_capture_rod_open_egg", {pos = pos})
			minetest.add_particlespawner({
				amount = 30,
				time = 0.1,
				minpos = pos,
				maxpos = pos,
				minvel = {x = -2, y = 1.0, z = -2},
				maxvel = {x = 2,  y = 2.5, z = 2},
				minacc = {x = 0, y = -5, z = 0},
				maxacc = {x = 0, y = -2, z = 0},
				minexptime = 0.5,
				maxexptime = 1,
				minsize = 0.5,
				maxsize = 2,
				collisiondetection = false,
				vertical = false,
				texture = "maidroid_tool_capture_rod_star.png^[colorize:#ff8000:127",
				player = user
			})

			local rad = user:get_look_horizontal()
			minetest.add_particle({
				pos = pos,
				velocity = {x = math.cos(rad) * 2, y = 1.5, z = math.sin(rad) * 2},
				acceleration = {x = 0, y = -3, z = 0},
				expirationtime = 1.5,
				size = 6,
				collisiondetection = false,
				vertical = false,
				texture = "(" .. inv_img .. "^[resize:32x32)^[mask:maidroid_tool_capture_rod_mask_right.png",
				player = user
			})
			minetest.add_particle({
				pos = pos,
				velocity = {x = math.cos(rad) * -2, y = 1.5, z = math.sin(rad) * -2},
				acceleration = { x = 0, y = -3, z = 0},
				expirationtime = 1.5,
				size = 6,
				collisiondetection = false,
				vertical = false,
				texture = "(" .. inv_img .. "^[resize:32x32)^[mask:maidroid_tool_capture_rod_mask_left.png",
				player = user
			})

			itemstack:take_item()
			return itemstack
		end,
	})
end
