local function befehl_ausfuhren(faden)
	local is = faden.is
	local imms = faden.imms
	local vars = faden.vars
	local anw = faden.liste[faden.ip]
	if not anw then
		return false, "Invalid instruction pointer"
	end
	local befehl, args = unpack(anw)
	for i = 1,#is do
		local bfunk = is[i][befehl]
		if bfunk then
			local fa = {}
			local ersetzbar = {}
			if args then
				for i = 1,#args do
					local arg = args[i]
					if type(arg) == "number" then
						fa[i] = imms[arg]
					else
						fa[i] = vars[arg]
						ersetzbar[i] = true
					end
				end
			end
			local weiter, ergebnis = bfunk(fa, faden)
			if not weiter then
				return false, "Command " .. befehl .. ": " .. ergebnis
			end
			if args
			and ergebnis ~= nil then
				if type(ergebnis) ~= "table" then
					ergebnis = {ergebnis}
				end
				for i,v in pairs(ergebnis) do
					if args[i]
					and ersetzbar[i] then
						vars[args[i]] = v
					end
				end
			end
			faden.ip = faden.ip + 1
			if faden.ip > #faden.liste then
				return false, "Done"
			end
			return true
		end
	end
	return false, 'Unknown command "' .. befehl .. '"'
end

local function programm_ausfuhren(faden)
	local weiter,msg = befehl_ausfuhren(faden)
	if not weiter then
		faden.log = faden.log .. "Aborted (" .. faden.ip .. "): " .. msg .. "\n"
		faden:exit()
		return
	end
	return not faden.stopped and programm_ausfuhren(faden)
end

return function(faden_manip, parsed)
	local faden = {
		log = "",
		vars = {pi = math.pi},
		ip = 1,
		sp = 3500,
		sb = 3500,
		strlen_max = 2000,
		stack = {},
		is = {pdisc.standard_befehlssatz},
		suscitate = programm_ausfuhren,
		flush = function(self)
			print(self.log)
			self.log = ""
			return true
		end,
		stop = function(self)
			self.stopped = true
		end,
		continue = function(self)
			self.stopped = false
			self:suscitate()
		end,
		try_rebirth = function(self)
			if minetest.get_us_time() >= self.rebirth then
				self:continue()
				return true
			end
			return false
		end,
		exit = function(self)
			self:flush()
		end,
	}
	if parsed then
		faden.imms = parsed[1]
		faden.liste = parsed[2]
		if not faden.liste[1] then
			faden.suscitate = function(self)
				self.log = self.log .. "Nothing to execute.\n"
				self:exit()
			end
		end
	end
	faden_manip(faden)
	return faden
end
