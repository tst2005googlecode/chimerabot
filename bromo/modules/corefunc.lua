require_mod('usertable')

allocate_namespace("core")
core = {}


print("Loading functions.")

function core.slice(inline)
	
	retable = {}
	retable.args = 0
	retable.text = ""
	retable.source = ""
	retable.command = ""
	retable.target = ""
	
	local i = 2
	mainsplit = string.find(inline,":",i,true)
	if mainsplit and mainsplit < #inline then retable.text = string.sub(inline,mainsplit+1) end
	
	chop = inline
	if string.sub(inline,1,1) == ":" then chop = string.sub(inline,2) end
	chop = " " .. chop
	
	chunked = {}
	
	for chunk in string.gmatch(chop," [%a%d%p]+") do
		chunk = string.sub(chunk,2)
		if string.sub(chunk,1,1) == ":" then break end
		table.insert(chunked, chunk)
	end
	
	retable.args = #chunked - 3
	if retable.args < 0 then retable.args = 0 end
	
	retable.source = chunked[1] or ""
	retable.command = chunked[2] or ""
	retable.target = chunked[3] or ""
	
	if retable.args > 0 then end
	
	for foo = 4, (retable.args + 3), 1 do
		
		table.insert(retable,chunked[foo])
	end
		
	return retable

end

function core.lop(inline)
	tochop = inline
	i = string.find(inline," ")
	if i then return string.sub(inline,1,i-1), string.sub(inline, i+1) end
	return inline,""
end

function core.join(tojoin)
	echo(ctcp_color(12) .. "== Joining " .. tojoin)
	print("== Joining " .. tojoin)
	push('JOIN ' .. tojoin)
end

function core.leave(toleave)
	echo(ctcp_color(12) .. "== Leaving " .. toleave)
	print("== Leaving " .. toleave)
	push('PART ' .. toleave)
end

function core.die()
    print("== Shutting down...")
	echo(ctcp_color(4) .. "== Shutting down...")
	tcpsock:shutdown()
	alive = false
end

function core.handle_cmd(inline, targ, sourc)
	target = targ
	source = sourc
	command, inline = core.lop(inline)
	if command == "" then command = inline end
	command = string.sub(command,2)

	for i,v in ipairs(reaction) do
		if command == reaction[i].command then
			safetorun = true
			if reaction[i].auth == true then
				safetorun = false
				for i,v in ipairs(authlist) do 
					if v == mask_to_end(source) then safetorun = true end 
				end
			end
			
			if safetorun == true then 
				print("== " .. mask_to_nick(source) .. " executed " .. command .. ".")
				arglist = {}
				for x=1,reaction[i].args,1 do
					newarg, inline = core.lop(inline)
					table.insert(arglist, newarg)
				end
				if reaction[i].passleft then table.insert(arglist, inline) end
				
				if reaction[i].cmdtype == "function" then reaction[i].link(unpack(arglist)) 
				elseif reaction[i].cmdtype == "dynamic" then 
					callstate, callerror = pcall(loadstring(reaction[i].link), function () end) 
					if callstate == false then 
						echo(ctcp_color(1,4) .. ctcp.underline ..  "ERROR:"	.. ctcp.plain .. " " .. callerror) 
					end
				end
			end
			
		end
	end

end

function core.parsechat(inline, targ, sourc)
	target = targ
	source = sourc

	--Process the stuff in chat[]
	if tonumber(noisy) == 1 then  
		for i,v in ipairs(chat) do
			temp = string.find(inline, v.trigger)
			if temp then
				if v.place == "any" then
					echo(v.reply)
				end
				if v.place == "start" and temp == 1 then
					echo(v.reply)
				end
			end
		end
	end
	
	--We should move this to a better place.
	if string.sub(inline,1,1) == ctcp.norm then
		
		if string.sub(inline,2,8) == "VERSION" then
			print("VERSION from " .. source)
			push("NOTICE " .. mask_to_nick(source) .. " " .. ctcp.norm .. "VERSION NewbLuck's Chimera v0.05 on luasockets v2.0.2" .. ctcp.norm)
		end

		if string.sub(inline,2,5) == "PING" then
			print("PING from " .. source)
			push("NOTICE " .. mask_to_nick(source) .. " " .. inline)
		end
		
	end
	
	for i,v in ipairs(hook_list) do	if v.target == "parse_chat" then v.link(inline) end end --hook caller

