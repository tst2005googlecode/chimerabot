<<<<<<< .mine
chatlog = {}

webroot = "webroot" --Set to your subdirectory that holds the root of webpage.
web_running = false
lb = "<br>\n"

--Hello
function open_server()
	web_server = nil
	web_server = socket.tcp()
	web_server:bind('*', 80)
	web_server:settimeout(0)
	web_server:listen()
	web_running = true
	print("== Webserver started.")
	echo(ctcp_color(12) .. "== Webserver initalized.")
end
--Goodbye
function close_server()
	web_running = false
	web_server:close()
	print("== Webserver terminated.")
	echo(ctcp_color(12) .. "== Webserver terminated.")

end

--This eats lines that <LUA> is found in and runs the stuff after the tag.
function run_lua_function(client, inline)
	callstate, callerror = pcall(loadstring(inline), function () end)
	if callstate == false then 
		client:send(lb .. "ERROR: " .. callerror .. lb)
	end
end

--This is a delicious 404, you must eat it.
function throw_404(client)
	client:send("HTTP/1.0 404 Not Found\n\n")
	send_ascii(client, webroot .. "/404.html")
end

function trim_whitespace(totrim)
	local spot = string.find(totrim,"[^%s]",1) or 1
	return string.sub(totrim,spot)
end

--Push some ascii data (file)
function send_ascii(client,file)
	rfile,err = io.open(file,"r")
	if rfile ~= nil then
		readaslua = false
		for inline in rfile:lines() do
			if string.find(inline,"<[lL][uU][aA]>",1) then 
				lcmdstring = ""
				readaslua = true
				local startpos = string.find(inline,"<[lL][uU][aA]>",1)
				pretag = string.sub(inline,1,startpos-1)
				inline = string.sub(inline,startpos + 5)
				client:send(pretag) 
			end
			if string.find(inline,"<%/[lL][uU][aA]>",1) then 
				readaslua = false
				local endpos = string.find(inline,"<%/[lL][uU][aA]>",1)
				pretag = string.sub(inline,1,endpos-1)
				inline = string.sub(inline,endpos + 6)
				pretag = trim_whitespace(pretag)
				lcmdstring = lcmdstring .. " " .. pretag 
				run_lua_function(client, lcmdstring)
			end

			if readaslua == false then 
				client:send(inline .. "\n") 
			else
				lcmdstring = lcmdstring .. " " .. trim_whitespace(inline)
			end

		end
	else
		throw_404(client)
	end
	rfile:close()
end

--Push some binary data (file)
function send_binary(client,file)
	rfile,err = io.open(file,"rb")
	if rfile ~= nil then
		data = rfile:read("*all")
		client:send(data)
	else
		throw_404(client)
	end
	rfile:close()
end

--Horribly shitty way to do this lol, will fix later (and add proper mime types etc.)
function do_get(client,web_target)

	if web_target == "/" then web_target = web_target .. "/index.html" end
	web_target = webroot .. web_target
	
	if string.find(web_target,".html",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".htm",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".txt",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".css",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".bs",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".jpg",1,true) then send_binary(client,web_target);return end
	if string.find(web_target,".jpeg",1,true) then send_binary(client,web_target);return end
	if string.find(web_target,".png",1,true) then send_binary(client,web_target);return end
	if string.find(web_target,".gif",1,true) then send_binary(client,web_target);return end
	if string.find(web_target,".ico",1,true) then send_binary(client,web_target);return end

	throw_404(client)
	
end

function handle_post(postlist)
	
	for i,v in ipairs(postlist) do
		local pos = string.find(v,"=",1)
		local lpart = string.sub(v,1,pos-1)
		local rpart = string.sub(v,pos+1)
		rpart = '"' .. rpart .. '"'
		print(lpart .. " " .. rpart)
		poststr = lpart .. " = " .. rpart
		
		callstate, callerror = pcall(loadstring(poststr), function () end)
		if callstate == false then 
			print("ERROR: " .. callerror)
		end
	end
	
	if d_sayline ~= nil then
		print(d_sayline .. " " .. d_channel)
		echo(d_sayline,d_channel)
	end
		
		
end

--Roll on our server handling func
function on_web_cycle()

	if (web_running == true) then

		client,werr = web_server:accept() --Check for a client needing stuff
		web_server:settimeout(0) --Noblock
		if werr == nil then --Client ready?
		  local line, err = client:receive() --Check his request

			if not err then --We have a valid line?
				client:settimeout(10) 
				print(line)
				comd, leftover = core.lop(line) --Chop out command...
				target_file, leftover = core.lop(leftover) --and target, toss the HTTP version crap.
				
				line, err = client:receive()
				while(err == nil and line ~= "") do  --Scrub out the rest
					line, err = client:receive()
					print(line)
				end
	
				if comd == "GET" then do_get(client,target_file) end --Get? Then give.
				if comd == "POST" then --Post? Lets grab our fields and content.
					print("POST DATA\n")
						client:settimeout(.3)
					postlist = nil
					postlist = {}
					line, err = client:receive()
					print(line)
					while(err == nil and line ~= "") do 
						print(line)
						table.insert(postlist,line)
						line, err = client:receive()
					end
					handle_post(postlist)
					client:send("HTTP/1.0 200 OK\n\n")
					do_get(client,target_file)
				end
								
			end
			client:settimeout(10)
			client:close()
		end
	web_server:settimeout(0) --Do we need this? lol...  Leaving it for now, not hurting anything.
	end


end

push_reaction("webstart",true,0,false,"function",open_server,"!webstart - Starts the web server.")
push_reaction("webkill",true,0,false,"function",close_server,"!webkill - Kills the web server.")
add_hook("cycle","web",on_web_cycle)

