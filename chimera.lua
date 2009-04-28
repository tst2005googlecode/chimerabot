END = "\r\n"
socket = require("socket")
tcpsock = socket.tcp()

bot_path = "" --Path to bot dir. EDIT THIS YO

server = "irc.toribash.com"
nickname = "Chimera"
masterpass = "9001"
masterauth = "1337-BC651D7C.nctv.com"
join_on_connect = "#test2"

authlist = {}
reaction = {}
target = ""
source = ""
oplist = {}
noisy = 1
color_mode = 1
verbose_mode = 0

hook_list = {}
module_list = {}
module_list.current = nil
socket_list = {}

alive = true

--[[CTCP Stuff:
There is alot of misnomer here, but I don't feel like fixing yet.
You can pass the ctcp_color function either a single color (sets only foreground)
or two colors (sets fore and back).  The func returns the required string to 
change the color in an IRC string.  The table members are for changing other 
things relating to appearance.  The only properly-named thing in this table is
ctcp.norm, which represents the ansi char needed for ctcp replies and requests.
]]--
ctcp = {}
function ctcp_color(a,b) 
	toret = ""
	if color_mode == 1 then 
		toret = string.char(3) .. a
		if b ~= nil then toret = toret .. "," .. b end
	end
	return toret
end

ctcp.norm = string.char(1)
ctcp.plain = string.char(15)
ctcp.bold = string.char(2)
ctcp.underline = string.char(31)
ctcp.reverse = string.char(22)

--Use this function to handle (re)connecting.
function block_till_connect()
	result = 0
	while(result ~= 1) do
		tcpsock:close()
		tcpsock = nil
		tcpsock = socket.tcp()
		tcpsock:settimeout(5)
		print("Attempting to connect (retry in 5 seconds)...")
		result,err = tcpsock:connect(server, 6667) 
		result = result or ""
		if err then 
			print("Error> " .. result .. " " .. err) 
			socket.sleep(5)
		end
		
	end
	tcpsock:settimeout(0)
	--------------------Need this---------------------------
	require_mod('corefunc')
	require_mod('timing')
	require_mod('usertable')
	---I want this to load on startup because I'm lazy------
	require_mod('chanadmin')
	require_mod('advanced')
	require_mod('web')
	--------------------------------------------------------


end

--Takes a complete maskline ( nick!user@hostmask ) and returns only the nick.
function mask_to_nick(hmask)
	loc = string.find(hmask,"!",1,true) or 0
	return string.sub(hmask,1,loc-1)
end

--Takes a complete maskline ( nick!user@hostmask ) and returns only the mask.
function mask_to_end(hmask)
	loc = string.find(hmask,"@",1,true)
	return string.sub(hmask,loc + 1)
end

--Pushes out a line of text to the server and add the proper terminators (CRLF)
function push(tosend) tcpsock:send(tosend .. END) end

--Echos out a string to specified channel or nick.  If no target specified, defaults to last 
--source bot recieved text from.
function echo(apass, sendto) 
	if string.lower(target) == string.lower(nickname) then newtarget = mask_to_nick(source) else newtarget = target end
	sendto = sendto or newtarget
	push("PRIVMSG " .. sendto .. " " .. apass) 
end

--Add a function hook.  See modules for usage.
function add_hook(tohook,tag,cmd)
	topush = {target = tohook, name = tag, link = cmd}
	table.insert(hook_list, topush)
end

--Removes specified hook(s)
function remove_hook(tag)
	for i,v in ipairs(hook_list) do
		if v.name == tag then 
			table.remove(hook_list,i) 
		end
	end
end
		
--Loads a module. I reccomend using require_mod instead so you don't have a chance
--of doubling up.
function load_module(mname)

	local mhold = module_list.current
	module_list.current = mname
	print("Loading module " .. mname .. "...")
	module_list[module_list.current] = {}
	module_path = bot_path .. "modules/" .. mname .. ".lua"
	loadstr = "dofile(module_path)"

	callstate, callerror = pcall(loadstring(loadstr), function () end) 
	
	if callstate == false then 
		print("ERROR: ".. callerror)
		echo(ctcp_color(1,4) .. ctcp.underline ..  "ERROR:"	.. ctcp.plain .. " " .. callerror) 
		module_list[module_list.current] = nil
	else
		echo(ctcp_color(12) .. "== Module " .. mname .. " loaded.")
	end
	
	module_list.current = mhold
end

--Loads a module only if it hasn't been loaded yet.
function require_mod(modname)
	if module_list[modname] == nil then 
		load_module(modname)
	else
		echo(ctcp_color(12) .. "== Module " .. modname .. " already loaded.")
	end
end


--Main logic loop here
function run_logic()
	
	while(alive==true) do
		run_bot()
		handle_timing()
		for i,v in ipairs(hook_list) do	if v.target == "cycle" then v.link() end end --hook caller
	end
	
end


--I will make this stuff useful later.  For now, it is not worth
--looking at.
chat = {}
chat[1] = {	trigger = nickname,	place = "any", reply = "hmm?"}
chat[2] = {	trigger = "o/" ,place = "start", reply = "o/*\\o"}

--Process all the IRC stuff.
function run_bot()
	--Grab a line
	
	inlin,err = tcpsock:receive('*l')
	
	--If content exists, lets process it.
	if inlin ~= nil then 
		
		--Logs the bot in, will make less hackish later.
		if string.find(inlin, "*** Found your hostname") then
			push("USER " .. nickname .. " 8 * :" .. nickname)
			push("NICK " .. nickname)
			print("==Logged in==")
		end
		--Chop line up into components.
		chop = slice(inlin)
		
		if verbose_mode == 1 then print(inline) end
		
		--Will relocate this later.  Keeps bot alive on server.
		if chop.source == "PING" then 
			push("PONG " .. chop.text) 
		end
		
		if string.sub(chop.text,1,1) == "!" then 
			handle_cmd(chop.text, chop.target, chop.source) 
		else
			parsechat(chop.text, chop.target, chop.source)
		end

		for i,v in ipairs(hook_list) do	if v.target == "parse_raw" then v.link(chop) end end --hook caller
	
	else
		--Otherwise our connection got dumped.  If this is so, start handling it.
		if err == 'closed' then 
			print('====DISCONNECTED====')
			block_till_connect()
		end
	end
	
	inlin = nil
end

--Bootstrap stuff.
block_till_connect()
run_logic()