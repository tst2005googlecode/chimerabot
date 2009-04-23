END = "\r\n"
socket = require("socket")
tcpsock = socket.tcp()

server = "irc.toribash.com"
nickname = "Chimera"
masterpass = "9001"
masterauth = "1337-BC651D7C.nctv.com"

authlist = {}
reaction = {}
target = ""
source = ""
oplist = {}
noisy = 1
color_mode = 1

hook_list = {}
module_list = {}
module_list.current = nil


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


tcpsock:connect(server, 6667)
alive = true

function block_till_connect()
	result = 0
	while(result ~= 1) do
		tcpsock:close()
		tcpsock = nil
		tcpsock = socket.tcp()
		print("Attempting to connect (retry in 55 seconds)...")
		result,err = tcpsock:connect(server, 6667) 
		result = result or ""
		if err then 
			print("Error> " .. result .. " " .. err) 
			socket.sleep(5)
		end
		
	end

end

function mask_to_nick(hmask)
	loc = string.find(hmask,"!",1,true) or 0
	return string.sub(hmask,1,loc-1)
end

function mask_to_end(hmask)
	loc = string.find(hmask,"@",1,true)
	return string.sub(hmask,loc + 1)
end

function push(tosend) tcpsock:send(tosend .. END) end

function echo(apass, sendto) 
	if string.lower(target) == string.lower(nickname) then newtarget = mask_to_nick(source) else newtarget = target end
	sendto = sendto or newtarget
	push("PRIVMSG " .. sendto .. " " .. apass) 
end

function add_hook(tohook,tag,cmd)
	topush = {target = tohook, name = tag, link = cmd}
	table.insert(hook_list, topush)
end

function remove_hook(tag)
	for i,v in ipairs(hook_list) do
		if v.name == tag then 
			table.remove(hook_list,i) 
		end
	end
end
		
function load_module(mname)

	local mhold = module_list.current
	module_list.current = mname
	print("Loading module " .. mname .. "...")
	module_list[module_list.current] = {}
	
	loadstr = "dofile('modules/" .. mname .. ".lua')"
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

function require_mod(modname)
	if module_list[modname] == nil then 
		load_module(modname)
	else
		echo(ctcp_color(12) .. "== Module " .. modname .. " already loaded.")
	end
end

block_till_connect()

require_mod('corefunc')
require_mod('timing')
require_mod('usertable')
----------------------------------------------------
require_mod('chanadmin')
require_mod('advanced')
----------------------------------------------------

chat = {}
chat[1] = {	trigger = nickname,	place = "any", reply = "hmm?"}
chat[2] = {	trigger = "o/" ,place = "start", reply = "o/*\\o"}

tcpsock:settimeout(0) --non-blocking

while (alive) do
	inlin,err = tcpsock:receive('*l')
	if inlin ~= nil then
		if string.find(inlin, "*** Found your hostname") then
			push("USER " .. nickname .. " 8 * :Chimera")
			push("NICK " .. nickname)
			print("==Logged in==")
		end
		
		chop = slice(inlin)
	
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
		if err == 'closed' then 
			print('====DISCONNECTED====')

			block_till_connect()
			
		end
	end
	
	
	handle_timing()
	inlin = nil
end

