-- Version of player model.
-- default_character_v1:
--	minetest_game before 25 nov 2016
--	3d_armor before 27 nov 2016	(overrides model from minetest_game)
-- default_character_v2:
--	minetest_game after 25 nov 2016
--	3d_armor after 27 nov 2016	(overrides model from minetest_game)

local valid_player_model_versions =  {
	default_character_v1 = true,
	default_character_v2 = true,
}

local player_model_version = minetest.setting_get("player_model_version")
if not player_model_version or player_model_version == "" then
	player_model_version = "default_character_v2"
elseif not  valid_player_model_versions[player_model_version] then
	error("Invalid value for player_model_version in minetest.conf: " .. player_model_version)
end

-- Localize to avoid table lookups
local vector_new = vector.new
local math_pi = math.pi
local math_sin = math.sin
local table_remove = table.remove
local get_animation = default.player_get_animation

-- Animation alias
local STAND = 1
local WALK = 2
local MINE = 3
local WALK_MINE = 4
local SIT = 5
local LAY = 6

-- Bone alias
local BODY = "Body"
local HEAD = "Head"
local CAPE = "Cape"
local LARM = "Arm_Left"
local RARM = "Arm_Right"
local LLEG = "Leg_Left"
local RLEG = "Leg_Right"

local bone_positions = {
	default_character_v1 = {
		[BODY] = vector_new(0, -3.5, 0),
		[HEAD] = vector_new(0, 6.75, 0),
		[CAPE] = vector_new(0, 6.75, 1.1),
		[LARM] = vector_new(2, 6.75, 0),
		[RARM] = vector_new(-2, 6.75, 0),
		[LLEG] = vector_new(-1, 0, 0),
		[RLEG] = vector_new(1, 0, 0)
	},
	default_character_v2 = {
		[BODY] = vector_new(0, -3.5, 0),
		[HEAD] = vector_new(0, 6.75, 0),
		[CAPE] = vector_new(0, 6.75, 1.2),
		[LARM] = vector_new(3, 5.75, 0),
		[RARM] = vector_new(-3, 5.75, 0),
		[LLEG] = vector_new(1, 0, 0),
		[RLEG] = vector_new(-1, 0, 0)
	}
}

local bone_rotations = {
	default_character_v1 = {
		[BODY] = vector_new(0, 0, 0),
		[HEAD] = vector_new(0, 0, 0),
		[CAPE] = vector_new(180, 0, 0),
		[LARM] = vector_new(180, 0, 9),
		[RARM] = vector_new(180, 0, -9),
		[LLEG] = vector_new(0, 0, 0),
		[RLEG] = vector_new(0, 0, 0)
	},
	default_character_v2 = {
		[BODY] = vector_new(0, 0, 0),
		[HEAD] = vector_new(0, 0, 0),
		[CAPE] = vector_new(0, 0, 0),
		[LARM] = vector_new(0, 0, 0),
		[RARM] = vector_new(0, 0, 0),
		[LLEG] = vector_new(0, 0, 0),
		[RLEG] = vector_new(0, 0, 0)
	}
}

local bone_rotation = bone_rotations[player_model_version]
local bone_position = bone_positions[player_model_version]
if not bone_rotation or not bone_position then
	error("Internal error: invalid player_model_version: " .. player_model_version)
end

local bone_rotation_cache = {}

local function rotate(player, bone, x, y, z)
	local default_rotation = bone_rotation[bone]
	local rotation = {
		x = (x or 0) + default_rotation.x,
		y = (y or 0) + default_rotation.y,
		z = (z or 0) + default_rotation.z
	}

	local player_cache = bone_rotation_cache[player]
	local rotation_cache = player_cache[bone]

	if not rotation_cache
	or rotation.x ~= rotation_cache.x
	or rotation.y ~= rotation_cache.y
	or rotation.z ~= rotation_cache.z then
		player_cache[bone] = rotation
		player:set_bone_position(bone, bone_position[bone], rotation)
	end
end

local step = 0

local look_pitch = {}
local animation_speed = {}