--========================================================================================

--Placing all the functions i need in html here...  Load dynamically later?--
--Also, rewrite lua tag thing to accept blocks and lines with open and close tags <lua> </lua>
function dump_channels(client)
	
	for chan,dat in pairs(chandata) do
		client:send("<hr /><br><h2>\n== IN CHANNEL " .. chan .. " ==</h2>".. lb)
		for k,v in pairs(dat) do
			client:send(k .. lb)
		end
	end
	
end

function logchat(push)
	
	toinsert = {channel = push.target, source = mask_to_nick(push.source), text = push.text }
	table.insert(chatlog,1,toinsert)
	if #chatlog > 50 then table.remove(chatlog) end
end
add_hook("parse_raw", "chatlog",logchat)

function dump_log(client)
	
	for x,v in ipairs(chatlog) do
		client:send("[" .. v.channel .. 
		"] " .. v.source .. 
		">  " .. v.text 
		.. lb .. "\n")
	end

end
=======
chatlog = {}

webroot = "webroot" --Set to your subdirectory that holds the root of webpage.
web_running = false
lb = "<br>\n"

--Hello
function open_server()
	web_server = nil
	web_server = socket.tcp()
	web_server:bind('*', 80)
	web_server:settimeout(0)
	web_server:listen()
	web_running = true
	print("== Webserver started.")
	echo(ctcp_color(12) .. "== Webserver initalized.")
end
--Goodbye
function close_server()
	web_running = false
	web_server:close()
	print("== Webserver terminated.")
	echo(ctcp_color(12) .. "== Webserver terminated.")

end

--This eats lines that <LUA> is found in and runs the stuff after the tag.
function run_lua_function(client, inline)
	startpos = string.find(inline,"<LUA>",1)
	cfunc = string.sub(inline,startpos)
	trash,cfunc = lop(cfunc)
	cfunc,trash = lop(cfunc)
	
	callstate, callerror = pcall(loadstring(cfunc), function () end)
	if callstate == false then 
		client:send(lb .. "ERROR: " .. callerror .. lb)
	end
end

--This is a delicious 404, you must eat it.
function throw_404(client)
	client:send("HTTP/1.0 404 Not Found\n\n")
	send_ascii(client, webroot .. "/404.html")
end

--Push some ascii data (file)
function send_ascii(client,file)
	rfile,err = io.open(file,"r")
	if rfile ~= nil then
		for inline in rfile:lines() do
			if string.find(inline,"<LUA>",1) then 
				run_lua_function(client, inline)
			else 
				client:send(inline .. "\n") 
			end
		end
	else
		throw_404(client)
	end
	rfile:close()
end

--Push some binary data (file)
function send_binary(client,file)
	rfile,err = io.open(file,"rb")
	if rfile ~= nil then
		data = rfile:read("*all")
		client:send(data)
	else
		throw_404(client)
	end
	rfile:close()
end

--Horribly shitty way to do this lol, will fix later (and add proper mime types etc.)
function do_get(client,web_target)

	if web_target == "/" then web_target = web_target .. "/index.html" end
	web_target = webroot .. web_target
	
	if string.find(web_target,".html",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".htm",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".txt",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".css",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".bs",1,true) then send_ascii(client,web_target); return end
	if string.find(web_target,".jpg",1,true) then send_binary(client,web_target);return end
	if string.find(web_target,".jpeg",1,true) then send_binary(client,web_target);return end
	if string.find(web_target,".png",1,true) then send_binary(client,web_target);return end
	if string.find(web_target,".gif",1,true) then send_binary(client,web_target);return end
	if string.find(web_target,".ico",1,true) then send_binary(client,web_target);return end

	throw_404(client)
	
end

--Roll on our server handling func
function on_web_cycle()

	if (web_running == true) then

		client,werr = web_server:accept() --Check for a client needing stuff
		web_server:settimeout(0) --Noblock
		if werr == nil then --Client ready?
		  local line, err = client:receive() --Check his request

			if not err then --We have a valid line?
				client:settimeout(10) 
				comd, leftover = lop(line) --Chop out command...
				target_file, leftover = lop(leftover) --and target, toss the HTTP version crap.

				print(comd .. " " .. target_file) 
				if comd == "GET" then do_get(client,target_file) end --Get? Then give.
				
			end
			client:settimeout(10)
			client:close()
		end
	web_server:settimeout(0) --Do we need this? lol...  Leaving it for now, not hurting anything.
	end


end

push_reaction("webstart",true,0,false,"function",open_server,"!webstart - Starts the web server.")
push_reaction("webkill",true,0,false,"function",close_server,"!webkill - Kills the web server.")
add_hook("cycle","web",on_web_cycle)

--========================================================================================

--Placing all the functions i need in html here...  Load dynamically later?--
--Also, rewrite lua tag thing to accept blocks and lines with open and close tags <lua> </lua>
function dump_channels(client)
	
	for chan,dat in pairs(chandata) do
		client:send("<hr /><br><h2>\n== IN CHANNEL " .. chan .. " ==</h2>".. lb)
		for k,v in pairs(dat) do
			client:send(k .. lb)
		end
	end
	
end

function logchat(push)
	
	toinsert = {channel = push.target, source = mask_to_nick(push.source), text = push.text }
	table.insert(chatlog,1,toinsert)
	if #chatlog > 50 then table.remove(chatlog) end
end
add_hook("parse_raw", "chatlog",logchat)

function dump_log(client)
	
	for x,v in ipairs(chatlog) do
		client:send("[" .. v.channel .. 
		"] " .. v.source .. 
		">  " .. v.text 
		.. lb .. "\n")
	end

end
>>>>>>> .r9
