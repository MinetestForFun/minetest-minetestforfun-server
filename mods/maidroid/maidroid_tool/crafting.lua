------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

minetest.register_craft{
	output = "maidroid_tool:core_writer",
	recipe = {
		{"default:steel_ingot",     "default:diamond", "default:steel_ingot"},
		{     "default:cobble", "default:steel_ingot",      "default:cobble"},
		{     "default:cobble",      "default:cobble",      "default:cobble"},
	},
}

minetest.register_craft{
	output = "maidroid_tool:egg_writer",
	recipe = {
		{    "default:diamond", "bucket:bucket_water",     "default:diamond"},
		{     "default:cobble", "default:steel_ingot",      "default:cobble"},
		{"default:steel_ingot",      "default:cobble", "default:steel_ingot"},
	},
}

minetest.register_craft{
	output = "maidroid_tool:nametag",
	recipe = {
		{                   "", "farming:cotton",                    ""},
		{      "default:paper",  "default:paper",       "default:paper"},
		{"default:steel_ingot",      "dye:black", "default:steel_ingot"},
	},
}

minetest.register_craft{
	output = "maidroid_tool:capture_rod",
	recipe = {
		{         "wool:white",            "dye:pink", "default:mese_crystal"},
		{                   "", "default:steel_ingot",             "dye:pink"},
		{"default:steel_ingot",                    "",           "wool:white"},
	},
}

