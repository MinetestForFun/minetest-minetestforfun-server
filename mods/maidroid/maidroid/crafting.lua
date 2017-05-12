------------------------------------------------------------
-- Copyright (c) 2016 tacigar. All rights reserved.
-- https://github.com/tacigar/maidroid
------------------------------------------------------------

minetest.register_craft{
	output = "maidroid:empty_egg",
	recipe = {
		{"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"},
		{"default:bronze_ingot",  "default:steel_ingot", "default:bronze_ingot"},
		{"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"},
	},
}
