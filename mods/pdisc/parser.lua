local function parse_zeile(marken, imms, z, ip)
	-- Kommentar entfernen
	local komment = z:find";"
	if komment then
		z = z:sub(1, komment-1)
	end

	z = z:trim()
	if #z == 0 then
		return {}
	end

	-- Marke erkennen
	local marke = z:find":"
	if marke then
		local mname = z:sub(1, marke - 1)
		marken[mname] = ip

		z = z:sub(marke+1):trim()
		if #z == 0 then
			return {}
		end
	end

	-- Befehl erkennen
	local immn = #imms+1
	local befehl = z
	local args
	local leernb = z:find" "
	if leernb then
		befehl = z:sub(1, leernb - 1)

		-- Argument(e) erkennen
		z = z:sub(leernb+1):trim()
		args = z:split","
		for i = 1,#args do
			local arg = args[i]:trim()
			if #arg == 0
			or arg == "false" then
				arg = false
			elseif arg == "true" then
				arg = true
			elseif arg:sub(1, 1) == "$" then
				imms[immn] = arg:sub(2)
				arg = immn
				immn = immn+1
			elseif tonumber(arg) then
				imms[immn] = tonumber(arg)
				arg = immn
				immn = immn+1
			end
			args[i] = arg
		end
	end

	return {befehl, args}
end

return function(programm)
	local imms = {}
	local marken = {}

	-- Programm erkennen
	local zeilen = programm:split"\n"
	local anz = 0
	local liste = {}
	for i = 1,#zeilen do
		local befehl = parse_zeile(marken, imms, zeilen[i], anz + 1)
		if befehl[1] then
			anz = anz + 1
			liste[anz] = befehl
		end
	end
	local immn = #imms+1

	-- Marken durch immediates ersetzen
	for i = 1,anz do
		local args = liste[i][2]
		if args then
			for i = 1,#args do
				local mwert = marken[args[i]]
				if mwert then
					imms[immn] = mwert
					args[i] = immn
					immn = immn+1
				end
			end
		end
	end

	return {imms, liste}
end