end

function core.list_cmd()
	sendto = mask_to_nick(source)
	todump = ''
	echo(ctcp_color(9) .. ctcp.bold .. "-- For more information on a command, use !help <command> --", sendto)
	for modname, mdata in pairs(module_list) do
		todump = ""
		for cname,htext in pairs(mdata) do
			if cname ~= "namespace" then
				for k,v in pairs(reaction) do 
					if v.command == cname and v.auth == true then todump = todump .. ctcp_color(4) .. "*" .. ctcp.plain end
				end	
				todump = todump .. cname .. " "
			end
		end
		if todump ~= "" then
			echo(ctcp_color(9) .. ctcp.underline .. "-- In module " .. modname .. " --", sendto)
			echo(todump, sendto)
		end
	end
	
end

function core.do_auth(pass)

	if pass == masterpass then 
		table.insert(authlist,mask_to_end(source)) 
		print("== " .. mask_to_nick(source) .. " authorized.")
		echo(ctcp_color(12) .. "== " .. mask_to_nick(source) .. " authorized.")
	else
		kick(target, mask_to_nick(source), "Nice try fag lol")
	end

end

function core.force_auth(nick)
	chan = target
	local v = find_user(nick,chan)
	if v then
		table.insert(authlist,v.mask)
		print("== " .. v.mask .. " authorized.")
		echo(ctcp_color(12) .. "== " .. v.mask .. " authorized.")
	else
	end
end

function core.get_help(incmd)
	found = false
	for modname, mdata in pairs(module_list) do
		for cname,htext in pairs(mdata) do
			if cname == incmd then
				echo(ctcp_color(9) .. ctcp.underline .. "-- Help for command [" .. cname .. "] in " .. modname .. " module --", mask_to_nick(source))
				echo(ctcp_color(9) .. htext, mask_to_nick(source))
				found = true
			end
		end
	end
	if found == false then
		echo(ctcp_color(9) .. "-- Command [" .. incmd .. "] not found. --", mask_to_nick(source))
	end
end

function core.set_nick(nickn)
	print("== Changing nick to " .. nickn)
	push('NICK ' .. nickn)
	nickname = nickn
end

function core.uptime()
	echo( os.time() - startuptime .. " seconds uptime." )
end

function core.list_auths()
	local ausers = ""
	for i,v in ipairs(authlist) do
		ausers = ausers .. " | " .. v
	end
	echo (ctcp_color(12) .. "Authorized users: " .. ausers)
end

table.insert(authlist,masterauth)

push_reaction("listauths",true,0,false,"function",core.list_auths,"!listauths - Prints every authed user.")
push_reaction("uptime",false,0,false,"function",core.uptime,"!uptime - Outputs bot's uptime in seconds.")
push_reaction("listcmd",false,0,false,"function",core.list_cmd,"!listcmd - Lists available commands.")
push_reaction("leave",false,1,false,"function",core.leave,"!leave <channel> - Commands bot to leave given channel.")
push_reaction("auth",false,1,false,"function",core.do_auth,"!auth <auth pass> - Authorizes yourself with bot for running priviledged commands.  Please PM this to the bot with /msg <botname> !auth <pass> so it is not revealed to other users.")
push_reaction("fauth",true,1,false,"function",core.force_auth,"!fauth <username> - Authorizes specified user with the bot.")
push_reaction("die",true,0,false,"function",core.die,"!die - Disconnects the bot from the server.")
push_reaction("join",true,1,false,"function",core.join,"!join <channel> - Tells the bot to join the specified channel.")
push_reaction("chatterbox",true,1,false,"dynamic","noisy = arglist[1]","!chatterbox <0|1> - Toggles random bot chat (unimplemented)")
push_reaction("rename",true,1,false,"function",core.set_nick,"!rename <nickname> - Renames the bot to specified nick.")
push_reaction("setpass",true,1,false,"dynamic","masterpass = arglist[1]")
push_reaction("load_module",true,1,false,"function",require_mod,"!load_module <module name> - Loads specified module.")
push_reaction("unload_module",true,1,false,"function",unload_module,"!unload_module <module name> - Unloads specified module.")
push_reaction("colormode",true,1,false,"dynamic","color_mode = tonumber(arglist[1])")
push_reaction("help",false,1,false,"function",core.get_help,"Retrieves help for given command.")