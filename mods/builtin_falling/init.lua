dofile(minetest.get_modpath("builtin_falling") .. "/func.lua") -- Not EDIT THAT
--
-- Config
--

-- Protect in realtime the lava flowing (can be slow)
PROTECT_LAVA_REALTIME = 0 -- 0 for OFF , 1 for ON
-- Protect in realtime the water flowing (can be very slow, because some water in this world :p)
PROTECT_WATER_REALTIME = 0 -- 0 for OFF , 1 for ON

--
-- List of your node need to rewirte
--

--Default
add_falling_protect_item("default:sand")
add_falling_protect_item("default:gravel")
add_falling_protect_item("default:desert_sand") -- prevent cheat from falling node


-- Snow
--add_falling_protect_item("default:snow") -- another falling but maybe it's more realistique to not delete it ?
add_falling_protect_item("default:snowblock")

--Mod Pyramid
add_falling_protect_item("tsm_pyramids:trap_2")

--Mod SeaGravel
add_falling_protect_item("seagravel:seagravel")
add_falling_protect_item("seagravel:seagravel_cyan")
add_falling_protect_item("seagravel:seagravel_magenta")
add_falling_protect_item("seagravel:seagravel_lime")
add_falling_protect_item("seagravel:seagravel_aqua")
add_falling_protect_item("seagravel:seagravel_skyblue")
add_falling_protect_item("seagravel:seagravel_redviolet")
add_falling_protect_item("stairs:seagravel")
add_falling_protect_item("stairs:seagravel_cyan")
add_falling_protect_item("stairs:seagravel_magenta")
add_falling_protect_item("stairs:seagravel_lime")
add_falling_protect_item("stairs:seagravel_aqua")
add_falling_protect_item("stairs:seagravel_skyblue")
add_falling_protect_item("stairs:seagravel_redviolet")

-- Mod Sea
add_falling_protect_item("whiteshell:whiteshell")
add_falling_protect_item("clams:sandalgae")
add_falling_protect_item("clams:sandalgaeused")
add_falling_protect_item("seawrecks:woodship")

-- Mod SeaPlant
add_falling_protect_item("seaplants:seaplantssandkelpgreen")
add_falling_protect_item("seaplants:seaplantssandkelpbrown")
add_falling_protect_item("seaplants:seaplantssandseagrassgreen")
add_falling_protect_item("seaplants:seaplantssandseagrassred")


-- Default liquid
add_protected_bukket_liquid("bucket:bucket_lava","default:lava_source") -- lava bukket
add_protected_bukket_liquid("bucket:bucket_water","default:water_source") -- water bukket

 -- Not EDIT AFTER
dofile(minetest.get_modpath("builtin_falling") .. "/rewirting.lua") -- Not EDIT THAT
