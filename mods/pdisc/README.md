commands are read line by line

```[<labelname>:] [<commandname> [<arg1>[,<arg2[…]]]] [; <comment>]```

arguments can be either variables, labels or immediates,  
labels are replaced with immediates which have the line numbers of the labels as their values  
true/false: boolean (immediate)  
12.6: number (immediate)  
$hello nwae: string (immediate)  
nodolla: either a label is called so (immediate) or it's a variable

```
Types:

e   anything
v   any variable
ve  any set variable
s   string
vs  string variable
n   number
vn  number variable
ui  unsigned integer number
b   bool
vn  bool variable


Instructions:

mov  <v to>, <e from>
  Copies from into to.

getvar  <vs varname>[, <ve exists>]
  Sets varname to the current variable called <varname> if it's set. If exists is passed, it's set to a bool indicating whether the variable was set.

add  <vn to>, <n from>
  to += from

add  <vb to>, <b from>
  to = to and from

add  <vs to>, <s from>
  to = to .. from

mul  <vn to>, <n from>
  to *= from

mul  <vb to>, <b from>
  to = to or from

mul  <vs str>, <n cnt>
  str = str:rep(from)

neg  <vn num>
  num = -num

neg  <vb var>
  var = not var

neg  <vs str>
  str = str:rev()

inv  <vn num>
  num = 1 / num

mod  <vn num>, <n dv>
  num = num % dv

jmp  <ui p>[, <e c>]
  If c is not false, the instruction pointer is set to p. To disallow infinite loops, the program is interrupted after changing the ip, the mod should then consider restarting it.

call  <ui p>
  push the ip, then jmp p; used to execute subroutines

ret  
  pop something, then jmp there; used to exit subroutines

push  <e a>[, <e b>[, <e c>[…]]]
  put values onto the stack; from left to right

pop  <v a>[, <v b>[, <v c>[…]]]
  takes values from the stack and sets the passed variables to them; from left to right

equal  <v a>, <e b>
  a = a == b

less  <vn a>, <n b>
  a = a < b; after executing, a is a bool

less  <vs a>, <s b>
  a = a < b; less also works for strings

usleep  <n t>
  aborts the program for at least floor(max(0, t)) ms

sleep  <n t>
  executes usleep with t * 1000000 as argument

get_us_time  <v to>
  stores minetest.get_us_time() into to; can be used to measure time differences

tostring  <ve var>
  var = tostring(var)

print  <e a>[, <e b>[, <e c>[…]]]
  adds variables to the log, seperated by \t, \n is added at the end

flush  
  Output the log, this should vary for every mod.
```



How mods can use this mod:

```
local mylog = print

local parsed_code = pdisc.parse(code_text)

local function mystart(parsed_code)
	local thread = pdisc.create_thread(function(thread)
		thread.flush = function(self)
			mylog(self.log)
			self.log = ""
			return true
		end
	end, parsed_code)
	thread:suscitate()
	mykeepalive(thread)
end

mystart(parsed_code)

local function mykeepalive(thread)
	if not thread.stopped then
		return
	end
	thread:try_rebirth()
	minetest.after(0.1, function()
		mykeepalive()
	end)
end
```


TODO:  
* add string. instructions
* metatable
