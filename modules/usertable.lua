chandata = {}
-- source command target text [1][2][3][4]etc

----Returns a table with members nick, mask, and channel{}
--usage: 	v = find_user('NewbLuck')
--		if v then print('Found NewbLuck') end
function find_user(fnick,fchan)
	toreturn = {}
	toreturn.nick = ""
	toreturn.mask = ""
	toreturn.mode = ""
	toreturn.channel = {}
	if fchan then
		if type(chandata[fchan][fnick]) == "table" then
			toreturn.nick = fnick
			toreturn.mask = chandata[tchan][fnick].mask
			toreturn.mode = chandata[tchan][fnick].mode
			table.insert(toreturn.channel,tchan)
		end
	
	else
		for tchan,dat in pairs(chandata) do
			if type(chandata[tchan][fnick]) == "table" then 
					toreturn.nick = fnick
					toreturn.mask = chandata[tchan][fnick].mask
					toreturn.mode = chandata[tchan][fnick].mode
					table.insert(toreturn.channel,tchan)
			end
		end
	end

	if toreturn.nick ~= "" then return toreturn end
	return nil
end



function user_hook(indata)

	if indata.command == "JOIN" then
		if string.lower(mask_to_nick(source)) == string.lower(nickname) then
			chandata[indata.text] = {}
		else
				tchan = indata.text
				tnick = mask_to_nick(indata.source)
				tmask = mask_to_end(indata.source)
				chandata[tchan][tnick] = {}
				chandata[tchan][tnick].mode = "none"
				chandata[tchan][tnick].mask = tmask
		end
		
	end
	
	if indata.command == "PART" then
		tnick = mask_to_nick(indata.source)
		tchan = indata.target
		if string.lower(tnick) == string.lower(nickname) then
			chandata[tchan] = nil
		else
			for tchan,dat in pairs(chandata) do
				if type(chandata[tchan][tnick]) == "table" then 
						chandata[tchan][tnick] = nil
				end
			end
		end
	end
	
	if indata.command == "MODE" then
		if indata.text == "" then
			tchan = indata.target
			modes = indata[1]
			index = 2
			whichway = "oops"
			for i=1,#modes,1 do
				current = string.sub(modes,i,i)
				if current == "+" then
					whichway = "add"
				elseif current == "-" then
					whichway = "subtract"
				else
					if current =="o" then
						if whichway == "add" then chandata[tchan][ indata[index] ].mode = "op" end
						if whichway == "subtract" then chandata[tchan][ indata[index] ].mode = "none" end
						if whichway == "oops" then print("Invalid mode operator detected.") end
					end
					index = index + 1
				end
			
			end
		end	
	end

	if indata.command == "353" then --get userlist
		
		--Im being a bit lazy about this block...  the only status we need to worry about for now is op.
		--Later on when things like this are more critical to the project, I will make it worry about the other modes.


		fromchan = indata[2]
		for chunk in string.gmatch(" " .. indata.text," [%a%d%p]+") do
			chunk = string.sub(chunk,2)
			optest = string.sub(chunk,1,1)
			opmode = "none"
			if optest == "~" then opmode = "owner" end
			if optest == "&" then opmode = "sop" end
			if optest == "@" then opmode = "op" end
			if optest == "%" then opmode = "hop" end
			if optest == "+" then opmode = "voice" end
			if opmode ~= "none" then chunk = string.sub(chunk,2) end
			if opmode ~= "op" then opmode = "none" end
			if type(chandata[fromchan][chunk]) == "nil" then
				chandata[fromchan][chunk] = {}
				chandata[fromchan][chunk].mode = opmode
				chandata[fromchan][chunk].mask = ""
			end
		end
		push("WHO " .. fromchan)
		--chandata[fromchan]
	end

	if indata.command == "352" then  --WHO parsing
		usern = indata[5]
		hmask = indata[3]
		tchan = indata[1]
		for k,v in pairs(chandata[tchan]) do
			if k == usern then chandata[tchan][k].mask = hmask end
		end
	end

	if indata.command == "NICK" then
		oldn = mask_to_nick(indata.source)
		newn = indata.text
		
		for chn,dat in pairs(chandata) do
			if type(chandata[chn][oldn]) == "table" then 
					chandata[chn][newn] = {}
					chandata[chn][newn].mask = chandata[chn][oldn].mask
					chandata[chn][newn].mode = chandata[chn][oldn].mode
					chandata[chn][oldn] = nil
			end
		end
	end
	
	if indata.command == "376" and join_on_connect then core.join(join_on_connect) end
	
	if indata.command == "433" then 
		print("== Nick taken. Appending _")
		nickname = nickname .. "_"
		core.set_nick(nickname)
		set_trigger("renick",10,function () nickname = string.sub(nickname,1,#nickname - 1); core.set_nick(nickname) end, "die")
	end
	
	
	
end



add_hook("parse_raw", "usertables", user_hook)




