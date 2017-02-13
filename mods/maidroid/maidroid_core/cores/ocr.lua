------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

local maidroid_instruction_set = {
	-- popular (similars in lua_api) information gathering functions
	getpos = function(_, thread)
		local pos = thread.droid.object:getpos()
		return true, {pos.x, pos.y, pos.z}
	end,

	getvelocity = function()
		local vel = self.vel
		return true, {vel.x, vel.y, vel.z}
	end,

	getacceleration = function(_, thread)
		local acc = thread.droid.object:getacceleration()
		return true, {acc.x, acc.y, acc.z}
	end,

	getyaw = function(_, thread)
		return true, thread.droid.object:getyaw()
	end,

	-- other info functions

	-- popular actions for changing sth
	setyaw = function(params, thread)
		if #params ~= 1 then
			return false, "wrong number of arguments"
		end
		local p = params[1]
		if type(p) ~= "number" then
			return false, "unsupported argument"
		end
		thread.droid.object:setyaw(p)
		return true
	end,

	-- other actions
	jump = function(params, thread)
		-- test if it can jump
		local droid = thread.droid
		if droid.vel.y ~= 0
		or droid.vel_prev.y ~= 0 then
			return true, false
		end

		-- get the strength of the jump
		local h = tonumber(params[1])
		if not h
		or h <= 0
		or h > 2 then
			h = 1
		end

		-- play sound
		local p = droid.object:getpos()
		p.y = p.y - 1
		local node_under = minetest.get_node(p).name
		local def = minetest.registered_nodes[node_under]
		if def
		and def.sounds then
			local snd = def.sounds.footstep or def.sounds.dig
			if snd then
				p.y = p.y + .5
				minetest.sound_play(snd.name, {pos = p, gain = snd.gain})
			end
		end

		-- perform jump
		droid.vel.y = math.sqrt(-2 * h * droid.object:getacceleration().y)
		droid.object:setvelocity(droid.vel)
		return true, true
	end,

	beep = function(_, thread)
		minetest.sound_play("maidroid_beep", {pos = thread.droid.object:getpos()})
		return true
	end,
}


local function mylog(log)
	-- This happens to the maidroids messages
	minetest.chat_send_all("maidroid says " .. log)
end

-- the program is loaded from a "default:book_written" with title "main"
-- if it's not present, following program is used in lieu:
local dummycode = [[
beep
print $No book with title "main" found.
]]

local function get_code(self)
	local list = self:get_inventory():get_list"main"
	for i = 1,#list do
		local stack = list[i]
		if stack:get_name() == "default:book_written" then
			local data = minetest.deserialize(stack:get_metadata())
			if data
			and data.title == "main" then
				return data.text
			end
		end
	end
end

local function on_start(self)
	self.object:setacceleration{x = 0, y = -10, z = 0}
	self.object:setvelocity{x = 0, y = 0, z = 0}
	self.vel = {x = 0, y = 0, z = 0}
	self.vel_prev = self.vel

	local parsed_code = pdisc.parse(get_code(self) or dummycode)
	self.thread = pdisc.create_thread(function(thread)
		thread.flush = function(self)
			mylog(self.log)
			self.log = ""
			return true
		end
		table.insert(thread.is, 1, maidroid_instruction_set)
		thread.droid = self
	end, parsed_code)
	self.thread:suscitate()
end

local function on_step(self)
	local thread = self.thread
	if not thread.stopped then
		return
	end
	self.vel_prev = self.vel
	self.vel = self.object:getvelocity()

	thread:try_rebirth()
end

local function on_resume(self)
	self.thread:continue()
end

local function on_pause(self)
	self.thread:flush()
end

local function on_stop(self)
	self.thread:exit()
	self.thread = nil

	self.object:setvelocity{x = 0, y = 0, z = 0}
end

-- register a definition of a new core.
maidroid.register_core("maidroid_core:ocr", {
	description      = "OCR programmable maidroid core",
	inventory_image  = "maidroid_core_ocr.png",
	on_start         = on_start,
	on_stop          = on_stop,
	on_resume        = on_resume,
	on_pause         = on_pause,
	on_step          = on_step,
})
