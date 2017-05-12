------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

maidroid = {}

maidroid.modname = "maidroid"
maidroid.modpath = minetest.get_modpath(maidroid.modname)

dofile(maidroid.modpath .. "/api.lua")
dofile(maidroid.modpath .. "/register.lua")
dofile(maidroid.modpath .. "/crafting.lua")