local animations = {
	[STAND] = function(player)
		rotate(player, BODY)
		rotate(player, CAPE)
		rotate(player, LARM)
		rotate(player, RARM)
		rotate(player, LLEG)
		rotate(player, RLEG)
	end,

	[WALK] = function(player)
		local swing = math_sin(step * 4 * animation_speed[player])

		rotate(player, CAPE, swing * -30 - 35)
		rotate(player, LARM, swing * -40)
		rotate(player, RARM, swing * 40)
		rotate(player, LLEG, swing * 40)
		rotate(player, RLEG, swing * -40)
	end,

	[MINE] = function(player)
		local pitch = look_pitch[player]
		local speed = animation_speed[player]

		local swing = math_sin(step * 4 * speed)
		local hand_swing = math_sin(step * 8 * speed)

		rotate(player, CAPE, swing * -5 - 10)
		rotate(player, LARM)
		rotate(player, RARM, hand_swing * 20 + 80 + pitch, hand_swing * 5 - 3, 10)
		rotate(player, LLEG)
		rotate(player, RLEG)
	end,

	[WALK_MINE] = function(player)
		local pitch = look_pitch[player]
		local speed = animation_speed[player]

		local swing = math_sin(step * 4 * speed)
		local hand_swing = math_sin(step * 8 * speed)

		rotate(player, CAPE, swing * -30 - 35)
		rotate(player, LARM, swing * -40)
		rotate(player, RARM, hand_swing * 20 + 80 + pitch, hand_swing * 5 - 3, 10)
		rotate(player, LLEG, swing * 40)
		rotate(player, RLEG, swing * -40)
	end,

	[SIT] = function(player)
		local body_position = vector_new(bone_position[BODY])
		body_position.y = body_position.y - 6

		player:set_bone_position(BODY, body_position, {x = 0, y = 0, z = 0})

		rotate(player, LARM)
		rotate(player, RARM)
		rotate(player, LLEG, 90)
		rotate(player, RLEG, 90)
	end,

	[LAY] = function(player)
		rotate(player, HEAD)
		rotate(player, CAPE)
		rotate(player, LARM)
		rotate(player, RARM)
		rotate(player, LLEG)
		rotate(player, RLEG)

		local body_position = {x = 0, y = -9, z = 0}
		local body_rotation = {x = 270, y = 0, z = 0}

		player:set_bone_position(BODY, body_position, body_rotation)
	end
}

local function update_look_pitch(player)
	local pitch = -player:get_look_vertical() * 180 / math_pi

	if look_pitch[player] ~= pitch then
		look_pitch[player] = pitch
	end
end

local function set_animation_speed(player, sneak)
	local speed = sneak and 0.75 or 2

	if animation_speed[player] ~= speed then
		animation_speed[player] = speed
	end
end

local previous_animation = {}

local function set_animation(player, anim)
	if (anim == WALK or anim == MINE or anim == WALK_MINE) 
	or (previous_animation[player] ~= anim) then
		previous_animation[player] = anim
		animations[anim](player)
	end
end

local previous_yaw = {}

local function body_moving(player, sneak, no_rotate_body)
	local yaw = player:get_look_horizontal()

	local player_previous_yaw = previous_yaw[player]
	local index = #player_previous_yaw + 1
	player_previous_yaw[index] = yaw

	local next_yaw = yaw
	if index > 7 then
		next_yaw = player_previous_yaw[1]
		table_remove(player_previous_yaw, 1)
	end

	local x, y = 0, 0
	if not no_rotate_body then
		x = sneak and 5 or 0
		y = (yaw - next_yaw) * 180 / math_pi
	end

	rotate(player, BODY, x, y)
	rotate(player, HEAD, look_pitch[player], -y)
end

local players = {}
local player_list = {}
local player_count = 0

local function update_players()
	players = {}

	local position = 0

	for player, joined in pairs(player_list) do
		if joined and player:is_player_connected() then
			position = position + 1
			players[position] = player
		end
	end

	player_count = position
end

minetest.register_on_joinplayer(function(player)
	bone_rotation_cache[player] = {}
	previous_yaw[player] = {}

	player_list[player] = true
	update_players()
end)

minetest.register_on_leaveplayer(function(player)
	bone_rotation_cache[player] = nil

	look_pitch[player] = nil
	animation_speed[player] = nil

	previous_yaw[player] = nil
	previous_animation[player] = nil

	player_list[player] = nil
	update_players()
end)

minetest.register_globalstep(function(dtime)
	if player_count == 0 then return end

	step = step + dtime
	if step >= 3600 then
		step = 1
	end

	for i = 1, player_count do
		local player = players[i]
		local animation = get_animation(player).animation

		if animation == "lay" then
			set_animation(player, LAY)

			if #previous_yaw[player] ~= 0 then
				previous_yaw[player] = {}
			end
		else
			local controls = player:get_player_control()
			local sneak = controls.sneak

			update_look_pitch(player)

			if animation == "walk" then
				set_animation_speed(player, sneak)
				set_animation(player, WALK)
				body_moving(player, sneak)
			elseif animation == "mine" then
				set_animation_speed(player, sneak)
				set_animation(player, MINE)
				body_moving(player, sneak)
			elseif animation == "walk_mine" then
				set_animation_speed(player, sneak)
				set_animation(player, WALK_MINE)
				body_moving(player, sneak)
			elseif animation == "sit" then
				set_animation(player, SIT)
				body_moving(player, sneak, true)
			else
				set_animation(player, STAND)
				body_moving(player, sneak)
			end
		end
	end
end)
