-- See also the pdisc mod's instruction list.

local instr = {
	{"getpos", "<v x>, <v y>, <v z>", "Gets the maidroid's position."},
	{"getvelocity", "<v x>, <v y>, <v z>", "Gets the maidroid's velocity."},
	{"getacceleration", "<v x>, <v y>, <v z>", "Gets the maidroid's acceleration."},
	{"getyaw", "<v yaw>", "Gets the maidroid's yaw."},


	{"setyaw", "<n yaw>", "Sets the maidroid's yaw in radians."},

	{"jump", "[<n heigth>]", "Makes the droid jump, if height is invalid (height ∈ ]0,2]), it's set to 1, if it's a variable, it's set to a bool indicating whether the jump succeeded."},
	{"beep", "", "Execute this every second while the droid walks backwards, pls."},
}

o = "Instructions:\n\n"
for i = 1,#instr do
	i = instr[i]
	o = o .. i[1] .. "  " .. i[2] .. "\n"
		.. "  " .. i[3] .. "\n\n" -- TODO: max 80 letters each line
end

print(o)
