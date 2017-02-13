local types = {
	{"e", "anything"},
	{"v", "any variable"},
	{"ve", "any set variable"},
	{"s", "string"},
	{"vs", "string variable"},
	{"n", "number"},
	{"vn", "number variable"},
	{"ui", "unsigned integer number"},
	{"b", "bool"},
	{"vn", "bool variable"}
}

local instr = {
	{"mov", "<v to>, <e from>", "Copies from into to."},
	{"xchg", "<v a>, <v b>", "Switches a with b."},
	{"getvar", "<vs varname>[, <ve exists>]", "Sets varname to the current variable called <varname> if it's set. If exists is passed, it's set to a bool indicating whether the variable was set."},
	{"add", "<vn to>, <n from>", "to += from"},
	{"add", "<vb to>[, <b ba>[, <b bb>[…]]]", "to indicates whether at least one of the arguments is true"},
	{"add", "<vs to>, <s from>", "to = to .. from"},
	{"sub", "<vn num>, <n tosub>", "num -= tosub"},
	{"sub", "<vs str>, <n start>[, <n end>]", "str = str:sub(start, end)"},
	{"mul", "<vn to>, <n from>", "to *= from"},
	{"mul", "<vb to>[, <b ba>[, <b bb>[…]]]", "to indicates whether all of the arguments are true"},
	{"mul", "<vs str>, <n cnt>", "str = str:rep(from)"},
	{"div", "<vn num>, <n todiv>", "num /= todiv"},
	{"inc", "<vn num>", "++num"},
	{"dec", "<vn num>", "--num"},
	{"neg", "<vn num>", "num = -num"},
	{"neg", "<vb var>", "var = not var"},
	{"neg", "<vs str>", "str = str:rev()"},
	{"inv", "<vn num>", "num = 1 / num"},
	{"mod", "<vn num>, <n dv>", "num = num % dv"},
	{"jmp", "<ui p>[, <e c>]", "If c is not false, the instruction pointer is set to p. To disallow infinite loops, the program is interrupted after changing the ip, the mod should then consider restarting it."},
	{"call", "<ui p>[, <e c>]", "push the ip, then jmp p; used to execute subroutines"},
	{"ret", "", "pop something, then jmp there; used to exit subroutines"},
	{"push", "<e a>[, <e b>[, <e c>[…]]]", "put values onto the stack; from left to right"},
	{"pop", "<v a>[, <v b>[, <v c>[…]]]", "takes values from the stack and sets the passed variables to them; from left to right"},
	{"equal", "<v a>, <e b>", "a = a == b"},
	{"less", "<vn a>, <n b>", "a = a < b; after executing, a is a bool"},
	{"less", "<vs a>, <s b>", "a = a < b; less also works for strings"},
	{"greater", "<v a>, <e b>", "executes less b,a"},
	{"usleep", "<n t>", "aborts the program for at least floor(max(0, t)) ms"},
	{"sleep", "<n t>", "executes usleep with t * 1000000 as argument"},
	{"get_us_time", "<v to>", "stores minetest.get_us_time() into to; can be used to measure time differences"},
	{"tostring", "<ve var>", "var = tostring(var)"},
	{"tonumber", "<ve var>", "var = tonumber(var)"},
	{"toboolean", "<ve var>", "var = var and true or false"},
	{"print", "<e a>[, <e b>[, <e c>[…]]]", "adds variables to the log, seperated by \\t, \\n is added at the end"},
	{"flush", "", "Output the log, this should vary for every mod."},
}

--[[
local mbl = 0
local mal = 0
for i = 1,#instr do
	local bef = instr[i]
	mbl = math.max(#bef[1], mbl)
	mal = math.max(#bef[2], mal)
end--]]

local mtl = 2

local o = "Types:\n\n"
for i = 1,#types do
	local t = types[i]
	o = o .. t[1] .. (" "):rep(mtl - #t[1] + 2) .. t[2] .. "\n"
end

o = o .. "\n\nInstructions:\n\n"
for i = 1,#instr do
	i = instr[i]
	o = o .. i[1] .. "  " .. i[2] .. "\n"
		.. "  " .. i[3] .. "\n\n" -- TODO: max 80 letters each line
end

print(o)
