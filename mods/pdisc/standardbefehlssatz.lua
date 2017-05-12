local WNOA = "wrong number of arguments"
local UAT = "unsupported argument type"
local SE = "error with cmd-cmd executing: "
local STRL = "attempt on exceeding maximum string length"

local s
s = {
	mov = function(params)
		return true, params[2]
	end,

	xchg = function(params)
		return true, params[2], params[1]
	end,

	getvar = function(params, faden)
		local p = params[1]
		if type(p) ~= "string" then
			return false, UAT
		end
		p = faden.vars[p]
		return true, {p, p ~= nil}
	end,

	add = function(params, faden)
		local p1,p2 = unpack(params)
		local t1 = type(p1)
		if t1 ~= type(p2) then
			return false, "different argument types"
		end

		if t1 == "number" then
			return true, p1 + p2
		end
		if t1 == "boolean" then
			for _,k in pairs(params) do
				if k then
					return true, true
				end
			end
			return true, false
		end
		if t1 == "string" then
			if #p1 + #p2 > faden.strlen_max then
				return false, STRL
			end
			return true, p1 .. p2
		end
		return false, UAT
	end,

	sub = function(params)
		local b = params[2]
		b = b and tonumber(b)
		local t2 = type(b)
		if t2 ~= "number" then
			return false, UAT
		end
		local t1 = type(params[1])
		if t1 == "number" then
			return true, params[1] - b
		end
		if t1 == "string" then
			return true, params[1]:sub(b, params[3] and tonumber(params[3]))
		end
	end,

	mul = function(params)
		local p1,p2 = unpack(params)
		local t1 = type(p1)
		local t2 = type(p2)
		if t1 == "string"
		and t2 == "number" then
			if #p1 * p2 > faden.strlen_max then
				return false, STRL
			end
			return true, p1:rep(p2)
		end
		if t1 ~= t2 then
			return false, "different argument types"
		end

		if t1 == "number" then
			return true, p1 * p2
		end
		if t1 == "boolean" then
			for _,k in pairs(params) do
				if not k then
					return true, false
				end
			end
			return true, p1 and p2 -- nil is tested in the first two params
		end
		return false, UAT
	end,

	div = function(params)
		local p1,p2 = unpack(params)
		if type(p1) ~= "number"
		or type(p2) ~= "number" then
			return false, UAT
		end
		return true, p1 / p2
	end,

	inc = function(params)
		if type(params[1]) ~= "number" then
			return false, UAT
		end
		return true, params[1] + 1
	end,

	dec = function(params)
		if type(params[1]) ~= "number" then
			return false, UAT
		end
		return true, params[1] - 1
	end,

	neg = function(params)
		local v = params[1]
		local t = type(v)
		if t == "number" then
			return true, -v
		end
		if t == "boolean" then
			return true, not v
		end
		if t == "string" then
			return true, v:rev() -- does string.rev exist?
		end
		return false, UAT
	end,

	inv = function(params)
		local p = params[1]
		if type(p) ~= "number" then
			return false, UAT
		end
		return true, 1 / p
	end,

	mod = function(params)
		local p1,p2 = unpack(params)
		if type(p1) ~= "number"
		or type(p2) ~= "number" then
			return false, UAT
		end
		return true, p1 % p2
	end,

	jmp = function(params, faden)
		if #params >= 2
		and not params[2] then
			return true
		end
		local p = params[1]
		if type(p) ~= "number" then
			return false, UAT
		end
		if p < 1
		or p%1 ~= 0
		or p > #faden.liste + 1 then
			return false, "jump target out of range"
		end
		faden.ip = p-1
		if not s.usleep({0}, faden) then
			error(SE)
		end
		return true
	end,

	call = function(params, faden)
		local subsucc,msg = s.push(faden.ip + 1, faden)
		if not subsucc then
			return false, SE .. msg
		end
		subsucc,msg = s.jmp(params, faden)
		if not subsucc then
			return false, SE .. msg
		end
		return true
	end,

	ret = function(_, faden)
		local subsucc,msg = s.pop({true}, faden)
		if not subsucc then
			return false, SE .. msg
		end
		subsucc,msg = s.jmp(msg, faden)
		if not subsucc then
			return false, SE .. msg
		end
		return true
	end,

	push = function(params, faden)
		local pc = #params
		if pc == 0 then
			return false, WNOA
		end
		for i = 1,pc do
			faden.stack[faden.sp] = params[i]
			faden.sp = faden.sp-1
		end
		if faden.sp < 0 then
			return false, "stack overflow"
		end
		return true
	end,

	pop = function(params, faden)
		local pc = #params
		if pc == 0 then
			return false, WNOA
		end
		local rt = {}
		for i = 1,pc do
			faden.sp = faden.sp+1
			rt[i] = faden.stack[faden.sp]
		end
		if faden.sp > faden.sb then
			return false, "stack underflow"
		end
		return true, rt
	end,

	equal = function(params)
		return true, params[1] == params[2]
	end,

	less = function(params)
		local p1,p2 = unpack(params)
		local t1 = type(p1)
		if t1 ~= type(p2) then
			return false, "different argument types"
		end

		if t1 ~= "number"
		and t1 ~= "string" then
			return false, UAT
		end
		return true, p1 < p2
	end,

	greater = function(params)
		return s.less{params[2], params[1]}
	end,

	usleep = function(params, faden)
		local p = params[1]
		if type(p) ~= "number" then
			return false, UAT
		end
		faden.rebirth = minetest.get_us_time() + p
		faden:stop()
		return true
	end,

	sleep = function(params, faden)
		local p = params[1]
		if type(p) ~= "number" then
			return false, UAT
		end
		local subsucc,msg = s.usleep({p * 1000000}, faden)
		if not subsucc then
			error(SE .. msg)
		end
		return true
	end,

	get_us_time = function()
		return true, minetest.get_us_time()
	end,

	tostring = function(params)
		return true, params[1] and tostring(params[1]) or nil
	end,

	tonumber = function(params)
		return true, params[1] and tonumber(params[1])
	end,

	toboolean = function(params)
		return true, params[1] and true or false
	end,

	print = function(params, faden)
		for i = 1,#params do
			params[i] = tostring(params[i])
		end
		faden.log = faden.log .. table.concat(params, "\t") .. "\n"
		return true
	end,

	flush = function(params, faden)
		return faden:flush(params)
	end,
}

local so_math_fcts = {"sin", "asin", "cos", "acos", "tan", "atan", "exp", "log",
	"abs", "sign", "floor", "ceil"}
for i = 1,#so_math_fcts do
	i = so_math_fcts[i]
	s[i] = function(params)
		local p = params[1]
		if type(p) ~= "number" then
			return false, "this arithmetic function needs a number as argument"
		end
		return true, math[i](p)
	end
end

local to_math_fcts = {"pow"}
for i = 1,#to_math_fcts do
	i = to_math_fcts[i]
	s[i] = function(params)
		local p1,p2 = unpack(params)
		if type(p1) ~= "number"
		or type(p2) ~= "number" then
			return false, "this arithmetic function needs 2 numbers as args"
		end
		return true, math[i](p1, p2)
	end
end

local abbreviations = {
	mov = ":=",
	add = "+",
	sub = "-",
	mul = "*",
	div = "/",
	inc = "++",
	dec = "--",
	neg = "!",
	less = "<",
	equal = "==",
	jmp = "@",
	usleep = "...",
}
-- TODO set metatable

return s
