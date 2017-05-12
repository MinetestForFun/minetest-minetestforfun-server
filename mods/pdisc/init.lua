local load_time_start = minetest.get_us_time()


local mpath = minetest.get_modpath"pdisc" .. "/"

pdisc = {
	parse = dofile(mpath .. "parser.lua"),
	standard_befehlssatz = dofile(mpath .. "standardbefehlssatz.lua"),
	create_thread = dofile(mpath .. "faden.lua")
}


local time = (minetest.get_us_time() - load_time_start) / 1000000
local msg = "[pdisc] loaded after ca. " .. time .. " seconds."
if time > 0.01 then
	print(msg)
else
	minetest.log("info", msg)
end
